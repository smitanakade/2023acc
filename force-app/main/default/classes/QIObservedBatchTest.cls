/**
* author: Daniel Clift
* date: 02/10/2022
* description: Test Class for QIObservedBatch, QIObservedHelper, NationalStatistics
**/
@isTest
public with sharing class QIObservedBatchTest {
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
        Database.executeBatch(new QIObservedBatch(), 200);
        Test.stopTest();
        List<National_Statistic__c> nsRecords = [SELECT Id, National_percentage_PI_Stage2__c,
                                                National_percentage_PI_Stage3__c, National_percentage_PI_Stage4__c, 
                                                National_percentage_PI_Deep_Tissue__c, National_percentage_PI_Unstageable__c, 
                                                National_percentage_significant_UWL__c, National_percentage_falls__c, 
                                                National_Percentage_falls_Major_Injury__c, National_percentage_ADL_DEC__c, 
                                                National_percentage_PIs__c, National_percentage_PI_Stage1__c
                                                FROM National_Statistic__c];
        // should only be one National_Statistic__c
        /*System.assertEquals(1, nsRecords.size(), 'There should only be one National Statistic record');
        System.assertEquals(50, nsRecords[0].National_percentage_PI_Stage2__c, 'PIS2 Percentage should be 50%');
        System.assertEquals(50, nsRecords[0].National_percentage_PI_Stage3__c, 'PIS3 Percentage should be 50%');
        System.assertEquals(50, nsRecords[0].National_percentage_PI_Stage4__c, 'PIS4 Percentage should be 50%');
        System.assertEquals(50, nsRecords[0].National_percentage_PI_Deep_Tissue__c, 'Deep Tissue Percentage should be 50%');
        System.assertEquals(50, nsRecords[0].National_percentage_PI_Unstageable__c, 'PI Unstageable Percentage should be 50%');
        System.assertEquals(50, nsRecords[0].National_percentage_significant_UWL__c, 'UPWL Percentage should be 50%');
        System.assertEquals(50, nsRecords[0].National_percentage_falls__c, 'Falls Percentage should be 50%');
        System.assertEquals(50, nsRecords[0].National_Percentage_falls_Major_Injury__c, 'Falls MI Percentage should be 50%');
        System.assertEquals(50, nsRecords[0].National_percentage_PI_Stage1__c, 'WF Stopped PC Percentage should be 50%');*/
    }
}