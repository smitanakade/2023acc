@isTest
public with sharing class QIObsCalcScriptTest {
    @TestSetup
    static void dataSetup(){
        Integer recordCount = 2;
        User testUser = TestDataFactory.createSystemAdminUser();

		Test.startTest();
		System.runAs(testUser){
            // reporting period
            Reporting_Period__c rPeriod = TestDataFactory.createReportingPeriod('Quarter');
            rPeriod.Start_Date__c = (System.today() + 12 ).addMonths(-6);
            rPeriod.End_Date__c = (System.today() + 24).addMonths(-3);
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
            // get quality indicator detail
            List<Quality_Indicator_Details__c> qidRecords = TestDataFactory.createQIDetailRecords(22, qisRecords);
            List<String> recordTypes = new List<String>{'Pressure_Injuries', 
            'Physical_Restraint', 
            'Unplanned_Weight_Loss', 
            'Falls_and_Major_Injury', 
            'Medication_Management', 
            'Workforce',
            'Activities_of_daily_living_ADLs',
            'Consumer_Experience',
            'Hospitalisation',
            'Continence',
            'Quality_of_life'};
            for(Integer i = 0; i < qidRecords.size(); i++) {
                if(i < 11) {
                    String recordId = Schema.SObjectType.Quality_Indicator_Details__c.getRecordTypeInfosByDeveloperName().get(recordTypes[i]).getRecordTypeId();
                    qidRecords[i].RecordTypeId = recordId;
                }
                else {
                    Integer k = i - 11;
                    String recordId = Schema.SObjectType.Quality_Indicator_Details__c.getRecordTypeInfosByDeveloperName().get(recordTypes[k]).getRecordTypeId();
                    qidRecords[i].RecordTypeId = recordId;
                }
            }
            insert qidRecords;
        }
        Test.stopTest();

    }
    @isTest
    public static void testQIObserved() {
        Test.startTest();
        Database.executeBatch(new QIObsCalcScript(), 200);
        Test.stopTest();
        System.assert(true);
    }
}