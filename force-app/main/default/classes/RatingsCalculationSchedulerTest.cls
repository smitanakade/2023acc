@isTest
public class RatingsCalculationSchedulerTest {
    @istest
    public static void ScheduleTest() {

        Test.startTest();

        RatingsCalculationScheduler testSched = new RatingsCalculationScheduler();
        String CRON_EXP = '0 0 0 3 9 ? 2023';

        
        String jobId = System.schedule('testBasicScheduledApex', CRON_EXP, testSched);

        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        
        System.assertEquals(CRON_EXP, ct.CronExpression, 'Cron Expression = ' + ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered, 'Times triggered = ' + ct.TimesTriggered);
        System.assertEquals('2023-09-03 00:00:00', String.valueOf(ct.NextFireTime), 'Next fire time = ' + String.valueOf(ct.NextFireTime));


        Test.stopTest();
    }
}