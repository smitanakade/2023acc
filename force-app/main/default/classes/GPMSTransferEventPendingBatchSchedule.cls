global with sharing class GPMSTransferEventPendingBatchSchedule implements Schedulable{
    global void execute(SchedulableContext sc){
        GPMSTransferEventPendingBatch a = new GPMSTransferEventPendingBatch();
        Database.executeBatch(a);
    }
}