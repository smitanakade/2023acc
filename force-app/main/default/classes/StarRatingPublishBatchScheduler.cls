public with sharing class StarRatingPublishBatchScheduler implements Schedulable{
    public void execute(SchedulableContext sContext) {    
        Database.executeBatch(new StarRatingPublishBatch() ,100);
    }
}