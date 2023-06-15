@isTest
public with sharing class StarRatingExemptionBatchTest {
	static final String NEW_RATING = 'New Rating';
	static final String CURRENT_RATING = 'Current Rating';

	@isTest
	public static void testExpriedStarRatingExemptionBatch() {
		Integer recordCount = 2;
		User testUser = TestDataFactory.createSystemAdminUser();

		Test.startTest();
		System.runAs(testUser){

			// create report period type year
			Reporting_Period__c yearRP = TestDataFactory.createReportingPeriod('Year');
			Integer yearDate = System.today().Year() - 1;
			yearRP.Start_Date__c = date.newInstance(yearDate, 7, 1);
			yearRP.End_Date__c = date.newInstance(yearDate, 12, 31);
			insert yearRP;

			// create report period type quarter
			Reporting_Period__c quarterRP = TestDataFactory.createReportingPeriod('Quarter');
			quarterRP.Start_Date__c = (System.today() + 12 ).addMonths(-6);
			quarterRP.End_Date__c = (System.today() + 24).addMonths(-3);
			insert quarterRP;

			// create services
			List<BusinessLicense> services = TestDataFactory.createServiceRecords(recordCount);

			// update services exemption flags
			for (BusinessLicense servRec : services) {
				servRec.CER_Exempt__c = true;
				servRec.CM_Exempt__c = true;
				servRec.QI_Exempt__c = true;
				servRec.SCR_Exempt__c = true;
			}

			insert services;

			// create expired cer exemptions
			List<SRQI_Exemption__c> cerExemptionList = TestDataFactory.createCERExemptionRecords(recordCount, services);
			insert cerExemptionList;

			// create expired cm exemptions
			List<SRQI_Exemption__c> cmExemptionList = TestDataFactory.createCMExemptionRecords(recordCount, services);
			insert cmExemptionList;

			// create expired qi exemptions
			List<SRQI_Exemption__c> qiExemptionList = TestDataFactory.createQIExemptionRecords(recordCount, services);
			insert qiExemptionList;

			// create expired scr exemptions
			List<SRQI_Exemption__c> scrExemptionList = TestDataFactory.createSCRExemptionRecords(recordCount, services);
			insert scrExemptionList;

			// create providers
			List<Account> providers = TestDataFactory.createProviderRecords(recordCount);
			insert providers;

			// create sar
			List<Service_Account_Relationship__c> sar = TestDataFactory.createServiceAccountRecords(
				recordCount,
				services,
				providers
			);
			insert sar;

			// create CER records
			List<SRQI_CER__c> cerRecords = TestDataFactory.createCERRecords(recordCount, sar, providers, services, yearRP);
			for (SRQI_CER__c cerRec : cerRecords) {
				cerRec.Rating_Type__c = NEW_RATING;
				cerRec.Under_Review__c = false;
			}
			insert cerRecords;

			// create CM records
			List<Care_Minutes_Summary__c> cmRecords = TestDataFactory.createCareMinuteSummary(recordCount, services);
			for (Care_Minutes_Summary__c cmRec : cmRecords) {
				cmRec.Under_Review__c = false;
				cmRec.Provider_Name__c = providers[0].Id;
				cmRec.Service_Account__c = sar[0].Id;
			}
			insert cmRecords;

			// create QI records
			List<Quality_Indicator_Summary__c> qiRecords = TestDataFactory.createQISummaryRecords(
				recordCount,
				providers,
				quarterRP,
				services,
				sar
			);
			for (Quality_Indicator_Summary__c qiRec : qiRecords) {
				qiRec.Rating_Type__c = NEW_RATING;
				qiRec.Under_Review__c = false;
			}
			insert qiRecords;

			// create star rating history records
			List<STAR_Rating_History__c> starRatingHistory = TestDataFactory.createStarRatingHistoryRecords(
				recordCount,
				services,
				providers,
				quarterRP
			);

			for (Integer i = 0; i < recordCount; i++) {
				starRatingHistory[i].Consumer_Experience_Id__c = cerRecords[i].Id;
				starRatingHistory[i].Care_Minutes_Id__c = cmRecords[i].Id;
				starRatingHistory[i].Quality_Indicator_Id__c = qiRecords[i].Id;
				starRatingHistory[i].Rating_Type__c = Math.mod(i, 2) == 0 ? NEW_RATING : CURRENT_RATING;
			}

			insert starRatingHistory;

		}
		StarRatingExemptionBatch batchJob = new StarRatingExemptionBatch();
		Database.executeBatch(batchJob);
		Test.stopTest();

		// Get services
		List<BusinessLicense> allServices = [
			SELECT Id, CER_Exempt__c, CM_Exempt__c, QI_Exempt__c, SCR_Exempt__c
			FROM BusinessLicense
		];

		// Check if exemption flags were reset
		for (BusinessLicense servRec : allServices) {
			System.assertEquals(false, servRec.CER_Exempt__c, 'CER exemption flag must be false');
			System.assertEquals(false, servRec.CM_Exempt__c, 'CM exemption flag must be false');
			System.assertEquals(false, servRec.QI_Exempt__c, 'QI exemption flag must be false');
			System.assertEquals(false, servRec.SCR_Exempt__c, 'SCR exemption flag must be false');
		}
	}

	@isTest
	public static void testActiveStarRatingExemptionBatch() {
		Integer recordCount = 10;
		User testUser = TestDataFactory.createSystemAdminUser();

		Test.startTest();
		System.runAs(testUser){

			// create report period type year
			Reporting_Period__c yearRP = TestDataFactory.createReportingPeriod('Year');
			Integer yearDate = System.today().Year() - 1;
			yearRP.Start_Date__c = date.newInstance(yearDate, 7, 1);
			yearRP.End_Date__c = date.newInstance(yearDate, 12, 31);
			insert yearRP;

			// create services
			List<BusinessLicense> services = TestDataFactory.createServiceRecords(recordCount);
			insert services;

			// create active cm exemptions
			List<SRQI_Exemption__c> cmExemptionList = TestDataFactory.createCMExemptionRecords(recordCount, services);

			for (SRQI_Exemption__c exempRec : cmExemptionList) {
				exempRec.Exemption_Finish__c = System.today().addYears(2);
			}

			insert cmExemptionList;

		}
		StarRatingExemptionBatch batchJob = new StarRatingExemptionBatch();
		Database.executeBatch(batchJob);
		Test.stopTest();

		// Get services
		List<BusinessLicense> allServices = [
			SELECT Id, CER_Exempt__c, CM_Exempt__c, QI_Exempt__c, SCR_Exempt__c
			FROM BusinessLicense
		];

		// Check if exemption flags were reset
		for (BusinessLicense servRec : allServices) {
			System.assertEquals(true, servRec.CM_Exempt__c, 'CM exemption flag must be true');
		}
	}
}