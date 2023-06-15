/**
* author: Neha Malik
* date: 18/05/2023
* description: This is the service class for the QI notifications which will have all the data regarding Reporting 
* Period and QI summary.
**/
public with sharing class QIRemindersService {
    private static final String BLANK_STRING = '';
    private static final String DUE_REMINDER = 'due';
    private static final String QI_SUBMIT = 'submitQI';
    private static final String OVERDUE_REMINDER = 'overdue';
    private static final String ORG_ROLE = 'QI Role - Org';
    private static final String SERVICE_ROLE = 'QI Role - Service';
    private static final List<String> statusCheck = new List<String> {'Submitted','Late Submission','Submitted - Updated After Due Date','Updated After Due Date'};
    private static final String DUE_TEMPLATE = 'QI_Due_Date';
    private static final String SERVICE_DUE_TEMPLATE = 'QI_Due_Date_Service_User';
    private static final String SUBMIT_TEMPLATE = 'QI_Date_Submission_Reminder';
    private static final String SUBMIT_TEMPLATE_SERVICE = 'QI_Submission_Reminder_Service_User';
    private static final String OVERDUE_TEMPLATE = 'QI_Date_Submission_Overdue_Reminder';
    private static final String OVERDUE_TEMPLATE_SERVICE = 'QI_Submission_Overdue_Reminder_Service_User';
        
    /**
     * This method will return the type of reminder - duedate, QI submission or overdue
     **/
    public String calculateQIReminderDate(List<Reporting_Period__c> prevRepPeriod){
        String reminderType = BLANK_STRING;
        if(prevRepPeriod.size()>0){
           Date todayDt = System.Today();
           Date endDate = prevRepPeriod.get(0).End_Date__c;
           Date dueDate = prevRepPeriod.get(0).QI_Submission_Due_Dt__c;
           if(endDate.daysBetween(todayDt) >= 1 && endDate.daysBetween(todayDt) < 5){
               	reminderType = DUE_REMINDER;
           	} else if(todayDt >= prevRepPeriod.get(0).Start_Date__c && (todayDt.daysBetween(dueDate)<=7 && todayDt.daysBetween(dueDate)>=4)){
               	reminderType = QI_SUBMIT;
           	} else if(todayDt >= prevRepPeriod.get(0).Start_Date__c
           			&& (dueDate.daysBetween(todayDt) >= 1 && dueDate.daysBetween(todayDt) < 5)){
           		reminderType = OVERDUE_REMINDER; 
           	} 
        }
        return reminderType;
    }
    
    /**
     * This method will prepare the list of Providers and send the reminders to the relevant contacts
     * send email reminders to the providers
     **/
    public void sendReminders(List<AccountContactRelation> acrList,EmailTemplate et){
        SendEmailNotificationService notificationService = new SendEmailNotificationService();
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        if(et != null){
        	for (AccountContactRelation acctConRelatn : acrList){
                List<String> toAddress = new List<String>();
                toAddress.add(acctConRelatn.Contact.Email);
                Messaging.SingleEmailMessage emailMsg = new Messaging.SingleEmailMessage();
                emailMsg = notificationService.prepareEmailList(toAddress,et.Id,acctConRelatn.ContactId,acctConRelatn.AccountId);
                emailList.add(emailMsg);
            }
            notificationService.sendEmailFromList(emailList);
        }
    }
    
    /**
     * This method will prepare the data for Org Roles
     **/
    public void prepareAccountDataForOrgRole(List<AccountContactRelation> acrRelnList,List<Reporting_Period__c> prevRepPeriod,EmailTemplate et){
        List<Service_Account_Relationship__c> serviceRelationList = [select Service_Name__r.Id, Service_Name__r.Name, Provider_Name__r.Id,Provider_Name__r.Name  
                                                                                  from Service_Account_Relationship__c WHERE (Service_Name__r.Status__c = 'Operational' OR Service_Name__r.Status__c = 'Offline') AND Service_Name__r.Care_Type__c = 'Residential' AND 
                                                                                  (Association_End_Date__c = null OR Association_End_Date__c >= TODAY)];
        Set<Id> accountIds = new Set<Id>();
        for(Service_Account_Relationship__c serAccReln : serviceRelationList){
        	accountIds.add(serAccReln.Provider_Name__r.Id);
        }
        
        List<Account> acctList = [SELECT Id, PreviousReportingPeriodDueDt__c, PreviousReportingPeriodName__c, ServiceNames__c FROM Account WHERE Id IN :(accountIds)];
        List<Account> accountUpdateList = new List<Account>();
        for(Account acct:acctList){
        	String serviceName = '';
            for(Service_Account_Relationship__c serAccReln : serviceRelationList){
            	if(acct.Id == serAccReln.Provider_Name__r.Id){
                	if(!serviceName.contains(serAccReln.Service_Name__r.Name)){
                    	serviceName = serAccReln.Service_Name__r.Name +', '+ serviceName;
                    }
                    acct.PreviousReportingPeriodName__c = prevRepPeriod.get(0).Reporting_Period_Short__c;
                    acct.PreviousReportingPeriodDueDt__c = prevRepPeriod.get(0).QI_Submission_Due_Dt__c;
                }
            }
            if (serviceName!=''){
            	serviceName = serviceName.removeEnd(', ');
                acct.ServiceNames__c = serviceName;
                accountUpdateList.add(acct);
            }
        }
        if(accountUpdateList.size()>0){
        	update accountUpdateList;
        }
        sendReminders(acrRelnList,et);
    }
    
    /**
     * This method will prepare the data for Service Roles
     **/
    public void prepareContactDataForServiceRole(List<AccountContactRelation> acrRelnList,List<Reporting_Period__c> prevRepPeriod,EmailTemplate et){
         List<Contact_Relationship__c> contactRelationList = [select Service__r.Name,Service__r.Id,Contact__r.Id,Portal_Service_Roles__c from Contact_Relationship__c WHERE (Service__r.Status__c = 'Operational' OR Service__r.Status__c = 'Offline')
                                                             AND Service__r.Care_Type__c = 'Residential' AND Portal_Service_Roles__c INCLUDES ('QI Role - Service')];
        if(contactRelationList.size()>0){
            Set<ID> contactIds = new Set<ID>();
            for(Contact_Relationship__c contReln:contactRelationList){
                if(contReln.Portal_Service_Roles__c.contains('QI Role - Service') && !contReln.Portal_Service_Roles__c.contains('QI Role - Org')){
                    contactIds.add(contReln.Contact__r.Id);
                }
            }             
            List<Contact> contactList = [SELECT Id,ServiceNames__c,PreviousReportingPeriodDueDt__c,PreviousReportingPeriodName__c FROM Contact Where Id IN :(contactIds)];
            List<Contact> contactsToUpdate = new List<Contact>();
            for(Contact contct:contactList){
                String serviceName = '';
                for(Contact_Relationship__c ctReln:contactRelationList){ 
                    if(contct.Id == ctReln.Contact__r.Id){
                        if(!serviceName.contains(ctReln.Service__r.Name)){
                            serviceName = ctReln.Service__r.Name+', '+serviceName;
                        }
                        contct.PreviousReportingPeriodName__c = prevRepPeriod.get(0).Reporting_Period_Short__c;
                        contct.PreviousReportingPeriodDueDt__c = prevRepPeriod.get(0).QI_Submission_Due_Dt__c;
                    }
                } 
                if (serviceName!=''){
                	serviceName = serviceName.removeEnd(', ');
                    contct.ServiceNames__c = serviceName;
                    contactsToUpdate.add(contct);
                }
            }
            if(contactsToUpdate.size()>0){
                update contactsToUpdate;
            }
            sendReminders(acrRelnList,et);
        }
    }
    
     /**
     * This method will prepare the data for Org Roles for QI submission and Overdue
     **/
    public void prepareAccountData(List<AccountContactRelation> acrRelnList,List<Reporting_Period__c> prevRepPeriod,EmailTemplate et,String reminderType){
        List<Service_Account_Relationship__c> serviceRelationList = [select Service_Name__r.Id, Service_Name__r.Name, Provider_Name__r.Id,Provider_Name__r.Name  
                                                                                  from Service_Account_Relationship__c WHERE (Service_Name__r.Status__c = 'Operational' OR Service_Name__r.Status__c = 'Offline') AND Service_Name__r.Care_Type__c = 'Residential' AND 
                                                                                  (Association_End_Date__c = null OR Association_End_Date__c >= TODAY)];
        Set<Id> accountIds = new Set<Id>();
        Set<Id> serviceIDs = new Set<Id>();
        for(Service_Account_Relationship__c serAccReln : serviceRelationList){
        	accountIds.add(serAccReln.Provider_Name__r.Id);
            serviceIDs.add(serAccReln.Service_Name__r.Id);
        }
        List<Quality_Indicator_Summary__c> qISummaryList = new List<Quality_Indicator_Summary__c>();
        if(reminderType.equals(QI_SUBMIT)){
        	qISummaryList =  [SELECT Id, Status__c, REPORTING_PERIOD__r.Start_Date__c, REPORTING_PERIOD__r.End_Date__c, REPORTING_PERIOD__r.QI_Submission_Due_Dt__c,Service__r.Id,Service__r.Name, Service__r.AccountId FROM Quality_Indicator_Summary__c WHERE Status__c = 'Submitted' AND 
                                                             REPORTING_PERIOD__r.Previous_Reporting_Period__c = true AND Service__r.Id IN :(serviceIDs)];
        }
        else if (reminderType.equals(OVERDUE_REMINDER)){
        	qISummaryList =  [SELECT Id, Status__c, REPORTING_PERIOD__r.Start_Date__c, REPORTING_PERIOD__r.End_Date__c, REPORTING_PERIOD__r.QI_Submission_Due_Dt__c,Service__r.Id,Service__r.Name, Service__r.AccountId FROM Quality_Indicator_Summary__c 
                                                             WHERE Status__c IN :(statusCheck) AND REPORTING_PERIOD__r.Previous_Reporting_Period__c = true AND Service__r.Id IN :(serviceIDs)];
        }
        List<Account> acctList = [SELECT Id, PreviousReportingPeriodDueDt__c, PreviousReportingPeriodName__c, ServiceNames__c FROM Account WHERE Id IN :(accountIds)];
        List<Account> accountUpdateList = new List<Account>();
        for(Account acct:acctList){
        	String serviceName = '';
            for(Service_Account_Relationship__c serAccReln : serviceRelationList){
            	if(acct.Id == serAccReln.Provider_Name__r.Id){
                	if(!serviceName.contains(serAccReln.Service_Name__r.Name)){
                    	serviceName = serAccReln.Service_Name__r.Name +', '+ serviceName;
                    }
                    acct.PreviousReportingPeriodName__c = prevRepPeriod.get(0).Reporting_Period_Short__c;
                    acct.PreviousReportingPeriodDueDt__c = prevRepPeriod.get(0).QI_Submission_Due_Dt__c;
                }
            }
            if (serviceName!=''){
            	serviceName = serviceName.removeEnd(', ');
                acct.ServiceNames__c = serviceName;
                accountUpdateList.add(acct);
            }
        }
        if(accountUpdateList.size()>0){
             //check if the qi data is already submitted then remove that service name from the Account field
        	if(qISummaryList.size()>0){
                for(Account acc:accountUpdateList){
                    String serviceNames = acc.ServiceNames__c;
                    for(Quality_Indicator_Summary__c qis:qISummaryList){
                        if(acc.Id == qis.Service__r.AccountId) {
                             if(serviceNames !=null && serviceNames.contains(qis.Service__r.Name)){
                        		serviceNames = serviceNames.remove(qis.Service__r.Name+',');
                    		}                          
                        }
            		}
                    acc.ServiceNames__c = serviceNames;
                }
        	}
        	update accountUpdateList;
        }
        sendReminders(acrRelnList,et); 
    }
    
    /**
     * This method will prepare the data for Service Roles for QI submission and Overdue
     **/
    public void prepareContactData(List<AccountContactRelation> acrRelnList,List<Reporting_Period__c> prevRepPeriod,EmailTemplate et,String reminderType){
        List<Contact_Relationship__c> contactRelationList = [select Service__r.Name,Service__r.Id,Contact__r.Id,Portal_Service_Roles__c from Contact_Relationship__c WHERE (Service__r.Status__c = 'Operational' OR Service__r.Status__c = 'Offline')
                                                             AND Service__r.Care_Type__c = 'Residential' AND Portal_Service_Roles__c INCLUDES ('QI Role - Service')];
        if(contactRelationList.size()>0){
            Set<ID> contactIds = new Set<ID>();
            Set<Id> serviceIds = new Set<Id>();
            for(Contact_Relationship__c contReln:contactRelationList){
                if(contReln.Portal_Service_Roles__c.contains('QI Role - Service') && !contReln.Portal_Service_Roles__c.contains('QI Role - Org')){
                    contactIds.add(contReln.Contact__r.Id);
                    serviceIds.add(contReln.Service__r.Id);
                }
            }             
            List<Contact> contactList = [SELECT Account.Id,ServiceNames__c,PreviousReportingPeriodDueDt__c,PreviousReportingPeriodName__c FROM Contact Where Id IN :(contactIds)];
            List<Contact> contactsToUpdate = new List<Contact>();
            for(Contact contct:contactList){
                String serviceName = '';
                for(Contact_Relationship__c ctReln:contactRelationList){ 
                    if(contct.Id == ctReln.Contact__r.Id){
                        if(!serviceName.contains(ctReln.Service__r.Name)){
                            serviceName = ctReln.Service__r.Name+', '+serviceName;
                        }
                        contct.PreviousReportingPeriodName__c = prevRepPeriod.get(0).Reporting_Period_Short__c;
                        contct.PreviousReportingPeriodDueDt__c = prevRepPeriod.get(0).QI_Submission_Due_Dt__c;
                    }
                } 
                if (serviceName!=''){
                	serviceName = serviceName.removeEnd(', ');
                    contct.ServiceNames__c = serviceName;
                    contactsToUpdate.add(contct);
                }
            }
             List<Quality_Indicator_Summary__c> qISummaryList = new List<Quality_Indicator_Summary__c>();
            if(reminderType.equals(QI_SUBMIT)){
                qISummaryList =  [SELECT Id, Status__c, REPORTING_PERIOD__r.Start_Date__c, REPORTING_PERIOD__r.End_Date__c, REPORTING_PERIOD__r.QI_Submission_Due_Dt__c,Service__r.Id,Service__r.Name, Service__r.AccountId FROM Quality_Indicator_Summary__c WHERE Status__c = 'Submitted' AND 
                                                                 REPORTING_PERIOD__r.Previous_Reporting_Period__c = true AND Service__r.Id IN :(serviceIDs)];
            }
            else if (reminderType.equals(OVERDUE_REMINDER)){
                qISummaryList =  [SELECT Id, Status__c, REPORTING_PERIOD__r.Start_Date__c, REPORTING_PERIOD__r.End_Date__c, REPORTING_PERIOD__r.QI_Submission_Due_Dt__c,Service__r.Id,Service__r.Name, Service__r.AccountId FROM Quality_Indicator_Summary__c 
                                                                 WHERE Status__c IN :(statusCheck) AND REPORTING_PERIOD__r.Previous_Reporting_Period__c = true AND Service__r.Id IN :(serviceIDs)];
            }
            if(contactsToUpdate.size()>0){
                //check if the qi data is already submitted then remove that service name from the Account field
        		if(qISummaryList.size()>0){
                	for(Contact ct:contactsToUpdate){
                        String serviceNames = ct.ServiceNames__c;
                        for(Quality_Indicator_Summary__c qis:qISummaryList){
                            if(ct.Account.Id == qis.Service__r.AccountId) {
                                 if(serviceNames !=null && serviceNames.contains(qis.Service__r.Name)){
                                    serviceNames = serviceNames.remove(qis.Service__r.Name+',');
                                }                          
                            }
                        }
                        ct.ServiceNames__c = serviceNames;
                    }
                }
            	update contactsToUpdate;  
            }
            sendReminders(acrRelnList,et);
        }
    }

    /**
     * This method will fetch due template
     **/
    public List<EmailTemplate> fetchDueTemplate(){
        List<EmailTemplate> etList = [SELECT Id,HtmlValue,Body,DeveloperName FROM EmailTemplate WHERE (DeveloperName = :DUE_TEMPLATE OR DeveloperName = :SERVICE_DUE_TEMPLATE)];
        return etList;
    }
    
    /**
     * This method will fetch due template
     **/
    public List<EmailTemplate> fetchQISubmitTemplate(){
        List<EmailTemplate> etList = [SELECT Id,HtmlValue,Body,DeveloperName FROM EmailTemplate WHERE (DeveloperName = :SUBMIT_TEMPLATE OR DeveloperName = :SUBMIT_TEMPLATE_SERVICE)];
        return etList;
    }
    
    /**
     * This method will fetch due template
     **/
    public List<EmailTemplate> fetchOverdueTemplate(){
        List<EmailTemplate> etList = [SELECT Id,HtmlValue,Body,DeveloperName FROM EmailTemplate WHERE (DeveloperName = :OVERDUE_TEMPLATE OR DeveloperName = :OVERDUE_TEMPLATE_SERVICE)];
        return etList;
    }
}