/****************************************************************************************************
* @CreatedBy   : Peter Xiang
* @CreatedDate : 14/04/2023
* @Description : Scheduler for QIVersioningBatchDelete
* @testClass   : QIVersioningBatchDeleteSchedulerTest
*****************************************************************************************************/
public with sharing class QIVersioningBatchDeleteScheduler implements Schedulable {
    
    public void execute(SchedulableContext sc) {
        
        QIVersioningBatchDelete batch = new QIVersioningBatchDelete();
        Database.executeBatch(batch);
        
    }
    
}