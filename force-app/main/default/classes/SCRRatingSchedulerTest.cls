@isTest
public class SCRRatingSchedulerTest {
	@isTest
	public static void testschedule() {
		User testUser = TestDataFactory.createSystemAdminUser();

		Test.StartTest();
		System.runAs(testUser) {
			SCRRatingScheduler sh1 = new SCRRatingScheduler();
			String sch = '0 0 23 * * ?';
			String jobId = system.schedule('SCRRatingScheduler check', sch, sh1);
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
