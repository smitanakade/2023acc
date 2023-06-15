/**
* author: Daniel Clift
* date: 1/11/2022
* description: trigger for Reporting_Period__c
**/
trigger ReportingPeriodTrigger on Reporting_Period__c (after update) {
    if( !(new TriggerBypassStrategy().isDisabled())) {
        if(Trigger.isUpdate) {
            if(Trigger.isAfter) {
                TriggerDispatcher.dispatch(new ReportingPeriodTriggerHandler(), TriggerOperation.AFTER_UPDATE);
            }
        }
    }
}