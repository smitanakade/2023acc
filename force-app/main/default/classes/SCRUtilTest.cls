@isTest
private class SCRUtilTest {
	private static User testUser = TestDataFactory.createSystemAdminUser();
	static final String SERVICE_STATUS = 'Operational';
	static final String SERVICE_CARE_TYPE = 'Residential';
	static final String SERVICE_REC_TYPE = 'Approved_Provider_Service';
	static final String LIVE_STATUS = 'LIVE';
	static final String CURRENT_RATING = 'Current Rating';

	@TestSetup
	static void dataSetup() {
		Integer recordCount = 1;

		Test.startTest();
		System.runAs(testUser) {
			// insert reporting period
			Reporting_Period__c rPeriod = TestDataFactory.createReportingPeriod('Quarter');
			rPeriod.Start_Date__c = (System.today() + 12).addMonths(-6);
			rPeriod.End_Date__c = (System.today() + 24).addMonths(-3);
			insert rPeriod;

			// insert providers
			List<Account> providers = TestDataFactory.createProviderRecords(recordCount);
			insert providers;

			// insert care type
			List<Care_Type__c> careTypeList = TestDataFactory.createSCRcareType(1, providers);
			insert careTypeList;
			// insert services
			List<BusinessLicense> services = TestDataFactory.createServiceRecords(recordCount);
			for (Integer i = 0; i < recordCount; i++) {
				services[i].Status__c = SERVICE_STATUS;
				services[i].Care_Type__c = SERVICE_CARE_TYPE;
				services[i].RecordTypeId = Schema.SObjectType.BusinessLicense.getRecordTypeInfosByDeveloperName()
					.get(SERVICE_REC_TYPE)
					.getRecordTypeId();
				services[i].AccountId = providers[i].Id;
				services[i].Operational_Two_Last_Quarters__c = true;
			}
			insert services;

			// create allotment
			List<Allotment__c> allAlots = new List<Allotment__c>();
			for (Integer i = 0; i < recordCount; i++) {
				Allotment__c allot = new Allotment__c();
				allot.Service_Name__c = services[i].Id;
				allAlots.add(allot);
			}
			insert allAlots;

			// create Places Allotment
			List<Places_Allotment__c> placeAllot = new List<Places_Allotment__c>();
			for (Integer i = 0; i < recordCount; i++) {
				Places_Allotment__c pallot = new Places_Allotment__c();
				pallot.Number_of_Places__c = 4;
				pallot.Status_of_Places__c = 'Operational';
				pallot.Current__c = 'Yes';
				pallot.Allotment__c = allAlots[i].Id;
				placeAllot.add(pallot);
			}

			insert placeAllot;
			update services;

			// insert service account relationships
			List<Service_Account_Relationship__c> serviceAccountRecords = TestDataFactory.createServiceAccountRecords(
				recordCount,
				services,
				providers
			);
			insert serviceAccountRecords;

			// get quality indicator summary
			List<Quality_Indicator_Summary__c> qisRecords = TestDataFactory.createQISummaryRecords(
				1,
				providers,
				rPeriod,
				services,
				serviceAccountRecords
			);
			qisRecords.get(0).Quality_Indicator_Rating__c = 4;
			insert qisRecords;

			// get consumer experience reports
			List<SRQI_CER__c> cerRecords = TestDataFactory.createCERRecords(
				1,
				serviceAccountRecords,
				providers,
				services,
				rPeriod
			);
			cerRecords.get(0).Consumer_Experience_Rating__c = 4;
			insert cerRecords;

			// get care minutes summary
			List<Care_Minutes_Summary__c> cmsRecords = TestDataFactory.createCareMinuteSummary(1, services);
			for (Care_Minutes_Summary__c cmsRecord : cmsRecords) {
				cmsRecord.Reporting_Period__c = rPeriod.Id;
				cmsRecord.Provider_Name__c = providers.get(0).Id;
				cmsRecord.Service_Account__c = serviceAccountRecords.get(0).Id;
			}
			cmsRecords.get(0).Care_Minutes_Rating__c = 4;
			insert cmsRecords;

			List<STAR_Rating_History__c> currentSRH = TestDataFactory.createStarRatingHistoryRecordsWithSAR(
				1,
				services,
				providers,
				rPeriod,
				serviceAccountRecords
			);
			currentSRH.get(0).Status__c = LIVE_STATUS;
			currentSRH.get(0).Rating_Type__c = CURRENT_RATING;
			currentSRH.get(0).Go_Live_Date__c = Date.today().addDays(-2);
			currentSRH.get(0).Publish_Date__c = currentSRH.get(0).Go_Live_Date__c.addDays(-10);
			currentSRH.get(0).Consumer_Experience_Id__c = cerRecords.get(0).Id;
			currentSRH.get(0).Care_Minutes_Id__c = cmsRecords.get(0).Id;
			currentSRH.get(0).Quality_Indicator_Id__c = qisRecords.get(0).Id;
			currentSRH.get(0).STAR_Rating_Calculation__c = 4;
			insert currentSRH;
		}
		Test.stopTest();
	}

