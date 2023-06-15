/**
 * @auther Kai-Fan Hsieh
 * @date 14-02-2023
 * @description Test class to cover SrqiStarRatingHistoryRetrieval apex class
 */
@isTest
private class srqiStarRatingHistoryRetrievalTest {
    @TestSetup
    private static void setupData() {
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
            for(Integer i = 0 ; i < recordCount; i++ ){
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
            }
            insert srhRecords;
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

    @IsTest
    private static void testGetSRHListBySFServiceIds() {
        //Given
        Id serviceId = [SELECT Id FROM BusinessLicense WHERE Name = 'Service Test 0' LIMIT 1].Id;
        Test.startTest();
        System.runAs(getProviderPortalUser()) {
            //When
            List<STAR_Rating_History__c> results = SrqiStarRatingHistoryRetrieval.getSRHListBySFServiceId(
                serviceId
            );
            //Then
            Assert.areEqual(1, results.size(), 'Expected result set size to match');
        }
        Test.stopTest();
    }

    @IsTest
    private static void testgetRDListBySFServiceAccountId() {
        //Given
        Id serviceId = [SELECT Id FROM BusinessLicense LIMIT 1].Id;
        //When
        List<RegulatoryCodeViolation> results = SrqiStarRatingHistoryRetrieval.getRDListBySFServiceAccountId(
            serviceId
        );
        //Then
        Assert.areEqual(1, results.size(), 'Expected result set size to match');
    }
    @IsTest
    private static void testgetRDListBySFServiceIdsFakeError() {
        Test.startTest();
        System.runAs(getProviderPortalUser()) {
            //Given
            Boolean hasError = false;
            //When
            try {
                srqiStarRatingHistoryRetrieval.fakeException = true;
                Id serviceAccountId = [SELECT Id FROM BusinessLicense LIMIT 1]
                .Id;
                SrqiStarRatingHistoryRetrieval.getRDListBySFServiceAccountId(
                    serviceAccountId
                );
            } catch (Exception ex) {
                hasError = true;
            }
            //Then
            System.assert(hasError, 'Expected error occurs');
        }
        Test.stopTest();
    }
    private static User getProviderPortalUser() {
        return [
            SELECT Id
            FROM User
            WHERE Username LIKE 'ProviderPortalTestClassUser0%'
            LIMIT 1
        ];
    }
}