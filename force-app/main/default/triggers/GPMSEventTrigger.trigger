/****************************************************************************************************
* @CreatedBy   : Accenture Developer Team
* @CreatedDate : 08-May-2023
* @Description : Trigger of event__c object
* @TestClass GPMSEventHelper
*****************************************************************************************************/
trigger GPMSEventTrigger on Event__c (before update) {
    
    if( !(new TriggerBypassStrategy().isDisabled())) {
        TriggerDispatcher.dispatch(new GPMSEventHandler(), TriggerOperation.BEFORE_UPDATE);
    }
    
}