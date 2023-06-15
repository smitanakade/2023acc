/****************************************************************************************************
* @CreatedBy   : Accenture Developer Team
* @CreatedDate : 25-Nov-2022
* @Description : Handles the logic to GPMSContactRelationshipEventTrigger
* @Test Class  : 
*****************************************************************************************************/
trigger GPMSContactRelationshipEventTrigger on Contact_Relationship__ChangeEvent (after insert) {
    
    if( !(new TriggerBypassStrategy().isDisabled())) {
        TriggerDispatcher.dispatch(new GPMSContactRelationshipEventHandler(), TriggerOperation.AFTER_INSERT);
    }

}