@IsTest
private class ReportingPeriodUtilTest {
	@TestSetup
	static void dataSetup() {
		Reporting_Period__c rPeriod = TestDataFactory.createReportingPeriod(ReportingPeriodUtil.REPORTING_PERIOD_TYPE_QUARTER);
		rPeriod.Start_Date__c = (System.today() + 12 ).addMonths(-6);
		rPeriod.End_Date__c = (System.today() + 24).addMonths(-3);
		insert rPeriod;
	}

	@IsTest
	private static void testGetPreviousQuarterReportingPeriod() {
		User srAdminUser = TestDataFactory.insertNewSysAdmin();
		System.runAs(srAdminUser) {
			Test.startTest();
			System.assert(ReportingPeriodUtil.previousQuarterReportingPeriod != null, 'Expected previousQuarterReportingPeriod to be not null');
			Test.stopTest();
		}
	}
}