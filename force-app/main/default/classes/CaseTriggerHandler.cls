/****************************************************************************************************
* @Description : Handler class for CaseTrigger
* @Test Class  : CaseTriggerHandlerTest
*****************************************************************************************************/

public with sharing class CaseTriggerHandler implements beforeUpdate, afterUpdate {
    
    public void beforeUpdate(Map<Id,Sobject> newCaseMap,Map<Id,Sobject> oldCaseMap) { 
        CaseTriggerService.validateCaseStatusChanges(newCaseMap,oldCaseMap);
    }

   public void afterUpdate(Map<Id,Sobject> newCaseMap,Map<Id,Sobject> oldCaseMap) {
        CaseTriggerService.invokeCaseAssignmentRule(
            newCaseMap,
            oldCaseMap
        );
	 }
}