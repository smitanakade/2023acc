@isTest
public with sharing class QiFileUploadControllerTest {
    @TestSetup
    static void dataSetup() {
        User testUser = TestDataFactory.createSystemAdminUser();
        Integer currentYear = System.Today().year();
        Integer lastYear = currentYear - 1;
        System.runAs(testUser) {
            insert new Contentversion(
                Title = 'Quality indicator file upload template',
                PathOnClient = 'test',
                VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body')
            );
            List<Reporting_Period__c> quarters = new List<Reporting_Period__c>();
            // create Q1
            Reporting_Period__c q1 = new Reporting_Period__c();
            q1.Reporting_Period_Type__c = 'Quarter';
            q1.Start_Date__c = Date.newInstance(lastYear, 7, 1);
            q1.End_Date__c = Date.newInstance(lastYear, 9, 31);
            q1.QI_Submission_Due_Dt__c = Date.newInstance(lastYear, 10, 21);
            quarters.add(q1);

            // create Q2
            Reporting_Period__c q2 = new Reporting_Period__c();
            q2.Reporting_Period_Type__c = 'Quarter';
            q2.Start_Date__c = Date.newInstance(lastYear, 10, 1);
            q2.End_Date__c = Date.newInstance(lastYear, 12, 31);
            q2.QI_Submission_Due_Dt__c = Date.newInstance(currentYear, 1, 21);
            quarters.add(q2);

            // create Q3
            Reporting_Period__c q3 = new Reporting_Period__c();
            q3.Reporting_Period_Type__c = 'Quarter';
            q3.Start_Date__c = Date.newInstance(currentYear, 1, 1);
            q3.End_Date__c = Date.newInstance(currentYear, 3, 31);
            q3.QI_Submission_Due_Dt__c = Date.newInstance(currentYear, 4, 21);
            quarters.add(q3);

            // create Q4
            Reporting_Period__c q4 = new Reporting_Period__c();
            q4.Reporting_Period_Type__c = 'Quarter';
            q4.Start_Date__c = Date.newInstance(currentYear, 4, 1);
            q4.End_Date__c = Date.newInstance(currentYear, 6, 31);
            q4.QI_Submission_Due_Dt__c = Date.newInstance(currentYear, 7, 21);
            quarters.add(q4);

            insert quarters;
        }
    }

    @isTest static void testGetOrgNameWhenNotExists() {
        // Create contact that is not linked to an approved provider or benchmarking org
        String agedCareOrgId = TestDataFactory.createACO();
        List<Account> accounts = [SELECT Id FROM Account WHERE Id = :agedCareOrgId];
        List<Contact> contacts = TestDataFactory.createContact(1, accounts);
        insert contacts;

        try {
            String orgName = QiFileUploadController.getOrgName(contacts.get(0).Id);
            Assert.fail();
        } catch (Exception ex) {
            Assert.areEqual('System.AuraHandledException', ex.getTypeName());
        }
    }

    @isTest static void testGetOrgNameWhenExists() {
        // Create contact linked to an approved provider
        List<Account> providers = TestDataFactory.createProviderRecords(1);
        insert providers;
        List<Contact> contacts = TestDataFactory.createContact(1, providers);
        insert contacts;

        String orgName = QiFileUploadController.getOrgName(contacts.get(0).Id);

        Assert.isNotNull(orgName);
    }
}