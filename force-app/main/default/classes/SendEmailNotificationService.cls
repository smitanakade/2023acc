/**
* author: Neha Malik
* date: 23/03/2023
* description: This is the Service class to send the email notifications
* @testClass SendEmailNotificationServiceTest
**/
public with sharing class SendEmailNotificationService {
    OrgWideEmailAddress[] owea ;
    private Map<String, EmailNotificationSetting__mdt> mapEmailNotf;
    private static final String SEND_EML_MDT = 'Send_Email';
    private static final List<String> ROLES = new List<String>{ 'QI Role - Service', 'QI Role - Org' };
    private static final String SUBMIT_TEMPLATE = 'QI_Submission_Template';


    public SendEmailNotificationService(){
        mapEmailNotf = EmailNotificationSetting__mdt.getAll();
        String emailAdr = mapEmailNotf.get(SEND_EML_MDT).OWEA__c;
        owea = [SELECT Id, IsAllowAllProfiles, DisplayName, Address FROM OrgWideEmailAddress WHERE Address = :emailAdr LIMIT 1];
    }

    public Messaging.SingleEmailMessage prepareEmailList2(List<String> toAddress, String emailTemplateId, Id targetObjectId, Id whatId){
        Messaging.SingleEmailMessage emailMsg = new Messaging.SingleEmailMessage();
       // List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();


        Messaging.SingleEmailMessage msg = Messaging.renderStoredEmailTemplate(emailTemplateId, targetObjectId, whatId);
        String emailSubject = msg.getSubject();
        String emailTextBody = msg.getPlainTextBody();
        msg.setSubject(emailSubject);
        msg.setPlainTextBody(emailTextBody);
        msg.setToAddresses(toAddress);
        msg.setUseSignature(false);
        msg.setBccSender(false);
        msg.setSaveAsActivity(false);
        msg.setSenderDisplayName('Government Provider Management System');
        return msg;
    }

    public Messaging.SingleEmailMessage prepareEmailList(List<String> toAddress, String emailTemplateId, Id targetObjectId, Id whatId){
        Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
        if ( owea?.size() > 0 ) {
            msg.setOrgWideEmailAddressId(owea[0].id);
        }
        msg.setTemplateId(emailTemplateId);
        msg.setToAddresses(toAddress);
        msg.setWhatId(whatId);
        msg.setUseSignature(false);
        msg.setBccSender(false);
        msg.setSaveAsActivity(true);
        msg.setTargetObjectId(targetObjectId);
        return msg;
    }


    public void sendEmailFromList(List<Messaging.SingleEmailMessage> lstMsgsToSend){
        if(!lstMsgsToSend.isempty()){
            List<Messaging.SendEmailResult> results = new List<Messaging.SendEmailResult>();
            try{
                results = Messaging.sendEmail(lstMsgsToSend,false);
                List<dohagedcare__Application_Log__c> logsList = new List<dohagedcare__Application_Log__c>();
                for(Messaging.SendEmailResult result:results) {
                    boolean isSuccess = result.isSuccess();
                    if(!isSuccess){
                        dohagedcare__Application_Log__c appLog = new dohagedcare__Application_Log__c();
                        appLog.dohagedcare__Exception_Type__c = 'SendEmailNotificationService error';
                        appLog.dohagedcare__Logging_Date_Time__c = System.now();
                        appLog.dohagedcare__Logging_Level__c = 'ERROR';
                        appLog.dohagedcare__Logging_User_Id__c = UserInfo.getUserId();
                        appLog.dohagedcare__Message__c = result.getErrors().get(0).getMessage();
                        appLog.dohagedcare__Source_Application__c = 'Star Rating';
                        logsList.add(appLog);
                    }
                }
                Database.insert(logsList);
            } catch (System.EmailException emlEx) {
                dohagedcare.Logger.error(emlEx.getMessage(),emlEx,'SendEmailNotificationService').Log();
            } catch(Exception exp) {
                dohagedcare.Logger.error(exp.getMessage(),exp,'SendEmailNotificationService').Log();
            }
        }
    }


    /**
    * @description : Send emails
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 05-26-2023
    * @param qiSummaries
    **/
    public void sendEmailForQISubmission(List<Quality_Indicator_Summary__c> qiSummaries){
        try{
            map<id, List<Quality_Indicator_Summary__c>> mapAccQIS= new map<id, List<Quality_Indicator_Summary__c>>();
            List<Quality_Indicator_Summary__c> qisList=[SELECT PROVIDER_ID__c, Reporting_Period__r.Reporting_Period_Short__c, Reporting_Period__r.QI_Submission_Due_Dt__c, Submission_Date_Time__c,
                                                        Service__r.Oracle_Service_ID__c,Service__r.Name FROM Quality_Indicator_Summary__c
                                                        WHERE Id IN : qiSummaries];
            for(Quality_Indicator_Summary__c qis:qisList){
                    if(mapAccQIS.containskey(qis.PROVIDER_ID__c)){
                        List<Quality_Indicator_Summary__c> qisSummaries=new List<Quality_Indicator_Summary__c>();
                        qisSummaries=mapAccQIS.get(qis.PROVIDER_ID__c);
                        qisSummaries.add(qis);
                        mapAccQIS.put(qis.PROVIDER_ID__c, qisSummaries);
                    }
                    else{
                        List<Quality_Indicator_Summary__c> qisSummaries=new List<Quality_Indicator_Summary__c>();
                        qisSummaries.add(qis);
                        mapAccQIS.put(qis.PROVIDER_ID__c, qisSummaries);
                    }
            }
            System.debug('Account Ids FROM QIS:'+ mapAccQIS.keyset());
            AccountUpdation updateAct =new AccountUpdation();
        	updateAct.updateAccountData(mapAccQIS);

            if (!mapAccQIS.isEmpty()) {
                List<AccountContactRelation> acctRelatnList = [
                    SELECT Id, ContactId, AccountId, Roles, Contact.Email
                    FROM AccountContactRelation
                    WHERE Roles INCLUDES('QI Role - Service', 'QI Role - Org') AND AccountId IN :mapAccQIS.keyset() AND Contact.Email != NULL];
                System.debug('acctRelatnList:'+ acctRelatnList);
                List<EmailTemplate> et = [  SELECT Id, HtmlValue, Body
                                            FROM EmailTemplate
                                            WHERE DeveloperName = :SUBMIT_TEMPLATE];
                if(!et.isEmpty()){
                    List<String> toAddress;
                    List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
                    for (AccountContactRelation acctConRelatn : acctRelatnList) {
                        Messaging.SingleEmailMessage emailMsg = new Messaging.SingleEmailMessage();
                        toAddress = new List<String>();
                        toAddress.add(acctConRelatn.Contact.Email);
                        emailMsg = prepareEmailList(toAddress, et[0].Id, acctConRelatn.ContactId, acctConRelatn.AccountId);
                        emailList.add(emailMsg);
                    }
                    sendEmailFromList(emailList);
                }
            }
        }
        catch(Exception exp) {
            dohagedcare.Logger.error(exp.getMessage(),exp,'SendEmailNotificationService').Log();
        }
    }

    //need to update account fields by portal users for sending emails
    // because of that need to run this in without sharing context
    private without sharing class AccountUpdation{

        /**
        * @description : Update Account fields
        * @author Neha | 29-05-2023
        * @param newMap
        **/
        public void updateAccountData(map<id, List<Quality_Indicator_Summary__c>> mapAccQIS) {
            List<Account> accountToUpdate = new List<Account>();
            for(Account acc: [SELECT Id, PreviousReportingPeriodName__c, PreviousReportingPeriodDueDt__c, QISubmissionDetails__c,ServiceNames__c,NAPS_Service_Id__c FROM Account WHERE Id IN :mapAccQIS.keyset()]){
                acc.PreviousReportingPeriodName__c=mapAccQIS.get(acc.id)[0].Reporting_Period__r.Reporting_Period_Short__c;
                acc.PreviousReportingPeriodDueDt__c=mapAccQIS.get(acc.id)[0].Reporting_Period__r.QI_Submission_Due_Dt__c;
                acc.ServiceNames__c = mapAccQIS.get(acc.id)[0].Service__r.Name;
                acc.NAPS_Service_Id__c = mapAccQIS.get(acc.id)[0].Service__r.Oracle_Service_ID__c;
                DateTime submittedDate = mapAccQIS.get(acc.id)[0].Submission_Date_Time__c;
                if(submittedDate != null) {
                    acc.QISubmissionDetails__c= date.newinstance(submittedDate.year(), submittedDate.month(), submittedDate.day());
                }
                accountToUpdate.add(acc);
            }
            if(accountToUpdate.size()>0){
                update accountToUpdate;
            }
        }
    }
}
