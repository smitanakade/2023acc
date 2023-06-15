@isTest
private with sharing class QIFileUploadInternalControllerTest {
    @isTest static void testGetContactsForProvider() {
        List<Account> providers = TestDataFactory.createProviderRecords(1);
        insert providers;
        List<Contact> contacts = TestDataFactory.createContact(1, providers);
        insert contacts;

        List<QIFileUploadInternalController.ContactWrapper> providerContacts = QIFileUploadInternalController.getContactsForProvider(providers[0].Id);
        Assert.areEqual(1, providerContacts.size());
    }

    @isTest static void testGetContactsForProviderWhenNoneExist() {
        List<Account> providers = TestDataFactory.createProviderRecords(1);
        insert providers;

        try {
            List<QIFileUploadInternalController.ContactWrapper> providerContacts = QIFileUploadInternalController.getContactsForProvider(providers[0].Id);
            Assert.fail();
        } catch (Exception ex) {
            Assert.areEqual('System.AuraHandledException', ex.getTypeName());
        }
    }

    @isTest static void testGetFileStagingRecord() {
        Reporting_Period__c reportingPeriod = TestDataFactory.createReportingPeriod('Quarter');
        insert reportingPeriod;
        File_Staging__c existingFileStaging = new File_Staging__c(
            Name = 'Test',
            File_Name__c = 'Test',
            Reporting_Period__c = reportingPeriod.Id
        );
        insert existingFileStaging;

        File_Staging__c fileStaging = QIFileUploadInternalController.getFileStagingRecord(existingFileStaging.Id);
        Assert.isNotNull(fileStaging);
    }

    @isTest static void testGetFileStagingRecordWhenNotExist() {
        try {
            File_Staging__c fileStaging = QIFileUploadInternalController.getFileStagingRecord('test');
            Assert.fail();
        } catch (Exception ex) {
            Assert.areEqual('System.AuraHandledException', ex.getTypeName());
        }
    }
}