/**
 * author: Yifei Pei
 * date: 21/04/2023
 * description: Test Class for SRQIVersionController
 **/
@isTest
private with sharing class SRQIVersionControllerTest {
    private static final String STATUS_COMPLETE = 'Completed';
    private static final String STATUS_SUBMIT = 'Submitted';
    private static final String STATUS_PROGRESS = 'In Progress';
    @TestSetup
    static void dataSetup() {
        Integer recordCount = 1;
        User testUser = TestDataFactory.createSystemAdminUser();
        Test.startTest();
        System.runAs(testUser) {
            Reporting_Period__c rPeriod = TestDataFactory.createReportingPeriod('Quarter');
            insert rPeriod;
            List<Account> providers = TestDataFactory.createProviderRecords(recordCount);
            insert providers;
            List<Contact> contacts = TestDataFactory.createContact(recordCount, providers);
            insert contacts;
            List<BusinessLicense> services = TestDataFactory.createServiceRecords(recordCount);
            insert services;
            List<Service_Account_Relationship__c> serviceAccountRecords = TestDataFactory.createServiceAccountRecords(
                recordCount,
                services,
                providers
            );
            insert serviceAccountRecords;
            List<Quality_Indicator_Summary__c> qisRecords = TestDataFactory.createQISummaryRecords(
                recordCount,
                providers,
                rPeriod,
                services,
                serviceAccountRecords
            );
            for (Integer i = 0; i < qisRecords.size(); i++) {
                qisRecords[i].Requested_by__c = contacts[i].Id;
            }
            insert qisRecords;
            List<Quality_Indicator_Details__c> qidRecords = TestDataFactory.createQIDetailRecords(11 * recordCount, qisRecords);
            Set<Id> allQIDRTIds = QIDynamicManagementController.getQIDRecordTypes();
            List<Id> allQIDRTIdList = new List<Id>();
            allQIDRTIdList.addAll(allQIDRTIds);
            for (Integer j = 0; j < recordCount; j++) {
                for (Integer i = 0; i < allQIDRTIdList.size(); i++) {
                    qidRecords[j * 11 + i].RecordTypeId = allQIDRTIdList[i];
                }
            }
            insert qidRecords;
        }
        Test.stopTest();
    }

    @isTest
    static void testVerCtrl() {
        List<Quality_Indicator_Summary__c> allQISRecords = [SELECT Id, Status__c, Requested_by__c FROM Quality_Indicator_Summary__c];
        List<Quality_Indicator_Details__c> allQIDRecords = [SELECT Id, Status__c FROM Quality_Indicator_Details__c];
        for (Quality_Indicator_Details__c qidRecord : allQIDRecords) {
            qidRecord.Status__c = STATUS_COMPLETE;
        }
        update allQIDRecords;
        for (Quality_Indicator_Summary__c qisRecord : allQISRecords) {
            String ctrlResponse = SRQISubmissionController.submitRecord(qisRecord.Id, false);
        }
        List<Quality_Indicator_Summary_Version__c> allQISVRecords = [
            SELECT Id, LastModifiedDate, LastModifiedBy.Name, Quality_Indicator_Summary__c, Status__c, Version__c
            FROM Quality_Indicator_Summary_Version__c
        ];

        Test.startTest();
        for (Quality_Indicator_Summary__c qisRecord : allQISRecords) {
            List<SRQIVersionController.VersionInfo> response = SRQIVersionController.getVersionInfo(qisRecord.Id);
            System.assert(response.size() > 0, 'SRQIVersionControllerTest assertion failed');
        }
        allQISVRecords[0].Status__c = STATUS_PROGRESS;
        update allQISVRecords[0];
        List<SRQIVersionController.VersionInfo> response = SRQIVersionController.getVersionInfo(
            allQISVRecords[0].Quality_Indicator_Summary__c
        );
        System.assert(response.size() > 0, 'SRQIVersionControllerTest assertion failed');
        Test.stopTest();
    }
}