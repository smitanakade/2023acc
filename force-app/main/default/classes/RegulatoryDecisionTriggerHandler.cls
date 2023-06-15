/**
 * author: Matthew Wall
 * date: 1/5/2023
 * description: Trigger Handler for Regulatory Decision Trigger
 * @testClass RegulatoryDecisionTriggerTest
 **/
public with sharing class RegulatoryDecisionTriggerHandler implements afterUpdate, afterInsert {
	public void afterUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {
		RegulatoryDecisionTriggerHelper.dispatchPlatformEvent(newMap, oldMap);

		RegulatoryDecisionTriggerHelper.shareWithPublicGroupWhenOwnershipChanges(
			(Map<Id, RegulatoryCodeViolation>) newMap,
			(Map<Id, RegulatoryCodeViolation>) oldMap
		);
	}

	public void afterInsert(Map<Id, SObject> newMap) {
		RegulatoryDecisionTriggerHelper.shareWithPublicGroup(
			(Map<Id, RegulatoryCodeViolation>) newMap
		);
	}
}
