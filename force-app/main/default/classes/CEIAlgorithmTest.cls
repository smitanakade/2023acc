/**
 * author: Daniel Clift
 * date: 25/08/2022
 * description: Test class for CEIAlgorithmHelper & CEIAlgorithmBatch
 **/

@isTest
public with sharing class CEIAlgorithmTest {
	@TestSetup
	public static void dataSetup() {
		Integer recordCount = 10;
		Integer ceiCount = 100;
		User testUser = TestDataFactory.createSystemAdminUser();

		Test.startTest();
		System.runAs(testUser){
			// get reporting period
			Reporting_Period__c reportingPeriod = TestDataFactory.createReportingPeriod('Year');
			Integer yearDate = System.today().Year() - 1;
			reportingPeriod.Start_Date__c = System.today().addMonths(-12);
			reportingPeriod.End_Date__c = System.today().addMonths(-9);
			insert reportingPeriod;
			// get list of service records
			List<BusinessLicense> services = TestDataFactory.createServiceRecords(recordCount);
			insert services;
			// get list of providers
			List<Account> providers = TestDataFactory.createProviderRecords(recordCount);
			insert providers;
			// get list of service accounts
			List<Service_Account_Relationship__c> serviceAccounts = TestDataFactory.createServiceAccountRecords(
				recordCount,
				services,
				providers
			);
			insert serviceAccounts;
			// get list of CER records
		/*	List<SRQI_CER__c> cers = TestDataFactory.createCERRecords(
				recordCount,
				serviceAccounts,
				providers,
				services,
				reportingPeriod
			);
			insert cers;*/
			
			List<SRQI_CER__c> cers = new List<SRQI_CER__c>();
			for(Integer i = 0; i < recordCount; i++) {
				SRQI_CER__c cer = new SRQI_CER__c();
				cer.Service_Account__c = serviceAccounts[i].Id;
				cer.Provider__c = providers[i].Id;
				cer.Reporting_Period__c = reportingPeriod.Id;

				cers.add(cer);
			}
			insert cers;

			// get list of CEI records
			List<SRQI_CEI__c> ceis = TestDataFactory.createCEIRecords(ceiCount, cers);
			insert ceis;
		}
		Test.stopTest();
	}

	@isTest
	public static void testCEIAlgorithmBatch() {
		test.startTest();
		CEIAlgorithmBatch batchJob = new CEIAlgorithmBatch();
		Id jobId = Database.executeBatch(batchJob, 200);
		test.stopTest();
		// get CER record with category ratings
		List<SRQI_CER__c> cerRecords = [
			SELECT Id, Care_Need_Score__c, Competent_Score__c, Food_Score__c, Safety_Score__c
			FROM SRQI_CER__c
			WHERE
				Care_Need_Score__c != NULL
				AND Food_Score__c != NULL
				AND Food_Score__c != NULL
				AND Safety_Score__c != NULL
		];
		// assert that score fields are not null
		System.assertEquals(10, cerRecords.size());
	}
}