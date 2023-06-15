/**
* author: Sharevreet Singh
* date: 14/10/2022
* @description Test class for QuintileScoreCalculator
**/ 
@IsTest
public with sharing class QuintileScoreCalculatorTest {
    @TestSetup
    static void makeData(){
        Integer recordCount = 10;
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
            qisRecords[0].Risk_Adjusted_PI_Level2__c = 5;
            qisRecords[1].Risk_Adjusted_PI_Level2__c = 10;
            qisRecords[2].Risk_Adjusted_PI_Level2__c = 15;
            qisRecords[3].Risk_Adjusted_PI_Level2__c = 20;
            qisRecords[4].Risk_Adjusted_PI_Level2__c = 25;
            qisRecords[5].Risk_Adjusted_PI_Level2__c = 25;
            qisRecords[6].Risk_Adjusted_PI_Level2__c = 30;
            qisRecords[7].Risk_Adjusted_PI_Level2__c = 35;
            qisRecords[8].Risk_Adjusted_PI_Level2__c = 35;
            qisRecords[9].Risk_Adjusted_PI_Level2__c = 40;
            for(Integer i = 0; i < 10; i++) {

                qisRecords[i].QI_Observed_PI_S2__c = 5;
                qisRecords[i].QI_Observed_PI_S3__c = 5;
                qisRecords[i].QI_Observed_PI_S4__c = 5;
                qisRecords[i].QI_Observed_WL_SIG__c = 10;
                qisRecords[i].QI_Observed_FALLS__c = 15;
                qisRecords[i].QI_Observed_Falls_MI__c = 20;
                qisRecords[i].Risk_Adjusted_Falls_with_Major_injury__c = 20;
                qisRecords[i].QI_Observed_PI_unstageable__c = 20;
                qisRecords[i].QI_Observed_PI_SDT__c = 20;
                //qisRecords[i].QI_Observed_Polypharmacy__c = 4;
                qisRecords[i].QI_Observed_Physical_Restraint__c = 4;
                qisRecords[i].QI_Observed_APSY__c = 4;
        
                qisRecords[i].QI_Predicted_PI_S2__c = 10;
                qisRecords[i].QI_Predicted_PI_S3__c = 10;
                qisRecords[i].QI_Predicted_PI_S4__c = 10;
                qisRecords[i].QI_Predicted_WL_SIG__c = 15;
                qisRecords[i].QI_Predicted_FALLS__c = 20;
                qisRecords[i].QI_Predicted_FALLS_MI__c = 25;
            }
            
            insert qisRecords;

            //Create and calculate National_Statistic__c
            NationalStatistics.calcNationalAverage(qisRecords);
        }
        Test.stopTest();
    }

    @IsTest
    static void  calculateQuintileScoreTest() {
       National_Statistic__c nsRecord = [SELECT National_percentage_PI_Stage2__c, National_percentage_PI_Stage3__c, National_percentage_PI_Stage4__c, National_percentage_significant_UWL__c, National_percentage_falls__c, National_Percentage_falls_Major_Injury__c
                                            FROM National_Statistic__c 
                                            LIMIT 1];
        List<Quality_Indicator_Summary__c> qiRecords = [SELECT QI_Observed_PI_S2__c, QI_Observed_PI_S3__c, QI_Observed_PI_S4__c, QI_Observed_WL_SIG__c, QI_Observed_FALLS__c, QI_Observed_Falls_MI__c, QI_Observed_APSY__c, QI_Observed_PI_SDT__c, QI_Observed_Physical_Restraint__c,
                                                                                                    QI_Predicted_PI_S2__c, QI_Predicted_PI_S3__c, QI_Predicted_PI_S4__c, QI_Predicted_WL_SIG__c, QI_Predicted_FALLS__c, QI_Predicted_FALLS_MI__c, QI_Observed_PI_unstageable__c,
                                                                                                    Risk_Adjusted_PI_Level2__c, Risk_Adjusted_PI_Level3__c, Risk_Adjusted_PI_Level4__c, Risk_Adjusted_SUWL__c, Risk_Adjusted_Falls_with_injury__c, Risk_Adjusted_Falls_with_Major_injury__c,
                                                                                                    Antipsychotic_Quintile__c, Deep_Tissue_Pressure_Injury_Quintile__c, Physical_Restraint_Quintile__c, Polypharmacy_Quintile__c, Unstageable_Pressure_Injury_Quintile__c, QI_Observed_Polypharmacy__c,
                                                                                                    Stage_2_Pressure_Injury_Quintile__c, Stage_3_Pressure_Injury_Quintile__c, Stage_4_Pressure_Injury_Quintile__c, Significant_Weight_Loss_Quintile__c, Falls_Quintile__c, Falls_Major_Injury_Quintile__c
                                                                                                    FROM Quality_Indicator_Summary__c];
        Map<Id, Quality_Indicator_Summary__c> qisMap = new Map<Id, Quality_Indicator_Summary__c>();
        for(Quality_Indicator_Summary__c qi : qiRecords) {
            qisMap.put(qi.Id, qi);
        }

        Reporting_Period__c rp = [SELECT Id, NationalAverageCreated__c, QuintileRangesCalculated__c FROM Reporting_Period__c WHERE Previous_Reporting_Period__c = true AND Reporting_Period_Type__c = 'Quarter' LIMIT 1];
        System.assertEquals(false, rp.QuintileRangesCalculated__c, 'Field should be false');

        National_Statistic__c ns = [SELECT Id,
                                    APSY_First_Quintile__c, APSY_Fourth_Quintile__c, APSY_Second_Quintile__c, APSY_Third_Quintile__c,
                                    DTPI_First_Quintile__c, DTPI_Fourth_Quintile__c, DTPI_Second_Quintile__c, DTPI_Third_Quintile__c,
                                    Falls_First_Quintile__c, Falls_Fourth_Quintile__c, Falls_Second_Quintile__c, Falls_Third_Quintile__c,
                                    FallsMI_First_Quintile__c, FallsMI_Fourth_Quintile__c, FallsMI_Second_Quintile__c, FallsMI_Third_Quintile__c,
                                    PhyRes_First_Quintile__c, PhyRes_Fourth_Quintile__c, PhyRes_Second_Quintile__c, PhyRes_Third_Quintile__c,
                                    PolyPharm_First_Quintile__c, PolyPharm_Fourth_Quintile__c, PolyPharm_Second_Quintile__c, PolyPharm_Third_Quintile__c,
                                    SigWL_First_Quintile__c, SigWL_Fourth_Quintile__c, SigWL_Second_Quintile__c, SigWL_Third_Quintile__c,
                                    Stg2PI_First_Quintile__c, Stg2PI_Fourth_Quintile__c, Stg2PI_Second_Quintile__c, Stg2PI_Third_Quintile__c,
                                    Stg3PI_First_Quintile__c, Stg3PI_Fourth_Quintile__c, Stg3PI_Second_Quintile__c, Stg3PI_Third_Quintile__c,
                                    Stg4PI_First_Quintile__c, Stg4PI_Fourth_Quintile__c, Stg4PI_Second_Quintile__c, Stg4PI_Third_Quintile__c,
                                    UnstgPI_First_Quintile__c, UnstgPI_Fourth_Quintile__c, UnstgPI_Second_Quintile__c, UnstgPI_Third_Quintile__c
                                    FROM National_Statistic__c LIMIT 1];

        Test.startTest();
        System.enqueueJob(new QuintileScoreCalculator(qisMap.keySet(), ns, rp, false));
        Test.stopTest();

        rp = [SELECT Id, NationalAverageCreated__c, QuintileRangesCalculated__c FROM Reporting_Period__c WHERE Previous_Reporting_Period__c = true AND Reporting_Period_Type__c = 'Quarter' LIMIT 1];
        //System.assertEquals(true, rp.QuintileRangesCalculated__c, 'Field should be updated to true');
        Quality_Indicator_Summary__c qiRecord = [SELECT Antipsychotic_Quintile__c, Risk_Adjusted_PI_Level2__c, Deep_Tissue_Pressure_Injury_Quintile__c, Physical_Restraint_Quintile__c, Polypharmacy_Quintile__c, Unstageable_Pressure_Injury_Quintile__c, 
                    Stage_2_Pressure_Injury_Quintile__c, Stage_3_Pressure_Injury_Quintile__c, Stage_4_Pressure_Injury_Quintile__c, Significant_Weight_Loss_Quintile__c, Falls_Quintile__c, Falls_Major_Injury_Quintile__c
                    FROM Quality_Indicator_Summary__c 
                    WHERE Risk_Adjusted_PI_Level2__c = 5];
        //System.assertEquals(1, qiRecord.Stage_2_Pressure_Injury_Quintile__c, 'The field should be in the lowest range');

        qiRecord = [SELECT Antipsychotic_Quintile__c, Deep_Tissue_Pressure_Injury_Quintile__c, Risk_Adjusted_PI_Level2__c, Physical_Restraint_Quintile__c, Polypharmacy_Quintile__c, Unstageable_Pressure_Injury_Quintile__c, 
                    Stage_2_Pressure_Injury_Quintile__c, Stage_3_Pressure_Injury_Quintile__c, Stage_4_Pressure_Injury_Quintile__c, Significant_Weight_Loss_Quintile__c, Falls_Quintile__c, Falls_Major_Injury_Quintile__c
                    FROM Quality_Indicator_Summary__c 
                    WHERE Risk_Adjusted_PI_Level2__c = 40];
        //System.assertEquals(5, qiRecord.Stage_2_Pressure_Injury_Quintile__c, 'The field should be in the highest range');

        qiRecord = [SELECT Polypharmacy_Quintile__c 
                    FROM Quality_Indicator_Summary__c 
                    WHERE QI_Observed_Polypharmacy__c = null LIMIT 1];
        //System.assertEquals(null, qiRecord.Polypharmacy_Quintile__c, 'The field should be null for null QI Observed values');
    }
}