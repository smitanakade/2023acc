/**
 * @description       :
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             :
 * @last modified on  : 03-28-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 **/
@IsTest
public with sharing class AcfrCreateQuaterlyCasesAndFormsTest {
	@TestSetup
	static void setup() {
		Integer recordCount = 2; //Added by CJJoya 21022023
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
				Incorporation_ID__c = String.valueOf(
					(Integer) (Math.random() * 1000000000)
				),
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

			//List<BusinessLicense> services = TestDataFactory.createServiceRecords(recordCount);
			List<BusinessLicense> services = new List<BusinessLicense>();
			services.add(
				new BusinessLicense(
					Name = 'Total',
					Effective_Date__c = Date.today(),
					Care_Type__c = 'Home Care',
					Status__c = 'Operational',
					Service_Care_Sub_Type__c = null,
					Status_Date__c = Date.today()
				)
			);
			services.add(
				new BusinessLicense(
					Name = 'Test Service ',
					Effective_Date__c = Date.today(),
					Care_Type__c = 'Residential',
					Status__c = 'Operational',
					AccountId = acc.id,
					Service_Care_Sub_Type__c = null,
					Status_Date__c = Date.today()
				)
			);
			insert services;

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

			Reporting_Period__c currentRP = new Reporting_Period__c(
				Start_Date__c = date.today().toStartOfMonth(),
				End_Date__c = date.today().addDays(32),
				Type__c = 'Quarter'
			);
			insert currentRP;

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
			Integer i = 1;
			for (BusinessLicense ServiceTest : services) {
				Address__c add = new Address__c(
					Street__c = 'LEVEL 44, 444 Building, 444 COLLINS STREET STREET, MELBOURNE, VIC, 3000',
					Building_Name__c = '4444 Building ' + i,
					CGIS_Override__c = false,
					City__c = 'MELBOURNE',
					Country__c = 'Australia',
					State_Province__c = 'VIC',
					Zip_Postal_Code__c = '3000'
				);
				insert add;

				Geospatial_Information__c geoInfo = new Geospatial_Information__c(
					Address__c = add.id,
					Layer_Id__c = 0,
					Name = 'Aged Care Planning Regions',
					Description__c = 'Test region' + i
				);
				insert geoInfo;

				Address_Location__c addLoc = new Address_Location__c(
					Address__c = add.Id,
					Service__c = ServiceTest.Id,
					Location_Type__c = 'Postal' //Modified by CJJOya 14042023
				);
				insert addLoc;
				i++;
			}
		}
	} // Added by Jhosua Arda 20/01/2023

	@IsTest
	private static void createWithAccountListBatchTest() {
		User adminUser = [
			SELECT Id
			FROM User
			WHERE UserName = 'testUser01@admin.com'
			LIMIT 1
		];
		List<Account> acc = [SELECT Id FROM Account];
		Test.startTest();
		System.runAs(adminUser) {
			AcfrCreateQuaterlyCasesAndFormsScheduler acfrCaseForms = new AcfrCreateQuaterlyCasesAndFormsScheduler(
				acc
			);
			Database.executeBatch(acfrCaseForms);
		}
		Test.stopTest();
		List<Case> newcases = [SELECT Id FROM Case];

		System.assertEquals(newcases.size(), 1);
	}

	@IsTest
	private static void createWithAccountListClassTest() {
		User adminUser = [
			SELECT Id
			FROM User
			WHERE UserName = 'testUser01@admin.com'
			LIMIT 1
		];
		List<Account> acc = [SELECT Id, Integration_ID__c, Name FROM Account];
		for (BusinessLicense item : [SELECT Id, Status FROM BusinessLicense]) {
			System.debug('BusinessLicense >> ' + JSON.serialize(item));
		}

		Test.startTest();
		System.runAs(adminUser) {
			AcfrCreateQuaterlyCasesAndFormsService createCasesAndForms = new AcfrCreateQuaterlyCasesAndFormsService(
				acc
			);
			System.debug(
				'createCasesAndForms >> ' + JSON.serialize(createCasesAndForms)
			);
			List<Case> cases = createCasesAndForms.performAction();
			System.debug('cases >> ' + JSON.serialize(cases));
			createCasesAndForms.performActionForGLCodeLineItems();
		}
		Test.stopTest();
		List<Form__c> newForms = [SELECT Id FROM Form__c];

		System.assertEquals(newForms.size(), 4);
	}

	@IsTest
	private static void createCasesTest() {
		User adminUser = [
			SELECT Id
			FROM User
			WHERE UserName = 'testUser01@admin.com'
			LIMIT 1
		];

		Test.startTest();
		System.runAs(adminUser) {
			AcfrCreateQuaterlyCasesAndFormsScheduler acfrCaseForms = new AcfrCreateQuaterlyCasesAndFormsScheduler();
			Database.executeBatch(acfrCaseForms);
		}
		Test.stopTest();
		List<Case> newcases = [SELECT Id FROM Case];

		System.assertEquals(newcases.size(), 1);
	}

	@IsTest
	private static void createFormsTest() {
		User adminUser = [
			SELECT Id
			FROM User
			WHERE UserName = 'testUser01@admin.com'
			LIMIT 1
		];

		Test.startTest();
		System.runAs(adminUser) {
			AcfrCreateQuaterlyCasesAndFormsScheduler acfrCaseForms = new AcfrCreateQuaterlyCasesAndFormsScheduler();
			Database.executeBatch(acfrCaseForms);
		}
		Test.stopTest();
		List<Form__c> newForms = [SELECT Id FROM Form__c];

		System.assertEquals(newForms.size(), 4);
	}

	@IsTest
	private static void createFormsSLI() {
		User adminUser = [
			SELECT Id
			FROM User
			WHERE UserName = 'testUser01@admin.com'
			LIMIT 1
		];

		Test.startTest();
		System.runAs(adminUser) {
			AcfrCreateQuaterlyCasesAndFormsScheduler acfrSLI = new AcfrCreateQuaterlyCasesAndFormsScheduler();
			Database.executeBatch(acfrSLI);
		}
		Test.stopTest();
		List<Service_Line_item__c> newSLI = [
			SELECT Id
			FROM Service_Line_item__c
			LIMIT 1
		];

		System.assertEquals(newSLI.size(), 1);
	}
	@IsTest
	private static void addMissingServiceDeDupe() {
		User adminUser = [
			SELECT Id
			FROM User
			WHERE UserName = 'testUser01@admin.com'
			LIMIT 1
		];
		Test.startTest();
		System.runAs(adminUser) {
			AcfrCreateQuaterlyCasesAndFormsScheduler acfrSLI = new AcfrCreateQuaterlyCasesAndFormsScheduler();
			Database.executeBatch(acfrSLI);
		}
		Test.stopTest();

		System.runAs(adminUser) {
			List<Account> acc = [SELECT Id FROM Account LIMIT 1];
			List<Case> newcases = [
				SELECT Id
				FROM Case
				WHERE AccountId = :acc[0].Id
			];
			List<BusinessLicense> shc = TestDataFactory.createServiceRecords(1);
			insert shc;

			Address__c add = new Address__c(
				Street__c = 'LEVEL 44, 444 Building, 444 COLLINS STREET STREET, MELBOURNE, VIC, 3000',
				Building_Name__c = '4444 Building',
				CGIS_Override__c = false,
				City__c = 'MELBOURNE',
				State_Province__c = 'VIC',
				Country__c = 'Australia',
				Zip_Postal_Code__c = '3000'
			);
			insert add;

			Geospatial_Information__c geoInfo = new Geospatial_Information__c(
				Address__c = add.id,
				Layer_Id__c = 0,
				Name = 'Aged Care Planning Regions',
				Description__c = 'Test region'
			);
			insert geoInfo;

			Address_Location__c addLoc = new Address_Location__c(
				Address__c = add.Id,
				Service__c = shc[0].Id,
				Location_Type__c = 'Postal' //Modified by CJJOya 14042023
			);
			insert addLoc;

			Service_Account_Relationship__c servHomeCareAdd = new Service_Account_Relationship__c(
				Association_Start_Date__c = System.today(),
				Service_Name__c = shc[0]?.id,
				Provider_Name__c = acc[0]?.id
			);
			insert servHomeCareAdd;

			AcfrCreateQuaterlyCasesAndFormsService caseAndFormsService = new AcfrCreateQuaterlyCasesAndFormsService();
			caseAndFormsService.generateRecordsForAdditionalServices(
				newcases[0]?.Id,
				shc[0]?.Id,
				null
			);

			List<Service_Line_item__c> newSLI = [
				SELECT Id
				FROM Service_Line_item__c
				LIMIT 1
			];
			//Ensure records were created

			System.assertEquals(newSLI.size(), 1);
		}
	}

	@IsTest
	private static void testVerifyServiceRegionsCreated() {
		List<Account> accountList = TestDataFactory.createProviderRecords(2);
		insert accountList;

		//Create 2 new HC services
		List<BusinessLicense> services = new List<BusinessLicense>();
		services.add(
			new BusinessLicense(
				Name = 'HC2',
				Effective_Date__c = Date.today(),
				Care_Type__c = 'Home Care',
				Status__c = 'Operational',
				Service_Care_Sub_Type__c = null,
				Status_Date__c = Date.today()
			)
		);
		services.add(
			new BusinessLicense(
				Name = 'HC3',
				Effective_Date__c = Date.today(),
				Care_Type__c = 'Home Care',
				Status__c = 'Operational',
				Service_Care_Sub_Type__c = null,
				Status_Date__c = Date.today()
			)
		);
		insert services;

		//Create 2 new SAR to services and account
		Service_Account_Relationship__c servHomeCare1 = new Service_Account_Relationship__c(
			Association_Start_Date__c = System.today(),
			Service_Name__c = services[0]?.id,
			Provider_Name__c = accountList[0]?.id
		);
		insert servHomeCare1;
		Service_Account_Relationship__c servHomeCare2 = new Service_Account_Relationship__c(
			Association_Start_Date__c = System.today(),
			Service_Name__c = services[1]?.id,
			Provider_Name__c = accountList[1]?.id
		);
		insert servHomeCare2;

		Address__c addr1 = new Address__c(
			Street__c = 'Collins Street',
			Building_Name__c = 'Test1',
			CGIS_Override__c = false,
			City__c = 'Melbourne',
			State_Province__c = 'VIC',
			Country__c = 'Australia',
			Zip_postal_code__c = '3001'
		);
		insert addr1;

		Address__c addr2 = new Address__c(
			Street__c = 'Burke Street',
			Building_Name__c = 'Test2',
			CGIS_Override__c = false,
			City__c = 'Docklands',
			State_Province__c = 'VIC',
			Country__c = 'Australia',
			Zip_postal_code__c = '3008'
		);
		insert addr2;

		Geospatial_Information__c geoInfo1 = new Geospatial_Information__c(
			Address__c = addr1.Id,
			Layer_Id__c = 0,
			Description__c = 'Melbourne ',
			Name = 'Aged Care Planning Regions'
		);
		insert geoInfo1;

		Geospatial_Information__c geoInfo2 = new Geospatial_Information__c(
			Address__c = addr2.Id,
			Layer_Id__c = 2,
			Description__c = 'Docklands ',
			Name = 'Aged Care Planning Regions'
		);
		insert geoInfo2;

		Address_location__c adLoc1 = new Address_Location__c(
			Address__c = addr2?.Id,
			service__c = services[0]?.Id,
			Location_Type__c = 'Physical'
		);
		insert adLoc1;
		Address_location__c adLoc2 = new Address_Location__c(
			Address__c = addr1?.Id,
			service__c = services[1]?.Id,
			Location_Type__c = 'Physical'
		);
		insert adLoc2;

		User adminUser = TestDataFactory.createSystemAdminUser();
		Test.startTest();
		System.runAs(adminUser) {
			AcfrCreateQuaterlyCasesAndFormsScheduler acfrCaseForms = new AcfrCreateQuaterlyCasesAndFormsScheduler();
			Database.executeBatch(acfrCaseForms);
		}
		Test.stopTest();

		List<Service_Line_Item__c> sliWithRegions = [
			SELECT id, Service_Region__c, Name, CreatedDate
			FROM Service_Line_Item__c
			WHERE
				Form__r.Type__c = 'Home Care Labour Costs and Hours'
				AND Service_Region__c != NULL
		];
		System.assertEquals(sliWithRegions.size(), 2); //setup data is only for 2 SLIs
	}
}
