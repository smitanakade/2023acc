/**
* author: Sharevreet Singh
* date: 06/05/2023
* description: Test class for QIErrorFileDelBatch
**/
@isTest
public with sharing class QIErrorFileDelBatchTest {
    @TestSetup
    public static void dataSetup() {
        User testUser = TestDataFactory.createSystemAdminUser();
        System.runAs(testUser) {
            Reporting_Period__c rp = new Reporting_Period__c();
            rp.Reporting_Period_Type__c = 'Quarter';
            rp.Start_Date__c = Date.today().addMonths(-15);
            rp.End_Date__c = Date.today().addMonths(-12);
            insert rp;

            File_Staging__c fileStagingRec = new File_Staging__c();
            fileStagingRec.recordTypeId = Schema.SObjectType.File_Staging__c.getRecordTypeInfosByDeveloperName().get('QI').getRecordTypeId();
            fileStagingRec.Name = 'test';
            fileStagingRec.File_Name__c = 'test';
            fileStagingRec.Reporting_Period__c = rp.Id;
            insert fileStagingRec;

            ContentVersion contentVersion = new ContentVersion(
                    Title          = 'a picture',
                    PathOnClient   = 'Pic.jpg',
                    VersionData    = Blob.valueOf('Test Content'),
                    IsMajorVersion = true,
                    dohagedcare__Source__c = 'MuleSoft Error File');
            insert contentVersion;

            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.LinkedEntityId = fileStagingRec.Id;
            cdl.ContentDocumentId = documents[0].Id;
            cdl.ShareType = 'V';
            cdl.Visibility = 'AllUsers';
            insert cdl;
        }
    }

    @isTest
    static void deleteFileTest(){
        File_Staging__c fileStagingRec = [SELECT Id FROM File_Staging__c WHERE Name = 'test' LIMIT 1];

        List<ContentDocumentLink> cdl = [SELECT Id, ContentDocumentId, ContentDocument.LatestPublishedVersionId 
                                    FROM ContentDocumentLink 
                                    WHERE LinkedEntityId =: fileStagingRec.Id];
        System.assert(cdl.size() > 0, 'cdl should exist');
        Test.startTest();
        Database.executeBatch(new QIErrorFileDelBatch(), 200);
        Test.stopTest();
        cdl = [SELECT Id, ContentDocumentId, ContentDocument.LatestPublishedVersionId 
                FROM ContentDocumentLink 
                WHERE LinkedEntityId =: fileStagingRec.Id];
        System.assert(cdl.size() == 0, 'cdl should not exist');
    }
}