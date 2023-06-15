
/**
* author: Sharevreet Singh
* date: 29/04/2023
* description: Test class for QIBulkUploadUtility
 */
@isTest
private with sharing class QIBulkUploadUtilityTest {
    @TestSetup
    private static void setup() {
        User testUser = TestDataFactory.createSystemAdminUser();
        Test.startTest();
		System.runAs(testUser){
            insert TestDataFactory.createReportingPeriod('Quarter');

            List<Account> accounts = TestDataFactory.createProviderRecords(1);
            insert accounts;

            Contact conRecord = new Contact(FirstName = 'John', LastName = 'Citizen');
            conRecord.AccountId = accounts[0].id;
            conrecord.lastname = 'TestCon1114';
            conrecord.Salutation = 'Mr';
            conrecord.Email = 'TestCon1114@accenture.com';
            insert conRecord;

            String uniqueUserName =
                'Admin1user' +
                DateTime.now().getTime() + '@accenture.com';
            Profile adminUsrProfile = [
                SELECT Id
                FROM Profile
                WHERE Name = 'System Administrator'
            ];
            TestDataFactory.createProviderPortalUser(1, new List<Contact> {conRecord});
        }
        Test.stopTest();
    }

    @IsTest
    private static void createFileStagingRecordTest() {
        User user = [SELECT Id, Alias, Contact.Id, Contact.AccountId FROM User WHERE Alias = 'pusr'];
        QIBulkUploadUtility.FileStagingWrapper fileStagingWrapper = new QIBulkUploadUtility.FileStagingWrapper();
        fileStagingWrapper.userId = user.Id;
        Test.startTest();
        System.runAs(user) {
            File_Staging__c fileStagingRecord = QIBulkUploadUtility.createFileStagingRecord(fileStagingWrapper);
            System.assertNotEquals(null, fileStagingRecord, 'fileStagingRecord should exist');

            fileStagingWrapper.fileStagingRecordId = fileStagingRecord.Id;
            fileStagingRecord = QIBulkUploadUtility.createFileStagingRecord(fileStagingWrapper);
            System.assertNotEquals(null, fileStagingRecord, 'testing existing record');
        }
        Test.stopTest();
    }

    @IsTest
    private static void createFileStagingRecordAuraTest() {
        User user = [SELECT Id, Alias, Contact.Id, Contact.AccountId FROM User WHERE Alias = 'pusr'];
        QIBulkUploadUtility.FileStagingWrapper fileStagingWrapper = new QIBulkUploadUtility.FileStagingWrapper();
        fileStagingWrapper.userIdAura = user.Id;
        Test.startTest();
        System.runAs(user) {
            List<File_Staging__c> fileStagingRecord = QIBulkUploadUtility.createFileStagingRecord(new List<QIBulkUploadUtility.FileStagingWrapper> {fileStagingWrapper});
            System.assert(fileStagingRecord.size() > 0, 'size should be 1');
        }
        Test.stopTest();
    }
}