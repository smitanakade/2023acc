/**
 * @description       : Trigger on Quality_Indicator_Summary__c
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 04-24-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
trigger QualityIndicatorSummaryTrigger on Quality_Indicator_Summary__c (before update, after update, before insert, after insert) {
    if( !(new TriggerBypassStrategy().isDisabled())) {
        if(Trigger.isUpdate) {
            if(Trigger.isBefore) {
                TriggerDispatcher.dispatch(new QualityIndicatorSummaryTriggerHandler(), TriggerOperation.BEFORE_UPDATE);
            }
            else if(Trigger.isAfter) {
                TriggerDispatcher.dispatch(new QualityIndicatorSummaryTriggerHandler(), TriggerOperation.AFTER_UPDATE);
            }
        }
        
        if(Trigger.isInsert) {
            if(Trigger.isBefore) {
                TriggerDispatcher.dispatch(new QualityIndicatorSummaryTriggerHandler(), TriggerOperation.BEFORE_INSERT);
            }
            if(Trigger.isAfter) {
                TriggerDispatcher.dispatch(new QualityIndicatorSummaryTriggerHandler(), TriggerOperation.AFTER_INSERT);
            }
        }
    }
}