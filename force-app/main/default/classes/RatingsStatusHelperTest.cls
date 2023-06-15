/**
* author: Daniel Clift
* date: 14/10/2022
* description: test class for RatingsStatusHelper
**/

@isTest
public with sharing class RatingsStatusHelperTest {

    @TestSetup
    public static void dataSetup(){

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
            // get Service Compliance History
            List<Service_Compliance_History__c> schRecords = TestDataFactory.createServiceComplianceHistory(recordCount);
            insert schRecords;
            // get quality indicator summary
            List<Quality_Indicator_Summary__c> qisRecords = TestDataFactory.createQISummaryRecords(recordCount, providers, rPeriod, services, serviceAccountRecords);
            insert qisRecords;
            // get consumer experience reports
            List<SRQI_CER__c> cerRecords = TestDataFactory.createCERRecords(recordCount, serviceAccountRecords, providers, services, rPeriod);
            insert cerRecords;
            // get care minutes summary
            List<Care_Minutes_Summary__c> cmsRecords = TestDataFactory.createCareMinuteSummary(recordCount, services);
            for(Integer i = 0; i < recordCount; i++){
                cmsRecords[i].Provider_Name__c = providers[i].Id;
                cmsRecords[i].Service_Account__c = serviceAccountRecords[i].Id;
            }
            insert cmsRecords;
            // get star rating history records
            List<STAR_Rating_History__c> srhRecords = TestDataFactory.createStarRatingHistoryRecords(recordCount, services, providers, rPeriod);
            for(Integer i = 0; i < srhRecords.size(); i++) {
                srhRecords[i].Care_Minutes_Id__c = cmsRecords[i].Id;
                srhRecords[i].Service_Compliance_Id__c = schRecords[i].Id;
                srhRecords[i].Quality_Indicator_Id__c = qisRecords[i].Id;
                srhRecords[i].Consumer_Experience_Id__c = cerRecords[i].Id;
                // srhRecords[i].Rating_Type__c = math.mod(i,2) == 0 ? 'New Rating' : 'Current Rating';
                srhRecords[i].Rating_Type__c = 'New Rating';
                srhRecords[i].Status__c = 'Published';
            }
            insert srhRecords;
        }
        Test.stopTest();
    }

    @isTest
    public static void testUpdateSubRatingRecords() {

        Map<String, Map<Id, String>> ratingsMap = InitiateRatingsMap();

        List<STAR_Rating_History__c> srhList = [SELECT Id, Care_Minutes_Id__c, Service_Compliance_Id__c, Quality_Indicator_Id__c, Consumer_Experience_Id__c, Rating_Type__c, Status__c FROM STAR_Rating_History__c];

        for(STAR_Rating_History__c srh : srhList) {
            if(srh.Consumer_Experience_Id__c != null) {
                ratingsMap.get('CER').put(srh.Consumer_Experience_Id__c, srh.Status__c);
            }
            if(srh.Care_Minutes_Id__c != null) {
                ratingsMap.get('CM').put(srh.Care_Minutes_Id__c, srh.Status__c);
            }
            if(srh.Quality_Indicator_Id__c != null) {
                ratingsMap.get('QI').put(srh.Quality_Indicator_Id__c, srh.Status__c);
            }
        }
        Test.startTest();
        RatingsStatusHelper.UpdateSubRatingRecords(ratingsMap);
        Test.stopTest();
		// here
        Care_Minutes_Summary__c cm = [SELECT Id, Availability_Status__c, Rating_Type__c FROM Care_Minutes_Summary__c  WHERE Id = :srhList[0].Care_Minutes_Id__c LIMIT 1];
        System.debug('cm: ' + cm);
        String assertMessage = 'Availability_Status__c should be Published';
        System.assertEquals('Published', cm.Availability_Status__c, assertMessage);
    }

    @isTest
    public static void testRatingType() {

        Test.startTest();
        // Service_Compliance_History__c
        List<Service_Compliance_History__c> schList = [SELECT Id, Availability_Status__c, Rating_Type__c, Service__c FROM Service_Compliance_History__c LIMIT 5];
        for(Service_Compliance_History__c sch : schList) {
            sch.Service__c = schList[0].Service__c;
            sch.Rating_Type__c = 'Current Rating';
        }
        update schList;
        Map<Id, Id> schMap = new Map<Id, Id>();
        schMap.put(schList[0].Id, schList[0].Service__c);
        RatingsStatusHelper.UpdateSCRRatingType(schMap);
        
        // Quality_Indicator_Summary__c
        List<Quality_Indicator_Summary__c> qiList = [SELECT Id, Availability_Status__c, Rating_Type__c, Service__c FROM Quality_Indicator_Summary__c LIMIT 5];
        for(Quality_Indicator_Summary__c qi : qiList) {
            qi.Service__c = qiList[0].Service__c;
            qi.Rating_Type__c = 'Current Rating';
        }
        update qiList;
        Map<Id, Id> qiMap = new Map<Id, Id>();
        qiMap.put(qiList[0].Id, qiList[0].Service__c);
        RatingsStatusHelper.UpdateQIRatingType(qiMap);
        
        // SRQI_CER__c
        List<SRQI_CER__c> cerList = [SELECT Id, Availability_Status__c, Rating_Type__c, Service__c FROM SRQI_CER__c LIMIT 5];
        for(SRQI_CER__c cer : cerList) {
            cer.Service__c = cerList[0].Service__c;
            cer.Rating_Type__c = 'Current Rating';
        }
        update cerList;
        Map<Id, Id> cerMap = new Map<Id, Id>();
        cerMap.put(cerList[0].Id, cerList[0].Service__c);
        RatingsStatusHelper.UpdateCERRatingType(cerMap);

        // Care_Minutes_Summary__c
        List<Care_Minutes_Summary__c> cmList = [SELECT Id, Availability_Status__c, Rating_Type__c, Service__c FROM Care_Minutes_Summary__c LIMIT 5];
        for(Care_Minutes_Summary__c cm : cmList) {
            cm.Service__c = cmList[0].Service__c;
            cm.Rating_Type__c = 'Current Rating';
        }
        update cmList;
        Map<Id, Id> cmMap = new Map<Id, Id>();
        cmMap.put(cmList[0].Id, cmList[0].Service__c);
        RatingsStatusHelper.UpdateCMRatingType(cmMap);

        // STAR_Rating_History__c
        List<STAR_Rating_History__c> srhList = [SELECT Id, Status__c, Rating_Type__c, SF_Service_Id__c FROM STAR_Rating_History__c LIMIT 5];
        for(STAR_Rating_History__c srh : srhList) {
            srh.SF_Service_Id__c = srhList[0].SF_Service_Id__c;
            srh.Rating_Type__c = 'Current Rating';
        }
        update srhList;
        Map<Id, Id> srhMap = new Map<Id, Id>();
        cmMap.put(srhList[0].Id, srhList[0].SF_Service_Id__c);
        RatingsStatusHelper.UpdateSRHRatingType(srhMap);
        Test.stopTest();

        Quality_Indicator_Summary__c qiTest = [SELECT Id, Availability_Status__c, Rating_Type__c, Service__c FROM Quality_Indicator_Summary__c WHERE Id = :qiList[1].Id LIMIT 1];
        SRQI_CER__c cerTest = [SELECT Id, Availability_Status__c, Rating_Type__c, Service__c FROM SRQI_CER__c WHERE Id = :cerList[1].Id LIMIT 1];

        String assertMessage = 'Rating_Type__c should be Previous Rating';
        System.assertEquals('Previous Rating', qiTest.Rating_Type__c, assertMessage);
        System.assertEquals('Previous Rating', cerTest.Rating_Type__c, assertMessage);

    }

    public static Map<String, Map<Id, String>> InitiateRatingsMap() {
        Map<String, Map<Id, String>> initiateMap = new Map<String, Map<Id, String>>();
        initiateMap.put('CER', new Map<Id, String>());
        initiateMap.put('CM', new Map<Id, String>());
        // initiateMap.put('SCR', new Map<Id, String>());
        initiateMap.put('QI', new Map<Id, String>());
        return initiateMap;
    }
}