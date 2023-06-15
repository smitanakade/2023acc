/**
 * @description       :
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             :
 * @last modified on  : 03-28-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 **/
@IsTest(isParallel=true)
private class DMLMockTest {
	private static final String EXPECTED_ISSUCCESS_TO_BE_TRUE = 'expected isSuccess() to be true, got: ';
	private static final String EXPECTED_GETID_TO_RETURN_QWER1234_BUT_GOT = 'expected getId() to return "qwer1234" but got: ';
	private static final String EXPECTED_ACCOUNTID_TO_BE_SET = 'expected accout.Id to be set';
	private static final String EXPECTED_RESULTS_TO_HAVE_SIZE = 'expected results to have size: ';
	private static final String EXPECTED_ISSUCCESS_TO_RETURN_TRUE = 'expected isSuccess() to return true';
	private static final String EXPECTED_INSERT_RECORD_CALL_COUNT_TO_BE_1_BUT_GOT = 'expected insertRecordCallCount to be 1, but got:';
	private static final String EXPECTED_GETID_TO_RETURN_THE_SOBJECT_ID = 'expected getId() to return the SObject ID';
	private static final String EXPECTED_DMLMOCKINSERTED_TO_CONTAIN_THE_INSERTED_OBJECT = 'expected DMLMock.inserted to contain the inserted object';
	private static final String EXPECTED_A_SAVERESULT_TOBE_RETURNED = 'expected a SaveResult to be returned';
	private static final String EXPECTED_INSERT_RECORD_ALLORNONE_CALL_COUNT_1_BUT_GOT = 'expected insertRecordAllOrNoneCallCount to be 1, but got: ';
	private static final String EXPECTED_INSERT_RECORD_OPTIONS_CALL_COUNT_1_BUT_GOT = 'expected insertRecordOptionsCallCount to be 1, but got: ';
	private static final String EXPECTED_INSERT_RECORDS_CALL_COUNT_1_BUT_GOT = 'expected insertRecordsCallCount to be 1, but got: ';
	private static final String SHOULD_HAVE_THROWN_A_NULLPOINTEREXCEPTION = 'should have thrown a NullPointerException';
	private static final String UPDATERECORDCOUNT_SHOULD_BE_1 = 'updateRecordCallCount should be 1';
	private static final String EXPECTED_DMLMOCKUPDATED_TO_CONTAIN_THE_UPDATED_OBJECT = 'expected DMLMock.updated to contain the updated object';
	private static final String EXPECTED_DMLMOCKUPDATED_TO_CONTAIN_THE_UPDATED_OBJECTS = 'expected DMLMock.updated to contain the updated objects';
	private static final String EXPECTED_DMLMOCKUPSERTED_TO_CONTAIN_UPSERTED_OBJECT = 'expected DMLMock.upserted to contain the upserted object';
	private static final String EXPECTED_DMLMOCKUPSERTED_TO_CONTAIN_UPSERTED_OBJECTS = 'expected DMLMock.upserted to contain the upserted objects';
	private static final String DELETED_RECORD_CALL_COUNT_SHOULD_BE_1 = 'deleteRecordCallCount should be 1';
	private static final String EXPECTED_DMLMOCK_DELETED_TO_CONTAIN_THE_DELETED_OBJECT_ID = 'expected DMLMock.deleted to contain the deleted object id';
	private static final String EXPECTED_DMLMOCK_DELETED_TO_CONTAIN_THE_DELETED_OBJECT_ID_1 = 'expected DMLMock.deleted to contain the deleted object Id';

	@IsTest
	static void testNewSaveResultShouldReturnASaveResult() {
		System.runAs(new User(Id = UserInfo.getUserId())) {
			Test.startTest();
			final Id fakeId = IdFaker.generateFor(Account.getSObjectType());
			final Database.SaveResult result = DMLMock.newSaveResult(
				true,
				fakeId
			);
			System.assertEquals(
				true,
				result.isSuccess(),
				EXPECTED_ISSUCCESS_TO_BE_TRUE + result.isSuccess()
			);
			System.assertEquals(
				fakeId,
				result.getId(),
				EXPECTED_GETID_TO_RETURN_QWER1234_BUT_GOT + result.getId()
			);
			Test.stopTest();
		}
	}

