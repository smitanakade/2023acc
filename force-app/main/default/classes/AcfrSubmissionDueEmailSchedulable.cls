public with sharing class AcfrSubmissionDueEmailSchedulable implements Schedulable {
  public void execute(SchedulableContext sc) {
    AcfrSubmissionDueEmailBatch b = new AcfrSubmissionDueEmailBatch();
    Database.executeBatch(b);
  }
}
