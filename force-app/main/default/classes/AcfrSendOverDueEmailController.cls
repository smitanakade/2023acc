public with sharing class AcfrSendOverDueEmailController {
  @AuraEnabled
  public static List<String> getRecordCount() {
    List<String> recordCount = new List<String>();
    Date dueDateFirst = date.today().addDays(-13);
    String recordFirstCount = String.valueOf(
      [
          SELECT Id, Status, Reporting_Due_Date__c
          FROM Case
          WHERE
            SkipLateSubmissionEmail__c != 'Yes'
            AND Status != 'Submitted'
            AND Status != 'Re-Submitted'
            AND Reporting_Due_Date__c >= :dueDateFirst
            AND Reporting_Due_Date__c < today
            AND AccountId != NULL
        ]
        .size()
    );
    recordCount.add(recordFirstCount);

    Date dueDateFinal = date.today().addDays(-21);
    String recordFinalCount = String.valueOf(
      [
          SELECT Id, Status, Reporting_Due_Date__c
          FROM Case
          WHERE
            SkipLateSubmissionEmail__c != 'Yes'
            AND Status != 'Submitted'
            AND Status != 'Re-Submitted'
            AND Reporting_Due_Date__c >= :dueDateFinal
            AND Reporting_Due_Date__c < :dueDateFirst
            AND AccountId != NULL
        ]
        .size()
    );
    recordCount.add(recordFinalCount);
    return recordCount;
  }

  @AuraEnabled
  public static void sendOverDueEmail() {
    Database.executeBatch(
      new AcfrSendFirstOverdueEmailBatch(),
      10
    );
    Database.executeBatch(
      new AcfrSendFinalOverdueEmailBatch(),
      10
    );
  }
}