	@IsTest
	static void testInsertRecord() {
		System.runAs(new User(Id = UserInfo.getUserId())) {
			Test.startTest();
			final Account acc = new Account();

			final DMLMock myDML = new DMLMock();
			Database.SaveResult result = myDML.insertRecord(acc);

			System.assertNotEquals(null, acc.Id, EXPECTED_ACCOUNTID_TO_BE_SET);
			System.assertEquals(
				true,
				result.isSuccess(),
				EXPECTED_ISSUCCESS_TO_RETURN_TRUE
			);
			System.assertEquals(
				acc.Id,
				result.getId(),
				EXPECTED_GETID_TO_RETURN_THE_SOBJECT_ID
			);
			System.assert(
				myDML.inserted.contains(acc),
				EXPECTED_DMLMOCKINSERTED_TO_CONTAIN_THE_INSERTED_OBJECT
			);
			System.assertEquals(
				1,
				myDML.insertRecordCallCount,
				EXPECTED_INSERT_RECORD_CALL_COUNT_TO_BE_1_BUT_GOT +
				myDML.insertRecordCallCount
			);
			Test.stopTest();
		}
	}

	@IsTest
	static void testInsertRecordAllOrNone() {
		System.runAs(new User(Id = UserInfo.getUserId())) {
			Test.startTest();
			final Account acc = new Account();
			final DMLMock myDML = new DMLMock();
			Database.SaveResult result = myDML.insertRecord(acc, true);
			System.assertNotEquals(
				null,
				result,
				EXPECTED_A_SAVERESULT_TOBE_RETURNED
			);
			System.assert(
				myDML.inserted.contains(acc),
				EXPECTED_DMLMOCKINSERTED_TO_CONTAIN_THE_INSERTED_OBJECT
			);
			System.assertEquals(
				1,
				myDML.insertRecordAllOrNoneCallCount,
				EXPECTED_INSERT_RECORD_ALLORNONE_CALL_COUNT_1_BUT_GOT +
				myDML.insertRecordsAllOrNoneCallCount
			);
			Test.stopTest();
		}
	}

	@IsTest
	static void testInsertRecordOptions() {
		System.runAs(new User(Id = UserInfo.getUserId())) {
			Test.startTest();
			final Account acc = new Account();
			final DMLMock myDML = new DMLMock();
			Database.SaveResult result = myDML.insertRecord(
				acc,
				new Database.DMLOptions()
			);
			System.assertNotEquals(
				null,
				result,
				EXPECTED_A_SAVERESULT_TOBE_RETURNED
			);
			System.assert(
				myDML.inserted.contains(acc),
				EXPECTED_DMLMOCKINSERTED_TO_CONTAIN_THE_INSERTED_OBJECT
			);
			System.assertEquals(
				1,
				myDML.insertRecordOptionsCallCount,
				EXPECTED_INSERT_RECORD_OPTIONS_CALL_COUNT_1_BUT_GOT +
				myDML.insertRecordOptionsCallCount
			);
			Test.stopTest();
		}
	}

	@IsTest
	static void testInsertRecords() {
		System.runAs(new User(Id = UserInfo.getUserId())) {
			Test.startTest();
			final List<Account> accounts = new List<Account>();
			final Integer size = 5;

			for (Integer i = 0; i < size; i++) {
				accounts.add(new Account());
			}

			final DMLMock myDML = new DMLMock();
			List<Database.SaveResult> results = myDML.insertRecords(accounts);
			System.assertEquals(
				size,
				results.size(),
				EXPECTED_RESULTS_TO_HAVE_SIZE + size
			);
			System.assertEquals(
				1,
				myDML.insertRecordsCallCount,
				EXPECTED_INSERT_RECORDS_CALL_COUNT_1_BUT_GOT +
				myDML.insertRecordsCallCount
			);

			for (Account acc : accounts) {
				System.assert(
					myDML.inserted.contains(acc),
					EXPECTED_DMLMOCKINSERTED_TO_CONTAIN_THE_INSERTED_OBJECT
				);
			}
			Test.stopTest();
		}
	}

	@IsTest
	static void testInsertRecordsAllOrNone() {
		System.runAs(new User(Id = UserInfo.getUserId())) {
			Test.startTest();
			final List<Account> accounts = new List<Account>();
			final Integer size = 5;

			for (Integer i = 0; i < size; i++) {
				accounts.add(new Account());
			}

			final DMLMock myDML = new DMLMock();
			List<Database.SaveResult> results = myDML.insertRecords(
				accounts,
				true
			);
			System.assertEquals(
				size,
				results.size(),
				EXPECTED_RESULTS_TO_HAVE_SIZE + size
			);
			System.assertEquals(
				1,
				myDML.insertRecordsAllOrNoneCallCount,
				'expected insertRecordsAllOrNoneCallCount to be 1, but got: ' +
				myDML.insertRecordsAllOrNoneCallCount
			);

			for (Account acc : accounts) {
				System.assert(
					myDML.inserted.contains(acc),
					EXPECTED_DMLMOCKINSERTED_TO_CONTAIN_THE_INSERTED_OBJECT
				);
			}
			Test.stopTest();
		}
	}

