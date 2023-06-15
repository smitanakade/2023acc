/****************************************************************************************************
* @CreatedBy   : Yohan Perera
* @CreatedDate : 7-12-2022
* @Description : Scheduler for GPMSCeasePlacesAllotmentBatch
* @Test Class  : 
*****************************************************************************************************/
public with sharing class GPMSCeasePlacesAllotmentBatchScheduler implements Schedulable {
    
    public void execute(SchedulableContext sc) {
        try{
            GPMSCeasePlacesAllotmentBatch batch = new GPMSCeasePlacesAllotmentBatch();
            Database.executeBatch(batch);
        } catch(Exception exp) {
            dohagedcare.Logger.error(exp.getMessage(),exp,'GPMS').Log(); 
        }
    }
    
}