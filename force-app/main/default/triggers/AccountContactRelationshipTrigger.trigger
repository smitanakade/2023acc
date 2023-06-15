/****************************************************************************************************
* @CreatedBy   : Yohan Perera
* @CreatedDate : 1-11-2022
* @Description : Trigger
* @Test Class  : AccountContactRelationshipTriggerTest
*****************************************************************************************************/

trigger AccountContactRelationshipTrigger on AccountContactRelation (after insert, after update, before delete) {
    if( !(new TriggerBypassStrategy().isDisabled())) {
        switch on Trigger.operationType {
            when AFTER_INSERT{
                TriggerDispatcher.dispatch(new AccountContactRelationshipHandler(), TriggerOperation.AFTER_INSERT);
            }
            when AFTER_UPDATE{
                TriggerDispatcher.dispatch(new AccountContactRelationshipHandler(), TriggerOperation.AFTER_UPDATE);
            }
            when BEFORE_DELETE{
                TriggerDispatcher.dispatch(new AccountContactRelationshipHandler(), TriggerOperation.BEFORE_DELETE);
            }
        }
    }
}