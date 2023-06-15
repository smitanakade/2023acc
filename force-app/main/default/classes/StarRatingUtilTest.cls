@isTest
public with sharing class StarRatingUtilTest {
	static final String SERVICE_STATUS = 'Pre-operational';
	static final String SERVICE_CARE_TYPE = 'Residential';
	static final String SERVICE_REC_TYPE = 'Approved_Provider_Service';
	static final String NEW_SERVICE = 'New Service';
	static final String TRANSFERRED_SERVICE = 'Transferred Service';
	static final String CER_FLAG_CHECKED = 'CER flag should be checked';
	static final String CM_FLAG_CHECKED = 'CM flag should be checked';
	static final String QI_FLAG_CHECKED = 'QI flag should be checked';
	static final String SCR_FLAG_CHECKED = 'SCR flag should be checked';
	static final String QUARTER = 'Quarter';
	static final String NEW_RATING = 'New Rating';
	/* This method tests the creation of exemption for new services with no SRH and no subdomains
    Expected behaviou: exemptions created with reason 'New Service', service exemption flags checked,
    SRH created, subdomains created, subdomains linked to SRH*/
	@isTest
	public static void testCreateNewSystemExemptions() {
		Integer recordCount = 10;
		User testUser = TestDataFactory.createSystemAdminUser();

		Test.startTest();
		System.runAs(testUser){
			// get reporting period
			Reporting_Period__c rPeriodYear = TestDataFactory.createReportingPeriod('Year');
			Integer yearDate = System.today().Year() - 1;
			rPeriodYear.Start_Date__c = date.newInstance(yearDate, 7, 1);
			rPeriodYear.End_Date__c = date.newInstance(yearDate, 12, 31);
			insert rPeriodYear;
			// Create service
			List<BusinessLicense> services = TestDataFactory.createServiceRecords(recordCount);
			Set<Id> servicesIDs = new Set<Id>();
			for (Integer i = 0; i < recordCount; i++) {
				services[i].Status__c = SERVICE_STATUS;
				services[i].Care_Type__c = SERVICE_CARE_TYPE;
				services[i].RecordTypeId = Schema.SObjectType.BusinessLicense.getRecordTypeInfosByDeveloperName()
					.get(SERVICE_REC_TYPE)
					.getRecordTypeId();
			}

			insert services;

			for (BusinessLicense serv : services) {
				servicesIDs.add(serv.Id);
			}

			// create providers
			List<Account> providers = TestDataFactory.createProviderRecords(recordCount);
			insert providers;

			// create sar
			List<Service_Account_Relationship__c> sar = TestDataFactory.createServiceAccountRecords(
				recordCount,
				services,
				providers
			);
			// update association start date in sar
			for (Service_Account_Relationship__c sarRec : sar) {
				sarRec.Association_Start_Date__c = System.today().addMonths(-3);
			}
			insert sar;

			// Insert Accreditation/Certification records
			List<Accreditation_Certification__c> accredCertRecords = TestDataFactory.createAccreditationCertification(
				recordCount,
				services
			);
			for (Integer i = 0; i < recordCount; i++) {
				accredCertRecords[i].Start_Date__c = System.today().addMonths(-6);
				accredCertRecords[i].End_Date__c = accredCertRecords[i].Start_Date__c.addMonths(36);
			}
			insert accredCertRecords;
			// Initialise required maps in star rating util class
			StarRatingUtil.cacheServiceAccRelationship(servicesIDs);
			StarRatingUtil.cacheAccredCertification(servicesIDs);
			StarRatingUtil.fakeException = true;

			
			List<SRQI_Exemption__c> exemptions = new List<SRQI_Exemption__c>();
			for (BusinessLicense serv : services) {
				List<SRQI_Exemption__c> servExemptions = StarRatingUtil.createSystemExemptions(serv);
				if (servExemptions.size() > 0) {
					exemptions.addAll(servExemptions);
				}
			}
			if (!exemptions.isEmpty()) {
				insert exemptions;
			}

			StarRatingUtil.updateServiceExemptionFlags(exemptions);
			StarRatingUtil.srhUpdate(exemptions);
		}
		Test.stopTest();

		List<SRQI_Exemption__c> newExemptions = [SELECT Id, Reason__c FROM SRQI_Exemption__c];
		List<BusinessLicense> servicesUpdated = [
			SELECT CER_Exempt__c, CM_Exempt__c, QI_Exempt__c, SCR_Exempt__c
			FROM BusinessLicense
		];
		List<STAR_Rating_History__c> srhCreated = [
			SELECT Id, Rating_Type__c, Consumer_Experience_Id__c, Care_Minutes_Id__c, Quality_Indicator_Id__c
			FROM STAR_Rating_History__c
		];

		for (SRQI_Exemption__c exemp : newExemptions) {
			System.assertEquals(NEW_SERVICE, exemp.Reason__c, 'Reason should be new service');
		}

		for (BusinessLicense serv : servicesUpdated) {
			System.assertEquals(true, serv.CER_Exempt__c, CER_FLAG_CHECKED);
			System.assertEquals(true, serv.CM_Exempt__c, CM_FLAG_CHECKED);
			System.assertEquals(true, serv.QI_Exempt__c, QI_FLAG_CHECKED);
			System.assertEquals(true, serv.SCR_Exempt__c, SCR_FLAG_CHECKED);
		}

		for (STAR_Rating_History__c srh : srhCreated) {
			System.assertNotEquals(srh.Consumer_Experience_Id__c, null, 'CER should not be null');
			System.assertNotEquals(srh.Quality_Indicator_Id__c, null, 'QI should not be null');
		}
	}

	/* This method tests the creation of exemption for transferred services with no SRH and no subdomains
    Expected behaviou: exemptions created with reason 'Transferred Service', service exemption flags checked,
    SRH created, subdomains created, subdomains linked to SRH*/
	@isTest
	public static void testCreateTransferredSystemExemptions() {
		Integer recordCount = 10;
		User testUser = TestDataFactory.createSystemAdminUser();

		Test.startTest();
		System.runAs(testUser){
			// get reporting period
			Reporting_Period__c rPeriodYear = TestDataFactory.createReportingPeriod('Year');
			Integer yearDate = System.today().Year() - 1;
			rPeriodYear.Start_Date__c = date.newInstance(yearDate, 7, 1);
			rPeriodYear.End_Date__c = date.newInstance(yearDate, 12, 31);
			insert rPeriodYear;
			// Create service
			List<BusinessLicense> services = TestDataFactory.createServiceRecords(recordCount);
			Set<Id> servicesIDs = new Set<Id>();
			for (Integer i = 0; i < recordCount; i++) {
				services[i].Status__c = SERVICE_STATUS;
				services[i].Care_Type__c = SERVICE_CARE_TYPE;
				services[i].RecordTypeId = Schema.SObjectType.BusinessLicense.getRecordTypeInfosByDeveloperName()
					.get(SERVICE_REC_TYPE)
					.getRecordTypeId();
			}

			insert services;
			for (BusinessLicense serv : services) {
				servicesIDs.add(serv.Id);
			}

			// create providers
			List<Account> providers = TestDataFactory.createProviderRecords(recordCount);
			insert providers;

			// create sar
			List<Service_Account_Relationship__c> sar = TestDataFactory.createServiceAccountRecords(
				recordCount,
				services,
				providers
			);
			// update association start date in sar
			for (Service_Account_Relationship__c sarRec : sar) {
				sarRec.Association_Start_Date__c = System.today().addMonths(-6);
			}
			insert sar;

			// Insert Accreditation/Certification records
			List<Accreditation_Certification__c> accredCertRecords = TestDataFactory.createAccreditationCertification(
				recordCount,
				services
			);
			for (Integer i = 0; i < recordCount; i++) {
				accredCertRecords[i].Start_Date__c = System.today().addMonths(-14);
				accredCertRecords[i].End_Date__c = accredCertRecords[i].Start_Date__c.addMonths(36);
			}
			insert accredCertRecords;

			// Initialise required maps in star rating util class
			StarRatingUtil.cacheServiceAccRelationship(servicesIDs);
			StarRatingUtil.cacheAccredCertification(servicesIDs);
			StarRatingUtil.fakeException = true;

			List<SRQI_Exemption__c> exemptions = new List<SRQI_Exemption__c>();
			for (BusinessLicense serv : services) {
				List<SRQI_Exemption__c> servExemptions = StarRatingUtil.createSystemExemptions(serv);
				if (servExemptions.size() > 0) {
					exemptions.addAll(servExemptions);
				}
			}
			if (!exemptions.isEmpty()) {
				insert exemptions;
			}

			StarRatingUtil.updateServiceExemptionFlags(exemptions);
			StarRatingUtil.srhUpdate(exemptions);
		}
		Test.stopTest();

		List<SRQI_Exemption__c> transferredExemptions = [SELECT Id, Reason__c FROM SRQI_Exemption__c];
		List<BusinessLicense> servicesUpdated = [
			SELECT CER_Exempt__c, CM_Exempt__c, QI_Exempt__c, SCR_Exempt__c
			FROM BusinessLicense
		];
		List<STAR_Rating_History__c> srhCreated = [
			SELECT Id, Rating_Type__c, Consumer_Experience_Id__c, Care_Minutes_Id__c, Quality_Indicator_Id__c
			FROM STAR_Rating_History__c
		];

		for (SRQI_Exemption__c exemp : transferredExemptions) {
			System.assertEquals(TRANSFERRED_SERVICE, exemp.Reason__c, 'Reason should be transferred service');
		}

		for (BusinessLicense serv : servicesUpdated) {
			System.assertEquals(true, serv.CER_Exempt__c, CER_FLAG_CHECKED);
			System.assertEquals(true, serv.CM_Exempt__c, CM_FLAG_CHECKED);
			System.assertEquals(true, serv.QI_Exempt__c, QI_FLAG_CHECKED);
			System.assertEquals(true, serv.SCR_Exempt__c, SCR_FLAG_CHECKED);
		}

		for (STAR_Rating_History__c srh : srhCreated) {
			System.assertNotEquals(srh.Consumer_Experience_Id__c, null, 'CER should not be null');
			System.assertNotEquals(srh.Quality_Indicator_Id__c, null, 'QI should not be null');
		}
	}

	/*This method tests the creation of exemption for transferred services with SRH and no subdomains
    Expected behaviou: exemptions created with reason 'Transferred Service', service exemption flags checked,
    SRH updated, subdomains created, subdomains linked to SRH*/
	@isTest
	public static void testUpdateSRHAndCreateSubdomains() {
		Integer recordCount = 10;
		User testUser = TestDataFactory.createSystemAdminUser();

		Test.startTest();
		System.runAs(testUser){
			// Create service
			List<BusinessLicense> services = TestDataFactory.createServiceRecords(recordCount);
			Set<Id> servicesIDs = new Set<Id>();
			for (Integer i = 0; i < recordCount; i++) {
				services[i].Status__c = SERVICE_STATUS;
				services[i].Care_Type__c = SERVICE_CARE_TYPE;
				services[i].RecordTypeId = Schema.SObjectType.BusinessLicense.getRecordTypeInfosByDeveloperName()
					.get(SERVICE_REC_TYPE)
					.getRecordTypeId();
			}
			insert services;
			for (BusinessLicense serv : services) {
				servicesIDs.add(serv.Id);
			}

			// create providers
			List<Account> providers = TestDataFactory.createProviderRecords(recordCount);
			insert providers;

			// create sar
			List<Service_Account_Relationship__c> sar = TestDataFactory.createServiceAccountRecords(
				recordCount,
				services,
				providers
			);
			// update association start date in sar
			for (Service_Account_Relationship__c sarRec : sar) {
				sarRec.Association_Start_Date__c = System.today().addMonths(-3);
			}
			insert sar;

			// Insert Accreditation/Certification records
			List<Accreditation_Certification__c> accredCertRecords = TestDataFactory.createAccreditationCertification(
				recordCount,
				services
			);
			for (Integer i = 0; i < recordCount; i++) {
				accredCertRecords[i].Start_Date__c = System.today().addMonths(-6);
				accredCertRecords[i].End_Date__c = accredCertRecords[i].Start_Date__c.addMonths(36);
			}

			insert accredCertRecords;

			// create report period type quarter
			Reporting_Period__c quarterRP = TestDataFactory.createReportingPeriod(QUARTER);
			insert quarterRP;

			// get reporting period
			Reporting_Period__c rPeriodYear = TestDataFactory.createReportingPeriod('Year');
			Integer yearDate = System.today().Year() - 1;
			rPeriodYear.Start_Date__c = date.newInstance(yearDate, 7, 1);
			rPeriodYear.End_Date__c = date.newInstance(yearDate, 12, 31);
			insert rPeriodYear;

			// create star rating history records
			List<STAR_Rating_History__c> starRatingHistory = TestDataFactory.createStarRatingHistoryRecords(
				recordCount,
				services,
				providers,
				quarterRP
			);
			for (Integer i = 0; i < recordCount; i++) {
				starRatingHistory[i].Rating_Type__c = NEW_RATING;
				starRatingHistory[i].Service_Account_Relationship__c = sar[i].Id;
				starRatingHistory[i].Consumer_Experience_Id__c = null;
				starRatingHistory[i].Care_Minutes_Id__c = null;
				starRatingHistory[i].Quality_Indicator_Id__c = null;
			}

			insert starRatingHistory;

			// Initialise required maps in star rating util class
			StarRatingUtil.cacheServiceAccRelationship(servicesIDs);
			StarRatingUtil.cacheAccredCertification(servicesIDs);
			StarRatingUtil.fakeException = true;

			
			List<SRQI_Exemption__c> exemptions = new List<SRQI_Exemption__c>();
			for (BusinessLicense serv : services) {
				List<SRQI_Exemption__c> servExemptions = StarRatingUtil.createSystemExemptions(serv);
				if (servExemptions.size() > 0) {
					exemptions.addAll(servExemptions);
				}
			}
			if (!exemptions.isEmpty()) {
				insert exemptions;
			}

			StarRatingUtil.updateServiceExemptionFlags(exemptions);
			StarRatingUtil.srhUpdate(exemptions);
		}
		Test.stopTest();

		List<STAR_Rating_History__c> srhUpdated = [
			SELECT Id, Rating_Type__c, Consumer_Experience_Id__c, Care_Minutes_Id__c, Quality_Indicator_Id__c
			FROM STAR_Rating_History__c
		];

		for (STAR_Rating_History__c srh : srhUpdated) {
			System.assertNotEquals(srh.Consumer_Experience_Id__c, null, 'CER should be linked to srh');
			System.assertNotEquals(srh.Care_Minutes_Id__c, null, 'CM should be linked to srh');
			System.assertNotEquals(srh.Quality_Indicator_Id__c, null, 'QI should be linked to srh');
			System.assertEquals('Current Rating', srh.Rating_Type__c, 'Rating Type should be current rating');
		}
	}

	/*This method tests the creation of exemption for transferred services with SRH and subdomains
    Expected behaviou: exemptions created with reason 'Transferred Service', service exemption flags checked,
    SRH updated, subdomains updated*/
	@isTest
	public static void testUpdateSRHAndUpdateSubdomains() {
		Integer recordCount = 10;
		User testUser = TestDataFactory.createSystemAdminUser();

		Test.startTest();
		System.runAs(testUser){
			// Create service
			List<BusinessLicense> services = TestDataFactory.createServiceRecords(recordCount);
			Set<Id> servicesIDs = new Set<Id>();
			for (Integer i = 0; i < recordCount; i++) {
				services[i].Status__c = SERVICE_STATUS;
				services[i].Care_Type__c = SERVICE_CARE_TYPE;
				services[i].RecordTypeId = Schema.SObjectType.BusinessLicense.getRecordTypeInfosByDeveloperName()
					.get(SERVICE_REC_TYPE)
					.getRecordTypeId();
			}
			insert services;
			for (BusinessLicense serv : services) {
				servicesIDs.add(serv.Id);
			}

			// create providers
			List<Account> providers = TestDataFactory.createProviderRecords(recordCount);
			insert providers;

			// create sar
			List<Service_Account_Relationship__c> sar = TestDataFactory.createServiceAccountRecords(
				recordCount,
				services,
				providers
			);
			// update association start date in sar
			for (Service_Account_Relationship__c sarRec : sar) {
				sarRec.Association_Start_Date__c = System.today().addMonths(-3);
			}
			insert sar;

			// Insert Accreditation/Certification records
			List<Accreditation_Certification__c> accredCertRecords = TestDataFactory.createAccreditationCertification(
				recordCount,
				services
			);
			for (Integer i = 0; i < recordCount; i++) {
				accredCertRecords[i].Start_Date__c = System.today().addMonths(-6);
				accredCertRecords[i].End_Date__c = accredCertRecords[i].Start_Date__c.addMonths(36);
			}

			insert accredCertRecords;

			// create report period type quarter
			Reporting_Period__c quarterRP = TestDataFactory.createReportingPeriod(QUARTER);
			insert quarterRP;

			// create CER records
			List<SRQI_CER__c> cerRecords = TestDataFactory.createCERRecords(
				recordCount,
				sar,
				providers,
				services,
				quarterRP
			);
			// update cer record and link service to it
			for (Integer i = 0; i < recordCount; i++) {
				cerRecords[i].Service__c = services[i].Id;
				cerRecords[i].Rating_Type__c = NEW_RATING;
				cerRecords[i].Under_Review__c = false;
				cerRecords[i].Consumer_Experience_Rating__c = 5;
			}
			insert cerRecords;
			// create CM records
			List<Care_Minutes_Summary__c> cmRecords = TestDataFactory.createCareMinuteSummary(recordCount, services);
			for (Care_Minutes_Summary__c cmRec : cmRecords) {
				cmRec.Rating_Type__c = NEW_RATING;
				cmRec.Under_Review__c = false;
				cmRec.Provider_Name__c = providers[0].Id;
				cmRec.Service_Account__c = sar[0].Id;
				cmRec.Care_Minutes_Rating__c = 5;
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
				qiRec.Quality_Indicator_Rating__c = 5;
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
				starRatingHistory[i].Rating_Type__c = NEW_RATING;
				starRatingHistory[i].Service_Account_Relationship__c = sar[i].Id;
				starRatingHistory[i].Consumer_Experience_Id__c = cerRecords[i].Id;
				starRatingHistory[i].Care_Minutes_Id__c = cmRecords[i].Id;
				starRatingHistory[i].Quality_Indicator_Id__c = qiRecords[i].Id;
			}

			insert starRatingHistory;

			// Initialise required maps in star rating util class
			StarRatingUtil.cacheServiceAccRelationship(servicesIDs);
			StarRatingUtil.cacheAccredCertification(servicesIDs);
			StarRatingUtil.fakeException = true;

			
			List<SRQI_Exemption__c> exemptions = new List<SRQI_Exemption__c>();
			for (BusinessLicense serv : services) {
				List<SRQI_Exemption__c> servExemptions = StarRatingUtil.createSystemExemptions(serv);
				if (servExemptions.size() > 0) {
					exemptions.addAll(servExemptions);
				}
			}
			if (!exemptions.isEmpty()) {
				insert exemptions;
			}

			StarRatingUtil.updateServiceExemptionFlags(exemptions);
			StarRatingUtil.srhUpdate(exemptions);
		}
		Test.stopTest();

		List<SRQI_CER__c> cerUpdated = [SELECT Id, Consumer_Experience_Rating__c FROM SRQI_CER__c];
		List<Care_Minutes_Summary__c> cmUpdated = [SELECT Id, Care_Minutes_Rating__c FROM Care_Minutes_Summary__c];
		List<Quality_Indicator_Summary__c> qiUpdated = [
			SELECT Id, Quality_Indicator_Rating__c
			FROM Quality_Indicator_Summary__c
		];

		for (SRQI_CER__c cerRec : cerUpdated) {
			System.assertEquals(null, cerRec.Consumer_Experience_Rating__c, 'CER rating should be null');
		}

		for (Care_Minutes_Summary__c cmRec : cmUpdated) {
			System.assertEquals(null, cmRec.Care_Minutes_Rating__c, 'CM rating should be null');
		}

		for (Quality_Indicator_Summary__c qiRec : qiUpdated) {
			System.assertEquals(null, qiRec.Quality_Indicator_Rating__c, 'QI rating should be null');
		}
	}

	/* This method tests the creation of exemption for new services which revoked cer consent with SRH and subdomains
    Expected behaviour: exemptions created with reason 'New Service' for all subdomains but cer, service exemption flags checked but cer,
    SRH updated, subdomains updated*/
	@isTest
	public static void testUpdateSRHAndUpdateSubdomainsCERRevoked() {
		Integer recordCount = 10;
		User testUser = TestDataFactory.createSystemAdminUser();

		Test.startTest();
		System.runAs(testUser){
			// Create service
			List<BusinessLicense> services = TestDataFactory.createServiceRecords(recordCount);
			Set<Id> servicesIDs = new Set<Id>();
			for (Integer i = 0; i < recordCount; i++) {
				services[i].Status__c = SERVICE_STATUS;
				services[i].Care_Type__c = SERVICE_CARE_TYPE;
				services[i].RecordTypeId = Schema.SObjectType.BusinessLicense.getRecordTypeInfosByDeveloperName()
					.get(SERVICE_REC_TYPE)
					.getRecordTypeId();
				services[i].CER_Consent_Revoked__c = true;
			}

			insert services;

			for (BusinessLicense serv : services) {
				servicesIDs.add(serv.Id);
			}

			// create providers
			List<Account> providers = TestDataFactory.createProviderRecords(recordCount);
			insert providers;

			// create sar
			List<Service_Account_Relationship__c> sar = TestDataFactory.createServiceAccountRecords(
				recordCount,
				services,
				providers
			);
			// update association start date in sar
			for (Service_Account_Relationship__c sarRec : sar) {
				sarRec.Association_Start_Date__c = System.today().addMonths(-3);
			}
			insert sar;

			// Insert Accreditation/Certification records
			List<Accreditation_Certification__c> accredCertRecords = TestDataFactory.createAccreditationCertification(
				recordCount,
				services
			);
			for (Integer i = 0; i < recordCount; i++) {
				accredCertRecords[i].Start_Date__c = System.today().addMonths(-6);
				accredCertRecords[i].End_Date__c = accredCertRecords[i].Start_Date__c.addMonths(36);
			}

			insert accredCertRecords;
			// create previous report period
			Reporting_Period__c yearRP = TestDataFactory.createReportingPeriod('Year');
			yearRP.Start_Date__c = System.today().addMonths(-12);
			yearRP.End_Date__c = yearRP.Start_Date__c.addMonths(11);
			insert yearRP;

			// create report period type quarter
			Reporting_Period__c quarterRP = TestDataFactory.createReportingPeriod(QUARTER);
			insert quarterRP;

			// create CER records
			List<SRQI_CER__c> cerRecords = TestDataFactory.createCERRecords(recordCount, sar, providers, services, yearRP);
			// update cer record and link service to it
			for (Integer i = 0; i < recordCount; i++) {
				cerRecords[i].Service__c = services[i].Id;
				cerRecords[i].Rating_Type__c = NEW_RATING;
				cerRecords[i].Under_Review__c = false;
			}
			insert cerRecords;
			// create CM records
			List<Care_Minutes_Summary__c> cmRecords = TestDataFactory.createCareMinuteSummary(recordCount, services);
			for (Care_Minutes_Summary__c cmRec : cmRecords) {
				cmRec.Rating_Type__c = NEW_RATING;
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
				starRatingHistory[i].Rating_Type__c = NEW_RATING;
				starRatingHistory[i].Service_Account_Relationship__c = sar[i].Id;
				starRatingHistory[i].Consumer_Experience_Id__c = cerRecords[i].Id;
				starRatingHistory[i].Care_Minutes_Id__c = cmRecords[i].Id;
				starRatingHistory[i].Quality_Indicator_Id__c = qiRecords[i].Id;
			}

			insert starRatingHistory;

			// Initialise required maps in star rating util class
			StarRatingUtil.cacheServiceAccRelationship(servicesIDs);
			StarRatingUtil.cacheAccredCertification(servicesIDs);
			StarRatingUtil.cacheCERData(servicesIDs);
			StarRatingUtil.fakeException = true;

			
			List<SRQI_Exemption__c> exemptions = new List<SRQI_Exemption__c>();
			for (BusinessLicense serv : services) {
				List<SRQI_Exemption__c> servExemptions = StarRatingUtil.createSystemExemptions(serv);
				if (servExemptions.size() > 0) {
					exemptions.addAll(servExemptions);
				}
			}
			if (!exemptions.isEmpty()) {
				insert exemptions;
			}

			StarRatingUtil.updateServiceExemptionFlags(exemptions);
			StarRatingUtil.srhUpdate(exemptions);
		}
		Test.stopTest();

		List<SRQI_Exemption__c> transferredExemptions = [SELECT Id, Reason__c FROM SRQI_Exemption__c];
		List<BusinessLicense> servicesUpdated = [
			SELECT CER_Exempt__c, CM_Exempt__c, QI_Exempt__c, SCR_Exempt__c
			FROM BusinessLicense
		];

		for (SRQI_Exemption__c exemp : transferredExemptions) {
			System.assertEquals(NEW_SERVICE, exemp.Reason__c, 'Reason should be new service');
		}

		for (BusinessLicense serv : servicesUpdated) {
			System.assertEquals(false, serv.CER_Exempt__c, 'CER flag should NOT be checked');
			System.assertEquals(true, serv.CM_Exempt__c, CM_FLAG_CHECKED);
			System.assertEquals(true, serv.QI_Exempt__c, QI_FLAG_CHECKED);
			System.assertEquals(true, serv.SCR_Exempt__c, SCR_FLAG_CHECKED);
		}
	}
}