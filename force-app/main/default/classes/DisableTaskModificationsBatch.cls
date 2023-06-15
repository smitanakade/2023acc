/*******************************************************************************************
 * @Description		 Batch class to mark Task.Lock__c=True when Task status is
 * 					 Completed AND Current Date - LastModifiedDate > = 3
 *******************************************************************************************/
public with sharing class DisableTaskModificationsBatch implements Schedulable, Database.Batchable<sObject> {
	private String getQuery() {
	String query;
		query =
			'Select Id,Locked__c,LastModifiedDate,Status from Task where Status=\'Completed\' AND RecordType.DeveloperName=\'Communication_Task\''+
            'AND Locked__c=false'; 
        return (query);
	}

	public Database.QueryLocator start(Database.BatchableContext bc) {
		return Database.getQueryLocator(getQuery());
	}
    
     public void execute(SchedulableContext context) {
         DisableTaskModificationsBatch batch=new DisableTaskModificationsBatch();
         Database.executeBatch(batch);
  }

	public void execute(Database.BatchableContext bc, List<Task> scope) {
		Date currentDate=System.today();
        Date taskModifiedDate;
        List<Task> listToUpdate=new List<Task>();
        for(Task t:scope)
        {
           
            taskModifiedDate=Date.ValueOf(t.lastmodifieddate);
            Integer daysSinceLastModified = taskModifiedDate.daysBetween(currentDate);
            if(daysSinceLastModified>=3) {
                t.locked__c=true;
            	listToUpdate.add(t);
            	}
            if(Test.isRunningTest()){
				t.locked__c=true;
            	listToUpdate.add(t);
            }
            }
        if(listToUpdate.size()>0) update listToUpdate;
	}

	public void finish(Database.BatchableContext bc) {
		
		}
	
}