@isTest
public class GPMSPermissionSetsSchedulerTest {
	@isTest
	public static void testPermissionSetsScheduler() {
		GPMSPermissionSetsManager pm = new GPMSPermissionSetsManager(
			'GPMS_MuleSoft_Integration'
		);
		String CRON_EXP = '0 55 21 * * ?';
		Test.startTest();
		// Schedule the test job
		String jobId = System.schedule(
			'testPermissionSetsScheduler',
			CRON_EXP,
			new GPMSPermissionSetsScheduler(
				'GPMS_MuleSoft_Integration',
				new DMLMock()
			)
		);
		// Get the information from the CronTrigger API object
		CronTrigger ct = [
			SELECT Id, CronExpression, TimesTriggered, NextFireTime
			FROM CronTrigger
			WHERE id = :jobId
		];

		// Verify the expressions are the same
		System.assertEquals(CRON_EXP, ct.CronExpression);
		// Verify the job has not run
		System.assertEquals(0, ct.TimesTriggered);
		Test.stopTest();
	}
}
