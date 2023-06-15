/****************************************************************************************************
* @CreatedBy   : Accenture Developer Team
* @CreatedDate : 08-May-2023
* @Description : Handler of Trigger of event__c object
* @TestClass GPMSEventHelper
*****************************************************************************************************/
public with sharing class GPMSEventHandler implements beforeUpdate{
    
    public void beforeUpdate(Map<Id, SObject> newMap,Map<Id, SObject> oldMap) {
        try {
            
            GPMSEventHelper.cloneChildForDisContinuingService(newMap, oldMap);
            
        } catch(Exception exp) {
            dohagedcare.Logger.error(exp.getMessage(),exp,'GPMS').Log(); 
        }
        
    }
    
    

}