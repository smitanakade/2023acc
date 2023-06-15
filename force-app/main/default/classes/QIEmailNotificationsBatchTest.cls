@IsTest
public with sharing class QIEmailNotificationsBatchTest {
    @TestSetup
    static void dataSetup(){
        Integer recordCount = 1;
        User testUser = TestDataFactory.createSystemAdminUser();
        System.runAs(testUser){
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

            Reporting_Period__c rPeriod1 = new Reporting_Period__c();
           	rPeriod1.Reporting_Period_Type__c = 'Quarter';
            Date todayDt = System.today();
            Date stDt = System.today() -10;
 			rPeriod1.Start_Date__c = stDt.addMonths(-3);
			rPeriod1.End_Date__c = todayDt.addMonths(-3);
			rPeriod1.CM_Calc_Date__c = System.today();
			rPeriod1.QI_Calc_Date__c = System.today();
			rPeriod1.CER_Calc_Date__c = System.today();
			rPeriod1.StarRating_Calc_Date__c = System.today();
            rPeriod1.QI_Submission_Due_Dt__c = System.today();
            insert rPeriod1;

            // get services
            List<BusinessLicense> services = TestDataFactory.createServiceRecords(recordCount);
            insert services;
            //List<Contact_Relationship__c> contReln = new List<Contact_Relationship__c>();
            Contact_Relationship__c cReln = new Contact_Relationship__c();
            //cReln.Account__r.Id = providers[0].Id;
            cReln.Contact__c = contToCreate[1].Id;
            cReln.Service__c = services[0].Id;
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
    public static void testQIObserved() {
        Test.startTest();
        Map<String, EmailNotificationSetting__mdt> mapEmailNotf = EmailNotificationSetting__mdt.getAll();
        Database.executeBatch(new QIEmailNotificationsBatch(0,'First'), 10);
        System.assertEquals(0 , Limits.getEmailInvocations());
        Test.stopTest();
    }

}
