@isTest
public with sharing class CreateExemptionsSchedulerTest {
	@isTest
	public static void testSchedule() {
		User testUser = TestDataFactory.createSystemAdminUser();

		Test.StartTest();
		System.runAs(testUser) {
			CreateExemptionsScheduler sh1 = new CreateExemptionsScheduler();
			String sch = '0 0 23 * * ?';
			String jobId = System.schedule('CreateExemptionsScheduler check', sch, sh1);
			CronTrigger ct = [
				SELECT Id, CronExpression, TimesTriggered, NextFireTime
				FROM CronTrigger
				WHERE id = :jobId
			];
			System.assertEquals(sch, ct.CronExpression, 'Expression must match schedule');
		}
		Test.stopTest();
	}
}
