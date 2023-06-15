/**
 * author: Sharevreet Singh
 * date: 29/04/2023
 * description: Utility class for QI Bulk Upload
 */
public with sharing class QIBulkUploadUtility {
    private static String STATUS_NEW = 'New';
    private static String QI_RT = 'QI';

    /**
     * @description Create file staging record if doesnot exist already, invocable from flow
     * @params List<FileStagingWrapper> fileStagingWrapper
     * @return List<File_Staging__c> record
     */
    @InvocableMethod(label='Create File Staging Record' description='Returns the file staging records')
    public static List<File_Staging__c> createFileStagingRecord(List<FileStagingWrapper> fileStagingWrapper) {
        return (new List<File_Staging__c>{ createFileStagingRecord(fileStagingWrapper[0]) });
    }

    /**
     * @description Create file staging record if doesnot exist already
     * @params FileStagingWrapper
     * @return File_Staging__c record
     */
    @AuraEnabled
    public static File_Staging__c createFileStagingRecord(FileStagingWrapper fileStagingWrapper) {
        //initialize variables for flow
        Id userId = fileStagingWrapper.userId;
        Id fileStagingRecordId = fileStagingWrapper.fileStagingRecordId;
        String fileName = fileStagingWrapper.fileName;
        Id providerId = null;
        Id subReqById = null;
        Date reqReceivedDate = null;
        final Id QT_RT = Schema.SObjectType.File_Staging__c.getRecordTypeInfosByDeveloperName().get(QI_RT).getRecordTypeId();
        final String FILE_NAME_DEFAULT = 'Pending';

        //initialize variables for lwc
        if (fileStagingWrapper.userId == null) {
            userId = fileStagingWrapper.userIdAura;
            fileStagingRecordId = fileStagingWrapper.fileStagingRecordIdAura;
            fileName = fileStagingWrapper.fileNameAura;
            providerId = fileStagingWrapper.providerIdAura;
            subReqById = fileStagingWrapper.subReqByIdAura;
            reqReceivedDate = fileStagingWrapper.reqReceivedDateAura;
        }

        File_Staging__c fileStaging = new File_Staging__c();
        User user = getUser(userId);
        Id accId = providerId != null ? providerId : getAccountIdFromContactId(user.Contact.Id);

        File_Staging__c fileStagingRecord = retrieveFileStagingRecord(userId, accId);

        if (fileStagingRecord != null && ((fileStagingRecordId == null && subReqById == null) || providerId != null)) {
            //return existing user if no update is required
            return fileStagingRecord;
        } else if (fileStagingRecord == null && (fileStagingRecordId == null || providerId != null)) {
            //create record when file staging record is not provided
            fileStaging = new File_Staging__c(
                RecordTypeId = QT_RT,
                Name = user.Alias + ' ' + Datetime.now().format(),
                Status__c = STATUS_NEW,
                Reporting_Period__c = [
                    SELECT Id
                    FROM Reporting_Period__c
                    WHERE Current_Reporting_Period__c = TRUE AND Reporting_Period_Type__c = 'Quarter'
                    LIMIT 1
                ]
                .Id,
                Provider__c = providerId != null ? providerId : accId,
                Submission_Requested_By__c = subReqById != null ? subReqById : user.Contact.Id,
                File_Name__c = fileName != null ? fileName : FILE_NAME_DEFAULT,
                Request_Received_Date__c = reqReceivedDate,
                Reporting_Category__c = QI_RT
            );
        } else if (fileStagingRecordId != null) {
            //create record based on existing file staging record
            File_Staging__c fileStagingRec = retrieveFileStagingRecord(fileStagingRecordId);
            fileStaging = new File_Staging__c(
                RecordTypeId = QT_RT,
                Name = user.Alias + ' ' + Datetime.now().format(),
                Status__c = STATUS_NEW,
                Reporting_Period__c = fileStagingRec.Reporting_Period__c,
                Provider__c = fileStagingRec.Provider__c != null ? fileStagingRec.Provider__c : accId,
                Submission_Requested_By__c = fileStagingRec.Submission_Requested_By__c != null
                    ? fileStagingRec.Submission_Requested_By__c
                    : user.Contact.Id,
                File_Name__c = fileName != null ? fileName : fileStagingRec.File_Name__c,
                Reporting_Category__c = QI_RT
            );
        }

        try {
            Database.insert(fileStaging, false);
        } catch (Exception ex) {
            dohagedcare.Logger.error(ex.getMessage(), ex, 'QIBulkUploadUtility.cls').log();
        }

        return fileStaging;
    }

    private static User getUser(Id userId) {
        return [SELECT Alias, Contact.Id, Contact.AccountId FROM USER WHERE Id = :userId LIMIT 1];
    }

    // Assumption: Contact will be related to either an Approved Provider or Benchmarking Organisation, not both.
    private static Id getAccountIdFromContactId(Id contactId) {
        final String AP_RT = 'Approved_Provider';
        final String BO_RT = 'Benchmarking_Organisation';

        return [
            SELECT AccountId
            FROM AccountContactRelation
            WHERE ContactId = :contactId 
            AND IsActive = TRUE 
            AND (
                Account.RecordType.DeveloperName = :AP_RT
                OR Account.RecordType.DeveloperName = :BO_RT
            )
            LIMIT 1
        ]
        .AccountId;
    }
    /**
     * @description Retrieve file staging record if exist
     * @params User user
     * @return File_Staging__c record
     */
    public static File_Staging__c retrieveFileStagingRecord(Id userId, Id accId) {
        List<File_Staging__c> fileStaging = [
            SELECT Id, Reporting_Period__c, Reporting_Period__r.Name, File_Id__c
            FROM File_Staging__c
            WHERE Provider__c = :accId AND Status__c = :STATUS_NEW AND CreatedById = :userId AND File_Id__c = NULL
        ];
        if (fileStaging.size() > 0) {
            return fileStaging[0];
        }
        return null;
    }

    /**
     * @description Retrieve file staging record if exists
     * @params Id of File Staging Record
     * @return File_Staging__c record
     */
    public static File_Staging__c retrieveFileStagingRecord(Id fileStagingRecordId) {
        List<File_Staging__c> fileStaging = [
            SELECT
                Id,
                Reporting_Period__c,
                Reporting_Period__r.Name,
                Name,
                File_Id__c,
                File_Name__c,
                File_CreatedDate__c,
                Provider__c,
                Submission_Requested_By__c
            FROM File_Staging__c
            WHERE Id = :fileStagingRecordId
        ];
        if (fileStaging.size() > 0) {
            return fileStaging[0];
        }
        return null;
    }

    public class FileStagingWrapper {
        //used with Flow
        @InvocableVariable
        public Id userId;
        @InvocableVariable
        public Id fileStagingRecordId;
        @InvocableVariable
        public String fileName;

        //used with lwc
        @AuraEnabled
        public Id userIdAura { get; set; }
        @AuraEnabled
        public Id fileStagingRecordIdAura { get; set; }
        @AuraEnabled
        public String fileNameAura { get; set; }
        @AuraEnabled
        public Id providerIdAura { get; set; }
        @AuraEnabled
        public Id subReqByIdAura { get; set; }
        @AuraEnabled
        public Date reqReceivedDateAura { get; set; }
    }
}