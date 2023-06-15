/**
 * @description       : For initialising sidebar states on load
 * @last modified on  : 29-May-2023
 * @TestClass AcfrSidebarControllerTest
 **/
public with sharing class AcfrSidebarController {
	@AuraEnabled
	public static List<Form__c> getFormStates(Id caseId) {
		List<Form__c> formStates = [
			SELECT Id, Type__c, Is_Complete__c
			FROM Form__c
			WHERE Case__c = :caseId
		];

		return formStates;
	}

	@AuraEnabled
	public static Boolean checkPrimaryContact(Id caseId) {
		List<Case> relatedAccount = [
			SELECT AccountId
			FROM Case
			WHERE Id = :caseId
		];

		List<Contact_Relationship__c> primaryContact = [
			SELECT Id
			FROM Contact_Relationship__c
			WHERE
				Account__c = :relatedAccount[0].AccountId
				AND Role__c = 'QFR Primary Contact'
		];

		Boolean primaryContactExists = false;
		if (!primaryContact.isEmpty()) {
			primaryContactExists = true;
		}

		return primaryContactExists;
	}

	@AuraEnabled
	public static void updateIsCompleteFlag(Id formId, String isCompleteValue) {
		Form__c formRecord = [
			SELECT Id, Is_Complete__c
			FROM Form__c
			WHERE Id = :formId
		];

		if (formRecord.Is_Complete__c != isCompleteValue) {
			formRecord.Is_Complete__c = isCompleteValue;
			update formRecord;
		}
	}

	@AuraEnabled
	public static string resumeForm(Id caseId) {
		Case currentCase = [
			SELECT Id, Active_Form__c
			FROM Case
			WHERE Id = :caseId
			LIMIT 1
		];

		if (currentCase.Active_Form__c == null) {
			return 'STBeforeYouStart';
		} else {
			return currentCase.Active_Form__c;
		}
	}

	@AuraEnabled
	public static void saveActiveForm(Id caseId, String activeForm) {
		Case currentCase = [
			SELECT Id, Active_Form__c
			FROM Case
			WHERE Id = :caseId
			LIMIT 1
		];

		currentCase.Active_Form__c = activeForm;
		update currentCase;
	}
}
