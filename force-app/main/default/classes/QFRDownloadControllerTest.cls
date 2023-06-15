@IsTest
private class QFRDownloadControllerTest {
	@TestSetup
	static void setup() {
		User testUser = TestDataFactory.createSystemAdminUser();
		System.runAs(testUser) {
			List<BusinessLicense> services = new List<BusinessLicense>();
			for (Integer i = 0; i < 5; i++) {
				services.add(
					new BusinessLicense(
						Name = 'Test Service ' + i,
						Effective_Date__c = Date.today(),
						Status_Date__c = Date.today(),
						Care_Type__c = 'Residential',
						Status = 'Approved'
					)
				);
			}
			services.add(
				new BusinessLicense(
					Name = 'Total',
					Effective_Date__c = Date.today(),
					Status_Date__c = Date.today(),
					Care_Type__c = 'Residential',
					Status = 'Approved'
				)
			);
			insert services;
			Account acc = TestDataFactory.createProviderRecords(1)[0]; // create one, get first entry
			insert acc;

			Contact con1 = new Contact(
				FirstName = '2',
				LastName = 'Test',
				Salutation = 'Ms',
				Email = 'test@gmail.com'
			);
			insert con1;

			Contact_Relationship__c cr1 = new Contact_Relationship__c(
				Account__c = acc.Id,
				Contact__c = con1.Id,
				Role__c = 'QFR Primary Contact'
			);
			insert cr1;

			Case tc = new Case(
				AccountId = acc.Id,
				Status = 'Submitted',
				RecordTypeId = [
					SELECT Id
					FROM RecordType
					WHERE SObjectType = 'Case' AND DeveloperName = 'QFR'
					LIMIT 1
				]
				.Id
			);
			insert tc;

			Form__c form = new Form__c(
				Type__c = 'Home Care Labour Costs and Hours',
				Account__c = acc.Id,
				Case__c = tc.Id,
				QA_Comments__c = 'None',
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
					Line_Item_Value_Type__c = 'Numeric'
				)
			);
			testGLCodes.add(
				new GL_Code__c(
					Name = 'Test GL 2',
					Type__c = 'Residential Labour Costs and Hours',
					Display_Order__c = 0,
					Line_Item_Value_Type__c = 'Numeric'
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
	}

	@IsTest
	static void it_gets_forms_for_case() {
		// ARRANGE

		Map<String, Object> input = new Map<String, Object>{
			//'caseId' => [SELECT Id FROM Case LIMIT 1].Id  //Modified by CJJOYA 20012023
			'caseId' => [SELECT Id FROM Case WHERE Status = 'Submitted' LIMIT 1]
			.Id
		};
		Map<String, Object> output = new Map<String, Object>();
		Map<String, Object> options = new Map<String, Object>();

		TestUserBuilder healthUserBuilder = getHealthProviderBuilder();
		User healthUser = healthUserBuilder.createUser();
		List<Form__c> forms = [SELECT Id FROM Form__c];
		for (Form__c form : forms) {
			form.OwnerId = healthUser.Id;
		}
		update forms;
		// ACT
		Test.startTest();

		System.runAs(healthUser) {
			new QFRDownloadController()
				.invokeMethod('getFormIdsForCase', input, output, options);
		}
		Test.stopTest();
		List<Object> result = (List<Object>) output.get('formDetails');
		System.assertEquals(1, result.size());
	}

	@IsTest
	static void it_gets_responses_for_form() {
		// ARRANGE

		Map<String, Object> input = new Map<String, Object>{
			'formId' => [SELECT Id FROM Form__c LIMIT 1]
			.Id
		};
		Map<String, Object> output = new Map<String, Object>();
		Map<String, Object> options = new Map<String, Object>();

		TestUserBuilder healthUserBuilder = getHealthProviderBuilder();
		User healthUser = healthUserBuilder.createUser();
		List<Form__c> forms = [SELECT Id FROM Form__c];
		for (Form__c form : forms) {
			form.OwnerId = healthUser.Id;
		}
		update forms;
		// ACT
		Test.startTest();

		System.runAs(healthUser) {
			new QFRDownloadController()
				.invokeMethod('getViabilityForm', input, output, options);
		}
		Test.stopTest();
		List<Object> result = (List<Object>) output.get('responses');
		System.assertEquals(0, result.size());
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
		Id profileId = [SELECT Id FROM Profile WHERE Name = 'VS Administrator']
		.Id;
		TestUserBuilder healthProviderBuilder = new TestUserBuilder();
		healthProviderBuilder.setUserProfile(profileId);
		healthProviderBuilder.setDoInsert(true);
		healthProviderBuilder.setPermissionSets(permissionSets);
		healthProviderBuilder.setPermissionSetLicenses(
			new List<PermissionSetLicense>{ permissionSetLicenses }
		);
		//healthProviderBuilder.setPortalUser();
		return healthProviderBuilder;
	}
}
