/****************************************************************************************************
* @CreatedBy   : Accenture Developer Team
* @CreatedDate : 08-May-2023
* @Description : Handles the logic to service combine event is accepet/cancel/reject
* @TestClass GPMSEventHelper
*****************************************************************************************************/
public with sharing class GPMSEventHelper {
    
    public static void cloneChildForDisContinuingService(Map<Id, SObject> newMap, Map<Id, SObject> oldMap){
        
        Set<Id> eventIds = new Set<Id>();
        Map<Id,Event__c> servMap = new Map<Id,Event__c>();
        Map<Id,Event__c> disContServApprovedMap = new Map<Id,Event__c>();
        Map<Id,Id> serviceAddressMap = new Map<Id,Id>();
        Set<Id> approvedEventIds = new Set<Id>();
        
        Map<Id, Event__c> newEventMap = (Map<Id, Event__c>)newMap;
        Map<Id, Event__c> oldEventMap = (Map<Id, Event__c>)oldMap;
        
        for(String eventId : newEventMap.keySet()){
            if( newEventMap.get(eventId).Activated__c != 'N/A' 
               && !newEventMap.get(eventId).Batch_Event_Completed__c 
               && newEventMap.get(eventId).Event_Type__c == 'Combine' 
               && (newEventMap.get(eventId).Service__r.Service_Name_Effective_Date__c != System.today() || newEventMap.get(eventId).NewServiceName__c == '')){
                    eventIds.add(eventId);
               }
        }
        
        if(eventIds.IsEmpty()){
            return;
        }
        
        List<Service_Event__c> serviceEventList = [SELECT Service__c,Service_Type__c,Event__r.Service__r.Physical_Address_Location__c, 
                                                   Event__r.Activated__c, Event__r.NewServiceName__c, Event__r.Service__c 
                                                   FROM Service_Event__c 
                                                   WHERE Event__c in :eventIds];
        
        if(serviceEventList.IsEmpty()){
            return;
        }
        
        for(Service_Event__c se : serviceEventList){
            if(se.Service_Type__c == 'Discontinuing Service' && newEventMap.get(se.Event__c).Activated__c == 'Yes'){
                disContServApprovedMap.put(se.Service__c, newEventMap.get(se.Event__c));
                serviceAddressMap.put(se.Event__r.Service__c,se.Event__r.Service__r.Physical_Address_Location__c);
                approvedEventIds.add(se.Event__c);
            }
            servMap.put(se.Service__c, newEventMap.get(se.Event__c));
            
        }
        
        updateService(servMap);
        

    }
    
    public static void updateService(Map<Id,Event__c> servMap){
        
        List<BusinessLicense> serviceList = [SELECT Id FROM BusinessLicense WHERE Id in :servMap.keyset()];
        
        for(BusinessLicense service :  serviceList){
            service.GPMS_CombineLock__c = false;
            if(servMap.get(service.Id).Activated__c == 'Yes'){
                service.Combined_Service__c = TRUE;
                if(servMap.get(service.Id).Service__c == Service.Id && String.isNotBlank(servMap.get(service.Id).NewServiceName__c)){
                    service.Name = servMap.get(service.Id).NewServiceName__c;
                }else if (servMap.get(service.Id).Service__c != Service.Id && servMap.get(service.Id).Activated__c == 'Yes'){
                    service.Combined_To__c = servMap.get(service.Id).Service__c;
                    service.Status__c = 'Closed-Combined';
                }
            }
            
        }
        
        update serviceList;
        
    }
    
}