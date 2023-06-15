@isTest
public with sharing class CreateExemptionsBatchTest {
	static final String SERVICE_STATUS = 'Operational';
	static final String SERVICE_CARE_TYPE = 'Residential';
	static final String SERVICE_REC_TYPE = 'Approved_Provider_Service';

	@TestSetup
	static void makeData() {
		User testUser = TestDataFactory.createSystemAdminUser();
		Test.startTest();
		System.runAs(testUser){
			Integer recordCount = 10;

			// create report period type year
			Reporting_Period__c yearRP = TestDataFactory.createReportingPeriod('Year');
			Integer yearDate = System.today().Year() - 1;
			yearRP.Start_Date__c = date.newInstance(yearDate, 7, 1);
			yearRP.End_Date__c = date.newInstance(yearDate, 12, 31);
			insert yearRP;

			// // Create service
			List<BusinessLicense> services = TestDataFactory.createServiceRecords(recordCount);
			for (Integer i = 0; i < recordCount; i++) {
				services[i].Status__c = SERVICE_STATUS;
				services[i].Care_Type__c = SERVICE_CARE_TYPE;
				services[i].RecordTypeId = Schema.SObjectType.BusinessLicense.getRecordTypeInfosByDeveloperName()
					.get(SERVICE_REC_TYPE)
					.getRecordTypeId();
			}

			insert services;
             
            // create allotment
            List<Allotment__c> allAlots = new List<Allotment__c>();
            for(Integer i = 0; i < recordCount; i++){
                Allotment__c allot = new Allotment__c();
            	allot.Service_Name__c = services[i].Id;
                allAlots.add(allot);
            }
            insert allAlots;
            
            // create Places Allotment
            List<Places_Allotment__c> placeAllot = new List<Places_Allotment__c>();
            for(Integer i = 0; i < recordCount; i++){
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
		}
		Test.stopTest();
	}

	@isTest
	public static void testCreateExemptionsBatchGoLive() {
		Map<Id, BusinessLicense> servicesMap = new Map<Id, BusinessLicense>([SELECT Id FROM BusinessLicense]);
		User testUser = TestDataFactory.createSystemAdminUser();

		// Initialise required maps in star rating util class
		StarRatingUtil.cacheServiceAccRelationship(servicesMap.keySet());
		StarRatingUtil.cacheAccredCertification(servicesMap.keySet());

		// Update custom metadata
		StarRatingExemptionCustomMetadata.goLiveSetting = true;

		Test.startTest();
		System.runAs(testUser){
			Database.executeBatch(new CreateExemptionsBatch());
		}
		Test.stopTest();

		Map<Id, BusinessLicense> updatedServices = new Map<Id, BusinessLicense>(
			[SELECT Id, CER_Exempt__c, CM_Exempt__c, QI_Exempt__c, SCR_Exempt__c FROM BusinessLicense]
		);

		for (BusinessLicense service : updatedServices.values()) {
			System.assertEquals(true, service.CER_Exempt__c, 'CER service flag should be checked');
			System.assertEquals(true, service.CM_Exempt__c, 'CM service flag should be checked');
			System.assertEquals(true, service.QI_Exempt__c, 'QI service flag should be checked');
			System.assertEquals(true, service.SCR_Exempt__c, 'SCR service flag should be checked');
		}
	}

	@isTest
	public static void testCreateExemptionsBatch() {
		Map<Id, BusinessLicense> servicesMap = new Map<Id, BusinessLicense>([SELECT Id FROM BusinessLicense]);
		User testUser = TestDataFactory.createSystemAdminUser();

		// Update status date to today
		for (BusinessLicense service : servicesMap.values()) {
			service.Status_Date__c = Date.today();
		}

		update servicesMap.values();

		// Initialise required maps in star rating util class
		StarRatingUtil.cacheServiceAccRelationship(servicesMap.keySet());
		StarRatingUtil.cacheAccredCertification(servicesMap.keySet());

		// Update custom metadata
		StarRatingExemptionCustomMetadata.goLiveSetting = false;

		Test.startTest();
		System.runAs(testUser){
			Database.executeBatch(new CreateExemptionsBatch());
		}
		Test.stopTest();

		Map<Id, BusinessLicense> updatedServices = new Map<Id, BusinessLicense>(
			[SELECT Id, CER_Exempt__c, CM_Exempt__c, QI_Exempt__c, SCR_Exempt__c FROM BusinessLicense]
		);

		for (BusinessLicense service : updatedServices.values()) {
			System.assertEquals(true, service.CER_Exempt__c, 'CER service flag should be checked');
			System.assertEquals(true, service.CM_Exempt__c, 'CM service flag should be checked');
			System.assertEquals(true, service.QI_Exempt__c, 'QI service flag should be checked');
			System.assertEquals(true, service.SCR_Exempt__c, 'SCR service flag should be checked');
		}
	}
}
