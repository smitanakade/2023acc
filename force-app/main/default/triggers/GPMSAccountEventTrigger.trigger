/****************************************************************************************************
* @CreatedBy   : Accenture Developer Team
* @CreatedDate : 25-Nov-2022
* @Description : Handles the logic to AccountChangeEvent
* @Test Class  : 
*****************************************************************************************************/
trigger GPMSAccountEventTrigger on AccountChangeEvent (after insert) {

    if( !(new TriggerBypassStrategy().isDisabled())) {
        TriggerDispatcher.dispatch(new GPMSAccountEventHandler(), TriggerOperation.AFTER_INSERT);
    }

}