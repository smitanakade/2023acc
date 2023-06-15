/****************************************************************************************************
* @CreatedBy   : Accenture Developer Team
* @CreatedDate : 25-Nov-2022
* @Description : Handles the logic to GPMSAccountRelationshipEventTrigger
* @Test Class  : 
*****************************************************************************************************/
trigger GPMSAccountRelationshipEventTrigger on Account_Relationship__ChangeEvent (after insert) {
    
    if( !(new TriggerBypassStrategy().isDisabled())) {
        TriggerDispatcher.dispatch(new GPMSAccountRelationshipEventHandler(), TriggerOperation.AFTER_INSERT);
    }

}