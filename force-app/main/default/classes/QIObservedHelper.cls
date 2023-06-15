/**
* author: Daniel Clift
* date: 02/10/2022
* description: Helper for batch class, logic Calculates QI Observed
**/
public with sharing class QIObservedHelper {

    public static Map<Id, Quality_Indicator_Summary__c> calculateObserved(Map<Id, Quality_Indicator_Summary__c>  qiSummaryMap) {
        Map<Id, Quality_Indicator_Summary__c> qiWithData = new  Map<Id, Quality_Indicator_Summary__c>();  // List to return
        Map<Id, Map<String, Quality_Indicator_Details__c>> qiDetailMap = getQiDetailMap(qiSummaryMap.keySet());

        for(Quality_Indicator_Summary__c qis : qiSummaryMap.values()) {
            // check if late submission and apply criteria for QI to be queried in late-sub QI IP
            if(qis.Status__c == 'Late Submission' || qis.Status__c == 'Updated After Due Date') {
                qis.IPRequired__c = true;
            }
            qis = QualityIndicatorService.checkQiStatusAndRating(qis);

            // show salesforce has was run calc
            qis.QIUpdatedbySiebel__c = false;
        }

        for (Quality_Indicator_Summary__c qiSummary : qiSummaryMap.values()) {
            // eliminates QI Summary with no QI Detail
            if(qiDetailMap.containsKey(qiSummary.Id)) {
                // gets the record types to iterate over
                for(String recordType : qiDetailMap.get(qiSummary.Id).keySet()) {
                    // gets the QI Detail for calc
                    Quality_Indicator_Details__c qiDetail = qiDetailMap.get(qiSummary.Id).get(recordType);

                    if(recordType == 'Pressure_Injuries') {
                        calcQIObsPI(qiDetail, qiSummary);
                    }
                    else if(recordType == 'Physical_Restraint') {
                        calcQIObsPR(qiDetail, qiSummary);
                    }
                    else if(recordType == 'Unplanned_Weight_Loss') {
                        calcQIObsUWL(qiDetail, qiSummary);
                    }
                    else if(recordType == 'Falls_and_Major_Injury') {
                        calcQIObsFMI(qiDetail, qiSummary);
                    }
                    else if(recordType == 'Medication_Management') {
                        calcQIObsMM(qiDetail, qiSummary);
                    }
                    else if(recordType == 'Activities_of_daily_living_ADLs') {
                        qiSummary.QI_Observed_ADL_DEC__c = calcQIObs(qiDetail.No_CR_MBI_declined__c, qiDetail.No_CR_Assessed__c);
                    }
                    else if(recordType == 'Continence') {
                        calcQIObsINC(qiDetail, qiSummary);
                    }
                    else if(recordType == 'Hospitalisation') {
                        calcQIObsHSP(qiDetail, qiSummary);
                    }
                    else if(recordType == 'Workforce') {
                        calcQIObsWF(qiDetail, qiSummary);
                    }
                    else if(recordType == 'Consumer_Experience') {
                        calcQIObsCE(qiDetail, qiSummary);
                    }
                    else if(recordType == 'Quality_of_life') {
                        calcQIObsQOL(qiDetail, qiSummary);
                    }
                    else {
                        continue;
                    }
                }
            }
            qiWithData.put(qiSummary.Id, qiSummary);
        }
        return qiWithData;
    }

    private static void calcQIObsPI(Quality_Indicator_Details__c qiDetail, Quality_Indicator_Summary__c qiSummary) {
        qiSummary.QI_Observed_PI_S2__c = calcQIObs(qiDetail.No_CR_One_More_PI_Stage2__c, qiDetail.No_CR_Assessed__c);
        qiSummary.QI_Observed_PI_S3__c = calcQIObs(qiDetail.No_CR_One_More_PI_Stage3__c, qiDetail.No_CR_Assessed__c);
        qiSummary.QI_Observed_PI_S4__c = calcQIObs(qiDetail.No_CR_One_More_PI_Stage4__c, qiDetail.No_CR_Assessed__c);
        qiSummary.QI_Observed_PI_unstageable__c = calcQIObs(qiDetail.No_CR_PI_Unstagable__c, qiDetail.No_CR_Assessed__c);
        qiSummary.QI_Observed_PI_SDT__c = calcQIObs(qiDetail.No_CR_PI_DeepTissue__c, qiDetail.No_CR_Assessed__c);

        qiSummary.QI_Observed_PIs__c = calcQIObs(qiDetail.No_CR_One_More_PI__c, qiDetail.No_CR_Assessed__c);
        qiSummary.QI_Observed_PI_S1__c = calcQIObs(qiDetail.No_CR_One_More_PI_Stage1__c, qiDetail.No_CR_Assessed__c);
        qiSummary.QI_Observed_PIs_Outside__c = calcQIObs(qiDetail.No_CR_PI_AcqOutside__c, qiDetail.No_CR_Assessed__c);
    }

    private static void calcQIObsPR(Quality_Indicator_Details__c qiDetail, Quality_Indicator_Summary__c qiSummary) {
        qiSummary.QI_Observed_Physical_Restraint__c = calcQIObs(qiDetail.No_CR_Physical_Restrained_3Day__c, qiDetail.No_CR_Assessed__c);
        
        qiSummary.QI_Observed_PR_3Day__c = calcQIObs(qiDetail.No_CR_Physical_Restrained_SecureArea_3D__c, qiDetail.No_CR_Assessed__c);
    }

    private static void calcQIObsUWL(Quality_Indicator_Details__c qiDetail, Quality_Indicator_Summary__c qiSummary) {
        qiSummary.QI_Observed_WL_SIG__c = calcQIObs(qiDetail.Unplanned_Sig_Weight_Loss__c, qiDetail.No_CR_Assessed__c);

        qiSummary.QI_Observed_WL_Cons__c = calcQIObs(qiDetail.Unplanned_Consecutive_Weight_Loss__c, qiDetail.No_CR_Assessed2__c);
    }

    private static void calcQIObsFMI(Quality_Indicator_Details__c qiDetail, Quality_Indicator_Summary__c qiSummary) {
        qiSummary.QI_Observed_FALLS__c = calcQIObs(qiDetail.No_CR_Exp_Fall__c, qiDetail.No_CR_Assessed__c);
        qiSummary.QI_Observed_Falls_MI__c = calcQIObs(qiDetail.No_CR_Exp_FallWith_Injury__c, qiDetail.No_CR_Assessed__c);
    }

    private static void calcQIObsMM(Quality_Indicator_Details__c qiDetail, Quality_Indicator_Summary__c qiSummary) {
        qiSummary.QI_Observed_Polypharmacy__c = calcQIObs(qiDetail.No_CR_Presc_Med__c, qiDetail.No_CR_Assessed__c);
        if(qiDetail.No_CR_rec_antipsychotic__c != null && qiDetail.No_Care_Recipients_diag_d_psychosis__c != null) {
            qiSummary.QI_Observed_APSY__c = calcQIObs((qiDetail.No_CR_rec_antipsychotic__c - qiDetail.No_Care_Recipients_diag_d_psychosis__c), qiDetail.No_CR_Assessed2__c);  
        }
        
        qiSummary.QI_Observed_MM_APSY_DIG__c = calcQIObs(qiDetail.No_Care_Recipients_diag_d_psychosis__c, qiDetail.No_CR_Assessed2__c);
    }

    private static void calcQIObsHSP(Quality_Indicator_Details__c qiDetail, Quality_Indicator_Summary__c qiSummary) {
        qiSummary.QI_Observed_HSP_ED_PR__c = calcQIObs(qiDetail.No_CR_hospitalisation_Pres_assessment__c, qiDetail.No_CR_Assessed__c);
        qiSummary.QI_Observed_HSP_ED_ADM__c = calcQIObs(qiDetail.No_CR_hospitalisation_emerg_assessment__c, qiDetail.No_CR_Assessed__c);
    }

    private static void calcQIObsINC(Quality_Indicator_Details__c qiDetail, Quality_Indicator_Summary__c qiSummary) {
        qiSummary.QI_Observed_INC__c = calcQIObs(qiDetail.No_CR_IAD__c, qiDetail.No_CR_Assessed__c);
        qiSummary.QI_Observed_INC_IAD__c = calcQIObs(qiDetail.No_Care_Recipients_experienced_IAD__c, qiDetail.No_CR_Assessed__c);
        qiSummary.QI_Observed_INC_1A__c = calcQIObs(qiDetail.No_CR_IAD_redness_without_infection__c, qiDetail.No_CR_Assessed__c);
        qiSummary.QI_Observed_INC_1B__c = calcQIObs(qiDetail.No_CR_IAD_redness_with_infection__c, qiDetail.No_CR_Assessed__c);
        qiSummary.QI_Observed_INC_2A__c = calcQIObs(qiDetail.No_CR_IAD_Skin_loss_without_infection__c, qiDetail.No_CR_Assessed__c);
        qiSummary.QI_Observed_INC_2B__c = calcQIObs(qiDetail.No_CR_IAD_Skin_loss_with_infection__c, qiDetail.No_CR_Assessed__c);
    }

    private static void calcQIObsWF(Quality_Indicator_Details__c qiDetail, Quality_Indicator_Summary__c qiSummary) {
        qiSummary.QI_Observed_WF_Stopped_CM__c = calcQIObs(qiDetail.No_staff_stopped_facility_manager__c, qiDetail.No_of_staff_FM_start_quarter__c);
        qiSummary.QI_Observed_WF_Stopped_RN__c = calcQIObs(qiDetail.No_staff_stopped_registered_nurse__c, qiDetail.No_of_staff_NP_start_quarter__c);
        qiSummary.QI_Observed_WF_Stopped_EN__c = calcQIObs(qiDetail.No_staff_stopped_enrolled_nurse__c, qiDetail.No_of_staff_employed_as_Enrolled_Nurse__c);
        qiSummary.QI_Observed_WF_Stopped_PC__c = calcQIObs(qiDetail.No_staff_stopped_personal_care_workers__c, qiDetail.No_of_staff_PCW_start_quarter__c);
    }

    private static void calcQIObsCE(Quality_Indicator_Details__c qiDetail, Quality_Indicator_Summary__c qiSummary) {
        Decimal moderateValueSC = qiDetail.No_CR_Self_CE_completion_Moderate__c != null ? qiDetail.No_CR_Self_CE_completion_Moderate__c : 0;
        Decimal poorValueSC = qiDetail.No_CR_Self_CE_completion_Poor__c != null ? qiDetail.No_CR_Self_CE_completion_Poor__c : 0;
        Decimal veryPoorValueSC = qiDetail.No_CR_Self_CE_completion_VeryPoor__c != null ? qiDetail.No_CR_Self_CE_completion_VeryPoor__c : 0;
        Decimal totalSC = moderateValueSC + poorValueSC + veryPoorValueSC;
        qiSummary.QI_Observed_CE_Good_SC__c = qiDetail.No_CRs_CE_Good_Excellent_SC__c == null ?
                                            null : 
                                            calcQIObs(qiDetail.No_CRs_CE_Good_Excellent_SC__c, (totalSC + qiDetail.No_CRs_CE_Good_Excellent_SC__c));

        Decimal moderateValueI = qiDetail.No_CR_interviewer_admin_CE_Moderate__c != null ? qiDetail.No_CR_interviewer_admin_CE_Moderate__c : 0;
        Decimal poorValueI = qiDetail.No_CR_interviewer_admin_CE_Poor__c != null ? qiDetail.No_CR_interviewer_admin_CE_Poor__c : 0;
        Decimal veryPoorValueI = qiDetail.No_CR_interviewer_admin_CE_VeryPoor__c != null ? qiDetail.No_CR_interviewer_admin_CE_VeryPoor__c : 0;
        Decimal totalI = moderateValueI + poorValueI + veryPoorValueI;                                    
        qiSummary.QI_Observed_CE_Good_Int__c = qiDetail.No_CRs_CE_Good_Excellent_IF__c == null ? 
                                            null : 
                                            calcQIObs(qiDetail.No_CRs_CE_Good_Excellent_IF__c, (totalI + qiDetail.No_CRs_CE_Good_Excellent_IF__c));
                                     
        Decimal moderateValuePC = qiDetail.No_CR_proxy_completion_CE_Moderate__c != null ? qiDetail.No_CR_proxy_completion_CE_Moderate__c : 0;
        Decimal poorValuePC = qiDetail.No_CR_proxy_completion_CE_Poor__c != null ? qiDetail.No_CR_proxy_completion_CE_Poor__c : 0;
        Decimal veryPoorValuePC = qiDetail.No_CR_proxy_completion_CE_VeryPoor__c != null ? qiDetail.No_CR_proxy_completion_CE_VeryPoor__c : 0;
        Decimal totalPC = moderateValuePC + poorValuePC + veryPoorValuePC;
        qiSummary.QI_Observed_CE_Good_PC__c = qiDetail.No_CRs_CE_Good_Excellent_PC__c == null ? 
                                            null : 
                                            calcQIObs(qiDetail.No_CRs_CE_Good_Excellent_PC__c, (totalPC + qiDetail.No_CRs_CE_Good_Excellent_PC__c));
    }
    
    private static void calcQIObsQOL(Quality_Indicator_Details__c qiDetail, Quality_Indicator_Summary__c qiSummary) {
        Decimal moderateValueSC = qiDetail.No_CR_Self_QOL_completion_Moderate__c != null ? qiDetail.No_CR_Self_QOL_completion_Moderate__c : 0;
        Decimal poorValueSC = qiDetail.No_CR_Self_QOL_completion_Poor__c != null ? qiDetail.No_CR_Self_QOL_completion_Poor__c : 0;
        Decimal veryPoorValueSC = qiDetail.No_CR_Self_QOL_completion_VeryPoor__c != null ? qiDetail.No_CR_Self_QOL_completion_VeryPoor__c : 0;
        Decimal totalSC = moderateValueSC + poorValueSC + veryPoorValueSC;
        qiSummary.QI_Observed_QL_Good_SC__c = qiDetail.No_CRs_QOL_Good_Excellent_SC__c == null ? 
                                            null : 
                                            calcQIObs(qiDetail.No_CRs_QOL_Good_Excellent_SC__c, (totalSC + qiDetail.No_CRs_QOL_Good_Excellent_SC__c));

        Decimal moderateValueI = qiDetail.No_CR_interviewer_admin_QOL_Moderate__c != null ? qiDetail.No_CR_interviewer_admin_QOL_Moderate__c : 0;
        Decimal poorValueI = qiDetail.No_CR_interviewer_admin_QOL_Poor__c != null ? qiDetail.No_CR_interviewer_admin_QOL_Poor__c : 0;
        Decimal veryPoorValueI = qiDetail.No_CR_interviewer_admin_QOL_VeryPoor__c != null ? qiDetail.No_CR_interviewer_admin_QOL_VeryPoor__c : 0;
        Decimal totalI = moderateValueI + poorValueI + veryPoorValueI;
        qiSummary.QI_Observed_QL_Good_Int__c = qiDetail.No_CRs_QOL_Good_Excellent_IF__c == null ? 
                                            null : 
                                            calcQIObs (qiDetail.No_CRs_QOL_Good_Excellent_IF__c, (totalI + qiDetail.No_CRs_QOL_Good_Excellent_IF__c));

        Decimal moderateValuePC = qiDetail.No_CR_proxy_completion_QOL_Moderate__c != null ? qiDetail.No_CR_proxy_completion_QOL_Moderate__c : 0;
        Decimal poorValuePC = qiDetail.No_CR_proxy_completion_QOL_Poor__c != null ? qiDetail.No_CR_proxy_completion_QOL_Poor__c : 0;
        Decimal veryPoorValuePC = qiDetail.No_CR_proxy_completion_QOL_VeryPoor__c != null ? qiDetail.No_CR_proxy_completion_QOL_VeryPoor__c : 0;
        Decimal totalPC = moderateValuePC + poorValuePC + veryPoorValuePC;                                    
        qiSummary.QI_Observed_QL_Good_PC__c = qiDetail.No_CRs_QOL_Good_Excellent_PC__c == null ? 
                                            null :
                                            calcQIObs(qiDetail.No_CRs_QOL_Good_Excellent_PC__c, (totalPC + qiDetail.No_CRs_QOL_Good_Excellent_PC__c));
    }

    private static Decimal calcQIObs(Decimal numerator, Decimal denominator) {
        if(numerator != null && denominator != null) {
            return denominator == 0 ? 0 : (numerator / denominator) * 100;
        }
        
        return null;
    }

    private static Map<Id, Map<String, Quality_Indicator_Details__c>> getQiDetailMap(Set<Id> qiIds){
        Map<Id, Map<String, Quality_Indicator_Details__c>> qiDetailMap = new Map<Id, Map<String, Quality_Indicator_Details__c>>();

        List<Quality_Indicator_Details__c> qiDetList =  [SELECT Id, No_CR_One_More_PI_Stage2__c, No_CR_One_More_PI_Stage3__c, No_CR_One_More_PI_Stage4__c,
                                                        No_CR_PI_Unstagable__c, No_CR_PI_DeepTissue__c, No_CR_Assessed__c, No_CR_Physical_Restrained_SecureArea_3D__c,
                                                        Unplanned_Consecutive_Weight_Loss__c, No_CR_Exp_Fall__c,No_CR_Exp_FallWith_Injury__c, No_CR_Presc_Med__c,
                                                        QI_Summary_Id__c, No_CR_rec_antipsychotic__c, No_CR_Assessed2__c, 
                                                        Unplanned_Sig_Weight_Loss__c, RecordType.Name, RecordType.DeveloperName,
                                                        No_CR_One_More_PI__c, No_CR_One_More_PI_Stage1__c, No_CR_PI_AcqOutside__c,
                                                        No_CR_Self_QOL_completion_Moderate__c, No_CR_Self_QOL_completion_Poor__c, No_CR_Self_QOL_completion_VeryPoor__c,
                                                        No_CRs_QOL_Good_Excellent_IF__c, No_CRs_QOL_Good_Excellent_PC__c, No_CRs_QOL_Good_Excellent_SC__c,
                                                        No_CR_Self_CE_completion_Moderate__c, No_CR_Self_CE_completion_Poor__c, No_CR_Self_CE_completion_VeryPoor__c,
                                                        No_CRs_CE_Good_Excellent_SC__c, No_CRs_CE_Good_Excellent_IF__c, No_CRs_CE_Good_Excellent_PC__c,
                                                        No_staff_stopped_facility_manager__c, No_staff_stopped_registered_nurse__c, No_staff_stopped_enrolled_nurse__c, 
                                                        No_staff_stopped_personal_care_workers__c, No_CR_IAD__c, No_Care_Recipients_experienced_IAD__c, 
                                                        No_CR_IAD_redness_without_infection__c, No_CR_IAD_redness_with_infection__c, No_CR_IAD_Skin_loss_without_infection__c,
                                                        No_CR_IAD_Skin_loss_with_infection__c, No_CR_hospitalisation_Pres_assessment__c, No_CR_hospitalisation_emerg_assessment__c,
                                                        No_Care_Recipients_diag_d_psychosis__c, No_CR_Physical_Restrained_3Day__c, No_CR_MBI_declined__c,
                                                        No_CR_proxy_completion_QOL_Moderate__c, No_CR_proxy_completion_QOL_Poor__c, No_CR_proxy_completion_QOL_VeryPoor__c,
                                                        No_CR_interviewer_admin_QOL_Moderate__c, No_CR_interviewer_admin_QOL_Poor__c, No_CR_interviewer_admin_QOL_VeryPoor__c,
                                                        No_CR_proxy_completion_CE_Moderate__c, No_CR_proxy_completion_CE_Poor__c, No_CR_proxy_completion_CE_VeryPoor__c,
                                                        No_CR_interviewer_admin_CE_Moderate__c, No_CR_interviewer_admin_CE_Poor__c, No_CR_interviewer_admin_CE_VeryPoor__c,
                                                        No_of_staff_PCW_start_quarter__c, No_of_staff_NP_start_quarter__c, No_of_staff_FM_start_quarter__c, 
                                                        No_of_staff_employed_as_Enrolled_Nurse__c 
                                                        FROM Quality_Indicator_Details__c WHERE QI_Summary_Id__c IN : qiIds];

        for (Quality_Indicator_Details__c qiDetail : qiDetList) {
            if(qiDetailMap.containsKey(qiDetail.QI_Summary_Id__c)) {
                qiDetailMap.get(qiDetail.QI_Summary_Id__c).put(qiDetail.RecordType.DeveloperName, qiDetail);
            }
            else {
                qiDetailMap.put(qiDetail.QI_Summary_Id__c, new Map<String, Quality_Indicator_Details__c>{qiDetail.RecordType.DeveloperName => qiDetail});
            }
        }
        return qiDetailMap;
    }

    public static Map<Id, Quality_Indicator_Summary__c> updateQiSummaryAndQiRatings(List<Quality_Indicator_Summary__c> qisList) {
        return QIObservedHelper.calculateObserved(new Map<Id, Quality_Indicator_Summary__c>(qisList));
    }

    public static void updateNationalStatsData( Map<Id, Quality_Indicator_Summary__c> qiSummaryList, Boolean lateUpdate){

        //query reporting period and set national average created for period = true.
        Reporting_Period__c rp = [SELECT Id, NationalAverageCreated__c, QuintileRangesCalculated__c FROM Reporting_Period__c WHERE Previous_Reporting_Period__c = true AND Reporting_Period_Type__c = 'Quarter' LIMIT 1];
        // check if national average record has been created for period
        National_Statistic__c ns;
        if(!rp.NationalAverageCreated__c) {
            if(qiSummaryList.size() > 0) {
                ns = NationalStatistics.calcNationalAverage(qiSummaryList.values());
            }
        }
        else {
            ns = [SELECT Id, Reporting_Period__c, National_percentage_PI_Stage2__c, National_percentage_PI_Stage3__c, National_percentage_PI_Stage4__c, National_percentage_PI_Deep_Tissue__c, National_percentage_PI_Unstageable__c, National_percentage_significant_UWL__c, National_percentage_falls__c, National_Percentage_falls_Major_Injury__c,
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
                    UnstgPI_First_Quintile__c, UnstgPI_Fourth_Quintile__c, UnstgPI_Second_Quintile__c, UnstgPI_Third_Quintile__c,
                    Risk_Adjusted_National_PI_Stage2__c, Risk_Adjusted_National_PI_Stage3__c, Risk_Adjusted_National_PI_Stage4__c, 
                    Risk_Adjusted_National_PI_DT__c, Risk_Adjusted_National_PI_Unstageable__c,
                    National_percentage_PIs__c, National_percentage_PI_Stage1__c, National_percentage_PIs_Outside__c,
                    National_percentage_PR_3Day__c, National_percentage_WL_Cons__c, National_percentage_MM_APSY_DIG__c,
                    National_percentage_ADL_DEC__c, National_percentage_HSP_ED_PR__c, National_percentage_HSP_ED_ADM__c,
                    National_percentage_INC__c, National_percentage_INC_IAD__c, National_percentage_INC_1A__c,
                    National_percentage_INC_1B__c, National_percentage_INC_2A__c, National_percentage_INC_2B__c,
                    National_percentage_WF_Stopped_CM__c, National_percentage_WF_Stopped_RN__c, National_percentage_WF_Stopped_EN__c,
                    National_percentage_WF_Stopped_PC__c, National_percentage_CE_Good_SC__c, National_percentage_CE_Good_Int__c,
                    National_percentage_CE_Good_PC__c, National_percentage_QL_Good_Int__c, National_percentage_QL_Good_PC__c, National_percentage_QL_Good_SC__c
                    FROM National_Statistic__c WHERE id IN (SELECT National_Statistic__c FROM Quality_Indicator_Summary__c WHERE Id =:qiSummaryList.values().get(0).Id ) LIMIT 1];
        }
        // calculates Risk & Quintiles
        if(!qiSummaryList.isEmpty()) {
            QualityIndicatorService.qualityIndicatorRatings(qiSummaryList, ns, rp, lateUpdate);
        }

        //update National Statistics for Risk Adjusted values
        if(!rp.NationalAverageCreated__c) {
            rp.NationalAverageCreated__c = true; //set flag to true to avoid re-calculation
            if(qiSummaryList.size() > 0) {
                NationalStatistics.updateRiskAdjusted(qiSummaryList.values(), ns);
            }
            
            try {
                update rp;
            } catch(Exception ex) {
                dohagedcare.Logger.error(ex.getMessage(), ex, 'QIObservedHelper - update reporting period').log();
            }
        }
    }
}