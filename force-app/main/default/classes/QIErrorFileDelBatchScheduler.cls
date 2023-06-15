/**
* author: Sharevreet Singh
* date: 08/05/2023
* description: Scheduler class for Batch job - QIErrorFileDelBatch
**/
public with sharing class QIErrorFileDelBatchScheduler implements Schedulable{
    public void execute(SchedulableContext sContext) {    
        Database.executeBatch(new QIErrorFileDelBatch() ,100);
    }
}