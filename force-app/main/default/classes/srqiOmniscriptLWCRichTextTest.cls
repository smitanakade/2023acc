@IsTest
public with sharing class srqiOmniscriptLWCRichTextTest {
	@TestSetup
	static void dataSetup() {
		Integer recordCount = 20;
		User testUser = TestDataFactory.createSystemAdminUser();

		Test.startTest();
		System.runAs(testUser) {
			// get list of providers
			List<Account> providers = TestDataFactory.createProviderRecords(1);
			insert providers;
			// get list of service records
			List<BusinessLicense> services = TestDataFactory.createQIServiceRecords(1, providers);
			insert services;
			// get list of ViolationType
			List<ViolationType> VType = TestDataFactory.createQIViolationType(1);
			insert VType;
			// get list of service accounts
			List<Service_Account_Relationship__c> serviceAccounts = TestDataFactory.createServiceAccountRecords(
				1,
				services,
				providers
			);
			insert serviceAccounts;

			List<RegulatoryCodeViolation> RCodeViolation = TestDataFactory.createQIRegulatoryCodeViolation(
				1,
				services,
				providers,
				VType,
				serviceAccounts
			);
			insert RCodeViolation;
		}
		Test.stopTest();
	}
	@IsTest
	private static void it_throws_if_invalid_method_given() {
		Boolean didThrow = false;
		Map<String, Object> input = new Map<String, Object>();
		Map<String, Object> output = new Map<String, Object>();
		Map<String, Object> options = new Map<String, Object>();
		Test.startTest();
		try {
			new srqiOmniscriptLWCRichText().invokeMethod('1invalid', input, output, options);
		} catch (srqiOmniscriptLWCRichText.QiSrCustomDatatableException exc) {
			if (
				exc.getMessage() == 'Specified action not supported' // confirm correct exception thrown
			) {
				didThrow = true;
			}
		}
		Test.stopTest();
		System.assertEquals(true, didThrow);
	}
	@IsTest
	private static void invoke_getResponseforIssue() {
		Boolean didThrow = false;
		RegulatoryCodeViolation RCodeViolation = [SELECT Id FROM RegulatoryCodeViolation LIMIT 1];
		Map<String, Object> input = new Map<String, Object>{ 'recordid' => RCodeViolation.Id };
		Map<String, Object> output = new Map<String, Object>();
		Map<String, Object> options = new Map<String, Object>();

		Test.startTest();
		didThrow = new srqiOmniscriptLWCRichText().invokeMethod('getResponseforIssue', input, output, options);
		didThrow = new srqiOmniscriptLWCRichText().invokeMethod('getDecisionDetails', input, output, options);
		didThrow = new srqiOmniscriptLWCRichText().invokeMethod('getProgressDetails', input, output, options);
		Test.stopTest();
		System.assertEquals(true, didThrow, 'All valid methods, hence response should be true');
	}

	@istest
	static void unitTest_getResponseforIssue() {
		RegulatoryCodeViolation RCodeViolation = [SELECT Id FROM RegulatoryCodeViolation LIMIT 1];
		test.startTest();
		String ResponseforIssue = srqiOmniscriptLWCRichText.getResponseforIssue(RCodeViolation.Id);
		test.stopTest();

		Assert.areNotEqual(null, ResponseforIssue, 'Reason_for_issuing_Regulatory_Decision should be populated');
	}
	@istest
	static void unitTest_getDecisionDetails() {
		RegulatoryCodeViolation RCodeViolation = [SELECT Id FROM RegulatoryCodeViolation LIMIT 1];
		test.startTest();
		String DecisionDetails = srqiOmniscriptLWCRichText.getDecisionDetails(RCodeViolation.Id);
		test.stopTest();

		Assert.areNotEqual(null, DecisionDetails, 'Decision details should be populated');
	}
	@istest
	static void unitTest_getProgressDetails() {
		RegulatoryCodeViolation RCodeViolation = [SELECT Id FROM RegulatoryCodeViolation LIMIT 1];
		test.startTest();
		String ProgressDetails = srqiOmniscriptLWCRichText.getProgressDetails(RCodeViolation.Id);
		test.stopTest();
		Assert.areNotEqual(null, ProgressDetails, 'Progress details should be populated');
	}
}
