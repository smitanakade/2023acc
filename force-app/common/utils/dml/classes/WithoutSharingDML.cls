/**
 * @description       :
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             :
 * @last modified on  : 03-28-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 **/
public with sharing class WithoutSharingDML implements DML {
	private final DML innerDML = new InnerDML();
	public Database.SaveResult insertRecord(SObject record) {
		return this.innerDML.insertRecord(record);
	}
	public Database.SaveResult insertRecord(SObject record, Boolean allOrNone) {
		return this.innerDML.insertRecord(record, allOrNone);
	}
	public Database.SaveResult insertRecord(
		SObject record,
		Database.DMLOptions options
	) {
		return this.innerDML.insertRecord(record, options);
	}
	public List<Database.SaveResult> insertRecords(List<SObject> records) {
		return this.innerDML.insertRecords(records);
	}
	public List<Database.SaveResult> insertRecords(
		List<SObject> records,
		Boolean allOrNone
	) {
		return this.innerDML.insertRecords(records, allOrNone);
	}
	public List<Database.SaveResult> insertRecords(
		List<SObject> records,
		Database.DMLOptions options
	) {
		return this.innerDML.insertRecords(records, options);
	}

	public Database.SaveResult updateRecord(SObject record) {
		return this.innerDML.updateRecord(record);
	}
	public Database.SaveResult updateRecord(SObject record, Boolean allOrNone) {
		return this.innerDML.updateRecord(record, allOrNone);
	}
	public Database.SaveResult updateRecord(
		SObject record,
		Database.DMLOptions options
	) {
		return this.innerDML.updateRecord(record, options);
	}
	public List<Database.SaveResult> updateRecords(List<SObject> records) {
		return this.innerDML.updateRecords(records);
	}
	public List<Database.SaveResult> updateRecords(
		List<SObject> records,
		Boolean allOrNone
	) {
		return this.innerDML.updateRecords(records, allOrNone);
	}
	public List<Database.SaveResult> updateRecords(
		List<SObject> records,
		Database.DMLOptions options
	) {
		return this.innerDML.updateRecords(records, options);
	}

	public Database.UpsertResult upsertRecord(SObject record) {
		return this.innerDML.upsertRecord(record);
	}
	public Database.UpsertResult upsertRecord(
		SObject record,
		Boolean allOrNone
	) {
		return this.innerDML.upsertRecord(record, allOrNone);
	}
	public Database.UpsertResult upsertRecord(
		SObject record,
		Schema.SObjectField externalIDField
	) {
		return this.innerDML.upsertRecord(record, externalIDField);
	}
	public Database.UpsertResult upsertRecord(
		SObject record,
		Schema.SObjectField externalIDField,
		Boolean allOrNone
	) {
		return this.innerDML.upsertRecord(record, externalIDField, allOrNone);
	}
	public List<Database.UpsertResult> upsertRecords(List<SObject> records) {
		return this.innerDML.upsertRecords(records);
	}
	public List<Database.UpsertResult> upsertRecords(
		List<SObject> records,
		Boolean allOrNone
	) {
		return this.innerDML.upsertRecords(records, allOrNone);
	}
	public List<Database.UpsertResult> upsertRecords(
		List<SObject> records,
		Schema.SObjectField externalIDField
	) {
		return this.innerDML.upsertRecords(records, externalIDField);
	}
	public List<Database.UpsertResult> upsertRecords(
		List<SObject> records,
		Schema.SObjectField externalIDField,
		Boolean allOrNone
	) {
		return this.innerDML.upsertRecords(records, externalIDField, allOrNone);
	}

	public Database.DeleteResult deleteRecord(SObject record) {
		return this.innerDML.deleteRecord(record);
	}
	public Database.DeleteResult deleteRecord(
		SObject record,
		Boolean allOrNone
	) {
		return this.innerDML.deleteRecord(record, allOrNone);
	}
	public Database.DeleteResult deleteRecord(ID recordID) {
		return this.innerDML.deleteRecord(recordID);
	}
	public Database.DeleteResult deleteRecord(ID recordID, Boolean allOrNone) {
		return this.innerDML.deleteRecord(recordID, allOrNone);
	}
	public List<Database.DeleteResult> deleteRecords(List<SObject> records) {
		return this.innerDML.deleteRecords(records);
	}
	public List<Database.DeleteResult> deleteRecords(
		List<SObject> records,
		Boolean allOrNone
	) {
		return this.innerDML.deleteRecords(records, allOrNone);
	}
	public List<Database.DeleteResult> deleteRecords(List<ID> recordIDs) {
		return this.innerDML.deleteRecords(recordIDs);
	}
	public List<Database.DeleteResult> deleteRecords(
		List<ID> recordIDs,
		Boolean allOrNone
	) {
		return this.innerDML.deleteRecords(recordIDs, allOrNone);
	}

	private without sharing class InnerDML extends DMLImpl {
	}
}
