/****************************************************************************************************
* @Description : Handler class for FeedCommentTrigger
* @Test Class  : FeedCommentTriggerHandlerTest
****************************************************************************************************
*/

public with sharing class FeedCommentTriggerHandler implements BeforeDelete {
    
    public void beforeDelete(Map<Id,Sobject> fCommentOldMap) { 
        for(FeedComment fc:(List<FeedComment>)fCommentOldMap.values())
        	{
            	fc.addError(Label.FeedCommentDeleteError);
        	}
   		}	
	}