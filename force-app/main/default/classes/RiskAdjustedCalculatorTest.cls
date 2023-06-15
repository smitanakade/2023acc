/**
* author: Sharevreet Singh
* date: 14/10/2022
* description: Test class for RiskAdjustedCalculator.
**/ 
@IsTest
public with sharing class RiskAdjustedCalculatorTest {
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
            qisRecords[0].QI_Observed_Polypharmacy__c = 4;
            qisRecords[0].QI_Observed_Physical_Restraint__c = 4;
            qisRecords[0].QI_Observed_APSY__c = 4;
            insert qisRecords;

            //Create and calculate National_Statistic__c
            NationalStatistics.calcNationalAverage(qisRecords);
        }
        Test.stopTest();
    }

    @IsTest
    static void  calculateRiskAdjustedTest() {
        National_Statistic__c nsRecord = [SELECT National_percentage_PI_Stage2__c, National_percentage_PI_Stage3__c, National_percentage_PI_Stage4__c, National_percentage_significant_UWL__c, National_percentage_falls__c, National_Percentage_falls_Major_Injury__c,
                                            National_percentage_PI_Deep_Tissue__c, National_percentage_PI_Unstageable__c
                                            FROM National_Statistic__c 
                                            LIMIT 1];
        Quality_Indicator_Summary__c qiRecord = [SELECT QI_Observed_PI_S2__c, QI_Observed_PI_S3__c, QI_Observed_PI_S4__c, QI_Observed_WL_SIG__c, QI_Observed_FALLS__c, QI_Observed_Falls_MI__c,
                                                    QI_Predicted_PI_S2__c, QI_Predicted_PI_S3__c, QI_Predicted_PI_S4__c, QI_Predicted_WL_SIG__c, QI_Predicted_FALLS__c, QI_Predicted_FALLS_MI__c, 
                                                    QI_Observed_PI_unstageable__c, QI_Observed_PI_SDT__c, Risk_Adjusted_DT_PI__c, Risk_Adjusted_Unstageable_PI__c,
                                                    Risk_Adjusted_PI_Level2__c, Risk_Adjusted_PI_Level3__c, Risk_Adjusted_PI_Level4__c, Risk_Adjusted_SUWL__c, Risk_Adjusted_Falls_with_injury__c, Risk_Adjusted_Falls_with_Major_injury__c
                                                    FROM Quality_Indicator_Summary__c 
                                                    LIMIT 1];
        System.assertEquals(null, qiRecord.Risk_Adjusted_PI_Level2__c, 'The field should be null');

        RiskAdjustedCalculator raCal = new RiskAdjustedCalculator(qiRecord, nsRecord);
        qiRecord = raCal.calculateRiskAdjusted();
        
        System.assertNotEquals(null, qiRecord.Risk_Adjusted_PI_Level2__c, 'The field should not be null');

        qiRecord.QI_Observed_PI_S2__c = null;
        update qiRecord;

        raCal = new RiskAdjustedCalculator(qiRecord, nsRecord);
        qiRecord = raCal.calculateRiskAdjusted();

        System.assertEquals(null, qiRecord.Risk_Adjusted_PI_Level2__c, 'The field should be null if QI_Observed_PI_S2__c is null');
    }
}