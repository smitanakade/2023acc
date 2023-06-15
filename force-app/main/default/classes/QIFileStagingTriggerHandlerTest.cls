@isTest 
private class QIFileStagingTriggerHandlerTest
{
    @TestSetup
    static void dataSetup(){
        User testAdmin = TestDataFactory.createSystemAdminUser();

        Integer recordCount = 2;
        System.runAs(testAdmin){
            //data for testFailedAfterUpdate % testReadyAfterUpdate
            // get providers
            List<Account> providers = TestDataFactory.createProviderRecords(recordCount);
            insert providers;
            // get services
            List<BusinessLicense> services = TestDataFactory.createServiceRecords(recordCount);
            insert services;
            List<Service_Account_Relationship__c> serviceAccountRecords = TestDataFactory.createServiceAccountRecords(recordCount, services, providers);
            insert serviceAccountRecords;
            //data for testFailedAfterUpdate % testReadyAfterUpdate
            File_Staging__c testData = new File_Staging__c();
            testData.Name = 'Testing Data';
            testData.File_Name__c = 'Testing Data Name';
            Reporting_Period__c reportingPeriod = TestDataFactory.createReportingPeriod('Quarter');
            insert reportingPeriod;
            User testUser = TestDataFactory.createTestUser();
            testUser.Alias = '1';
            insert testUser;
            testData.OwnerId = testUser.Id;
            testData.CreatedById = testUser.Id;
            testData.Reporting_Period__c = reportingPeriod.Id;
            testData.Status__c = 'New';
            testData.Success_Records__c = 2;
            insert testData;


            File_Staging__c testData2 = new File_Staging__c();
            testData2.OwnerId = testUser.Id;
            testData2.CreatedById = testUser.Id;
            testData2.Reporting_Period__c = reportingPeriod.Id;
            testData2.Status__c = 'New';
            testData2.Provider__c =providers[0].Id;
            testData2.File_Name__c = 'TEST FILE';
            testData2.RecordTypeId= Schema.SObjectType.File_Staging__c.getRecordTypeInfosByName().get('QI').getRecordTypeId();
            insert testData2;

            
        }

    }

    @isTest
    public static void testFailedAfterUpdate() {

        File_Staging__c fStaging = [SELECT Id, Status__c FROM File_Staging__c WHERE Name = 'Testing Data'];
        fStaging.Status__c = 'Failed';
        Test.startTest();
        update fStaging;
        System.assertEquals(1 , Limits.getEmailInvocations());
        Test.stopTest();

    }

    @isTest
    public static void testReadyAfterUpdate() {

        File_Staging__c fStaging = [SELECT Id, Status__c FROM File_Staging__c WHERE Name = 'Testing Data'];
        fStaging.Status__c = 'Ready To Publish';
        Test.startTest();
        update fStaging;
        System.assertEquals(1 , Limits.getEmailInvocations());
        Test.stopTest();

    }

    @isTest
    public static void testProccessedAfterUpdate() {

        File_Staging__c fStaging = [SELECT Id, Status__c FROM File_Staging__c WHERE Name = 'Testing Data'];
        fStaging.Status__c = 'Processed';
        Test.startTest();
        update fStaging;
        Test.stopTest();

    }



}
