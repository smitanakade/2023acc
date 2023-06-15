/**
 * author: Matthew Wall
 * date: 1/5/2023
 * description: Handler class to Generic Event Trigger
 * @testClass RegulatoryDecisionTriggerTest
 **/
public with sharing class GenericPlatformEventHandler implements afterInsert {
	public void afterInsert(Map<Id, SObject> newMap) {
		GenericEventTriggerHelper.filterObject(newMap);
	}
}
