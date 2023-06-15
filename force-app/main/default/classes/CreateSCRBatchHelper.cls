/**
 * author: Matthew WAll
 * date: 10/11/2022
 * description: Helper Class used by CreateSCRBatch to process Regulatory Decisions
 **/
/* MODIFICATION LOG
 * Version       Developer                   Date                Description
 *-------------------------------------------------------------------------------------------
 *  1.0     		Matthew Wall               10-11-2022          Initial Creation
 *******************************************************************************************/
public with sharing class CreateSCRBatchHelper {
    static final String NEW_RATING = 'New Rating';

    public void processSCRBatch(List<Service_Account_Relationship__c> sarList) { 

        Map<Id,Service_Account_Relationship__c> serviceAccountMap = new Map<Id,Service_Account_Relationship__c>(sarList);
        Map<Id,List< RegulatoryCodeViolation>> regDecMap = getRegulatoryDecisionMap(sarList);
        List<Service_Compliance_History__c> schList = new List<Service_Compliance_History__c>(); 

        Map<Id, BusinessLicense> serviceAccountIdToServiceMap = getServiceAccountIdToServiceMap(sarList);

        // loop Service Account Relationship from RegDec
        for (Id key : regDecMap.keySet()) {
            // get counts
            Integer currentCount = 0;
            Integer nonCurrentCount = 0;
            Integer archivedCount = 0;
            for (RegulatoryCodeViolation current : regDecMap.get(key)) {
                if (current.published__c == true && current.Status == 'Current') {
                    currentCount++;
                    continue;
                }
                if (current.Status == 'Non-Current' && current.Rating_Relevant__c == true) {
                    nonCurrentCount++;
                    continue;
                }
                if (current.Status == 'Non-Current' && current.Archived_Regulatory_Decision__c == true) {
                    archivedCount++;
                    continue;
                }
            }
            
            BusinessLicense service = serviceAccountIdToServiceMap.get(key);
            service.CountCurrentRegDec__c = currentCount;
            service.NoOf_NonCurr_Rating_RegDecision__c = nonCurrentCount;
            service.CountArchRegDecision__c = archivedCount;
            Service_Account_Relationship__c sar = serviceAccountMap.get(key);
            sar.CountCurrentRegDec__c = currentCount;
            sar.CurrentNonCurrentRegDec__c = nonCurrentCount;
            sar.CountArchRegDecision__c = archivedCount;

            // create SCH
            RegulatoryCodeViolation latestRegDec = getLatestRegDec(regDecMap.get(key));
            if(latestRegDec != null && currentCount > 0 && latestRegDec.Date_Decision_Applied__c >= sar.Association_Start_Date__c) {
                Service_Compliance_History__c sch = new Service_Compliance_History__c();
                sch.Rating_Type__c = NEW_Rating;
                sch.Regulatory_Decision__c = latestRegDec.Id;
                sch.Service__c = latestRegDec.Service_Name_lookup__c;
                sch.Provider__c = latestRegDec.Service_Provider_Name_lookup__c;
                sch.Rating_Calc_Date__c = datetime.now();
                sch.Publication_Date__c=datetime.now();
                sch.Rating_Type__c = 'Current Rating';
                sch.Availability_Status__c = 'LIVE';
                sch.Service_Account__c = latestRegDec.Service_Account_Relationship__c;
                sch.Service_Compliance_Rating__c = RegulatoryDecisionEventTriggerHelper.getLeastStarRating(regDecMap.get(key));
                schList.add(sch);
            } 
        }
        insert schList;
        
        // loop SCH to create SCD
        List<Service_Compliance_Detail__c> scdList = new List<Service_Compliance_Detail__c>();
        for (Service_Compliance_History__c sch : schList) {
            for (RegulatoryCodeViolation current : regDecMap.get(sch.Service_Account__c)) {
                Service_Compliance_Detail__c scd = new Service_Compliance_Detail__c(Regulatory_Decision__c=current.Id, 
                                                                                Regulatory_Decision_Status__c=current.status, 
                                                                                Service_Compliance_History__c=sch.Id);
                scdList.add(scd);
            }
        }

        if (Schema.sObjectType.Service_Account_Relationship__c.isCreateable()) {
            insert scdList;
        }
        
        update serviceAccountMap.values();

        update serviceAccountIdToServiceMap.values();
    }

    // Map of sarId to RegDec
    private Map<Id,List<RegulatoryCodeViolation>> getRegulatoryDecisionMap(List<Service_Account_Relationship__c> sarList) { 
        Set<Id> sarIds = new Set<Id>();
        for (Service_Account_Relationship__c sar : sarList) {
            sarIds.add(sar.Id);
        }

        List<RegulatoryCodeViolation> regDecList =  [SELECT Id, Service_Name_lookup__c, published__c, Status, 
                                                    Rating_Relevant__c, Archived_Regulatory_Decision__c, 
                                                    Date_Decision_Applied__c, Service_Provider_Name_lookup__c,
                                                    Service_Account_Relationship__c, Service_Compliance_Rating__c,
                                                    Service_Compliance_Rating_Effect__c 
                                                    FROM RegulatoryCodeViolation 
                                                    WHERE Service_Account_Relationship__c IN: sarIds];

        Map<id,List< RegulatoryCodeViolation>> serviceAccountRegDecMap = new Map<id,List<RegulatoryCodeViolation>>();

        for (RegulatoryCodeViolation currentRegDec : regDecList) {
            if (!serviceAccountRegDecMap.containsKey(currentRegDec.Service_Account_Relationship__c)) {
                serviceAccountRegDecMap.put(currentRegDec.Service_Account_Relationship__c, new List<RegulatoryCodeViolation>());
            }
            serviceAccountRegDecMap.get(currentRegDec.Service_Account_Relationship__c).add(currentRegDec);
        }

        return serviceAccountRegDecMap;
    }
    
    private Map<Id,BusinessLicense> getServiceAccountIdToServiceMap(List<Service_Account_Relationship__c> sarList) {
        Map<Id,BusinessLicense> serviceAccountIdToServiceMap = new Map<Id,BusinessLicense>();
        Set<Id> serviceIds = new Set<Id>();
        for (Service_Account_Relationship__c sar : sarList) {
            serviceIds.add(sar.Service_Name__c);
        }
        Map<Id,BusinessLicense> serviceMap = new Map<Id,BusinessLicense>([Select Id, Name, Care_Type__c, CountCurrentRegDec__c, CountArchRegDecision__c, 
                                                                            NoOf_NonCurr_Rating_RegDecision__c 
                                                                            FROM BusinessLicense WHERE Id IN: serviceIds]);
        for (Service_Account_Relationship__c sar : sarList) {
            serviceAccountIdToServiceMap.put(sar.Id,serviceMap.get(sar.Service_Name__c));
        }
        return serviceAccountIdToServiceMap;
    }

    private RegulatoryCodeViolation getLatestRegDec(List<RegulatoryCodeViolation> regDecList) {
        RegulatoryCodeViolation current = null;
        for (RegulatoryCodeViolation regDec : regDecList) {
            if (regDec.Status == 'Current' && regDec.Date_Decision_Applied__c != null && current == null ) {
                current = regDec;
            }
            else if ( regDec.Status == 'Current' && regDec.Date_Decision_Applied__c != null && current != null && 
                    regDec.Date_Decision_Applied__c > current.Date_Decision_Applied__c ) {
                current = regDec;
            }
            else {
                continue;
            }
        }
        return current;
    }
}