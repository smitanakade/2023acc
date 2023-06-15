/* 
    * Regulatory Decision Utility
    * Class provides library of functionality for Regulatory Decisions
    * Author: Matthew Wall
    * Date: 5/10/22
*/
/* MODIFICATION LOG
 * Version       Developer                   Date                Description
 *-------------------------------------------------------------------------------------------
 *  1.0     		Matthew Wall               05-10-2022          Initial Creation
 *  1.1             Matthew Wall               11-11-2022          Update to work on Service Account Relationship
 *******************************************************************************************/
public with sharing class RegulatoryDecisionUtility {
    public static final String CURRENT_STATUS = 'Current';
    public static final String NON_CURRENT_STATUS = 'Non-Current';
    public static final String DRAFT_STATUS = 'Draft';
    public static final String PUBLISH_STATUS = 'Published';

    public static Map<Id,Integer> getCurrentDecisionCount(List<RegulatoryCodeViolation> regDecList) {
        Integer count = 0;

        Map<Id,Integer> servAccIdWithCount = new Map<Id,Integer>();
        for (RegulatoryCodeViolation regDec : regDecList) {
            if (regDec.Status == CURRENT_STATUS) {
                count = 0;
                if(servAccIdWithCount.containsKey(regDec.Service_Account_Relationship__c)){
                    count = servAccIdWithCount.get(regDec.Service_Account_Relationship__c);
                }
                count++;
                servAccIdWithCount.put(regDec.Service_Account_Relationship__c, count);
            }
        }
        return servAccIdWithCount;
    }
    
    public static void setRegDecCount(Set<Id> serviceAccountIds, Map<Id,RegulatoryCodeViolation> regDecMap) { 
        List<Service_Account_Relationship__c> serviceAccountList = getServiceAccountList(serviceAccountIds);
        Map<Id,BusinessLicense> serviceMap = getServiceMap(serviceAccountList);
        List<RegulatoryCodeViolation> regDecList = regDecMap.values();
        Map<Id,Integer> servAccIdWithCount = getCurrentDecisionCount(regDecList); 

        for(Service_Account_Relationship__c sar : serviceAccountList) {
            sar.CountCurrentRegDec__c = (servAccIdWithCount.containsKey(sar.Id) ? servAccIdWithCount.get(sar.Id) : 0 );
            serviceMap.get(sar.Service_Name__c).CountCurrentRegDec__c = (servAccIdWithCount.containsKey(sar.Id) ? servAccIdWithCount.get(sar.Id) : 0 );
        }

        if (Schema.sObjectType.Service_Account_Relationship__c.isUpdateable()) {
            update serviceAccountList;
        }
        

        if (Schema.sObjectType.BusinessLicense.isUpdateable()) {
            update serviceMap.values();
        }
    }

    
    public static void updateNonCurrentCount(Set<Id> serviceAccountIds, Map<Id,RegulatoryCodeViolation> regDecMap) { 
        Integer nonCurrentCount;
        Integer archivedCount;
        List<Service_Account_Relationship__c> serviceAccountList = getServiceAccountList(serviceAccountIds);
        Map<Id,BusinessLicense> serviceMap = getServiceMap(serviceAccountList);
        Map<Id,Service_Account_Relationship__c> serviceToSarMap = new Map<Id,Service_Account_Relationship__c>();
        for (Service_Account_Relationship__c sar : serviceAccountList) {
            ServiceToSarMap.put(sar.Service_Name__c,sar);
        }

        for (Id id : serviceMap.keyset()) {
            nonCurrentCount = 0;
            archivedCount = 0;
            for (RegulatoryCodeViolation rd : regDecMap.values()) {
                if (rd.Service_Name_lookup__c == id && rd.Status == NON_CURRENT_STATUS 
                    && rd.Rating_Relevant__c == true) {  
                        nonCurrentCount++;
                }
                else if (rd.Service_Name_lookup__c == id && rd.Status == NON_CURRENT_STATUS
                        && rd.Archived_Regulatory_Decision__c == true) { 
                            archivedCount++;
                }
            }
            
            serviceToSarMap.get(id).CurrentNonCurrentRegDec__c = nonCurrentCount;
            serviceMap.get(id).NoOf_NonCurr_Rating_RegDecision__c = nonCurrentCount;
            serviceToSarMap.get(id).CountArchRegDecision__c = archivedCount;
            serviceMap.get(id).CountArchRegDecision__c = archivedCount;
        }
        
        update serviceToSarMap.values();
        update serviceMap.values();
    }
    
    public static List<Service_Account_Relationship__c> getServiceAccountList(Set<Id> serviceAccountIds) {
        return [SELECT Id, Name, CountCurrentRegDec__c, Service_Name__c, 
                CurrentNonCurrentRegDec__c 
                FROM Service_Account_Relationship__c
                WHERE Id IN: serviceAccountIds];
    }

    public static Map<Id,BusinessLicense> getServiceMap(List<Service_Account_Relationship__c> serviceAccountList) {
        Set<Id> serviceIds = new Set<Id>();
        for (Service_Account_Relationship__c sar : serviceAccountList) {
            serviceIds.add(sar.Service_Name__c);
        }
        Map<Id,BusinessLicense> serviceMap = new Map<Id,BusinessLicense>([SELECT Id, Name, CountCurrentRegDec__c
                                                                        FROM BusinessLicense
                                                                        WHERE Id IN: serviceIds]);
        return serviceMap;
    }

    public static Date convertDate(DateTime dt) {
        if (dt != null) {
            return date.newinstance(dt.year(), dt.month(), dt.day());
        }
        return null;
    }
}