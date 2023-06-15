/****************************************************************************************************
 * @CreatedBy   : Yohan Perera
 * @CreatedDate : 1-11-2022
 * @Description : Handler class for AccountContactRelationshipTrigger
 * @testClass AccountContactRelationshipTriggerTest
 *****************************************************************************************************/

public with sharing class AccountContactRelationshipHandler implements afterInsert, afterUpdate, beforeDelete {
	public void afterInsert(Map<Id, SObject> newMap) {
		ACRTriggerServiceNew.createACR(
			(Map<Id, AccountContactRelation>) newMap,
			null
		);
	}

	public void afterUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {
		AccountContactRelationshipTriggerService.fireAddOrDeleteUsersToFromPublicGroupsPE(
			(Map<Id, AccountContactRelation>) newMap,
			(Map<Id, AccountContactRelation>) oldMap
		);

		ACRTriggerServiceNew.createACR(
			(Map<Id, AccountContactRelation>) newMap,
			(Map<Id, AccountContactRelation>) oldMap
		);
	}

	public void beforeDelete(Map<Id, SObject> oldMap) {
		AccountContactRelationshipTriggerService.fireDeleteUsersFromPublicGroupsPE(
			(Map<Id, AccountContactRelation>) oldMap
		);
	}
}
