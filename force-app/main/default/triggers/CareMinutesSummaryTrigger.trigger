trigger CareMinutesSummaryTrigger on Care_Minutes_Summary__c (after insert, before update) {
    if( !(new TriggerBypassStrategy().isDisabled())) {
        if(Trigger.isUpdate) {
            if(Trigger.isBefore) {
                TriggerDispatcher.dispatch(new CareMinutesSummaryTriggerHandler(), TriggerOperation.BEFORE_UPDATE);
            }
        } else if (Trigger.isInsert) {
            if(Trigger.isAfter) {
                TriggerDispatcher.dispatch(new CareMinutesSummaryTriggerHandler(), TriggerOperation.AFTER_INSERT);
            }
        }
    }
}