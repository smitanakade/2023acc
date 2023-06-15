/****************************************************************************************************
* @CreatedBy   : Accenture Developer Team
* @CreatedDate : 18-Sep-2022
* @Description : Handles the logic to link service with service schedule
* @Test Class  : GPMSCHSPLinkServiceScheduleTest
*****************************************************************************************************/
public with sharing class GPMSCHSPLinkServiceBatch implements Database.Batchable<sObject>{
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        
        String query = 'SELECT Id,Party_Id__c,Service_Care_Sub_Type__c '+
            +'FROM CHSP_Service_Schedule__c '
            +'WHERE Organisation_Name__c != null AND Party_Id__c != null';
        return Database.getQueryLocator(query);
        
    }
    
    public void execute(Database.BatchableContext BC, List<CHSP_Service_Schedule__c> scope){
        GPMSCHSPLinkServiceHelper chspLinkServiceHelper = new GPMSCHSPLinkServiceHelper(scope);
        chspLinkServiceHelper.executeGPMSCHSPLinkService();
    }
    
    public void finish(Database.BatchableContext BC){
        
    }
}