	@IsTest
	static void testInsertRecordsOptions() {
		System.runAs(new User(Id = UserInfo.getUserId())) {
			Test.startTest();
			final List<Account> accounts = new List<Account>();
			final Integer size = 5;

			for (Integer i = 0; i < size; i++) {
				accounts.add(new Account());
			}

			final DMLMock myDML = new DMLMock();
			List<Database.SaveResult> results = myDML.insertRecords(
				accounts,
				new Database.DMLOptions()
			);
			System.assertEquals(
				size,
				results.size(),
				EXPECTED_RESULTS_TO_HAVE_SIZE + size
			);
			System.assertEquals(
				1,
				myDML.insertRecordsOptionsCallCount,
				'expected insertRecordsOptionsCallCount to be 1, but got: ' +
				myDML.insertRecordsOptionsCallCount
			);

			for (Account acc : accounts) {
				System.assert(
					myDML.inserted.contains(acc),
					EXPECTED_DMLMOCKINSERTED_TO_CONTAIN_THE_INSERTED_OBJECT
				);
			}
			Test.stopTest();
		}
	}

	@IsTest
	static void testInsertRecordWithNull() {
		System.runAs(new User(Id = UserInfo.getUserId())) {
			Test.startTest();
			final DMLMock myDML = new DMLMock();
			try {
				myDML.insertRecord(null);
				System.assert(false, SHOULD_HAVE_THROWN_A_NULLPOINTEREXCEPTION);
			} catch (NullPointerException e) {
				System.assert(true, 'expected');
				System.assertEquals(1, myDML.insertRecordCallCount);
			}
			Test.stopTest();
		}
	}

	@IsTest
	static void testUpdateRecord() {
		System.runAs(new User(Id = UserInfo.getUserId())) {
			Test.startTest();
			final Account acc = new Account();
			acc.Id = IdFaker.generateFor(Account.getSObjectType());

			final DMLMock myDML = new DMLMock();
			Database.SaveResult result = myDML.updateRecord(acc);

			System.assertEquals(
				true,
				result.isSuccess(),
				EXPECTED_ISSUCCESS_TO_RETURN_TRUE
			);
			System.assertEquals(
				1,
				myDML.updateRecordCallCount,
				UPDATERECORDCOUNT_SHOULD_BE_1
			);
			System.assert(
				myDML.updated.contains(acc),
				EXPECTED_DMLMOCKUPDATED_TO_CONTAIN_THE_UPDATED_OBJECT
			);
			Test.stopTest();
		}
	}

	@IsTest
	static void testUpdateRecordAllOrNone() {
		System.runAs(new User(Id = UserInfo.getUserId())) {
			Test.startTest();
			final Account acc = new Account();
			acc.Id = IdFaker.generateFor(Account.getSObjectType());

			final DMLMock myDML = new DMLMock();
			Database.SaveResult result = myDML.updateRecord(acc, true);
			System.assertEquals(
				1,
				myDML.updateRecordAllOrNoneCallCount,
				'updateRecordAllOrNoneCallCount should be 1'
			);

			System.assertEquals(
				true,
				result.isSuccess(),
				EXPECTED_ISSUCCESS_TO_RETURN_TRUE
			);
			System.assert(
				myDML.updated.contains(acc),
				EXPECTED_DMLMOCKUPDATED_TO_CONTAIN_THE_UPDATED_OBJECT
			);
			Test.stopTest();
		}
	}

	@IsTest
	static void testUpdateRecordOptions() {
		System.runAs(new User(Id = UserInfo.getUserId())) {
			Test.startTest();
			final Account acc = new Account();
			acc.Id = IdFaker.generateFor(Account.getSObjectType());

			final DMLMock myDML = new DMLMock();
			Database.SaveResult result = myDML.updateRecord(
				acc,
				new Database.DMLOptions()
			);
			System.assertEquals(
				1,
				myDML.updateRecordOptionsCallCount,
				'updateRecordOptionsCallCount should be 1'
			);

			System.assertEquals(
				true,
				result.isSuccess(),
				EXPECTED_ISSUCCESS_TO_RETURN_TRUE
			);
			System.assert(
				myDML.updated.contains(acc),
				EXPECTED_DMLMOCKUPDATED_TO_CONTAIN_THE_UPDATED_OBJECT
			);
			Test.stopTest();
		}
	}

