public with sharing class AcfrSendFinalOverdueEmailBatch implements Database.Batchable<sObject> {
  public List<Case> start(Database.BatchableContext bc) {
    Date dueDateFirst = date.today().addDays(-13);
    Date dueDateFinal = date.today().addDays(-21);
    List<Case> recordFinalList = [
      SELECT Id, Status, AccountId, Reporting_Due_Date__c
      FROM Case
      WHERE
        SkipLateSubmissionEmail__c != 'Yes'
        AND Status != 'Submitted'
        AND Status != 'Re-Submitted'
        AND Reporting_Due_Date__c >= :dueDateFinal
        AND Reporting_Due_Date__c < :dueDateFirst
        AND AccountId!=null
    ];

    return recordFinalList;
  }

  public void execute(Database.BatchableContext bc, List<Case> scope) {
    if (scope.size() > 0) {
      AcfrEmailService.sendEmailMain(
        true,
        'QFR_Final_Overdue',
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