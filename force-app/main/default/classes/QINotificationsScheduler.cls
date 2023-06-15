/**
* author: Neha Malik
* date: 09-05-2023
* description: This is the scheduler class for QI Notifications
**/
public with sharing class QINotificationsScheduler implements Schedulable{
    private Integer numberOfContacts;
    private String dayOfBatchExecute;

    public QINotificationsScheduler(Integer numberOfCntcts,String dayOfBatchEx){
        numberOfContacts = numberOfCntcts;
        dayOfBatchExecute = dayOfBatchEx;
    }

    public void execute(SchedulableContext sContext) {
        Database.executeBatch(new QIEmailNotificationsBatch(numberOfContacts,dayOfBatchExecute) ,100);
    }
}