	@IsTest
	static void testUpdateRecordWithNullRecord() {
		System.runAs(new User(Id = UserInfo.getUserId())) {
			Test.startTest();
			final DMLMock myDML = new DMLMock();
			try {
				myDML.updateRecord(null);
				System.assert(false, SHOULD_HAVE_THROWN_A_NULLPOINTEREXCEPTION);
			} catch (NullPointerException e) {
				System.assert(true, 'expected');
				System.assertEquals(
					1,
					myDML.updateRecordCallCount,
					UPDATERECORDCOUNT_SHOULD_BE_1
				);
			}
			Test.stopTest();
		}
	}

	@IsTest
	static void testUpdateRecordWithNullID() {
		System.runAs(new User(Id = UserInfo.getUserId())) {
			Test.startTest();
			final DMLMock myDML = new DMLMock();
			try {
				myDML.updateRecord(new Account());
				System.assert(false, 'should have thrown a DmlException');
			} catch (DmlException e) {
				System.assert(true, 'expected');
				System.assertEquals(
					1,
					myDML.updateRecordCallCount,
					UPDATERECORDCOUNT_SHOULD_BE_1
				);
			}
			Test.stopTest();
		}
	}

	@IsTest
	static void testUpdateRecords() {
		System.runAs(new User(Id = UserInfo.getUserId())) {
			Test.startTest();
			final List<Account> accounts = new List<Account>();
			final Integer size = 5;

			for (Integer i = 0; i < size; i++) {
				final Account acc = new Account();
				acc.Id = IdFaker.generateFor(Account.getSObjectType());
				accounts.add(acc);
			}

			final DMLMock myDML = new DMLMock();
			List<Database.SaveResult> results = myDML.updateRecords(accounts);
			System.assertEquals(
				1,
				myDML.updateRecordsCallCount,
				'updateRecordsCallCount should be 1'
			);
			System.assertEquals(
				size,
				results.size(),
				EXPECTED_RESULTS_TO_HAVE_SIZE + size
			);

			for (Account acc : accounts) {
				System.assert(
					myDML.updated.contains(acc),
					EXPECTED_DMLMOCKUPDATED_TO_CONTAIN_THE_UPDATED_OBJECTS
				);
			}
			Test.stopTest();
		}
	}

	@IsTest
	static void testUpdateRecordsAllOrNone() {
		System.runAs(new User(Id = UserInfo.getUserId())) {
			Test.startTest();
			final List<Account> accounts = new List<Account>();
			final Integer size = 5;

			for (Integer i = 0; i < size; i++) {
				final Account acc = new Account();
				acc.Id = IdFaker.generateFor(Account.getSObjectType());
				accounts.add(acc);
			}

			final DMLMock myDML = new DMLMock();
			List<Database.SaveResult> results = myDML.updateRecords(
				accounts,
				true
			);
			System.assertEquals(
				1,
				myDML.updateRecordsAllOrNoneCallCount,
				'updateRecordsAllOrNoneCallCount should be 1'
			);
			System.assertEquals(
				size,
				results.size(),
				EXPECTED_RESULTS_TO_HAVE_SIZE + size
			);

			for (Account acc : accounts) {
				System.assert(
					myDML.updated.contains(acc),
					EXPECTED_DMLMOCKUPDATED_TO_CONTAIN_THE_UPDATED_OBJECTS
				);
			}
			Test.stopTest();
		}
	}

	@IsTest
	static void testUpdateRecordsOptions() {
		System.runAs(new User(Id = UserInfo.getUserId())) {
			Test.startTest();
			final List<Account> accounts = new List<Account>();
			final Integer size = 5;

			for (Integer i = 0; i < size; i++) {
				final Account acc = new Account();
				acc.Id = IdFaker.generateFor(Account.getSObjectType());
				accounts.add(acc);
			}

			final DMLMock myDML = new DMLMock();
			List<Database.SaveResult> results = myDML.updateRecords(
				accounts,
				new Database.DMLOptions()
			);
			System.assertEquals(
				1,
				myDML.updateRecordsOptionsCallCount,
				'updateRecordsOptionsCallCount should be 1'
			);
			System.assertEquals(
				size,
				results.size(),
				EXPECTED_RESULTS_TO_HAVE_SIZE + size
			);

			for (Account acc : accounts) {
				System.assert(
					myDML.updated.contains(acc),
					EXPECTED_DMLMOCKUPDATED_TO_CONTAIN_THE_UPDATED_OBJECTS
				);
			}
			Test.stopTest();
		}
	}

	@IsTest
	static void testUpsertNullRecord() {
		System.runAs(new User(Id = UserInfo.getUserId())) {
			Test.startTest();
			final DMLMock myDML = new DMLMock();
			try {
				myDML.upsertRecord((Account) null);
				System.assert(false, SHOULD_HAVE_THROWN_A_NULLPOINTEREXCEPTION);
			} catch (NullPointerException e) {
				System.assert(true, 'expected');
			}
			Test.stopTest();
		}
	}

