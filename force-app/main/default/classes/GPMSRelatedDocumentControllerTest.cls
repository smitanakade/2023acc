@IsTest
public class GPMSRelatedDocumentControllerTest {
    
    static void setup() {
        Account acc = new Account(Name = 'TestAcct0',Incorporation_ID_Type__c='Taken to be Incorporated',Prospective_Provider__c='');
        acc.Purpose__c = 'Government';
        acc.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Approved_Provider').getRecordTypeId();
        insert acc;

        ContentVersion cv = new ContentVersion();
        cv.Description  = 'test description';
        cv.PathOnClient ='test_file.txt';
        cv.Title = 'test file '+DateTime.now();
        cv.versiondata=Blob.valueOf('test file body');
        cv.Received_Date__c = System.today().addDays(-1);
        insert cv;

        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id].ContentDocumentId;
        cdl.LinkedEntityId =acc.Id;
        cdl.ShareType = 'V';
        insert cdl;

    }

    @isTest static void testGetRelatedDocuments() {
        User gpmsUser = TestDataFactory.createGPMSTestUser();
        System.runAs(gpmsUser)
        {
            Test.startTest();
            setup();
        Account acct = [SELECT Id FROM Account WHERE Name='TestAcct0' LIMIT 1];
        GPMSRelatedDocumentController.RelatedDocument documents =  GPMSRelatedDocumentController.getRelatedDocuments(acct.Id);
        System.assertEquals(documents.documentsSize, 1);
            Test.stopTest();
        }
    }

    @isTest static void testUpdateRelatedDocument() {
        User gpmsUser = TestDataFactory.createGPMSTestUser();
        System.runAs(gpmsUser)
        {
            Test.startTest();
            setup();
        Account acct = [SELECT Id FROM Account WHERE Name='TestAcct0' LIMIT 1];
        GPMSRelatedDocumentController.RelatedDocument documentResult =  GPMSRelatedDocumentController.getRelatedDocuments(acct.Id);
        List<ContentVersion> docs = documentResult.documents;
        for (ContentVersion doc : docs) {
            doc.Received_Date__c = System.today();
        }
        GPMSRelatedDocumentController.updateRelatedDocument((Object)docs);
        documentResult =  GPMSRelatedDocumentController.getRelatedDocuments(acct.Id);
        System.assertEquals(documentResult.documentsSize, 1);
        System.assertEquals(documentResult.documents[0].Received_Date__c, System.today());
            Test.stopTest();
        }
    }

    @isTest static void testDeleteRelatedDocument() {
        User gpmsUser = TestDataFactory.createGPMSTestUser();
        System.runAs(gpmsUser)
        {
            Test.startTest();
            setup();
        Account acct = [SELECT Id FROM Account WHERE Name='TestAcct0' LIMIT 1];
        GPMSRelatedDocumentController.RelatedDocument documentResult =  GPMSRelatedDocumentController.getRelatedDocuments(acct.Id);
        System.assertEquals(documentResult.documentsSize, 1);
        String a = GPMSRelatedDocumentController.deleteRelatedDocument(documentResult.documents[0].ContentDocumentId);
        documentResult =  GPMSRelatedDocumentController.getRelatedDocuments(acct.Id);
        System.assertEquals(documentResult.documentsSize, 0);
            Test.stopTest();
        }
    }

}