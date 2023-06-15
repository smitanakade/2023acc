/**
 * @description       :
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             :
 * @last modified on  : 11-24-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 **/

@IsTest
public with sharing class ACFRGetViabilityResponseTest {
	@TestSetup
	static void setup() {
		User testUser = TestDataFactory.createSystemAdminUser(); //Added by CJJOYA 20012023

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

			Account acc = new Account(
				Name = 'Test Provider',
				Purpose__c = 'Government',
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
				Care_Type__c = 'Home Care',
				Status = 'Operational',
				Status_Date__c = Date.today()
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
				Type__c = 'Home Care Viability and Prudential Reporting',
				Display_Order__c = 0,
				Line_Item_Value_Type__c = 'Numeric'
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
			form.Type__c = 'Home Care Viability and Prudential Reporting';
			form.QA_Comments__c = 'None';
			form.RecordTypeId = Schema.SObjectType.Form__c.getRecordTypeInfosByDeveloperName()
				.get('QFR')
				.getRecordTypeId();
			insert form;

			Question_Category__c qc = new Question_Category__c(
				name = 'Cat1',
				External_Id__c = 'qc001' //, //qfr to fix
				//Type__c = 'Home Care Viability and Prudential Reporting' //qfr to fix
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
		}
	}

	@IsTest
	private static void Test_getViabilityResponse() {
		User testUser = TestDataFactory.createSystemAdminUser(); //Added by CJJOYA
		System.runAs(testUser) {
			User adminUser = [
				SELECT Id
				FROM User
				WHERE UserName = 'testUser01@admin.com'
				LIMIT 1
			];
			Form__c form = [
				SELECT id
				FROM Form__c
				WHERE Type__c = 'Home Care Viability and Prudential Reporting'
			];
			Boolean result;
			Map<String, Map<String, Object>> args = new Map<String, Map<String, Object>>{
				'output' => new Map<String, Object>(),
				'input' => new Map<String, Object>{ 'FormId' => form.Id }
			};

			if (form != null) {
				Test.startTest();
				//System.runAs(adminUser) { //Modified by CJJOYA 20012023
				Callable extension = (Callable) Type.forName(
						'ACFRGetViabilityResponse'
					)
					.newInstance();
				result = (Boolean) extension.call('getResponse', args);

				//}
				Test.stopTest();
				List<Case> newcases = [SELECT Id FROM Case];

				//Ensure records were created
				System.assertNotEquals(
					newcases.size(),
					0,
					'List should not be empty'
				);
			}
		}
	}
}
