/****************************************************************************************************
* @CreatedBy   : Jamil Khaki
* @CreatedDate : 14/03/2023
* @Description : Test class for QITargetsTrigger && QITargetsTriggerHandler && QITargetsHelper
*****************************************************************************************************/

@isTest
public with sharing class QualityIndicatorTargetsTrigHandlerTest {

    static Integer updateIntData = 100;

    @TestSetup
    static void dataSetup(){
        Integer recordCount = 1;
        User testUser = TestDataFactory.createSystemAdminUser();
        
        
		System.runAs(testUser){
            // reporting period
            Reporting_Period__c rPeriod = TestDataFactory.createReportingPeriod('Quarter');
            rPeriod.Start_Date__c = (System.today() + 12 ).addMonths(-6);
            rPeriod.End_Date__c = (System.today() + 24).addMonths(-3);
            insert rPeriod;
            Reporting_Period__c rPeriodOld = TestDataFactory.createReportingPeriod('Quarter');
            rPeriodOld.Start_Date__c = (System.today() + 12 ).addMonths(-9);
            rPeriodOld.End_Date__c = rPeriod.Start_Date__c.addDays(-1);
            insert rPeriodOld;
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
            List<Quality_Indicator_Summary__c> qisRecords = TestDataFactory.createQISummaryRecords(recordCount, providers, rPeriodOld, services, serviceAccountRecords);
            insert qisRecords;
            List<Quality_Indicator_Summary__c> qisRecordsOld = TestDataFactory.createQISummaryRecords(recordCount, providers, rPeriodOld, services, serviceAccountRecords);
            insert qisRecordsOld;
            // get quality indicator detail
            List<Quality_Indicator_Details__c> qidRecords = TestDataFactory.createQIDetailRecords(recordCount, qisRecords);
            insert qidRecords;
            // get quality indicator targets
            List<Quality_Indicator_Targets__c> qitRecords = TestDataFactory.createQITargetsRecords(recordCount, rPeriod, services, qisRecords);
            insert qitRecords;
        }
    }


    @isTest
    public static void testBeforeUpdate() {

        Quality_Indicator_Targets__c qit = [SELECT Id FROM Quality_Indicator_Targets__c LIMIT 1];
    
        Test.startTest();
        qit.No_CR_One_More_PI__c = updateIntData;
        update qit;
        Test.stopTest();

        //Validate update is made correctly
        Quality_Indicator_Targets__c updatedQit = [SELECT Id, No_CR_One_More_PI__c FROM Quality_Indicator_Targets__c WHERE Id = :qit.Id];
        System.assertEquals(updateIntData, updatedQit.No_CR_One_More_PI__c);
        
    }

    @isTest
    public static void testBeforeInsert() {
        Reporting_Period__c rp = [SELECT Id FROM Reporting_Period__c ORDER BY Start_Date__c LIMIT 1];

        //Retrieve existing QIT record
        Quality_Indicator_Targets__c qit = [SELECT Id, Name, Reporting_Period__c, Service__c, Quality_Indicator_Summary__c FROM Quality_Indicator_Targets__c LIMIT 1];

        //update existing qit
        qit.No_CR_One_More_PI__c = updateIntData;
        qit.External_ID__c = '';
        qit.Reporting_Period__c = rp.Id;
        update qit;

        rp = [SELECT Id FROM Reporting_Period__c ORDER BY Start_Date__c DESC LIMIT 1];
        //setup new qit record
        Quality_Indicator_Targets__c newQit = new Quality_Indicator_Targets__c();
        newQit.Reporting_Period__c = rp.Id;
        newQit.Service__c = qit.Service__c;
        newQit.Quality_Indicator_Summary__c = qit.Quality_Indicator_Summary__c;
        
        Test.startTest();
        //Insert new qit record with same service, provider and relation as existing qit
        insert newQit;
        Test.stopTest();

        //validate inserted qit and data copied across
        Quality_Indicator_Targets__c insertedQit = [SELECT Id, No_CR_One_More_PI__c FROM Quality_Indicator_Targets__c WHERE Id = :newQit.Id];
        System.assertEquals(updateIntData,insertedQit.No_CR_One_More_PI__c);
    }
}