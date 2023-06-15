/**
* author: Daniel Clift
* date: 06/09/2022
* description: handles status changes for StarRating History, QI, SCR, CER, CM 
**/
public with sharing class RatingsStatusHelper {

    public static Map<String, String> serviceIds = new Map<String, String>();

    public static void UpdateSubRatingRecords(Map<String, Map<Id, String>> ratingsMap) {
        
        Map<Id, String> cerIds = ratingsMap.get('CER');
        Map<Id, String> cmIds = ratingsMap.get('CM');
        Map<Id, String> qiIds = ratingsMap.get('QI');
        
        if(!cerIds.isEmpty()) {
            //serviceIds.clear();
            List<SRQI_CER__c> cerRecords = [Select Id, Availability_Status__c, Rating_Type__c, Service__c FROM SRQI_CER__c WHERE Id IN :cerIds.keySet()]; // OR (Availability_Status__c = 'Current Rating' OR Availability_Status__c = 'New Rating')];
            List<SRQI_CER__c> cerUpdate = UpdateSubRatingStatus(cerRecords, cerIds);
            update cerUpdate;
        }

        if(!cmIds.isEmpty()) {
            //serviceIds.clear();
            List<Care_Minutes_Summary__c> cmRecords = [Select Id, Availability_Status__c, Rating_Type__c, Service__c FROM Care_Minutes_Summary__c WHERE Id IN :cmIds.keySet()]; // OR (Availability_Status__c = 'Current Rating' OR Availability_Status__c = 'New Rating')];
            List<Care_Minutes_Summary__c> cmUpdate = UpdateSubRatingStatus(cmRecords, cmIds);
            //UpdateCMRatingType();
            update cmUpdate;
        }

        if(!qiIds.isEmpty()) {
            //serviceIds.clear();
            List<Quality_Indicator_Summary__c> qiRecords = [Select Id, Availability_Status__c, Rating_Type__c, Service__c FROM Quality_Indicator_Summary__c WHERE Id IN :qiIds.keySet()]; // OR (Availability_Status__c = 'Current Rating' OR Availability_Status__c = 'New Rating')];
            List<Quality_Indicator_Summary__c> qiUpdate = UpdateSubRatingStatus(qiRecords, qiIds);
            //UpdateQIRatingType();
            update qiUpdate;
        }
    }

    public static List<sObject> UpdateSubRatingStatus(List<sObject> subRatingRecords, Map<Id, String> sObjectIds) {
        for(sObject subRatingRecord : subRatingRecords) {
            if(sObjectIds.get(subRatingRecord.Id) == 'Published' && subRatingRecord.get('Availability_Status__c') != 'LIVE') {
                subRatingRecord.put('Availability_Status__c', 'Published');
            }
            else if(sObjectIds.get(subRatingRecord.Id) == 'LIVE') {
                subRatingRecord.put('Availability_Status__c', 'LIVE');
            }
            else{
                continue;
            }
            
        }
        return subRatingRecords;
    }

    public static void UpdateCERRatingType(Map<Id, Id> cerMap) {
        List<SRQI_CER__c> cerRecords = [Select Id, Availability_Status__c, Rating_Type__c, Service__c FROM SRQI_CER__c WHERE Service__c IN :cerMap.values() AND Id NOT IN :cerMap.keySet() AND Rating_Type__c = 'Current Rating'];
        if(!cerRecords.isEmpty()){
            for(SRQI_CER__c cerRecord : cerRecords) {
                cerRecord.Rating_Type__c = 'Previous Rating';
            }
            update cerRecords;
        }
    }

    public static void UpdateCMRatingType(Map<Id, Id> cmMap) {
        List<Care_Minutes_Summary__c> cmRecords = [Select Id, Availability_Status__c, Rating_Type__c, Service__c FROM Care_Minutes_Summary__c WHERE Service__c IN :cmMap.values() AND Id NOT IN :cmMap.keySet() AND Rating_Type__c = 'Current Rating'];
        if(!cmRecords.isEmpty()) {
            for(Care_Minutes_Summary__c cmRecord : cmRecords) {
                cmRecord.Rating_Type__c = 'Previous Rating';
            }
            update cmRecords;
        }
    }

    public static void UpdateQIRatingType(Map<Id, Id> qiMap) {
        List<Quality_Indicator_Summary__c> qiRecords = [Select Id, Availability_Status__c, Rating_Type__c, Service__c FROM Quality_Indicator_Summary__c WHERE Service__c IN :qiMap.values() AND Id NOT IN :qiMap.keySet() AND Rating_Type__c = 'Current Rating'];
        if(!qiRecords.isEmpty()) {
            for(Quality_Indicator_Summary__c qiRecord : qiRecords) {
                qiRecord.Rating_Type__c = 'Previous Rating';
            }
            update qiRecords;
        }
    }

    public static void UpdateSCRRatingType(Map<Id, Id> scrMap) {
        List<Service_Compliance_History__c> scrRecords = [Select Id, Availability_Status__c, Rating_Type__c, Service__c FROM Service_Compliance_History__c WHERE Service__c IN :scrMap.values() AND Id NOT IN :scrMap.keySet() AND Rating_Type__c = 'Current Rating'];
        if(!scrRecords.isEmpty()) {
            for(Service_Compliance_History__c scrRecord : scrRecords) {
                scrRecord.Rating_Type__c = 'Previous Rating';
            }
            update scrRecords;
        }
    }

    public static void UpdateSRHRatingType(Map<Id, Id> shrMap) {
        List<STAR_Rating_History__c> shrRecords = [Select Id, Status__c, Rating_Type__c, SF_Service_Id__c FROM STAR_Rating_History__c WHERE SF_Service_Id__c IN :shrMap.values() AND Id NOT IN :shrMap.keySet() AND Rating_Type__c = 'Current Rating'];
        if(!shrRecords.isEmpty()) {
            for (STAR_Rating_History__c shr : shrRecords) {
                shr.Rating_Type__c = 'Previous Rating';
            }
            update shrRecords;
        }
    }
}