	@IsTest
	static void testUpsertRecord() {
		System.runAs(new User(Id = UserInfo.getUserId())) {
			Test.startTest();
			final Account acc = new Account();
			acc.Id = IdFaker.generateFor(Account.getSObjectType());

			final DMLMock myDML = new DMLMock();
			Database.UpsertResult result = myDML.upsertRecord(acc);
			System.assertEquals(
				1,
				myDML.upsertRecordCallCount,
				'upsertRecordCallCount should be 1'
			);

			System.assertEquals(
				true,
				result.isSuccess(),
				EXPECTED_ISSUCCESS_TO_RETURN_TRUE
			);
			System.assert(
				myDML.upserted.contains(acc),
				EXPECTED_DMLMOCKUPSERTED_TO_CONTAIN_UPSERTED_OBJECT
			);
			Test.stopTest();
		}
	}

	@IsTest
	static void testUpsertRecordAllOrNone() {
		System.runAs(new User(Id = UserInfo.getUserId())) {
			Test.startTest();
			final Account acc = new Account();

			final DMLMock myDML = new DMLMock();
			Database.UpsertResult result = myDML.upsertRecord(acc, true);
			System.assertEquals(
				1,
				myDML.upsertRecordAllOrNoneCallCount,
				'upsertRecordAllOrNoneCallCount should be 1'
			);

			System.assertNotEquals(
				null,
				acc.Id,
				'expected account.Id not to be null.'
			);
			System.assertEquals(
				true,
				result.isSuccess(),
				EXPECTED_ISSUCCESS_TO_RETURN_TRUE
			);
			System.assert(
				myDML.upserted.contains(acc),
				EXPECTED_DMLMOCKUPSERTED_TO_CONTAIN_UPSERTED_OBJECT
			);
			Test.stopTest();
		}
	}

	@IsTest
	static void testUpsertRecordWithField() {
		System.runAs(new User(Id = UserInfo.getUserId())) {
			Test.startTest();
			final Account acc = new Account();
			acc.Id = IdFaker.generateFor(Account.getSObjectType());

			final DMLMock myDML = new DMLMock();
			Database.UpsertResult result = myDML.upsertRecord(
				acc,
				Account.Name
			);
			System.assertEquals(
				1,
				myDML.upsertRecordWithFieldCallCount,
				'upsertRecordWithFieldCallCount should be 1'
			);

			System.assertEquals(
				true,
				result.isSuccess(),
				EXPECTED_ISSUCCESS_TO_RETURN_TRUE
			);
			System.assert(
				myDML.upserted.contains(acc),
				EXPECTED_DMLMOCKUPSERTED_TO_CONTAIN_UPSERTED_OBJECT
			);
			Test.stopTest();
		}
	}

	@IsTest
	static void testUpsertRecordWithFieldAllOrNone() {
		System.runAs(new User(Id = UserInfo.getUserId())) {
			Test.startTest();
			final Account acc = new Account();

			final DMLMock myDML = new DMLMock();
			Database.UpsertResult result = myDML.upsertRecord(
				acc,
				Account.Name,
				true
			);
			System.assertEquals(
				1,
				myDML.upsertRecordWithFieldAllOrNoneCallCount,
				'upsertRecordWithFieldAllOrNoneCallCount should be 1'
			);

			System.assertNotEquals(
				null,
				acc.Id,
				'expected account.Id not to be null.'
			);
			System.assertEquals(
				true,
				result.isSuccess(),
				EXPECTED_ISSUCCESS_TO_RETURN_TRUE
			);
			System.assert(
				myDML.upserted.contains(acc),
				'expected DMLMock.upserted to contain the updated object'
			);
			Test.stopTest();
		}
	}

	@IsTest
	static void testUpsertRecords() {
		System.runAs(new User(Id = UserInfo.getUserId())) {
			Test.startTest();
			final List<Account> accounts = new List<Account>();
			final Integer size = 5;

			for (Integer i = 0; i < size; i++) {
				final Account acc = new Account();
				acc.Id = IdFaker.generateFor(Account.getSObjectType());
				accounts.add(acc);
			}

			final DMLMock myDML = new DMLMock();
			List<Database.UpsertResult> results = myDML.upsertRecords(accounts);
			System.assertEquals(
				1,
				myDML.upsertRecordsCallCount,
				'upsertRecordsCallCount should be 1'
			);
			System.assertEquals(
				size,
				results.size(),
				EXPECTED_RESULTS_TO_HAVE_SIZE + size
			);

			for (Account acc : accounts) {
				System.assert(
					myDML.upserted.contains(acc),
					EXPECTED_DMLMOCKUPSERTED_TO_CONTAIN_UPSERTED_OBJECTS
				);
			}
			Test.stopTest();
		}
	}

