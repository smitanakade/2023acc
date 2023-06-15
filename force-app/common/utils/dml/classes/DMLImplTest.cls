/**
 * @description test for DMLImpl.
 *
 * Note: tests use Individual for testing as it
 * is unlikely to have been customized on the org or
 * Test.stopTest();}
 * have triggers associated to it.
 */
@IsTest(isParallel=true)
private class DMLImplTest {
	private static final String SHOULD_HAVE_SAVED_SUCCESSFULLY = 'should have been saved successfully';
	private static final String SHOULD_HAVE_RETURNED_2_RESULTS = 'should have returned 2 results';
	private static final String EXEPECTED_RESULTS_SIZE_SAME_AS_UPDATED_OBJECTS_SIZE = 'expected results size to be the same as updated objects size';
	private static final String SHOULD_HAVE_ASSIGNED_AN_ID = 'should have assigned an id.';
	private static final String SHOULD_HAVE_RETURNED_12_RESULTS = 'should have returned 12 results';
	@IsTest
	static void testInsertRecord() {
		System.runAs(new User(Id = UserInfo.getUserId())) {
			Test.startTest();
			final Individual i = new Individual();
			i.FirstName = 'John';
			i.LastName = 'Doe';

			DML dml = new DMLImpl();
			final Database.SaveResult result = dml.insertRecord(i);

			System.assert(result.success, SHOULD_HAVE_SAVED_SUCCESSFULLY);
			Test.stopTest();
		}
	}

	@IsTest
	static void testInsertRecordWithAllOrNone() {
		System.runAs(new User(Id = UserInfo.getUserId())) {
			Test.startTest();
			final Individual i = new Individual();
			i.FirstName = 'John';
			i.LastName = 'Doe';

			DML dml = new DMLImpl();
			final Database.SaveResult result = dml.insertRecord(i, true);

			System.assert(result.success, SHOULD_HAVE_SAVED_SUCCESSFULLY);
			Test.stopTest();
		}
	}

	@IsTest
	static void testInsertRecordWithOptions() {
		System.runAs(new User(Id = UserInfo.getUserId())) {
			Test.startTest();
			final Individual i = new Individual();
			i.FirstName = 'John';
			i.LastName = 'Doe';

			DML dml = new DMLImpl();
			final Database.SaveResult result = dml.insertRecord(
				i,
				new Database.DMLOptions()
			);

			System.assert(result.success, SHOULD_HAVE_SAVED_SUCCESSFULLY);
			Test.stopTest();
		}
	}

	@IsTest
	static void testInsertRecords() {
		System.runAs(new User(Id = UserInfo.getUserId())) {
			Test.startTest();
			final List<Individual> individuals = new List<Individual>{
				new Individual(FirstName = 'John', LastName = 'Doe'),
				new Individual(FirstName = 'Jane', LastName = 'Doe')
			};

			DML dml = new DMLImpl();
			final List<Database.SaveResult> results = dml.insertRecords(
				individuals
			);
			System.assertEquals(
				individuals.size(),
				results.size(),
				SHOULD_HAVE_RETURNED_2_RESULTS
			);

			for (Database.SaveResult result : results) {
				System.assert(result.success, SHOULD_HAVE_SAVED_SUCCESSFULLY);
			}
			Test.stopTest();
		}
	}

	@IsTest
	static void testInsertRecordsAllOrNone() {
		System.runAs(new User(Id = UserInfo.getUserId())) {
			Test.startTest();
			final List<Individual> individuals = new List<Individual>{
				new Individual(FirstName = 'John', LastName = 'Doe'),
				new Individual(FirstName = 'Jane', LastName = 'Doe')
			};

			DML dml = new DMLImpl();
			final List<Database.SaveResult> results = dml.insertRecords(
				individuals,
				true
			);
			System.assertEquals(
				individuals.size(),
				results.size(),
				SHOULD_HAVE_RETURNED_2_RESULTS
			);

			for (Database.SaveResult result : results) {
				System.assert(result.success, SHOULD_HAVE_SAVED_SUCCESSFULLY);
			}
			Test.stopTest();
		}
	}

	@IsTest
	static void testInsertRecordsOptions() {
		System.runAs(new User(Id = UserInfo.getUserId())) {
			Test.startTest();
			final List<Individual> individuals = new List<Individual>{
				new Individual(FirstName = 'John', LastName = 'Doe'),
				new Individual(FirstName = 'Jane', LastName = 'Doe')
			};

			DML dml = new DMLImpl();
			final List<Database.SaveResult> results = dml.insertRecords(
				individuals,
				new Database.DMLOptions()
			);
			System.assertEquals(
				individuals.size(),
				results.size(),
				SHOULD_HAVE_RETURNED_2_RESULTS
			);

			for (Database.SaveResult result : results) {
				System.assert(result.success, SHOULD_HAVE_SAVED_SUCCESSFULLY);
			}
			Test.stopTest();
		}
	}

