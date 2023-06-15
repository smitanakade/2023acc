@isTest
private with sharing class StarRatingsSettingsCustomMetadataTest {
	private static Integer RECORD_COUNT = 1;
	private static User testAdminUser1 = TestDataFactory.insertNewSysAdmin();

	@TestSetup
	static void makeData() {
		System.runAs(testAdminUser1) {
			// Insert previous quarter reporting period
			Reporting_Period__c rPeriod = TestDataFactory.createReportingPeriod('Quarter');
			rPeriod.Start_Date__c = (System.today() + 12).addMonths(-6);
			rPeriod.End_Date__c = (System.today() + 24).addMonths(-3);
			insert rPeriod;

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

			List<Places_Allotment__c> placesAllotments = TestDataFactory.createPlacesAllotments(
				RECORD_COUNT,
				allotments
			);
			insert placesAllotments;

			// This update will trigger flow Service: Update Service Status Start Date and set service status to operational
			update services;
			Test.getEventBus().deliver();

			// Insert service account relationships
			List<Service_Account_Relationship__c> serviceAccountRecords = TestDataFactory.createServiceAccountRecords(
				RECORD_COUNT,
				services,
				providers
			);
			insert serviceAccountRecords;
		}
	}

	/**
	 * Test star ratings settings custom metadata config
	 * Expected result: fields should match the values set in test method
	 */
	@isTest
	static void starRatingsSettingsConfigTest() {
		Test.startTest();
		System.runAs(testAdminUser1) {
			StarRatingsSettingsCustomMetadata.daysAfterDateDecisionEndsOne = 500;
			StarRatingsSettingsCustomMetadata.daysAfterDateDecisionEndsTwo = 400;
			StarRatingsSettingsCustomMetadata.goLiveDate = 30;
			StarRatingsSettingsCustomMetadata.publishDate = 20;
		}
		Test.stopTest();

		// Assert Results
		Assert.areEqual(500, StarRatingsSettingsCustomMetadata.daysAfterDateDecisionEndsOne, 'Value should be 500');
		Assert.areEqual(400, StarRatingsSettingsCustomMetadata.daysAfterDateDecisionEndsTwo, 'Value should be 400');
		Assert.areEqual(30, StarRatingsSettingsCustomMetadata.goLiveDate, 'Value should be 30');
		Assert.areEqual(20, StarRatingsSettingsCustomMetadata.publishDate, 'Value should be 20');
	}

	/**
	 * Test SRH creation using the default values of STARRating_Settings__mdt
	 * Expected result: publish date = today, go-live date = today + 14
	 */
	@isTest
	static void defaultCustomMetadataTest() {
		Test.startTest();
		System.runAs(testAdminUser1) {
			RatingsCalculationService.starRatingRecords();
		}
		Test.stopTest();

		// Asserts Result
		List<STAR_Rating_History__c> srhsCreated = [
			SELECT Id, Go_Live_Date__c, Publish_Date__c
			FROM STAR_Rating_History__c
			LIMIT 1
		];
		Assert.areNotEqual(0, srhsCreated.size(), 'SRH should have been created');
		Assert.areEqual(System.today(), srhsCreated.get(0).Publish_Date__c, 'Default publish date is current day');
		Assert.areEqual(
			System.today().addDays(14),
			srhsCreated.get(0).Go_Live_Date__c,
			'Default golive date is today + 14 days'
		);
	}

	/**
	 * Test SRH creation using the CUSTOM values of STARRating_Settings__mdt
	 * Expected result: publish date = today + 5, go-live date = today + 20
	 */
	@isTest
	static void customValuesCustomMetadataTest() {
		// Set custom values in custom metadata
		StarRatingsSettingsCustomMetadata.goLiveDate = 20;
		StarRatingsSettingsCustomMetadata.publishDate = 5;

		Test.startTest();
		System.runAs(testAdminUser1) {
			RatingsCalculationService.starRatingRecords();
		}
		Test.stopTest();

		// Asserts Result
		List<STAR_Rating_History__c> srhsCreated = [
			SELECT Id, Go_Live_Date__c, Publish_Date__c
			FROM STAR_Rating_History__c
			LIMIT 1
		];
		Assert.areNotEqual(0, srhsCreated.size(), 'SRH should have been created');
		Assert.areEqual(
			System.today().addDays(5),
			srhsCreated.get(0).Publish_Date__c,
			'Custom publish date is current day + 5 days'
		);
		Assert.areEqual(
			System.today().addDays(20),
			srhsCreated.get(0).Go_Live_Date__c,
			'Custom golive date is today + 20 days'
		);
	}
}
