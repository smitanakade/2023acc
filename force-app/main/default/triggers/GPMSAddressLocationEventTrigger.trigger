/****************************************************************************************************
* @CreatedBy   : Accenture Developer Team
* @CreatedDate : 25-Nov-2022
* @Description : Handles the logic to GPMSAddressLocationEventTrigger
* @Test Class  : 
*****************************************************************************************************/
trigger GPMSAddressLocationEventTrigger on Address_Location__ChangeEvent (after insert) {
    
    if( !(new TriggerBypassStrategy().isDisabled())) {
        TriggerDispatcher.dispatch(new GPMSAddressLocationEventHandler(), TriggerOperation.AFTER_INSERT);
    }

}