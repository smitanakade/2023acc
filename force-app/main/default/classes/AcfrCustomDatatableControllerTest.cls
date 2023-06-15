@IsTest
public with sharing class AcfrCustomDatatableControllerTest {
	@TestSetup
	static void setup() {
		List<BusinessLicense> services = new List<BusinessLicense>();
		for (Integer i = 0; i < 5; i++) {
			services.add(
				new BusinessLicense(
					Name = 'Test Service ' + i,
					Effective_Date__c = Date.today(),
					Status_Date__c = Date.today(),
					//Care_Type__c = 'Residential Care',
					Care_Type__c = 'Residential', //Modified by CJJOYA 20012023
					Status = 'Approved'
				)
			);
		}
		services.add(
			new BusinessLicense(
				Name = 'Total',
				Effective_Date__c = Date.today(),
				Status_Date__c = Date.today(),
				//Care_Type__c = 'Residential Care',
				Care_Type__c = 'Residential', //Modified by CJJOYA 20012023
				Status = 'Approved'
			)
		);
		insert services;
		Account acc = TestDataFactory.createProviderRecords(1)[0];
		insert acc;
		Case qfrCase = new Case(
			Status = 'New',
			Priority = 'Medium',
			AccountId = acc.Id
		);
		insert qfrCase;

		Form__c form = new Form__c(
			Type__c = 'Home Care Labour Costs and Hours',
			Account__c = acc.Id,
			QA_Outcome__c = 'Accepted',
			QA_Comments__c = 'test',
			Case__c = qfrCase.Id,
			RecordTypeId = Schema.SObjectType.Form__c.getRecordTypeInfosByDeveloperName()
				.get('QFR')
				.getRecordTypeId()
		);
		insert form;
		List<GL_Code__c> testGLCodes = new List<GL_Code__c>();
		testGLCodes.add(
			new GL_Code__c(
				Name = 'Test GL',
				Type__c = 'Home Care Labour Costs and Hours',
				Display_Order__c = 0,
				Line_Item_Value_Type__c = 'Picklist',
				Line_Item_Value_Options__c = 'Cook freeze;Cook fresh',
				Business_Id__c = 'TEST1'
			)
		);
		testGLCodes.add(
			new GL_Code__c(
				Name = 'Test GL 2',
				Type__c = 'Residential Labour Costs and Hours',
				Display_Order__c = 0,
				Line_Item_Value_Type__c = 'Numeric',
				Business_Id__c = 'TEST2'
			)
		);
		insert testGLCodes;
		insert new List<Service_Line_Item__c>{
			new Service_Line_Item__c(
				Service__c = services[0].Id,
				Form__c = form.Id
			),
			new Service_Line_Item__c(
				Service__c = services[services.size() - 1].Id, // add Total Service Line Item
				Form__c = form.Id
			)
		};
	}

	@IsTest
	private static void it_throws_if_invalid_method_given() {
		Boolean didThrow = false;
		Map<String, Object> input = new Map<String, Object>();
		Map<String, Object> output = new Map<String, Object>();
		Map<String, Object> options = new Map<String, Object>();

		TestUserBuilder healthUserBuilder = getHealthProviderBuilder();
		User healthUser = healthUserBuilder.createUser();

		Test.startTest();
		System.runAs(healthUser) {
			try {
				new AcfrCustomDatatableController()
					.invokeMethod('1invalid', input, output, options);
			} catch (AcfrCustomDatatableController.AcfrCustomDatatableException exc) {
				if (
					exc.getMessage() ==
					'Specified action not supported' // confirm correct exception thrown
				) {
					didThrow = true;
				}
			}
		}
		Test.stopTest();
		System.assertEquals(true, didThrow);
	}

	@IsTest
	private static void it_gets_datatable_definition_matching_form() {
		List<BusinessLicense> services = [SELECT Id FROM BusinessLicense];
		Form__c form = [
			SELECT Id
			FROM Form__c
			WHERE Type__c = 'Home Care Labour Costs and Hours'
			LIMIT 1
		];

		TestUserBuilder healthUserBuilder = getHealthProviderBuilder();
		User healthUser = healthUserBuilder.createUser();

		for (BusinessLicense service : services) {
			service.OwnerId = healthUser.Id;
		}
		update services;

		QFRDatatableDefinition datatableDef;
		Test.startTest();
		System.runAs(healthUser) {
			datatableDef = AcfrLWCDatatableController.getDatatableDefinitionForForm(
				form.Id
			);
		}
		Test.stopTest();
		System.assertNotEquals(null, datatableDef);
		System.assertEquals(1, datatableDef.rowDefinitions.size());
		// System.assertEquals(2, datatableDef.columnDefinitions.size());
		// System.assertEquals('Total', datatableDef.columnDefinitions[0].name); // Total column should be first one
	}

	@IsTest
	private static void getDatatableDefinition_returns_empty_definition_if_id_null() {
		TestUserBuilder healthUserBuilder = getHealthProviderBuilder();
		User healthUser = healthUserBuilder.createUser();
		QFRDatatableDefinition datatableDef;
		Test.startTest();
		System.runAs(healthUser) {
			datatableDef = AcfrLWCDatatableController.getDatatableDefinitionForForm(
				null
			);
		}
		Test.stopTest();
		System.assertNotEquals(null, datatableDef);
		System.assertEquals(0, datatableDef.rowDefinitions.size());
		System.assertEquals(0, datatableDef.columnDefinitions.size());
	}

	@IsTest
	private static void invoke_callable_getDatatableDefinitionForForm_calls_correct_method() {
		Form__c form = [
			SELECT Id
			FROM Form__c
			WHERE Type__c = 'Home Care Labour Costs and Hours'
			LIMIT 1
		];
		Map<String, Object> input = new Map<String, Object>{
			'formId' => form.Id
		};
		Map<String, Object> output = new Map<String, Object>();
		Map<String, Object> options = new Map<String, Object>();

		TestUserBuilder healthUserBuilder = getHealthProviderBuilder();
		User healthUser = healthUserBuilder.createUser();

		QFRDatatableDefinition datatableDef;
		Test.startTest();
		System.runAs(healthUser) {
			new AcfrCustomDatatableController()
				.invokeMethod(
					'getDatatableDefinitionForForm',
					input,
					output,
					options
				);
			datatableDef = AcfrLWCDatatableController.getDatatableDefinitionForForm(
				form.Id
			);
		}

		Test.stopTest();
		System.assertNotEquals(null, datatableDef);
		QFRDatatableDefinition outputDatatableDef = (QFRDatatableDefinition) output.get(
			'datatableDefinition'
		);
		// System.assertEquals(2, outputDatatableDef.columnDefinitions.size());
		System.assertEquals(
			datatableDef.rowDefinitions.size(),
			outputDatatableDef.rowDefinitions.size()
		);
	}

	@IsTest
	private static void getCrossRowFormDefinitions_returns_additional_data() {
		Form__c form = [
			SELECT Id, Case__c, Account__c
			FROM Form__c
			WHERE Type__c = 'Home Care Labour Costs and Hours'
			LIMIT 1
		];
		Form__c form2 = new Form__c(
			Type__c = 'Residential Labour Costs and Hours',
			Account__c = form.Account__c,
			QA_Outcome__c = 'Accepted',
			Reasonableness_Check_Outcome__c = 'No review required',
			QA_Comments__c = 'test',
			Case__c = form.Case__c
		);
		insert form2;

		List<String> additionalGlCodeBusinessIds = new List<String>{ 'TEST2' };

		Map<String, Object> input = new Map<String, Object>{
			'formId' => form.Id,
			'glCodeBusinessIds' => additionalGLCodeBusinessIds
		};
		Map<String, Object> output = new Map<String, Object>();
		Map<String, Object> options = new Map<String, Object>();

		TestUserBuilder healthUserBuilder = getHealthProviderBuilder();
		User healthUser = healthUserBuilder.createUser();

		Test.startTest();
		System.runAs(healthUser) {
			new AcfrCustomDatatableController()
				.invokeMethod(
					'getCrossFormRowDefinitions',
					input,
					output,
					options
				);
		}
		Test.stopTest();

		List<QFRDatatableDefinition> outputDatatableDefs = (List<QFRDatatableDefinition>) output.get(
			'datatableDefinitions'
		);
		System.assertNotEquals(null, outputDatatableDefs);
		System.assertEquals(1, outputDatatableDefs.size());
		System.assertEquals(1, outputDatatableDefs[0].rowDefinitions.size());
		// System.assertEquals(2, outputDatatableDef.rowDefinitions[0].lineItemValueOptions.size());
		// System.assertEquals(2, outputDatatableDef.columnDefinitions.size());
		// System.assertEquals('Total', outputDatatableDef.columnDefinitions[0].name); // Total column should be first one
	}
	@IsTest
	private static void it_updates_line_items_correctly() {
		// ARRANGE
		List<GL_Code_Line_Item__c> updates = [
			SELECT Id
			FROM GL_Code_Line_Item__c
		];
		for (GL_Code_Line_Item__c u : updates) {
			u.Value__c = 150;
		}
		Map<String, Object> input = new Map<String, Object>{
			'glCodeLineItemJson' => JSON.serialize(updates)
		};
		Map<String, Object> output = new Map<String, Object>();
		Map<String, Object> options = new Map<String, Object>();

		TestUserBuilder healthUserBuilder = getHealthProviderBuilder();
		User healthUser = healthUserBuilder.createUser();
		List<Form__c> forms = [SELECT Id FROM Form__c];
		for (Form__c form : forms) {
			form.OwnerId = healthUser.Id;
		}
		//update forms;

		// ACT
		Test.startTest();
		System.runAs(healthUser) {
			new AcfrCustomDatatableController()
				.invokeMethod('updateCells', input, output, options);
		}
		Test.stopTest();

		// ASSERT
		updates = [SELECT Id, Value__c FROM GL_Code_Line_Item__c];
		for (GL_Code_Line_Item__c lineItem : updates) {
			System.assertEquals(150, lineItem.Value__c);
		}
	}

	@IsTest
	private static void it_updates_services_correctly() {
		List<Service_Line_Item__c> services = [
			SELECT Id
			FROM Service_Line_Item__c
		];
		List<Form__c> forms = [SELECT Id FROM Form__c];

		// defaults to true
		for (Service_Line_Item__c service : services) {
			service.Active__c = false;
		}
		Map<String, Object> input = new Map<String, Object>{
			'servicesJson' => JSON.serialize(services)
		};
		Map<String, Object> output = new Map<String, Object>();
		Map<String, Object> options = new Map<String, Object>();
		TestUserBuilder healthUserBuilder = getHealthProviderBuilder();
		User healthUser = healthUserBuilder.createUser();

		List<Case> cases = [SELECT Id FROM Case];
		for (Case c : cases) {
			c.AccountId = healthUser.AccountId;
		}
		update cases;

		Test.startTest();

		System.runAs(healthUser) {
			new AcfrCustomDatatableController()
				.invokeMethod('updateServices', input, output, options);
		}
		Test.stopTest();
		services = [
			SELECT Id, Active__c
			FROM Service_Line_Item__c
			WHERE Id IN :services
		];
		for (Service_Line_Item__c lineItem : services) {
			// System.assertEquals(false, lineItem.Active__c);
		}
	}

	private static TestUserBuilder getHealthProviderBuilder() {
		List<PermissionSet> permissionSets = [
			SELECT Id
			FROM PermissionSet
			WHERE Name IN ('QFR_Report_Create_Update_and_Submit')
		];
		PermissionSetLicense permissionSetLicenses = [
			SELECT Id
			FROM PermissionSetLicense
			WHERE PermissionSetLicenseKey = 'PublicSectorAccessPSL'
		];
		Id profileId = [
			SELECT Id
			FROM Profile
			WHERE Name = 'System Administrator'
		]
		.Id;
		TestUserBuilder healthProviderBuilder = new TestUserBuilder();
		healthProviderBuilder.setUserProfile(profileId);
		healthProviderBuilder.setDoInsert(true);
		healthProviderBuilder.setPermissionSets(permissionSets);
		healthProviderBuilder.setPermissionSetLicenses(
			new List<PermissionSetLicense>{ permissionSetLicenses }
		);
		// healthProviderBuilder.setPortalUser();
		return healthProviderBuilder;
	}
}
