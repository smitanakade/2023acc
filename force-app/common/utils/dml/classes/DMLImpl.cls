/**
 * @description DMLImpl implements the DML interface
 * by delegating all the processing to the equivalent
 * methods in the `System.Database` class.
 *
 * DmlImpl also optimize operations to minimize chunking errors
 * (i.e. "Cannot have more than 10 chunks in a single operations").
 *
 * The original order of the list passed to the methods is preserved as
 * the chunking optimisation uses a copy of the original list. This also
 * means that the caller can't rely on the order of the `Database.xxxResult`
 * lists and MUST match the result by record ID.
 */
public virtual inherited sharing class DMLImpl implements DML {
	private static final Integer MAX_CHUNKS = 10;

	/**
	 * @{inheritDoc}
	 */
	public Database.SaveResult insertRecord(SObject record) {
		return Database.insert(record);
	}

	/**
	 * @{inheritDoc}
	 */
	public Database.SaveResult insertRecord(SObject record, Boolean allOrNone) {
		return Database.insert(record, allOrNone);
	}

	/**
	 * @{inheritDoc}
	 */
	public Database.SaveResult insertRecord(
		SObject record,
		Database.DMLOptions options
	) {
		return Database.insert(record, options);
	}

	/**
	 * @{inheritDoc}
	 */
	public List<Database.SaveResult> insertRecords(List<SObject> records) {
		return Database.insert(this.sortChunks(records));
	}

	/**
	 * @{inheritDoc}
	 */
	public List<Database.SaveResult> insertRecords(
		List<SObject> records,
		Boolean allOrNone
	) {
		return Database.insert(this.sortChunks(records), allOrNone);
	}

	/**
	 * @{inheritDoc}
	 */
	public List<Database.SaveResult> insertRecords(
		List<SObject> records,
		Database.DMLOptions options
	) {
		return Database.insert(this.sortChunks(records), options);
	}

	/**
	 * @{inheritDoc}
	 */
	public Database.SaveResult updateRecord(SObject record) {
		return Database.update(record);
	}

	/**
	 * @{inheritDoc}
	 */
	public Database.SaveResult updateRecord(SObject record, Boolean allOrNone) {
		return Database.update(record, allOrNone);
	}

	/**
	 * @{inheritDoc}
	 */
	public Database.SaveResult updateRecord(
		SObject record,
		Database.DMLOptions options
	) {
		return Database.update(record, options);
	}

	/**
	 * @{inheritDoc}
	 */
	public List<Database.SaveResult> updateRecords(List<SObject> records) {
		return Database.update(this.sortChunks(records));
	}

	/**
	 * @{inheritDoc}
	 */
	public List<Database.SaveResult> updateRecords(
		List<SObject> records,
		Boolean allOrNone
	) {
		return Database.update(this.sortChunks(records), allOrNone);
	}

	/**
	 * @{inheritDoc}
	 */
	public List<Database.SaveResult> updateRecords(
		List<SObject> records,
		Database.DMLOptions options
	) {
		return Database.update(this.sortChunks(records), options);
	}

	/**
	 * @{inheritDoc}
	 */
	public Database.UpsertResult upsertRecord(SObject record) {
		return Database.upsert(record);
	}

	/**
	 * @{inheritDoc}
	 */
	public Database.UpsertResult upsertRecord(
		SObject record,
		Boolean allOrNone
	) {
		return Database.upsert(record, allOrNone);
	}

	/**
	 * @{inheritDoc}
	 */
	public Database.UpsertResult upsertRecord(
		SObject record,
		Schema.SObjectField externalIDField
	) {
		return Database.upsert(record, externalIDField);
	}

	/**
	 * @{inheritDoc}
	 */
	public Database.UpsertResult upsertRecord(
		SObject record,
		Schema.SObjectField externalIDField,
		Boolean allOrNone
	) {
		return Database.upsert(record, externalIDField, allOrNone);
	}

	/**
	 * @{inheritDoc}
	 */
	public List<Database.UpsertResult> upsertRecords(List<SObject> records) {
		return Database.upsert(this.sortChunks(records));
	}

	/**
	 * @{inheritDoc}
	 */
	public List<Database.UpsertResult> upsertRecords(
		List<SObject> records,
		Boolean allOrNone
	) {
		return Database.upsert(this.sortChunks(records), allOrNone);
	}

	/**
	 * @{inheritDoc}
	 */
	public List<Database.UpsertResult> upsertRecords(
		List<SObject> records,
		Schema.SObjectField externalIDField
	) {
		return Database.upsert(this.sortChunks(records), externalIDField);
	}

	/**
	 * @{inheritDoc}
	 */
	public List<Database.UpsertResult> upsertRecords(
		List<SObject> records,
		Schema.SObjectField externalIDField,
		Boolean allOrNone
	) {
		return Database.upsert(
			this.sortChunks(records),
			externalIDField,
			allOrNone
		);
	}

	/**
	 * @{inheritDoc}
	 */
	public Database.DeleteResult deleteRecord(SObject record) {
		return Database.delete(record);
	}

	/**
	 * @{inheritDoc}
	 */
	public Database.DeleteResult deleteRecord(
		SObject record,
		Boolean allOrNone
	) {
		return Database.delete(record, allOrNone);
	}

	/**
	 * @{inheritDoc}
	 */
	public Database.DeleteResult deleteRecord(ID recordID) {
		return Database.delete(recordID);
	}

	/**
	 * @{inheritDoc}
	 */
	public Database.DeleteResult deleteRecord(ID recordID, Boolean allOrNone) {
		return Database.delete(recordID, allOrNone);
	}

	/**
	 * @{inheritDoc}
	 */
	public List<Database.DeleteResult> deleteRecords(List<SObject> records) {
		return Database.delete(this.sortChunks(records));
	}

	/**
	 * @{inheritDoc}
	 */
	public List<Database.DeleteResult> deleteRecords(
		List<SObject> records,
		Boolean allOrNone
	) {
		return Database.delete(this.sortChunks(records), allOrNone);
	}

	/**
	 * @{inheritDoc}
	 */
	public List<Database.DeleteResult> deleteRecords(List<ID> recordIDs) {
		return Database.delete(recordIDs);
	}

	/**
	 * @{inheritDoc}
	 */
	public List<Database.DeleteResult> deleteRecords(
		List<ID> recordIDs,
		Boolean allOrNone
	) {
		return Database.delete(recordIDs, allOrNone);
	}

	/**
	 * @description sorts SObject by type to prevent errors related
	 *   to too many chunks in a single operation (ex "Cannot have more
	 *   than 10 chunks in a single operation.")
	 * @param records the collection of records to sort
	 * @return the original list if no sorting is needed, or a sorted
	 *   copy of the given list
	 */
	protected List<SObject> sortChunks(List<SObject> records) {
		if (records == null || records.size() < MAX_CHUNKS) {
			return records;
		}

		// sort a copy of the list to preserve the original order for
		// the caller
		List<SObject> sorted = new List<SObject>(records);
		sorted.sort();
		return sorted;
	}
}
