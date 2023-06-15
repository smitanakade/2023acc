/**
* author: Daniel Clift
* date: 09/09/2022
* description: trigger handler for Care Minites Summary
**/

public with sharing class CareMinutesSummaryTriggerHandler implements afterInsert, beforeUpdate {
    // Care_Minutes_Summary__c
    public static final String DRAFT_STATUS = 'Draft';
    public static final String PUBLISHED_STATUS = 'Published';
    public static final String LIVE_STATUS = 'Live';
    public static final String REMOVED_STATUS = 'Removed';

    public void beforeUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {
        
        List<Care_Minutes_Summary__c> cmList = (List<Care_Minutes_Summary__c>) newMap.values();
        // store service Ids
        Map<Id, Id> liveCMRecords = new Map<Id, Id>();
        
        for(Care_Minutes_Summary__c cm : cmList) {
            
            Care_Minutes_Summary__c cmOld = (Care_Minutes_Summary__c) oldMap.get(cm.Id);

            if(cm.Availability_Status__c == PUBLISHED_STATUS && cmOld.Availability_Status__c != PUBLISHED_STATUS) {
                cm.Rating_Type__c = 'New Rating';
                cm.Publication_Date__c = Datetime.now();
            }
            if(cm.Availability_Status__c == LIVE_STATUS && cmOld.Availability_Status__c != LIVE_STATUS) {
                cm.Rating_Type__c = 'Current Rating';
                liveCMRecords.put(cm.Id, cm.Service__c);
            }
        }
        if(!liveCMRecords.isEmpty()) {
            RatingsStatusHelper.UpdateCMRatingType(liveCMRecords);
        }
    }

    public void afterInsert(Map<Id, SObject> newMap) {
        CareMinuteSummaryTriggerService.shareCareMinuteSummaryRecords((Map<Id, Care_Minutes_Summary__c>)newMap);
    }
}