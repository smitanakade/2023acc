public with sharing class QIObsCalcScript implements Database.Batchable<sObject>{

    private final static String NS_STATUS = 'Not Submitted';
    private final static String MASTER_RT = 'Master';
    private final static String STATUS_COMP = 'Completed';
    private final static List<String> rpList = new List<String> {'Quarter 1 FY 21 - 22',
        'Quarter 2 FY 21 - 22',
        'Quarter 3 FY 21 - 22',
        'Quarter 4 FY 21 - 22',
        'Quarter 1 FY 22 - 23',
        'Quarter 2 FY 22 - 23',
        'Quarter 3 FY 22 - 23'
        };
    private final static Id userId = [SELECT Id FROM User WHERE Name = 'GPMS User' LIMIT 1].Id;


    public Database.QueryLocator start(Database.BatchableContext bc)
    {
        return Database.getQueryLocator(getQuery());
    }

    public void execute(Database.BatchableContext bc, List<Quality_Indicator_Summary__c> scope)
    {
        if(!scope.isEmpty()) {
            try
            {
                Map<Id, Quality_Indicator_Summary__c> qiMap = updateQiSummaryAndQiRatings(scope);
                update qiMap.values();
            }
            catch(Exception ex)
            {
                System.debug('exception :: '+ex.getMessage());
                dohagedcare.Logger.error(ex.getMessage(), ex, 'QIObservedBatch').log();
            }
        }
    }

    public static String getQuery() {
        User user = [SELECT Id FROM User WHERE Name = 'GPMS User' LIMIT 1];
        

        String query = 'SELECT Id, Status__c, Service__c, QIUpdatedbySiebel__c, QI_Observed_PI_S2__c, QI_Observed_PI_S3__c, ';
        query = query + 'QI_Observed_PI_S4__c, QI_Observed_PI_SDT__c, QI_Observed_PI_unstageable__c, ';
        query = query + 'QI_Observed_WL_SIG__c, QI_Observed_FALLS__c, QI_Observed_Falls_MI__c, Reporting_Period__c, ';
        query = query + 'QI_Predicted_PI_S2__c, QI_Predicted_PI_S3__c, QI_Predicted_PI_S4__c, QI_Predicted_WL_SIG__c, ';
        query = query + 'QI_Predicted_FALLS__c, QI_Predicted_FALLS_MI__c, QI_Observed_Polypharmacy__c, QI_Observed_APSY__c, QI_Observed_Physical_Restraint__c, ';
        query = query + 'Risk_Adjusted_PI_Level2__c, Risk_Adjusted_PI_Level3__c, Risk_Adjusted_PI_Level4__c, ';
        query = query + 'Risk_Adjusted_DT_PI__c, Risk_Adjusted_Unstageable_PI__c, QI_Observed_ADL_DEC__c, '; 
        query = query + 'QI_Observed_PIs__c, QI_Observed_PI_S1__c, QI_Observed_PIs_Outside__c, ';
        query = query + 'QI_Observed_PR_3Day__c, QI_Observed_WL_Cons__c, QI_Observed_MM_APSY_DIG__c, '; 
        query = query + 'QI_Observed_HSP_ED_PR__c, QI_Observed_HSP_ED_ADM__c, QI_Observed_INC__c, '; 
        query = query + 'QI_Observed_INC_IAD__c, QI_Observed_INC_1A__c, QI_Observed_INC_1B__c, '; 
        query = query + 'QI_Observed_INC_2A__c, QI_Observed_INC_2B__c, QI_Observed_WF_Stopped_CM__c, '; 
        query = query + 'QI_Observed_WF_Stopped_RN__c, QI_Observed_WF_Stopped_EN__c, QI_Observed_WF_Stopped_PC__c, '; 
        query = query + 'QI_Observed_CE_Good_SC__c, QI_Observed_CE_Good_Int__c, QI_Observed_CE_Good_PC__c, '; 
        query = query + 'QI_Observed_QL_Good_Int__c, QI_Observed_QL_Good_PC__c, QI_Observed_QL_Good_SC__c, '; 
        query = query + 'Quality_Indicator_Rating__c, (SELECT Id FROM Quality_Indicator_Details__r) ';


        query = query + 'FROM Quality_Indicator_Summary__c ';
        if(!Test.isRunningTest()) {
            query = query + 'WHERE Reporting_Period__r.Reporting_Period_Short__c IN :rpList ';
            query = query + 'AND CreatedById =: userId ';
        }
        return query;
    }

    public void finish(Database.BatchableContext bc){
    }

    public static Map<Id, Quality_Indicator_Summary__c> updateQiSummaryAndQiRatings(List<Quality_Indicator_Summary__c> qisList) {
        return calculateObserved(new Map<Id, Quality_Indicator_Summary__c>(qisList));
    }

    public static Map<Id, Quality_Indicator_Summary__c> calculateObserved(Map<Id, Quality_Indicator_Summary__c>  qiSummaryMap) {
        Map<Id, Quality_Indicator_Summary__c> qiWithData = new  Map<Id, Quality_Indicator_Summary__c>();  // List to return
        Map<Id, Map<String, Quality_Indicator_Details__c>> qiDetailMap = getQiDetailMap(qiSummaryMap.keySet());

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
}