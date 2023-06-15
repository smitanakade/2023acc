trigger StarRatingHistoryTrigger on STAR_Rating_History__c (after insert) {
    if( !(new TriggerBypassStrategy().isDisabled())) {
        if (Trigger.isInsert) {
            if(Trigger.isAfter) {
                TriggerDispatcher.dispatch(new StarRatingTriggerHandler(), TriggerOperation.AFTER_INSERT);
            }
        }
    }
}