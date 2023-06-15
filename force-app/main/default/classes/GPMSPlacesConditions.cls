/****************************************************************************************************
* @CreatedBy   : Accenture Developer Team
* @CreatedDate : 11-01-2023
* @Description : Update conditions status for delete event conditions
* @Test Class  : GPMSPlacesConditionsTest
*****************************************************************************************************/

public with sharing class GPMSPlacesConditions implements System.Callable, omnistudio.VlocityOpenInterface {
    
    public Object call(String action, Map<String,Object> args) {
        
        Boolean result = invokeMethod(action, (Map<String, Object>)args.get('input'), (Map<String, Object>)args.get('output'),(Map<String, Object>)args.get('options'));
        
        return (Object)result;
    }
    
    public Boolean invokeMethod(String methodName, Map<String,Object> input, Map<String,Object> output, Map<String,Object> options) {
        
        try{
            
            String conditionId = '';
            
            if(null != input.get('AllotmentConditionId')){
                conditionId = (String)input.get('AllotmentConditionId');
            } else if(null != input.get('NewAllotmentConditionId')){
                conditionId = (String)input.get('NewAllotmentConditionId');
            }else {
                return null;
            }
            
            if(String.isNotBlank(conditionId)){
                AllotmentConditions__c condition = new AllotmentConditions__c(Id = conditionId, GPMS_Condition_Status__c = 'Non-current');
            	upsert condition;
            }
			
            return true;
            
        } catch (Exception exp){
            
            dohagedcare.Logger.error(exp.getMessage(),exp,'GPMS').Log();
            return false;
        }
        
    }
}