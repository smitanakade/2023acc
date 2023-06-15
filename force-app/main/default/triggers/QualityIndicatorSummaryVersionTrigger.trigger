/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 05-17-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
trigger QualityIndicatorSummaryVersionTrigger on Quality_Indicator_Summary_Version__c (after update, before update) {
    if( !(new TriggerBypassStrategy().isDisabled())) {
        if(Trigger.isUpdate) {
            if(Trigger.isBefore) {
                TriggerDispatcher.dispatch(new QISVersionTriggerHandler(), TriggerOperation.BEFORE_UPDATE);
            }
            if(Trigger.isAfter) {
                TriggerDispatcher.dispatch(new QISVersionTriggerHandler(), TriggerOperation.AFTER_UPDATE);
            }

        }
    }
}