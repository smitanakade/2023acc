/*****************************************
 *@Author        :Jhosua Arda
 *@Company       :Accenture
 *@Description   : this class will test the functionality of FinancialReportingRulesController
 *@Test Class    :
 *@Date:N/A
 *@Revision:
 *When                 Who               What
 *11-Jan-2023          Developer Name    Created
 *15-Feb-2023		  Cla Capagas		Modified
 *****************************************/
@isTest
private class FinancialReportingRulesControllerTest {
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

			//Case
			Case caseData = new Case(
				AccountId = acc.id,
				Status = 'Not Required'
			);
			insert caseData;

			//Form
			Form__c formData = new Form__c(
				Account__c = acc.id,
				Case__c = caseData.Id,
				Type__c = 'Residential Food and Nutrition Reporting',
				RecordTypeId = Schema.SObjectType.Form__c.getRecordTypeInfosByDeveloperName()
					.get('QFR')
					.getRecordTypeId()
			);
			insert formData;

			// Business License
			BusinessLicense businessLicense = new BusinessLicense();
			businessLicense.Care_Type__c = 'Residential';
			businessLicense.Name = 'Home care Melbourne City - North West Region';
			businessLicense.Effective_Date__c = Date.today();
			businessLicense.Status = 'Operational';
			insert businessLicense;

			// Service Line item 1
			Service_Line_Item__c serviceLineItem1 = new Service_Line_Item__c(
				Form__c = formData.Id,
				active__c = true,
				Service_Category__c = 'Home Care',
				Service__c = businessLicense.Id
			);
			insert serviceLineItem1;

			// Service Line item 2
			Service_Line_Item__c serviceLineItem2 = new Service_Line_Item__c(
				Form__c = formData.Id,
				active__c = true,
				Service_Category__c = 'Residential',
				Service__c = businessLicense.Id
			);
			insert serviceLineItem2;

			// Service Line item 2
			Service_Line_Item__c serviceLineItemTotal = new Service_Line_Item__c(
				Form__c = formData.Id,
				active__c = true,
				Service_Category__c = 'Total'
			);
			insert serviceLineItemTotal;

			//GL Code Residential
			GL_Code__c gLCodeResi = new GL_Code__c(
				External_Name__c = 'Dietetic Care',
				Name = 'Dietetic Care',
				run_rules__c = true,
				Business_ID__c = 'Q00001',
				Type__c = 'Residential Food and Nutrition Reporting',
				Line_Item_Value_Type__c = 'Hrs'
			);
			insert gLCodeResi;

			//GL Code Residential Labour Cost and Hours
			GL_Code_Line_Item__c gLCodeLineItemResi = new GL_Code_Line_Item__c(
				Line_Item_Value__c = '15',
				GL_Code__c = gLCodeResi.Id,
				Service_Line_Item__c = ServiceLineItem1.Id
			);
			insert gLCodeLineItemResi;

			//GL Code Labour
			GL_Code__c gLCodeLabour = new GL_Code__c(
				External_Name__c = 'Dietetic Care - Labour',
				Name = 'Dietetic Care - Labour',
				run_rules__c = true,
				Business_ID__c = 'Q00002',
				Type__c = 'Home Care Labour Costs and Hours',
				Line_Item_Value_Type__c = 'Hrs'
			);
			insert gLCodeLabour;

			//GL Code Residential Food and Nutrition Reporting
			GL_Code_Line_Item__c gLCodeLineItemLabour = new GL_Code_Line_Item__c(
				Line_Item_Value__c = '25',
				GL_Code__c = gLCodeLabour.Id,
				Service_Line_Item__c = ServiceLineItem2.Id
			);
			insert gLCodeLineItemLabour;

			//GL Code Residential Food and Nutrition Reporting Total
			GL_Code_Line_Item__c gLCodeLineItemLabourTotal = new GL_Code_Line_Item__c(
				Line_Item_Value__c = '0',
				GL_Code__c = GLCodeLabour.Id,
				Service_Line_Item__c = ServiceLineItemTotal.Id
			);
			insert gLCodeLineItemLabourTotal;

			//Get RecordType
			Id financialRepRuleDuplicateTypeId = Schema.SObjectType.Financial_Reporting_Rule_Details__c.getRecordTypeInfosByDeveloperName()
				.get('Duplicate_Value_Reference')
				.getRecordTypeId();

			// Financial reporting for Residential
			Financial_Reporting_Rule_Details__c financialReportingResi = new Financial_Reporting_Rule_Details__c(
				Active__c = true,
				GL_Code__c = GLCodeResi.Id,
				GL_Code_Target__c = GLCodeLabour.Id,
				RecordTypeId = financialRepRuleDuplicateTypeId
			);
			insert financialReportingResi;

