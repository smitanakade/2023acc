/**
* author: Neha Malik
* date: 08-05-2023
* description: Fetch the records from Quality_Indicator_Summary__c. Then send the overdue reminder notifications for QI submissions
**/
public with sharing class QIOverdueRemindersBatch implements Database.Batchable<sObject> {
    private static final String OVERDUE_TEMPLATE = 'QI_Date_Submission_Overdue_Reminder';
    private static final String OVERDUE_TEMPLATE_SERVICE = 'QI_Submission_Overdue_Reminder_Service_User';
    private static final String ORG_ROLE = 'QI Role - Org';
    private static final String SERVICE_ROLE = 'QI Role - Service';
    private static final String OVERDUE_REMINDER = 'overdue';
    private static final List<String> statusCheck = new List<String> {'Submitted','Late Submission','Submitted - Updated After Due Date','Updated After Due Date'};
    private static final String OPERATIONAL = 'Operational';
    private static final String OFFLINE = 'Offline';
    private static final String RESIDENTIAL = 'Residential';
    private static final String APPROVED_PROVIDER = 'Approved_Provider';
    private static final String EMAIL_SUBJECT = 'The QI results for the most recent reporting period are now overdue ​[SEC = OFFICIAL]';
    private static final String CONTACT = 'Contact';
    private static final String FIRST_DAY = 'First';
    private Integer numberOfContacts;
    private String batchDay = '';
    List<Reporting_Period__c> prevRepPeriod = [SELECT ID,Name, Start_Date__c, End_Date__c, QI_Submission_Due_Dt__c,Reporting_Period_Short__c From Reporting_Period__c WHERE Previous_Reporting_Period__c = true AND Reporting_Period_Type__c = 'Quarter'];

    public QIOverdueRemindersBatch(Integer numberOfCt,String batchExecutionDay){
        numberOfContacts = numberOfCt;
        batchDay = batchExecutionDay;
    }

    public Database.QueryLocator start(Database.BatchableContext bc){
        String query;
        Map<String, EmailNotificationSetting__mdt> mapEmailNotf = EmailNotificationSetting__mdt.getAll();
        if(mapEmailNotf.get('Send_Email').QINotifications__c) {
        	if(batchDay!= null && batchDay.equalsIgnoreCase(FIRST_DAY)){
                query = 'SELECT AccountId, ContactId, AccountRecordType__c, Roles, Contact.Email FROM AccountContactRelation '+
                	'WHERE IsActive = true AND AccountRecordType__c =  :APPROVED_PROVIDER '+
                	' AND Contact.Email != null AND Roles INCLUDES (\'QI Role - Service\',\'QI Role - Org\') ' +
                	'AND AccountId IN (select Provider_Name__c from Service_Account_Relationship__c WHERE '+
                	'(Service_Name__r.Status__c = :OPERATIONAL OR Service_Name__r.Status__c = :OFFLINE ) AND '+
                	'Service_Name__r.Care_Type__c = :RESIDENTIAL AND (Association_End_Date__c = null OR Association_End_Date__c >= TODAY))';
            } else {
                 query = 'SELECT Contact.Name,AccountId, ContactId, AccountRecordType__c, Roles, Contact.Email, IsActive '+
            	'FROM AccountContactRelation WHERE IsActive = true AND AccountRecordType__c = :APPROVED_PROVIDER '+
            	' AND Contact.Email != null AND Roles INCLUDES (\'QI Role - Service\',\'QI Role - Org\') AND ContactId '+
            	'NOT IN(select RelationId from EmailMessageRelation WHERE EmailMessage.Subject = :EMAIL_SUBJECT '+
            	' AND RelationObjectType = :CONTACT AND CreatedDate = LAST_N_DAYS:10  ) AND AccountId IN '+
            	'(select Provider_Name__c from Service_Account_Relationship__c WHERE (Service_Name__r.Status__c = :OPERATIONAL '+
            	' OR Service_Name__r.Status__c = :OFFLINE ) AND Service_Name__r.Care_Type__c = :RESIDENTIAL '+
            	' AND (Association_End_Date__c = null OR Association_End_Date__c >= TODAY))';
            }
            if(numberOfContacts >0 ){
                query = query + ' LIMIT :numberOfContacts';
            }
        }
        return Database.getQueryLocator(query);
     }

    public void execute(Database.BatchableContext bc,List<AccountContactRelation> acrRelnList) {
    	if(acrRelnList.size()>0){
        	QIRemindersService qiService = new QIRemindersService();
            String dueDate = qiService.calculateQIReminderDate(prevRepPeriod);
            if(dueDate.equals(OVERDUE_REMINDER)){
            	List<AccountContactRelation> serviceRoleList = new List<AccountContactRelation>();
                List<AccountContactRelation> orgRoleList = new List<AccountContactRelation>();
                for(AccountContactRelation acr:acrRelnList){
                    if(acr.Roles.contains(ORG_ROLE)){
                    	orgRoleList.add(acr);
                    } else if(acr.Roles.contains(SERVICE_ROLE) && !acr.Roles.contains(ORG_ROLE)){
                        serviceRoleList.add(acr);
                    }
                }
                try {
                     List<EmailTemplate> etList = qiService.fetchOverdueTemplate();
                    if(etList.size()>0){
                        if(orgRoleList.size()>0){
                            for(EmailTemplate et:etList){
                                if(et.DeveloperName.equals(OVERDUE_TEMPLATE)){
                                    qiService.prepareAccountData(orgRoleList,prevRepPeriod,et,dueDate);
                                }
                   			}
                        }
                        if(serviceRoleList.size()>0){
                            for(EmailTemplate et:etList){
                                if(et.DeveloperName.equals(OVERDUE_TEMPLATE_SERVICE)){
                                    qiService.prepareContactData(serviceRoleList,prevRepPeriod,et,dueDate);
                                }
                   			}
                    	}
                    }
                 } catch(Exception exp) {
            		dohagedcare.Logger.error(exp.getMessage(),exp,'QIOverdueRemindersBatch').Log();
            	}
            }
        }
     }

    public void finish(Database.BatchableContext bc){
        //No execution required
    }
}
