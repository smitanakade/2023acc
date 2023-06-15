/****************************************************************************************************
* @CreatedBy   : Yohan Perera
* @CreatedDate : 6-12-2022
* @Description : Batch class for ceasing Provisional PAs
* @Test Class  : 
*****************************************************************************************************/
public with sharing class GPMSCeasePlacesAllotmentBatch implements Database.Batchable<sObject>,Database.Stateful {
    
    public static final String PA_STATUS_PROVISIONAL = 'Provisional';
    public static final String PA_STATUS_CEASED = 'Ceased';
    public static final String PA_STATUS_REASON = 'S15-2 Not action taken in relation to provisional allocation';
    public static final String PA_CURRENT = 'Yes';
    public static final String PA_CURRENT_NO = 'No';
    public static final String PA_CEASE = 'Cease PA';
    public static final String EVENT_STATUS_PENDING = 'Pending';
    public static final String PA_CURRENT_PENDING = 'Pending';

    public static final Id RT_EVENT_CEASE = Schema.SObjectType.Event__c.getRecordTypeInfosByDeveloperName().get('GPMS_Cease_Places').getRecordTypeId();
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'SELECT Id, Current__c, Care_Type__c, Care_Level__c, Care_Setting__c, Care_Setting_Effective_Date__c, Number_of_Places__c, First_Brought_into_Effect_Date__c, Allotment__c,'
            		+ ' Allotment__r.PA_Period_End_Date__c, Allotment__r.Service_Name__c, Allotment__r.Service_Name__r.AccountId FROM Places_Allotment__c'
            		+ ' WHERE Status_of_Places__c = :PA_STATUS_PROVISIONAL AND Current__c = :PA_CURRENT AND Allotment__r.PA_Period_End_Date__c < TODAY';
        
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<Places_Allotment__c> scope) {
        
        Map<Id, Places_Allotment__c> allotmentToPa = new Map<Id, Places_Allotment__c>();
        for (Places_Allotment__c pa : scope) {
            allotmentToPa.put(pa.Allotment__c, pa);
        }

        GPMSEventStatusCheck statusCheck = new GPMSEventStatusCheck();
        Map<Id, Places_Allotment__c> paIdToPaMap = new Map<Id, Places_Allotment__c>();
        
        Map<Id, Event__c> serviceToPendingEventsMap = new Map<Id, Event__c>();
        
        try{
            for (Places_Allotment__c pa : allotmentToPa.values()) {
                if (pa.Allotment__r.Service_Name__c != null) {
                    serviceToPendingEventsMap.put(pa.Allotment__r.Service_Name__c, null);
                }
            }
            
            List<String> statusList = statusCheck.getStatusesList(PA_CEASE);
            for (Event__c event : [SELECT Id, Service__c FROM Event__c WHERE Service__c IN :serviceToPendingEventsMap.keySet() AND Status__c IN :statusList]) {
                serviceToPendingEventsMap.put(event.Service__c, event);
            }
            
            Map<Id, Event__c> paToNewEventRecords = new Map<Id, Event__c>();
            
            for (Places_Allotment__c pa : allotmentToPa.values()) {
                //Create the Event only when there are no Pending Events related to the Allotment and one event per Allotments even thought multiple Pending PAs exist under a single Allotment
                if (serviceToPendingEventsMap.get(pa.Allotment__r.Service_Name__c) == null) {
                    Event__c ceaseStatus = new Event__c(); 
                    ceaseStatus.Status__c = EVENT_STATUS_PENDING;
                    ceaseStatus.Service__c = pa.Allotment__r.Service_Name__c; 
                    ceaseStatus.Account_From__c = pa.Allotment__r.Service_Name__r.AccountId;
                    ceaseStatus.Status_Date__c = Date.today();
                    ceaseStatus.Event_Type__c = PA_CEASE;
                    ceaseStatus.RecordTypeId= RT_EVENT_CEASE;
                    paToNewEventRecords.put(pa.Id, ceaseStatus);
                    
                    paIdToPaMap.put(pa.Id, pa);
                }
            }
            insert paToNewEventRecords.values();
            
            List<Service_Event__c> serviceEventsToInsert = new List<Service_Event__c>();
            List<Event_Allotment__c> eventAllotmentsToInsert = new List<Event_Allotment__c>();
            List<Places_Allotment__c> pasToInsert = new List<Places_Allotment__c>();
            
            for (Id paId: paToNewEventRecords.keySet()) {
                Service_Event__c se = new Service_Event__c();
                se.Service__c = paToNewEventRecords.get(paId).Service__c;
                se.Event__c = paToNewEventRecords.get(paId).Id;
                serviceEventsToInsert.add(se);
                
                Places_Allotment__c source = paIdToPaMap.get(paId);
                
                Event_Allotment__c ea = new Event_Allotment__c();
                ea.Event__c = paToNewEventRecords.get(paId).Id;
                ea.Allotment__c = source.Allotment__c;
                eventAllotmentsToInsert.add(ea);
                          
                Places_Allotment__c paPending = new Places_Allotment__c(Allotment__c = source.Allotment__c
                                                                        , Event__c = paToNewEventRecords.get(paId).Id, Current__c = PA_CURRENT_PENDING
                                                                        , Status_of_Places__c = PA_STATUS_CEASED, Parent_Packet__c = paId
                                                                        , Care_Type__c = source.Care_Type__c
                                                                        , Care_Level__c = source.Care_Level__c
                                                                        , Care_Setting__c = source.Care_Setting__c, Care_Setting_Effective_Date__c = source.Care_Setting_Effective_Date__c
                                                                        , Number_of_Places__c = source.Number_of_Places__c, First_Brought_into_Effect_Date__c = source.First_Brought_into_Effect_Date__c
                                                                        , Status_Reason__c = PA_STATUS_REASON);
                pasToInsert.add(paPending);
            }
            
            insert eventAllotmentsToInsert;
            upsert pasToInsert;
        } catch(Exception exp) {
            dohagedcare.Logger.error(exp.getMessage(),exp,'GPMS').Log(); 
        }
    }
    
    public void finish(Database.BatchableContext bc) {
        //Nothing to do here
    }
}