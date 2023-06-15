@isTest
private with sharing class CerHybridBatchTest {
	private static User testUser = TestDataFactory.insertNewSysAdmin();
	static final String SERVICE_STATUS = 'Operational';
	static final String SERVICE_CARE_TYPE = 'Residential';
	static final String SERVICE_REC_TYPE = 'Approved_Provider_Service';

	@TestSetup
	static void makeData() {
		Integer recordCount = 1;

		System.runAs(testUser) {
			// insert reporting period
			Reporting_Period__c rPeriod = TestDataFactory.createReportingPeriod('Quarter');
			rPeriod.Start_Date__c = (System.today() + 12).addMonths(-6);
			rPeriod.End_Date__c = (System.today() + 24).addMonths(-3);
			insert rPeriod;
			// insert reporting period
			Reporting_Period__c rPeriodYear = TestDataFactory.createReportingPeriod('Year');
			Integer yearDate = System.today().Year() - 1;
			rPeriodYear.Start_Date__c = System.today().addMonths(-12);
			rPeriodYear.End_Date__c = System.today().addMonths(-9);
			insert rPeriodYear;
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
			// This update will trigger flow Service: Update Service Status Start Date and set service status to operational
			update services;
			// insert service account relationships
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
				rPeriodYear
			);
			insert cerRecords;
			// get star rating history records
			List<STAR_Rating_History__c> srhRecords = TestDataFactory.createStarRatingHistoryRecords(
				recordCount,
				services,
				providers,
				rPeriod
			);
			for (Integer i = 0; i < srhRecords.size(); i++) {
				srhRecords[i].Rating_Type__c = 'Draft Rating';
				srhRecords[i].Status__c = 'Draft';
				srhRecords[i].Service_Account_Relationship__c = serviceAccountRecords[i].Id;
				srhRecords[i].Consumer_Experience_Id__c = cerRecords[i].Id;
			}
			insert srhRecords;
		}
	}

	@isTest
	static void testPeriodicalCalcCall() {
		Test.setMock(HttpCalloutMock.class, new CERExpressionSetMock());
		Test.startTest();
		System.runAs(testUser) {
			Database.executeBatch(new CerHybridBatch(true), 90);
		}
		Test.stopTest();
		List<SRQI_CER__c> cer = [SELECT Id, Consumer_Experience_Rating__c FROM SRQI_CER__C];
		Assert.areEqual(3.0, cer[0].Consumer_Experience_Rating__c, 'CER rating should be 3.0');
	}

	@isTest
	static void testRecalculationCall() {
		Map<Id, SRQI_CER__C> cers = new Map<Id, SRQI_CER__C>([SELECT Id FROM SRQI_CER__c]);
		Map<Id, BusinessLicense> services = new Map<Id, BusinessLicense>([SELECT Id FROM BusinessLicense]);
		Test.setMock(HttpCalloutMock.class, new CERExpressionSetMock());
		Test.startTest();
		System.runAs(testUser) {
			Database.executeBatch(new CerHybridBatch(cers.keySet(), services.keySet()), 90);
		}
		Test.stopTest();
		List<SRQI_CER__c> cer = [SELECT Id, Consumer_Experience_Rating__c FROM SRQI_CER__C];
		Assert.areEqual(3.0, cer[0].Consumer_Experience_Rating__c, 'CER rating should be 3.0');
	}

	@isTest
	static void testRecalculationConsentRevokedCall() {
		List<BusinessLicense> service = [SELECT Id, CER_Consent_Revoked__c FROM BusinessLicense LIMIT 1];
		service[0].CER_Consent_Revoked__c = true;
		update service;
		Map<Id, SRQI_CER__C> cers = new Map<Id, SRQI_CER__C>([SELECT Id FROM SRQI_CER__c]);
		Map<Id, BusinessLicense> services = new Map<Id, BusinessLicense>([SELECT Id FROM BusinessLicense]);
		Test.setMock(HttpCalloutMock.class, new CERExpressionSetMock());
		Test.startTest();
		System.runAs(testUser) {
			Database.executeBatch(new CerHybridBatch(cers.keySet(), services.keySet()), 90);
		}
		Test.stopTest();
		List<SRQI_CER__c> cer = [SELECT Id, Consumer_Experience_Rating__c FROM SRQI_CER__C];
		Assert.areEqual(1, cer[0].Consumer_Experience_Rating__c, 'CER rating should be 1');
	}

	@isTest
	static void testRecalculationExemptionCall() {
		List<BusinessLicense> service = [SELECT Id, CER_Consent_Revoked__c FROM BusinessLicense LIMIT 1];
		List<SRQI_Exemption__c> cerExemption = TestDataFactory.createCERExemptionRecords(1, service);
		cerExemption[0].Exemption_Finish__c = cerExemption[0].Exemption_Start__c.addDays(100);
		insert cerExemption;
		Map<Id, SRQI_CER__C> cers = new Map<Id, SRQI_CER__C>([SELECT Id FROM SRQI_CER__c]);
		Map<Id, BusinessLicense> services = new Map<Id, BusinessLicense>([SELECT Id FROM BusinessLicense]);
		Test.setMock(HttpCalloutMock.class, new CERExpressionSetMock());
		Test.startTest();
		System.runAs(testUser) {
			Database.executeBatch(new CerHybridBatch(cers.keySet(), services.keySet()), 90);
		}
		Test.stopTest();
		List<SRQI_CER__c> cer = [SELECT Id, Consumer_Experience_Rating__c FROM SRQI_CER__C];
		Assert.areEqual(0, cer[0].Consumer_Experience_Rating__c, 'CER rating should be 0');
	}
}