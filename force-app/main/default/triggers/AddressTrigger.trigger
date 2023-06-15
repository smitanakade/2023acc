trigger AddressTrigger on Address__c (before insert, before update) {
    if( !(new TriggerBypassStrategy().isDisabled())) {
        switch on Trigger.operationType {
            when BEFORE_INSERT{
                TriggerDispatcher.dispatch(new AddressTriggerHandler(), TriggerOperation.BEFORE_INSERT);
            }
            when BEFORE_UPDATE{
                TriggerDispatcher.dispatch(new AddressTriggerHandler(), TriggerOperation.BEFORE_UPDATE);
            }
        }
    }
}