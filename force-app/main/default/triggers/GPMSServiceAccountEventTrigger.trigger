/****************************************************************************************************
* @CreatedBy   : Accenture Developer Team
* @CreatedDate : 25-Nov-2022
* @Description : Handles the logic to GPMSServiceAccountEventTrigger
* @Test Class  : 
*****************************************************************************************************/
trigger GPMSServiceAccountEventTrigger on Service_Account_Relationship__ChangeEvent (after insert) {
    
    if( !(new TriggerBypassStrategy().isDisabled())) {
        TriggerDispatcher.dispatch(new GPMSServiceAccountEventHandler(), TriggerOperation.AFTER_INSERT);
    }

}