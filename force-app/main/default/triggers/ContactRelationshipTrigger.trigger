/****************************************************************************************************
* @CreatedBy   : Yohan Perera
* @CreatedDate : 1-11-2022
* @Description : Trigger
* @Test Class  : ContactRelationshipTriggerTest
* @Modified by : Sanjeev Bajpai -Added after insert for General Enquiry validation
* @ModifiedDate : 21-12-2022
*****************************************************************************************************/
trigger ContactRelationshipTrigger on Contact_Relationship__c (after insert, after update, before delete) {
    if( !(new TriggerBypassStrategy().isDisabled())) {
        switch on Trigger.operationType {
            when AFTER_INSERT{
                TriggerDispatcher.dispatch(new ContactRelationshipTriggerHandler(), TriggerOperation.AFTER_INSERT);
            }
            when AFTER_UPDATE{
                TriggerDispatcher.dispatch(new ContactRelationshipTriggerHandler(), TriggerOperation.AFTER_UPDATE);
            }
            when BEFORE_DELETE{
                TriggerDispatcher.dispatch(new ContactRelationshipTriggerHandler(), TriggerOperation.BEFORE_DELETE);
            }
             when BEFORE_INSERT{
                TriggerDispatcher.dispatch(new ContactRelationshipTriggerHandler(), TriggerOperation.BEFORE_INSERT);
            }
        }
    }
}