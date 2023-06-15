/****************************************************************************************************
* @CreatedBy   : Accenture Developer Team
* @CreatedDate : 25-Nov-2022
* @Description : Handles the logic to GPMSPlacesAllotmentEventTrigger
* @Test Class  : 
*****************************************************************************************************/
trigger GPMSPlacesAllotmentEventTrigger on Places_Allotment__ChangeEvent (after insert) {
    
    if( !(new TriggerBypassStrategy().isDisabled())) {
        TriggerDispatcher.dispatch(new GPMSPlacesAllotmentEventHandler(), TriggerOperation.AFTER_INSERT);
    }

}