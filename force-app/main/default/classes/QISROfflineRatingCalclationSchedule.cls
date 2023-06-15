public with sharing class QISROfflineRatingCalclationSchedule implements Schedulable {
	public void execute(SchedulableContext sContext) {   
            
        QISROfflineRatingCalclationBatch batch = new QISROfflineRatingCalclationBatch();
            Database.executeBatch(batch,100);     
          
    }
}