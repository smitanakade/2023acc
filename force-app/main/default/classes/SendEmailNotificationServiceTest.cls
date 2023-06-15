@IsTest
public with sharing class SendEmailNotificationServiceTest {
    @TestSetup
    static void dataSetup(){
        Integer recordCount = 1;
        User testUser = TestDataFactory.createSystemAdminUser();
        System.runAs(testUser){
            // get providers
            List<Account> providers = TestDataFactory.createProviderRecords(recordCount);
            insert providers;
            List<Contact> contToCreate = TestDataFactory.createContact(1,providers);
            insert contToCreate;
            // get services
            List<BusinessLicense> services = TestDataFactory.createServiceRecords(recordCount);
            insert services;
            Reporting_Period__c rPeriod1 = new Reporting_Period__c();
            rPeriod1.Reporting_Period_Type__c = 'Quarter';
            rPeriod1.Start_Date__c = System.today()-20;
            rPeriod1.End_Date__c = System.today() -1;
            rPeriod1.CM_Calc_Date__c = System.today();
            rPeriod1.QI_Calc_Date__c = System.today();
            rPeriod1.StarRating_Calc_Date__c = System.today();
            rPeriod1.QI_Submission_Due_Dt__c = System.today()-1;
            insert rPeriod1;
            // get service account relationships
            List<Service_Account_Relationship__c> serviceAccountRecords = TestDataFactory.createServiceAccountRecords(recordCount, services, providers);
            insert serviceAccountRecords;
            // get quality indicator summary
            List<Quality_Indicator_Summary__c> qisRecords = TestDataFactory.createQISummaryRecords(recordCount, providers, rPeriod1, services, serviceAccountRecords);
            insert qisRecords;
        }
    }

    @isTest
    public static void testSendEmail(){
        Test.startTest();
        EmailTemplate et = [SELECT id FROM EmailTemplate WHERE developername = :'Send_Star_Rating_Report_Template'];
        List<String> toAddress;
        toAddress = new List<String>();
        toAddress.add('abc@xyz.com');
        Account acct = [SELECT Id FROM Account];
        Contact contct = [SELECT Id FROM Contact];
        SendEmailNotificationService notfServ = new SendEmailNotificationService();
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage emailmsg = notfServ.prepareEmailList(toAddress,et.Id,contct.Id,acct.Id);
        emailList.add(emailmsg);
        notfServ.sendEmailFromList(emailList);
        System.assertEquals(1 , Limits.getEmailInvocations());
        Test.stopTest();
    }

     @isTest
    public static void testSendEmailFail(){
        Test.startTest();
        EmailTemplate et = [SELECT id FROM EmailTemplate WHERE developername = :'Send_Star_Rating_Report_Template'];
        List<String> toAddress;
        toAddress = new List<String>();
        for(Integer i=0;i<2200;i++){
        	toAddress.add('qwewreuqrwreqabc@xyz.com');
        }
        Account acct = [SELECT Id FROM Account];
        Contact contct = [SELECT Id FROM Contact];
        SendEmailNotificationService notfServ = new SendEmailNotificationService();
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage emailmsg = notfServ.prepareEmailList(toAddress,et.Id,contct.Id,acct.Id);
        emailList.add(emailmsg);
        Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
        List<Messaging.SendEmailResult> results = Messaging.sendEmail(emailList,false);
        Assert.areEqual(
                'There are too many recipients for this email.',
                 results[0].getErrors()[0].getMessage() );
        Test.stopTest();
    }

     @isTest
    public static void testSendEmailQISubmission(){
        Test.startTest();
        EmailTemplate et = [SELECT id FROM EmailTemplate WHERE developername = :'Send_Star_Rating_Report_Template'];
        List<String> toAddress;
        toAddress = new List<String>();
        toAddress.add('abc@xyz.com');
        Account acct = [SELECT Id FROM Account];
        Contact contct = [SELECT Id FROM Contact];
        List<Quality_Indicator_Summary__c> qisRecords = [Select Id,Service__r.AccountId,Status__c,Submission_Date_Time__c,Reporting_Period__r.Reporting_Period_Short__c,Reporting_Period__r.QI_Submission_Due_Dt__c FROM Quality_Indicator_Summary__c];
        SendEmailNotificationService notfServ = new SendEmailNotificationService();
        if(qisRecords.size()>0){
            notfServ.sendEmailForQISubmission(qisRecords);
        }
        Test.stopTest();
    }
}
