/**
 * @description       : QISVersionTriggerHandler
 * @author            : Sharevreet Singh
 * @group             : 
 * @last modified on  : 05-17-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class QISVersionTriggerHandler implements beforeUpdate, afterUpdate {
    final static Set<String> STATUS_LIST = new Set<String>{'Submitted', 'Late Submission', 'Updated After Due Date'};

    public void beforeUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {
        for(Quality_Indicator_Summary_Version__c qisVersion : (List<Quality_Indicator_Summary_Version__c>) newMap.values()) {
            Quality_Indicator_Summary_Version__c qisVersionOld = (Quality_Indicator_Summary_Version__c) oldMap.get(qisVersion.Id);
            if(qisVersion.Submission_Date_Time__c!=qisVersionOld.Submission_Date_Time__c && STATUS_LIST.contains(qisVersion.Status__c)){
                qisVersion.Submitted_By__c=UserInfo.getUserId();
            }
        }
    }
    
    public void afterUpdate(Map<Id, SObject> newMap, Map<Id,SObject> oldMap) {
        Set<Id> qisIdsForRating = new Set<Id>();
        List<Quality_Indicator_Summary_Version__c> qisVerList=new List<Quality_Indicator_Summary_Version__c>();

        for(Quality_Indicator_Summary_Version__c qisVersion : (List<Quality_Indicator_Summary_Version__c>) newMap.values()) {
            if(STATUS_LIST.contains(qisVersion.Status__c)) {
                qisVerList.add(qisVersion);
            }
        }

        if(!qisVerList.isEmpty()){
            QISVersionTriggerService.updateQIRelatedObjs(new Map<Id, Quality_Indicator_Summary_Version__c>(qisVerList));
        }
    }
}