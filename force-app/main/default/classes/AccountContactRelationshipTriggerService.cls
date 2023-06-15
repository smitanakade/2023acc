/****************************************************************************************************
* @CreatedBy   : Yohan Perera
* @CreatedDate : 1-11-2022
* @Description : Service class for AccountContactRelationshipTrigger
* @testClass AccountContactRelationshipTriggerTest

* @Modified by : AG - Enable "QI Role - Org" for sharing
* @ModifiedDate : 25-03-2023
* @testClass AccountContactRelationshipTriggerTest

*****************************************************************************************************/
public with sharing class AccountContactRelationshipTriggerService {
	public static final String ROLE_STAR_RATING_REVIEWER = 'Star Rating Reviewer';
	public static final String ROLE_QI_ORG = 'QI Role - Org';
	public static final String ROLE_QI_SERVICE = 'QI Role - Service';
	public static final String ROLE_QI_BENCHMARKER = 'QI Benchmarker';
	public static final List<String> ACR_ROLE_WITH_STAR_RATING_ACCESS = new List<String>{
		ROLE_STAR_RATING_REVIEWER,
		ROLE_QI_ORG,
		ROLE_QI_SERVICE,
		ROLE_QI_BENCHMARKER
	};

	public static final String OP_INSERT = 'INSERT';
	public static final String OP_DELETE = 'DELETE';

	public static void fireAddOrDeleteUsersToFromPublicGroupsPE(
		Map<Id, AccountContactRelation> newAccountContactRelationshipMap,
		Map<Id, AccountContactRelation> oldAccountContactRelationshipMap
	) {
		Map<Id, AccountContactRelation> newACRsToAddMap = new Map<Id, AccountContactRelation>();
		Map<Id, AccountContactRelation> acrsToRemoveMap = new Map<Id, AccountContactRelation>();

		for (Id acrId : newAccountContactRelationshipMap.keySet()) {
			if (
				(oldAccountContactRelationshipMap.get(acrId).Roles == null ||
				!oldAccountContactRelationshipMap.get(acrId)
					.Roles.split(';')
					.contains(ROLE_STAR_RATING_REVIEWER) ||
				!oldAccountContactRelationshipMap.get(acrId)
					.Roles.split(';')
					.contains(ROLE_QI_ORG) ||
				!oldAccountContactRelationshipMap.get(acrId)
					.Roles.split(';')
					.contains(ROLE_QI_SERVICE) ||
				!oldAccountContactRelationshipMap.get(acrId)
					.Roles.split(';')
					.contains(ROLE_QI_BENCHMARKER)) &&
				(newAccountContactRelationshipMap.get(acrId).Roles != null &&
				(newAccountContactRelationshipMap.get(acrId)
					.Roles.split(';')
					.contains(ROLE_STAR_RATING_REVIEWER) ||
				newAccountContactRelationshipMap.get(acrId)
					.Roles.split(';')
					.contains(ROLE_QI_ORG) ||
				newAccountContactRelationshipMap.get(acrId)
					.Roles.split(';')
					.contains(ROLE_QI_SERVICE) ||
				newAccountContactRelationshipMap.get(acrId)
					.Roles.split(';')
					.contains(ROLE_QI_BENCHMARKER)))
			) {
				newACRsToAddMap.put(
					acrId,
					newAccountContactRelationshipMap.get(acrId)
				);
			} else if (
				(newAccountContactRelationshipMap.get(acrId).Roles == null ||
				!newAccountContactRelationshipMap.get(acrId)
					.Roles.split(';')
					.contains(ROLE_STAR_RATING_REVIEWER) ||
				newAccountContactRelationshipMap.get(acrId)
					.Roles.split(';')
					.contains(ROLE_QI_ORG) ||
				newAccountContactRelationshipMap.get(acrId)
					.Roles.split(';')
					.contains(ROLE_QI_SERVICE) ||
				newAccountContactRelationshipMap.get(acrId)
					.Roles.split(';')
					.contains(ROLE_QI_BENCHMARKER)) &&
				(oldAccountContactRelationshipMap.get(acrId).Roles != null &&
				(oldAccountContactRelationshipMap.get(acrId)
					.Roles.split(';')
					.contains(ROLE_STAR_RATING_REVIEWER) ||
				oldAccountContactRelationshipMap.get(acrId)
					.Roles.split(';')
					.contains(ROLE_QI_ORG) ||
				oldAccountContactRelationshipMap.get(acrId)
					.Roles.split(';')
					.contains(ROLE_QI_SERVICE) ||
				oldAccountContactRelationshipMap.get(acrId)
					.Roles.split(';')
					.contains(ROLE_QI_BENCHMARKER)))
			) {
				acrsToRemoveMap.put(
					acrId,
					newAccountContactRelationshipMap.get(acrId)
				);
			} else {
				continue;
			}
		}

		if (!newACRsToAddMap.isEmpty())
			fireAddUsersToPublicGroupsPE(newACRsToAddMap);
		if (!acrsToRemoveMap.isEmpty())
			fireDeleteUsersFromPublicGroupsPE(acrsToRemoveMap);
	}

	public static void fireAddUsersToPublicGroupsPE(
		Map<Id, AccountContactRelation> newAccountContactRelationshipMap
	) {
		List<AccountContactRelationPE__e> eventsList = new List<AccountContactRelationPE__e>();

		for (Id acrId : newAccountContactRelationshipMap.keySet()) {
			AccountContactRelationPE__e event = new AccountContactRelationPE__e();
			event.AccountContactRelationId__c = acrId;
			event.Operation__c = AccountContactRelationshipTriggerService.OP_INSERT;
			eventsList.add(event);
		}

		EventBus.publish(eventsList);
	}

	public static void fireDeleteUsersFromPublicGroupsPE(
		Map<Id, AccountContactRelation> oldAccountContactRelationshipMap
	) {
		List<AccountContactRelationPE__e> eventsList = new List<AccountContactRelationPE__e>();

		for (Id acrId : oldAccountContactRelationshipMap.keySet()) {
			AccountContactRelationPE__e event = new AccountContactRelationPE__e();
			event.AccountContactRelationId__c = acrId;
			event.AccountId__c = oldAccountContactRelationshipMap.get(acrId)
				.AccountId;
			event.ContactId__c = oldAccountContactRelationshipMap.get(acrId)
				.ContactId;
			event.Role__c = oldAccountContactRelationshipMap.get(acrId).Roles;
			event.Operation__c = AccountContactRelationshipTriggerService.OP_DELETE;
			eventsList.add(event);
		}

		EventBus.publish(eventsList);
	}

	public static void distributeEvents(
		List<AccountContactRelationPE__e> events
	) {
		Map<Id, AccountContactRelation> toInsertACRs = new Map<Id, AccountContactRelation>();
		List<AccountContactRelationPE__e> toDeleteACRs = new List<AccountContactRelationPE__e>();

		try {
			for (AccountContactRelationPE__e event : events) {
				if (
					event.Operation__c ==
					AccountContactRelationshipTriggerService.OP_INSERT
				) {
					toInsertACRs.put(
						(Id) event.AccountContactRelationId__c,
						null
					);
				} else if (
					event.Operation__c ==
					AccountContactRelationshipTriggerService.OP_DELETE
				) {
					toDeleteACRs.add(event);
				}
			}

			if (!toInsertACRs.isEmpty()) {
				Map<Id, AccountContactRelation> relationshipsMap = new Map<Id, AccountContactRelation>(
					[
						SELECT Id, AccountId, ContactId, Roles
						FROM AccountContactRelation
						WHERE Id IN :toInsertACRs.keySet()
					]
				);
				for (Id key : relationshipsMap.keySet()) {
					AccountContactRelation acr = relationshipsMap.get(key);
					if (toInsertACRs.containsKey(key)) {
						toInsertACRs.put(key, acr);
					}
				}
			}

			if (!toInsertACRs.isEmpty())
				AccountContactRelationshipTriggerService.addUsersToPublicGroups(
					toInsertACRs
				);

			if (!toDeleteACRs.isEmpty())
				AccountContactRelationshipTriggerService.deleteUsersFromPublicGroups(
					toDeleteACRs
				);
		} catch (Exception ex) {
			dohagedcare.Logger.error(ex.getMessage(), ex, 'Star Rating').log();
		}
	}

	public static void deleteUsersFromPublicGroups(
		List<AccountContactRelationPE__e> accountcontactRelationshipList
	) {
		Set<Id> allAccountIds = new Set<Id>();
		Map<Id, List<Id>> parentToChildAccounts = new Map<Id, List<Id>>();

		Map<Id, Id> acrToContactMap = new Map<Id, Id>();
		Map<Id, Id> acrToUserMap = new Map<Id, Id>();

		try {
			for (
				AccountContactRelationPE__e acr : accountcontactRelationshipList
			) {
				//Step 1: Filter only the relevant ACRS
				acrToContactMap.put(
					acr.AccountContactRelationId__c,
					acr.ContactId__c
				);
				allAccountIds.add(acr.AccountId__c);

				parentToChildAccounts.put(acr.AccountId__c, new List<Id>());
			}

			//Step 2: Grab the users per Contact and map them with each ACR
			if (!acrToContactMap.isEmpty()) {
				Map<Id, User> contactToUserMap = new Map<Id, User>();

				for (User u : [
					SELECT Id, ContactId
					FROM User
					WHERE ContactId IN :acrToContactMap.values()
				]) {
					contactToUserMap.put(u.ContactId, u);
				}

				for (Id acrId : acrToContactMap.keySet()) {
					if (
						contactToUserMap.containsKey(acrToContactMap.get(acrId))
					) {
						acrToUserMap.put(
							acrId,
							contactToUserMap.get(acrToContactMap.get(acrId)).Id
						);
					}
				}
			}

			//Step 3: Get all the child accounts for the parent account mentioned in the ACR
			for (Account a : [
				SELECT Id, ParentId
				FROM Account
				WHERE ParentId IN :parentToChildAccounts.keySet()
			]) {
				parentToChildAccounts.get(a.ParentId).add(a.Id);
				allAccountIds.add(a.Id);
			}

			//Step 4: Get all the service ids related to all the accounts including parent & childern
			Map<Id, List<String>> accountToGroupName = new Map<Id, List<String>>();
			Set<String> allGroups = new Set<String>();

			for (BusinessLicense service : [
				SELECT Id, AccountId
				FROM BusinessLicense
				WHERE AccountId IN :allAccountIds
			]) {
				if (accountToGroupName.containsKey(service.AccountId)) {
					accountToGroupName.get(service.AccountId)
						.add('SRV_' + service.Id);
				} else {
					List<String> groupNames = new List<String>();
					groupNames.add('SRV_' + service.Id);
					accountToGroupName.put(service.AccountId, groupNames);
				}

				allGroups.add('SRV_' + service.Id);
			}

			//Step 5: Get all the Public Group Ids for each Group name retrieved
			Map<String, Id> groupNameToGroupIdMap = new Map<String, Id>();
			for (Group g : [
				SELECT Id, DeveloperName
				FROM Group
				WHERE DeveloperName IN :allGroups
			]) {
				groupNameToGroupIdMap.put(g.DeveloperName, g.Id);
			}

			List<GroupMember> groupMembersToDelete = new List<GroupMember>();
			for (GroupMember gm : [
				SELECT Id
				FROM GroupMember
				WHERE
					GroupId IN :groupNameToGroupIdMap.values()
					AND UserOrGroupId IN :acrToUserMap.values()
			]) {
				groupMembersToDelete.add(gm);
			}

			if (!groupMembersToDelete.isEmpty())
				delete groupMembersToDelete;
		} catch (Exception ex) {
			dohagedcare.Logger.error(ex.getMessage(), ex, 'Star Rating').log();
		}
	}

	public static void addUsersToPublicGroups(
		Map<Id, AccountContactRelation> newAccountContactRelationshipMap
	) {
		Set<Id> allAccountIds = new Set<Id>();
		Map<Id, List<Id>> parentToChildAccounts = new Map<Id, List<Id>>();

		Map<Id, Id> acrToContactMap = new Map<Id, Id>();
		Map<Id, User> acrToUserMap = new Map<Id, User>();

		try {
			for (Id acrId : newAccountContactRelationshipMap.keySet()) {
				AccountContactRelation acr = newAccountContactRelationshipMap.get(
					acrId
				);

				//Step 1: Filter only the relevant ACRS
				if (isAvalidACR(acr)) {
					acrToContactMap.put(acr.Id, acr.ContactId);
					allAccountIds.add(acr.AccountId);

					parentToChildAccounts.put(acr.AccountId, new List<Id>());
				}
			}

			//Step 2: Grab the users per Contact and map them with each ACR
			if (!acrToContactMap.isEmpty()) {
				Map<Id, User> contactToUserMap = new Map<Id, User>();

				for (User u : [
					SELECT Id, ContactId
					FROM User
					WHERE ContactId IN :acrToContactMap.values()
				]) {
					contactToUserMap.put(u.ContactId, u);
				}

				for (Id acrId : acrToContactMap.keySet()) {
					if (
						contactToUserMap.containsKey(acrToContactMap.get(acrId))
					) {
						acrToUserMap.put(
							acrId,
							contactToUserMap.get(acrToContactMap.get(acrId))
						);
					}
				}
			}

			//Step 3: Get all the child accounts for the parent account mentioned in the ACR
			for (Account a : [
				SELECT Id, ParentId
				FROM Account
				WHERE ParentId IN :parentToChildAccounts.keySet()
			]) {
				parentToChildAccounts.get(a.ParentId).add(a.Id);
				allAccountIds.add(a.Id);
			}

			//Step 4: Get all the service ids related to all the accounts including parent & childern
			Map<Id, List<String>> accountToGroupName = new Map<Id, List<String>>();

			Set<String> allGroups = new Set<String>();

			for (BusinessLicense service : [
				SELECT Id, AccountId
				FROM BusinessLicense
				WHERE AccountId IN :allAccountIds
			]) {
				if (accountToGroupName.containsKey(service.AccountId)) {
					accountToGroupName.get(service.AccountId)
						.add('SRV_' + service.Id);
				} else {
					List<String> groupNames = new List<String>();
					groupNames.add('SRV_' + service.Id);
					accountToGroupName.put(service.AccountId, groupNames);
				}

				allGroups.add('SRV_' + service.Id);
			}

			//Step 5: Get all the Public Group Ids for each Group name retrieved
			Map<String, Id> groupNameToGroupIdMap = new Map<String, Id>();
			for (Group g : [
				SELECT Id, DeveloperName
				FROM Group
				WHERE DeveloperName IN :allGroups
			]) {
				groupNameToGroupIdMap.put(g.DeveloperName, g.Id);
			}

			//Step 6: Create group members for each ACR and its related accounts
			List<GroupMember> groupMembersToInsert = new List<GroupMember>();
			for (Id acrId : acrToUserMap.keySet()) {
				AccountContactRelation acr = newAccountContactRelationshipMap.get(
					acrId
				);

				List<Id> accountsList = parentToChildAccounts.get(
					acr.AccountId
				);
				accountsList.add(acr.AccountId); //Adding the parent account id to the list too

				for (Id accountId : accountsList) {
					//Step 7: Get the list of groups the membership should be created
					List<String> groupNames = accountToGroupName.get(accountId);
					if (groupNames != null) {
						for (String groupName : groupNames) {
							if (groupNameToGroupIdMap.get(groupName) != null) {
								GroupMember gm = new GroupMember(
									GroupId = groupNameToGroupIdMap.get(
										groupName
									),
									UserOrGroupId = acrToUserMap.get(acrId).Id
								);
								groupMembersToInsert.add(gm);
							}
						}
					}
				}
			}

			if (!groupMembersToInsert.isEmpty())
				insert groupMembersToInsert;
		} catch (Exception ex) {
			dohagedcare.Logger.error(ex.getMessage(), ex, 'Star Rating').log();
		}
	}

	private static boolean isAvalidACR(AccountContactRelation acr) {
		if (
			acr != null &&
			acr.ContactId != null &&
			acr.Roles != null &&
			(acr.Roles.split(';').contains(ROLE_STAR_RATING_REVIEWER) ||
			acr.Roles.split(';').contains(ROLE_QI_ORG) ||
			acr.Roles.split(';').contains(ROLE_QI_SERVICE) ||
			acr.Roles.split(';').contains(ROLE_QI_BENCHMARKER))
		)
			return true;

		return false;
	}
}
