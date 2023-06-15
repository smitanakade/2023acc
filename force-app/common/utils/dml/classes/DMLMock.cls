public virtual class DMLMock implements DML {
	// insert
	public Integer insertRecordCallCount = 0;
	public Integer insertRecordAllOrNoneCallCount = 0;
	public Integer insertRecordOptionsCallCount = 0;
	public Integer insertRecordsCallCount = 0;
	public Integer insertRecordsAllOrNoneCallCount = 0;
	public Integer insertRecordsOptionsCallCount = 0;
	// update
	public Integer updateRecordCallCount = 0;
	public Integer updateRecordAllOrNoneCallCount = 0;
	public Integer updateRecordOptionsCallCount = 0;
	public Integer updateRecordsCallCount = 0;
	public Integer updateRecordsAllOrNoneCallCount = 0;
	public Integer updateRecordsOptionsCallCount = 0;
	// upsert
	public Integer upsertRecordCallCount = 0;
	public Integer upsertRecordAllOrNoneCallCount = 0;
	public Integer upsertRecordWithFieldCallCount = 0;
	public Integer upsertRecordWithFieldAllOrNoneCallCount = 0;

	public Integer upsertRecordsCallCount = 0;
	public Integer upsertRecordsAllOrNoneCallCount = 0;
	public Integer upsertRecordsWithFieldCallCount = 0;
	public Integer upsertRecordsWithFieldAllOrNoneCallCount = 0;

	// delete
	public Integer deleteRecordCallCount = 0;
	public Integer deleteRecordAllOrNoneCallCount = 0;
	public Integer deleteRecordIdCallCount = 0;
	public Integer deleteRecordIdAllOrNoneCallCount = 0;

	public Integer deleteRecordsCallCount = 0;
	public Integer deleteRecordsAllOrNoneCallCount = 0;
	public Integer deleteRecordIdsCallCount = 0;
	public Integer deleteRecordIdsAllOrNoneCallCount = 0;

	public List<SObject> inserted = new List<SObject>();
	public List<SObject> updated = new List<SObject>();
	public List<SObject> upserted = new List<SObject>();
	public List<Id> deleted = new List<Id>();

	protected Database.SaveResult doInsertRecord(SObject record) {
		if (record == null) {
			throw new NullPointerException(); // Database.insert throws an exception on null
		}

		record.Id = IdFaker.generateFor(record.getSObjectType());
		this.inserted.add(record);
		return newSaveResult(true, record.Id);
	}

	public virtual Database.SaveResult insertRecord(SObject record) {
		this.insertRecordCallCount++;
		return this.doInsertRecord(record);
	}

	public virtual Database.SaveResult insertRecord(
		SObject record,
		Boolean allOrNone
	) {
		this.insertRecordAllOrNoneCallCount++;
		return this.doInsertRecord(record);
	}

	public Database.SaveResult insertRecord(
		SObject record,
		Database.DMLOptions options
	) {
		this.insertRecordOptionsCallCount++;
		return this.doInsertRecord(record);
	}

	protected List<Database.SaveResult> doInsertRecords(List<SObject> records) {
		final List<Database.SaveResult> results = new List<Database.SaveResult>();
		for (SObject record : records) {
			results.add(this.doInsertRecord(record));
		}
		return results;
	}

	public List<Database.SaveResult> insertRecords(List<SObject> records) {
		this.insertRecordsCallCount++;
		return this.doInsertRecords(records);
	}

	public List<Database.SaveResult> insertRecords(
		List<SObject> records,
		Boolean allOrNone
	) {
		this.insertRecordsAllOrNoneCallCount++;
		return this.doInsertRecords(records);
	}

	public List<Database.SaveResult> insertRecords(
		List<SObject> records,
		Database.DMLOptions options
	) {
		this.insertRecordsOptionsCallCount++;
		return this.doInsertRecords(records);
	}

	protected Database.SaveResult doUpdateRecord(SObject record) {
		if (record == null) {
			throw new NullPointerException(); // Database.insert throws an exception on null
		}

		if (record.Id == null) {
			throw new DmlException(
				'Id not specified in an update call: ' + record
			);
		}

		this.updated.add(record);
		return newSaveResult(true, record.Id);
	}

	public virtual Database.SaveResult updateRecord(SObject record) {
		this.updateRecordCallCount++;
		return this.doUpdateRecord(record);
	}

	public virtual Database.SaveResult updateRecord(
		SObject record,
		Boolean allOrNone
	) {
		this.updateRecordAllOrNoneCallCount++;
		return this.doUpdateRecord(record);
	}

	public Database.SaveResult updateRecord(
		SObject record,
		Database.DMLOptions options
	) {
		this.updateRecordOptionsCallCount++;
		return this.doUpdateRecord(record);
	}

	protected List<Database.SaveResult> doUpdateRecords(List<SObject> records) {
		final List<Database.SaveResult> results = new List<Database.SaveResult>();
		for (SObject record : records) {
			results.add(this.doUpdateRecord(record));
		}
		return results;
	}

	public List<Database.SaveResult> updateRecords(List<SObject> records) {
		this.updateRecordsCallCount++;
		return this.doUpdateRecords(records);
	}

	public List<Database.SaveResult> updateRecords(
		List<SObject> records,
		Boolean allOrNone
	) {
		this.updateRecordsAllOrNoneCallCount++;
		return this.doUpdateRecords(records);
	}

	public List<Database.SaveResult> updateRecords(
		List<SObject> records,
		Database.DMLOptions options
	) {
		this.updateRecordsOptionsCallCount++;
		return this.doUpdateRecords(records);
	}

	protected Database.UpsertResult doUpsertRecord(SObject record) {
		if (record == null) {
			throw new NullPointerException(); // Database.insert throws an exception on null
		}

		if (record.Id == null) {
			record.Id = IdFaker.generateFor(record.getSObjectType());
		}

		this.upserted.add(record);
		return newUpsertResult(true, record.Id);
	}

	public Database.UpsertResult upsertRecord(SObject record) {
		this.upsertRecordCallCount++;
		return this.doUpsertRecord(record);
	}

	public Database.UpsertResult upsertRecord(
		SObject record,
		Boolean allOrNone
	) {
		this.upsertRecordAllOrNoneCallCount++;
		return this.doUpsertRecord(record);
	}

	public Database.UpsertResult upsertRecord(
		SObject record,
		Schema.SObjectField externalIDField
	) {
		this.upsertRecordWithFieldCallCount++;
		return this.doUpsertRecord(record);
	}

	public Database.UpsertResult upsertRecord(
		SObject record,
		Schema.SObjectField externalIDField,
		Boolean allOrNone
	) {
		this.upsertRecordWithFieldAllOrNoneCallCount++;
		return this.doUpsertRecord(record);
	}

	public List<Database.UpsertResult> upsertRecords(List<SObject> records) {
		this.upsertRecordsCallCount++;

		final List<Database.UpsertResult> results = new List<Database.UpsertResult>();
		for (SObject record : records) {
			results.add(this.doUpsertRecord(record));
		}
		return results;
	}

	public List<Database.UpsertResult> upsertRecords(
		List<SObject> records,
		Boolean allOrNone
	) {
		this.upsertRecordsAllOrNoneCallCount++;

		final List<Database.UpsertResult> results = new List<Database.UpsertResult>();
		for (SObject record : records) {
			results.add(this.doUpsertRecord(record));
		}
		return results;
	}

	public List<Database.UpsertResult> upsertRecords(
		List<SObject> records,
		Schema.SObjectField externalIDField
	) {
		this.upsertRecordsWithFieldCallCount++;

		final List<Database.UpsertResult> results = new List<Database.UpsertResult>();
		for (SObject record : records) {
			results.add(this.doUpsertRecord(record));
		}
		return results;
	}

	public List<Database.UpsertResult> upsertRecords(
		List<SObject> records,
		Schema.SObjectField externalIDField,
		Boolean allOrNone
	) {
		this.upsertRecordsWithFieldAllOrNoneCallCount++;

		final List<Database.UpsertResult> results = new List<Database.UpsertResult>();
		for (SObject record : records) {
			results.add(this.doUpsertRecord(record));
		}
		return results;
	}

	protected Database.DeleteResult doDelete(SObject record) {
		if (record == null) {
			throw new NullPointerException();
		}

		return doDelete(record.Id);
	}

	protected Database.DeleteResult doDelete(Id recordID) {
		if (recordID == null) {
			throw new NullPointerException();
		}

		this.deleted.add(recordID);
		return newDeleteResult(true, recordID);
	}

	protected List<Database.DeleteResult> doDelete(List<SObject> records) {
		if (records == null) {
			throw new NullPointerException();
		}

		List<Database.DeleteResult> results = new List<Database.DeleteResult>();
		for (SObject record : records) {
			results.add(doDelete(record));
		}
		return results;
	}

	protected List<Database.DeleteResult> doDelete(List<Id> recordIDs) {
		if (recordIDs == null) {
			throw new NullPointerException();
		}

		List<Database.DeleteResult> results = new List<Database.DeleteResult>();
		for (ID recordID : recordIDs) {
			results.add(doDelete(recordID));
		}
		return results;
	}

	public Database.DeleteResult deleteRecord(SObject record) {
		this.deleteRecordCallCount++;
		return doDelete(record);
	}

	public Database.DeleteResult deleteRecord(
		SObject record,
		Boolean allOrNone
	) {
		this.deleteRecordAllOrNoneCallCount++;
		return doDelete(record);
	}

	public Database.DeleteResult deleteRecord(ID recordID) {
		this.deleteRecordIdCallCount++;
		return doDelete(recordID);
	}

	public Database.DeleteResult deleteRecord(ID recordID, Boolean allOrNone) {
		this.deleteRecordIdAllOrNoneCallCount++;
		return doDelete(recordID);
	}

	/**
	 * @{inheritDoc}
	 */
	public List<Database.DeleteResult> deleteRecords(List<SObject> records) {
		this.deleteRecordsCallCount++;
		return doDelete(records);
	}

	/**
	 * @{inheritDoc}
	 */
	public List<Database.DeleteResult> deleteRecords(
		List<SObject> records,
		Boolean allOrNone
	) {
		this.deleteRecordsAllOrNoneCallCount++;
		return doDelete(records);
	}

	/**
	 * @{inheritDoc}
	 */
	public List<Database.DeleteResult> deleteRecords(List<ID> recordIDs) {
		this.deleteRecordIdsCallCount++;
		return doDelete(recordIDs);
	}

	/**
	 * @{inheritDoc}
	 */
	public List<Database.DeleteResult> deleteRecords(
		List<ID> recordIDs,
		Boolean allOrNone
	) {
		this.deleteRecordIdsAllOrNoneCallCount++;
		return doDelete(recordIDs);
	}

	public static Database.SaveResult newSaveResult(
		Boolean isSuccess,
		String id
	) {
		// Database.SaveResult can't be constructed directly from Apex. As a workaround
		// we use JSON deserialization to create a new instance.
		final JSONGenerator generator = JSON.createGenerator(false);
		generator.writeStartObject();
		generator.writeBooleanField('success', isSuccess == true);
		generator.writeIdField('id', id);
		generator.writeEndObject();

		return (Database.SaveResult) JSON.deserialize(
			generator.getAsString(),
			Database.SaveResult.class
		);
	}

	public static Database.UpsertResult newUpsertResult(
		Boolean isSuccess,
		String id
	) {
		// Database.SaveResult can't be constructed directly from Apex. As a workaround
		// we use JSON deserialization to create a new instance.
		final JSONGenerator generator = JSON.createGenerator(false);
		generator.writeStartObject();
		generator.writeBooleanField('success', isSuccess == true);
		generator.writeIdField('id', id);
		generator.writeEndObject();

		return (Database.UpsertResult) JSON.deserialize(
			generator.getAsString(),
			Database.UpsertResult.class
		);
	}

	public static Database.DeleteResult newDeleteResult(
		Boolean isSuccess,
		String id
	) {
		// Database.SaveResult can't be constructed directly from Apex. As a workaround
		// we use JSON deserialization to create a new instance.
		final JSONGenerator generator = JSON.createGenerator(false);
		generator.writeStartObject();
		generator.writeBooleanField('success', isSuccess == true);
		generator.writeIdField('id', id);
		generator.writeEndObject();

		return (Database.DeleteResult) JSON.deserialize(
			generator.getAsString(),
			Database.DeleteResult.class
		);
	}
}
