/****************************************************************************************************
* @CreatedBy   : David Zheng
* @CreatedDate : 30-01-2023
* @Description : Batch class for Transfer expired pending events
* @testClass GPMSTransferEventPendingBatchTest
*****************************************************************************************************/

public with sharing class GPMSTransferEventPendingBatch implements Database.Batchable<sObject>,Database.Stateful{
    public static final String EVENT_STATUS_PENDING = 'Pending';
    public static final String EVENT_STATUS_CHANGE_TO = 'Automatic Transfer: Pending Activation';

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id, Status__c, GPMS_Proposed_Transfer_Date__c, Status_Date__c FROM Event__c WHERE GPMS_Proposed_Transfer_Date__c <= TODAY AND Status__c =:EVENT_STATUS_PENDING';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Event__c> batch) {
        for(Event__c event : batch) {
            event.Status__c = EVENT_STATUS_CHANGE_TO;
            event.Status_Date__c = Date.today();
        }
        try {
            update batch;
        } catch (Exception exp) {
            dohagedcare.Logger.error(exp.getMessage(),exp,'GPMS').Log(); 
        }
    }

    public void finish(Database.BatchableContext bc) {
        // Nothing to do with this section
    }
}