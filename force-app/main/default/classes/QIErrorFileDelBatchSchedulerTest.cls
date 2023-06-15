/**
* author: Sharevreet Singh
* date: 06/05/2023
* description: Test class for QIErrorFileDelBatchScheduler
**/
@IsTest
public with sharing class QIErrorFileDelBatchSchedulerTest {
    @TestSetup
    public static void dataSetup() {
        QIErrorFileDelBatchTest.dataSetup();
    }

    @isTest
    static void runSchTest(){
        Test.startTest();
        QIErrorFileDelBatchScheduler testsche = new QIErrorFileDelBatchScheduler();
        String sch = '20 30 8 10 2 ?';
        String jobid = System.schedule('Sechdule QIErrorFileDelBatch', sch, testsche );
        CronTrigger ct = [Select id , CronExpression from CronTrigger where id = :jobId];
        System.assertEquals(sch,ct.CronExpression, 'batch not scheduled');
        Test.stopTest();
    }
}