	@IsTest
	static void testInsertWithChunks() {
		System.runAs(new User(Id = UserInfo.getUserId())) {
			Test.startTest();
			final List<Individual> individuals = new List<Individual>{
				new Individual(FirstName = 'John1', LastName = 'Doe'),
				new Individual(FirstName = 'Jane2', LastName = 'Doe'),
				new Individual(FirstName = 'Jane3', LastName = 'Doe'),
				new Individual(FirstName = 'John4', LastName = 'Doe'),
				new Individual(FirstName = 'Jane5', LastName = 'Doe'),
				new Individual(FirstName = 'Jane6', LastName = 'Doe'),
				new Individual(FirstName = 'Jane7', LastName = 'Doe'),
				new Individual(FirstName = 'Jane8', LastName = 'Doe'),
				new Individual(FirstName = 'Jane9', LastName = 'Doe'),
				new Individual(FirstName = 'Jane10', LastName = 'Doe'),
				new Individual(FirstName = 'Jane11', LastName = 'Doe'),
				new Individual(FirstName = 'Jane12', LastName = 'Doe')
			};

			DML dml = new DMLImpl();
			final List<Database.SaveResult> results = dml.insertRecords(
				individuals
			);
			System.assertEquals(
				individuals.size(),
				results.size(),
				SHOULD_HAVE_RETURNED_12_RESULTS
			);

			// TODO: check that the order of 'individuals' has not changed.

			for (Database.SaveResult result : results) {
				System.assert(result.success, SHOULD_HAVE_SAVED_SUCCESSFULLY);
			}
			Test.stopTest();
		}
	}

	@IsTest
	static void testUpdateRecord() {
		System.runAs(new User(Id = UserInfo.getUserId())) {
			Test.startTest();
			final Individual i = new Individual(
				FirstName = 'John',
				LastName = 'Doe'
			);
			DML dml = new DMLImpl();
			Database.SaveResult result = dml.insertRecord(i);

			i.FirstName = 'Jane';
			result = dml.updateRecord(i);
			System.assert(result.success, SHOULD_HAVE_SAVED_SUCCESSFULLY);
			Test.stopTest();
		}
	}

	@IsTest
	static void testUpdateRecordAllOrNone() {
		System.runAs(new User(Id = UserInfo.getUserId())) {
			Test.startTest();
			final Individual i = new Individual(
				FirstName = 'John',
				LastName = 'Doe'
			);
			DML dml = new DMLImpl();
			Database.SaveResult result = dml.insertRecord(i);

			i.FirstName = 'Jane';
			result = dml.updateRecord(i, true);
			System.assert(result.success, SHOULD_HAVE_SAVED_SUCCESSFULLY);
			Test.stopTest();
		}
	}

	@IsTest
	static void testUpdateRecordOptions() {
		System.runAs(new User(Id = UserInfo.getUserId())) {
			Test.startTest();
			final Individual i = new Individual(
				FirstName = 'John',
				LastName = 'Doe'
			);
			DML dml = new DMLImpl();
			Database.SaveResult result = dml.insertRecord(i);

			i.FirstName = 'Jane';
			result = dml.updateRecord(i, new Database.DMLOptions());
			System.assert(result.success, SHOULD_HAVE_SAVED_SUCCESSFULLY);
			Test.stopTest();
		}
	}

	@IsTest
	static void testUpdateRecords() {
		System.runAs(new User(Id = UserInfo.getUserId())) {
			Test.startTest();
			final List<Individual> individuals = new List<Individual>{
				new Individual(FirstName = 'John', LastName = 'Doe'),
				new Individual(FirstName = 'Jane', LastName = 'Doe')
			};

			DML dml = new DMLImpl();
			dml.insertRecords(individuals);

			for (Individual i : individuals) {
				i.FirstName = 'Jane';
			}

			List<Database.SaveResult> results = dml.updateRecords(individuals);
			System.assertEquals(
				individuals.size(),
				results.size(),
				EXEPECTED_RESULTS_SIZE_SAME_AS_UPDATED_OBJECTS_SIZE
			);
			for (Database.SaveResult result : results) {
				System.assertEquals(true, result.success);
			}
			Test.stopTest();
		}
	}

