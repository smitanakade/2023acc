/**
 * @description       : Test class for QIVersionsController
 * @author            : Vivek Jaiswal
 * @group             : 
 * @last modified on  : 04-24-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@IsTest
public with sharing class QIVersionsControllerTest {
    private static final String STATUS_COMPLETE = 'Completed';
    @TestSetup
    static void dataSetup() {
        Integer recordCount = 2;
        User testUser = TestDataFactory.createSystemAdminUser();

        Test.startTest();
        System.runAs(testUser) {
            // reporting period
            Reporting_Period__c rPeriod = TestDataFactory.createReportingPeriod('Quarter');
            rPeriod.Start_Date__c = Date.today().addYears(-30);
            rPeriod.End_Date__c = Date.today().addYears(-20);
            insert rPeriod;
            // get providers
            List<Account> providers = TestDataFactory.createProviderRecords(recordCount);
            insert providers;
            List<Contact> contacts = TestDataFactory.createContact(recordCount, providers);
            insert contacts;
            // get services
            List<BusinessLicense> services = TestDataFactory.createServiceRecords(recordCount);
            insert services;
            // get service account relationships
            List<Service_Account_Relationship__c> serviceAccountRecords = TestDataFactory.createServiceAccountRecords(
                recordCount,
                services,
                providers
            );
            insert serviceAccountRecords;
            // insert national statistics
            National_Statistic__c ns = new National_Statistic__c();
            ns.Reporting_Period__c = rPeriod.Id;
            insert ns;

            List<Quality_Indicator_Summary__c> qisList = TestDataFactory.createQISummaryRecords(1, providers, rPeriod, services, serviceAccountRecords);
            insert qisList;
        }
        Test.stopTest();
    }
   

    @isTest
    public static void test_createQIVersions() {
        Integer sigWL = 6;
        Quality_Indicator_Summary__c qisRecord = [
            SELECT Id, Service__c, QIUpdatedbySiebel__c, Status__c, Availability_Status__c,Completed_QI_Details__c 
            FROM Quality_Indicator_Summary__c
            LIMIT 1
        ];

        List<Quality_Indicator_Details__c> qidList = new List<Quality_Indicator_Details__c>();
        List<Schema.RecordTypeInfo> recordTypes= Quality_Indicator_Details__c.SObjectType.getDescribe().getRecordTypeInfos();
        for(Schema.RecordTypeInfo rt : recordTypes) {
            if(rt.isActive() && rt.getDeveloperName() != 'Master') {
                qidList.add(new Quality_Indicator_Details__c(
                    QI_Summary_Id__c = qisRecord.Id,
                    Status__c = 'Completed',
                    RecordTypeId = rt.getRecordTypeId()));
            }
        }
        insert qidList;

        qisRecord.Status__c = 'Submitted';
        qisRecord.Submission_Date_Time__c = Datetime.now();
        qisRecord.Significant_Weight_Loss_Quintile__c = sigWL;
        qisRecord.Requested_by__c = [SELECT Id FROM Contact LIMIT 1].Id;
        update qisRecord;

        Quality_Indicator_Summary_Version__c qisVer = [SELECT Id, Significant_Weight_Loss_Quintile__c FROM Quality_Indicator_Summary_Version__c WHERE Quality_Indicator_Summary__c =: qisRecord.Id];
        System.assertEquals(sigWL, qisVer.Significant_Weight_Loss_Quintile__c, 'Significant_Weight_Loss_Quintile__c should be trigger to false');
    }
}