/*------------------------------------------------------------------------------------------------
Author:         Pinali Patel
Description:    This class will be the Batch class and Scheduler class for bulk case and form creation functionality.
************************************************************************************************
History
************************************************************************************************
 * @TestClass AcfrCreateQuaterlyCasesAndFormsTest
--------------------------------------------------------------------------------------------------*/
public with sharing class AcfrCreateQuaterlyCasesAndFormsScheduler implements Schedulable, Database.Batchable<sObject> {
	List<Account> accountList = new List<Account>();
	public AcfrCreateQuaterlyCasesAndFormsScheduler(List<Account> accounts) {
		this.accountList = accounts;
	}

	public AcfrCreateQuaterlyCasesAndFormsScheduler() {
	}
	public void execute(SchedulableContext context) {
		Database.executebatch(this, 30);
	}
	public Database.QueryLocator start(Database.BatchableContext bc) {
		Id approvedProvider = Schema.Account.getSObjectType()
			.getDescribe()
			.getRecordTypeInfosByDeveloperName()
			.get('Approved_Provider')
			.getRecordTypeId();

		if (this.accountList.isEmpty()) {
			return Database.getQueryLocator(
				[
					SELECT
						Id,
						Purpose__c,
						RecordType.Name,
						Name,
						Integration_ID__c,
						RecordType.SobjectType
					FROM Account
					WHERE
						RecordType.Name = 'Approved Provider'
						AND RecordType.SobjectType = 'Account'
						AND Id IN (
							SELECT Provider_name__c
							FROM Service_Account_Relationship__c
						)
				]
			);
		} else {
			return Database.getQueryLocator(
				[
					SELECT
						Id,
						Purpose__c,
						RecordType.Name,
						Name,
						Integration_ID__c,
						RecordType.SobjectType
					FROM Account
					WHERE Id IN :this.accountList
				]
			);
		}
	}

	public void execute(
		Database.BatchableContext bc,
		List<Account> accountList
	) {
		AcfrCreateQuaterlyCasesAndFormsService createCasesAndForms = new AcfrCreateQuaterlyCasesAndFormsService(
			accountList
		);
		createCasesAndForms.performAction();
	}

	public void finish(Database.BatchableContext bc) {
		List<String> jobStatus = new List<String>{
			'Aborted',
			'Completed',
			'Failed'
		};

		List<AsyncApexJob> glCodeLineItemBatchInProgress = [
			SELECT Id, ApexClass.Name, Status
			FROM AsyncApexJob
			WHERE
				ApexClass.Name = 'AcfrCreateQuaterlyGLCLineItemScheduler'
				AND Status NOT IN :jobStatus
		];
		if (glCodeLineItemBatchInProgress.size() == 0) {
			AcfrCreateQuaterlyGLCLineItemScheduler glCodeLineItemBatch = new AcfrCreateQuaterlyGLCLineItemScheduler();
			Database.executeBatch(
				glCodeLineItemBatch,
				AcfrCreateQuaterlyGLCLineItemScheduler.DEFAULT_BATCH_SIZE
			);
		}
	}
}