			// Financial reporting for Labour
			Financial_Reporting_Rule_Details__c financialReportingLabour = new Financial_Reporting_Rule_Details__c(
				Active__c = true,
				GL_Code__c = GLCodeLabour.Id,
				GL_Code_Target__c = GLCodeResi.Id,
				RecordTypeId = financialRepRuleDuplicateTypeId
			);
			insert financialReportingLabour;
		}

	}

	@isTest
	static void updateGLCodeLineItemVal() {
		String itemValue = '100';
		User adminUser = [
			SELECT Id
			FROM User
			WHERE UserName = 'testUser01@admin.com'
			LIMIT 1
		];
		GL_Code_Line_Item__c glliCode = [
			SELECT Id, Line_Item_Value__c
			FROM GL_Code_Line_Item__c
			WHERE GL_Code__r.Business_ID__c = 'Q00001'
			LIMIT 1
		];

		Test.startTest();
		System.runAs(adminUser) {
			glliCode.Line_Item_Value__c = itemValue;
			update glliCode;
		}
		Test.stopTest();
		//check if glcodetarget values are getting updated
		GL_Code_Line_Item__c glliCodeTarget = [
			SELECT Id, Line_Item_Value__c
			FROM GL_Code_Line_Item__c
			WHERE GL_Code__r.Business_ID__c = 'Q00002'
			LIMIT 1
		];
		system.assertEquals(itemValue, glliCodeTarget.Line_Item_Value__c);
	}

	@isTest
	static void updateGLCodeLineItemValWithDecimal() {
		String itemValue = '45.01';
		User adminUser = [
			SELECT Id
			FROM User
			WHERE UserName = 'testUser01@admin.com'
			LIMIT 1
		];
		GL_Code_Line_Item__c glliCode = [
			SELECT Id, Line_Item_Value__c
			FROM GL_Code_Line_Item__c
			WHERE GL_Code__r.Business_ID__c = 'Q00001'
			LIMIT 1
		];

		Test.startTest();
		System.runAs(adminUser) {
			glliCode.Line_Item_Value__c = itemValue;
			update glliCode;
		}
		Test.stopTest();
		//check if glcodetarget values are getting updated
		GL_Code_Line_Item__c glliCodeTarget = [
			SELECT Id, Line_Item_Value__c
			FROM GL_Code_Line_Item__c
			WHERE GL_Code__r.Business_ID__c = 'Q00002'
			LIMIT 1
		];
		system.assertEquals(itemValue, glliCodeTarget.Line_Item_Value__c);
	}

	@isTest
	static void updateGLCodeLineItemValString() {
		String itemValue = 'Cook Chill';
		User adminUser = [
			SELECT Id
			FROM User
			WHERE UserName = 'testUser01@admin.com'
			LIMIT 1
		];
		GL_Code_Line_Item__c glliCode = [
			SELECT Id, Line_Item_Value__c
			FROM GL_Code_Line_Item__c
			WHERE GL_Code__r.Business_ID__c = 'Q00001'
			LIMIT 1
		];

		Test.startTest();
		System.runAs(adminUser) {
			glliCode.Line_Item_Value__c = itemValue;
			update glliCode;
		}
		Test.stopTest();
		//check if glcodetarget values are not updated since duplicate rules applicable for numeric only
		GL_Code_Line_Item__c glliCodeTarget = [
			SELECT Id, Line_Item_Value__c
			FROM GL_Code_Line_Item__c
			WHERE GL_Code__r.Business_ID__c = 'Q00002'
			LIMIT 1
		];
		system.assertEquals('25', glliCodeTarget.Line_Item_Value__c);
	}

	@isTest
	static void updateGLCodeLineItemValNull() {
		String itemValue = null;
		User adminUser = [
			SELECT Id
			FROM User
			WHERE UserName = 'testUser01@admin.com'
			LIMIT 1
		];
		GL_Code_Line_Item__c glliCode = [
			SELECT Id, Line_Item_Value__c
			FROM GL_Code_Line_Item__c
			WHERE GL_Code__r.Business_ID__c = 'Q00001'
			LIMIT 1
		];

		Test.startTest();
		System.runAs(adminUser) {
			glliCode.Line_Item_Value__c = itemValue;
			update glliCode;
		}
		Test.stopTest();
		//check if glcodetarget values are getting updated
		GL_Code_Line_Item__c glliCodeTarget = [
			SELECT Id, Line_Item_Value__c
			FROM GL_Code_Line_Item__c
			WHERE GL_Code__r.Business_ID__c = 'Q00002'
			LIMIT 1
		];
		system.assertEquals(null, glliCodeTarget.Line_Item_Value__c);
	}
}
