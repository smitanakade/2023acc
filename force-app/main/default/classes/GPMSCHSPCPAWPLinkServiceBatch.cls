/****************************************************************************************************
* @CreatedBy   : Accenture Developer Team
* @CreatedDate : 19-Sep-2022
* @Description : Handles the logic to CHSP Procurement Based AWP with CHSP Service
* @Test Class  : GPMSCHSPCPAWPLinkServiceScheduleTest
*****************************************************************************************************/
public with sharing class GPMSCHSPCPAWPLinkServiceBatch implements Database.Batchable<sObject>{
    
    private static final String ServiceRT = Schema.SObjectType.BusinessLicense.getRecordTypeInfosByDeveloperName().get('CHSP_Service').getRecordTypeId();
    private static final String ServiceProviderRT = Schema.SObjectType.Service_Account_Relationship__c.getRecordTypeInfosByDeveloperName().get('Provider_to_Service').getRecordTypeId();
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        
        String query = 'SELECT Id,Party_Id__c,Service_Care_Sub_Type__c, Activity_Status__c, Service_Area__c '+
            'FROM CHSP_Procurement_Based_AWP_Record__c '+
            'WHERE Party_Id__c != null AND Service_Care_Sub_Type__c != null';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<CHSP_Procurement_Based_AWP_Record__c> scope){
        GPMSCHSPCPAWPLinkServiceHelper chspLinkServiceHelper = new GPMSCHSPCPAWPLinkServiceHelper(scope);
        chspLinkServiceHelper.executeGPMSCHSPCPAWPLinkService();
    }
    
    public void finish(Database.BatchableContext BC){
        
    }
}