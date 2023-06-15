trigger ContactRelationEventTrigger on ContactRelationshipPE__e (after insert) {
    ContactRelationshipTriggerService.distributeEvents(Trigger.new);
}