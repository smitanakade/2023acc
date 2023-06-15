/**
 * @auther Rami Zuhairi
 * @date 30-09-2022
 * @description Test class to cover srqiSearchStarRating apex class
 */
@isTest
private class SrqiSearchStarRatingTest {
    @TestSetup private static void setupData() {
        User adminUser = TestDataFactory.createSystemAdminUser();
        Test.startTest();
        System.runAs(adminUser) {
            Integer recordCount = 10;
            // get reporting period
            Reporting_Period__c rPeriod = TestDataFactory.createReportingPeriod(
                'Quarter'
            );
            insert rPeriod;
            // get providers
            List<Account> providers = TestDataFactory.createProviderRecords(
                recordCount
            );
            insert providers;
            // get services
            List<BusinessLicense> services = TestDataFactory.createServiceRecords(
                recordCount
            );
            for (Integer i = 0; i < recordCount; i++) {
                services[i].AccountId = providers[i].Id;
            }
            insert services;
            Test.getEventBus().deliver();
            // get provide contacts
            List<Contact> providerContacts = TestDataFactory.createContact(
                recordCount,
                providers
            );
            insert providerContacts;
            List<User> providerPortalUsers = TestDataFactory.createProviderPortalUser(
                recordCount,
                providerContacts
            );
            // get service account relationships
            List<Service_Account_Relationship__c> serviceAccountRecords = TestDataFactory.createServiceAccountRecords(
                recordCount,
                services,
                providers
            );
            insert serviceAccountRecords;
            // get consumer experience reports
            List<SRQI_CER__c> cerRecords = TestDataFactory.createCERRecords(
                recordCount,
                serviceAccountRecords,
                providers,
                services,
                rPeriod
            );
            insert cerRecords;
            // get ViolationTypes records
            List<ViolationType> violationTypeRecords = TestDataFactory.createQIViolationType(
                recordCount
            );
            insert violationTypeRecords;

            // get RegulatoryCodeViolation records
            List<RegulatoryCodeViolation> regulatoryCodeViolationRecords = TestDataFactory.createQIRegulatoryCodeViolation(
                recordCount,
                services,
                providers,
                violationTypeRecords,
                serviceAccountRecords
            );
            insert regulatoryCodeViolationRecords;
            // get service compliance history
            List<Service_Compliance_History__c> schRecords = TestDataFactory.createServiceComplianceHistory(
                recordCount
            );
            insert schRecords;
            // get star rating history records
            List<STAR_Rating_History__c> srhRecords = TestDataFactory.createStarRatingHistoryRecords(
                recordCount,
                services,
                providers,
                rPeriod
            );
            for (Integer i = 0; i < srhRecords.size(); i++) {
                srhRecords[i].Service_Account_Relationship__c = serviceAccountRecords[i].Id;
                srhRecords[i].Consumer_Experience_Id__c = cerRecords[i].Id;
                srhRecords[i].Service_Compliance_Id__c = schRecords[i].Id;
                srhRecords[i].Rating_Type__c = Math.mod(i, 2) == 0
                    ? 'New Rating'
                    : 'Current Rating';
                srhRecords[i].Status__c = Math.mod(i, 2) == 0
                    ? 'Published'
                    : 'Live';
                srhRecords[i].STAR_Rating_Calculation__c = Math.mod(i, 2) == 0
                    ? 2
                    : 5;

            }
            insert srhRecords;
            // Create public groups
            List<Group> serviceGroups = new List<Group>();
            for (BusinessLicense rec : services) {
                Group grp = new Group(Name = 'SRV_' + rec.Id, DoesIncludeBosses = false);
                serviceGroups.add(grp);
            }
            insert serviceGroups;
            Map<Id, String> accountToGroupName = new Map<Id, String>();
            Map<Id, Account> accountMap = new Map<Id, Account>(providers);
            for (BusinessLicense service : [

                SELECT Id, AccountId
                FROM BusinessLicense
                WHERE AccountId IN :accountMap.keySet()
            ]) {
                accountToGroupName.put(service.AccountId, 'SRV_' + service.Id);
            }
            Map<String, Id> groupNameToGroupIdMap = new Map<String, Id>();
            for (Group g : [
                SELECT Id, DeveloperName
                FROM Group
                WHERE DeveloperName IN :accountToGroupName.values()
            ]) {
                groupNameToGroupIdMap.put(g.DeveloperName, g.Id);
            }
            List<GroupMember> groupMembers = new List<GroupMember>();
            for (Integer i = 0; i < recordCount; i++) {
                GroupMember gm = new GroupMember(
                    GroupId = groupNameToGroupIdMap.get(
                        accountToGroupName.get(providers[i].Id)
                    ),
                    UserOrGroupId = providerPortalUsers[i].Id
                );
                groupMembers.add(gm);
            }
            insert groupMembers;


        }
        Test.stopTest();
    }

