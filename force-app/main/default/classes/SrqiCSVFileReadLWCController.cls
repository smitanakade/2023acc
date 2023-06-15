/**
 * @author Rami Zuhairi
 * @date 06/2022
 * @objects Reporting_Period__c, ContentDocument, File_Staging__c
 * @description developed APEX class for file upload LWC component that will read values of both CER and QI and insert the value to file staging.
 */
public with sharing class SrqiCSVFileReadLWCController {
    // Method to get the Current year of Reporting_Period
    @AuraEnabled(Cacheable=true)
    public static List<Reporting_Period__c> getRecordsRP() {
        List<Reporting_Period__c> nameRPList;
        try {
            nameRPList = [
               SELECT Reporting_Period_Short__c FROM Reporting_Period__c Where Current_Reporting_Period__c   = true AND Reporting_Period_Type__c = 'Year' ORDER BY Reporting_Period__c DESC LIMIT 1
            ];
            return nameRPList;
        } catch (Exception ex) {
            dohagedcare.Logger.error(ex.getMessage(), ex, 'QISR').log();
            throw new AuraHandledException('Error in getting reporting period. Please refresh page or contact system administrator');
        }
    }

    @AuraEnabled
    public static List<File_Staging__c> insertFileEntryFields(
        Id contentDocumentId,
        Id reportingPeriodId,
        String hdpFileRefNum
    ) {
        try {
            ContentVersion contentVersionObj = [
                SELECT ContentDocumentId, CreatedById, Title, CreatedDate
                FROM ContentVersion
                WHERE ContentDocumentId = :contentDocumentId
            ];

            List<File_Staging__c> fsList = new List<File_Staging__c>();
           	// Adding record type as a part of 308014 requirment
            File_Staging__c fileStatingObj = new File_Staging__c();
            Id ceiRecordTypeID = Schema.SObjectType.File_Staging__c.getRecordTypeInfosByName().get('CEI').getRecordTypeId();

            fileStatingObj.File_Id__c = contentVersionObj.ContentDocumentId;
            fileStatingObj.OwnerId = contentVersionObj.CreatedById;
            fileStatingObj.Name = contentVersionObj.Title;
            fileStatingObj.File_Name__c = contentVersionObj.Title;
            fileStatingObj.File_CreatedDate__c = contentVersionObj.CreatedDate;
            fileStatingObj.Status__c = 'Ready To Publish';
            fileStatingObj.Reporting_Period__c = reportingPeriodId;
            fileStatingObj.Reporting_Category__c = 'CEI';
            fileStatingObj.RecordTypeId = ceiRecordTypeID;
            fileStatingObj.HDP_File_Ref__c = hdpFileRefNum;
            fsList.add(fileStatingObj);

            if (!fsList.isEmpty()) {
                insert fsList;
                ContentDocumentLink cDocLink = new ContentDocumentLink();
                cDocLink.ContentDocumentId = contentDocumentId;//Add ContentDocumentId
                cDocLink.LinkedEntityId = fsList[0].Id;//Add attachment parentId
                cDocLink.ShareType = 'I';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
                cDocLink.Visibility = 'InternalUsers';//AllUsers, InternalUsers, SharedUsers
                insert cDocLink;
            }
            return fsList;
        } catch (Exception ex) {
            dohagedcare.Logger.error(ex.getMessage(), ex, 'QISR').log();
            throw new AuraHandledException('Error in updating staging file. Please try again or contact system administrator.');
        }
    }
}
