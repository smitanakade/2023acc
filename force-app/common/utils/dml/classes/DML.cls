/**
 * @description DML represents DML operations available in Salesforce.
 * In a nutshell, it's an interface matching some of the DML operations
 * in System.Database.
 */
public interface DML {
	// insert
	Database.SaveResult insertRecord(SObject record);
	Database.SaveResult insertRecord(SObject record, Boolean allOrNone);
	Database.SaveResult insertRecord(
		SObject record,
		Database.DMLOptions options
	);

	List<Database.SaveResult> insertRecords(List<SObject> records);
	List<Database.SaveResult> insertRecords(
		List<SObject> records,
		Boolean allOrNone
	);
	List<Database.SaveResult> insertRecords(
		List<SObject> records,
		Database.DMLOptions options
	);

	// update
	Database.SaveResult updateRecord(SObject record);
	Database.SaveResult updateRecord(SObject record, Boolean allOrNone);
	Database.SaveResult updateRecord(
		SObject record,
		Database.DMLOptions options
	);

	List<Database.SaveResult> updateRecords(List<SObject> records);
	List<Database.SaveResult> updateRecords(
		List<SObject> records,
		Boolean allOrNone
	);
	List<Database.SaveResult> updateRecords(
		List<SObject> records,
		Database.DMLOptions options
	);

	// upsert
	Database.UpsertResult upsertRecord(SObject record);
	Database.UpsertResult upsertRecord(SObject record, Boolean allOrNone);
	Database.UpsertResult upsertRecord(
		SObject record,
		Schema.SObjectField externalIDField
	);
	Database.UpsertResult upsertRecord(
		SObject record,
		Schema.SObjectField externalIDField,
		Boolean allOrNone
	);

	List<Database.UpsertResult> upsertRecords(List<SObject> records);
	List<Database.UpsertResult> upsertRecords(
		List<SObject> records,
		Boolean allOrNone
	);
	List<Database.UpsertResult> upsertRecords(
		List<SObject> record,
		Schema.SObjectField externalIDField
	);
	List<Database.UpsertResult> upsertRecords(
		List<SObject> records,
		Schema.SObjectField externalIDField,
		Boolean allOrNone
	);

	// delete
	Database.DeleteResult deleteRecord(SObject record);
	Database.DeleteResult deleteRecord(SObject record, Boolean allOrNone);
	Database.DeleteResult deleteRecord(ID recordID);
	Database.DeleteResult deleteRecord(ID recordID, Boolean allOrNone);

	List<Database.DeleteResult> deleteRecords(List<SObject> records);
	List<Database.DeleteResult> deleteRecords(
		List<SObject> records,
		Boolean allOrNone
	);
	List<Database.DeleteResult> deleteRecords(List<ID> recordIDs);
	List<Database.DeleteResult> deleteRecords(
		List<ID> recordIDs,
		Boolean allOrNone
	);
}
