/**
* @CreatedBy   : Voleak Vong
* @CreatedDate : 18-04-2022
* @Description : Test class for GPMSTransferEventPendingBatchSchedule
* @Test Class  : GPMSTransferEventPendingBatchSchedule
**/

@isTest
Private class GPMSTransferEventPendingScheduleTest {
    private static User currentUser = TestDataFactory.createGPMSTestUser();
    
    @isTest
    static void testTransferEventPending() {
        System.runAs(currentUser){
            Test.startTest();
            String jobId = System.schedule('GPMSTransferEventPendingBatchSchedule1' + Datetime.now(), '0 0 0 18 4 ? 2050', new GPMSTransferEventPendingBatchSchedule());
            
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId];
            System.assertEquals(0, ct.TimesTriggered);
            
            Test.stopTest();
        }
   
    }
}