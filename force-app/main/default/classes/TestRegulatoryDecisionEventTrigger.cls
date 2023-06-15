@IsTest
public class TestRegulatoryDecisionEventTrigger {
	private static User currentUser = TestDataFactory.createSystemAdminUser();

	@TestSetup
	static void makeData() {
		System.runAs(currentUser) {
			Test.startTest();
			List<Account> providerList = TestDataFactory.createProviderRecords(
				1
			);
			insert providerList;

			List<BusinessLicense> testService = TestDataFactory.createServiceRecords(
				1
			);
			testService[0].Care_Type__c = 'Residential';
			testService[0].AccountId = providerList[0].Id;
			insert testService;

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
			Test.stopTest();
		}

	}

	/**
	 * This method creates a regulatory decision and publishes it.
	 * Expected result: 1 SCRH and 1 SCD records created
	 */
	@isTest
	static void testPublishEvent() {
		System.runAs(currentUser) {
			Test.startTest();

			List<Account> providers = [SELECT Id FROM Account];
			List<Service_Account_Relationship__c> sarList = [
				SELECT Id
				FROM Service_Account_Relationship__c
			];

			BusinessLicense service = [
				SELECT Id, Name
				FROM BusinessLicense
				WHERE Name = 'Service Test 0'
			];

			List<ViolationType> violationTypeList = [
				SELECT Id
				FROM ViolationType
			];

			List<RegulatoryCodeViolation> regDecisionList = new List<RegulatoryCodeViolation>{
				new RegulatoryCodeViolation(
					Service_name_lookup__c = service.Id,
					Service_Provider_Name__c = null,
					ViolationTypeId = violationTypeList.get(0).Id,
					Status = 'Current',
					Service_Provider_Name_lookup__c = providers[0].Id,
					Service_Account_Relationship__c = sarList[0].Id,
					DateCreated = Datetime.now(),
					Published__c = false,
					Rating_Relevant__c = true,
					SCR_Rating__c = '2 Star',
					Decision_Details__c = 'Decision Details',
					Reason_for_issuing_Regulatory_Decision__c = 'Test Reason'
				)
			};

			insert regDecisionList;

			List<RegulatoryCodeViolation> regForPublishing = [
				SELECT Id, Published__c
				FROM RegulatoryCodeViolation
				WHERE Published__c = FALSE
			];

			regForPublishing.get(0).Published__c = true;
			update regForPublishing;

			Test.getEventBus().deliver();
			Test.stopTest();

			List<Service_Compliance_History__c> schList = [
				SELECT Id, Name
				FROM Service_Compliance_History__c
			];

			List<Service_Compliance_Detail__c> scdList = [
				SELECT Id, Name, Service_Compliance_History__c
				FROM Service_Compliance_Detail__c
			];

			Assert.areEqual(1, schList.size(), '1 history should exist');
			Assert.areEqual(1, scdList.size(), '1 detail should exist');
		}
	}

	/**
	 * This method creates a regulatory decision which is published and non current. Status is then updated to removed.
	 * Expected result: 1 SCRH and 1 SCD records created
	 */
	@isTest
	static void testRemoveDecisionDecision() {
		System.runAs(currentUser) {
			Test.startTest();
			List<Account> providers = [SELECT Id FROM Account];
			List<Service_Account_Relationship__c> sarList = [
				SELECT Id
				FROM Service_Account_Relationship__c
			];

			List<BusinessLicense> service = [
				SELECT Id, Name
				FROM BusinessLicense
				WHERE Name = 'Service Test 0'
			];

			List<ViolationType> violationTypeList = [
				SELECT Id
				FROM ViolationType
			];

			List<RegulatoryCodeViolation> regDecisionList = new List<RegulatoryCodeViolation>{
				new RegulatoryCodeViolation(
					Service_name_lookup__c = service.get(0).Id,
					Service_Provider_Name__c = null,
					ViolationTypeId = violationTypeList.get(0).Id,
					Status = 'Non-Current',
					Service_Provider_Name_lookup__c = providers[0].Id,
					Service_Account_Relationship__c = sarList[0].Id,
					DateCreated = Datetime.now(),
					Published__c = true,
					Rating_Relevant__c = true,
					SCR_Rating__c = '2 Star',
					Decision_Details__c = 'Decision Details',
					Reason_for_issuing_Regulatory_Decision__c = 'Test Reason'
				)
			};

			insert regDecisionList;

			List<RegulatoryCodeViolation> regToUpdate = [
				SELECT Id, Status, Removed_Reason__c
				FROM RegulatoryCodeViolation
			];
			regToUpdate.get(0).Status = 'Removed';
			regToUpdate.get(0).Removed_Reason__c = 'Test';
			update regToUpdate;

			Test.getEventBus().deliver();
			Test.stopTest();

			List<Service_Compliance_History__c> schList = [
				SELECT Id, Name, Service_Compliance_Rating__c
				FROM Service_Compliance_History__c
			];

			List<Service_Compliance_Detail__c> scdList = [
				SELECT Id
				FROM Service_Compliance_Detail__c
			];

			Assert.areEqual(1, schList.size(), 'Expected 1');
			Assert.areEqual(1, scdList.size(), 'Expected 1');
		}
	}
}
