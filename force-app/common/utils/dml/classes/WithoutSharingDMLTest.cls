/**
 * @description       :
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             :
 * @last modified on  : 03-28-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 **/

@IsTest(isParallel=true)
public with sharing class WithoutSharingDMLTest {
	private static final String SHOULD_HAVE_BEEN_SAVED_SUCCESSFULLY = 'should have been saved successfully';
	private static final String SHOULD_HAVE_BEEN_UPDATED_SUCCESSFULLY = 'should have been updated successfully';
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

			WithoutSharingDML withoutSharingDML = new WithoutSharingDML();
			final Database.SaveResult result = withoutSharingDML.insertRecord(
				i
			);

			System.assert(result.success, SHOULD_HAVE_BEEN_SAVED_SUCCESSFULLY);
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

			WithoutSharingDML withoutSharingDML = new WithoutSharingDML();
			final Database.SaveResult result = withoutSharingDML.insertRecord(
				i,
				true
			);

			System.assert(result.success, SHOULD_HAVE_BEEN_SAVED_SUCCESSFULLY);
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

			WithoutSharingDML withoutSharingDML = new WithoutSharingDML();
			final Database.SaveResult result = withoutSharingDML.insertRecord(
				i,
				new Database.DMLOptions()
			);

			System.assert(result.success, SHOULD_HAVE_BEEN_SAVED_SUCCESSFULLY);
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

			WithoutSharingDML withoutSharingDML = new WithoutSharingDML();
			final List<Database.SaveResult> results = withoutSharingDML.insertRecords(
				individuals
			);
			System.assertEquals(
				individuals.size(),
				results.size(),
				SHOULD_HAVE_RETURNED_2_RESULTS
			);

			for (Database.SaveResult result : results) {
				System.assert(
					result.success,
					SHOULD_HAVE_BEEN_SAVED_SUCCESSFULLY
				);
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

			WithoutSharingDML withoutSharingDML = new WithoutSharingDML();
			final List<Database.SaveResult> results = withoutSharingDML.insertRecords(
				individuals,
				true
			);
			System.assertEquals(
				individuals.size(),
				results.size(),
				SHOULD_HAVE_RETURNED_2_RESULTS
			);

			for (Database.SaveResult result : results) {
				System.assert(
					result.success,
					SHOULD_HAVE_BEEN_SAVED_SUCCESSFULLY
				);
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

			WithoutSharingDML withoutSharingDML = new WithoutSharingDML();
			final List<Database.SaveResult> results = withoutSharingDML.insertRecords(
				individuals,
				new Database.DMLOptions()
			);
			System.assertEquals(
				individuals.size(),
				results.size(),
				SHOULD_HAVE_RETURNED_2_RESULTS
			);

			for (Database.SaveResult result : results) {
				System.assert(
					result.success,
					SHOULD_HAVE_BEEN_SAVED_SUCCESSFULLY
				);
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

			WithoutSharingDML withoutSharingDML = new WithoutSharingDML();
			final List<Database.SaveResult> results = withoutSharingDML.insertRecords(
				individuals
			);
			System.assertEquals(
				individuals.size(),
				results.size(),
				SHOULD_HAVE_RETURNED_12_RESULTS
			);

			// TODO: check that the order of 'individuals' has not changed.

			for (Database.SaveResult result : results) {
				System.assert(
					result.success,
					SHOULD_HAVE_BEEN_SAVED_SUCCESSFULLY
				);
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
			WithoutSharingDML withoutSharingDML = new WithoutSharingDML();
			Database.SaveResult result = withoutSharingDML.insertRecord(i);

			i.FirstName = 'Jane';
			result = withoutSharingDML.updateRecord(i);
			System.assert(
				result.success,
				SHOULD_HAVE_BEEN_UPDATED_SUCCESSFULLY
			);
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
			WithoutSharingDML withoutSharingDML = new WithoutSharingDML();
			Database.SaveResult result = withoutSharingDML.insertRecord(i);

			i.FirstName = 'Jane';
			result = withoutSharingDML.updateRecord(i, true);
			System.assert(
				result.success,
				SHOULD_HAVE_BEEN_UPDATED_SUCCESSFULLY
			);
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
			WithoutSharingDML withoutSharingDML = new WithoutSharingDML();
			Database.SaveResult result = withoutSharingDML.insertRecord(i);

			i.FirstName = 'Jane';
			result = withoutSharingDML.updateRecord(
				i,
				new Database.DMLOptions()
			);
			System.assert(
				result.success,
				SHOULD_HAVE_BEEN_UPDATED_SUCCESSFULLY
			);
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

			WithoutSharingDML withoutSharingDML = new WithoutSharingDML();
			withoutSharingDML.insertRecords(individuals);

			for (Individual i : individuals) {
				i.FirstName = 'Jane';
			}

			List<Database.SaveResult> results = withoutSharingDML.updateRecords(
				individuals
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
	static void testUpdateRecordsAllOrNone() {
		System.runAs(new User(Id = UserInfo.getUserId())) {
			Test.startTest();
			final List<Individual> individuals = new List<Individual>{
				new Individual(FirstName = 'John', LastName = 'Doe'),
				new Individual(FirstName = 'Jane', LastName = 'Doe')
			};

			WithoutSharingDML withoutSharingDML = new WithoutSharingDML();
			withoutSharingDML.insertRecords(individuals);

			for (Individual i : individuals) {
				i.FirstName = 'Jane';
			}

			List<Database.SaveResult> results = withoutSharingDML.updateRecords(
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

			WithoutSharingDML withoutSharingDML = new WithoutSharingDML();
			withoutSharingDML.insertRecords(individuals);

			for (Individual i : individuals) {
				i.FirstName = 'Jane';
			}

			List<Database.SaveResult> results = withoutSharingDML.updateRecords(
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
			WithoutSharingDML withoutSharingDML = new WithoutSharingDML();
			Database.UpsertResult result = withoutSharingDML.upsertRecord(i);
			System.assert(
				result.success,
				SHOULD_HAVE_BEEN_UPDATED_SUCCESSFULLY
			);
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
			WithoutSharingDML withoutSharingDML = new WithoutSharingDML();
			Database.UpsertResult result = withoutSharingDML.upsertRecord(
				i,
				true
			);
			System.assert(
				result.success,
				SHOULD_HAVE_BEEN_UPDATED_SUCCESSFULLY
			);
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

			final WithoutSharingDML withoutSharingDML = new WithoutSharingDML();

			List<Database.UpsertResult> results = withoutSharingDML.upsertRecords(
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

			final WithoutSharingDML withoutSharingDML = new WithoutSharingDML();

			List<Database.UpsertResult> results = withoutSharingDML.upsertRecords(
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
			WithoutSharingDML withoutSharingDML = new WithoutSharingDML();
			withoutSharingDML.insertRecord(i);

			Database.DeleteResult result = withoutSharingDML.deleteRecord(i);
			System.assert(
				result.success,
				'should have been deleted successfully'
			);
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
			WithoutSharingDML withoutSharingDML = new WithoutSharingDML();
			withoutSharingDML.insertRecord(i);

			Database.DeleteResult result = withoutSharingDML.deleteRecord(i.Id);
			System.assert(
				result.success,
				'should have been deleted successfully'
			);
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
			WithoutSharingDML withoutSharingDML = new WithoutSharingDML();
			withoutSharingDML.insertRecord(i);

			Database.DeleteResult result = withoutSharingDML.deleteRecord(
				i,
				true
			);
			System.assert(
				result.success,
				'should have been deleted successfully'
			);
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
			WithoutSharingDML withoutSharingDML = new WithoutSharingDML();
			withoutSharingDML.insertRecord(i);

			Database.DeleteResult result = withoutSharingDML.deleteRecord(
				i.Id,
				true
			);
			System.assert(
				result.success,
				'should have been deleted successfully'
			);
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

			WithoutSharingDML withoutSharingDML = new WithoutSharingDML();
			withoutSharingDML.insertRecords(individuals);

			List<Database.DeleteResult> results = withoutSharingDML.deleteRecords(
				individuals
			);

			for (Database.DeleteResult result : results) {
				System.assert(
					result.success,
					'should have been deleted successfully'
				);
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

			WithoutSharingDML withoutSharingDML = new WithoutSharingDML();
			withoutSharingDML.insertRecords(individuals);

			List<Database.DeleteResult> results = withoutSharingDML.deleteRecords(
				individuals,
				true
			);

			for (Database.DeleteResult result : results) {
				System.assert(
					result.success,
					'should have been deleted successfully'
				);
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

			WithoutSharingDML withoutSharingDML = new WithoutSharingDML();
			withoutSharingDML.insertRecords(individuals);

			List<Id> recordIds = new List<ID>();
			for (Individual i : individuals) {
				recordIds.add(i.ID);
			}

			List<Database.DeleteResult> results = withoutSharingDML.deleteRecords(
				recordIds
			);

			for (Database.DeleteResult result : results) {
				System.assert(
					result.success,
					'should have been deleted successfully'
				);
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

			WithoutSharingDML withoutSharingDML = new WithoutSharingDML();
			withoutSharingDML.insertRecords(individuals);

			List<Id> recordIds = new List<ID>();
			for (Individual i : individuals) {
				recordIds.add(i.ID);
			}

			List<Database.DeleteResult> results = withoutSharingDML.deleteRecords(
				recordIds,
				true
			);

			for (Database.DeleteResult result : results) {
				System.assert(
					result.success,
					'should have been deleted successfully'
				);
			}
			Test.stopTest();
		}
	}
}
