/****************************************************************************************************
* @CreatedBy   : Accenture Developer Team
* @CreatedDate : 25-Nov-2022
* @Description : Handles the logic to GPMSServiceFundingEventTrigger
* @Test Class  : 
*****************************************************************************************************/
trigger GPMSServiceFundingEventTrigger on GPMS_Service_Funding__ChangeEvent (after insert) {
    
    if( !(new TriggerBypassStrategy().isDisabled())) {
        TriggerDispatcher.dispatch(new GPMSServiceFundingEventHandler(), TriggerOperation.AFTER_INSERT);
    }

}