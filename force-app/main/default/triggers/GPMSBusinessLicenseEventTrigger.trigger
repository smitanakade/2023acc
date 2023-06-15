/****************************************************************************************************
* @CreatedBy   : Accenture Developer Team
* @CreatedDate : 25-Nov-2022
* @Description : Handles the logic to BusinessLicenseChangeEvent
* @Test Class  : 
*****************************************************************************************************/
trigger GPMSBusinessLicenseEventTrigger on BusinessLicenseChangeEvent (after insert) {
    
    if( !(new TriggerBypassStrategy().isDisabled())) {
        GPMSBusinessLicenseEventHandler handler = new GPMSBusinessLicenseEventHandler();
        handler.afterInsert(Trigger.NewMap);
    }

}