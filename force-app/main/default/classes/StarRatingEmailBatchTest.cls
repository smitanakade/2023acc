/**
* author: Neha Malik
* Created date: 14/11/2022
* description: This batch test class is responsible for code coverage for StarRatingEmailBatch.
**/
@IsTest
public class StarRatingEmailBatchTest {

	@TestSetup
    static void dataSetup(){
        Integer recordCount = 20;
        User testUser = TestDataFactory.createSystemAdminUser();

		System.runAs(testUser){
            // get reporting period
            Reporting_Period__c rPeriod = TestDataFactory.createReportingPeriod('Quarter');
            insert rPeriod;
            // get providers
            List<Account> providers = TestDataFactory.createProviderRecords(recordCount);
            insert providers;
            List<Contact> contToCreate = TestDataFactory.createContact(5,providers);
            insert contToCreate;
            List<AccountContactRelation> acctList = new List<AccountContactRelation>();
            AccountContactRelation acr = new AccountContactRelation();
            acr.Accountid = providers[10].id;
            acr.Contactid = contToCreate[0].id;
            acr.Roles = 'Organisation Administrator';
            acctList.add(acr);
            insert acctList;
            // get services
            List<BusinessLicense> services = TestDataFactory.createServiceRecords(recordCount);
            insert services;
            // get service account relationships
            List<Service_Account_Relationship__c> serviceAccountRecords = TestDataFactory.createServiceAccountRecords(recordCount, services, providers);
            insert serviceAccountRecords;
            // get Service Compliance History
            List<Service_Compliance_History__c> schRecords = TestDataFactory.createServiceComplianceHistory(recordCount);
            insert schRecords;
            // get quality indicator summary
            List<Quality_Indicator_Summary__c> qisRecords = TestDataFactory.createQISummaryRecords(recordCount, providers, rPeriod, services, serviceAccountRecords);
            insert qisRecords;
            // get consumer experience reports
            List<SRQI_CER__c> cerRecords = TestDataFactory.createCERRecords(recordCount, serviceAccountRecords, providers, services, rPeriod);
            insert cerRecords;
            // get care minutes summary
            List<Care_Minutes_Summary__c> cmsRecords = TestDataFactory.createCareMinuteSummary(recordCount, services);
            for(Integer i = 0; i < recordCount; i++){
                cmsRecords[i].Provider_Name__c = providers[i].Id;
                cmsRecords[i].Service_Account__c = serviceAccountRecords[i].Id;
            }
            insert cmsRecords;
            // get star rating history records
            List<STAR_Rating_History__c> srhRecords = TestDataFactory.createStarRatingHistoryRecords(recordCount, services, providers, rPeriod);
            for(Integer i = 0; i < srhRecords.size(); i++) {
                srhRecords[i].Care_Minutes_Id__c = cmsRecords[i].Id;
                srhRecords[i].Service_Compliance_Id__c = schRecords[i].Id;
                srhRecords[i].Quality_Indicator_Id__c = qisRecords[i].Id;
                srhRecords[i].Consumer_Experience_Id__c = cerRecords[i].Id;
                srhRecords[i].Rating_Type__c = 'New Rating';
                if(math.mod(i,2) == 0) {
                    srhRecords[i].Publish_Date__c = System.today();
                    srhRecords[i].Status__c = 'Published';
                }
                else {
                    srhRecords[i].Go_Live_Date__c = System.today();
                    srhRecords[i].Status__c = 'Published';
                }

            }
            insert srhRecords;
        }
    }
	public static Boolean runningInASandbox() {
  		return [SELECT Id, IsSandbox FROM Organization LIMIT 1].IsSandbox;
	}

    @isTest
    public static void testQIObserved() {
        Test.startTest();
        Database.executeBatch(new StarRatingEmailBatch(), 10);
        integer count = [Select Count() from EmailMessage where ToAddress = 'ajdkaaajf@xyz.com'];
        Test.stopTest();
        System.assertEquals(0, count);
    }
}