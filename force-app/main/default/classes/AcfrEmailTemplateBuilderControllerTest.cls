@isTest
private class AcfrEmailTemplateBuilderControllerTest {
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
		PermissionSet ps = [
			SELECT Id
			FROM PermissionSet
			WHERE Name = 'Fin_QA_Assessor'
		];
		insert new PermissionSetAssignment(
			AssigneeId = adminUser.id,
			PermissionSetId = ps.Id
		);

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

			Contact_Relationship__c cr1 = new Contact_Relationship__c(
				Account__c = acc[0].Id,
				Contact__c = con1.Id,
				Role__c = 'QFR Primary Contact'
			);
			insert cr1;

			Contact_Relationship__c cr2 = new Contact_Relationship__c(
				Account__c = acc[0].Id,
				Contact__c = con1.Id
			);
			insert cr2;

			Case cs = new Case(Status = 'New', AccountId = acc[0].Id);
			insert cs;

			Case cs2 = new Case(Status = 'New', AccountId = acc[0].Id);
			insert cs2;

			List<Form__c> formList = new List<Form__c>();

			Form__c f1 = new Form__c(
				Type__c = 'Declaration and Submission',
				Declaration_Complete__c = 'No',
				Declaration_Incomplete_Reason__c = 'Signatory is not an authorised person;Other;',
				Case__c = cs.Id
			);
			Form__c f2 = new Form__c(
				Type__c = 'Residential Viability and Prudential Reporting',
				Case__c = cs.Id
			);
			Form__c f3 = new Form__c(
				Type__c = 'Home Care Viability and Prudential Reporting',
				Case__c = cs.Id
			);
			Form__c f4 = new Form__c(
				Type__c = 'Approved Provider Quarterly Financial Statements',
				Case__c = cs.Id
			);
			Form__c f5 = new Form__c(
				Type__c = 'Home Care Labour Costs and Hours',
				Case__c = cs.Id
			);
			Form__c f6 = new Form__c(
				Type__c = 'Residential Labour Costs and Hours',
				Case__c = cs.Id
			);
			Form__c f7 = new Form__c(
				Type__c = 'Residential Food and Nutrition Reporting',
				Case__c = cs.Id
			);
			Form__c f8 = new Form__c(
				Type__c = 'MPS Food and Nutrition Reporting',
				Case__c = cs.Id
			);
			Form__c f9 = new Form__c(
				Type__c = 'NATSIFACP Food and Nutrition Reporting',
				Case__c = cs.Id
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
		}
	}

	@isTest
	static void testReissueEmail() {
		User finQAAssessorUser = [
			SELECT id
			FROM user
			WHERE isActive = TRUE
			LIMIT 1
		];

		System.runAs(finQAAssessorUser) {
			List<Case> rec = [SELECT Id FROM Case ORDER BY Createddate ASC];
			if (rec.size() > 0) {
				String emailSubject = AcfrEmailTemplateBuilderController.getEmailSubject(
					rec[0].Id
				);
				String emailContent = AcfrEmailTemplateBuilderController.getEmailContent(
					rec[0].Id
				);
				String emailAddress = AcfrEmailTemplateBuilderController.getEmailAddress(
					rec[0].Id
				);
				String emailAddressCC = AcfrEmailTemplateBuilderController.getEmailAddressCC(
					rec[0].Id
				);
				Test.startTest();
				AcfrEmailTemplateBuilderController.sendSingleEmailMethod(
					rec[0].Id,
					emailContent,
					emailAddress,
					emailAddressCC,
					emailSubject
				);
				Test.stopTest();
				List<Task> t = [SELECT id FROM task LIMIT 1];
				System.assert(t.size() > 0);
			}
		}
	}
}