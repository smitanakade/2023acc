/****************************************************************************************************
* @CreatedBy   : Daniel Clift
* @CreatedDate : 01/02/2023
* @Description : Test class for QualityIndicatorDetailsTrigger && QualityIndicatorDetailsTriggerHandler
*****************************************************************************************************/
@isTest
public with sharing class QualityIndicatorDetailsTrigHandlerTest {

    @TestSetup
    static void dataSetup(){
        Integer recordCount = 2;
        User testUser = TestDataFactory.createSystemAdminUser();
        
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
            List<Quality_Indicator_Details__c> qidRecords = TestDataFactory.createQIDetailRecords(10, qisRecords);
            List<String> recordTypes = new List<String>{'Pressure_Injuries', 'Physical_Restraint', 'Unplanned_Weight_Loss', 'Falls_and_Major_Injury', 'Medication_Management'};
            for(Integer i = 0; i < qidRecords.size(); i++) {
                if(i < 5) {
                    String recordId = Schema.SObjectType.Quality_Indicator_Details__c.getRecordTypeInfosByDeveloperName().get(recordTypes[i]).getRecordTypeId();
                    qidRecords[i].RecordTypeId = recordId;
                }
                else {
                    Integer k = i - 5;
                    String recordId = Schema.SObjectType.Quality_Indicator_Details__c.getRecordTypeInfosByDeveloperName().get(recordTypes[k]).getRecordTypeId();
                    qidRecords[i].RecordTypeId = recordId;
                }
            }
            insert qidRecords;
        }
    }
    @isTest
    public static void testBeforeUpdate() {

        Quality_Indicator_Details__c qid = [SELECT Id, Status__c FROM Quality_Indicator_Details__c LIMIT 1];
        qid.Status__c = 'Not Started';

        Test.startTest();
        update qid;
        Test.stopTest();
        
    }
}