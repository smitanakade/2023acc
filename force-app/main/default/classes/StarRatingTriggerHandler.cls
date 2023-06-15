/**
* author: Matthew Wall
* date: 09/09/2022
* description: handlers Star Rating trigger
**/

public with sharing class StarRatingTriggerHandler implements afterInsert {
    
    public void afterInsert(Map<Id, SObject> newMap) {
        StarRatingTriggerService.shareStartRatingHistoryRecords((Map<Id, STAR_Rating_History__c>)newMap);
    }
}