trigger FeedCommentTrigger on FeedComment (before delete) {
TriggerDispatcher.dispatch(new FeedCommentTriggerHandler(), Trigger.operationType);
    }