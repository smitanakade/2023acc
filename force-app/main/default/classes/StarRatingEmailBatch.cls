/**
* author: Neha Malik
* Created date: 10/11/2022
* description: This batch class is responsible for sending the emails to the Business users.
* @testClass StarRatingEmailBatchTest
**/
public with sharing class StarRatingEmailBatch implements Database.Batchable<sObject>{

    private Map<String, EmailNotificationSetting__mdt> mapEmailNotf  = EmailNotificationSetting__mdt.getAll();
    private static final String EMAIL_TEMPLATE = 'Send_Star_Rating_Report_Template';
    private static final String SEND_EML_MDT = 'Send_Email';
    public static final String PUBLISHED_STATUS = 'Published';
    public static final String RATING_TYPE = 'New Rating';

    public Database.QueryLocator start(Database.BatchableContext bc){
       String query;
       Date todayDate = System.Today();
       if(mapEmailNotf != null){
        	String roles = mapEmailNotf.get(SEND_EML_MDT).SRRoles__c;
            if(roles ==null){
                roles = 'Organisation Administrator';
            }
       		List <String> rolesList = roles.split(',');
       		String rList = '(\'' + String.join(rolesList,'\',\'')+'\')';
       		query = 'SELECT Id, AccountId,ContactId, Contact.Email, Roles from AccountContactRelation '+
           		'WHERE Contact.Email != null AND Roles INCLUDES '+rList+' AND ' +
           		'AccountId IN (Select SF_Provider_Id__c from STAR_Rating_History__c WHERE Status__c = :PUBLISHED_STATUS '+
           		'AND Publish_Date__c = :todayDate AND Rating_Type__c = :RATING_TYPE)';
        }
       return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc,List<AccountContactRelation> acctRelatnList) {
            try {
				if(acctRelatnList.size()>0){
                    List<Messaging.SingleEmailMessage> lstMsgsToSend = new List<Messaging.SingleEmailMessage>();
                    EmailTemplate et = [SELECT Id from EmailTemplate WHERE DeveloperName = :EMAIL_TEMPLATE];
                    if(et!=null) {
                        SendEmailNotificationService notfService = new SendEmailNotificationService();
                        for (AccountContactRelation acctConRelatn : acctRelatnList){
                            Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
                            List<String> toAddress = new List<String>();
                            toAddress.add(acctConRelatn.Contact.Email);
                            msg = notfService.prepareEmailList(toAddress,et.Id,acctConRelatn.ContactId,acctConRelatn.AccountId);
                            lstMsgsToSend.add(msg);
                        }
                        notfService.sendEmailFromList(lstMsgsToSend);
                    }
                }
            } catch(Exception exp) {
                dohagedcare.Logger.error(exp.getMessage(),exp,'StarRatingEmailBatch').Log();
            }
    }

    public void finish(Database.BatchableContext bc){
         try{
            Map<String, EmailNotificationSetting__mdt> mapEmailNotf = EmailNotificationSetting__mdt.getAll();
            if(mapEmailNotf.get(SEND_EML_MDT).EnableGoLiveNotification__c){
                SRLiveNotificationBatch sRatingBatch = new SRLiveNotificationBatch();
                Database.executeBatch(sRatingBatch,200);
            }
        } catch(Exception exp){
            dohagedcare.Logger.error(exp.getMessage(),exp,'StarRatingEmailBatch').Log();
        }
    }
}
