/****************************************************************************************************
* @CreatedBy   : Peter Xiang
* @CreatedDate : 26/04/2023
* @Description : Trigger for File_Staging__c
* @Test Class  : 
*****************************************************************************************************/

trigger QualityIndicatorFileStagingTrigger on File_Staging__c (after update, after insert) {


    if(Trigger.isUpdate){
        
        if( !(new TriggerBypassStrategy().isDisabled())) {
            if(Trigger.isUpdate) {
                if(Trigger.isAfter) {
                    TriggerDispatcher.dispatch(new QIFileStagingTriggerHandler(), TriggerOperation.AFTER_UPDATE);
                }
            }
            
        }
       
    }
    if(Trigger.isInsert) {
        
        if(Trigger.isAfter) {
            TriggerDispatcher.dispatch(new QIFileStagingTriggerHandler(), TriggerOperation.AFTER_INSERT);
        }
    }
}
