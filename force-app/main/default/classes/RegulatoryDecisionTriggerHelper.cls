/**
 * author: Matthew Wall
 * date: 1/5/2023
 * description: Helper class dispatches Generic Event when criteria met
 * @testClass RegulatoryDecisionTriggerTest
 **/
public with sharing class RegulatoryDecisionTriggerHelper {
	public static void dispatchPlatformEvent(
		Map<Id, SObject> newMap,
		Map<Id, SObject> oldMap
	) {
		for (Id key : newMap.keySet()) {
			RegulatoryCodeViolation newRegDec = (RegulatoryCodeViolation) newMap.get(
				key
			);
			RegulatoryCodeViolation oldRegDec = (RegulatoryCodeViolation) oldMap.get(
				key
			);

			List<Generic_Event__e> eventList = new List<Generic_Event__e>();
			eventList.add(
				PlatformEventHelper.createGenericEvent(
					newRegDec,
					oldRegDec,
					'UPDATE'
				)
			);
			Eventbus.publish(eventList);
		}
	}

	public static void shareWithPublicGroup(
		Map<Id, RegulatoryCodeViolation> newDecisionMap
	) {
		Map<Id, String> rcvToGroupMap = new Map<Id, String>();
		Map<String, Group> groupNameToGroupMap = new Map<String, Group>();
		List<RegulatoryCodeViolationShare> sharesList = new List<RegulatoryCodeViolationShare>();

		try {
			for (Id rcvId : newDecisionMap.keySet()) {
				rcvToGroupMap.put(
					rcvId,
					'SRV_' + newDecisionMap.get(rcvId).Service_Name_lookup__c
				);
			}

			for (Group g : [
				SELECT Id, DeveloperName
				FROM Group
				WHERE DeveloperName IN :rcvToGroupMap.values()
				WITH SECURITY_ENFORCED
			]) {
				groupNameToGroupMap.put(g.DeveloperName, g);
			}

			for (Id rcvId : rcvToGroupMap.keySet()) {
				//Checks if a real group exists for the RCV Name
				if (groupNameToGroupMap.containsKey(rcvToGroupMap.get(rcvId))) {
					Group newGroup = groupNameToGroupMap.get(
						rcvToGroupMap.get(rcvId)
					);

					RegulatoryCodeViolationShare rcvShare = new RegulatoryCodeViolationShare();
					rcvShare.ParentId = rcvId;
					rcvShare.UserOrGroupId = newGroup.Id;
					rcvShare.RowCause = Schema.RegulatoryCodeViolationShare.RowCause.Manual;
					rcvShare.AccessLevel = 'Read';
					sharesList.add(rcvShare);
				}
			}

			if (!sharesList.isEmpty()) {
				insert sharesList;
			}
		} catch (Exception ex) {
			dohagedcare.Logger.error(ex.getMessage(), ex, 'Star Rating').log();
		}
	}

	public static void shareWithPublicGroupWhenOwnershipChanges(
		Map<Id, RegulatoryCodeViolation> newDecisionMap,
		Map<Id, RegulatoryCodeViolation> oldDecisionMap
	) {
		List<RegulatoryCodeViolationShare> sharesList = new List<RegulatoryCodeViolationShare>();

		Map<String, Group> groupToNameMap = new Map<String, Group>();
		Map<String, Group> groupToNameMap2 = new Map<String, Group>();

		try {
			for (Id rcvId : newDecisionMap.keySet()) {
				groupToNameMap.put(
					'SRV_' + newDecisionMap.get(rcvId).Service_Name_lookup__c,
					null
				);
			}

			for (Group g : [
				SELECT Id, DeveloperName
				FROM Group
				WHERE DeveloperName IN :groupToNameMap.keySet()
				WITH SECURITY_ENFORCED
			]) {
				groupToNameMap2.put(g.DeveloperName, g);
			}

			for (Id rcvId : newDecisionMap.keySet()) {
				if (
					newDecisionMap.get(rcvId).ownerId !=
					oldDecisionMap.get(rcvId).ownerId
				) {
					Group newGroup = groupToNameMap2.get(
						'SRV_' +
						newDecisionMap.get(rcvId).Service_Name_lookup__c
					);

					RegulatoryCodeViolationShare rcvShare = new RegulatoryCodeViolationShare();
					rcvShare.ParentId = rcvId;
					rcvShare.UserOrGroupId = newGroup.Id;
					rcvShare.RowCause = Schema.RegulatoryCodeViolationShare.RowCause.Manual;
					rcvShare.AccessLevel = 'Read';

					sharesList.add(rcvShare);
				}
			}

			if (!sharesList.isEmpty()) {
				insert sharesList;
			}
		} catch (Exception ex) {
			dohagedcare.Logger.error(ex.getMessage(), ex, 'Star Rating').log();
		}
	}
}
