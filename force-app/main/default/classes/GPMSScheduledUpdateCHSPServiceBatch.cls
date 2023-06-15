/****************************************************************************************************
* @CreatedBy   : Lavanya Uddarraju
* @CreatedDate : 29-Aug-2022
* @Description : Handles the logic to update CHSP service status to 'Inactive' 
                 when Contract End Date lapses
* @Test Class  : GPMSScheduledUpdateCHSPServiceBatchTest
*****************************************************************************************************/
public class GPMSScheduledUpdateCHSPServiceBatch implements Database.Batchable<SObject>,Schedulable {
    private String queryString;
    private Set<Id> recIdSet;
    private Date today;
    private final String STATUS_INACTIVE = 'Inactive'; 
    
    //////* --------- CONSTRUCTORS ------------ *//////
    public GPMSScheduledUpdateCHSPServiceBatch() {
        this.today = System.today();
        this.queryString = 'Select Id, Contract_End_Date__c from CHSP_Service_Schedule__c where Contract_End_Date__c <= today';
    }
    
    ////////* -------- SCHEDULE -------- *//////////
    public void execute(SchedulableContext sc) {
       Database.executeBatch(new GPMSScheduledUpdateCHSPServiceBatch(),50);
    }
    
    public GPMSScheduledUpdateCHSPServiceBatch(Set<Id> recIdSet) {
        this.today = System.today();
        this.recIdSet = recIdSet;
        this.queryString = 'Select Id, Contract_End_Date__c from CHSP_Service_Schedule__c where Contract_End_Date__c <= today';
    }
    
    /////////* ---------- MANUAL EXECUTION ------------- *//////
    public static void executeByIds(Set<Id> recIdSet, Integer i) {
        database.executeBatch(new GPMSScheduledUpdateCHSPServiceBatch(recIdSet), i);
    }
    
    //////////* ------------- START -------------- *////////
    public Database.QueryLocator start(Database.BatchableContext bc) {
        system.debug('-------GPMSScheduledUpdateCHSPServiceBatch Started---------');
        return Database.getQueryLocator(this.queryString);
    }
    
    /////////* ------------ Execute ------------- */////////
    public void execute(Database.BatchableContext bc, List<CHSP_Service_Schedule__c> scope) {
        Set<Id> serviceIdSet =  new Set<Id>();
        Map<Id, BusinessLicense> servicesToUpdateMap = new Map<Id, BusinessLicense>();
        Set<Id> chspServSchDetailIdSet =  new Set<Id>();
        try {        
            for(CHSP_Service_Schedule__c chspSchDetail : scope) {
                chspServSchDetailIdSet.add(chspSchDetail.Id);
            }
            
            List<CHSP_Service_Schedule__c> chspSchDetailList = [Select Id,Name,
                                                               (Select Id, CHSP_Schedule_Detail__c, Service__c 
                                                               from Service_with_CHSP_Schedule_Details__r) 
                                                               from CHSP_Service_Schedule__c 
                                                               where Id IN :chspServSchDetailIdSet];
            for(CHSP_Service_Schedule__c chspSchDet : chspSchDetailList) {
                if ( chspSchDet.Service_with_CHSP_Schedule_Details__r.size() > 0 ) {
                    for(Service_with_CHSP_Schedule_Detail__c srvWithCHSPScheDet : chspSchDet.Service_with_CHSP_Schedule_Details__r) {
                        serviceIdSet.add(srvWithCHSPScheDet.Service__c);
                    }
                }
            }
            
            List<BusinessLicense> serviceList = [select Id, Status__c, (Select Id, CHSP_Schedule_Detail__c, Service__c,CHSP_Schedule_Detail__r.Contract_End_Date__c
                                                 from Service_with_CHSP_Schedule_Details__r Order By CHSP_Schedule_Detail__r.Contract_End_Date__c DESC Limit 1) 
                                                 from BusinessLicense where Id IN :serviceIdSet];
            for(BusinessLicense service : serviceList) {
                if (service.Service_with_CHSP_Schedule_Details__r.size() > 0 
                   && service.Service_with_CHSP_Schedule_Details__r[0].CHSP_Schedule_Detail__r.Contract_End_Date__c <= today) {
                    service.Status__c = STATUS_INACTIVE;
                    servicesToUpdateMap.put(service.Id, service); 
                }
            }
            
            if ( !servicesToUpdateMap.isEmpty() ) {
                update servicesToUpdateMap.values();
            }
         } catch ( Exception exp ) {
            dohagedcare.Logger.error(exp.getMessage(),exp,'GPMS').Log(); 
         }
     }
     
    /////////* ------------ FINISH ------------- */////////
    public void finish(Database.BatchableContext bc) {
       system.debug('-------GPMSScheduledUpdateCHSPServiceBatch Completed---------'); 
    }
}