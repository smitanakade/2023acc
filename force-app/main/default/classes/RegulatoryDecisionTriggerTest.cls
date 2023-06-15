@IsTest
public with sharing class RegulatoryDecisionTriggerTest {
	@TestSetup
	static void makeData() {
		User u = TestDataFactory.createTestUser();
		u.Alias = 'TestUser';
		insert u;
	}

	@isTest
	static void testUpdate() {
		User adminUser = TestDataFactory.createSystemAdminUser();
		adminUser.isActive = true;

		update adminUser;

		System.runAs(adminUser) {
			List<Account> providerList = TestDataFactory.createProviderRecords(
				1
			);
			insert providerList;

			List<Care_Type__c> careTypeListRecords = TestDataFactory.createSCRcareType(
				1,
				providerList
			);
			insert careTypeListRecords;

			List<BusinessLicense> testService = TestDataFactory.createSCRServiceRecords(
				1,
				'TestService1',
				providerList,
				0,
				0,
				0
			);

			testService.get(0)
				.RecordTypeId = Schema.SObjectType.BusinessLicense.getRecordTypeInfosByDeveloperName()
				.get('Approved_Provider_Service')
				.getRecordTypeId();
			testService.get(0).Name = 'Test JC';
			testService.get(0).Care_Type__c = 'Home Care';
			testService.get(0).Status__c = 'Operational';
			testService.get(0).AccountId = providerList[0].Id;
			testService.get(0).Service_Care_Sub_Type__c = 'Home Care';
			insert testService;

			Test.getEventBus().deliver();

			List<ViolationType> violationTypeList = TestDataFactory.createQIViolationType(
				1
			);
			insert violationTypeList;

			List<Service_Account_Relationship__c> sarList = TestDataFactory.createServiceAccountRecords(
				1,
				testService,
				providerList
			);
			for (Service_Account_Relationship__c rec : sarList) {
				rec.Association_Start_Date__c = Date.today().addDays(-10);
			}
			insert sarList;

			List<Service_Compliance_History__c> servCompHistory = TestDataFactory.createServiceComplianceHistory(
				1
			);
			for (Service_Compliance_History__c rec : servCompHistory) {
				rec.Service_Account__c = sarList[0].Id;
				rec.Service__c = testService[0].Id;
				rec.Provider__c = providerList[0].Id;
			}
			insert servCompHistory;

			List<RegulatoryCodeViolation> regDecisionList = TestDataFactory.createQIRegulatoryCodeViolation(
				1,
				testService,
				providerList,
				violationTypeList,
				sarList
			);
			regDecisionList[0].published__c = false;
			regDecisionList[0].Status = 'Current';
			insert regDecisionList;

			Test.startTest();
			regDecisionList[0].published__c = true;
			update regDecisionList;
			regDecisionList[0].Status = 'Removed';
			regDecisionList[0].Removed_Reason__c = 'testtesttesttest';
			update regDecisionList;
			Test.stopTest();
			System.assertEquals(
				regDecisionList[0].published__c,
				true,
				'Error occured on update'
			);
		}
	}

	@isTest
	public static void testShareAfterRegulatoryCodeViolationInsert() {
		User adminUser = TestDataFactory.createSystemAdminUser();
		adminUser.isActive = true;

		update adminUser;

		System.runAs(adminUser) {
			List<Account> providerList = TestDataFactory.createProviderRecords(
				1
			);
			insert providerList;

			List<Care_Type__c> careTypeListRecords = TestDataFactory.createSCRcareType(
				1,
				providerList
			);
			insert careTypeListRecords;

			List<BusinessLicense> testService = TestDataFactory.createSCRServiceRecords(
				1,
				'TestService1',
				providerList,
				0,
				0,
				0
			);

			testService.get(0)
				.RecordTypeId = Schema.SObjectType.BusinessLicense.getRecordTypeInfosByDeveloperName()
				.get('Approved_Provider_Service')
				.getRecordTypeId();
			testService.get(0).Name = 'Test JC';
			testService.get(0).Care_Type__c = 'Home Care';
			testService.get(0).Status__c = 'Operational';
			testService.get(0).AccountId = providerList[0].Id;
			testService.get(0).Service_Care_Sub_Type__c = 'Home Care';
			insert testService;

			Test.getEventBus().deliver();
			// Create public groups
			BusinessLicenseTriggerService.createPublicGroupAndShare(
				new Map<Id, BusinessLicense>(testService)
			);
			List<ViolationType> violationTypeList = TestDataFactory.createQIViolationType(
				1
			);
			insert violationTypeList;

			List<Service_Account_Relationship__c> sarList = TestDataFactory.createServiceAccountRecords(
				1,
				testService,
				providerList
			);
			insert sarList;

			Test.startTest();
			List<RegulatoryCodeViolation> regDecisionList = TestDataFactory.createQIRegulatoryCodeViolation(
				1,
				testService,
				providerList,
				violationTypeList,
				sarList
			);
			regDecisionList[0].published__c = false;
			regDecisionList[0].Status = 'Current';
			regDecisionList[0].Service_Name_lookup__c = testService[0].Id;

			insert regDecisionList;
			regDecisionList[0].published__c = true;
			update regDecisionList;
			Test.stopTest();

			Integer count = Database.countQuery(
				'SELECT Count() FROM RegulatoryCodeViolationShare WHERE ParentId = \'' +
					regDecisionList[0].Id +
					'\' AND RowCause = \'Manual\''
			);
			System.assertEquals(1, count);
		}
	}

	@isTest
	public static void testOwnershipChangeRegulatoryCodeViolationUpdate() {
		User adminUser = TestDataFactory.createSystemAdminUser();
		adminUser.isActive = true;

		update adminUser;

		System.runAs(adminUser) {
			User u = [SELECT Id, Alias FROM User WHERE Alias = 'TestUser'];

			List<Account> providerList = TestDataFactory.createProviderRecords(
				1
			);
			insert providerList;

			List<Care_Type__c> careTypeListRecords = TestDataFactory.createSCRcareType(
				1,
				providerList
			);
			insert careTypeListRecords;

			List<BusinessLicense> testService = TestDataFactory.createSCRServiceRecords(
				1,
				'TestService1',
				providerList,
				0,
				0,
				0
			);

			testService.get(0)
				.RecordTypeId = Schema.SObjectType.BusinessLicense.getRecordTypeInfosByDeveloperName()
				.get('Approved_Provider_Service')
				.getRecordTypeId();
			testService.get(0).Name = 'Test JC';
			testService.get(0).Care_Type__c = 'Home Care';
			testService.get(0).Status__c = 'Operational';
			testService.get(0).AccountId = providerList[0].Id;
			testService.get(0).Service_Care_Sub_Type__c = 'Home Care';
			insert testService;

			Test.getEventBus().deliver();
			// Create public groups
			BusinessLicenseTriggerService.createPublicGroupAndShare(
				new Map<Id, BusinessLicense>(testService)
			);
			List<ViolationType> violationTypeList = TestDataFactory.createQIViolationType(
				1
			);
			insert violationTypeList;

			List<Service_Account_Relationship__c> sarList = TestDataFactory.createServiceAccountRecords(
				1,
				testService,
				providerList
			);
			insert sarList;

			List<RegulatoryCodeViolation> regDecisionList = TestDataFactory.createQIRegulatoryCodeViolation(
				1,
				testService,
				providerList,
				violationTypeList,
				sarList
			);
			regDecisionList[0].published__c = false;
			regDecisionList[0].Status = 'Current';
			regDecisionList[0].Service_Name_lookup__c = testService[0].Id;

			insert regDecisionList;

			Test.startTest();

			regDecisionList[0].OwnerId = u.Id;

			update regDecisionList;
			Test.stopTest();

			Integer count = Database.countQuery(
				'SELECT Count() FROM RegulatoryCodeViolationShare WHERE ParentId = \'' +
					regDecisionList[0].Id +
					'\' AND RowCause = \'Manual\''
			);
			System.assertEquals(1, count);
		}
	}
}
