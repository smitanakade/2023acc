trigger TaskTrigger on Task (before delete) { 
TriggerDispatcher.dispatch(new TaskTriggerHandler(), Trigger.operationType);
}