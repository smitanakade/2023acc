/****************************************************************************************************
* @Description : Handler class for TaskTrigger
* @Test Class  : TaskTriggerHandlerTest
****************************************************************************************************
*/

public with sharing class TaskTriggerHandler implements BeforeDelete {
    
    public void beforeDelete(Map<Id,Sobject> taskOldMap) { 
        for(Task t:(List<Task>)taskOldMap.values())
        	{
            	t.addError(Label.TaskDeleteError);
        	}
   		}	
	}