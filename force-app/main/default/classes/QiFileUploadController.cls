/**
 * Author : Cyrille Jeufo
 * Date : 12/04/2023
 * Description : Controller class for QiFileUploadInstructions
 **/
public with sharing class QiFileUploadController {
    private static final String APPROVED_PROVIDER_RECORD_TYPE = 'Approved_Provider';
    private static final String BENCHMARKING_ORGANISATION_RECORD_TYPE = 'Benchmarking_Organisation';

    @AuraEnabled
    public static String getReportingPeriods(String fileStagingId) {
        String response = '';
        ReportingPeriodsResponse rpResponse = new ReportingPeriodsResponse();
        rpResponse.rpOptions = new List<ReportingPeriodsOptions>();
        try {
            Set<Id> allRPIds = new Set<Id>();
            File_Staging__c relatedFileStaging = QIBulkUploadUtility.retrieveFileStagingRecord(fileStagingId);
            List<Reporting_Period__c> reportingPeriods = getCurrentPreviousRP();
            for (Reporting_Period__c reRec : reportingPeriods) {
                rpResponse.rpOptions.add(new ReportingPeriodsOptions(reRec));
                allRPIds.add(reRec.Id);
            }
            if (relatedFileStaging.Reporting_Period__c != null) {
                Reporting_Period__c currentRp = getCurrentRP(relatedFileStaging.Reporting_Period__c);
                rpResponse.id = currentRp.Id;
                if (currentRp.Current_Reporting_Period__c) {
                    rpResponse.value = currentRp.Reporting_Period_Short__c + ' (Current quarter)';
                } else {
                    rpResponse.value = currentRp.Reporting_Period_Short__c;
                }
                ReportingPeriodsOptions currentRPOption = new ReportingPeriodsOptions(currentRp);
                if (!allRPIds.contains(currentRp.Id)) {
                    if (rpResponse.rpOptions.size() > 0) {
                        rpResponse.rpOptions.add(0, currentRPOption);
                    } else {
                        rpResponse.rpOptions.add(currentRPOption);
                    }
                }
            }
            response = JSON.serialize(rpResponse);
        } catch (Exception e) {
            dohagedcare.Logger.error(e.getMessage(), e, 'QiFileUploadController.getReportingPeriods failed').Log();
            System.debug('QiFileUploadController.getReportingPeriods Exception: ' + e.getMessage() + ' ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
        return response;
    }

    @AuraEnabled
    public static String autoSave(String fileStagingId, String reportingPeriodId) {
        String response = '';
        try {
            File_Staging__c relatedFileStaging = QIBulkUploadUtility.retrieveFileStagingRecord(fileStagingId);
            relatedFileStaging.Reporting_Period__c = reportingPeriodId;
            update relatedFileStaging;
            response = 'success';
        } catch (Exception e) {
            dohagedcare.Logger.error(e.getMessage(), e, 'QiFileUploadController.autoSave failed').Log();
            System.debug('QiFileUploadController.autoSave Exception: ' + e.getMessage() + ' ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
        return response;
    }

    @AuraEnabled
    public static String sendToTRIMExt(String fileStagingId, String uploadedFileId) {
        String response = '';
        try {
            List<dohagedcare.FileStorageUtility.FileStorageWrapper> resultList = dohagedcare.FileStorageListController.uploadFilesToTRIMExt(
                fileStagingId,
                new List<Id>{ uploadedFileId }
            );
            system.debug('QiFileUploadController.sendToTRIMExt: ' + resultList);
            if (resultList[0].status == 'Error') {
                throw QIDynamicManagementController.qiMessageException(resultList[0].statusMessage);
            } else if (resultList[0].status == 'Success') {
                response = resultList[0].statusMessage;
            }
            File_Staging__c relatedFileStaging = QIBulkUploadUtility.retrieveFileStagingRecord(fileStagingId);
            relatedFileStaging.File_Id__c = uploadedFileId;
            relatedFileStaging.File_CreatedDate__c = System.now();
            update relatedFileStaging;
        } catch (Exception e) {
            dohagedcare.Logger.error(e.getMessage(), e, 'QiFileUploadController.sendToTRIMExt failed').Log();
            System.debug('QiFileUploadController.sendToTRIMExt Exception: ' + e.getMessage() + ' ' + e.getLineNumber());
            System.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        return response;
    }
    
    @AuraEnabled
    public static String getFileStorageContentDocumentId(String fileStagingId) {
        String response = '';
        try {
            List<dohagedcare__File_Storage__c>fileStorage = [SELECT Id,dohagedcare__Content_Document_Id__c FROM dohagedcare__File_Storage__c WHERE dohagedcare__Parent_Id__c =:fileStagingId ];
            if(!fileStorage.isEmpty()){
                response = fileStorage[0].dohagedcare__Content_Document_Id__c;
            }
        } catch (Exception e) {
            dohagedcare.Logger.error(e.getMessage(), e, 'QiFileUploadController.getFileStorageContentDocumentId failed').Log();
            System.debug('QiFileUploadController.getFileStorageContentDocumentId Exception: ' + e.getMessage() + ' ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
        return response;
    }

    @AuraEnabled
    public static Boolean isExternal(String userId) {
        User currentUser = getCurrentUser(userId);
        if (currentUser != null) {
            return (currentUser.Profile.UserType == 'PowerCustomerSuccess');
        } else {
            return false;
        }
    }

    @AuraEnabled
    public static String getOrgName(Id contactId) {
        List<AccountContactRelation> accountContactRelations = [
            SELECT Account.Name 
            FROM AccountContactRelation 
            WHERE ContactId = :contactId 
            AND IsActive = TRUE
            AND (
                Account.RecordType.DeveloperName = :APPROVED_PROVIDER_RECORD_TYPE
                OR Account.RecordType.DeveloperName = :BENCHMARKING_ORGANISATION_RECORD_TYPE
            )
            LIMIT 1
        ];
        if (accountContactRelations.isEmpty()) {
            throw new AuraHandledException('No active account found');
        }
        return accountContactRelations.get(0).Account.Name;
    }

    private static List<Reporting_Period__c> getCurrentPreviousRP() {
        return [
            SELECT
                Reporting_Period_Type__c,
                QI_Submission_Due_Dt__c,
                Start_Date__c,
                End_Date__c,
                Current_Reporting_Period__c,
                Previous_Reporting_Period__c,
                Reporting_Period_Short__c
            FROM Reporting_Period__c
            WHERE
                Reporting_Period_Type__c = 'Quarter'
                AND QI_Submission_Due_Dt__c != NULL
                AND Reporting_Period_Short__c != NULL
                AND (Current_Reporting_Period__c = TRUE
                OR Previous_Reporting_Period__c = TRUE)
            ORDER BY QI_Submission_Due_Dt__c DESC
        ];
    }
    private static Reporting_Period__c getCurrentRP(String rpId) {
        return [
            SELECT
                Id,
                Reporting_Period_Type__c,
                QI_Submission_Due_Dt__c,
                Start_Date__c,
                End_Date__c,
                Current_Reporting_Period__c,
                Previous_Reporting_Period__c,
                Reporting_Period_Short__c
            FROM Reporting_Period__c
            WHERE Id = :rpId
            LIMIT 1
        ];
    }
    private static User getCurrentUser(String userId) {
        return [SELECT Id, Name, Profile.Name, Profile.UserType FROM User WHERE Id = :userId];
    }

    public class ReportingPeriodsResponse {
        @AuraEnabled
        public String value;

        @AuraEnabled
        public String id;

        @AuraEnabled
        public List<ReportingPeriodsOptions> rpOptions;
    }

    public class ReportingPeriodsOptions {
        ReportingPeriodsOptions(Reporting_Period__c rpRec) {
            id = rpRec.Id;
            if (rpRec.Current_Reporting_Period__c) {
                value = rpRec.Reporting_Period_Short__c + ' (Current quarter)';
                label = rpRec.Reporting_Period_Short__c + ' (Current quarter)';
            } else {
                value = rpRec.Reporting_Period_Short__c;
                label = rpRec.Reporting_Period_Short__c;
            }
        }

        @AuraEnabled
        public String id;

        @AuraEnabled
        public String value;

        @AuraEnabled
        public String label;
    }
}