    @isTest
    private static void testGetFilterValuesAndDefaultSearchResults() {
        Test.startTest();
        // When
        System.runAs(getProviderPortalUser()) {
            Map<String, Object> results = SrqiSearchStarRating.getFilterValuesAndDefaultSearchResults();
            // Then
            System.assertEquals(1, ((Set<String>) results.get('reportingPeriods')).size(), 'Expected reportingPeriods size to match');
            System.assertEquals(1, ((Set<String>) results.get('statuses')).size(), 'Expected statuses size to match');
            System.assertEquals(1, ((Set<String>) results.get('ratingTypes')).size(), 'Expected ratingTypes size to match');
            System.assertEquals(1, ((List<String>) results.get('ratings')).size(), 'Expected ratings size to match');
            System.assertEquals(1, ((List<STAR_Rating_History__c>) results.get('defaultSearchResults')).size(), 'Expected defaultSearchResults size to match');
        }
        Test.stopTest();
    }

    @isTest
    private static void testSearchStarRatingHistoriesByReportingPeriod() {
        //Given
        String reportingPeriod = [SELECT Reporting_Period_Short__c FROM Reporting_Period__c LIMIT 1].Reporting_Period_Short__c;
        SrqiSearchStarRating.SearchConfig searchConfig = new SrqiSearchStarRating.SearchConfig();
        searchConfig.reportingPeriods.add(reportingPeriod);
        searchConfig.ratingTypes.add('New');
        Test.startTest();
        // When
        System.runAs(getProviderPortalUser()) {
            List<STAR_Rating_History__c> results = SrqiSearchStarRating.searchStarRatingHistories(searchConfig);
            // Then
            Assert.areEqual(1, results.size(), 'Expected results size to match');
        }
        Test.stopTest();
    }

    @isTest
    private static void testSearchStarRatingHistoriesByRatingType() {
        //Given
        SrqiSearchStarRating.SearchConfig searchConfig = new SrqiSearchStarRating.SearchConfig();
        searchConfig.ratingTypes.add('New');
        Test.startTest();
        // When
        System.runAs(getProviderPortalUser()) {
            List<STAR_Rating_History__c> results = SrqiSearchStarRating.searchStarRatingHistories(searchConfig);
            // Then
            Assert.areEqual(1, results.size(), 'Expected results size to match');
        }
        Test.stopTest();
    }

    @isTest
    private static void testSearchStarRatingHistoriesByStatus() {
        //Given
        SrqiSearchStarRating.SearchConfig searchConfig = new SrqiSearchStarRating.SearchConfig();
        searchConfig.statuses.add('Preview');
        Test.startTest();
        // When
        System.runAs(getProviderPortalUser()) {
            List<STAR_Rating_History__c> results = SrqiSearchStarRating.searchStarRatingHistories(searchConfig);
            // Then
            Assert.areEqual(1, results.size(), 'Expected results size to match');
        }
        Test.stopTest();
    }

