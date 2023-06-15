@isTest
private class AcfrSendRCOutcomeEmailTest {
	@testSetup
	static void setup() {
		User adminUser = TestDataFactory.createSystemAdminUser();
		UserRole userRole = [
			SELECT Id, Name
			FROM UserRole
			WHERE Name = 'Health Staff'
			LIMIT 1
		];
		adminUser.isActive = true;
		adminUser.UserRoleId = userRole.Id;

		update adminUser;

		System.runAs(adminUser) {
			String accountStr = TestDataFactory.createACO();

			List<Account> acc = [
				SELECT id, name
				FROM Account
				WHERE id = :accountStr
			];
			Contact con1 = new Contact(
				FirstName = '1',
				LastName = 'Test',
				Salutation = 'Ms',
				Email = 'test@gmail.com'
			);
			insert con1;

			Contact con2 = new Contact(
				FirstName = '2',
				LastName = 'Test',
				Salutation = 'Ms',
				Email = 'test@gmail.com'
			);
			insert con2;

			Contact_Relationship__c cr1 = new Contact_Relationship__c(
				Account__c = acc[0].Id,
				Contact__c = con1.Id,
				Role__c = 'QFR Primary Contact'
			);
			insert cr1;

			Contact_Relationship__c cr2 = new Contact_Relationship__c(
				Account__c = acc[0].Id,
				Contact__c = con2.Id
			);
			insert cr2;
			Application__c app = new Application__c(
				Application_Status__c = 'Application Submitted - RFI'
			);
			insert app;

			Reporting_Period__c rp1 = new Reporting_Period__c();
			rp1.Reporting_Period_Type__c = 'Quarter';
			rp1.Start_Date__c = Date.Today().addDays(-12).addMonths(-3);
			rp1.End_Date__c = Date.Today().addDays(-12);
			insert rp1;

			Case cs = new Case(
				Status = 'New',
				AccountId = acc[0].Id,
				//Application__c = app.Id,
				SkipLateSubmissionEmail__c = 'No',
				Reporting_Period__c = rp1.Id
			);
			insert cs;

			Case cs2 = new Case(
				Status = 'New',
				AccountId = acc[0].Id,
				//Application__c = app.Id,
				SkipLateSubmissionEmail__c = 'No',
				Reporting_Period__c = rp1.Id
			);
			insert cs2;

			List<Form__c> formList = new List<Form__c>();

			Form__c f1 = new Form__c(
				Type__c = 'Declaration and Submission',
				Declaration_Complete__c = 'No',
				Declaration_Incomplete_Reason__c = 'Signatory is not an authorised person;Other;',
				Case__c = cs.Id,
				RecordTypeId = Schema.SObjectType.Form__c.getRecordTypeInfosByDeveloperName()
					.get('QFR')
					.getRecordTypeId()
			);
			Form__c f2 = new Form__c(
				Type__c = 'Residential Viability and Prudential Reporting',
				Case__c = cs.Id,
				RecordTypeId = Schema.SObjectType.Form__c.getRecordTypeInfosByDeveloperName()
					.get('QFR')
					.getRecordTypeId()
			);
			Form__c f3 = new Form__c(
				Type__c = 'Home Care Viability and Prudential Reporting',
				Case__c = cs.Id,
				RecordTypeId = Schema.SObjectType.Form__c.getRecordTypeInfosByDeveloperName()
					.get('QFR')
					.getRecordTypeId()
			);
			Form__c f4 = new Form__c(
				Type__c = 'Approved Provider Quarterly Financial Statements',
				Case__c = cs.Id,
				RecordTypeId = Schema.SObjectType.Form__c.getRecordTypeInfosByDeveloperName()
					.get('QFR')
					.getRecordTypeId()
			);
			Form__c f5 = new Form__c(
				Type__c = 'Home Care Labour Costs and Hours',
				Case__c = cs.Id,
				RecordTypeId = Schema.SObjectType.Form__c.getRecordTypeInfosByDeveloperName()
					.get('QFR')
					.getRecordTypeId()
			);
			Form__c f6 = new Form__c(
				Type__c = 'Residential Labour Costs and Hours',
				Case__c = cs.Id,
				RecordTypeId = Schema.SObjectType.Form__c.getRecordTypeInfosByDeveloperName()
					.get('QFR')
					.getRecordTypeId()
			);
			Form__c f7 = new Form__c(
				Type__c = 'Residential Food and Nutrition Reporting',
				Case__c = cs.Id,
				RecordTypeId = Schema.SObjectType.Form__c.getRecordTypeInfosByDeveloperName()
					.get('QFR')
					.getRecordTypeId()
			);
			Form__c f8 = new Form__c(
				Type__c = 'MPS Food and Nutrition Reporting',
				Case__c = cs.Id,
				RecordTypeId = Schema.SObjectType.Form__c.getRecordTypeInfosByDeveloperName()
					.get('QFR')
					.getRecordTypeId()
			);
			Form__c f9 = new Form__c(
				Type__c = 'NATSIFACP Food and Nutrition Reporting',
				Case__c = cs.Id,
				RecordTypeId = Schema.SObjectType.Form__c.getRecordTypeInfosByDeveloperName()
					.get('QFR')
					.getRecordTypeId()
			);
			formList.add(f1);
			formList.add(f2);
			formList.add(f3);
			formList.add(f4);
			formList.add(f5);
			formList.add(f6);
			formList.add(f7);
			formList.add(f8);
			formList.add(f9);

			insert formList;

			Service_Line_Item__c sli = new Service_Line_Item__c(
				Reasonableness_Check_Outcome__c = 'For review',
				Form__c = f6.Id,
				Reasonableness_Check_Outcome_comments__c = 'testing',
				Reasonableness_Check__c = '1',
				Service_Region__c = 'test'
			);
			insert sli;
		}
	}

	@isTest
	static void testSendOverDueEmail() {
		User adminUser = [SELECT id FROM user WHERE isActive = TRUE LIMIT 1];
		System.runAs(adminUser) {
			Test.StartTest();
			List<Service_Line_Item__c> serviceLineItems = [
				SELECT
					id,
					Form__c,
					Form__r.Case__c,
					Form__r.Case__r.AccountId,
					Service__r.Name,
					Reasonableness_Check_Outcome__c,
					Reasonableness_Check_Outcome_comments__c,
					Reasonableness_Check__c
				FROM service_line_item__c
				WHERE
					Reasonableness_Check_Outcome__c = 'For review'
					AND Form__r.Type__c = 'Residential Labour Costs and Hours'
					AND Date_last_notified__c = NULL
					AND Form__c != NULL
					AND Form__r.Case__c != NULL
				ORDER BY Form__r.Case__c ASC
			];
			System.AssertEquals(serviceLineItems.size() > 0, true);
			Id batchJobId1 = Database.executeBatch(
				new AcfrSendRCOutcomeEmailBatch(),
				100
			);
			Test.StopTest();
		}
	}
}
