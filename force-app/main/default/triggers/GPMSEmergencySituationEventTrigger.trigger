/****************************************************************************************************
* @CreatedBy   : Accenture Developer Team
* @CreatedDate : 25-Nov-2022
* @Description : Handles the logic to GPMSEmergencySituationEventTrigger
* @Test Class  : 
*****************************************************************************************************/
trigger GPMSEmergencySituationEventTrigger on GPMS_Emergency_Situation__ChangeEvent (after insert) {
    
    if( !(new TriggerBypassStrategy().isDisabled())) {
        TriggerDispatcher.dispatch(new GPMSEmergencySituationEventHandler(), TriggerOperation.AFTER_INSERT);
    }

}