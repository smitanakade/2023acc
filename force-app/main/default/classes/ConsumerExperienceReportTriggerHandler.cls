/**
* author: Daniel Clift
* date: 09/09/2022
* description: trigger handler for SRQI_CER__c
**/
public with sharing class ConsumerExperienceReportTriggerHandler implements afterInsert, beforeUpdate {
    // SRQI_CER__c
    public static final String DRAFT_STATUS = 'Draft';
    public static final String PUBLISHED_STATUS = 'Published';
    public static final String LIVE_STATUS = 'Live';

    public void beforeUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {

        List<SRQI_CER__c> cerList = (List<SRQI_CER__c>) newMap.values();
        // store service Ids
        Map<Id, Id> liveCERRecords = new Map<Id, Id>();

        for(SRQI_CER__c cer : cerList) {
            
            SRQI_CER__c cerOld = (SRQI_CER__c) oldMap.get(cer.Id);

            if(cer.Availability_Status__c == PUBLISHED_STATUS && cerOld.Availability_Status__c != PUBLISHED_STATUS) {
                cer.Rating_Type__c = 'New Rating';
                cer.Publication_Date__c = Datetime.now();
            }
            if(cer.Availability_Status__c == LIVE_STATUS && cerOld.Availability_Status__c != LIVE_STATUS) {
                cer.Rating_Type__c = 'Current Rating';
                liveCERRecords.put(cer.Id, cer.Service__c);
            }
        }
        if(!liveCERRecords.isEmpty()) {
            RatingsStatusHelper.UpdateCERRatingType(liveCERRecords);
        }
    }

    public void afterInsert(Map<Id, SObject> newMap) {
        ConsumerExperienceReportTriggerService.shareConsumerExperienceReportRecords((Map<Id, SRQI_CER__c>)newMap);
    }
}