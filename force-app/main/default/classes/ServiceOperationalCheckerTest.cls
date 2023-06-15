/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-28-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public with sharing class ServiceOperationalCheckerTest {
	@TestSetup
	static void makeData() {
		Test.startTest();
		Integer recordCount = 10;
		User testUser = TestDataFactory.createSystemAdminUser();

		System.runAs(testUser) {
			// Create service
			List<BusinessLicense> services = TestDataFactory.createServiceRecords(recordCount);
			Set<Id> servicesIDs = new Set<Id>();
			for (Integer i = 0; i < recordCount; i++) {
				services[i].Status__c = 'Operational';
				services[i].Care_Type__c = 'Residential';
				services[i].Status_Date__c = System.today();
				services[i].RecordTypeId = Schema.SObjectType.BusinessLicense.getRecordTypeInfosByDeveloperName()
					.get('Approved_Provider_Service')
					.getRecordTypeId();
			}
			insert services;

			// create report period type quarter
			List<Reporting_Period__c> rps = new List<Reporting_Period__c>();
			for (Integer i = 1; i < 5; i++) {
				Reporting_Period__c quarterRP = TestDataFactory.createReportingPeriod('Quarter');
				String year = String.valueOf(System.Today().year());
				
				switch on i {
					when 1 {
						quarterRP.Start_Date__c = System.today().addMonths(-6).toStartOfMonth();
						quarterRP.End_Date__c = System.today().addMonths(-3).toStartofMonth().addDays(-1); 
					}
					when 2 {
						quarterRP.Start_Date__c = System.today().addMonths(-3).toStartOfMonth();
						quarterRP.End_Date__c = System.today().addMonths(-0).toStartofMonth().addDays(-1); 
					}
					when 3 {
						quarterRP.Start_Date__c = System.today().addMonths(0).toStartOfMonth();
						quarterRP.End_Date__c = System.today().addMonths(+3).toStartofMonth().addDays(-1);
					}
					when 4 {
						quarterRP.Start_Date__c = System.today().addMonths(+3).toStartOfMonth();
						quarterRP.End_Date__c = System.today().addMonths(+6).toStartofMonth().addDays(-1);
					}
					when else {
						dohagedcare.Logger.warn('Invalid quarter').log();
					}
				}
				rps.add(quarterRP);
			}

			insert rps;
			Test.stopTest();
		}
	}

	@isTest
	public static void statusOperationalCheckOperationalLastTwoQuartersTest() {
		List<BusinessLicense> services = [
			SELECT Id, Status__c, Status_Date__c, Operational_Two_Last_Quarters__c
			FROM BusinessLicense
		];

		/*-9 indicates service has been operational for last 2 full quarters.
		 -6 indicates service has NOT been operational for last 2 full quarters*/
		for (Integer i = 0; i < services.size(); i++) {
			services[i].Status_Date__c = Math.mod(i, 2) == 0
				? services[i].Status_Date__c.addMonths(-9)
				: services[i].Status_Date__c.addMonths(-6);
			services[i].Care_Type__c = 'Home Care';
		}

		update services;

		Test.startTest();
		ServiceOperationalChecker.isOperationalForLastTwoFullQuarters(services);
		Test.stopTest();

		List<BusinessLicense> servicesUpdated = [SELECT Id, Operational_Two_Last_Quarters__c FROM BusinessLicense];

		for (Integer i = 0; i < servicesUpdated.size(); i++) {
			if (servicesUpdated[i].Operational_Two_Last_Quarters__c) {
				System.assertEquals(
					true,
					servicesUpdated[i].Operational_Two_Last_Quarters__c,
					'Flag should be checked'
				);
			} else {
				System.assertEquals(
					false,
					servicesUpdated[i].Operational_Two_Last_Quarters__c,
					'Flag should NOT be checked'
				);
			}
		}
	}

	@isTest
	public static void statusOfflineCheckOperationalLastTwoQuartersTest() {
		List<BusinessLicense> services = [
			SELECT Id, Status__c, Status_Date__c, Operational_Two_Last_Quarters__c
			FROM BusinessLicense
		];

		/*0 indicates service has been operational for last 2 full quarters.
		 -6 indicates service has NOT been operational for last 2 full quarters*/
		for (Integer i = 0; i < services.size(); i++) {
			services[i].Status_Date__c = Math.mod(i, 2) == 0
				? services[i].Status_Date__c.addMonths(0)
				: services[i].Status_Date__c.addMonths(-6);
			services[i].Status__c = 'Offline';
		}

		update services;

		Test.startTest();
		ServiceOperationalChecker.isOperationalForLastTwoFullQuarters(services);
		Test.stopTest();

		List<BusinessLicense> servicesUpdated = [SELECT Id, Operational_Two_Last_Quarters__c FROM BusinessLicense];

		for (Integer i = 0; i < servicesUpdated.size(); i++) {
			if (Math.mod(i, 2) == 0) {
				System.assertEquals(
					true,
					servicesUpdated[i].Operational_Two_Last_Quarters__c,
					'Flag should be checked'
				);
			} else {
				System.assertEquals(
					false,
					servicesUpdated[i].Operational_Two_Last_Quarters__c,
					'Flag should NOT be checked'
				);
			}
		}
	}

	@isTest
	private static void checkOperationalLastQuarterTest() {
		User adminUser = [SELECT Id FROM User WHERE Email = 'adminuser@testorg.com' AND IsActive = true LIMIT 1];
		System.runAs(adminuser) {
			delete [SELECT Id FROM Reporting_Period__c LIMIT 1]; //for test coverage
		}
		List<BusinessLicense> services = [
			SELECT Id, Status__c, Status_Date__c, Operational_Two_Last_Quarters__c
			FROM BusinessLicense LIMIT 1
		];
		services[0].Status__c = 'Operational';
        services[0].Care_Type__c = 'Home Care';
		update services;
		services[0].Status_Date__c = services[0].Status_Date__c.addMonths(-6);
		update services;
		ServiceOperationalChecker.getRPStartDate();
		Test.startTest();
		Map<Id, Boolean> servIdByOperationalMap = ServiceOperationalChecker.isOperationalForLastFullQuarter(services);
		System.assertEquals(false, servIdByOperationalMap.get(services[0].Id), 'Flag should be checked');
		services[0].Status__c = 'Offline';
		update services;
		servIdByOperationalMap = ServiceOperationalChecker.isOperationalForLastFullQuarter(services);
		System.assertEquals(false, servIdByOperationalMap.get(services[0].Id), 'Flag should not be checked');
		Test.stopTest();
	}
}