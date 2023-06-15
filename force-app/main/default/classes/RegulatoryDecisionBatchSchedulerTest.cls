/**
 * author: Vivek J
 * date: 17/11/2022
 * description: test class for RegulatoryDecisionBatchScheduler
 **/
@isTest
private with sharing class RegulatoryDecisionBatchSchedulerTest {
    public static testMethod void testschedule() {
		User testUser = TestDataFactory.createSystemAdminUser();

		Test.StartTest();
		System.runAs(testUser) {
			RegulatoryDecisionBatchScheduler.fakeException = true;
			RegulatoryDecisionBatchScheduler sh1 = new RegulatoryDecisionBatchScheduler();
			String sch = '0 0 23 * * ?';
			String jobId = system.schedule('***Star rating check', sch, sh1);
			CronTrigger ct = [
				SELECT Id, CronExpression, TimesTriggered, NextFireTime
				FROM CronTrigger
				WHERE id = :jobId
			];
			System.assertEquals(sch, ct.CronExpression);
		}
		Test.stopTest();
	}
}