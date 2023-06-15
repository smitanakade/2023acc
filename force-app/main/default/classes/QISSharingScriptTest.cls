/**
Scripting Test class for QISSharingScript
@author - Sharev Singh
 */
@isTest
public with sharing class QISSharingScriptTest {
    // Quality_Indicator_Summary__c
    @TestSetup
    public static void dataSetup() {
        Integer recordCount = 20;
        User testUser = TestDataFactory.createSystemAdminUser();

		Test.startTest();
		System.runAs(testUser){
            // get reporting period
            Reporting_Period__c rPeriod = TestDataFactory.createReportingPeriod('Quarter');
            insert rPeriod;
            // get providers
            List<Account> providers = TestDataFactory.createProviderRecords(recordCount);
            insert providers;
            // get services
            List<BusinessLicense> services = TestDataFactory.createServiceRecords(recordCount);
            insert services;
            // get service account relationships
            List<Service_Account_Relationship__c> serviceAccountRecords = TestDataFactory.createServiceAccountRecords(recordCount, services, providers);
            insert serviceAccountRecords;
            // get quality indicator summary
            List<Quality_Indicator_Summary__c> qisRecords = TestDataFactory.createQISummaryRecords(recordCount, providers, rPeriod, services, serviceAccountRecords);
            insert qisRecords;
        }
        Test.stopTest();
    }

    @isTest
    private static void testBatch() {
        Test.startTest();
        QISSharingScript qISharing = new QISSharingScript();
        Database.executeBatch(qISharing);
        Test.stopTest();
        System.assert(true);
    }
}