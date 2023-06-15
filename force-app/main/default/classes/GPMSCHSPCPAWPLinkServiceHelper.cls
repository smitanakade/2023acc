public with sharing class GPMSCHSPCPAWPLinkServiceHelper {
    
    private List<CHSP_Procurement_Based_AWP_Record__c> scope;
    private static final String ServiceRT = Schema.SObjectType.BusinessLicense
        .getRecordTypeInfosByDeveloperName()
        .get('CHSP_Service').getRecordTypeId();
    private static final String ServiceProviderRT = Schema.SObjectType.Service_Account_Relationship__c
        .getRecordTypeInfosByDeveloperName()
        .get('Provider_to_Service').getRecordTypeId();
    
    private List<String> partyIds = new List<String>();
    private Set<String> setServiceCareSubTypes_all = new set<String>();
    private Map<String,BusinessLicense> serviceMap = new Map<String,BusinessLicense>();
    private Map<String,Account> accountMap = new Map<String,Account>();
    private Set<String> awpStatusIsApproved = new Set<String>();
    private Map<String,BusinessLicense> serviceToInsertMap = new Map<String,BusinessLicense>();
    private Map<String,BusinessLicense> serviceToUpdateMap = new Map<String,BusinessLicense>();
    private Map<String, Id> agedCarePlanningRegionRecords = new Map<String, Id>();
    
    public GPMSCHSPCPAWPLinkServiceHelper(List<CHSP_Procurement_Based_AWP_Record__c> scope) {
        this.scope = scope;
    }
    
    public void executeGPMSCHSPCPAWPLinkService() {
        getPartyIdsAndServiceCareSubTypes();
        
        //No Service SubCareType
        if(setServiceCareSubTypes_all.isEmpty() || partyIds.isEmpty()){
            return;
        }
        
        getExistingServiceMap();
        getRelatedProviderAccounts();
        getApprovedProcurementBasedAWPRecords();
        
        // get ACPR data
        getAgedCarePlanningRegionRecords();
        
        processCHSPWorkPlans();
    }
    
    private void getPartyIdsAndServiceCareSubTypes() {
        for(CHSP_Procurement_Based_AWP_Record__c chspserviceschedule : scope){
            partyIds.add(chspserviceschedule.Party_Id__c);
            setServiceCareSubTypes_all.add(chspserviceschedule.Service_Care_Sub_Type__c);
        }
    }
    
    private void getExistingServiceMap() {
        for(BusinessLicense service : [SELECT Id,Party_Id__c,Service_Care_Sub_Type__c, Status__c
                                          FROM BusinessLicense WHERE Party_Id__c in :partyIds 
                                          AND Service_Care_Sub_Type__c in :setServiceCareSubTypes_all]){
            serviceMap.put(service.Party_Id__c + service.Service_Care_Sub_Type__c,service);
        }
    }
    
    private void getRelatedProviderAccounts() {
        for(Account acc : [SELECT Id,Party_Id__c, Name 
                           FROM Account 
                           WHERE Party_Id__c in :partyIds]){
            accountMap.put(acc.Party_Id__c, acc);
        }
    }
    
    private void getApprovedProcurementBasedAWPRecords() {
        for(CHSP_Procurement_Based_AWP_Record__c chspserviceschedule : scope) {
            String serviceKey = chspserviceschedule.Party_Id__c+chspserviceschedule.Service_Care_Sub_Type__c;
            if(chspserviceschedule.Activity_Status__c == 'Approved') {
                awpStatusIsApproved.add(serviceKey);
            }
        }
    }
    
    private void processCHSPWorkPlans() {
        try {
            processCHSPServiceSchedule();
            
            if(!serviceToUpdateMap.values().isEmpty()) {
                update serviceToUpdateMap.values();
            }
            
            if(!serviceToInsertMap.values().isEmpty()){
                insert serviceToInsertMap.Values();
                
                List<Service_Account_Relationship__c> serviceaccountToInsert = getServiceAccountRelationships();
                if(!serviceaccountToInsert.isEmpty()){
                    insert serviceaccountToInsert;
                }
            }
            
            for(CHSP_Procurement_Based_AWP_Record__c chspserviceschedule : scope){
                chspserviceschedule.Service__c = serviceMap.get(chspserviceschedule.Party_Id__c+chspserviceschedule.Service_Care_Sub_Type__c).Id;
                chspserviceschedule.Aged_Care_Planning_Region__c = getAgedCarePlanningRegionRecordId(chspserviceschedule);
            }
            
            update scope;
        } catch (Exception ex) {
            dohagedcare.Logger.error(ex.getMessage(),ex,'GPMS').Log();
        }
    }
    
    private void processCHSPServiceSchedule() {
        for(CHSP_Procurement_Based_AWP_Record__c chspserviceschedule : scope){
            String serviceKey = chspserviceschedule.Party_Id__c+chspserviceschedule.Service_Care_Sub_Type__c;
            if(serviceMap.get(serviceKey) == null){
                BusinessLicense service = new BusinessLicense();
                service.RecordTypeId = ServiceRT;
                service.Care_Type__c = 'Commonwealth Home Support Programme';
                service.Service_Name_Effective_Date__c = Date.today();
                service.Status_Date__c = Date.today();
                service.Party_Id__c = chspserviceschedule.Party_Id__c;
                service.Service_Care_Sub_Type__c = chspserviceschedule.Service_Care_Sub_Type__c;
                service.Status__c = awpStatusIsApproved.contains(serviceKey) ? 'Operational':'Inactive';
                service.Name = getServiceName(chspserviceschedule);
                serviceToInsertMap.put(service.Party_Id__c + service.Service_Care_Sub_Type__c,service);
            } else {
                BusinessLicense serviceRecord = serviceMap.get(serviceKey);
                if(awpStatusIsApproved.contains(serviceKey) && serviceRecord.Status__c != 'Operational') {
                    serviceRecord.Status__c = 'Operational';
                    serviceToUpdateMap.put(serviceKey, serviceRecord);
                } else if(!awpStatusIsApproved.contains(serviceKey) && serviceRecord.Status__c == 'Operational') {
                    serviceRecord.Status__c = 'Inactive';
                    serviceToUpdateMap.put(serviceKey, serviceRecord);
                } else {
                    continue;
                }
            }
        }
    }
    
    private List<Service_Account_Relationship__c> getServiceAccountRelationships() {
        List<Service_Account_Relationship__c> serviceaccountToInsert = new List<Service_Account_Relationship__c>();
        for(BusinessLicense service : serviceToInsertMap.Values()){
            serviceMap.put(service.Party_Id__c + service.Service_Care_Sub_Type__c,service);
            if(accountMap.get(service.Party_Id__c) != null){
                Service_Account_Relationship__c accountservice = new Service_Account_Relationship__c();
                accountservice.Provider_Name__c = accountMap.get(service.Party_Id__c).Id;
                accountservice.RecordTypeId = ServiceProviderRT;
                accountservice.Service_Name__c = service.Id;
                accountservice.Association_Start_Date__c = Date.today();
                serviceaccountToInsert.add(accountservice);
            }
        }
        
        return serviceaccountToInsert;
    }
    
   	private void getAgedCarePlanningRegionRecords() {
        for(Aged_Care_Planning_Region__c acpr: [SELECT Id, Name, ACPR_State__c, 
                                                Geospatial_Information_Layer_Version__r.Start_Date__c,
                                                Geospatial_Information_Layer_Version__r.End_Date__c 
                                                FROM Aged_Care_Planning_Region__c
                                               	WHERE Geospatial_Information_Layer_Version__r.Start_Date__c <= TODAY
												AND (Geospatial_Information_Layer_Version__r.End_Date__c >= TODAY
                                                OR Geospatial_Information_Layer_Version__r.End_Date__c = null)]) {
			String searchKey = acpr.Name + ';' + acpr.ACPR_State__c;
			agedCarePlanningRegionRecords.put(searchKey, acpr.Id);
        }
    }
    
    private String getServiceName(CHSP_Procurement_Based_AWP_Record__c record) {
        String serviceName = record.Service_Care_Sub_Type__c;
         if(accountMap != null && accountMap.size() >0)
         {
            Account acc_tmp = accountMap.get(record.Party_ID__c);
            if(null != acc_tmp){
                serviceName = acc_tmp.Name + ' - ' + record.Service_Care_Sub_Type__c;
                if(String.isNotBlank(serviceName)){
                    serviceName = serviceName.left(80);
                }
            } 
      }
        return serviceName;
    }
    
    private Id getAgedCarePlanningRegionRecordId(CHSP_Procurement_Based_AWP_Record__c workPlanRecord) {
        String region;
        String state;
        String acprKey;
        
        // Extract region and state
        Pattern serviceAreaPattern = Pattern.compile('(.*?)\\((.*?)\\)');
        Matcher serviceAreaMatcher = serviceAreaPattern.matcher(workPlanRecord.Service_Area__c);
        if(serviceAreaMatcher.find()) { 
            region = serviceAreaMatcher.group(1).trim();
            state = serviceAreaMatcher.group(2);
        } else {
            region = workPlanRecord.Service_Area__c;
        }

        // Locate ACPR Id
        if(region == 'ACT') {
            acprKey = region + ';' + 'ACT';
        } else if(state == null) {
            for(String searchKey : agedCarePlanningRegionRecords.keySet()) {
                if(searchKey.contains(region)) {
                    acprKey = searchKey;
                    break;
                }
            }    
        } else {
            acprKey = region + ';' + state;
        }

        return agedCarePlanningRegionRecords.get(acprKey);

    }
}