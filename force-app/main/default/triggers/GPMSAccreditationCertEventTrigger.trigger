/****************************************************************************************************
* @CreatedBy   : Accenture Developer Team
* @CreatedDate : 25-Nov-2022
* @Description : Handles the logic to GPMSAccreditationCertEventTrigger
* @Test Class  : 
*****************************************************************************************************/
trigger GPMSAccreditationCertEventTrigger on Accreditation_Certification__ChangeEvent (after insert) {
    
    if( !(new TriggerBypassStrategy().isDisabled())) {
        TriggerDispatcher.dispatch(new GPMSAccreditationCertEventHandler(), TriggerOperation.AFTER_INSERT);
    }

}