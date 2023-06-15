/**
 * author: Matthew Wall
 * date: 1/5/2023
 * description: Helper class for Generic Event, filters based on EntityName and calls related logic
 * @testClass RegulatoryDecisionTriggerTest
 **/
public with sharing class GenericEventTriggerHelper {
	public static void filterObject(Map<Id, SObject> newMap) {
		Map<Id, String> changedFieldMap = new Map<Id, String>();
		List<Generic_Event__e> regulatoryDecisionList = new List<Generic_Event__e>();

		for (SObject o : newMap.values()) {
			Generic_Event__e ge = (Generic_Event__e) o;
			switch on ge.entityName__c {
				when 'RegulatoryCodeViolation' {
					// call reg dec code
					regulatoryDecisionList.add(ge);
					changedFieldMap.put(ge.recordIds__c, ge.changedFields__c);
				}
				when else {
					// do nothing when object not found
				}
			}
		}

		// Call helper method if list is not empty
		if (regulatoryDecisionList.size() > 0) {
			RegulatoryDecisionEventTriggerHelper.process(
				regulatoryDecisionList,
				changedFieldMap
			);
		}
	}
}
