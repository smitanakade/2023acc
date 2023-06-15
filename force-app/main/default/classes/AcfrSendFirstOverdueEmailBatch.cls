public with sharing class AcfrSendFirstOverdueEmailBatch implements Database.Batchable<sObject> {
  public List<Case> start(Database.BatchableContext bc) {
    Date dueDateFirst = date.today().addDays(-13);
    List<Case> recordFirstList = [
      SELECT Id, Status, AccountId, Reporting_Due_Date__c
      FROM Case
      WHERE
        SkipLateSubmissionEmail__c != 'Yes'
        AND Status != 'Submitted'
        AND Status != 'Re-Submitted'
        AND Reporting_Due_Date__c >= :dueDateFirst
        AND Reporting_Due_Date__c < today
        AND AccountId != NULL
    ];
    return recordFirstList;
  }

  public void execute(Database.BatchableContext bc, List<Case> scope) {
    if (scope.size() > 0) {
      AcfrEmailService.sendEmailMain(
        true,
        'QFR_Overdue_Template',
        scope,
        null,
        null,
        false,
        false,
        false,
        true,
        false
      );
    }
  }

  public void finish(Database.BatchableContext bc) {
    //Nothing required here
  }
}
