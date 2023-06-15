public with sharing class UserTriggerHandler implements afterInsert, afterUpdate {

    public void afterInsert(Map<Id, SObject> newUsersMap) {
        UserTriggerService.fireAddRemoveUsersToFromPublicGroupsPE((Map<Id, User>)newUsersMap, null);
    }
    
    public void afterUpdate(Map<Id, SObject> newUsersMap, Map<Id, SObject> oldUsersMap) {
        UserTriggerService.fireAddRemoveUsersToFromPublicGroupsPE((Map<Id, User>)newUsersMap, (Map<Id, User>)oldUsersMap);
    }
    
}