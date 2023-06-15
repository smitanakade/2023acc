trigger UserTrigger on User (after insert, after update) {
    
    if( !(new TriggerBypassStrategy().isDisabled())) {
        switch on Trigger.operationType {
            when AFTER_INSERT{
                TriggerDispatcher.dispatch(new UserTriggerHandler(), TriggerOperation.AFTER_INSERT);
            }
            when AFTER_UPDATE{
                TriggerDispatcher.dispatch(new UserTriggerHandler(), TriggerOperation.AFTER_UPDATE);
            }
        }
    }
    
}