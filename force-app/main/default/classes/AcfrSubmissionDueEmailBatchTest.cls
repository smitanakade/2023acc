@isTest
private class AcfrSubmissionDueEmailBatchTest {
	@testSetup
	static void setup() {
		User adminUser = TestDataFactory.createSystemAdminUser();
		UserRole userrole = [
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
			rp1.End_Date__c = Date.Today().addDays(5);
			insert rp1;

			Id RecordTypeId = [
				SELECT Id
				FROM RecordType
				WHERE SobjectType = 'Case' AND IsActive = TRUE AND Name = 'QFR'
				LIMIT 1
			]
			.id;

			Case cs = new Case(
				Status = 'New',
				AccountId = acc[0].Id,
				SkipLateSubmissionEmail__c = 'No',
				Reporting_Period__c = rp1.Id,
				RecordTypeId = RecordTypeId
			);
			insert cs;
		}
	}

	@IsTest
	static void testSubmissionDueEmailBatch() {
		User adminUser = TestDataFactory.createSystemAdminUser();
		System.runAs(adminUser) {
			Test.startTest();
			Date dueDate = date.today().addDays(5);
			List<Case> rec = [
				SELECT Id, AccountId
				FROM Case
				WHERE Reporting_Due_Date__c = :dueDate AND AccountId != NULL
			];
			AcfrSubmissionDueEmailBatch b = new AcfrSubmissionDueEmailBatch();
			Database.executeBatch(b);

			System.AssertEquals(rec.size() > 0, true);
			Test.stopTest();
		}
	}
}
