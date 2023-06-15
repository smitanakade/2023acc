/**
* author: Daniel Clift
* date: 30/10/2022
* description: Test integration procedure remote action call, for class IntegrationProcedureQIRecalc
**/
@isTest
public with sharing class IntegrationProcedureQIRecalcTest {
    @TestSetup
    static void dataSetup(){
        Integer recordCount = 2;
        User testUser = TestDataFactory.createSystemAdminUser();

		Test.startTest();
		System.runAs(testUser){
            // reporting period
            Reporting_Period__c rPeriod = TestDataFactory.createReportingPeriod('Quarter');
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
            List<Quality_Indicator_Summary__c> qisRecords = TestDataFactory.createQISummaryRecords(recordCount, providers, rPeriod, services, serviceAccountRecords);
            insert qisRecords;
            // get quality indicator detail
            List<Quality_Indicator_Details__c> qidRecords = TestDataFactory.createQIDetailRecords(10, qisRecords);
            List<String> recordTypes = new List<String>{'Pressure_Injuries', 'Physical_Restraint', 'Unplanned_Weight_Loss', 'Falls_and_Major_Injury', 'Medication_Management'};
            for(Integer i = 0; i < qidRecords.size(); i++) {
                if(i < 5) {
                    String recordId = Schema.SObjectType.Quality_Indicator_Details__c.getRecordTypeInfosByDeveloperName().get(recordTypes[i]).getRecordTypeId();
                    qidRecords[i].RecordTypeId = recordId;
                }
                else {
                    Integer k = i - 5;
                    String recordId = Schema.SObjectType.Quality_Indicator_Details__c.getRecordTypeInfosByDeveloperName().get(recordTypes[k]).getRecordTypeId();
                    qidRecords[i].RecordTypeId = recordId;
                }
            }
            insert qidRecords;
        }
        Test.stopTest();
    }

    @isTest
    public static void testRemoteAction() {
        String extensionClass = 'IntegrationProcedureQIRecalc';
        String serviceId = (String) ([SELECT Id FROM BusinessLicense LIMIT 1].Id);

        Test.startTest();
        Callable extension = (Callable) Type.forName(extensionClass).newInstance();

        extension.call('recalcQI', new Map<String, Object> { 
            'input' => new Map<String, Object> {'ServID' => serviceId}
        });
        Test.stopTest();

        Decimal qis = [SELECT Total_QI_Domain_Rating_Score__c FROM Quality_Indicator_Summary__c WHERE Service__c = :serviceId LIMIT 1].Total_QI_Domain_Rating_Score__c;

        System.assertEquals(true, qis == null, 'Total_QI_Domain_Rating_Score__c should be null');
    }

    @isTest
    public static void testMethodDoesNotExist() {
        String extensionClass = 'IntegrationProcedureQIRecalc';
        String serviceId = (String) ([SELECT Id FROM BusinessLicense LIMIT 1].Id);
        
        Test.startTest();
        Callable extension = (Callable) Type.forName(extensionClass).newInstance();
        Object result = extension.call('badMethod', new Map<String, Object> { 
            'input' => new Map<String, Object> {'ServID' => serviceId}
        });
        Test.stopTest();
        System.assertEquals(false, result, 'result should return false');
    }

}