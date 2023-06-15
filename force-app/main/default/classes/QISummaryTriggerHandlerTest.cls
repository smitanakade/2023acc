/**
* author: Daniel Clift
* date: 28/09/2022
* description: Test class for QualityIndicatorSummaryTriggerHandler
**/
@isTest
public with sharing class QISummaryTriggerHandlerTest {
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
            // get service complaince hisotry records
            List<Service_Compliance_History__c> schRecords = TestDataFactory.createServiceComplianceHistory(recordCount);
            insert schRecords;
            // get star rating history records
            List<STAR_Rating_History__c> srhRecords = TestDataFactory.createStarRatingHistoryRecords(recordCount, services, providers, rPeriod);
            for(Integer i = 0; i < srhRecords.size(); i++) {
                srhRecords[i].Quality_Indicator_Id__c = qisRecords[i].Id;
                srhRecords[i].Service_Compliance_Id__c = schRecords[i].Id;
                srhRecords[i].Rating_Type__c = math.mod(i,2) == 0 ? 'New Rating' : 'Current Rating';
            }
            insert srhRecords;
        }
        Test.stopTest();
    }

    @isTest
    public static void testPublishedStatus() {
        List<Quality_Indicator_Summary__c> qisList = [SELECT Id, Name, Availability_Status__c, Rating_Type__c, Service__c FROM Quality_Indicator_Summary__c LIMIT 20];
        System.debug(qisList);
        for(Quality_Indicator_Summary__c qis : qisList) {
            qis.Availability_Status__c = 'Draft';
        }
        update qisList;
        test.startTest();
        for (Quality_Indicator_Summary__c qis : qisList) {
            qis.Availability_Status__c = 'Published';
        }
        update qisList;
        test.stopTest();

        AggregateResult count = [SELECT COUNT(Id) FROM Quality_Indicator_Summary__c WHERE Availability_Status__c = 'Published' GROUP BY Availability_Status__c  LIMIT 20];

        System.assertEquals(20, count.get('expr0'), 'The number of published records is incorrect');
    }

    @isTest
    public static void testLiveStatus() {
        List<Quality_Indicator_Summary__c> qisList = [SELECT Id, Name, Availability_Status__c, Rating_Type__c, Service__c FROM Quality_Indicator_Summary__c LIMIT 20];
        System.debug(qisList);
        for(Quality_Indicator_Summary__c qis : qisList) {
            qis.Availability_Status__c = 'Published';
            qis.Rating_Type__c = 'New Rating';
        }
        update qisList;
        test.startTest();
        for (Quality_Indicator_Summary__c qis : qisList) {
            qis.Availability_Status__c = 'Live';
        }
        update qisList;
        test.stopTest();

        AggregateResult count = [SELECT COUNT(Id) FROM Quality_Indicator_Summary__c WHERE Availability_Status__c = 'LIVE' GROUP BY Availability_Status__c  LIMIT 20];

        System.assertEquals(20, count.get('expr0'), 'The number of live records is incorrect');
    }

    @isTest
    public static void testCurrentRating() {
        Quality_Indicator_Summary__c qisCurrent = [SELECT Id, Name, Availability_Status__c, Rating_Type__c, External_ID__c, Service__c, PROVIDER_ID__c, SERVICE_ACCOUNT_ID__c, REPORTING_PERIOD__c FROM Quality_Indicator_Summary__c LIMIT 1];
        qisCurrent.Availability_Status__c = 'LIVE';
        qisCurrent.Rating_Type__c = 'Current Rating';
        update qisCurrent;

        Quality_Indicator_Summary__c qisNewCurrent = new Quality_Indicator_Summary__c();
        qisNewCurrent.Availability_Status__c = 'Published';
        qisNewCurrent.Rating_Type__c = 'New Rating';
        qisNewCurrent.External_ID__c = 'ExternalId2';
        qisNewCurrent.PROVIDER_ID__c = qisCurrent.PROVIDER_ID__c;
        qisNewCurrent.Service__c = qisCurrent.Service__c;
        qisNewCurrent.SERVICE_ACCOUNT_ID__c = qisCurrent.SERVICE_ACCOUNT_ID__c;
        qisNewCurrent.Reporting_Period__c = qisCurrent.Reporting_Period__c;
        insert qisNewCurrent;

        test.startTest();
        qisNewCurrent.Availability_Status__c = 'LIVE';
        update qisNewCurrent;
        test.stopTest();
    }
}