public with sharing class GPMSCHSPLinkServiceHelper {

    private List<CHSP_Service_Schedule__c> scope;
    private static final String ServiceRT = Schema.SObjectType.BusinessLicense
        .getRecordTypeInfosByDeveloperName()
        .get('CHSP_Service').getRecordTypeId();
    private static final String ServiceProviderRT = Schema.SObjectType.Service_Account_Relationship__c
        .getRecordTypeInfosByDeveloperName()
        .get('Provider_to_Service').getRecordTypeId();
    
    private List<String> partyIds = new List<String>();
    private List<String> recordIds = new List<String>();
    private Set<String> setServiceCareSubTypes_all = new set<String>();
    private Map<String, Set<String>> awpCareSubTypeAndActivityStatusMap = new Map<String, Set<String>>();
    private Map<id, List<String>> mapDetailWithSubtype = new Map<id, List<String>>();
    private Map<String,BusinessLicense> serviceMap = new Map<String,BusinessLicense>();
    private Map<String,Account> accountMap = new Map<String,Account>();
    private Map<String,Service_with_CHSP_Schedule_Detail__c> serviceDetailMap = new Map<String,Service_with_CHSP_Schedule_Detail__c>();
    private Map<String,BusinessLicense> serviceToInsertMap = new Map<String,BusinessLicense>();
    private Map<String,BusinessLicense> serviceToUpdateMap = new Map<String,BusinessLicense>();
    private Map<String, Id> agedCarePlanningRegionRecords = new Map<String, Id>();
    private Map<Id, List<CHSP_Service_Activity_Work_Plan_Record__c>> scheduleIdToWorkPlanMap = new Map<Id, List<CHSP_Service_Activity_Work_Plan_Record__c>>();
    
    public GPMSCHSPLinkServiceHelper(List<CHSP_Service_Schedule__c> scope) {
        this.scope = scope;
    }
    
    public void executeGPMSCHSPLinkService() {
        getRelatedWorkPlanRecords();
        getCareSubtypeAndStatus();
        
        //No Service SubCareType
        if(setServiceCareSubTypes_all.isEmpty() || partyIds.isEmpty()){
            return;
        }
        
        getExistingServiceMap();
        getRelatedProviderAccounts();
        getServiceAndScheduleDetailRelations();
        processCHSPWorkPlans();
        
        // De-duplicate
        processServiceWithScheduleDetails();
        
        // get ACPR data
        getAgedCarePlanningRegionRecords();
        
        // Update ACPR field
        updateACPRFieldOnWorkPlan();
    }

    private void getRelatedWorkPlanRecords() {
        for (CHSP_Service_Activity_Work_Plan_Record__c workPlan : [
            SELECT Id, Name, Service_Care_Sub_Type__c, Activity_Status__c, Service_Area__c, CHSP_Service_Schedule__c 
            FROM CHSP_Service_Activity_Work_Plan_Record__c 
            WHERE Service_Care_Sub_Type__c != null AND CHSP_Service_Schedule__c IN : scope
        ]) {
            List<CHSP_Service_Activity_Work_Plan_Record__c> workPlanList = scheduleIdToWorkPlanMap.get(workPlan.CHSP_Service_Schedule__c);
            if (workPlanList == null) {
                workPlanList = new List<CHSP_Service_Activity_Work_Plan_Record__c>{ workPlan };
            } else {
                workPlanList.add(workPlan);
            }
            scheduleIdToWorkPlanMap.put(workPlan.CHSP_Service_Schedule__c, workPlanList);
        }
    }
    
    private void getCareSubtypeAndStatus() {
        for(CHSP_Service_Schedule__c chspserviceschedule : scope){
            partyIds.add(chspserviceschedule.Party_Id__c);
            recordIds.add(chspserviceschedule.Id);
            set<String> setServiceCareSubTypes = new set<String>();
            Set<String> awpStatusIsApproved = new Set<String>();
            if (scheduleIdToWorkPlanMap.get(chspserviceschedule.Id) != null) {
                for(CHSP_Service_Activity_Work_Plan_Record__c AWP : scheduleIdToWorkPlanMap.get(chspserviceschedule.Id)){
                    if(AWP.Activity_Status__c == 'Approved') {
                        awpStatusIsApproved.add(chspserviceschedule.Party_Id__c+AWP.Service_Care_Sub_Type__c);
                    }
                    setServiceCareSubTypes.add(AWP.Service_Care_Sub_Type__c);
                    setServiceCareSubTypes_all.add(AWP.Service_Care_Sub_Type__c);
                }
            }
            awpCareSubTypeAndActivityStatusMap.put(chspserviceschedule.Id, awpStatusIsApproved);
            List<String> tmp = new List<string>(setServiceCareSubTypes);
            mapDetailWithSubtype.put(chspserviceschedule.id, tmp);
        }
    }
    
    private void getExistingServiceMap() {
        for(BusinessLicense service : [SELECT Id,Party_Id__c,Service_Care_Sub_Type__c, Status__c 
                                       FROM BusinessLicense 
                                       WHERE Party_Id__c in :partyIds 
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
    
    private void getServiceAndScheduleDetailRelations() {
        for(Service_with_CHSP_Schedule_Detail__c swsc : [SELECT Id,CHSP_Schedule_Detail__c,Service__c 
                                                         FROM Service_with_CHSP_Schedule_Detail__c 
                                                         WHERE CHSP_Schedule_Detail__c in :recordIds]){
            serviceDetailMap.put(String.valueof(swsc.Service__c) + String.valueOf(swsc.CHSP_Schedule_Detail__c), swsc);
        }
    }
    
    private void processCHSPWorkPlans() {
        for(CHSP_Service_Schedule__c chspserviceschedule : scope){
			processServicesForCreateOrUpdate(chspserviceschedule);
        }
        
        try {
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
        } catch(Exception exp){
            dohagedcare.Logger.error(exp.getMessage(),exp,'GPMS').Log(); 
        }
    }
    
    private void processServicesForCreateOrUpdate(CHSP_Service_Schedule__c chspserviceschedule) {
        Set<String> awpStatusIsApproved = awpCareSubTypeAndActivityStatusMap.get(chspserviceschedule.Id);
        for(String subtype : mapDetailWithSubtype.get(chspserviceschedule.id)){
            if(serviceMap.get(chspserviceschedule.Party_Id__c+subtype) == null){
                BusinessLicense service = new BusinessLicense();
                service.RecordTypeId = ServiceRT;
                service.Care_Type__c = 'Commonwealth Home Support Programme';
                service.Party_Id__c = chspserviceschedule.Party_Id__c;
                service.Service_Name_Effective_Date__c = Date.today();
                service.Status_Date__c = Date.today();
                service.Service_Care_Sub_Type__c = subtype;
                service.Status__c = awpStatusIsApproved.contains(chspserviceschedule.Party_Id__c+subtype) ? 
                    'Operational':'Inactive';
                service.Name = getServiceName(chspserviceschedule.Party_Id__c, subtype);
                serviceToInsertMap.put(service.Party_Id__c + service.Service_Care_Sub_Type__c,service);
            } else {
                BusinessLicense serviceRecord = serviceMap.get(chspserviceschedule.Party_Id__c+subtype);
                if(awpStatusIsApproved.contains(chspserviceschedule.Party_Id__c+subtype) && serviceRecord.Status__c != 'Operational') {
                    serviceRecord.Status__c = 'Operational';
                    serviceToUpdateMap.put(chspserviceschedule.Party_Id__c+subtype, serviceRecord);
                } else if (!awpStatusIsApproved.contains(chspserviceschedule.Party_Id__c+subtype) && serviceRecord.Status__c == 'Operational') {
                    serviceRecord.Status__c = 'Inactive';
                    serviceToUpdateMap.put(chspserviceschedule.Party_Id__c+subtype, serviceRecord);
                } else {
                    continue;
                }
            }
        }
    }
    
    @TestVisible
    private String getServiceName(String partyId, String subtype) {
        String servName;
        Account acc_tmp = accountMap.get(partyId);
        if(null != acc_tmp){
            String serviceName = acc_tmp.Name + ' - ' + subtype;
            if(String.isNotBlank(serviceName)){
                servName = serviceName.left(80);
            }
        }else{
            servName = subtype;
        }
        
        return servName;
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
    
    private void processServiceWithScheduleDetails() {
        List<Service_with_CHSP_Schedule_Detail__c> listJunctionInsert = new List<Service_with_CHSP_Schedule_Detail__c>();
        for(CHSP_Service_Schedule__c chspserviceschedule : scope){
            for(String subtype : mapDetailWithSubtype.get(chspserviceschedule.id)){
                String serviceRelationship = String.valueof(serviceMap.get(chspserviceschedule.Party_Id__c+subtype).id) + chspserviceschedule.Id;
                if(serviceDetailMap.get(serviceRelationship) == null){
                    Service_with_CHSP_Schedule_Detail__c juction = new Service_with_CHSP_Schedule_Detail__c();
                    juction.CHSP_Schedule_Detail__c = chspserviceschedule.id;
                    juction.Service__c = serviceMap.get(chspserviceschedule.Party_Id__c+subtype).id;
                    listJunctionInsert.add(juction);
                }
            }
        }
        
        if(!listJunctionInsert.isEmpty()){
            insert listJunctionInsert;
        }
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
    
    private void updateACPRFieldOnWorkPlan() {
        List<CHSP_Service_Activity_Work_Plan_Record__c> workPlanRecords = new List<CHSP_Service_Activity_Work_Plan_Record__c>();
        for(CHSP_Service_Schedule__c chspserviceschedule : scope){
            if (scheduleIdToWorkPlanMap.get(chspserviceschedule.Id) != null) {
                for(CHSP_Service_Activity_Work_Plan_Record__c AWP : scheduleIdToWorkPlanMap.get(chspserviceschedule.Id)){
                    AWP.Aged_Care_Planning_Region__c = getAgedCarePlanningRegionRecordId(AWP);
                    workPlanRecords.add(AWP);
                }
            }
        }
        
        try {
			update workPlanRecords;    
        } catch(Exception ex) {
            dohagedcare.Logger.error(ex.getMessage(),ex,'GPMS').Log();
        }
    }
    
    private Id getAgedCarePlanningRegionRecordId(CHSP_Service_Activity_Work_Plan_Record__c workPlanRecord) {
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