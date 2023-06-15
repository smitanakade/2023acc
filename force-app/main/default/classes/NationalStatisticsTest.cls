/**
* author: Daniel Clift
* date: 17/10/2022
* description: Test class for NationalStatistics
**/
@isTest
public with sharing class NationalStatisticsTest {

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
            for(Integer k = 0; k < qisRecords.size(); k++) {
                qisRecords[k].QI_Observed_PI_S2__c = 4;
                qisRecords[k].QI_Observed_PI_S3__c = 4;
                qisRecords[k].QI_Observed_PI_S4__c = 4;
                qisRecords[k].QI_Observed_PI_SDT__c = 4;
                qisRecords[k].QI_Observed_PI_unstageable__c = 4;
                qisRecords[k].QI_Observed_WL_SIG__c = 4;
                qisRecords[k].QI_Observed_FALLS__c = 4;
                qisRecords[k].QI_Observed_Falls_MI__c = 4;
                qisRecords[k].QI_Observed_Polypharmacy__c = 4;
                qisRecords[k].QI_Observed_Physical_Restraint__c = 4;
                qisRecords[k].QI_Observed_APSY__c = 4;

                qisRecords[k].Risk_Adjusted_PI_Level2__c = 4;
            }
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
                    String recordId =Schema.SObjectType.Quality_Indicator_Details__c.getRecordTypeInfosByDeveloperName().get(recordTypes[k]).getRecordTypeId();
                    qidRecords[i].RecordTypeId = recordId;
                }
            }
            insert qidRecords;
        }
        Test.stopTest();
    }

    @isTest
    public static void testCalcNationalAverage() {
        List<Quality_Indicator_Summary__c> qiSummaryList = [SELECT Id, Service__c, 
                                                            QI_Observed_PI_S2__c, QI_Observed_PI_S3__c, QI_Observed_ADL_DEC__c,
                                                            QI_Observed_PI_S4__c, QI_Observed_PI_SDT__c, QI_Observed_PI_unstageable__c, 
                                                            QI_Observed_WL_SIG__c, QI_Observed_FALLS__c, QI_Observed_Falls_MI__c, 
                                                            Reporting_Period__c, QI_Predicted_PI_S2__c, QI_Predicted_PI_S3__c, 
                                                            QI_Predicted_PI_S4__c, QI_Predicted_WL_SIG__c, QI_Predicted_FALLS__c, 
                                                            QI_Predicted_FALLS_MI__c, QI_Observed_Polypharmacy__c, QI_Observed_APSY__c, 
                                                            QI_Observed_Physical_Restraint__c, Risk_Adjusted_PI_Level2__c, Risk_Adjusted_PI_Level3__c, 
                                                            Risk_Adjusted_PI_Level4__c, Risk_Adjusted_DT_PI__c, Risk_Adjusted_Unstageable_PI__c,
                                                            QI_Observed_PIs__c, QI_Observed_PI_S1__c, QI_Observed_PIs_Outside__c,
                                                            QI_Observed_PR_3Day__c, QI_Observed_WL_Cons__c, QI_Observed_MM_APSY_DIG__c,
                                                            QI_Observed_HSP_ED_PR__c, QI_Observed_HSP_ED_ADM__c, QI_Observed_INC__c,
                                                            QI_Observed_INC_IAD__c, QI_Observed_INC_1A__c, QI_Observed_INC_1B__c,
                                                            QI_Observed_INC_2A__c, QI_Observed_INC_2B__c, QI_Observed_WF_Stopped_CM__c,
                                                            QI_Observed_WF_Stopped_RN__c, QI_Observed_WF_Stopped_EN__c, QI_Observed_WF_Stopped_PC__c,
                                                            QI_Observed_CE_Good_SC__c, QI_Observed_CE_Good_Int__c, QI_Observed_CE_Good_PC__c,
                                                            QI_Observed_QL_Good_Int__c, QI_Observed_QL_Good_PC__c, QI_Observed_QL_Good_SC__c
                                                            FROM Quality_Indicator_Summary__c];
        Test.startTest();
        National_Statistic__c ns = NationalStatistics.calcNationalAverage(qiSummaryList);
        Test.stopTest();
        
        System.assertEquals(4, ns.National_percentage_PI_Stage2__c , 'National_percentage_PI_Stage2__c should not be null');
        System.assertEquals(4, ns.National_percentage_significant_UWL__c , 'National_percentage_significant_UWL__c should not be null');
        System.assertEquals(null, ns.Risk_Adjusted_National_PI_Stage2__c , 'Risk_Adjusted_National_PI_Stage2__c should be null');
        NationalStatistics.updateRiskAdjusted(qiSummaryList, ns);
        System.assertNotEquals(null, ns.Risk_Adjusted_National_PI_Stage2__c , 'Risk_Adjusted_National_PI_Stage2__c should not be null');
    }
}