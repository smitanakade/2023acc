/****************************************************************************************************
* @CreatedBy   : Jamil Khaki
* @CreatedDate : 09/03/2023
* @Description : trigger for Quality_Indicator_Targets__c
* @Test Class  : QualityIndicatorTargetsTrigHandlerTest
*****************************************************************************************************/

trigger QualityIndicatorTargetsTrigger on Quality_Indicator_Targets__c (before update, before insert) {

    if( !(new TriggerBypassStrategy().isDisabled())) {
        if(Trigger.isUpdate) {
            if(Trigger.isBefore) {
                TriggerDispatcher.dispatch(new QualityIndicatorTargetsTriggerHandler(), TriggerOperation.BEFORE_UPDATE);
            }
        }
        

        if(Trigger.isInsert) {
            if(Trigger.isBefore) {
                TriggerDispatcher.dispatch(new QualityIndicatorTargetsTriggerHandler(), TriggerOperation.BEFORE_INSERT);
            }
        }
    }

}