	/**
	 * Scenario: service has a current and live SRH. New SCRH will be generated.
	 * Expected result: original SRH to be updated to previous;new srh to contain new SCRH;
	 */
	@isTest
	static void testCurrentAndLiveSRHOnly() {
		// Prepping data
		List<BusinessLicense> service = [
			SELECT Id
			FROM BusinessLicense
			LIMIT 1
		];
		List<Service_Account_Relationship__c> sar = [
			SELECT Id
			FROM Service_Account_Relationship__c
			LIMIT 1
		];
		List<Account> provider = [SELECT Id FROM Account LIMIT 1];

		List<Service_Compliance_History__c> scrh = new List<Service_Compliance_History__c>{
			new Service_Compliance_History__c(
				Service__c = service.get(0).Id,
				Service_Account__c = sar.get(0).Id,
				Provider__c = provider.get(0).Id,
				Service_Compliance_Rating__c = 1,
				Rating_Type__c = CURRENT_RATING,
				Availability_Status__c = LIVE_STATUS
			)
		};

		// Simulate creation of scrh by scr batch
		Test.startTest();
		System.runAs(testUser) {
			insert scrh;

			Map<Id, BusinessLicense> services = new Map<Id, BusinessLicense>(service);
			Map<Id, Service_Account_Relationship__c> sars = new Map<Id, Service_Account_Relationship__c>(sar);
			SCRUtil.createNUpdateSCR(services.keySet(), sars.keySet(), scrh);
		}
		Test.stopTest();

		// Assert results
		List<STAR_Rating_History__c> originalSRH = [
			SELECT Id
			FROM STAR_Rating_History__c
			WHERE Rating_Type__c = 'Previous Rating'
		];
		List<STAR_Rating_History__c> newSRH = [
			SELECT Id, Rating_Type__c, Status__c, STAR_Rating_Calculation__c, Service_Compliance_Id__c
			FROM STAR_Rating_History__c
			WHERE Id != :originalSRH.get(0).Id
		];

		Assert.areEqual(1, originalSRH.size(), 'We should have 1 SRH set to previous rating');

		Assert.areEqual(
			scrh.get(0).Id,
			newSRH.get(0).Service_Compliance_Id__c,
			'new srh should have new scrh attached'
		);
	}