    @isTest
    private static void testSearchStarRatingHistoriesByOverallRating() {
        //Given
        SrqiSearchStarRating.SearchConfig searchConfig = new SrqiSearchStarRating.SearchConfig();
        searchConfig.ratings.add('2');
        Test.startTest();
        // When
        System.runAs(getProviderPortalUser()) {
            List<STAR_Rating_History__c> results = SrqiSearchStarRating.searchStarRatingHistories(searchConfig);
            // Then
            Assert.areEqual(1, results.size(), 'Expected results size to match');
        }
        Test.stopTest();
    }

    @isTest
    private static void testSearchStarRatingHistoriesByServiceName() {
        //Given
        SrqiSearchStarRating.SearchConfig searchConfig = new SrqiSearchStarRating.SearchConfig();
        searchConfig.serviceNamesOrIds = 'Service Test 0';
        Test.startTest();
        // When
        System.runAs(getProviderPortalUser()) {
            List<STAR_Rating_History__c> results = SrqiSearchStarRating.searchStarRatingHistories(searchConfig);
            // Then
            Assert.areEqual(1, results.size(), 'Expected results size to match');
        }
        Test.stopTest();
    }


    @isTest
    private static void testSearchStarRatingHistoriesByServiceId() {
        //Given
        String serviceId = [SELECT Integration_ID__c FROM BusinessLicense WHERE Name = 'Service Test 0'].Integration_ID__c;
        SrqiSearchStarRating.SearchConfig searchConfig = new SrqiSearchStarRating.SearchConfig();
        searchConfig.serviceNamesOrIds = serviceId;
        Test.startTest();
        // When
        System.runAs(getProviderPortalUser()) {
            List<STAR_Rating_History__c> results = SrqiSearchStarRating.searchStarRatingHistories(searchConfig);
            // Then
            Assert.areEqual(1, results.size(), 'Expected results size to match');
        }
        Test.stopTest();
    }

    @isTest
    private static void testSearchStarRatingHistoriesNegative() {
        //Given
        SrqiSearchStarRating.SearchConfig searchConfig = new SrqiSearchStarRating.SearchConfig();
        searchConfig.serviceNamesOrIds = 'Test non-extsting';
        Test.startTest();
        // When
        System.runAs(getProviderPortalUser()) {
            List<STAR_Rating_History__c> results = SrqiSearchStarRating.searchStarRatingHistories(searchConfig);
            // Then
            Assert.areEqual(0, results.size(), 'Expected results size to match');
        }
        Test.stopTest();
    }

    @isTest
    static void testGetServiceNameRecords() {
        Test.startTest();
        System.runAs(getProviderPortalUser()) {
            List<BusinessLicense> results = srqiSearchStarRating.getServiceNameRecords();
            System.assertEquals(1, results.size(), 'Expected results size to match');
        }
        Test.stopTest();
    }

    @isTest
    static void testGetServiceNameIDRecord() {
        Test.startTest();
        System.runAs(getProviderPortalUser()) {
            String integrationID = [SELECT Id FROM BusinessLicense WHERE Name = 'Service Test 0'].Id;
            String returnedIntegrationID = srqiSearchStarRating.getServiceNameIDRecord('Service Test 0');
            System.assertEquals(integrationID, returnedIntegrationID, 'Expected integrationID to match');
        }
        Test.stopTest();
    }

    @isTest
    static void testGetServiceNameIDRecordNegative() {
        Boolean hasError = false;
        Test.startTest();
        System.runAs(getProviderPortalUser()) {
            try {
                String returnedIntegrationID = srqiSearchStarRating.getServiceNameIDRecord('Test non-existence');
            } catch (AuraHandledException ex) {
                hasError = true;
            }
            System.assert(hasError, 'Expected error to occur');
        }
        Test.stopTest();
    }

    private static User getProviderPortalUser() {
        return [SELECT Id FROM User WHERE Username LIKE 'ProviderPortalTestClassUser0%' LIMIT 1];
    }
}