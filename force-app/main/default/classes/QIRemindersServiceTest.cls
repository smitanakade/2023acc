/**
* author: Neha Malik
* date: 18/05/2023
* description: This is the Test service class for the QI notifications which will have all the data regarding Reporting
* Period and QI summary.
**/
@IsTest
public with sharing class  QIRemindersServiceTest {
    @TestSetup
    static void dataSetup(){
        Integer recordCount = 1;
        User testUser = TestDataFactory.createSystemAdminUser();
        System.runAs(testUser){
            //insert reporting period
            Reporting_Period__c rPeriod1 = new Reporting_Period__c();
            rPeriod1.Reporting_Period_Type__c = 'Quarter';
            Date todayDt = System.today();
            Date stDt = System.today() -10;
            rPeriod1.Start_Date__c = stDt.addMonths(-3);
            rPeriod1.End_Date__c = todayDt.addMonths(-3);
            rPeriod1.QI_Submission_Due_Dt__c = System.today();
            insert rPeriod1;
            // get providers
            List<Account> providers = TestDataFactory.createProviderRecords(recordCount);
            insert providers;
            Account acct = providers.get(0);
            List<Contact> contToCreate = new List<Contact>();
            for (Integer i = 1; i <= 3; i++) {
                Contact testContact = new Contact();
                testContact.Salutation = 'Mr';
                testContact.FirstName = 'First Name' + i;
                testContact.LastName = 'Last Name';
                testContact.AccountId = providers[0].Id;
                testContact.Email = 'TestClassContact@health.gov.au';
                contToCreate.add(testContact);
            }
            insert contToCreate;
           	List<AccountContactRelation> acctList = new List<AccountContactRelation>();
    		List<AccountContactRelation> acrToUpdate = [SELECT Id, Account.RecordType.DeveloperName, Roles
      													FROM AccountContactRelation
      													WHERE Account.ParentId = :acct.Id OR AccountId = :acct.Id
    													];
            integer counter = 0;
    		for (AccountContactRelation iterAcr : acrToUpdate) {
                if(counter > 0) {
                   iterAcr.roles = 'QI Role - Service';
                } else {
        			iterAcr.roles = 'QI Role - Org';
                }
                	++counter ;
    		}
    		update (acrToUpdate);
        	// get services
            List<BusinessLicense> services = TestDataFactory.createServiceRecords(recordCount);
            insert services;
            //List<Contact_Relationship__c> contReln = new List<Contact_Relationship__c>();
            Contact_Relationship__c cReln = new Contact_Relationship__c();
            //cReln.Account__r.Id = providers[0].Id;
            cReln.Contact__c = contToCreate[1].Id;
            cReln.Service__c = services[0].Id;
            cReln.Portal_Service_Roles__c = 'QI Role - Service';
            insert cReln;

            // get service account relationships
            List<Service_Account_Relationship__c> serviceAccountRecords = TestDataFactory.createServiceAccountRecords(recordCount, services, providers);
            insert serviceAccountRecords;
            // get quality indicator summary
            List<Quality_Indicator_Summary__c> qisRecords = TestDataFactory.createQISummaryRecords(recordCount, providers, rPeriod1, services, serviceAccountRecords);
            insert qisRecords;
        }
    }

    @isTest
    static void testQIReminderDate(){
        Test.startTest();
        QIRemindersService reminderService = new QIRemindersService();
        List<Reporting_Period__c> repPd = [SELECT End_Date__c,Start_Date__c,QI_Submission_Due_Dt__c FROM Reporting_Period__c];
        String notificationType = reminderService.calculateQIReminderDate(repPd);
        System.assertEquals('', notificationType);
        Test.stopTest();        
    }

    @isTest
    static void testSendReminders(){
        Test.startTest();
        QIRemindersService reminderService = new QIRemindersService();
        List<AccountContactRelation> acrList = [SELECT AccountId, ContactId, Roles, Contact.Email FROM AccountContactRelation];
        EmailTemplate et = [SELECT Id,HtmlValue,Body from EmailTemplate WHERE DeveloperName = 'QI_Due_Date'];
        reminderService.sendReminders(acrList,et);
        System.assertEquals(1 , Limits.getEmailInvocations());
        Test.stopTest();
    }

    @isTest
    static void testAccountDataForDueDt(){
        Test.startTest();
        QIRemindersService reminderService = new QIRemindersService();
        List<AccountContactRelation> acrList = [SELECT AccountId, ContactId, Roles, Contact.Email FROM AccountContactRelation];
        EmailTemplate et = [SELECT Id,HtmlValue,Body from EmailTemplate WHERE DeveloperName = 'QI_Due_Date'];
        List<Reporting_Period__c> repPd = [SELECT End_Date__c,Reporting_Period_Short__c,Start_Date__c,QI_Submission_Due_Dt__c FROM Reporting_Period__c];
        reminderService.prepareAccountDataForOrgRole(acrList,repPd,et);
        System.assertEquals(1 , Limits.getEmailInvocations());
        Test.stopTest();
    }

    @isTest
    static void testServiceDataForDueDt(){
        Test.startTest();
        QIRemindersService reminderService = new QIRemindersService();
        List<AccountContactRelation> acrList = [SELECT AccountId, ContactId, Roles, Contact.Email FROM AccountContactRelation];
        EmailTemplate et = [SELECT Id,HtmlValue,Body from EmailTemplate WHERE DeveloperName = 'QI_Due_Date'];
        List<Reporting_Period__c> repPd = [SELECT Reporting_Period_Short__c,End_Date__c,Start_Date__c,QI_Submission_Due_Dt__c FROM Reporting_Period__c];
        reminderService.prepareContactDataForServiceRole(acrList,repPd,et);
        Test.stopTest();
    }

    @isTest
    static void testAccountData(){
        Test.startTest();
        QIRemindersService reminderService = new QIRemindersService();
        List<AccountContactRelation> acrList = [SELECT AccountId, ContactId, Roles, Contact.Email FROM AccountContactRelation];
        EmailTemplate et = [SELECT Id,HtmlValue,Body from EmailTemplate WHERE DeveloperName = 'QI_Due_Date'];
        List<Reporting_Period__c> repPd = [SELECT Reporting_Period_Short__c,End_Date__c,Start_Date__c,QI_Submission_Due_Dt__c FROM Reporting_Period__c];
        reminderService.prepareAccountData(acrList,repPd,et,'submitQI');
        System.assertEquals(1 , Limits.getEmailInvocations());
        Test.stopTest();
    }

    @isTest
    static void testContactData(){
        Test.startTest();
        QIRemindersService reminderService = new QIRemindersService();
        List<AccountContactRelation> acrList = [SELECT AccountId, ContactId, Roles, Contact.Email FROM AccountContactRelation];
        EmailTemplate et = [SELECT Id,HtmlValue,Body from EmailTemplate WHERE DeveloperName = 'QI_Due_Date'];
        List<Reporting_Period__c> repPd = [SELECT Reporting_Period_Short__c,End_Date__c,Start_Date__c,QI_Submission_Due_Dt__c FROM Reporting_Period__c];
        reminderService.prepareContactData(acrList,repPd,et,'submitQI');
        Test.stopTest();
    }

    @isTest
    static void testfetchDueTemplate(){
        Test.startTest();
        QIRemindersService reminderService = new QIRemindersService();
        List<EmailTemplate> etList = reminderService.fetchDueTemplate();
        System.assertEquals(2,etList.size());
        Test.stopTest();
    }

    @isTest
    static void fetchQISubmitTemplate(){
        Test.startTest();
        QIRemindersService reminderService = new QIRemindersService();
        List<EmailTemplate> etList = reminderService.fetchQISubmitTemplate();
        System.assertEquals(2,etList.size());
        Test.stopTest();
    }

    @isTest
    static void fetchOverdueTemplate(){
        Test.startTest();
        QIRemindersService reminderService = new QIRemindersService();
        List<EmailTemplate> etList = reminderService.fetchOverdueTemplate();
        System.assertEquals(2,etList.size());
        Test.stopTest();
    }
}