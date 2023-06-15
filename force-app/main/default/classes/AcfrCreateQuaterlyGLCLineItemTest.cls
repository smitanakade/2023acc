/**
 * @description       :
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             :
 * @last modified on  : 03-01-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 **/
@IsTest
public with sharing class AcfrCreateQuaterlyGLCLineItemTest {
	@TestSetup
	static void setup() {
		User testUser = TestDataFactory.createSystemAdminUser(); // Added by Jhosua Arda 20/01/2023
		System.runAs(testUser) {
			// Added by Jhosua Arda 20/01/2023
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
				TimeZoneSidKey = 'Australia/Sydney',
				LanguageLocaleKey = 'en_US',
				EmailEncodingKey = 'UTF-8',
				LocaleSidKey = 'en_AU',
				ProfileId = adminProfile.Id,
				UserName = 'testUser01@admin.com'
			);
			insert record;

			//Account
			Account acc = new Account(
				Name = 'Test Account Company',
				Purpose__c = 'Government',
				Incorporated_Under__c = 'Associations Act 2008 (NT)',
				Incorporation_Status__c = 'Registered',
				Incorporation_ID_Type__c = 'Other',
				Prospective_Provider__c = 'No',
				Incorporation_ID__c = '1222211111',
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

			//Service

			List<BusinessLicense> services = new List<BusinessLicense>();
			{
				//for (Integer i = 0; i < 5; i++)
				services.add(
					new BusinessLicense(
						Name = 'Test Service ',
						Effective_Date__c = Date.today(),
						Status_Date__c = Date.today(),
						Care_Type__c = 'Residential',
						Status = 'Operational',
						AccountId = acc.id
					)
				);
			}
			services.add(
				new BusinessLicense(
					Name = 'Total',
					Effective_Date__c = Date.today(),
					Status_Date__c = Date.today(),
					Care_Type__c = 'Home Care',
					Status = 'Operational'
				)
			);
			insert services;

			//Service Account Relationship
			List<Service_Account_Relationship__c> serviceRelations = new List<Service_Account_Relationship__c>();
			Service_Account_Relationship__c servResiCare = new Service_Account_Relationship__c(
				Association_Start_Date__c = System.today(),
				Service_Name__c = services[0]?.id,
				Provider_Name__c = acc.id
			);

			serviceRelations.add(servResiCare);
			Service_Account_Relationship__c servHomeCare = new Service_Account_Relationship__c(
				Association_Start_Date__c = System.today(),
				Service_Name__c = services[1]?.id,
				Provider_Name__c = acc.id
			);
			serviceRelations.add(servHomeCare);
			insert serviceRelations;

			//Reporting Period
			Reporting_Period__c currentRP = new Reporting_Period__c(
				Start_Date__c = date.today().toStartOfMonth(),
				End_Date__c = date.today().addDays(32)
			);
			insert currentRP;

			//GL Codes
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

			//Cases
			List<Case> cases = new List<Case>();
			cases.add(
				new Case(
					Status = 'New',
					accountid = acc.id,
					Priority = 'Medium',
					Reporting_Period__c = currentRP.id
				)
			);
			insert cases;

			//Forms
			List<Form__c> forms = new List<Form__c>();
			forms.add(
				new Form__c(
					Account__c = acc.id,
					Case__c = cases[0].Id,
					Reporting_Period__c = currentRP.id,
					Type__c = 'Residential Labour Costs and Hours',
					QA_Comments__c = 'None',
					RecordTypeId = Schema.SObjectType.Form__c.getRecordTypeInfosByDeveloperName()
						.get('QFR')
						.getRecordTypeId()
				)
			);
			forms.add(
				new Form__c(
					Account__c = acc.id,
					Case__c = cases[0].Id,
					Reporting_Period__c = currentRP.id,
					Type__c = 'Residential Viability and Prudential Reporting',
					QA_Comments__c = 'None',
					QA_Outcome__c = 'Re-Issue',
					RecordTypeId = Schema.SObjectType.Form__c.getRecordTypeInfosByDeveloperName()
						.get('QFR')
						.getRecordTypeId()
				)
			);
			forms.add(
				new Form__c(
					Account__c = acc.id,
					Case__c = cases[0].Id,
					Reporting_Period__c = currentRP.id,
					Type__c = 'Residential Food and Nutrition Reporting',
					QA_Comments__c = 'None',
					QA_Outcome__c = 'Re-Issue',
					RecordTypeId = Schema.SObjectType.Form__c.getRecordTypeInfosByDeveloperName()
						.get('QFR')
						.getRecordTypeId()
				)
			);

			insert forms;

			//Service LineItems
			List<Service_Line_Item__c> serviceLineItems = new List<Service_Line_Item__c>();
			serviceLineItems.add(
				new Service_Line_Item__c(
					Form__c = forms[0]?.Id,
					Service__c = services[0]?.Id,
					Service_Category__c = 'Home Care',
					Active__c = true
				)
			);
			serviceLineItems.add(
				new Service_Line_Item__c(
					Form__c = forms[0].Id,
					Service__c = services[1]?.Id,
					Service_Category__c = 'Residential',
					Active__c = true
				)
			);
			serviceLineItems.add(
				new Service_Line_Item__c(
					Form__c = forms[2].Id,
					Service__c = services[1]?.Id,
					Service_Category__c = 'Residential',
					Active__c = true
				)
			);
			serviceLineItems.add(
				new Service_Line_Item__c(
					Form__c = forms[2].Id,
					Service__c = null,
					Service_Category__c = 'Total',
					Active__c = true,
					Service_Region__c = null
				)
			);
			insert serviceLineItems;
		} // Added by Jhosua Arda 20/01/2023
	}

	@IsTest
	private static void createFormsGLCodeLineItems() {
		User adminUser = [
			SELECT Id
			FROM User
			WHERE UserName = 'testUser01@admin.com'
			LIMIT 1
		];
		System.runAs(adminUser) {
			Test.startTest();
			AcfrCreateQuaterlyGLCLineItemScheduler acfrGLC = new AcfrCreateQuaterlyGLCLineItemScheduler();
			Database.executeBatch(acfrGLC);
		}
		Test.stopTest();
		List<GL_Code_Line_Item__c> glcLineItems = [
			SELECT Id
			FROM GL_Code_Line_Item__c
		];

		//Ensure records were created
		System.assertNotEquals(
			glcLineItems.size(),
			0,
			'List should not be empty'
		);
	}

	@IsTest
	private static void createFormsGLCodeLineItemsAdditionalServices() {
		User adminUser = [
			SELECT Id
			FROM User
			WHERE UserName = 'testUser01@admin.com'
			LIMIT 1
		];
		System.runAs(adminUser) {
			Test.startTest();
			List<BusinessLicense> services = [SELECT id FROM BusinessLicense];
			system.debug('servicesssss: ' + services);

			AcfrCreateQuaterlyCasesAndFormsService acfrService = new AcfrCreateQuaterlyCasesAndFormsService();
		}
		Test.stopTest();
		List<Service_Line_Item__c> srvLineItems = [
			SELECT Id
			FROM Service_Line_Item__c
		];

		//Ensure records were created
		System.assertNotEquals(
			srvLineItems.size(),
			0,
			'List should not be empty'
		);
	}
}
