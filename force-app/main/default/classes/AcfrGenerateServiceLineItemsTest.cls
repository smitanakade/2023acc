/******************************************************************************
 *  Test Class Name   :       AcfrGenerateServiceLineItemsTest
 *  Main Class  	  :       AcfrGenerateServiceLineItems
 *  Author            :       CJJOYA
 *
 *  Revision History:
 *  31032023    :       Date created
 *                      PBI#339782
 *
 */
@IsTest
public with sharing class AcfrGenerateServiceLineItemsTest {
	public static final String homecareType = 'Home Care';
	public static final String homecarelc = 'Home Care Labour Costs and Hours';
	public static final String qfStatements = 'Approved Provider Quarterly Financial Statements';

	@TestSetup
	static void setup() {
		User testUser = TestDataFactory.createSystemAdminUser();
		System.runAs(testUser) {
			//Account
			Account acc = new Account(
				Name = 'Test Account Company',
				Type = 'ACN',
				Incorporated_Under__c = 'Royal Charter',
				Incorporation_Status__c = 'Registered',
				Incorporation_Status_Date__c = System.today(),
				Incorporation_ID_Type__c = 'ACN',
				Incorporation_Type__c = 'State Government',
				Prospective_Provider__c = '',
				Incorporation_ID__c = '137083964',
				RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
					.get('Approved_Provider')
					.getRecordTypeId()
			);
			insert acc;

			List<BusinessLicense> services = new List<BusinessLicense>();
			services.add(
				new BusinessLicense(
					Name = 'Total',
					Effective_Date__c = Date.today(),
					Care_Type__c = homecareType,
					Status = 'Operational',
					Service_Care_Sub_Type__c = null,
					Status_Date__c = Date.today()
				)
			);
			services.add(
				new BusinessLicense(
					Name = 'Test Service ',
					Effective_Date__c = Date.today(),
					Care_Type__c = 'Residential',
					Status = 'Operational',
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
				End_Date__c = date.today().addDays(32)
			);
			insert currentRP;

			//Create case
			Case newCase = new Case(
				Status = 'New',
				AccountId = acc.id,
				Priority = 'Medium',
				RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
					.get('QFR')
					.getRecordTypeId(),
				Reporting_Period__c = currentRP.id
			);
			insert newCase;

			//Create new forms
			List<Form__c> forms = new List<Form__c>();
			forms.add(
				new Form__c(
					Account__c = acc.id,
					Case__c = newCase.id,
					RecordTypeId = Schema.SObjectType.Form__c.getRecordTypeInfosByDeveloperName()
						.get('QFR')
						.getRecordTypeId(),
					Reporting_Period__c = currentRP.id,
					Type__c = qfStatements
				)
			);
			forms.add(
				new Form__c(
					Account__c = acc.id,
					Case__c = newCase.id,
					RecordTypeId = Schema.SObjectType.Form__c.getRecordTypeInfosByDeveloperName()
						.get('QFR')
						.getRecordTypeId(),
					Reporting_Period__c = currentRP.id,
					Type__c = homecarelc
				)
			);
			forms.add(
				new Form__c(
					Account__c = acc.id,
					Case__c = newCase.id,
					RecordTypeId = Schema.SObjectType.Form__c.getRecordTypeInfosByDeveloperName()
						.get('QFR')
						.getRecordTypeId(),
					Reporting_Period__c = currentRP.id,
					Type__c = 'MPS Food and Nutrition Reporting'
				)
			);
			insert forms;

			List<GL_Code__c> testGLCodes = new List<GL_Code__c>();
			testGLCodes.add(
				new GL_Code__c(
					Name = 'Test GL',
					Type__c = homecarelc,
					Display_Order__c = 0,
					Line_Item_Value_Type__c = 'Numeric'
				)
			);
		}
	}

	@IsTest
	private static void generateSLIForFinancialStatements() {
		User testUser = TestDataFactory.createSystemAdminUser();
		System.runAs(testUser) {
			List<Account> acc = [SELECT Id FROM Account LIMIT 1];
			List<Id> acctids = new List<Id>();
			acctids.add(acc[0].Id);

			Form__c forms = [
				SELECT
					Id,
					RecordType.Name,
					Account__r.Id,
					Account__r.Name,
					Case__c,
					Reporting_Period__c,
					Type__c
				FROM Form__c
				WHERE RecordType.Name = 'QFR' AND Type__c = :qfStatements
				LIMIT 1
			];

			List<BusinessLicense> service = [
				SELECT Id, Care_Type__c, Status, Name
				FROM BusinessLicense
				WHERE Care_Type__c = :homecareType
				LIMIT 1
			];

			List<Form__c> newforms = [
				SELECT Id, Account__c, Case__c, Type__c, Name
				FROM Form__c
				WHERE Type__c = :qfStatements
				LIMIT 1
			];

			Map<Id, List<Form__c>> accountIdToFormMap = new Map<Id, List<Form__c>>();
			Map<Id, List<BusinessLicense>> accountIdToServiceMap = new Map<Id, List<BusinessLicense>>();
			accountIdToFormMap.put(forms.Account__c, newforms);
			accountIdToServiceMap.put(forms.Account__c, service);

			Test.startTest();
			new AcfrGenerateServiceLineItems(
				acctids,
				newforms,
				accountIdToFormMap,
				accountIdToServiceMap
			);
			Test.stopTest();

			List<Service_Line_Item__c> newSLI = [
				SELECT Id
				FROM Service_Line_Item__c
			];
			System.assertNotEquals(newsli.size(), 9);
		}
	}

	@IsTest
	private static void generateSLIMPSFoodNutritionReporting() {
		User testUser = TestDataFactory.createSystemAdminUser();

		System.runAs(testUser) {
			List<Account> acc = [SELECT Id FROM Account LIMIT 1];
			List<Id> acctids = new List<Id>();
			acctids.add(acc[0].Id);

			Form__c forms = [
				SELECT
					Id,
					RecordType.Name,
					Account__r.Id,
					Account__r.Name,
					Case__c,
					Reporting_Period__c,
					Type__c
				FROM Form__c
				WHERE
					RecordType.Name = 'QFR'
					AND Type__c = 'MPS Food and Nutrition Reporting'
				LIMIT 1
			];

			List<BusinessLicense> service = [
				SELECT Id, Care_Type__c, Status, Name
				FROM BusinessLicense
				WHERE Care_Type__c = :homecareType
				LIMIT 1
			];

			List<Form__c> newforms = [
				SELECT Id, Account__c, Case__c, Type__c, Name
				FROM Form__c
				WHERE Type__c = 'MPS Food and Nutrition Reporting'
				LIMIT 1
			];

			Map<Id, List<Form__c>> accountIdToFormMap = new Map<Id, List<Form__c>>();
			Map<Id, List<BusinessLicense>> accountIdToServiceMap = new Map<Id, List<BusinessLicense>>();
			accountIdToFormMap.put(forms.Account__c, newforms);
			accountIdToServiceMap.put(forms.Account__c, service);

			Test.startTest();
			new AcfrGenerateServiceLineItems(
				acctids,
				newforms,
				accountIdToFormMap,
				accountIdToServiceMap
			);
			Test.stopTest();

			List<Service_Line_Item__c> newSLI = [
				SELECT Id
				FROM Service_Line_Item__c
			];
			System.assertNotEquals(newSLI.size(), 9);
		}
	}

	@IsTest
	private static void generateSLIForHomeCareLabourCostHours() {
		User testUser = TestDataFactory.createSystemAdminUser();

		System.runAs(testUser) {
			List<Account> acc = [SELECT Id FROM Account LIMIT 1];
			List<Id> acctids = new List<Id>();
			acctids.add(acc[0].Id);

			Form__c forms = [
				SELECT
					Id,
					RecordType.Name,
					Account__r.Id,
					Account__r.Name,
					Case__c,
					Reporting_Period__c,
					Type__c
				FROM Form__c
				WHERE RecordType.Name = 'QFR' AND Type__c = :homecarelc
				LIMIT 1
			];

			List<BusinessLicense> service = [
				SELECT Id, Care_Type__c, Status, Name
				FROM BusinessLicense
				WHERE Care_Type__c = :homecareType
				LIMIT 1
			];

			List<Form__c> newforms = [
				SELECT Id, Account__c, Case__c, Type__c, Name
				FROM Form__c
				WHERE Type__c = :homecarelc
				LIMIT 1
			];

			Map<Id, List<Form__c>> accountIdToFormMap = new Map<Id, List<Form__c>>();
			Map<Id, List<BusinessLicense>> accountIdToServiceMap = new Map<Id, List<BusinessLicense>>();

			accountIdToFormMap.put(forms.Account__c, newforms);
			accountIdToServiceMap.put(forms.Account__c, service);

			Test.startTest();
			new AcfrGenerateServiceLineItems(
				acctids,
				newforms,
				accountIdToFormMap,
				accountIdToServiceMap
			);
			Test.stopTest();

			List<Service_Line_Item__c> newSLI = [
				SELECT Id
				FROM Service_Line_Item__c
				LIMIT 1
			];
			System.assertNotEquals(newSLI.size(), 1);
		}
	}
}
