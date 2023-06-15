/**
 * @Author      Rami Zuhairi
 * @Date        14-02-2023
 * @Description Test class for StarRatingHistorySelector
 */

@IsTest
private class RegulatoryCodeViolationSelectorTest {
	static final Integer recordCount = 5;
	static final Integer recordCountRD = 5;
	@TestSetup
	private static void setupData() {
		User adminUser = TestDataFactory.createSystemAdminUser();
		Test.startTest();
		System.runAs(adminUser) {
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

			// get ViolationTypes records
			List<ViolationType> violationTypeRecords = TestDataFactory.createQIViolationType(
				recordCount
			);
			insert violationTypeRecords;

			// get RegulatoryCodeViolation records
			List<RegulatoryCodeViolation> regulatoryCodeViolationRecords = TestDataFactory.createQIRegulatoryCodeViolation(
				recordCountRD,
				services,
				providers,
				violationTypeRecords,
				serviceAccountRecords
			);
			insert regulatoryCodeViolationRecords;
		}
		Test.stopTest();
	}

	@IsTest
	private static void testgetRDListBySFServiceIds() {
		Test.startTest();

		//Given
		Id serviceAccountId = [SELECT Id FROM BusinessLicense LIMIT 1].Id;

		List<RegulatoryCodeViolation> resultsActual = [
			SELECT Id
			FROM RegulatoryCodeViolation
			WHERE
				(Service_Name_lookup__c = :serviceAccountId
				AND Status = 'Current')
				OR (Service_Name_lookup__c = :serviceAccountId
				AND Status = 'Non-Current'
				AND Date_Decision_Ends__c >= LAST_N_DAYS:1095)
			ORDER BY Status, CreatedDate DESC
		];

		//When
		List<RegulatoryCodeViolation> resultsTarget = RegulatoryCodeViolationSelector.singletonInstance.getRDListBySFServiceIds(
			serviceAccountId
		);

		//Then
		System.assertEquals(
			resultsActual.size(),
			resultsTarget.size(),
			'Expected results size to match'
		);

		Test.stopTest();
	}
}