	@IsTest
	static void testUpsertRecordsAllOrNone() {
		System.runAs(new User(Id = UserInfo.getUserId())) {
			Test.startTest();
			final List<Account> accounts = new List<Account>();
			final Integer size = 5;

			for (Integer i = 0; i < size; i++) {
				final Account acc = new Account();
				acc.Id = IdFaker.generateFor(Account.getSObjectType());
				accounts.add(acc);
			}

			final DMLMock myDML = new DMLMock();
			List<Database.UpsertResult> results = myDML.upsertRecords(
				accounts,
				true
			);
			System.assertEquals(
				1,
				myDML.upsertRecordsAllOrNoneCallCount,
				'upsertRecordsAllOrNoneCallCount should be 1'
			);
			System.assertEquals(
				size,
				results.size(),
				EXPECTED_RESULTS_TO_HAVE_SIZE + size
			);

			for (Account acc : accounts) {
				System.assert(
					myDML.upserted.contains(acc),
					EXPECTED_DMLMOCKUPSERTED_TO_CONTAIN_UPSERTED_OBJECTS
				);
			}
			Test.stopTest();
		}
	}

	@IsTest
	static void testUpsertRecordsWithField() {
		System.runAs(new User(Id = UserInfo.getUserId())) {
			Test.startTest();
			final List<Account> accounts = new List<Account>();
			final Integer size = 5;

			for (Integer i = 0; i < size; i++) {
				final Account acc = new Account();
				acc.Id = IdFaker.generateFor(Account.getSObjectType());
				accounts.add(acc);
			}

			final DMLMock myDML = new DMLMock();
			List<Database.UpsertResult> results = myDML.upsertRecords(
				accounts,
				Account.Name
			);
			System.assertEquals(
				1,
				myDML.upsertRecordsWithFieldCallCount,
				'upsertRecordsWithFieldCallCount should be 1'
			);
			System.assertEquals(
				size,
				results.size(),
				EXPECTED_RESULTS_TO_HAVE_SIZE + size
			);

			for (Account acc : accounts) {
				System.assert(
					myDML.upserted.contains(acc),
					EXPECTED_DMLMOCKUPSERTED_TO_CONTAIN_UPSERTED_OBJECTS
				);
			}
			Test.stopTest();
		}
	}

	@IsTest
	static void testUpsertRecordsWithFieldAllOrNone() {
		System.runAs(new User(Id = UserInfo.getUserId())) {
			Test.startTest();
			final List<Account> accounts = new List<Account>();
			final Integer size = 5;

			for (Integer i = 0; i < size; i++) {
				final Account acc = new Account();
				acc.Id = IdFaker.generateFor(Account.getSObjectType());
				accounts.add(acc);
			}

			final DMLMock myDML = new DMLMock();
			List<Database.UpsertResult> results = myDML.upsertRecords(
				accounts,
				Account.Name,
				true
			);
			System.assertEquals(
				1,
				myDML.upsertRecordsWithFieldAllOrNoneCallCount,
				'upsertRecordsWithFieldAllOrNoneCallCount should be 1'
			);
			System.assertEquals(
				size,
				results.size(),
				EXPECTED_RESULTS_TO_HAVE_SIZE + size
			);

			for (Account acc : accounts) {
				System.assert(
					myDML.upserted.contains(acc),
					EXPECTED_DMLMOCKUPSERTED_TO_CONTAIN_UPSERTED_OBJECTS
				);
			}
			Test.stopTest();
		}
	}

	@IsTest
	static void testDeleteNullRecord() {
		System.runAs(new User(Id = UserInfo.getUserId())) {
			Test.startTest();
			final DMLMock myDML = new DMLMock();
			try {
				myDML.deleteRecord((Account) null);
				System.assert(false, SHOULD_HAVE_THROWN_A_NULLPOINTEREXCEPTION);
			} catch (NullPointerException e) {
				System.assert(true, 'expected');
			}
			Test.stopTest();
		}
	}

	@IsTest
	static void testDeleteNullRecordId() {
		System.runAs(new User(Id = UserInfo.getUserId())) {
			Test.startTest();
			final DMLMock myDML = new DMLMock();
			try {
				myDML.deleteRecord((Id) null);
				System.assert(false, SHOULD_HAVE_THROWN_A_NULLPOINTEREXCEPTION);
			} catch (NullPointerException e) {
				System.assert(true, 'expected');
			}
			Test.stopTest();
		}
	}

