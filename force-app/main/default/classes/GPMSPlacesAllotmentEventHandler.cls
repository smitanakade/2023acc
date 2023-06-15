/****************************************************************************************************
* @CreatedBy   : Accenture Developer Team
* @CreatedDate : 25-Nov-2022
* @Description : Handles the logic to GPMSPlacesAllotmentEventHandler
* @Test Class  : 
*****************************************************************************************************/
public with sharing class GPMSPlacesAllotmentEventHandler implements afterInsert{
    
    public static final String OBJECT_API = 'Places_Allotment__c';
    
    public void afterInsert(Map<Id, SObject> newMap) {
        try {
            GPMSInterfaceLogHelper.insertInterfaceLog(OBJECT_API, newMap);
        } catch(Exception exp) {
            dohagedcare.Logger.error(exp.getMessage(),exp,'GPMS').Log(); 
        }
    }

}