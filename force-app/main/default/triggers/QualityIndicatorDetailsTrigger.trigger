/****************************************************************************************************
* @CreatedBy   : Daniel Clift
* @CreatedDate : 01/02/2023
* @Description : trigger for Quality_Indicator_Details__c
* @Test Class  : QualityIndicatorDetailsTrigHandlerTest
*****************************************************************************************************/

trigger QualityIndicatorDetailsTrigger on Quality_Indicator_Details__c (before update, before insert) {

    if( !(new TriggerBypassStrategy().isDisabled())) {
        if(Trigger.isUpdate) {
            if(Trigger.isBefore) {
                TriggerDispatcher.dispatch(new QualityIndicatorDetailsTriggerHandler(), TriggerOperation.BEFORE_UPDATE);
            }
        }
        
        if(Trigger.isInsert) {
            if(Trigger.isBefore) {
                TriggerDispatcher.dispatch(new QualityIndicatorDetailsTriggerHandler(), TriggerOperation.BEFORE_INSERT);
            }
        }
    }
}