	@IsTest
	static void testDeleteRecord() {
		System.runAs(new User(Id = UserInfo.getUserId())) {
			Test.startTest();
			final Account acc = new Account();
			acc.Id = IdFaker.generateFor(Account.getSObjectType());

			final DMLMock myDML = new DMLMock();
			Database.DeleteResult result = myDML.deleteRecord(acc);
			System.assertEquals(
				1,
				myDML.deleteRecordCallCount,
				DELETED_RECORD_CALL_COUNT_SHOULD_BE_1
			);

			System.assertEquals(
				true,
				result.isSuccess(),
				EXPECTED_ISSUCCESS_TO_RETURN_TRUE
			);
			System.assert(
				myDML.deleted.contains(acc.Id),
				EXPECTED_DMLMOCK_DELETED_TO_CONTAIN_THE_DELETED_OBJECT_ID
			);
			Test.stopTest();
		}
	}

	@IsTest
	static void testDeleteRecordId() {
		System.runAs(new User(Id = UserInfo.getUserId())) {
			Test.startTest();
			final Account acc = new Account();
			acc.Id = IdFaker.generateFor(Account.getSObjectType());

			final DMLMock myDML = new DMLMock();
			Database.DeleteResult result = myDML.deleteRecord(acc.Id);
			System.assertEquals(
				1,
				myDML.deleteRecordIdCallCount,
				DELETED_RECORD_CALL_COUNT_SHOULD_BE_1
			);

			System.assertEquals(
				true,
				result.isSuccess(),
				EXPECTED_ISSUCCESS_TO_RETURN_TRUE
			);
			System.assert(
				myDML.deleted.contains(acc.Id),
				EXPECTED_DMLMOCK_DELETED_TO_CONTAIN_THE_DELETED_OBJECT_ID
			);
			Test.stopTest();
		}
	}

	@IsTest
	static void testDeleteRecordAllOrNone() {
		System.runAs(new User(Id = UserInfo.getUserId())) {
			Test.startTest();
			final Account acc = new Account();
			acc.Id = IdFaker.generateFor(Account.getSObjectType());

			final DMLMock myDML = new DMLMock();
			Database.DeleteResult result = myDML.deleteRecord(acc, true);
			System.assertEquals(
				1,
				myDML.deleteRecordAllOrNoneCallCount,
				DELETED_RECORD_CALL_COUNT_SHOULD_BE_1
			);

			System.assertEquals(
				true,
				result.isSuccess(),
				EXPECTED_ISSUCCESS_TO_RETURN_TRUE
			);
			System.assert(
				myDML.deleted.contains(acc.Id),
				EXPECTED_DMLMOCK_DELETED_TO_CONTAIN_THE_DELETED_OBJECT_ID
			);
			Test.stopTest();
		}
	}

	@IsTest
	static void testDeleteRecordIdAllOrNone() {
		System.runAs(new User(Id = UserInfo.getUserId())) {
			Test.startTest();
			final Account acc = new Account();
			acc.Id = IdFaker.generateFor(Account.getSObjectType());

			final DMLMock myDML = new DMLMock();
			Database.DeleteResult result = myDML.deleteRecord(acc.Id, true);
			System.assertEquals(
				1,
				myDML.deleteRecordIdAllOrNoneCallCount,
				DELETED_RECORD_CALL_COUNT_SHOULD_BE_1
			);

			System.assertEquals(
				true,
				result.isSuccess(),
				EXPECTED_ISSUCCESS_TO_RETURN_TRUE
			);
			System.assert(
				myDML.deleted.contains(acc.Id),
				EXPECTED_DMLMOCK_DELETED_TO_CONTAIN_THE_DELETED_OBJECT_ID
			);
			Test.stopTest();
		}
	}

	@IsTest
	static void testDeleteRecords() {
		System.runAs(new User(Id = UserInfo.getUserId())) {
			Test.startTest();
			final List<Account> accounts = new List<Account>();
			final Integer size = 5;

			for (Integer i = 0; i < size; i++) {
				final Account acc = new Account();
				acc.Id = IdFaker.generateFor(Account.getSObjectType());
				accounts.add(acc);
			}

			final DMLMock myDML = new DMLMock();

			List<Database.DeleteResult> results = myDML.deleteRecords(accounts);
			System.assertEquals(
				1,
				myDML.deleteRecordsCallCount,
				'deleteRecordsCallCount should be 1'
			);
			System.assertEquals(
				size,
				results.size(),
				EXPECTED_RESULTS_TO_HAVE_SIZE + size
			);

			for (Account acc : accounts) {
				System.assert(
					myDML.deleted.contains(acc.Id),
					EXPECTED_DMLMOCK_DELETED_TO_CONTAIN_THE_DELETED_OBJECT_ID_1
				);
			}
			Test.stopTest();
		}
	}

