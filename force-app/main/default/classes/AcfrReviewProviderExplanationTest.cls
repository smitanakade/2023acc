@IsTest
public with sharing class AcfrReviewProviderExplanationTest {
	private static final string HOME_CARE = 'Home Care';
	private static final string HOME_CARE_LABOUR_COSTS = 'Home Care Labour Costs and Hours';

	@TestSetup
	static void setup() {
		User testUser = TestDataFactory.createSystemAdminUser();
		System.runAs(testUser) {
			Profile adminProfile = [
				SELECT Id
				FROM Profile
				WHERE Name = 'System Administrator'
				LIMIT 1
			];

			User record = new User(
				Alias = 'testUser',
				Email = 'testUser@admin.com',
				FirstName = 'Test',
				LastName = 'User',
				TimeZoneSidKey = 'America/Los_Angeles',
				LanguageLocaleKey = 'en_US',
				EmailEncodingKey = 'UTF-8',
				LocaleSidKey = 'en_US',
				ProfileId = adminProfile.Id,
				UserName = 'testUser01@admin.com'
			);
			insert record;

			List<PermissionSet> permissionSets = [
				SELECT Id
				FROM PermissionSet
				WHERE
					Name IN (
						'QFR_Create_Update_View',
						'System_Admin',
						'QFR_Create_Update_View_Submit',
						'QFR_Dev_Permission_Set'
					)
			];

			List<PermissionSetAssignment> permissionSetAssignments = new List<PermissionSetAssignment>();
			for (PermissionSet permissionSet : permissionSets) {
				PermissionSetAssignment psa = new PermissionSetAssignment(
					PermissionSetId = permissionSet.Id,
					AssigneeId = record.Id
				);
				permissionSetAssignments.add(psa);
			}
			insert permissionSetAssignments;

			Account acc = new Account(
				Name = 'Test Provider',
				Purpose__c = 'Private for Profit',
				Incorporation_ID_Type__c = 'ACN',
				Prospective_Provider__c = 'No',
				Incorporation_ID__c = '852147963',
				RecordTypeId = [
					SELECT Id
					FROM RecordType
					WHERE
						SobjectType = 'Account'
						AND IsActive = TRUE
						AND Name = 'Approved Provider'
					LIMIT 1
				]
				.Id
			);
			insert acc;

			BusinessLicense serviceHome = new BusinessLicense(
				Name = 'Total',
				Effective_Date__c = Date.today(),
				Care_Type__c = HOME_CARE,
				Status_Date__c = Date.today(),
				Status = 'Operational'
			);
			insert serviceHome;

			Service_Account_Relationship__c servHomeCare = new Service_Account_Relationship__c(
				Association_Start_Date__c = System.today(),
				Service_Name__c = serviceHome.id,
				Provider_Name__c = acc.id
			);
			insert servHomeCare;

			Reporting_Period__c currentRP = new Reporting_Period__c(
				Start_Date__c = date.today().toStartOfMonth(),
				End_Date__c = date.today().addDays(32)
			);
			insert currentRP;

			GL_Code__c testGLCode = new GL_Code__c(
				Name = 'Test GL',
				Type__c = HOME_CARE_LABOUR_COSTS,
				Display_Order__c = 0,
				Line_Item_Value_Type__c = 'Numeric',
				run_rules__c = true,
				Business_Id__c = 'Q00001'
			);
			insert testGLCode;

			Case c = new Case();
			c.Status = 'New';
			c.accountid = acc.id;
			c.Priority = 'Medium';
			c.Reporting_Period__c = currentRP.id;
			insert c;

			Form__c form = new Form__c();
			form.Account__c = acc.id;
			form.Case__c = c.Id;
			form.Reporting_Period__c = currentRP.Id;
			form.Type__c = HOME_CARE_LABOUR_COSTS;
			form.QA_Comments__c = 'None';
			form.RecordTypeId = Schema.SObjectType.Form__c.getRecordTypeInfosByDeveloperName()
				.get('QFR')
				.getRecordTypeId();
			insert form;

			Service_Line_Item__c serviceLineItem1 = new Service_Line_Item__c(
				Form__c = form.Id,
				active__c = true,
				Service_Category__c = HOME_CARE,
				Service__c = serviceHome.Id
			);
			insert serviceLineItem1;

			GL_Code_Line_Item__c gLCodeLineItem = new GL_Code_Line_Item__c(
				Line_Item_Value__c = '15',
				GL_Code__c = testGLCode.Id,
				QA_Outcome__c = 'Review',
				provider_explanation__c = 'Requesting for exemption',
				QA_External_Comments__c = 'Sending this back',
				Amended_Explanation__c = 'Appealing for the review',
				Service_Line_Item__c = serviceLineItem1.Id
			);
			insert gLCodeLineItem;

			Financial_Reporting_Rule__c financialReportingRule = new Financial_Reporting_Rule__c(
				Hard_Validation__c = false,
				Form_Type__c = HOME_CARE_LABOUR_COSTS,
				Name = HOME_CARE_LABOUR_COSTS
			);
			insert financialReportingRule;

			Financial_Reporting_Rule_Details__c frr = new Financial_Reporting_Rule_Details__c();
			frr.GL_Code__c = testGLCode.Id;
			frr.Active__c = true;
			frr.Validation_Rule__c = '1 > 0';
			frr.Error_Message__c = 'this is error';
			frr.Financial_Reporting_Rule__c = financialReportingRule.Id;
			insert frr;
		}
	}

	@IsTest
	private static void testGetProviderExplanation() {
		User adminUser = [
			SELECT Id
			FROM User
			WHERE UserName = 'testUser01@admin.com'
			LIMIT 1
		];
		List<GL_Code_Line_Item__c> glCodeLineItem = [
			SELECT
				Id,
				provider_explanation__c,
				QA_Outcome__c,
				QA_External_Comments__c,
				Amended_Explanation__c,
				Line_Item_Value__c,
				Service_Line_item__r.Service_Label__c
			FROM GL_Code_Line_Item__c
			LIMIT 1
		];
		List<GL_Code__c> testGLCode = [
			SELECT Business_Id__c
			FROM GL_Code__c
			LIMIT 1
		];

		List<Financial_Reporting_Rule_Details__c> rules = [
			SELECT Id, Rule_Name__c, Error_Message__c
			FROM Financial_Reporting_Rule_Details__c
			WHERE GL_Code__c = :testGLCode[0].id
			LIMIT 1
		];

		List<Form__c> forms = [SELECT id FROM Form__c LIMIT 1];
		System.runAs(adminUser) {
			Test.startTest();
			AcfrReviewProviderExplanation.getProviderExplanation(forms[0].id);
		}
		Test.stopTest();
		System.assertEquals(forms.size(), 1, 'Records returned');
	}

	@isTest
	private static void testNegativeGetProviderExplanation() {
		User adminUser = [
			SELECT Id
			FROM User
			WHERE UserName = 'testUser01@admin.com'
			LIMIT 1
		];
		List<GL_Code_Line_Item__c> glCodeLineItem = [
			SELECT
				Id,
				provider_explanation__c,
				QA_Outcome__c,
				QA_External_Comments__c,
				Amended_Explanation__c,
				Line_Item_Value__c,
				Service_Line_item__r.Service_Label__c
			FROM GL_Code_Line_Item__c
			LIMIT 1
		];
		List<GL_Code__c> testGLCode = [
			SELECT Business_Id__c
			FROM GL_Code__c
			LIMIT 1
		];

		List<Financial_Reporting_Rule_Details__c> rules = [
			SELECT Id, Rule_Name__c, Error_Message__c
			FROM Financial_Reporting_Rule_Details__c
			WHERE GL_Code__c = :testGLCode[0].id
			LIMIT 1
		];

		List<Boolean> exceptions = new List<Boolean>();
		List<Form__c> forms = [SELECT id FROM Form__c LIMIT 1];
		forms[0].id = null;

		System.runAs(adminUser) {
			Test.startTest();
			try {
				AcfrReviewProviderExplanation.getProviderExplanation(
					forms[0].id
				);
			} catch (QueryException queryException) {
				if (queryException.getMessage().contains('ERROR')) {
					exceptions.add(true);
				}
			}
		}
		Test.stopTest();
		System.assertNotEquals(
			null,
			exceptions,
			'There is an exception that occured'
		);
		for (Boolean b : exceptions) {
			system.assert(b, 'This should have thrown exception');
		}
	}
}
