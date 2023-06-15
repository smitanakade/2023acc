@isTest
private with sharing class QIFileUploadHistoryControllerTest {
    @testSetup static void setup() {
        User systemAdminUser = TestDataFactory.createSystemAdminUser();
        System.runAs(systemAdminUser) {
            List<Account> providers = TestDataFactory.createProviderRecords(1);
            insert providers;
            List<Contact> contacts = TestDataFactory.createContact(1, providers);
            insert contacts;
            Reporting_Period__c reportingPeriod = TestDataFactory.createReportingPeriod('Quarter');
            insert reportingPeriod;
            List<File_Staging__c> fileStagingRecords = new List<File_Staging__c>{
                new File_Staging__c(
                    Name = 'Test 1',
                    File_Name__c = 'Test_File_1',
                    Reporting_Period__c = reportingPeriod.Id,
                    Provider__c = providers.get(0).Id
                ),
                new File_Staging__c(
                    Name = 'Test 2',
                    File_Name__c = 'Test_File_2',
                    Reporting_Period__c = reportingPeriod.Id,
                    Provider__c = providers.get(0).Id
                )
            };
            insert fileStagingRecords;
            TestDataFactory.createProviderPortalUser(1, contacts);
        }
    }

    @isTest static void testGetPicklistValues() {
        QIFileUploadHistoryController.PicklistValues picklistValues = QIFileUploadHistoryController.getPicklistValues();
        Assert.isNotNull(picklistValues.reportingQuarters);
        Assert.isFalse(picklistValues.reportingQuarters.isEmpty());
        Assert.isNotNull(picklistValues.statuses);
        Assert.isFalse(picklistValues.statuses.isEmpty());
    }

    @isTest static void testGetFileUploadHistory() {
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        User portalUser = [SELECT Id FROM User WHERE ContactId = :contact.Id];
        System.runAs(portalUser) {
            List<QIFileUploadHistoryController.FileUploadDetail> fileUploadHistory = QIFileUploadHistoryController.getFileUploadHistory(null);
            Assert.areEqual(2, fileUploadHistory.size());
        }
    }

    @isTest static void testGetFileUploadHistoryWithFilters() {
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        User portalUser = [SELECT Id FROM User WHERE ContactId = :contact.Id];
        System.runAs(portalUser) {
            String filterJSON = '{"search":"File_2"}';
            List<QIFileUploadHistoryController.FileUploadDetail> fileUploadHistory = QIFileUploadHistoryController.getFileUploadHistory(filterJSON);
            Assert.areEqual(1, fileUploadHistory.size());
        }
    }
}