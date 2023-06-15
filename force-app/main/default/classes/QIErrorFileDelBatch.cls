/**
* author: Sharevreet Singh
* date: 06/05/2023
* description: Batch job to delete error files that are older than 12 months
    Criteria:
    --> ‘Reporting Period’ on ‘File Staging’ record is earlier than 4 quarters.
    --> ‘File Staging’ record type = QI
    --> Related error files exist on ‘File Staging’ records matching above criteria. Check 'Error_FileId__c' field
    --> Batch job to run quarterly
**/
public with sharing class QIErrorFileDelBatch implements Database.Batchable<sObject>{
    final static String MULE_ERROR = 'MuleSoft Error File';
    static Integer monthsInPast = (Integer) Quality_Indicator_Settings__mdt.getInstance('Error_File_Del_Month').Number_of_Days__c;
    static Date pastDate = Date.today().addMonths(-monthsInPast);
    static Id recordTypeId = Schema.SObjectType.File_Staging__c.getRecordTypeInfosByDeveloperName().get('QI').getRecordTypeId();

    public Database.QueryLocator start(Database.BatchableContext bc)
    {
        return Database.getQueryLocator(getQuery());
    }

    public void execute(Database.BatchableContext bc, List<File_Staging__c> scope)
    {
        if(!scope.isEmpty()) {
            Set<Id> latestConVerIds = new Set<Id>();
            List<ContentDocument> conDocToDel = new List<ContentDocument>();
            Map<Id, File_Staging__c> fileStagingRecords = new Map<Id, File_Staging__c> (scope);

            for(ContentDocumentLink cdl : [SELECT Id, ContentDocumentId, ContentDocument.LatestPublishedVersionId
                                            FROM ContentDocumentLink
                                            WHERE LinkedEntityId IN :fileStagingRecords.keySet()]) {
                latestConVerIds.add(cdl.ContentDocument.LatestPublishedVersionId);
            }

            for(ContentVersion conVer : [SELECT dohagedcare__Source__c, ContentDocumentId, CreatedDate 
                                        FROM ContentVersion 
                                        WHERE Id IN: latestConVerIds]) {
                if(conVer.dohagedcare__Source__c == MULE_ERROR) {
                    conDocToDel.add(new ContentDocument(Id = conVer.ContentDocumentId));
                }
            }

            if(conDocToDel.size() > 0) {
                try {
                    Database.delete(conDocToDel, false);
                }
                catch(Exception ex) {
                    dohagedcare.Logger.error(ex.getMessage(), ex, 'QIErrorFileDelBatch').log();
                }
            }
        }
    }

    public static String getQuery()
    {
        String query = 'SELECT Id ';
        query += 'FROM File_Staging__c ';
        query += 'WHERE RecordTypeId = \'' + recordTypeId  + '\' ';
        query += 'AND Reporting_Period__r.End_Date__c <= :pastDate';

        return query;
    }

    public void finish(Database.BatchableContext bc){
        //do nothing
    }
}