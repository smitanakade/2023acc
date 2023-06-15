/**
 * @description       : update QIS, QIT, QID to match QI Summary Versions
 * @author            : Sharevreet Singh
 * @group             :
 * @last modified on  : 05-19-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class QISVersionTriggerService {
    /***
     * @description update QIS, QIT and QID
     * @params qiSummaries
    **/
    public static void updateQIRelatedObjs(Map<Id, Quality_Indicator_Summary_Version__c> qiSummaryVers) {
        updateQISummary(qiSummaryVers);
    }

    /***
     * @description update QI Summary to match QI Summary Versions
     * @params qiSummaryVers
    **/
    public static void updateQISummary(Map<Id, Quality_Indicator_Summary_Version__c> qiSummaryVerMap){
        List<Quality_Indicator_Summary__c> qisList = new List<Quality_Indicator_Summary__c>();
        Map<id, List<Quality_Indicator_Detail_Version__c>> mapQidVerByQisId= new  Map<id, List<Quality_Indicator_Detail_Version__c>>();
        Map<id, Quality_Indicator_Target_Version__c> mapQitVersionIdQit= new  Map<id, Quality_Indicator_Target_Version__c>();
        Map<Id, Id> MapQisIdQisvId=new Map<Id, Id>();
        Schema.SObjectType Sqis = new Quality_Indicator_Summary__c().getSObjectType();
        Schema.SObjectType SqisVersions = new Quality_Indicator_Summary_Version__c().getSObjectType();
        Map<String, Schema.SObjectField> SqisFields = Sqis.getDescribe().fields.getMap();
        Map<String, Schema.SObjectField> SqisVersionsFields = SqisVersions.getDescribe().fields.getMap();
        Set<Id> qisIds = new Set<Id>();
        try{
            for(Quality_Indicator_Summary_Version__c qiSummaryVer: qiSummaryVerMap.values()) {
                qisIds.add(qiSummaryVer.Quality_Indicator_Summary__c);
                Quality_Indicator_Summary__c qis = new Quality_Indicator_Summary__c();
                for(String fieldName: SqisVersionsFields.keySet()){
                    if(SqisFields.containsKey(fieldName)){
                        if(SqisFields.get(fieldName).getDescribe().isUpdateable()){
                            qis.put(fieldName, qiSummaryVer.get(fieldName));
                        }
                    }
                }
                qis.Id = qiSummaryVer.Quality_Indicator_Summary__c;
                qisList.add(qis);
            }
            if(!qisList.isEmpty()){
                try {
                    Database.update(qisList, false);
                }
                catch(Exception ex) {
                    dohagedcare.Logger.error(ex.getMessage(), ex, 'QualityIndicatorSummaryVerTrigger.cls').log();
                }
            }

            for(Quality_Indicator_Summary_Version__c qisVer: [SELECT Id, Quality_Indicator_Summary__c, (SELECT Id,
                                                    Name,
                                                    RecordTypeId,
                                                    RecordType.Name,
                                                    RecordType.DeveloperName,
                                                    Comments__c,
                                                    Comments2__c ,
                                                    Completion_Date__c ,
                                                    Date_Of_Collection__c ,
                                                    Date_Of_Collection2__c ,
                                                    Estimated_percentage_of_Care_Recipients__c ,
                                                    No_Care_Recipients_diag_d_psychosis__c ,
                                                    No_Care_Recipients_Excl_UnCon_WH_consent__c ,
                                                    No_Care_Recipients_Excl_UnSig_WH_consent__c ,
                                                    No_Care_Recipients_experienced_IAD__c ,
                                                    No_care_recipients_offered_QCE_ACC__c ,
                                                    No_care_recipients_offered_QOL_ACC__c ,
                                                    No_CR_Antipsychotics_Excluded_hopital_7d__c ,
                                                    No_CR_Assessed__c ,
                                                    No_CR_Assessed_incontinence__c ,
                                                    No_CR_Assessed2__c ,
                                                    No_CR_Exclud_Poly_hospit_collection_date__c ,
                                                    No_CR_Excluded_Absent__c ,
                                                    No_CR_Excluded_Consent__c ,
                                                    No_CR_excluded_EOL_Care__c ,
                                                    //No_CR_Excluded_Hospitalised__c ,
                                                    No_CR_Excluded_MissingWtData__c ,
                                                    No_CR_Exp_Fall__c,
                                                    No_CR_Exp_FallWith_Injury__c ,
                                                    //No_CR_hospitalisation_adm_assessment__c ,
                                                    No_CR_hospitalisation_emerg_assessment__c ,
                                                    No_CR_hospitalisation_Pres_assessment__c ,
                                                    No_CR_IAD__c,
                                                    No_CR_IAD_redness_with_infection__c ,
                                                    No_CR_IAD_redness_without_infection__c ,
                                                    No_CR_IAD_Skin_loss_with_infection__c ,
                                                    No_CR_IAD_Skin_loss_without_infection__c,
                                                    No_CR_interviewer_admin_CE_Excellent__c ,
                                                    No_CR_interviewer_admin_CE_Good__c,
                                                    No_CR_interviewer_admin_CE_Moderate__c,
                                                    No_CR_interviewer_admin_CE_Poor__c ,
                                                    No_CR_interviewer_admin_CE_VeryPoor__c ,
                                                    No_CR_interviewer_admin_QOL_Excellent__c,
                                                    No_CR_interviewer_admin_QOL_Good__c ,
                                                    No_CR_interviewer_admin_QOL_Moderate__c ,
                                                    No_CR_interviewer_admin_QOL_Poor__c ,
                                                    No_CR_interviewer_admin_QOL_VeryPoor__c,
                                                    No_CR_MBI_declined__c,
                                                    No_CR_MBI_Score__c ,
                                                    No_CR_One_More_PI__c,
                                                    No_CR_One_More_PI_AcqOutside_DeepTissue__c ,
                                                    No_CR_One_More_PI_AcqOutside_Unstag__c ,
                                                    No_CR_One_More_PI_AcqStage1__c ,
                                                    No_CR_One_More_PI_AcqStage2__c ,
                                                    No_CR_One_More_PI_AcqStage3__c ,
                                                    No_CR_One_More_PI_AcqStage4__c ,
                                                    No_CR_One_More_PI_Stage1__c ,
                                                    No_CR_One_More_PI_Stage2__c ,
                                                    No_CR_One_More_PI_Stage3__c ,
                                                    No_CR_One_More_PI_Stage4__c ,
                                                    No_CR_Physical_Restrained_3Day__c ,
                                                    No_CR_Physical_Restrained_SecureArea_3D__c ,
                                                    No_CR_PI_AcqOutside__c ,
                                                    No_CR_PI_DeepTissue__c ,
                                                    No_CR_PI_Unstagable__c ,
                                                    //No_CR_planned_attend_hospital_assessment__c ,
                                                    //No_CR_PR_Exclusive_Secure_Area__c ,
                                                    No_CR_Presc_Med__c ,
                                                    No_CR_proxy_completion_CE_Excellent__c ,
                                                    No_CR_proxy_completion_CE_Good__c ,
                                                    No_CR_proxy_completion_CE_Moderate__c ,
                                                    No_CR_proxy_completion_CE_Poor__c ,
                                                    No_CR_proxy_completion_CE_VeryPoor__c ,
                                                    No_CR_proxy_completion_QOL_Excellent__c ,
                                                    No_CR_proxy_completion_QOL_Good__c ,
                                                    No_CR_proxy_completion_QOL_Moderate__c ,
                                                    No_CR_proxy_completion_QOL_Poor__c ,
                                                    No_CR_proxy_completion_QOL_VeryPoor__c,
                                                    No_CR_rec_antipsychotic__c ,
                                                    No_CR_rec_antipsychotic_med__c ,
                                                    //No_CR_Record_Assessed_3Day__c ,
                                                    No_CR_Self_CE_completion_Excellent__c ,
                                                    No_CR_Self_CE_completion_Good__c ,
                                                    No_CR_Self_CE_completion_Moderate__c ,
                                                    No_CR_Self_CE_completion_Poor__c ,
                                                    No_CR_Self_CE_completion_VeryPoor__c ,
                                                    No_CR_Self_QOL_completion_Excellent__c ,
                                                    No_CR_Self_QOL_completion_Good__c ,
                                                    No_CR_Self_QOL_completion_Moderate__c ,
                                                    No_CR_Self_QOL_completion_Poor__c,
                                                    No_CR_Self_QOL_completion_VeryPoor__c ,
                                                    No_CRs_CE_Good_Excellent_PC__c ,
                                                    No_CRs_CE_Good_Excellent_SC__c ,
                                                    No_CRs_No_ADL_score__c ,
                                                    No_CRs_QOL_Good_Excellent_IF__c ,
                                                    No_CRs_QOL_Good_Excellent_PC__c ,
                                                    No_CRs_QOL_Good_Excellent_SC__c ,
                                                    No_of_CRs_excluded_EOL_care_2__c ,
                                                    No_of_CRs_excluded_Missing_Weight_data_2__c ,
                                                    No_of_CRs_Excluded_Withheld__c ,
                                                    No_of_staff_employed_as_Enrolled_Nurse__c ,
                                                    No_of_staff_EN_start_quarter__c ,
                                                    No_of_staff_FM_start_quarter__c ,
                                                    No_of_staff_NP_start_quarter__c ,
                                                    No_of_staff_PCW_start_quarter__c ,
                                                    //No_staff_Enrolled_Nurse__c ,
                                                    No_staff_facility_Manager__c ,
                                                    No_staff_Personal_care_workers__c ,
                                                    No_staff_Registered_Nurse__c ,
                                                    No_staff_stopped_enrolled_nurse__c ,
                                                    No_staff_stopped_facility_manager__c ,
                                                    No_staff_stopped_personal_care_workers__c ,
                                                    No_staff_stopped_registered_nurse__c ,
                                                    //QI_Rating__c,
                                                    //QI_Score__c ,
                                                    Version_No__c,
                                                    //SERVICE_ID__c ,
                                                    quality_indicator_ext_id__c ,
                                                    Status__c,
                                                    Unplanned_Consecutive_Weight_Loss__c ,
                                                    Unplanned_Sig_Weight_Loss__c,
                                                    No_CRs_CE_Good_Excellent_IF__c ,
                                                    Error_Flag__c
                                                    FROM Quality_Indicator_Detail_Version__r),
                                                    (SELECT Id,
                                                    External_ID__c,
                                                    Name,
                                                    No_Care_Recipients_experienced_IAD__c,
                                                    No_Care_Recipients_with_Polypharmacy__c,
                                                    No_CR_Exp_Fall__c,
                                                    No_CR_Exp_FallWith_Injury__c,
                                                    No_CR_hospitalisation_emerg_assessment__c,
                                                    No_CR_hospitalisation_Pres_assessment__c,
                                                    No_CR_IAD__c,
                                                    Service__c ,
                                                    No_CR_IAD_redness_with_infection__c,
                                                    No_CR_IAD_redness_without_infection__c,
                                                    No_CR_IAD_Skin_loss_with_infection__c,
                                                    No_CR_IAD_Skin_loss_without_infection__c,
                                                    No_CR_MBI_declined__c,
                                                    No_CR_One_More_PI__c,
                                                    No_CR_One_More_PI_Stage1__c,
                                                    No_CR_One_More_PI_Stage2__c,
                                                    No_CR_One_More_PI_Stage3__c,
                                                    No_CR_One_More_PI_Stage4__c,
                                                    No_CR_Physical_Restrained_3Day__c,
                                                    No_CR_PI_DeepTissue__c,
                                                    No_CR_PI_Unstagable__c,
                                                    No_CR_rec_antipsychotic__c,
                                                    No_CRs_CE_Good_Excellent_IF__c,
                                                    No_CRs_CE_Good_Excellent_PC__c,
                                                    No_CRs_CE_Good_Excellent_SC__c,
                                                    No_CRs_QOL_Good_Excellent_IF__c,
                                                    No_CRs_QOL_Good_Excellent_PC__c,
                                                    No_CRs_QOL_Good_Excellent_SC__c,
                                                    No_staff_stopped_enrolled_nurse__c,
                                                    No_staff_stopped_facility_manager__c,
                                                    No_staff_stopped_personal_care_workers__c,
                                                    No_staff_stopped_registered_nurse__c,
                                                    //Quality_Indicator_Summary__c,
                                                    Unplanned_Consecutive_Weight_Loss__c,
                                                    Reporting_Period__c,
                                                    Unplanned_Sig_Weight_Loss__c
                                                    FROM Quality_Indicator_Target_Versions__r LIMIT 1)
                                                    FROM Quality_Indicator_Summary_Version__c WHERE Id IN :qiSummaryVerMap.keySet()]) {
                mapQidVerByQisId.put(qisVer.Quality_Indicator_Summary__c, qisVer.Quality_Indicator_Detail_Version__r);
                if(!qisVer.Quality_Indicator_Target_Versions__r.isEmpty()){
                    mapQitVersionIdQit.put(qisVer.Quality_Indicator_Summary__c, qisVer.Quality_Indicator_Target_Versions__r);
                }
            }

            Map<Id, Quality_Indicator_Summary__c> qisMap = new Map<Id, Quality_Indicator_Summary__c>();
            for(Quality_Indicator_Summary__c qis: [SELECT Id, (SELECT Id
                                                    FROM Quality_Indicator_Targets__r LIMIT 1),
                                                    (SELECT Id, RecordType.DeveloperName
                                                    FROM Quality_Indicators__r)
                                                    FROM Quality_Indicator_Summary__c WHERE Id IN :qisIds]) {
                qisMap.put(qis.Id, qis);
            }

            updateQIDs(mapQidVerByQisId, qisMap.values());
            if(mapQitVersionIdQit.values().size()>0){
                updateQIT(mapQitVersionIdQit, qisMap);
            }
        }
        catch(Exception ex){
            dohagedcare.Logger.error(ex.getMessage(), ex, 'QIVersionsController.cls').log();
        }
    }


    /**
    * @description update QIDs
    * @params mapQisVersionIdQid
    **/
    public static void updateQIDs(Map<Id, List<Quality_Indicator_Detail_Version__c>> mapQidVerByQisId, List<Quality_Indicator_Summary__c> qisList) {
        Map<Id,Map<String, Id>> qidIdsByQis = qIDsByQIS(qisList);
        Map<String, String> recordTypeMap = new Map<String, String>();
        List<RecordType> recordTypes = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Quality_Indicator_Details__c'];
        for (RecordType rt : recordTypes) {
            recordTypeMap.put(rt.DeveloperName, rt.Id);
        }

        List<Quality_Indicator_Details__c> qids= new List<Quality_Indicator_Details__c>();
        Schema.SObjectType SqidVersions = new Quality_Indicator_Detail_Version__c().getSObjectType();
        Schema.SObjectType Sqid = new Quality_Indicator_Details__c().getSObjectType();
        Map<String, Schema.SObjectField> SqidFields = Sqid.getDescribe(SObjectDescribeOptions.DEFERRED).fields.getMap();
        Map<String, Schema.SObjectField> SqidVersionsFields = SqidVersions.getDescribe().fields.getMap();

        for(Id qisId: mapQidVerByQisId.keySet()) {
            for(Quality_Indicator_Detail_Version__c qidVer: mapQidVerByQisId.get(qisId)) {
                Map<String, Id> qidIdByRt = qidIdsByQis.get(qisId);

                Quality_Indicator_Details__c qid = new Quality_Indicator_Details__c();
                qid.Id = qidIdByRt.get(qidVer.RecordType.DeveloperName);
                for(String fieldName: SqidVersionsFields.keySet()){
                    if(SqidFields.containsKey(fieldName)){
                        if(SqidFields.get(fieldName).getDescribe().isUpdateable()){
                            qid.put(fieldName, qidVer.get(fieldName));
                        }
                    }
                }
                if(recordTypeMap.containsKey(qidVer.RecordType.DeveloperName)){
                    qid.RecordTypeId=recordTypeMap.get(qidVer.RecordType.DeveloperName);
                }
                qids.add(qid);
            }
        }

        if(!qids.isEmpty()){
            try {
                Database.update(qids, false);
            }
            catch(Exception ex) {
                dohagedcare.Logger.error(ex.getMessage(), ex, 'QualityIndicatorSummaryVerTrigger.cls').log();
            }
        }
    }

    private static Map<Id,Map<String, Id>> qIDsByQIS(List<Quality_Indicator_Summary__c> qisList) {
            Map<Id,Map<String, Id>> qidIdsByQis = new Map<Id,Map<String, Id>>();
            for(Quality_Indicator_Summary__c qis : qisList) {
                Map<String, Id> qidIdByRt = new Map<String, Id>();

                for(Quality_Indicator_Details__c qid : qis.Quality_Indicators__r) {
                    qidIdByRt.put(qid.RecordType.DeveloperName, qid.Id);
                }
                qidIdsByQis.put(qis.Id, qidIdByRt);
            }
            return qidIdsByQis;
    }


   /**
    * @description update QIT
    * @params mapQisVersionIdQid
    **/
    public static void updateQIT(Map<Id, Quality_Indicator_Target_Version__c> mapQitVersionIdQit, Map<Id, Quality_Indicator_Summary__c> qisMap) {
        List<Quality_Indicator_Targets__c> qits= new List<Quality_Indicator_Targets__c>();
        Schema.SObjectType Sqit = new Quality_Indicator_Targets__c().getSObjectType();
        Schema.SObjectType SqitVersions = new Quality_Indicator_Target_Version__c().getSObjectType();
        Map<String, Schema.SObjectField> SqitFields = Sqit.getDescribe(SObjectDescribeOptions.DEFERRED).fields.getMap();
        Map<String, Schema.SObjectField> SqitVersionsFields = SqitVersions.getDescribe(SObjectDescribeOptions.DEFERRED).fields.getMap();
        for(Id qitId: mapQitVersionIdQit.keyset()){
            Quality_Indicator_Targets__c qit=new Quality_Indicator_Targets__c();
            for(String fieldName: SqitVersionsFields.keySet()){
                if(SqitFields.containsKey(fieldName)){
                    if(SqitFields.get(fieldName).getDescribe().isUpdateable()){
                        if(mapQitVersionIdQit.get(qitId)!=null){
                            qit.put(fieldName, mapQitVersionIdQit.get(qitId).get(fieldName));
                        }
                    }
                }
            }

            qit.Id = qisMap.get(qitId).Quality_Indicator_Targets__r[0].Id;
            qit.Quality_Indicator_Summary__c = qitId;
            qits.add(qit);
        }

        if(!qits.isEmpty()){
            try {
                Database.update(qits, false);
            }
            catch(Exception ex) {
                dohagedcare.Logger.error(ex.getMessage(), ex, 'QualityIndicatorSummaryVerTrigger.cls').log();
            }
        }
    }
}
