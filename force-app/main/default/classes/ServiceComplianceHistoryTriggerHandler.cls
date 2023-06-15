public with sharing class ServiceComplianceHistoryTriggerHandler implements afterInsert, beforeUpdate {
    // Service_Compliance_History__c
    public static final String DRAFT_STATUS = 'Draft';
    public static final String PUBLISHED_STATUS = 'Published';
    public static final String LIVE_STATUS = 'Live';

    public void beforeUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {

        List<Service_Compliance_History__c> scrList = (List<Service_Compliance_History__c>) newMap.values();
        // store service Ids
        Map<Id, Id> liveSCRRecords = new Map<Id, Id>();

        for(Service_Compliance_History__c scr : scrList) {
            
            Service_Compliance_History__c scrOld = (Service_Compliance_History__c) oldMap.get(scr.Id);

            if(scr.Availability_Status__c == LIVE_STATUS && scrOld.Availability_Status__c != LIVE_STATUS) {
                scr.Rating_Type__c = 'Current Rating';
                liveSCRRecords.put(scr.Id, scr.Service__c);
            }                           
        }
        if(!liveSCRRecords.isEmpty()) {
            RatingsStatusHelper.UpdateSCRRatingType(liveSCRRecords);
        }
    }

    public void afterInsert(Map<Id, SObject> newMap) {
        ServiceComplianceHistoryTriggerService.shareServiceComplianceHistoryRecords((Map<Id, Service_Compliance_History__c>)newMap);
    }
}