/****************************************************************************************************
* @CreatedBy   : Accenture Developer Team
* @CreatedDate : 25-Nov-2022
* @Description : Handles the logic to GPMSAddressEventTrigger
* @Test Class  : 
*****************************************************************************************************/
trigger GPMSAddressEventTrigger on Address__ChangeEvent (after insert) {
    
    if( !(new TriggerBypassStrategy().isDisabled())) {
        TriggerDispatcher.dispatch(new GPMSAddressEventHandler(), TriggerOperation.AFTER_INSERT);
    }

}