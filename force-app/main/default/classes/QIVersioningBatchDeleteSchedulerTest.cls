/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 04-24-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class QIVersioningBatchDeleteSchedulerTest {
   @isTest
    static void testBehavior(){
        try{
            DateTime deleteCreatedDate = DateTime.now().addDays(-402);
            DateTime keepCreatedDate = DateTime.now().addDays(-300);
            Reporting_Period__c rPeriod = TestDataFactory.createReportingPeriod('Quarter');
            Integer recordCount = 1;
            rPeriod.Start_Date__c = (System.today() + 12 ).addMonths(-6);
            rPeriod.End_Date__c = (System.today() + 24).addMonths(-3);
            insert rPeriod;
            // get providers
            List<Account> providers = TestDataFactory.createProviderRecords(recordCount);
            insert providers;
            // get services
            List<BusinessLicense> services = TestDataFactory.createServiceRecords(recordCount);
            insert services;
            // get service account relationships
            List<Service_Account_Relationship__c> serviceAccountRecords = TestDataFactory.createServiceAccountRecords(recordCount, services, providers);
            insert serviceAccountRecords;
            // get quality indicator summary
            List<Contact> contacts = TestDataFactory.createContact(recordCount, providers);
            List<Quality_Indicator_Summary__c> qisRecords = TestDataFactory.createQISummaryRecords(recordCount, providers, rPeriod, services, serviceAccountRecords);
            qisRecords[0].Requested_by__c = contacts[0].Id;
            insert qisRecords;
            // get quality indicator detail
            //test data that has QI Summary Version that is kept
            
            Quality_Indicator_Summary__c testData = [SELECT Id FROM Quality_Indicator_Summary__c WHERE Id = :qisRecords[0].Id ALL ROWS];
            Quality_Indicator_Summary_Version__c qiSummaryKeep = new Quality_Indicator_Summary_Version__c(Quality_Indicator_Summary__c = testData.Id);
            insert qiSummaryKeep;
            Test.setCreatedDate(qiSummaryKeep.Id, keepCreatedDate);

            //test data that has QI Summary Version that is deleted
            Quality_Indicator_Summary_Version__c qiSummaryDelete = new Quality_Indicator_Summary_Version__c(Quality_Indicator_Summary__c = testData.Id);
            insert qiSummaryDelete;
            Test.setCreatedDate(qiSummaryDelete.Id, deleteCreatedDate);

            Test.startTest();
            QIVersioningBatchDeleteScheduler QIBatch= new QIVersioningBatchDeleteScheduler();
            String jobId = System.schedule('testScheduledApex', '0 0 22 ? * 6L', QIBatch);
            Test.stopTest();
            
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId];
            System.assertEquals(0, ct.TimesTriggered);
            
        }catch(Exception exp){
            dohagedcare.Logger.error(exp.getMessage(),exp,'QIVersioningBatchDeleteSchedulerTest ').Log();             
            throw exp;
        }
    }
}