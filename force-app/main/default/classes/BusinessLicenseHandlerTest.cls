@isTest
private class BusinessLicenseHandlerTest {
    private static final User testAdminUser1 = TestDataFactory.insertNewSysAdmin();
    private static final String APPROVED_PROVIDER_REC_TYPE = 'Approved_Provider';
    private static final Integer RECORD_COUNT = 1;
    private static final String SERVICE_GROUP_NAME_PREFIX = 'SRV_';

    @TestSetup
    static void makeData() {
        System.runAs(testAdminUser1) {
            // Insert providers
            List<Account> providers = TestDataFactory.createProviderRecords(RECORD_COUNT);
            insert providers;

            // Insert care type
            List<Care_Type__c> careTypeList = TestDataFactory.createSCRcareType(1, providers);
            insert careTypeList;

            // Insert services
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
        }
    }

    @isTest
    public static void testOwnershipChangeBusinessLicenseUpdate() {
        System.runAs(testAdminUser1) {
            // Given
            Test.startTest();
            Account accountToInsert = GPMSTestUtility.getACOAccount();
            insert accountToInsert;

            Contact contactToInsert = GPMSTestUtility.getContact();
            insert contactToInsert;

            BusinessLicense service = [SELECT Id, Status__c FROM BusinessLicense LIMIT 1].get(0);
            String groupName = SERVICE_GROUP_NAME_PREFIX + service.Id;
            Integer recordCount = Database.countQuery('SELECT Count() FROM Group WHERE DeveloperName = \'' + groupName + '\'');
            Assert.areEqual(1, recordCount, 'Expected public group to be created');

            User adminUser2 = TestDataFactory.createSystemAdminUser();
            adminUser2.IsActive = true;
            update adminUser2;

            // When
            service.OwnerId = adminUser2.Id;
            update service;
            Test.getEventBus().deliver();
            Test.stopTest();

            // Then
            Integer count = Database.countQuery('SELECT Count() FROM BusinessLicenseShare WHERE ParentId = \'' + service.Id + '\' AND RowCause = \'Manual\'');
            Assert.areEqual(1, count, 'Expected BusinessLicenseShare record to be created');
        }
    }

    @isTest
    public static void testCreateDeletePublicGroupAfterBusinessLicenseInsertDelete() {
        System.runAs(testAdminUser1) {
            // Given
            Test.startTest();
            BusinessLicense service = [SELECT Id, Status__c FROM BusinessLicense LIMIT 1].get(0);
            String groupName = SERVICE_GROUP_NAME_PREFIX + service.Id;
            Integer recordCount = Database.countQuery('SELECT Count() FROM Group WHERE DeveloperName = \'' + groupName + '\'');
            Assert.areEqual(1, recordCount, 'Expected public group to exist');

            // When
            delete service;
            Test.getEventBus().deliver();
            Test.stopTest();

            // Then
            recordCount = Database.countQuery('SELECT Count() FROM Group WHERE DeveloperName = \'' + groupName + '\'');
            Assert.areEqual(0, recordCount, 'Expected public group to be deleted');
        }
    }

    @isTest
    public static void testCreateGroupAfterSAR() {
        System.runAs(testAdminUser1) {
            // Given
            Id approvedProviderRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
                .get(APPROVED_PROVIDER_REC_TYPE)
                .getRecordTypeId();
            List<Account> providers = [SELECT Id FROM Account WHERE RecordTypeId = :approvedProviderRecordTypeId];

            List<Contact> providerContacts = TestDataFactory.createContact(
                RECORD_COUNT,
                providers
            );
            insert providerContacts;

            List<AccountContactRelation> acrs = [
                SELECT Id
                FROM AccountContactRelation
                WHERE ContactId IN :new Map<Id, Contact>(providerContacts).keySet()
            ];
            for (AccountContactRelation acr : acrs) {
                acr.Roles = AccountContactRelationshipTriggerService.ROLE_STAR_RATING_REVIEWER;
            }
            update acrs;

            List<User> providerPortalUsers = TestDataFactory.createProviderPortalUser(
                RECORD_COUNT,
                providerContacts
            );


            // Test situation that groups are created 'AFTER' SAR imported so we need to
            // again create new services and make them operational after inserting SARs
            List<BusinessLicense> services = TestDataFactory.createServiceRecords(RECORD_COUNT);
            setServiceUniqueOracleId(services);
            insert services;

            // Insert service account relationships and the flow will assign account to service
            List<Service_Account_Relationship__c> serviceAccountRecords = TestDataFactory.createServiceAccountRecords(
                RECORD_COUNT,
                services,
                providers
            );
            insert serviceAccountRecords;

            // When
            Test.startTest();
            // As per the new requirements, everytime a service is created, the status will be defaulted to 'Inactive'.
            // The system requires an Allotment to be attached to the Service in order to make the service Operational
            List<Allotment__c> allotments = TestDataFactory.createAllotments(RECORD_COUNT, services);
            insert allotments;

            List<Places_Allotment__c> placesAllotments = TestDataFactory.createPlacesAllotments(RECORD_COUNT, allotments);
            setPlacesAllotmentUniqueOracleId(placesAllotments);
            insert placesAllotments;

            // This update will trigger flow Service: Update Service Status Start Date and set service status to operational
            update services;
            Test.getEventBus().deliver();
            Test.stopTest();

            // Then
            String groupName = SERVICE_GROUP_NAME_PREFIX + services[0].Id;
            Group publicGroup = [SELECT Id FROM Group WHERE DeveloperName = :groupName LIMIT 1];
            List<GroupMember> publicGroupMembers = [
                SELECT Id
                FROM GroupMember
                WHERE GroupId = :publicGroup.Id
                AND UserOrGroupId = :providerPortalUsers[0].Id
            ];
            Assert.areEqual(
                RECORD_COUNT, publicGroupMembers.size(),
                'Expected existing community user to be added to public group when SAR is imported AFTER group creation');
        }
    }

