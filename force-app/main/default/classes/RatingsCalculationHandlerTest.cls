/**
 * author: Daniel Clift
 * date: 18/08/2022
 * description: test class for RatingsCalculationHandler
 **/

@isTest
public class RatingsCalculationHandlerTest {
	private static User testUser = TestDataFactory.insertNewSysAdmin();
	static final String SERVICE_STATUS = 'Operational';
	static final String SERVICE_CARE_TYPE = 'Residential';
	static final String SERVICE_REC_TYPE = 'Approved_Provider_Service';
	@TestSetup
	public static void dataSetup() {
		Integer recordCount = 1;
		System.runAs(testUser){
			// use data factory to create  reporting period records
			List<Reporting_Period__c> rpList = new List<Reporting_Period__c>();
			// create reporting period, where type = Quarter
			Reporting_Period__c quaterRP = TestDataFactory.createReportingPeriod('Quarter');
			quaterRP.Start_Date__c = (System.today() + 12).addMonths(-6);
			quaterRP.End_Date__c = (System.today() + 24).addMonths(-3);
			quaterRP.QI_Calculated__c = true;
			quaterRP.CM_Calculated__c = true;
			rpList.add(quaterRP);

			// create reporting period, where type = Year
			Reporting_Period__c yearRP = TestDataFactory.createReportingPeriod('Year');
			Integer yearDate = System.today().Year() - 1;
			yearRP.Start_Date__c = date.newInstance(yearDate, 7, 1);
			yearRP.End_Date__c = date.newInstance(yearDate, 12, 31);
			rpList.add(yearRP);

			insert rpList;

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
				yearRP
			);
			insert cerRecords;
		}
	}

	@isTest
	public static void testCalculationDates() {
		// RatingsCalculationHandler.doChainJob = false;
        Test.setMock(HttpCalloutMock.class, new CERExpressionSetMock());
		Test.startTest();
		System.runAs(testUser){
			// run RatingsCalculationHandler logic
			RatingsCalculationHandler.executeHandler();
		}
		
        System.assertEquals(System.today(), RatingsCalculationHandler.cmCalcDate, 'CM Calc date should be today');
        System.assertEquals(System.today(), RatingsCalculationHandler.qiCalcDate, 'QI Calc date should be today');
        System.assertEquals(System.today(), RatingsCalculationHandler.cerCalcDate, 'CER Calc date should be today');
		Test.stopTest();
        List<Reporting_Period__c> rPeriods = [
			SELECT
				Id,
				CER_Calculated__c
			FROM Reporting_Period__c
			WHERE Previous_Reporting_Period__c = TRUE AND Reporting_Period_Type__c = 'Quarter'
			LIMIT 1
		];
        List<SRQI_CER__c> cerRecord = [SELECT Id, Consumer_Experience_Rating__c FROM SRQI_CER__C];
        Assert.areEqual(3.0, cerRecord[0].Consumer_Experience_Rating__c, 'CER rating should be 3.0');
        Assert.areEqual(true, rPeriods[0].CER_Calculated__c, 'CER Periodical batch should have checked cer calculated');
	}
}