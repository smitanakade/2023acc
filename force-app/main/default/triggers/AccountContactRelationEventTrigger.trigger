trigger AccountContactRelationEventTrigger on AccountContactRelationPE__e (after insert) {
    AccountContactRelationshipTriggerService.distributeEvents(Trigger.new);
}