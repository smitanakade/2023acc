/**
* author: Daniel Clift
* date: 1/11/2022
* description: Trigger handler for Reporting_Period__c
**/
public with sharing class ReportingPeriodTriggerHandler implements afterUpdate {
    
    public void afterUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {

        for(Reporting_Period__c rp : (List<Reporting_Period__c>) newMap.values()) {
            Reporting_Period__c oldRP = (Reporting_Period__c) oldMap.get(rp.Id);
            if((rp.CM_Calculated__c == true && oldRP.CM_Calculated__c == false) ||
               (rp.CER_Calculated__c == true && oldRP.CER_Calculated__c == false) ||
               (rp.QI_Calculated__c == true && oldRP.QI_Calculated__c == false))
            {
                RatingsCalculationHandler.checkSRHDate();
                break;
            }
        }
    }
}