	@IsTest
	static void testDeleteRecordsAllOrNone() {
		System.runAs(new User(Id = UserInfo.getUserId())) {
			Test.startTest();
			final List<Account> accounts = new List<Account>();
			final Integer size = 5;

			for (Integer i = 0; i < size; i++) {
				final Account acc = new Account();
				acc.Id = IdFaker.generateFor(Account.getSObjectType());
				accounts.add(acc);
			}

			final DMLMock myDML = new DMLMock();

			List<Database.DeleteResult> results = myDML.deleteRecords(
				accounts,
				true
			);
			System.assertEquals(
				1,
				myDML.deleteRecordsAllOrNoneCallCount,
				'deleteRecordsAllOrNoneCallCount should be 1'
			);
			System.assertEquals(
				size,
				results.size(),
				EXPECTED_RESULTS_TO_HAVE_SIZE + size
			);

			for (Account acc : accounts) {
				System.assert(
					myDML.deleted.contains(acc.Id),
					EXPECTED_DMLMOCK_DELETED_TO_CONTAIN_THE_DELETED_OBJECT_ID_1
				);
			}
			Test.stopTest();
		}
	}

	@IsTest
	static void testDeleteRecordIds() {
		System.runAs(new User(Id = UserInfo.getUserId())) {
			Test.startTest();
			final List<Id> accountIds = new List<Id>();
			final Integer size = 5;

			for (Integer i = 0; i < size; i++) {
				accountIds.add(IdFaker.generateFor(Account.getSObjectType()));
			}

			final DMLMock myDML = new DMLMock();

			List<Database.DeleteResult> results = myDML.deleteRecords(
				accountIds
			);
			System.assertEquals(
				1,
				myDML.deleteRecordIdsCallCount,
				'deleteRecordIdsCallCount should be 1'
			);
			System.assertEquals(
				size,
				results.size(),
				EXPECTED_RESULTS_TO_HAVE_SIZE + size
			);

			for (Id accountID : accountIDs) {
				System.assert(
					myDML.deleted.contains(accountID),
					EXPECTED_DMLMOCK_DELETED_TO_CONTAIN_THE_DELETED_OBJECT_ID_1
				);
			}
			Test.stopTest();
		}
	}

	@IsTest
	static void testDeleteRecordIdsAllOrNone() {
		System.runAs(new User(Id = UserInfo.getUserId())) {
			Test.startTest();
			final List<Id> accountIds = new List<Id>();
			final Integer size = 5;

			for (Integer i = 0; i < size; i++) {
				accountIds.add(IdFaker.generateFor(Account.getSObjectType()));
			}

			final DMLMock myDML = new DMLMock();

			List<Database.DeleteResult> results = myDML.deleteRecords(
				accountIds,
				true
			);
			System.assertEquals(
				1,
				myDML.deleteRecordIdsAllOrNoneCallCount,
				'deleteRecordIdsAllOrNoneCallCount should be 1'
			);
			System.assertEquals(
				size,
				results.size(),
				EXPECTED_RESULTS_TO_HAVE_SIZE + size
			);

			for (Id accountID : accountIDs) {
				System.assert(
					myDML.deleted.contains(accountID),
					EXPECTED_DMLMOCK_DELETED_TO_CONTAIN_THE_DELETED_OBJECT_ID_1
				);
			}
			Test.stopTest();
		}
	}

	@IsTest
	static void testDeleteNullRecords() {
		System.runAs(new User(Id = UserInfo.getUserId())) {
			Test.startTest();
			final DMLMock myDML = new DMLMock();
			try {
				myDML.deleteRecords((List<SObject>) null);
				System.assert(false, SHOULD_HAVE_THROWN_A_NULLPOINTEREXCEPTION);
			} catch (NullPointerException e) {
				System.assert(true, 'expected');
			}
			Test.stopTest();
		}
	}

	@IsTest
	static void testDeleteNullRecordIds() {
		System.runAs(new User(Id = UserInfo.getUserId())) {
			Test.startTest();
			final DMLMock myDML = new DMLMock();
			try {
				myDML.deleteRecords((List<Id>) null);
				System.assert(false, SHOULD_HAVE_THROWN_A_NULLPOINTEREXCEPTION);
			} catch (NullPointerException e) {
				System.assert(true, 'expected');
			}
			Test.stopTest();
		}
	}
}
