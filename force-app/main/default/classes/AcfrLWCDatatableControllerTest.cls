/**
 * @Author        :Cla Capagas
 * @Company       :Accenture
 * @Description   : this class will test the functionality of AcfrLWCDatatableController
 * @Test Class    :
 * @Date:N/A
 * @Revision:
 * When                 Who               What
 * 07-Feb-2023          Cla Capagas       Created
 * 28-02-2023           Jhosua Arda       Modified
 */
@IsTest
public with sharing class AcfrLWCDatatableControllerTest {
	private static final string HOME_CARE = 'Home Care';
	private static final string HOME_CARE_VIABILITY = 'Home Care Viability and Prudential Reporting';

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
				//Incorporation_ID_Type__c = 'Not Incorporated',
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
				Type__c = HOME_CARE_VIABILITY,
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
			form.Type__c = HOME_CARE_VIABILITY;
			form.QA_Comments__c = 'None';
			form.RecordTypeId = Schema.SObjectType.Form__c.getRecordTypeInfosByDeveloperName()
				.get('QFR')
				.getRecordTypeId();
			insert form;

			Question_Category__c qc = new Question_Category__c(
				name = 'Cat1',
				External_Id__c = 'qc001',
				Type__c = HOME_CARE_VIABILITY
			);
			insert qc;

			List<Question_Library__c> qls = new List<Question_Library__c>();
			qls.add(
				new Question_Library__c(
					Question_Category__c = qc.id,
					QL_DM_Key__c = 'Q.HV.A.BSS.OTH001',
					Question__c = 'Business Improvement Fund?'
				)
			);
			qls.add(
				new Question_Library__c(
					Question_Category__c = qc.id,
					QL_DM_Key__c = 'Q.HV.A.SOL002',
					Question__c = 'solvecy next six months'
				)
			);
			insert qls;

			List<Response__c> responseList = new List<Response__c>();
			responseList.add(
				new Response__c(
					Form__c = form.id,
					Question_Library__c = qls[0].id,
					Care_or_Services__c = 'Clinical Care;Personal Care',
					Response_options__c = 'Yes',
					Additional_information__c = 'Test Only'
				)
			);
			responseList.add(
				new Response__c(
					Form__c = form.id,
					Question_Library__c = qls[1].id,
					Care_or_Services__c = 'Clinical Care;Personal Care;Allied Health;Diversional Therapy;Lifestyle/Recreation/Activities Officer;Other',
					Response_options__c = 'Yes',
					Additional_information__c = 'Test Only'
				)
			);
			insert responseList;

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
				Service_Line_Item__c = serviceLineItem1.Id
			);
			insert gLCodeLineItem;

			Financial_Reporting_Rule__c financialReportingRule = new Financial_Reporting_Rule__c(
				Hard_Validation__c = true,
				Form_Type__c = HOME_CARE_VIABILITY,
				Name = HOME_CARE_VIABILITY
			);
			insert financialReportingRule;

			Financial_Reporting_Rule_Exemption__c financialReportingRuleExemption = new Financial_Reporting_Rule_Exemption__c(
				Financial_Reporting_Rule__c = financialReportingRule.Id,
				Service__c = serviceLineItem1.Id,
				Form__c = form.Id,
				Rule_Exemption_Status__c = true
			);
			insert financialReportingRuleExemption;

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
	private static void getDatatableDefinitionForFormTest() {
		User adminUser = [
			SELECT Id
			FROM User
			WHERE UserName = 'testUser01@admin.com'
			LIMIT 1
		];
		Form__c fr = [SELECT Id FROM Form__c LIMIT 1];
		Test.startTest();
		System.runAs(adminUser) {
			QFRDatatableDefinition dataTableResult = AcfrLWCDatatableController.getDatatableDefinitionForForm(
				fr.Id
			);
			system.assertEquals(true, dataTableResult != null);
		}
		Test.stopTest();
	}

	@IsTest
	private static void getDatatableDefinitionForFormNegTest() {
		User adminUser = [
			SELECT Id
			FROM User
			WHERE UserName = 'testUser01@admin.com'
			LIMIT 1
		];
		Test.startTest();
		System.runAs(adminUser) {
			QFRDatatableDefinition qfrDef = new QFRDatatableDefinition();
			QFRDatatableDefinition dataTableResult = AcfrLWCDatatableController.getDatatableDefinitionForForm(
				null
			);
			system.assertEquals(
				true,
				dataTableResult.financialReportingRules.isEmpty()
			);
		}
		Test.stopTest();
	}

	@IsTest
	private static void updateCellsTest() {
		User adminUser = [
			SELECT Id
			FROM User
			WHERE UserName = 'testUser01@admin.com'
			LIMIT 1
		];
		List<GL_Code_Line_Item__c> glCodeLineItem = [
			SELECT Id, Value__c
			FROM GL_Code_Line_Item__c
			LIMIT 1
		];
		glCodeLineItem[0].Value__c = 10;
		String jsonstring = Json.serialize(glCodeLineItem);

		Test.startTest();
		System.runAs(adminUser) {
			AcfrLWCDatatableController.updateCells(jsonstring);
			system.assertEquals(10, glCodeLineItem[0].Value__c);
		}
		Test.stopTest();
	}

	@IsTest
	private static void updateCellsFailedTest() {
		Test.startTest();
		try {
			AcfrLWCDatatableController.updateServices(null);
			Assert.fail('An exception should have been thrown, skipping this.');
		} catch (Exception exc) {
			// no-op, test execution succeeded
		}
		Test.stopTest();
	}

	@IsTest
	private static void updateServicesTest() {
		User adminUser = [
			SELECT Id
			FROM User
			WHERE UserName = 'testUser01@admin.com'
			LIMIT 1
		];
		List<Service_Line_Item__c> serviceLineItems = [
			SELECT Id, Active__c
			FROM Service_Line_Item__c
			LIMIT 1
		];
		serviceLineItems[0].Active__c = true;
		String jsonstring = Json.serialize(serviceLineItems);

		Test.startTest();
		System.runAs(adminUser) {
			AcfrLWCDatatableController.updateServices(jsonstring);
			system.assertEquals(true, serviceLineItems[0].Active__c);
		}
		Test.stopTest();
	}

	@IsTest
	private static void updateServices_throws_on_null_input() {
		Test.startTest();
		try {
			AcfrLWCDatatableController.updateServices(null);
			Assert.fail('An exception should have been thrown, skipping this.');
		} catch (Exception exc) {
		}
		Test.stopTest();
	}

	@IsTest
	private static void getCrossFormRowDefinitionsTest() {
		User adminUser = [
			SELECT Id
			FROM User
			WHERE UserName = 'testUser01@admin.com'
			LIMIT 1
		];
		Form__c fr = [SELECT Id FROM Form__c LIMIT 1];
		List<string> glCodeIds = new List<string>{ 'Q00001', 'Q00002' };
		Test.startTest();
		System.runAs(adminUser) {
			Map<Id, QFRDatatableDefinition> dataTableResult = AcfrLWCDatatableController.getCrossFormRowDefinitions(
				fr.Id,
				glCodeIds
			);
			system.assertEquals(true, dataTableResult != null);
		}
		Test.stopTest();
	}

	@isTest
	static void testGetQFRGLCodeItemData() {
		List<GL_Code_Line_Item__c> glCodeLineItem = [
			SELECT Id
			FROM GL_Code_Line_Item__c
			LIMIT 1
		];
		List<GL_Code__c> testGLCode = [
			SELECT Business_Id__c
			FROM GL_Code__c
			LIMIT 1
		];
		User adminUser = [
			SELECT Id
			FROM User
			WHERE UserName = 'testUser01@admin.com'
			LIMIT 1
		];

		Case testCase = [SELECT Id FROM Case LIMIT 1];
		//List<GL_Code__c> testGlCode = [SELECT Id FROM GL_Code__c LIMIT 1];
		//List<Service_Line_Item__c> testServiceLineItems = [SELECT Service_Category__c FROM Service_Line_Item__c LIMIT 1];
		List<String> businessIds = new List<String>{ 'Q00001' };
		List<String> serviceNames = new List<String>{ 'Home Care' };

		// Call the method with test data
		List<GL_Code_Line_Item__c> result = AcfrLWCDatatableController.getQFRGLCodeItemData(
			businessIds,
			serviceNames,
			testCase.Id
		);

		System.debug('diri: ' + result);
		// Verify the result
		Test.startTest();
		System.runAs(adminUser) {
			System.assertEquals(1, result.size());
			System.assertEquals(glCodeLineItem[0].Id, result[0].Id);
			System.assertEquals(
				testGLCode[0].Business_ID__c,
				result[0].GL_Code__r.Business_ID__c
			);
		}
		Test.stopTest();
	}
}
