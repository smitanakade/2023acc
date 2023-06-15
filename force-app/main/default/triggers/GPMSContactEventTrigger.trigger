/****************************************************************************************************
* @CreatedBy   : Accenture Developer Team
* @CreatedDate : 25-Nov-2022
* @Description : Handles the logic to GPMSContactEventTrigger
* @Test Class  : 
*****************************************************************************************************/
trigger GPMSContactEventTrigger on ContactChangeEvent (after insert) {
    
    if( !(new TriggerBypassStrategy().isDisabled())) {
        TriggerDispatcher.dispatch(new GPMSContactEventHandler(), TriggerOperation.AFTER_INSERT);
    }

}