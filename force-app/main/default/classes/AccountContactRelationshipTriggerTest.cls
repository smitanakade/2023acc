/****************************************************************************************************
 * @CreatedBy   : Yohan Perera
 * @CreatedDate : 1-11-2022
 * @Description : Test class for AccountContactRelationshipTrigger
 * @Test Class  : AccountContactRelationshipTriggerTest
 *****************************************************************************************************/
@isTest
private class AccountContactRelationshipTriggerTest {
    private static final User testAdminUser = TestDataFactory.insertNewSysAdmin();
    private static final Integer RECORD_COUNT = 1;
    private static final String SERVICE_GROUP_NAME_PREFIX = 'SRV_';
    private static final String ROLE_SR_REVIEWER = 'Star Rating Reviewer';

    @TestSetup
    static void makeData() {
        System.runAs(testAdminUser) {
            List<Account> accounts = TestDataFactory.createProviderRecords(3);
            Account a1 = accounts.get(0);
            insert a1;

            Account a2 = accounts.get(1);
            a2.ParentId = a1.Id;
            insert a2;

            Account a3 = accounts.get(2);
            a3.ParentId = a1.Id;
            insert a3;

            Contact conRecord = new Contact(
                FirstName = 'John',
                LastName = 'Citizen'
            );
            conRecord.AccountId = a1.Id;
            conRecord.LastName = 'TestCon1114';
            conRecord.Salutation = 'Mr';
            insert conRecord;

            Contact c = [SELECT Id FROM Contact LIMIT 1].get(0);
            Profile p = [SELECT Id FROM Profile WHERE Name = 'Provider User'];
            User u = new User(
                Email = 'test@test.com',
                ProfileId = p.Id,
                Alias = 'TestUser',
                ContactId = c.Id,
                FirstName = 'John',
                LastName = 'Citizen',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'Australia/Sydney',
                Username = 'starRatingUser' + Datetime.now().getTime() + '@testorg.com',
                IsActive = true);
            insert u;
            Test.getEventBus().deliver();

            List<BusinessLicense> services = TestDataFactory.createServiceRecords(1);
            services.get(0).AccountId = a1.Id;
            insert services;

            // As per the new requirements, everytime a service is created, the status will be defaulted to 'Inactive'.
            // The system requires an Allotment to be attached to the Service in order to make the service Operational
            List<Allotment__c> allotments = TestDataFactory.createAllotments(RECORD_COUNT, services);
            insert allotments;

            List<Places_Allotment__c> placesAllotments = TestDataFactory.createPlacesAllotments(RECORD_COUNT, allotments);
            insert placesAllotments;

            // This update will trigger flow Service: Update Service Status Start Date and set service status to operational
            update services;
            Test.getEventBus().deliver();

            BusinessLicense service = [SELECT Id, Status__c FROM BusinessLicense LIMIT 1].get(0);
            String groupName = SERVICE_GROUP_NAME_PREFIX + service.Id;
            Integer groupCount = Database.countQuery('SELECT Count() FROM Group WHERE DeveloperName = \'' + groupName + '\'');
            Assert.areEqual(1, groupCount, 'Expected public group to be created');
        }
    }

    @isTest
    static void testAccountContactRelationshipInsert() {
        System.runAs(testAdminUser) {
            // Given
            BusinessLicense service = [SELECT Id, AccountId FROM BusinessLicense LIMIT 1];
            Contact conRecord = [SELECT Id FROM Contact WHERE AccountId = :service.AccountId];
            User contactUser = [SELECT Id FROM User WHERE ContactId = :conRecord.Id];
            Account account2 = [SELECT Id FROM Account WHERE Id != :service.AccountId LIMIT 1];

            // When
            Test.startTest();
            AccountContactRelation acr2 = new AccountContactRelation();
            acr2.AccountId = account2.Id;
            acr2.ContactId = conRecord.Id;
            acr2.Roles = ROLE_SR_REVIEWER;
            insert acr2;
            Test.getEventBus().deliver();
            Test.stopTest();

            // Then
            /**
             * No group member will be created for user because:
             * User does not have 'Star Rating Reviewer' role assigned for acr1 (created in testSetup)
             * User has 'Star Rating Reviewer' role assigned for acr2 but there is no service linked to account2
             */
            Integer groupMemberCount = Database.countQuery('SELECT Count() FROM GroupMember WHERE UserOrGroupId = \'' + contactUser.Id + '\'');
            Assert.areEqual(0, groupMemberCount, 'Expected user not to be added to any groups');
        }
    }

