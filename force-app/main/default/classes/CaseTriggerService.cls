/****************************************************************************************************
 * @Description : New Service class for CaseTriggerHandler
 *****************************************************************************************************/
public with sharing class CaseTriggerService {
	public static void validateCaseStatusChanges(
		Map<Id, Sobject> newCaseMap,
		Map<Id, Sobject> oldCaseMap
	) {
		Map<Id, String> formQAOutcomeMap = new Map<Id, String>();
		Set<Id> reissuedCaseIds = new Set<Id>();

		Id qfrRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName()
			.get('QFR')
			.getRecordTypeId();
		for (Case c : (List<Case>) newCaseMap.values()) {
			Case oldcase = (Case) oldCaseMap.get(c.id);
			Case newCase = (Case) newCaseMap.get(c.id);

			if (
				(oldcase.status != newCase.status) &&
				(c.status == 'Reissued') &&
				c.RecordTypeId == qfrRecordTypeId
			) {
				reissuedCaseIds.add(c.id);
			}
		}

		for (Form__c form : [
			SELECT id, QA_Outcome__c, case__c
			FROM form__c
			WHERE case__c IN :reissuedCaseIds
		]) {
			if (form.QA_Outcome__c == 'Re-Issue') {
				formQAOutcomeMap.put(form.case__c, 'Reissued');
			} else if (!formQAOutcomeMap.containsKey(form.case__c)) {
				formQAOutcomeMap.put(form.case__c, 'Not Reissued');
			}
		}

		for (Case c : (List<Case>) newCaseMap.values()) {
			if (
				formQAOutcomeMap.size() > 0 &&
				formQAOutcomeMap.containsKey(c.Id) &&
				formQAOutcomeMap.get(c.id) == 'Not Reissued' &&
				c.RecordTypeId == qfrRecordTypeId
			) {
				c.addError(System.Label.QFR_Reissued_Case);
			}
		}
	}

	public static void invokeCaseAssignmentRule(
		Map<Id, Sobject> newCaseMap,
		Map<Id, Sobject> oldCaseMap
	) {
		if (!(Schema.sObjectType.AssignmentRule.isAccessible())) {
			return;
		} else {
			Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName()
				.get('Request_for_Information')
				.getRecordTypeId();

			AssignmentRule AR = new AssignmentRule();
			AR = [
				SELECT id
				FROM AssignmentRule
				WHERE SobjectType = 'Case' AND Active = TRUE
				LIMIT 1
			];
			Database.DMLOptions dmlOpts = new Database.DMLOptions();
			dmlOpts.assignmentRuleHeader.assignmentRuleId = AR.id;

			Map<Id, String> ARnewCaseMap = new Map<Id, String>();
			List<Id> caseIdList = new List<Id>();
			List<Case> caseList = new List<Case>();

			for (Case c : (List<Case>) newCaseMap.values()) {
				Case oldcase = (Case) oldCaseMap.get(c.id);
				Case newCase = (Case) newCaseMap.get(c.id);

				if (
					(oldcase.status != newCase.status) &&
					((newCase.status == 'Send to Assessor') ||
					(newCase.status == 'Send to Reviewer') ||
					(newCase.status == 'Send to Delegate')) &&
					(devRecordTypeId == oldcase.RecordTypeId)
				) {
					caseIdList.add(c.id);
				}
			}

			for (Case c : [
				SELECT id, ownerid
				FROM Case
				WHERE Id IN :caseIdList
			]) {
				c.setOptions(dmlOpts);
				caseList.add(c);
			}
			update caseList;
		}
	}
}
