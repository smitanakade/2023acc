@isTest
private class IntegrationProcedureSCRRecalcServiceTest {
    @TestSetup
    static void dataSetup(){
        Integer recordCount = 20;
        User testUser = TestDataFactory.createSystemAdminUser();

		Test.startTest();
		System.runAs(testUser){
            // get reporting period
            Reporting_Period__c rPeriod = TestDataFactory.createReportingPeriod('Quarter');
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
                srhRecords[i].Status__c = 'Draft';
                if(math.mod(i,2) == 0) {
                    srhRecords[i].Publish_Date__c = System.today();
                }
                else {
                    srhRecords[i].Go_Live_Date__c = System.today();
                }
                
            }
            insert srhRecords;
        }
        Test.stopTest();
    }
    @isTest
	public static void testrunIPs() {
        User testUser = TestDataFactory.createSystemAdminUser();
		Test.startTest();
        System.runAs(testUser){


            List<STAR_Rating_History__c> srhRecords = [SELECT Id FROM STAR_Rating_History__c LIMIT 1];
            Map<String, Object> ipInput = new Map<String, Object> (); // used to pass data to 
            ipInput.put('SRHID', srhRecords[0].Id);    
            
            Map<String, Object> args = new Map<String, Object>();
            args.put('input', ipInput);
            args.put('output', new Map<String, Object> ());
            args.put('options', new Map<String, Object> ());
            
            String callableClass = 'IntegrationProcedureSCRRecalcService';
    
            Callable extension = (Callable) Type.forName(callableClass).newInstance();
            Boolean results = (Boolean)extension.call('execute', args);
            Boolean negativeResults = (Boolean)extension.call('NegativeCase', args);
            
            System.assert(results,'Result should be true');
            System.assert(negativeResults,'Result should be true');
        }
		Test.stopTest();
	}
}