    @isTest
    static void testAccountContactRelationshipDelete() {
        System.runAs(testAdminUser) {
            // Given
            BusinessLicense service = [SELECT Id, AccountId FROM BusinessLicense LIMIT 1];
            Contact conRecord = [SELECT Id FROM Contact WHERE AccountId = :service.AccountId];
            User contactUser = [SELECT Id FROM User WHERE ContactId = :conRecord.Id];
            Account account2 = [SELECT Id FROM Account WHERE Id != :service.AccountId LIMIT 1];
            AccountContactRelation acr1 = [SELECT Id FROM AccountContactRelation WHERE AccountId = :service.AccountId AND ContactId = :conRecord.Id LIMIT 1];
            acr1.Roles = ROLE_SR_REVIEWER;
            update acr1;
            Test.getEventBus().deliver();
            Integer groupMemberCount1 = Database.countQuery('SELECT Count() FROM GroupMember WHERE UserOrGroupId = \'' + contactUser.Id + '\'');
            Assert.areEqual(1, groupMemberCount1, 'Expected user be added to a group');
            conRecord.AccountId = account2.Id; // Change account Id so ACR can be deleted later
            update conRecord;

            // When
            Test.startTest();
            delete acr1;
            Test.getEventBus().deliver();
            Test.stopTest();

            // Then
            Integer groupMemberCount2 = Database.countQuery('SELECT Count() FROM GroupMember WHERE UserOrGroupId = \'' + contactUser.Id + '\'');
            Assert.areEqual(0, groupMemberCount2, 'Expected user to be removed from a group as ACR is deleted');
        }
    }

    @isTest
    static void testAccountContactRelationshipUpdate() {
        System.runAs(testAdminUser) {
            // Given
            BusinessLicense service = [SELECT Id, AccountId FROM BusinessLicense LIMIT 1];
            Contact conRecord = [SELECT Id FROM Contact WHERE AccountId = :service.AccountId];
            User contactUser = [SELECT Id FROM User WHERE ContactId = :conRecord.Id];
            AccountContactRelation acr1 = [SELECT Id FROM AccountContactRelation WHERE AccountId = :service.AccountId AND ContactId = :conRecord.Id LIMIT 1];
            Integer groupMemberCount1 = Database.countQuery('SELECT Count() FROM GroupMember WHERE UserOrGroupId = \'' + contactUser.Id + '\'');
            Assert.areEqual(0, groupMemberCount1, 'Expected user not yet in any groups');

            // When
            Test.startTest();
            acr1.Roles = ROLE_SR_REVIEWER;
            update acr1;
            Test.getEventBus().deliver();
            Test.stopTest();

            // Then
            Integer groupMemberCount2 = Database.countQuery('SELECT Count() FROM GroupMember WHERE UserOrGroupId = \'' + contactUser.Id + '\'');
            Assert.areEqual(1, groupMemberCount2, 'Expected user be added to a group as ROLE_SR_REVIEWER is assigned');
        }
    }

    @isTest
    static void testAccountContactRelationshipUpdateToNull() {
        System.runAs(testAdminUser) {
            // Given
            BusinessLicense service = [SELECT Id, AccountId FROM BusinessLicense LIMIT 1];
            Contact conRecord = [SELECT Id FROM Contact WHERE AccountId = :service.AccountId];
            User contactUser = [SELECT Id FROM User WHERE ContactId = :conRecord.Id];
            AccountContactRelation acr1 = [SELECT Id FROM AccountContactRelation WHERE AccountId = :service.AccountId AND ContactId = :conRecord.Id LIMIT 1];
            acr1.Roles = ROLE_SR_REVIEWER;
            update acr1;
            Test.getEventBus().deliver();
            Integer groupMemberCount1 = Database.countQuery('SELECT Count() FROM GroupMember WHERE UserOrGroupId = \'' + contactUser.Id + '\'');
            Assert.areEqual(1, groupMemberCount1, 'Expected user be added to a group');

            // When
            acr1.Roles = null;
            update acr1;
            Test.getEventBus().deliver();

            // Then
            Integer groupMemberCount2 = Database.countQuery('SELECT Count() FROM GroupMember WHERE UserOrGroupId = \'' + contactUser.Id + '\'');
            Assert.areEqual(0, groupMemberCount2, 'Expected user be removed from a group as role is NULL');
        }
    }
}