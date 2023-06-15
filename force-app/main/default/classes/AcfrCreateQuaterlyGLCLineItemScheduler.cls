/**
 * @description       : This class will be the Batch class and Scheduler class for bulk case and form creation functionality.
 * @author            : Pinali Patel
 * @group             :
 * @last modified on  : 11-17-2022
 * @last modified by  : Ethan Sargent
 * @TestClass AcfrCreateQuaterlyCasesAndFormsTest
 **/

public with sharing class AcfrCreateQuaterlyGLCLineItemScheduler implements Schedulable, Database.Batchable<sObject> {
	public static final Integer DEFAULT_BATCH_SIZE = 110;
	public AcfrCreateQuaterlyGLCLineItemScheduler() {
	}

	public void execute(SchedulableContext context) {
	}
	public Database.QueryLocator start(Database.BatchableContext bc) {
		List<Reporting_Period__c> reportingPeriods = [
			SELECT Id
			FROM Reporting_Period__c
			WHERE Current_Reporting_Period__c = TRUE
		];
		return Database.getQueryLocator(
			[
				SELECT
					Id,
					Service__c,
					Service_Category__c,
					Form__c,
					Form__r.Type__c,
					Form__r.case__r.Reporting_Period__r.Current_Reporting_Period__c
				FROM Service_Line_Item__c
				WHERE
					Id NOT IN (
						SELECT Service_Line_Item__c
						FROM GL_Code_Line_Item__c
					)
			]
		);
	}

	public void execute(
		Database.BatchableContext bc,
		List<Service_Line_Item__c> serviceLineItems
	) {
		System.debug('serviceLineItem size in GLC:' + serviceLineItems.Size());
		AcfrCreateQuaterlyCasesAndFormsService createCasesAndForms = new AcfrCreateQuaterlyCasesAndFormsService(
			serviceLineItems
		);
		createCasesAndForms.performActionForGLCodeLineItems();
	}

	public void finish(Database.BatchableContext bc) {
	}
}
