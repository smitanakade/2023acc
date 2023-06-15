/**
* author: Daniel Clift
* date: 28/09/2022
* description: Test class for ConsumerExperienceReportTriggerHandler
**/

@isTest
public with sharing class CERTriggerHandlerTest {
    @TestSetup
    public static void dataSetup() {
        User gpmsUser = TestDataFactory.createGPMSTestUser();

        Test.startTest();
        System.runAs(gpmsUser)
        {
        
            Integer recordCount = 20;
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
            // get consumer experience reports
            List<SRQI_CER__c> cerRecords = TestDataFactory.createCERRecords(recordCount, serviceAccountRecords, providers, services, rPeriod);
            insert cerRecords;
            // get service complaince history
            List<Service_Compliance_History__c> schRecords = TestDataFactory.createServiceComplianceHistory(recordCount);
            insert schRecords;
            // get star rating history records
            List<STAR_Rating_History__c> srhRecords = TestDataFactory.createStarRatingHistoryRecords(recordCount, services, providers, rPeriod);
            for(Integer i = 0; i < srhRecords.size(); i++) {
                srhRecords[i].Consumer_Experience_Id__c = cerRecords[i].Id;
                srhRecords[i].Service_Compliance_Id__c = schRecords[i].Id;
                srhRecords[i].Rating_Type__c = math.mod(i,2) == 0 ? 'New Rating' : 'Current Rating';
            }
            insert srhRecords;
        	
       }
       Test.stopTest();
    }

    @isTest
    public static void testPublishedStatus() {
        
        List<SRQI_CER__c> cerList = [SELECT Id, Name, Availability_Status__c, Rating_Type__c, Service__c FROM SRQI_CER__c LIMIT 20];
        System.debug(cerList);
        for(SRQI_CER__c cer : cerList) {
            cer.Availability_Status__c = 'Draft';
            cer.Rating_Type__c = 'New Rating';
        }
        update cerList;

        	Test.startTest();
        for (SRQI_CER__c cer : cerList) {
            cer.Availability_Status__c = 'Published';
        }
        update cerList;
        	test.stopTest();
        
        AggregateResult count = [SELECT COUNT(Id) FROM SRQI_CER__c WHERE Availability_Status__c = 'Published' GROUP BY Availability_Status__c  LIMIT 20];

        System.assertEquals(20, count.get('expr0'), 'The number of published records is incorrect');
    }

    @isTest
    public static void testLiveStatus() {
        List<SRQI_CER__c> cerList = [SELECT Id, Name, Availability_Status__c, Rating_Type__c, Service__c FROM SRQI_CER__c LIMIT 20];
        System.debug(cerList);
        for(SRQI_CER__c cer : cerList) {
            cer.Availability_Status__c = 'Published';
            cer.Rating_Type__c = 'Current Rating';
        }
        update cerList;
        	Test.startTest();
        for (SRQI_CER__c cer : cerList) {
            cer.Availability_Status__c = 'Live';
        }
        update cerList;
        	test.stopTest();
        
        AggregateResult count = [SELECT COUNT(Id) FROM SRQI_CER__c WHERE Availability_Status__c = 'LIVE' GROUP BY Availability_Status__c  LIMIT 20];

        System.assertEquals(20, count.get('expr0'), 'The number of live records is incorrect');
    }

    @isTest
    public static void testCurrentRating() {
        SRQI_CER__c cerCurrent = [SELECT Id, Name, Availability_Status__c, Rating_Type__c, Reporting_Period__c, Service_Account__c, Service__c FROM SRQI_CER__c LIMIT 1];
        cerCurrent.Availability_Status__c = 'LIVE';
        cerCurrent.Rating_Type__c = 'Current Rating';
        update cerCurrent;

        SRQI_CER__c cerNewCurrent = new SRQI_CER__c();
        cerNewCurrent.Availability_Status__c = 'Published';
        cerNewCurrent.Rating_Type__c = 'New Rating';
        cerNewCurrent.Reporting_Period__c = cerCurrent.Reporting_Period__c;
        cerNewCurrent.Service_Account__c = cerCurrent.Service_Account__c;
        cerNewCurrent.Service__c = cerCurrent.Service__c;
        insert cerNewCurrent;

        
        	Test.startTest();
        cerNewCurrent.Availability_Status__c = 'LIVE';
        update cerNewCurrent;
        	test.stopTest();
        
    }
}