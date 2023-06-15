@isTest
public class QISROfflineRatingCalclationScheduleTest {
   @isTest
    static void testBehavior(){
        try{
            Test.startTest();
            String jobId = System.schedule('testScheduledApex', '0 0 9 * * ?', new QISROfflineRatingCalclationSchedule());
            Test.stopTest();

            // Get the information from the CronTrigger API object
            List<CronTrigger> ctrigger = [
                    SELECT Id, CronExpression, TimesTriggered, NextFireTime
                    FROM CronTrigger WHERE id = :jobId];

            System.assertNotEquals(0, ctrigger.size());
        }catch(Exception exp){
            dohagedcare.Logger.error(exp.getMessage(),exp,'QISROfflineRatingCalclationSchedule').Log();             
            throw exp;
        }
    }
}