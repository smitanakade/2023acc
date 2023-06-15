@isTest
public with sharing class AcfrSidebarControllerTest {
	@TestSetup
	static void setup() {
		Account acc = TestDataFactory.createProviderRecords(1)[0];
		insert acc;

		Contact con = new Contact(
			FirstName = 'Test',
			LastName = 'Contact',
			Salutation = 'Ms',
			Email = 'test@email.com'
		);
		insert con;

		Contact_Relationship__c cr = new Contact_Relationship__c(
			Account__c = acc.Id,
			Contact__c = con.Id,
			Role__c = 'QFR Primary Contact'
		);
		insert cr;

		Case c = new Case(
			AccountId = acc.Id,
			Status = 'Submitted',
			Active_Form__c = 'STViabiltyQuestionsHomeCareProvider',
			RecordTypeId = [
				SELECT Id
				FROM RecordType
				WHERE SObjectType = 'Case' AND DeveloperName = 'QFR'
				LIMIT 1
			]
			.Id
		);
		insert c;

		Form__c f_resi = new Form__c(
			Type__c = 'Residential Labour Costs and Hours',
			Account__c = acc.Id,
			Case__c = c.Id,
			Is_Complete__c = 'false'
		);
		insert f_resi;

		Form__c f_home = new Form__c(
			Type__c = 'Home Care Labour Costs and Hours',
			Account__c = acc.Id,
			Case__c = c.Id,
			Is_Complete__c = 'true'
		);
		insert f_home;

		Account acc_non = TestDataFactory.createProviderRecords(2)[1];
		insert acc_non;

		Contact con_non = new Contact(
			FirstName = 'No',
			LastName = 'Primary',
			Salutation = 'Mr',
			Email = 'noprimarycontact@email.com'
		);
		insert con_non;

		Contact_Relationship__c cr_non = new Contact_Relationship__c(
			Account__c = acc_non.Id,
			Contact__c = con_non.Id,
			Role__c = 'Financial Reporting Contact'
		);
		insert cr_non;

		Case c_non = new Case(
			AccountId = acc_non.Id,
			Status = 'Draft',
			RecordTypeId = [
				SELECT Id
				FROM RecordType
				WHERE SObjectType = 'Case' AND DeveloperName = 'QFR'
				LIMIT 1
			]
			.Id
		);
		insert c_non;
	}

	@isTest
	static void testGetFormStates() {
		Id caseId = [SELECT Id FROM Case WHERE Status = 'Submitted' LIMIT 1].Id;

		TestUserBuilder healthUserBuilder = QFRTestDataFactory.getHealthProviderBuilder();
		User healthUser = healthUserBuilder.createUser();
		List<Form__c> forms = [
			SELECT Id
			FROM Form__c
			ORDER BY CreatedDate DESC
		];
		for (Form__c form : forms) {
			form.OwnerId = healthUser.Id;
		}
		update forms;

		List<Form__c> result = new List<Form__c>();

		Test.startTest();
		System.runAs(healthUser) {
			result = AcfrSidebarController.getFormStates(caseId);
		}
		Test.stopTest();

		System.assertEquals(false, result.isEmpty());
		System.assertEquals('false', result[0].Is_Complete__c);
		System.assertEquals('true', result[1].Is_Complete__c);
	}

	@isTest
	static void testCheckPrimaryContact() {
		Id caseId = [SELECT Id FROM Case WHERE Status = 'Submitted' LIMIT 1].Id;
		Id caseId_non = [SELECT Id FROM Case WHERE Status = 'Draft' LIMIT 1].Id;

		TestUserBuilder healthUserBuilder = QFRTestDataFactory.getHealthProviderBuilder();
		User healthUser = healthUserBuilder.createUser();
		List<Form__c> forms = [
			SELECT Id
			FROM Form__c
			ORDER BY CreatedDate DESC
		];
		for (Form__c form : forms) {
			form.OwnerId = healthUser.Id;
		}
		update forms;

		Boolean result = false;
		Boolean result_non = true;

		Test.startTest();
		System.runAs(healthUser) {
			result = AcfrSidebarController.checkPrimaryContact(caseId);
			result_non = AcfrSidebarController.checkPrimaryContact(caseId_non);
		}
		Test.stopTest();

		System.assertEquals(true, result);
		System.assertEquals(false, result_non);
	}

	@isTest
	static void testUpdateIsCompleteFlag() {
		Id caseId = [SELECT Id FROM Case WHERE Status = 'Submitted' LIMIT 1].Id;
		TestUserBuilder healthUserBuilder = QFRTestDataFactory.getHealthProviderBuilder();
		User healthUser = healthUserBuilder.createUser();
		List<Form__c> forms = [
			SELECT Id
			FROM Form__c
			ORDER BY CreatedDate DESC
		];
		for (Form__c form : forms) {
			form.OwnerId = healthUser.Id;
		}
		update forms;

		Id form_change = forms[0].Id;
		Id form_same = forms[1].Id;

		Test.startTest();
		System.runAs(healthUser) {
			AcfrSidebarController.updateIsCompleteFlag(form_change, 'true');
			AcfrSidebarController.updateIsCompleteFlag(form_same, 'true');
		}
		Test.stopTest();

		List<Form__c> forms_results = [
			SELECT Id, Is_Complete__c
			FROM Form__c
			ORDER BY CreatedDate DESC
		];

		System.assertEquals('true', forms_results[0].Is_Complete__c);
		System.assertEquals('true', forms_results[1].Is_Complete__c);
	}

	@isTest
	static void testResumeForn() {
		Id caseId = [SELECT Id FROM Case WHERE Status = 'Submitted' LIMIT 1].Id;
		Id caseId_non = [SELECT Id FROM Case WHERE Status = 'Draft' LIMIT 1].Id;
		TestUserBuilder healthUserBuilder = QFRTestDataFactory.getHealthProviderBuilder();
		User healthUser = healthUserBuilder.createUser();

		String result;
		String result_non;

		Test.startTest();
		System.runAs(healthUser) {
			result = AcfrSidebarController.resumeForm(caseId);
			result_non = AcfrSidebarController.resumeForm(caseId_non);
		}
		Test.stopTest();

		System.assertEquals('STViabiltyQuestionsHomeCareProvider', result);
		System.assertEquals('STBeforeYouStart', result_non);
	}

	@isTest
	static void testSaveActiveForm() {
		Id caseId = [SELECT Id FROM Case WHERE Status = 'Submitted' LIMIT 1].Id;
		TestUserBuilder healthUserBuilder = QFRTestDataFactory.getHealthProviderBuilder();
		User healthUser = healthUserBuilder.createUser();

		String activeForm = 'ResidentialProviderFinancialPerformanceSurvey';

		Test.startTest();
		System.runAs(healthUser) {
			AcfrSidebarController.saveActiveForm(caseId, activeForm);
		}
		Test.stopTest();

		Case case_results = [
			SELECT Id, Active_Form__c
			FROM Case
			WHERE Id = :caseId
			LIMIT 1
		];

		System.assertEquals(
			'ResidentialProviderFinancialPerformanceSurvey',
			case_results.Active_Form__c
		);
	}
}
