/**
 * @Author      Kai-Fan Hsieh
 * @Date        14-02-2023
 * @Description Test class for StarRatingHistorySelector
 */
@IsTest
private class StarRatingHistorySelectorTest {

    static final Integer recordCount = 20;
    @TestSetup
    static void dataSetup() {
        User testUser = TestDataFactory.createSystemAdminUser();

        Test.startTest();
        System.runAs(testUser) {
            // get reporting period
            Reporting_Period__c rPeriod = TestDataFactory.createReportingPeriod('Quarter');
            insert rPeriod;
            // get accounts
            List<Account> providers = TestDataFactory.createProviderRecords(recordCount);
            insert providers;
            // get services
            List<BusinessLicense> services = TestDataFactory.createServiceRecords(recordCount);
            insert services;
            // get service account relationships
            List<Service_Account_Relationship__c> serviceAccountRecords = TestDataFactory.createServiceAccountRecords(recordCount, services, providers);
            insert serviceAccountRecords;
            // get Service Compliance History
            List<Service_Compliance_History__c> schRecords = TestDataFactory.createServiceComplianceHistory(recordCount);
            insert schRecords;
            // get star rating history
            List<STAR_Rating_History__c> srhRecords = TestDataFactory.createStarRatingHistoryRecords(recordCount, services, providers, rPeriod);
            for (Integer i = 0; i < srhRecords.size(); i++) {
                srhRecords[i].Service_Compliance_Id__c = schRecords[i].Id;
                srhRecords[i].Rating_Type__c = Math.mod(i, 2) == 0 ? 'New Rating' : 'Current Rating';
                srhRecords[i].Status__c = Math.mod(i, 2) == 0 ? 'Draft' : 'Published';
            }
            insert srhRecords;
        }
        Test.stopTest();
    }

    @IsTest
    private static void testGetSRHListBySFServiceIds() {
        //Given
        Map<Id, BusinessLicense> services = new Map<Id, BusinessLicense>([SELECT Id FROM BusinessLicense]);
        //When
        List<STAR_Rating_History__c> results = StarRatingHistorySelector.singletonInstance.getSRHListBySFServiceIds(services.keySet());
        //Then
        Assert.areEqual(recordCount / 2, results.size(), 'Expected result set size to match');
    }
}