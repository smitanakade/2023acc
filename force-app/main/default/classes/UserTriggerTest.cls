/****************************************************************************************************
* @CreatedBy   : Yohan Perera
* @CreatedDate : 1-11-2022
* @Description : Test class for UserTrigger
* @Test Class  : UserTriggerTest
* @Modified by : AG - To replace Role__c field with Portal_Service_Roles__c
* @ModifiedDate : 25-03-2023
*****************************************************************************************************/
@isTest
private class UserTriggerTest {
    private static final Integer RECORD_COUNT = 1;
    private static final String SERVICE_GROUP_NAME_PREFIX = 'SRV_';

    @TestSetup
    static void makeData() {
        System.runAs(getAdminUser()) {
            List<Account> providers = TestDataFactory.createProviderRecords(RECORD_COUNT);
            insert providers;
            List<Contact> contacts = TestDataFactory.createContact(RECORD_COUNT, providers);
            insert contacts;

            List<BusinessLicense> services = TestDataFactory.createServiceRecords(RECORD_COUNT);
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

            // Insert service account relationships and the flow, 'SACR : Update Service', will assign account to service
            List<Service_Account_Relationship__c> serviceAccountRecords = TestDataFactory.createServiceAccountRecords(
                RECORD_COUNT,
                services,
                providers
            );
            insert serviceAccountRecords;

            BusinessLicense service = [SELECT Id, Status__c FROM BusinessLicense LIMIT 1].get(0);
            String groupName = SERVICE_GROUP_NAME_PREFIX + service.Id;
            Integer groupCount = Database.countQuery('SELECT Count() FROM Group WHERE DeveloperName = \'' + groupName + '\'');
            Assert.areEqual(1, groupCount, 'Expected public group to be created');
        }
    }

    @isTest
    static void testContactRelationshipInsertUser() {
        System.runAs(getAdminUser()) {
            Test.startTest();
            // Given
            BusinessLicense service = [SELECT Id FROM BusinessLicense LIMIT 1].get(0);
            User contactUser = getContactUser();

            // When
            createNewContactRelationship(service.Id, contactUser.ContactId);
            Test.stopTest();

            // Then
            Integer groupMemberCount = Database.countQuery('SELECT Count() FROM GroupMember WHERE UserOrGroupId = \'' + contactUser.Id + '\'');
            Assert.areEqual(1, groupMemberCount, 'Expected user to be added to public group');
        }
    }

    @isTest
    static void testContactRelationshipDeactivateUser() {
        System.runAs(getAdminUser()) {
            Test.startTest();
            // Given
            BusinessLicense service = [SELECT Id FROM BusinessLicense LIMIT 1].get(0);
            User contactUser = getContactUser();
            createNewContactRelationship(service.Id, contactUser.ContactId);

            // When
            contactUser.IsActive = false;
            update contactUser;
            Test.getEventBus().deliver();

            Test.stopTest();

            // Then
            Integer groupMemberCount = Database.countQuery('SELECT Count() FROM GroupMember WHERE UserOrGroupId = \'' + contactUser.Id + '\'');
            Assert.areEqual(0, groupMemberCount, 'Expected user to be removed from the group');
        }
    }

    @isTest
    static void testContactRelationshipInactiveToActiveUser() {
        System.runAs(getAdminUser()) {
            Test.startTest();
            // Given
            BusinessLicense service = [SELECT Id FROM BusinessLicense LIMIT 1].get(0);
            User contactUser = getContactUser();
            createNewContactRelationship(service.Id, contactUser.ContactId);
            contactUser.IsActive = false;
            update contactUser;
            Test.getEventBus().deliver();
            Integer groupMemberCountInactive = Database.countQuery('SELECT Count() FROM GroupMember WHERE UserOrGroupId = \'' + contactUser.Id + '\'');
            Assert.areEqual(0, groupMemberCountInactive, 'Expected user to be removed from the group');

            // When
            contactUser.IsActive = true;
            update contactUser;
            Test.getEventBus().deliver();
            Test.stopTest();

            // Then
            Integer groupMemberCountActive = Database.countQuery('SELECT Count() FROM GroupMember WHERE UserOrGroupId = \'' + contactUser.Id + '\'');
            Assert.areEqual(1, groupMemberCountActive, 'Expected user to be added to public group');
        }
    }

    private static Contact_Relationship__c createNewContactRelationship(Id serviceId, Id contactId) {
        Contact_Relationship__c cRelationship = new Contact_Relationship__c(
            Service__c = serviceId,
            Contact__c = contactId,
            Role__c = 'Primary Contact',
            Portal_Service_Roles__c = ContactRelationshipTriggerService.ROLE_STAR_RATING_SERVICE_REVIEWER);
        insert cRelationship;
        Test.getEventBus().deliver();
        return cRelationship;
    }

    private static User getAdminUser() {
        User adminUser = TestDataFactory.createSystemAdminUser();
        UserRole userRole = [SELECT Id, Name FROM UserRole WHERE Name = 'Health Staff' LIMIT 1];
        adminUser.IsActive = true;
        adminUser.UserRoleId = userRole.Id;
        update adminUser;
        return adminUser;
    }

    private static User getContactUser() {
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
        return u;
    }
}