trigger ServiceComplianceHistoryTrigger on Service_Compliance_History__c (after insert, before update) {
    if( !(new TriggerBypassStrategy().isDisabled())) {
        if(Trigger.isUpdate) {
            if(Trigger.isBefore) {
                TriggerDispatcher.dispatch(new ServiceComplianceHistoryTriggerHandler(), TriggerOperation.BEFORE_UPDATE);
            }
        } else if (Trigger.isInsert) {
            if(Trigger.isAfter) {
                TriggerDispatcher.dispatch(new ServiceComplianceHistoryTriggerHandler(), TriggerOperation.AFTER_INSERT);
            }
        }
    }
}