	@IsTest
	static void testUpdateRecordsAllOrNone() {
		System.runAs(new User(Id = UserInfo.getUserId())) {
			Test.startTest();
			final List<Individual> individuals = new List<Individual>{
				new Individual(FirstName = 'John', LastName = 'Doe'),
				new Individual(FirstName = 'Jane', LastName = 'Doe')
			};

			DML dml = new DMLImpl();
			dml.insertRecords(individuals);

			for (Individual i : individuals) {
				i.FirstName = 'Jane';
			}

			List<Database.SaveResult> results = dml.updateRecords(
				individuals,
				false
			);
			System.assertEquals(
				individuals.size(),
				results.size(),
				EXEPECTED_RESULTS_SIZE_SAME_AS_UPDATED_OBJECTS_SIZE
			);
			for (Database.SaveResult result : results) {
				System.assertEquals(true, result.success);
			}
			Test.stopTest();
		}
	}

	@IsTest
	static void testUpdateRecordsDMLOptions() {
		System.runAs(new User(Id = UserInfo.getUserId())) {
			Test.startTest();
			final List<Individual> individuals = new List<Individual>{
				new Individual(FirstName = 'John', LastName = 'Doe'),
				new Individual(FirstName = 'Jane', LastName = 'Doe')
			};

			DML dml = new DMLImpl();
			dml.insertRecords(individuals);

			for (Individual i : individuals) {
				i.FirstName = 'Jane';
			}

			List<Database.SaveResult> results = dml.updateRecords(
				individuals,
				new Database.DMLOptions()
			);
			System.assertEquals(
				individuals.size(),
				results.size(),
				EXEPECTED_RESULTS_SIZE_SAME_AS_UPDATED_OBJECTS_SIZE
			);
			for (Database.SaveResult result : results) {
				System.assertEquals(true, result.success);
			}
			Test.stopTest();
		}
	}

	@IsTest
	static void testUpsertRecord() {
		System.runAs(new User(Id = UserInfo.getUserId())) {
			Test.startTest();
			final Individual i = new Individual(
				FirstName = 'John',
				LastName = 'Doe'
			);
			DML dml = new DMLImpl();
			Database.UpsertResult result = dml.upsertRecord(i);
			System.assert(result.success, SHOULD_HAVE_SAVED_SUCCESSFULLY);
			System.assertNotEquals(null, i.Id, SHOULD_HAVE_ASSIGNED_AN_ID);
			Test.stopTest();
		}
	}

	@IsTest
	static void testUpsertRecordAllOrNone() {
		System.runAs(new User(Id = UserInfo.getUserId())) {
			Test.startTest();
			final Individual i = new Individual(
				FirstName = 'John',
				LastName = 'Doe'
			);
			DML dml = new DMLImpl();
			Database.UpsertResult result = dml.upsertRecord(i, true);
			System.assert(result.success, SHOULD_HAVE_SAVED_SUCCESSFULLY);
			System.assertNotEquals(null, i.Id, SHOULD_HAVE_ASSIGNED_AN_ID);
			Test.stopTest();
		}
	}

	@IsTest
	static void testUpsertRecords() {
		System.runAs(new User(Id = UserInfo.getUserId())) {
			Test.startTest();
			final List<Individual> individuals = new List<Individual>{
				new Individual(FirstName = 'John', LastName = 'Doe'),
				new Individual(FirstName = 'Jane', LastName = 'Doe')
			};

			final DML myDML = new DMLImpl();

			List<Database.UpsertResult> results = myDML.upsertRecords(
				individuals
			);
			System.assertEquals(
				individuals.size(),
				results.size(),
				EXEPECTED_RESULTS_SIZE_SAME_AS_UPDATED_OBJECTS_SIZE
			);
			for (Database.UpsertResult result : results) {
				System.assertEquals(true, result.success);
			}
			Test.stopTest();
		}
	}

	@IsTest
	static void testUpsertRecordsAllOrNone() {
		System.runAs(new User(Id = UserInfo.getUserId())) {
			Test.startTest();
			final List<Individual> individuals = new List<Individual>{
				new Individual(FirstName = 'John', LastName = 'Doe'),
				new Individual(FirstName = 'Jane', LastName = 'Doe')
			};

			final DML myDML = new DMLImpl();

			List<Database.UpsertResult> results = myDML.upsertRecords(
				individuals,
				true
			);
			System.assertEquals(
				individuals.size(),
				results.size(),
				EXEPECTED_RESULTS_SIZE_SAME_AS_UPDATED_OBJECTS_SIZE
			);
			for (Database.UpsertResult result : results) {
				System.assertEquals(true, result.success);
			}
			Test.stopTest();
		}
	}

	@IsTest
	static void testDeleteRecord() {
		System.runAs(new User(Id = UserInfo.getUserId())) {
			Test.startTest();
			final Individual i = new Individual(
				FirstName = 'John',
				LastName = 'Doe'
			);
			DML dml = new DMLImpl();
			dml.insertRecord(i);

			Database.DeleteResult result = dml.deleteRecord(i);
			System.assert(result.success, SHOULD_HAVE_SAVED_SUCCESSFULLY);
			Test.stopTest();
		}
	}

