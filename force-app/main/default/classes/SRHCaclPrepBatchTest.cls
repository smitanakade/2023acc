/**
* author: Daniel Clift
* date: 30/09/2022
* description: Test class for;
    -SRHCalcPrepBatch
    -SRHCalcPrepHelper
    -CheckExemptions
**/
@isTest
public with sharing class SRHCaclPrepBatchTest {
	@TestSetup
	static void dataSetup() {
		Integer recordCount = 20;
		User testUser = TestDataFactory.createSystemAdminUser();

		Test.startTest();
		System.runAs(testUser) {
			// get previous quarter reporting period
			Reporting_Period__c rPeriod = TestDataFactory.createReportingPeriod('Quarter');
			rPeriod.Start_Date__c = (System.today() + 12).addMonths(-6);
			rPeriod.End_Date__c = (System.today() + 24).addMonths(-3);
			insert rPeriod;

			// get current quarter reporting period
			Date d = Date.today();
			Integer quarterStartMonth = (((Math.ceil((Decimal.valueOf(d.month()) / 12) * 4)) * 3) - 2).intValue();
			Date quarterStart = Date.newInstance(d.year(), quarterStartMonth, 1);
			Reporting_Period__c currentQuarterPeriod = TestDataFactory.createReportingPeriod('Quarter');
			rPeriod.Start_Date__c = quarterStart;
			rPeriod.End_Date__c = quarterStart.addMonths(3).addDays(-1);
			insert currentQuarterPeriod;

			// get yearly reporting period
			Reporting_Period__c rPeriodYear = TestDataFactory.createReportingPeriod('Year');
			rPeriodYear.Start_Date__c = Date.valueOf(Date.today().year() + '-01-01');
			rPeriodYear.End_Date__c = Date.valueOf(Date.today().year() + '-12-31');
			insert rPeriodYear;
			// get providers
			List<Account> providers = TestDataFactory.createProviderRecords(recordCount);
			insert providers;
			// get services
			List<BusinessLicense> services = TestDataFactory.createServiceRecords(recordCount);
			insert services;
			// get service account relationships
			List<Service_Account_Relationship__c> serviceAccountRecords = TestDataFactory.createServiceAccountRecords(
				recordCount,
				services,
				providers
			);
			insert serviceAccountRecords;
			// get Service Compliance History
			List<Service_Compliance_History__c> schRecords = TestDataFactory.createServiceComplianceHistory(19);
			for (Integer y = 0; y < schRecords.size(); y++) {
				schRecords[y].Rating_Type__c = 'Current Rating';
				schRecords[y].Service__c = services[y].Id;
			}
			insert schRecords;
			// get quality indicator summary
			List<Quality_Indicator_Summary__c> qisRecords = TestDataFactory.createQISummaryRecords(
				19,
				providers,
				rPeriod,
				services,
				serviceAccountRecords
			);
			insert qisRecords;
			// get consumer experience reports
			List<SRQI_CER__c> cerRecords = TestDataFactory.createCERRecords(
				19,
				serviceAccountRecords,
				providers,
				services,
				rPeriodYear
			);
			insert cerRecords;
			// get care minutes summary
			List<Care_Minutes_Summary__c> cmsRecords = TestDataFactory.createCareMinuteSummary(19, services);
			for (Care_Minutes_Summary__c cmsRecord : cmsRecords) {
				cmsRecord.Reporting_Period__c = rPeriod.Id;
				cmsRecord.Provider_Name__c = providers[0].Id;
				cmsRecord.Service_Account__c = serviceAccountRecords[0].Id;
			}
			insert cmsRecords;
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
			}
			insert srhRecords;
		}
		Test.stopTest();
	}

	@isTest
	public static void testsrhCalcPrepBatch() {
		Test.startTest();
		Database.executeBatch(new SRHCalcPrepBatch(), 200);
		Test.stopTest();

		List<STAR_Rating_History__c> srhList = [
			SELECT Id, Consumer_Experience_Id__c, Care_Minutes_Id__c, Quality_Indicator_Id__c, Service_Compliance_Id__c
			FROM STAR_Rating_History__c
			WHERE Consumer_Experience_Id__c != NULL
			LIMIT 19
		];

		System.assertEquals(19, srhList.size(), 'There should be 19 records');
	}

	@isTest
	private static void testAddQIDandQIT() {
		STAR_Rating_History__c srh = [SELECT SF_Service_Id__c, Reporting_Period__c FROM STAR_Rating_History__c LIMIT 1];
		Quality_Indicator_Summary__c qis = [
			SELECT Id, Service__c, Reporting_Period__c
			FROM Quality_Indicator_Summary__c
			LIMIT 1
		];
		qis.Service__c = srh.SF_Service_Id__c;
		qis.Reporting_Period__c = srh.Reporting_Period__c;
		update qis;
		Test.startTest();
		SRHCalcPrepHelper.insertQID(new List<Quality_Indicator_Summary__c>{ qis });
		insert SRHCalcPrepHelper.insertQIT(new List<Quality_Indicator_Summary__c>{ qis });
		Test.stopTest();
		List<Quality_Indicator_Targets__c> qit = [
			SELECT Id
			FROM Quality_Indicator_Targets__c
			WHERE Quality_Indicator_Summary__c = :qis.Id
			LIMIT 1
		];

		System.assert(qit.size() > 0, 'There should be 1 QIT record created');
	}
}
