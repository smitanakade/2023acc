@isTest
private class AcfrEmailServiceTest {
	private static final String TEST_EMAIL_DOT_COM = 'test@test.com;';

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

			Reporting_Period__c rp1 = new Reporting_Period__c();
			rp1.Reporting_Period_Type__c = 'Quarter';
			rp1.Start_Date__c = Date.Today().addDays(-12).addMonths(-3);
			rp1.End_Date__c = Date.Today().addDays(-12);
			insert rp1;

			Case cs = new Case(
				Status = 'New',
				AccountId = acc[0].Id,
				SkipLateSubmissionEmail__c = 'No',
				Reporting_Period__c = rp1.Id
			);
			insert cs;
		}
	}

	@isTest
	static void testGenerateReissueEmailTemplate() {
		user finQAAssessor = [
			SELECT id
			FROM user
			WHERE isActive = TRUE
			LIMIT 1
		];
		System.runAs(finQAAssessor) {
			List<Case> rec = [
				SELECT Id, AccountId
				FROM Case
				ORDER BY createddate ASC
				LIMIT 1
			];
			List<Account> acc = [
				SELECT Id
				FROM Account
				WHERE Id = :rec[0].AccountId
			];
			String emailSubject = AcfrEmailService.getEmailSubject(
				rec[0].Id,
				'Case',
				'QFR_Reissue_Email'
			);
			String emailContent = AcfrEmailService.getEmailContent(
				rec[0].Id,
				'Case',
				'QFR_Reissue_Email'
			);
			String primaryEmailAddress = AcfrEmailService.getPrimaryEmailAddress(
				rec[0].Id
			);
			String primaryandNonPrimaryEmailAddress = AcfrEmailService.getPrimaryandNonPrimaryEmailAddress(
				rec[0].Id,
				'test1@gmail.com'
			);
			emailContent = AcfrEmailService.hideConditions(
				emailContent,
				'TEST',
				true
			);
			emailContent = AcfrEmailService.hideConditions(
				emailContent,
				'TEST',
				false
			);

			List<String> invocableVariables = new List<String>();
			String var = 'recordId=' + rec[0].Id + ';';
			var = var + 'isStandard=true;';
			var = var + 'templateName=QFR_Reissue_Email;';
			var = var + 'toAddress=' + primaryEmailAddress + ';';
			var = var + 'ccAddress=' + primaryEmailAddress + ';';
			var = var + 'hasPrimaryMergeField=false;';
			var = var + 'toAddress1PrimaryOnly=false;';
			var = var + 'toAddressPrimaryAll=false;';
			var = var + 'toAddressAllContactRel=false;';
			var = var + 'toAddressVariable=false;';
			invocableVariables.add(var);
			AcfrEmailService.sendEmailMainInvocable(invocableVariables);

			Test.startTest();
			AcfrEmailService.sendEmailMain(
				true,
				'QFR_Reissue_Email',
				acc,
				primaryEmailAddress,
				primaryandNonPrimaryEmailAddress,
				true,
				true,
				false,
				false,
				false
			);
			AcfrEmailService.sendEmailMain(
				true,
				'QFR_Reissue_Email',
				acc,
				primaryEmailAddress,
				primaryandNonPrimaryEmailAddress,
				true,
				false,
				true,
				false,
				false
			);
			AcfrEmailService.sendEmailMain(
				true,
				'QFR_Reissue_Email',
				acc,
				primaryEmailAddress,
				primaryandNonPrimaryEmailAddress,
				true,
				false,
				false,
				true,
				false
			);
			AcfrEmailService.sendEmailMain(
				true,
				'QFR_Reissue_Email',
				acc,
				primaryEmailAddress,
				primaryandNonPrimaryEmailAddress,
				true,
				false,
				false,
				false,
				true
			);

			AcfrEmailService.sendEmailMain(
				false,
				'QFR_Reissue_Email',
				acc,
				primaryEmailAddress,
				primaryandNonPrimaryEmailAddress,
				true,
				true,
				false,
				false,
				false
			);
			AcfrEmailService.sendEmailMain(
				false,
				'QFR_Reissue_Email',
				acc,
				primaryEmailAddress,
				primaryandNonPrimaryEmailAddress,
				true,
				false,
				true,
				false,
				false
			);
			AcfrEmailService.sendEmailMain(
				false,
				'QFR_Reissue_Email',
				acc,
				primaryEmailAddress,
				primaryandNonPrimaryEmailAddress,
				true,
				false,
				false,
				true,
				false
			);
			AcfrEmailService.sendEmailMain(
				false,
				'QFR_Reissue_Email',
				acc,
				primaryEmailAddress,
				primaryandNonPrimaryEmailAddress,
				true,
				false,
				false,
				false,
				true
			);
			Test.stopTest();
			System.assert(emailSubject != '');
		}
	}

	@isTest
	static void testReissueTemplateConditions() {
		user finQAAssessor = [
			SELECT id
			FROM user
			WHERE isActive = TRUE
			LIMIT 1
		];
		System.runAs(finQAAssessor) {
			List<Case> rec = [
				SELECT Id, AccountId
				FROM Case
				ORDER BY createddate ASC
				LIMIT 1
			];
			List<Account> acc = [
				SELECT Id
				FROM Account
				WHERE Id = :rec[0].AccountId
			];
			String emailSubject = AcfrEmailService.getEmailSubject(
				rec[0].Id,
				'Case',
				'QFR_Reissue_Email'
			);
			String emailContent = AcfrEmailService.getEmailContent(
				rec[0].Id,
				'Case',
				'QFR_Reissue_Email'
			);
			String primaryEmailAddress = AcfrEmailService.getPrimaryEmailAddress(
				rec[0].Id
			);
			String nonPrimaryEmailAddress = AcfrEmailService.getNonPrimaryEmailAddress(
				rec[0].Id
			);
			String primaryandNonPrimaryEmailAddress = AcfrEmailService.getPrimaryandNonPrimaryEmailAddress(
				rec[0].Id,
				'test1@gmail.com'
			);
			emailContent = AcfrEmailService.hideConditions(
				emailContent,
				'TEST',
				true
			);
			emailContent = AcfrEmailService.hideConditions(
				emailContent,
				'TEST',
				false
			);
			List<String> invocableVariables = new List<String>();
			String var = 'recordId=' + acc[0].Id + ';';
			var = var + 'isStandard=true;';
			var = var + 'templateName=QFR_Reissue_Email;';
			var = var + 'toAddress=' + primaryEmailAddress + ';';
			var = var + 'ccAddress=' + primaryEmailAddress + ';';
			var = var + 'hasPrimaryMergeField=false;';
			var = var + 'toAddress1PrimaryOnly=false;';
			var = var + 'toAddressPrimaryAll=false;';
			var = var + 'toAddressAllContactRel=false;';
			var = var + 'toAddressVariable=false;';
			invocableVariables.add(var);
			AcfrEmailService.sendEmailMainInvocable(invocableVariables);
			Test.startTest();
			System.AssertEquals(primaryEmailAddress != null, true);
			AcfrEmailService.sendEmailMain(
				true,
				'QFR_Reissue_Email',
				rec,
				primaryEmailAddress,
				primaryandNonPrimaryEmailAddress,
				true,
				true,
				false,
				false,
				false
			);
			AcfrEmailService.sendEmailMain(
				true,
				'QFR_Reissue_Email',
				rec,
				primaryEmailAddress,
				primaryandNonPrimaryEmailAddress,
				true,
				false,
				true,
				false,
				false
			);
			AcfrEmailService.sendEmailMain(
				true,
				'QFR_Reissue_Email',
				rec,
				primaryEmailAddress,
				primaryandNonPrimaryEmailAddress,
				true,
				false,
				false,
				true,
				false
			);
			AcfrEmailService.sendEmailMain(
				true,
				'QFR_Reissue_Email',
				rec,
				primaryEmailAddress,
				primaryandNonPrimaryEmailAddress,
				true,
				false,
				false,
				false,
				true
			);

			AcfrEmailService.sendEmailMain(
				false,
				'QFR_Reissue_Email',
				rec,
				primaryEmailAddress,
				primaryandNonPrimaryEmailAddress,
				true,
				true,
				false,
				false,
				false
			);
			AcfrEmailService.sendEmailMain(
				false,
				'QFR_Reissue_Email',
				rec,
				primaryEmailAddress,
				primaryandNonPrimaryEmailAddress,
				true,
				false,
				true,
				false,
				false
			);
			AcfrEmailService.sendEmailMain(
				false,
				'QFR_Reissue_Email',
				rec,
				primaryEmailAddress,
				primaryandNonPrimaryEmailAddress,
				true,
				false,
				false,
				true,
				false
			);
			AcfrEmailService.sendEmailMain(
				false,
				'QFR_Reissue_Email',
				rec,
				primaryEmailAddress,
				primaryandNonPrimaryEmailAddress,
				true,
				false,
				false,
				false,
				true
			);

			Contact con = [SELECT Id FROM Contact LIMIT 1];
			AcfrEmailService.sendStandardSingleEmailMethod(
				rec[0].Id,
				con.Id,
				'QFR_Reissue_Email',
				TEST_EMAIL_DOT_COM,
				TEST_EMAIL_DOT_COM
			);

			AcfrEmailService.sendCustomSingleEmailMethod(
				rec[0].Id,
				'email body',
				TEST_EMAIL_DOT_COM,
				TEST_EMAIL_DOT_COM,
				'email subject'
			);

			Test.stopTest();
			System.assert(emailSubject != '');
			System.assert(nonPrimaryEmailAddress != '');
		}
	}
}
