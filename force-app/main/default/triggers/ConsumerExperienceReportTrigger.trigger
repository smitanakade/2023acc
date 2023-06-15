trigger ConsumerExperienceReportTrigger on SRQI_CER__c (after insert, before update) {
    if( !(new TriggerBypassStrategy().isDisabled())) {
        if(Trigger.isUpdate) {
            if(Trigger.isBefore) {
                TriggerDispatcher.dispatch(new ConsumerExperienceReportTriggerHandler(), TriggerOperation.BEFORE_UPDATE);
            }
        }

        if(Trigger.isInsert) {
            if(Trigger.isAfter) {
                TriggerDispatcher.dispatch(new ConsumerExperienceReportTriggerHandler(), TriggerOperation.AFTER_INSERT);
            }
        }
    }
}