/**
 *
 * @testClass AcfrSubmissionDueEmailBatchTest
 */
public with sharing class AcfrSubmissionDueEmailBatch implements Database.Batchable<sObject> {
	public List<Case> start(Database.BatchableContext bc) {
		Date dueDate = date.today().addDays(5);
		return [
			SELECT Id, AccountId
			FROM Case
			WHERE
				RecordType.DeveloperName = 'QFR'
				AND Status IN ('Draft', 'New')
				AND Reporting_Due_Date__c = :Date.today().addDays(5)
		];
	}

	public void execute(Database.BatchableContext bc, List<Case> scope) {
		if (scope.size() > 0) {
			AcfrEmailService.sendEmailMain(
				true,
				'eQFR_Submissions_Due_in_5_days',
				scope,
				null,
				null,
				true,
				true,
				false,
				false,
				false
			);
		}
	}

	public void finish(Database.BatchableContext bc) {
		//Nothing required here
	}
}
