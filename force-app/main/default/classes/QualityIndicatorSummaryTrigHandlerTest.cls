@isTest
public with sharing class QualityIndicatorSummaryTrigHandlerTest {
    private static final String STATUS_COMPLETE = 'Completed';

    @TestSetup
    static void dataSetup() {
        Integer recordCount = 2;
        User testUser = TestDataFactory.createSystemAdminUser();

        Test.startTest();
        System.runAs(testUser) {
            // reporting period
            Reporting_Period__c rPeriod = TestDataFactory.createReportingPeriod('Quarter');
            rPeriod.Start_Date__c = (System.today() + 12).addMonths(-6);
            rPeriod.End_Date__c = (System.today() + 24).addMonths(-3);
            rPeriod.QI_Calc_Date__c = System.today() - 5;
            rPeriod.QI_Calculated__c = true;
            rPeriod.NationalAverageCreated__c = true;
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
            // get quality indicator summary
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
            qisRecords[0].Availability_Status__c = 'Draft';
            insert qisRecords;

            List<Quality_Indicator_Summary__c> qisRecordsWithCompletedQIDs = new List<Quality_Indicator_Summary__c>();
            List<Quality_Indicator_Summary__c> qisRecordsWithoutCompletedQIDs = new List<Quality_Indicator_Summary__c>();
            qisRecordsWithCompletedQIDs.add(qisRecords[1]);
            qisRecordsWithoutCompletedQIDs.add(qisRecords[0]);
            List<Quality_Indicator_Details__c> completedQIDRecords = TestDataFactory.createQIDetailRecords(11, qisRecordsWithCompletedQIDs);
            Set<Id> allQIDRTIds = QIDynamicManagementController.getQIDRecordTypes();
            List<Id> allQIDRTIdList = new List<Id>();
            allQIDRTIdList.addAll(allQIDRTIds);
            for (Integer i = 0; i < completedQIDRecords.size(); i++) {
                completedQIDRecords[i].RecordTypeId = allQIDRTIdList[i];
                completedQIDRecords[i].Status__c = STATUS_COMPLETE;
            }
            insert completedQIDRecords;
            qisRecords[1].Availability_Status__c = 'Published';
            qisRecords[1].Status__c = 'Late Submission';
            qisRecords[1].QIUpdatedbySiebel__c = true;
            qisRecords[1].National_Statistic__c = ns.Id;
            update qisRecords[1];

            // get quality indicator detail
            List<Quality_Indicator_Details__c> qidRecords = TestDataFactory.createQIDetailRecords(11, qisRecordsWithoutCompletedQIDs);
            for (Integer i = 0; i < qidRecords.size(); i++) {
                qidRecords[i].RecordTypeId = allQIDRTIdList[i];
            }
            insert qidRecords;
        }
        Test.stopTest(); 
    }

    @isTest
    public static void testBeforeUpdate() {
        Quality_Indicator_Summary__c qisRecord = [
            SELECT Id, Service__c, QIUpdatedbySiebel__c, Status__c, Availability_Status__c
            FROM Quality_Indicator_Summary__c
            WHERE Availability_Status__c = 'Draft'
            LIMIT 1
        ];

        Test.startTest();

        qisRecord.Availability_Status__c = 'Live';
        update qisRecord;

        Test.stopTest();

        Quality_Indicator_Summary__c qisTest2 = [SELECT Rating_Type__c FROM Quality_Indicator_Summary__c WHERE Id = :qisRecord.Id];

        System.assertEquals('Current Rating', qisTest2.Rating_Type__c);
    }

    @isTest
    public static void testAfterUpdate() {
        Quality_Indicator_Summary__c qisRecord = [
            SELECT Id, Service__c, QIUpdatedbySiebel__c, Status__c, Availability_Status__c
            FROM Quality_Indicator_Summary__c
            WHERE Availability_Status__c = 'Draft'
            LIMIT 1
        ];
        List<Quality_Indicator_Details__c> relatedQIDRecords = [
            SELECT Id, Status__c
            FROM Quality_Indicator_Details__c
            WHERE QI_Summary_Id__c = :qisRecord.Id
        ];
        Test.startTest();
        for (Quality_Indicator_Details__c relatedQIDRecord : relatedQIDRecords) {
            relatedQIDRecord.Status__c = STATUS_COMPLETE;
        }
        update relatedQIDRecords;
        qisRecord.Status__c = 'Late Submission';
        qisRecord.QIUpdatedbySiebel__c = true;
        qisRecord.Submission_Date_Time__c = System.now();
        update qisRecord;
        Test.stopTest();

        Quality_Indicator_Summary__c qisTest2 = [
            SELECT QIUpdatedbySiebel__c, Status__c, Quality_Indicator_Rating__c
            FROM Quality_Indicator_Summary__c
            WHERE Id = :qisRecord.Id
        ];

        System.assertEquals(false, qisTest2.QIUpdatedbySiebel__c, 'QIUpdatedbySiebel__c should be trigger to false');
    }
}