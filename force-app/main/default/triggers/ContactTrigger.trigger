trigger ContactTrigger on Contact (before insert) {
    TriggerDispatcher.dispatch(new ContactTriggerHandler(), Trigger.operationType);
   
}