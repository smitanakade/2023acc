/**
 * @author Vivek J
 * @date 23-02-2023
 * @objects 
 * @description : Unit testing for QIDataEntrySubmissionController
 */
@isTest
public with sharing class QIDataEntrySubmissionControllerTest {
    @TestSetup
    static void makeData(){
        Integer recordCount = 1;
        User testUser = TestDataFactory.createSystemAdminUser();

		Test.startTest();
		System.runAs(testUser){
            // reporting period
            Reporting_Period__c rPeriod = TestDataFactory.createReportingPeriod('Quarter');
            rPeriod.Start_Date__c = (System.today() + 12 ).addMonths(-6);
            rPeriod.End_Date__c = (System.today() + 24).addMonths(-3);
            insert rPeriod;
            // get providers//
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
            qisRecords[0].QI_Observed_PI_S2__c = 5;
            qisRecords[0].QI_Observed_PI_S3__c = 5;
            qisRecords[0].QI_Observed_PI_S4__c = 5;
            qisRecords[0].QI_Observed_WL_SIG__c = 10;
            qisRecords[0].QI_Observed_FALLS__c = 15;
            qisRecords[0].QI_Observed_Falls_MI__c = 20;
            qisRecords[0].QI_Observed_PI_unstageable__c = 20;
            qisRecords[0].QI_Observed_PI_SDT__c = 20;

            qisRecords[0].QI_Predicted_PI_S2__c = 10;
            qisRecords[0].QI_Predicted_PI_S3__c = 10;
            qisRecords[0].QI_Predicted_PI_S4__c = 10;
            qisRecords[0].QI_Predicted_WL_SIG__c = 15;
            qisRecords[0].QI_Predicted_FALLS__c = 20;
            qisRecords[0].QI_Predicted_FALLS_MI__c = 25;

            qisRecords[0].QI_Observed_Polypharmacy__c = 10;
            qisRecords[0].QI_Observed_Physical_Restraint__c = 10;
            qisRecords[0].QI_Observed_APSY__c = 10;
            insert qisRecords;

            //Create and calculate National_Statistic__c
            NationalStatistics.calcNationalAverage(qisRecords);
        }
        Test.stopTest();
    }

    @isTest
    static void getfilterComponents_test(){
        QIResponseDTO response=QIDataEntrySubmissionController.getfilterComponents();
        System.assertNotEquals(response, null);
        System.assertNotEquals(response.returnValue,'');
        
    } 
}