	/**
	 * Scenario: service has a current and live SRH and a new rating and published SRH. New SCRH will be generated.
	 * Expected result: original SRH to be updated to previous;new srh to be created and to contain new SCRH;
	 * new rating and published SRH to be updated with new SCRH
	 */
	@isTest
	static void testCurrentAndNewRating() {
		// Prepping data
		List<STAR_Rating_History__c> originalSRH = [
			SELECT Id, Rating_Type__c
			FROM STAR_Rating_History__c
			LIMIT 1
		];

		List<BusinessLicense> service = [
			SELECT Id
			FROM BusinessLicense
			LIMIT 1
		];
		List<Service_Account_Relationship__c> sar = [
			SELECT Id
			FROM Service_Account_Relationship__c
			LIMIT 1
		];
		List<Account> provider = [SELECT Id FROM Account LIMIT 1];
		List<Reporting_Period__c> rPeriod = [
			SELECT Id
			FROM Reporting_Period__c
			LIMIT 1
		];
		List<SRQI_CER__c> cerRecords = [SELECT Id FROM SRQI_CER__C LIMIT 1];
		List<Care_Minutes_Summary__c> cmsRecords = [
			SELECT Id
			FROM Care_Minutes_Summary__c
			LIMIT 1
		];
		List<Quality_Indicator_Summary__c> qisRecords = [
			SELECT Id
			FROM Quality_Indicator_Summary__c
			LIMIT 1
		];
		List<STAR_Rating_History__c> newRatingSRH = TestDataFactory.createStarRatingHistoryRecordsWithSAR(
			1,
			service,
			provider,
			rPeriod.get(0),
			sar
		);
		newRatingSRH.get(0).Status__c = 'Published';
		newRatingSRH.get(0).Rating_Type__c = 'New Rating';
		newRatingSRH.get(0).Go_Live_Date__c = Date.today().addDays(+10);
		newRatingSRH.get(0).Publish_Date__c = Date.today().addDays(-4);
		newRatingSRH.get(0).Consumer_Experience_Id__c = cerRecords.get(0).Id;
		newRatingSRH.get(0).Care_Minutes_Id__c = cmsRecords.get(0).Id;
		newRatingSRH.get(0).Quality_Indicator_Id__c = qisRecords.get(0).Id;
		newRatingSRH.get(0).STAR_Rating_Calculation__c = 4;
		insert newRatingSRH;

		List<Service_Compliance_History__c> scrh = new List<Service_Compliance_History__c>{
			new Service_Compliance_History__c(
				Service__c = service.get(0).Id,
				Service_Account__c = sar.get(0).Id,
				Provider__c = provider.get(0).Id,
				Service_Compliance_Rating__c = 1,
				Rating_Type__c = CURRENT_RATING,
				Availability_Status__c = LIVE_STATUS
			)
		};

		// Simulate creation of scrh by scr batch
		Test.startTest();
		System.runAs(testUser) {
			insert scrh;

			Map<Id, BusinessLicense> services = new Map<Id, BusinessLicense>(service);
			Map<Id, Service_Account_Relationship__c> sars = new Map<Id, Service_Account_Relationship__c>(sar);
			SCRUtil.createNUpdateSCR(services.keySet(), sars.keySet(), scrh);
		}
		Test.stopTest();

		// Assert results
		List<STAR_Rating_History__c> originalSRHUpdated = [
			SELECT Id, Rating_Type__c
			FROM STAR_Rating_History__c
			WHERE Id = :originalSRH.get(0).Id
			LIMIT 1
		];

		List<STAR_Rating_History__c> newRatingSRHUpdated = [
			SELECT Id, Service_Compliance_Id__c
			FROM STAR_Rating_History__c
			WHERE Id = :newRatingSRH.get(0).Id
			LIMIT 1
		];

		List<STAR_Rating_History__c> currentSRH = [
			SELECT Id, Service_Compliance_Id__c
			FROM STAR_Rating_History__c
			WHERE Id != :newRatingSRH.get(0).Id AND Id != :originalSRH.get(0).Id
			LIMIT 1
		];

		Assert.areEqual(
			'Previous Rating',
			originalSRHUpdated.get(0).Rating_Type__c,
			'Original SRH should be set to previous rating'
		);
		Assert.areEqual(
			scrh.get(0).Id,
			newRatingSRHUpdated.get(0).Service_Compliance_Id__c,
			'New Rating SRH should be updated with new SCRH'
		);
		Assert.areEqual(
			scrh.get(0).Id,
			currentSRH.get(0).Service_Compliance_Id__c,
			'Current SRH should be updated with new SCRH'
		);
	}
}
