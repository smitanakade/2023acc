/**
 * author: Yifei Pei
 * date: 28/02/2023
 * description: Test Class for QIDynamicManagementController
 **/
@isTest
private with sharing class QIDynamicManagementControllerTest {
    @TestSetup
    static void dataSetup() {
        Integer recordCount = 2;
        User testUser = TestDataFactory.createSystemAdminUser();
        Test.startTest();
        System.runAs(testUser) {
            Reporting_Period__c rPeriod = TestDataFactory.createReportingPeriod('Quarter');
            insert rPeriod;

            List<Account> providersWithQIS = new List<Account>();
            List<BusinessLicense> servicesWithQIS = new List<BusinessLicense>();
            List<Service_Account_Relationship__c> serviceAccountRecordsWithQIS = new List<Service_Account_Relationship__c>();

            List<Account> providers = TestDataFactory.createProviderRecords(recordCount);
            insert providers;
            providersWithQIS.add(providers[1]);
            List<BusinessLicense> services = TestDataFactory.createServiceRecords(recordCount);
            insert services;
            servicesWithQIS.add(services[1]);
            List<Service_Account_Relationship__c> serviceAccountRecords = TestDataFactory.createServiceAccountRecords(
                recordCount,
                services,
                providers
            );
            insert serviceAccountRecords;
            serviceAccountRecordsWithQIS.add(serviceAccountRecords[1]);

            List<Quality_Indicator_Summary__c> qisRecords = TestDataFactory.createQISummaryRecords(
                1,
                providersWithQIS,
                rPeriod,
                servicesWithQIS,
                serviceAccountRecordsWithQIS
            );
            insert qisRecords;
            List<Quality_Indicator_Details__c> qidRecords = TestDataFactory.createQIDetailRecords(11, qisRecords);
            // assuming there are totally 11 record types
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
    public static void testQIMgmtCtrl() {
        List<BusinessLicense> allServices = [
            SELECT Id, Oracle_Service_ID__c
            FROM BusinessLicense
        ];
        List<Account> allProviders = [SELECT Id, Oracle_ID__c FROM Account];
        List<Quality_Indicator_Summary__c> allQISList = [
            SELECT Id, Service__c
            FROM Quality_Indicator_Summary__c
        ];
        List<Service_Account_Relationship__c> allServiceAccountRelationships = [
            SELECT Id
            FROM Service_Account_Relationship__c
        ];
        List<Reporting_Period__c> allReportingPeriods = [
            SELECT Id, Start_Date__c, End_Date__c
            FROM Reporting_Period__c
        ];
        Id serviceWithQISId = allQISList[0].Service__c;
        BusinessLicense serviceWithQIS;
        BusinessLicense serviceWithoutQIS;
        for (BusinessLicense serviceRecord : allServices) {
            if (serviceRecord.Id == serviceWithQISId) {
                serviceWithQIS = serviceRecord;
            } else {
                serviceWithoutQIS = serviceRecord;
            }
        }

        String getExistingQIS = '';
        String getEmptyQIS = '';
        String successCreation = '';

        Test.startTest();
        // Test the successful path
        getExistingQIS = QIDynamicManagementController.getCurrentQISList(serviceWithQIS.Id);
        getEmptyQIS = QIDynamicManagementController.getCurrentQISList(serviceWithoutQIS.Id);
        successCreation = QIDynamicManagementController.createNewQI(serviceWithoutQIS.Id);
        // Test the exceptions
        Exception capturedException;
        for (Account provider : allProviders) {
            provider.Oracle_ID__c = null;
        }
        for (BusinessLicense service : allServices) {
            service.Oracle_Service_ID__c = null;
        }
        update allProviders;
        update allServices;
        try {
            QIDynamicManagementController.createNewQI(serviceWithoutQIS.Id);
        } catch (Exception e) {
            capturedException = e;
        }
        delete allServiceAccountRelationships;
        for (Reporting_Period__c reportingPeriod : allReportingPeriods) {
            reportingPeriod.Start_Date__c = (System.today() + 12).addMonths(-6);
            reportingPeriod.End_Date__c = (System.today() + 24).addMonths(-3);
        }
        update allReportingPeriods;
        try {
            QIDynamicManagementController.createNewQI(serviceWithoutQIS.Id);
        } catch (Exception e) {
            capturedException = e;
        }
        Test.stopTest();

        Quality_Indicator_Summary__c newlyCreatedQIS = [
            SELECT Id
            FROM Quality_Indicator_Summary__c
            WHERE Service__c = :serviceWithoutQIS.Id
            LIMIT 1
        ];

        String assetedExistingQIS = '{\"isEmpty\":false,\"id\":\"' + allQISList[0].Id + '\"}';
        String assetedEmptyQIS = '{\"isEmpty\":true,\"id\":null}';
        String assetedSsuccessCreation = '{\"isEmpty\":false,\"id\":\"' + newlyCreatedQIS.Id + '\"}';

        System.assertEquals(assetedExistingQIS, getExistingQIS, 'Existing QIS assertion failed');
        System.assertEquals(assetedEmptyQIS, getEmptyQIS, 'Empty QIS assertion failed');
        System.assertEquals(assetedSsuccessCreation, successCreation, 'Newly Created QIS assertion failed');
    }
}