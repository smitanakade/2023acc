/**
* author: Daniel Clift
* date: 27/09/2022
* description: test class for CareMinutesSummaryTriggerHandler
**/

@isTest
public with sharing class StarRatingTriggerServiceTest {
    @TestSetup
    static void dataSetup(){
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
            List<Group> grpList = new List<Group>();
            for(Integer i = 0; i < srhRecords.size(); i++) {
                srhRecords[i].Care_Minutes_Id__c = cmsRecords[i].Id;
                srhRecords[i].Service_Compliance_Id__c = schRecords[i].Id;
                srhRecords[i].Quality_Indicator_Id__c = qisRecords[i].Id;
                srhRecords[i].Consumer_Experience_Id__c = cerRecords[i].Id;
                srhRecords[i].Rating_Type__c = math.mod(i,2) == 0 ? 'New Rating' : 'Current Rating';
                if(i == 0) {
                    srhRecords[i].Status__c = 'Draft';
                }
                else {
                    srhRecords[i].Status__c = 'Published';
                }
                grpList.add(new Group(Name = 'SRV_' + srhRecords[i].SF_Service_Id__c, DeveloperName = 'SRV_' + srhRecords[i].SF_Service_Id__c,Type = 'Regular'));
            }
            insert grpList;
            insert srhRecords;
        }
        Test.stopTest();
    }

    @IsTest
    static void testUpdateWithoutCalculation(){
        STAR_Rating_History__c srh = [SELECT Status__c, STAR_Rating_Calculation__c, 
                                      Publish_Date__c, Go_Live_Date__c
                                      FROM STAR_Rating_History__c
                                      WHERE Status__c = 'Draft' LIMIT 1];
        Test.startTest();
        update srh;
        Test.stopTest();
        srh = [SELECT Status__c, STAR_Rating_Calculation__c, 
               Publish_Date__c, Go_Live_Date__c
               FROM STAR_Rating_History__c
               WHERE Status__c = 'Draft' LIMIT 1];
        System.assertEquals(null, srh.Go_Live_Date__c, 'Go Live date should not be set');
        System.assertEquals(null, srh.Publish_Date__c, 'Publish date should not be set');
    }

    @IsTest
    static void HandleStarRating(){
        //get star rating records
        List<STAR_Rating_History__c> srhRecords = [SELECT Id, Name, Care_Minutes_Id__c, Service_Compliance_Id__c, Quality_Indicator_Id__c, Consumer_Experience_Id__c, Rating_Type__c, Status__c FROM STAR_Rating_History__c];

        for (STAR_Rating_History__c srhRecord : srhRecords) {
            if(srhRecord.Status__c == 'Draft') {
                srhRecord.Status__c = 'Published';
            }
            else {
                srhRecord.Status__c = 'Live';
            }
        }
        Test.startTest();
        update srhRecords;
        Test.stopTest();
    }
}