    @isTest
    public static void testCreateGroupBeforeSAR() {
        System.runAs(testAdminUser1) {
            // Given
            Id approvedProviderRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
                .get(APPROVED_PROVIDER_REC_TYPE)
                .getRecordTypeId();
            List<Account> providers = [SELECT Id FROM Account WHERE RecordTypeId = :approvedProviderRecordTypeId];

            List<Contact> providerContacts = TestDataFactory.createContact(
                RECORD_COUNT,
                providers
            );
            insert providerContacts;

            List<AccountContactRelation> acrs = [
                SELECT Id
                FROM AccountContactRelation
                WHERE ContactId IN :new Map<Id, Contact>(providerContacts).keySet()
            ];
            for (AccountContactRelation acr : acrs) {
                acr.Roles = AccountContactRelationshipTriggerService.ROLE_STAR_RATING_REVIEWER;
            }
            update acrs;

            List<User> providerPortalUsers = TestDataFactory.createProviderPortalUser(
                RECORD_COUNT,
                providerContacts
            );

            // Test situation that groups are created 'BEFORE' SAR imported so we need to
            // again create new services and make them operational after inserting SARs
            List<BusinessLicense> services = TestDataFactory.createServiceRecords(RECORD_COUNT);
            setServiceUniqueOracleId(services);
            insert services;

            // When
            // As per the new requirements, everytime a service is created, the status will be defaulted to 'Inactive'.
            // The system requires an Allotment to be attached to the Service in order to make the service Operational
            List<Allotment__c> allotments = TestDataFactory.createAllotments(RECORD_COUNT, services);
            insert allotments;

            List<Places_Allotment__c> placesAllotments = TestDataFactory.createPlacesAllotments(RECORD_COUNT, allotments);
            setPlacesAllotmentUniqueOracleId(placesAllotments);
            insert placesAllotments;

            // This update will trigger flow Service: Update Service Status Start Date and set service status to operational
            update services;
            Test.getEventBus().deliver();

            // Insert service account relationships and the flow will assign account to service
            Test.startTest();
            List<Service_Account_Relationship__c> serviceAccountRecords = TestDataFactory.createServiceAccountRecords(
                RECORD_COUNT,
                services,
                providers
            );
            insert serviceAccountRecords;
            Test.stopTest();

            // Then
            String groupName = SERVICE_GROUP_NAME_PREFIX + services[0].Id;
            Group publicGroup = [SELECT Id FROM Group WHERE DeveloperName = :groupName LIMIT 1];
            List<GroupMember> publicGroupMembers = [
                SELECT Id
                FROM GroupMember
                WHERE GroupId = :publicGroup.Id
                AND UserOrGroupId = :providerPortalUsers[0].Id
            ];
            Assert.areEqual(
                RECORD_COUNT, publicGroupMembers.size(),
                'Expected existing community user to be added to public group when SAR is imported BEFORE group creation');
        }
    }


    // When calling TestDataFactory.createServiceRecords more than once, we need to assign unique Oracle_Service_ID__c
    private static void setServiceUniqueOracleId(List<BusinessLicense> services) {
        List<BusinessLicense> serviceWithLastOracleId = [
            SELECT Oracle_Service_ID__c
            FROM BusinessLicense
            ORDER BY Oracle_Service_ID__c DESC
            LIMIT 1
        ];
        if (!serviceWithLastOracleId.isEmpty()) {
            for (Integer i = 0; i < services.size(); i++) {
                services[i].Oracle_Service_ID__c = serviceWithLastOracleId.get(0).Oracle_Service_ID__c + (i + 1);
            }
        }
    }

    // When calling TestDataFactory.createPlacesAllotments more than once, we need to assign unique Oracle_ID__c
    private static void setPlacesAllotmentUniqueOracleId(List<Places_Allotment__c> placesAllotments) {
        List<Places_Allotment__c> placesAllotmentWithLastOracleId = [
            SELECT Oracle_ID__c
            FROM Places_Allotment__c
            ORDER BY Oracle_ID__c DESC
            LIMIT 1
        ];
        if (!placesAllotmentWithLastOracleId.isEmpty()) {
            for (Integer i = 0; i < placesAllotments.size(); i++) {
                placesAllotments[i].Oracle_ID__c = Integer.valueOf(placesAllotmentWithLastOracleId.get(0).Oracle_ID__c) + (i + 1);
            }
        }
    }
}
