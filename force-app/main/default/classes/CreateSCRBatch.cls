/**
 * author: Matthew WAll
 * date: 10/11/2022
 * description: Batch job to process Regulatory Decisions
 **/
/* MODIFICATION LOG
 * Version       Developer                   Date                Description
 *-------------------------------------------------------------------------------------------
 *  1.0     		Matthew Wall               10-11-2022          Initial Creation
 *******************************************************************************************/
public with sharing class CreateSCRBatch implements Database.Batchable<sobject> {
   
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id, Name, Service_Name__c, Service_Name__r.Care_Type__c,  CountCurrentRegDec__c, CountArchRegDecision__c, CurrentNonCurrentRegDec__c, Association_Start_Date__c ' + 
                        'FROM Service_Account_Relationship__c WHERE (Service_Name__r.Care_Type__c = \'Residential\' OR Service_Name__r.Care_Type__c = \'Home Care\') ' +
                        'AND Active__c = true';
                      
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Service_Account_Relationship__c> sarList) { 
        try {
            CreateSCRBatchHelper helper = new CreateSCRBatchHelper();
            helper.processSCRBatch(sarList); 
        } catch (Exception ex) {
            dohagedcare.Logger.error(ex.getMessage(), ex, 'Star Rating').log();
        }
        
    }

    public void finish(Database.BatchableContext bc) {
        // nothing to do here
    }
}