@isTest
private class AcfrSendOverDueEmailControllerTest {
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
	static void testFinalSendOverDueEmail() {
		User adminUser = [SELECT id FROM user WHERE isActive = TRUE LIMIT 1];
		Reporting_Period__c rp = [
			SELECT
				id,
				Start_Date__c,
				End_Date__c,
				QFR_Lock_Date__c,
				QFR_Reporting_Due_Date__c
			FROM Reporting_Period__c
			LIMIT 1
		];
		rp.End_Date__c = Date.Today().addDays(-18);
		update rp;
		System.debug(
			'case:' + [SELECT Id, Status, Reporting_Due_Date__c FROM Case]
		);
		System.debug(
			'rp:' +
			[
				SELECT Id, End_Date__c, QFR_Reporting_Due_Date__c
				FROM Reporting_Period__c
			]
		);
		try {
			System.runAs(adminUser) {
				Test.StartTest();
				Date dueDateFinal = date.today().addDays(-14);
				List<Case> rec = [
					SELECT Id, Status, Reporting_Due_Date__c
					FROM Case
					WHERE
						SkipLateSubmissionEmail__c != 'Yes'
						AND Status != 'Submitted'
						AND Status != 'Re-Submitted'
				];
				System.assertEquals(rec.size() > 0, true);
				AcfrSendOverDueEmailController.sendOverDueEmail();
				Test.stopTest();
			}
		} catch (Exception e) {
			dohagedcare.logger.error(e.getMessage(), e, 'QFR').log();
		}
	}
	@isTest
	static void testSendOverDueEmail() {
		User adminUser = [SELECT id FROM user WHERE isActive = TRUE LIMIT 1];
		Reporting_Period__c rp = [
			SELECT
				id,
				Start_Date__c,
				End_Date__c,
				QFR_Lock_Date__c,
				QFR_Reporting_Due_Date__c
			FROM Reporting_Period__c
			LIMIT 1
		];
		try {
			System.runAs(adminUser) {
				Test.StartTest();
				Date dueDateFirst = date.today().addDays(-13);
				List<Case> rec = [
					SELECT Id, Status, Reporting_Due_Date__c
					FROM Case
					WHERE
						SkipLateSubmissionEmail__c != 'Yes'
						AND Status != 'Submitted'
						AND Status != 'Re-Submitted'
						AND Reporting_Due_Date__c >= :rp.QFR_Reporting_Due_Date__c
						AND Reporting_Due_Date__c < today
				];
				System.assertEquals(rec.size() > 0, true);
				AcfrSendOverDueEmailController.sendOverDueEmail();
				Test.stopTest();
			}
		} catch (Exception e) {
			dohagedcare.logger.error(e.getMessage(), e, 'QFR').log();
		}
	}

	@isTest
	static void testGetRecordCount() {
		User adminUser = [SELECT id FROM user WHERE isActive = TRUE LIMIT 1];
		Reporting_Period__c rp = [
			SELECT
				id,
				Start_Date__c,
				End_Date__c,
				QFR_Lock_Date__c,
				QFR_Reporting_Due_Date__c
			FROM Reporting_Period__c
			LIMIT 1
		];
		try {
			System.runAs(adminUser) {
				Test.StartTest();
				Date dueDateFirst = date.today().addDays(-13);
				List<Case> rec = [
					SELECT Id, Status, Reporting_Due_Date__c
					FROM Case
					WHERE
						SkipLateSubmissionEmail__c != 'Yes'
						AND Status != 'Submitted'
						AND Status != 'Re-Submitted'
						AND Reporting_Due_Date__c >= :rp.QFR_Reporting_Due_Date__c
						AND Reporting_Due_Date__c < today
				];
				System.assertEquals(rec.size() > 0, true);
				List<String> recSize = AcfrSendOverDueEmailController.getRecordCount();
				System.assertEquals(rec.size(), Integer.valueOf(recSize[0]));
				Test.stopTest();
			}
		} catch (Exception e) {
			dohagedcare.logger.error(e.getMessage(), e, 'QFR').log();
		}
	}
}