	@IsTest
	static void testDeleteRecordId() {
		System.runAs(new User(Id = UserInfo.getUserId())) {
			Test.startTest();
			final Individual i = new Individual(
				FirstName = 'John',
				LastName = 'Doe'
			);
			DML dml = new DMLImpl();
			dml.insertRecord(i);

			Database.DeleteResult result = dml.deleteRecord(i.Id);
			System.assert(result.success, SHOULD_HAVE_SAVED_SUCCESSFULLY);
			Test.stopTest();
		}
	}

	@IsTest
	static void testDeleteRecordAllOrNone() {
		System.runAs(new User(Id = UserInfo.getUserId())) {
			Test.startTest();
			final Individual i = new Individual(
				FirstName = 'John',
				LastName = 'Doe'
			);
			DML dml = new DMLImpl();
			dml.insertRecord(i);

			Database.DeleteResult result = dml.deleteRecord(i, true);
			System.assert(result.success, SHOULD_HAVE_SAVED_SUCCESSFULLY);
			Test.stopTest();
		}
	}

	@IsTest
	static void testDeleteRecordIdAllOrNone() {
		System.runAs(new User(Id = UserInfo.getUserId())) {
			Test.startTest();
			final Individual i = new Individual(
				FirstName = 'John',
				LastName = 'Doe'
			);
			DML dml = new DMLImpl();
			dml.insertRecord(i);

			Database.DeleteResult result = dml.deleteRecord(i.Id, true);
			System.assert(result.success, SHOULD_HAVE_SAVED_SUCCESSFULLY);
			Test.stopTest();
		}
	}

	@IsTest
	static void testDeleteRecords() {
		System.runAs(new User(Id = UserInfo.getUserId())) {
			Test.startTest();
			final List<Individual> individuals = new List<Individual>{
				new Individual(FirstName = 'John', LastName = 'Doe'),
				new Individual(FirstName = 'Jane', LastName = 'Doe')
			};

			DML dml = new DMLImpl();
			dml.insertRecords(individuals);

			List<Database.DeleteResult> results = dml.deleteRecords(
				individuals
			);

			for (Database.DeleteResult result : results) {
				System.assert(result.success, SHOULD_HAVE_SAVED_SUCCESSFULLY);
			}
			Test.stopTest();
		}
	}

	@IsTest
	static void testDeleteRecordsAllOrNone() {
		System.runAs(new User(Id = UserInfo.getUserId())) {
			Test.startTest();
			final List<Individual> individuals = new List<Individual>{
				new Individual(FirstName = 'John', LastName = 'Doe'),
				new Individual(FirstName = 'Jane', LastName = 'Doe')
			};

			DML dml = new DMLImpl();
			dml.insertRecords(individuals);

			List<Database.DeleteResult> results = dml.deleteRecords(
				individuals,
				true
			);

			for (Database.DeleteResult result : results) {
				System.assert(result.success, SHOULD_HAVE_SAVED_SUCCESSFULLY);
			}
			Test.stopTest();
		}
	}

	@IsTest
	static void testDeleteRecordIDs() {
		System.runAs(new User(Id = UserInfo.getUserId())) {
			Test.startTest();
			final List<Individual> individuals = new List<Individual>{
				new Individual(FirstName = 'John', LastName = 'Doe'),
				new Individual(FirstName = 'Jane', LastName = 'Doe')
			};

			DML dml = new DMLImpl();
			dml.insertRecords(individuals);

			List<Id> recordIds = new List<ID>();
			for (Individual i : individuals) {
				recordIds.add(i.ID);
			}

			List<Database.DeleteResult> results = dml.deleteRecords(recordIds);

			for (Database.DeleteResult result : results) {
				System.assert(result.success, SHOULD_HAVE_SAVED_SUCCESSFULLY);
			}
			Test.stopTest();
		}
	}

	@IsTest
	static void testDeleteRecordIDsAllOrNone() {
		System.runAs(new User(Id = UserInfo.getUserId())) {
			Test.startTest();
			final List<Individual> individuals = new List<Individual>{
				new Individual(FirstName = 'John', LastName = 'Doe'),
				new Individual(FirstName = 'Jane', LastName = 'Doe')
			};

			DML dml = new DMLImpl();
			dml.insertRecords(individuals);

			List<Id> recordIds = new List<ID>();
			for (Individual i : individuals) {
				recordIds.add(i.ID);
			}

			List<Database.DeleteResult> results = dml.deleteRecords(
				recordIds,
				true
			);

			for (Database.DeleteResult result : results) {
				System.assert(result.success, SHOULD_HAVE_SAVED_SUCCESSFULLY);
			}
			Test.stopTest();
		}
	}
}
