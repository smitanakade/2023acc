/**
 * author: Yifei Pei
 * date: 10/03/2023
 * description: Test Class for SRQISubmissionController
 **/
@isTest
private with sharing class SRQISubmissionControllerTest {
    private static final String STATUS_COMPLETE = 'Completed';
    private static final String STATUS_NOT_STARTED = 'Not Started';
    private static final String STATUS_PROGRESS = 'In Progress';
    @TestSetup
    static void dataSetup() {
        Integer recordCount = 2;
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
            List<Quality_Indicator_Summary__c> qisWithQIDs = new List<Quality_Indicator_Summary__c>();
            qisWithQIDs.add(qisRecords[0]);
            List<Quality_Indicator_Details__c> qidRecords = TestDataFactory.createQIDetailRecords(11, qisWithQIDs);
            Set<Id> allQIDRTIds = QIDynamicManagementController.getQIDRecordTypes();
            List<Id> allQIDRTIdList = new List<Id>();
            allQIDRTIdList.addAll(allQIDRTIds);
            for (Integer i = 0; i < qidRecords.size(); i++) {
                qidRecords[i].RecordTypeId = allQIDRTIdList[i];
            }
            insert qidRecords;
        }
        Test.stopTest();
    }
    @isTest
    static void testSubCtrl() {
        List<Quality_Indicator_Summary__c> allQISList = [SELECT Id FROM Quality_Indicator_Summary__c];
        List<Quality_Indicator_Details__c> allQIDList = [
            SELECT Id, Amended_after_Completion__c, QI_Summary_Id__c, Status__c
            FROM Quality_Indicator_Details__c
        ];
        List<Reporting_Period__c> allReportingPeriods = [
            SELECT Id, Start_Date__c, End_Date__c, QI_Submission_Due_Dt__c
            FROM Reporting_Period__c
        ];
        // assumption: all qid records have the same QI_Summary_Id__c
        Id qisIdwithQIDs = allQIDList[0].QI_Summary_Id__c;
        Quality_Indicator_Summary__c qisWithQIDs = new Quality_Indicator_Summary__c();
        Quality_Indicator_Summary__c qisWithoutQIDs = new Quality_Indicator_Summary__c();
        for (Quality_Indicator_Summary__c qisRecord : allQISList) {
            if (qisRecord.Id != qisIdwithQIDs) {
                qisWithoutQIDs = qisRecord;
            } else {
                qisWithQIDs = qisRecord;
            }
        }
        String ctrlResponse = '';
        String successResponse = '';
        Boolean isSubmitted = false;
        Test.startTest();

        Exception capturedException;
        try {
            ctrlResponse = SRQISubmissionController.getDomainInfo(qisWithoutQIDs.Id);
        } catch (Exception e) {
            capturedException = e;
        }

        /*ctrlResponse = SRQISubmissionController.getDomainInfo(qisIdwithQIDs);
        SRQISubmissionController.DomainInfo allUncompleted = (SRQISubmissionController.DomainInfo) JSON.deserializeStrict(
            ctrlResponse,
            SRQISubmissionController.DomainInfo.class
        );
        System.assertEquals(11, allUncompleted.uncompletedDomains.size(), 'SRQISubmissionControllerTest Case 1 assertion failed');
        isSubmitted = SRQISubmissionController.isSubmitted(qisIdwithQIDs);
        System.assertEquals(false, isSubmitted, 'SRQISubmissionControllerTest Case 1.1 assertion failed');

        for (Quality_Indicator_Details__c qidRecord : allQIDList) {
            qidRecord.Status__c = STATUS_COMPLETE;
        }
        update allQIDList;
        ctrlResponse = SRQISubmissionController.getDomainInfo(qisIdwithQIDs);
        SRQISubmissionController.DomainInfo allCompleted = (SRQISubmissionController.DomainInfo) JSON.deserializeStrict(
            ctrlResponse,
            SRQISubmissionController.DomainInfo.class
        );
        System.assertEquals(11, allCompleted.completedDomains.size(), 'SRQISubmissionControllerTest Case 2 assertion failed');
        ctrlResponse = SRQISubmissionController.submitRecord(qisIdwithQIDs, false);
        successResponse = (String) JSON.deserializeUntyped(ctrlResponse);
        System.assertEquals('Success', successResponse, 'SRQISubmissionControllerTest Case 3 assertion failed');*/

        /*Quality_Indicator_Summary_Version__c qisvRecord = [
            SELECT Id, LastModifiedDate, LastModifiedBy.Name, Quality_Indicator_Summary__c, Status__c, Version__c
            FROM Quality_Indicator_Summary_Version__c
            WHERE Quality_Indicator_Summary__c = :qisIdwithQIDs
            LIMIT 1
        ];
        qisvRecord.Status__c = STATUS_PROGRESS;
        update qisvRecord;
        ctrlResponse = SRQISubmissionController.submitVersionRecord(qisvRecord.Id, false);
        successResponse = (String) JSON.deserializeUntyped(ctrlResponse);
        System.assertEquals('Success', successResponse, 'SRQISubmissionControllerTest Case 8 assertion failed');*/

        /*ctrlResponse = SRQISubmissionController.getDomainInfo(qisIdwithQIDs);
        SRQISubmissionController.DomainInfo afterSubmission = (SRQISubmissionController.DomainInfo) JSON.deserializeStrict(
            ctrlResponse,
            SRQISubmissionController.DomainInfo.class
        );
        System.assertEquals(true, afterSubmission.isCompleted, 'SRQISubmissionControllerTest Case 4 assertion failed');
        isSubmitted = SRQISubmissionController.isSubmitted(qisIdwithQIDs);
        System.assertEquals(true, isSubmitted, 'SRQISubmissionControllerTest Case 4.1 assertion failed');

        try {
            ctrlResponse = SRQISubmissionController.submitRecord('abc', false);
        } catch (Exception e) {
            capturedException = e;
        }
        try {
            isSubmitted = SRQISubmissionController.isSubmitted('abc');
        } catch (Exception e) {
            capturedException = e;
        }

        allQIDList[1].Amended_after_Completion__c = true;
        update allQIDList[1];
        for (Reporting_Period__c reportingPeriod : allReportingPeriods) {
            reportingPeriod.QI_Submission_Due_Dt__c = (System.today() + 24).addMonths(-2);
        }
        update allReportingPeriods;
        ctrlResponse = SRQISubmissionController.getDomainInfo(qisIdwithQIDs);
        SRQISubmissionController.DomainInfo amendedSub = (SRQISubmissionController.DomainInfo) JSON.deserializeStrict(
            ctrlResponse,
            SRQISubmissionController.DomainInfo.class
        );
        System.assertEquals(true, amendedSub.isAmended, 'SRQISubmissionControllerTest Case 5 assertion failed');
        isSubmitted = SRQISubmissionController.isSubmitted(qisIdwithQIDs);
        System.assertEquals(false, isSubmitted, 'SRQISubmissionControllerTest Case 5.1 assertion failed');
        ctrlResponse = SRQISubmissionController.submitRecord(qisIdwithQIDs, false);
        successResponse = (String) JSON.deserializeUntyped(ctrlResponse);
        System.assertEquals('Success', successResponse, 'SRQISubmissionControllerTest Case 6 assertion failed');
        ctrlResponse = SRQISubmissionController.submitRecord(qisIdwithQIDs, true);
        successResponse = (String) JSON.deserializeUntyped(ctrlResponse);
        System.assertEquals('Success', successResponse, 'SRQISubmissionControllerTest Case 7 assertion failed');

        qisWithQIDs.Status__c = STATUS_NOT_STARTED;
        update qisWithQIDs;
        delete allQIDList[allQIDList.size() - 1];
        try {
            ctrlResponse = SRQISubmissionController.getDomainInfo(qisIdwithQIDs);
        } catch (Exception e) {
            capturedException = e;
        }*/

        Test.stopTest();
    }
}