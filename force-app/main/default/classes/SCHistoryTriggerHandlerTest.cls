/**
* author: Daniel Clift
* date: 28/09/2022
* description: test class for ServiceComplianceHistoryTriggerHandler
**/
@isTest
public with sharing class SCHistoryTriggerHandlerTest {
    // Service_Compliance_History__c
    @TestSetup
    public static void dataSetup() {
        Integer recordCount = 20;
        User testUser = TestDataFactory.createSystemAdminUser();

		Test.startTest();
		System.runAs(testUser){
            // get reporting period
            Reporting_Period__c rPeriod = TestDataFactory.createReportingPeriod('Quarter');
            insert rPeriod;
            // get accounts
            List<Account> providers = TestDataFactory.createProviderRecords(recordCount);
            insert providers;
            // get services
            List<BusinessLicense> services = TestDataFactory.createServiceRecords(recordCount);
            insert services;
            // get service account relationships
            List<Service_Account_Relationship__c> serviceAccountRecords = TestDataFactory.createServiceAccountRecords(recordCount, services, providers);
            insert serviceAccountRecords;
            // get Service Compliance History
            List<Service_Compliance_History__c> schRecords = TestDataFactory.createServiceComplianceHistory(recordCount);
            insert schRecords;
            // get star rating history
            List<STAR_Rating_History__c> srhRecords = TestDataFactory.createStarRatingHistoryRecords(recordCount, services, providers, rPeriod);
            for(Integer i = 0; i < srhRecords.size(); i++) {
                srhRecords[i].Service_Compliance_Id__c = schRecords[i].Id;
                srhRecords[i].Rating_Type__c = math.mod(i,2) == 0 ? 'New Rating' : 'Current Rating';
            }
            insert srhRecords;
        }
        Test.stopTest();
    }

    @isTest
    public static void testLiveStatus() {
        List<Service_Compliance_History__c> scrList = [SELECT Id, Name, Availability_Status__c, Rating_Type__c, Service__c FROM Service_Compliance_History__c LIMIT 20];
        System.debug(scrList);
        for(Service_Compliance_History__c scr : scrList) {
            scr.Availability_Status__c = 'Published';
            scr.Rating_Type__c = 'New Rating';
        }
        update scrList;
        test.startTest();
        for (Service_Compliance_History__c scr : scrList) {
            scr.Availability_Status__c = 'Live';
        }
        update scrList;
        test.stopTest();

        AggregateResult count = [SELECT COUNT(Id) FROM Service_Compliance_History__c WHERE Availability_Status__c = 'LIVE' GROUP BY Availability_Status__c  LIMIT 20];

        System.assertEquals(20, count.get('expr0'), 'The number of live records is incorrect');
    }

    @isTest
    public static void testCurrentRating() {
        Service_Compliance_History__c schCurrent = [SELECT Id, Name, Availability_Status__c, Rating_Type__c, Service__c FROM Service_Compliance_History__c LIMIT 1];
        schCurrent.Availability_Status__c = 'LIVE';
        schCurrent.Rating_Type__c = 'Current Rating';
        update schCurrent;

        Service_Compliance_History__c schNewCurrent = new Service_Compliance_History__c();
        schNewCurrent.Availability_Status__c = 'Published';
        schNewCurrent.Rating_Type__c = 'New Rating';
        schNewCurrent.Service__c = schCurrent.Service__c;
        insert schNewCurrent;

        test.startTest();
        schNewCurrent.Availability_Status__c = 'LIVE';
        update schNewCurrent;
        test.stopTest();
    }
}