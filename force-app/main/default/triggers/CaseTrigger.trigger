trigger CaseTrigger on Case (before update, after update) {
    TriggerDispatcher.dispatch(new CaseTriggerHandler(), Trigger.operationType);  
}