/**
* Author : Vivek Jaiswal
* Date : 11/04/2023
* Description : QI Version controller
**/
public with sharing class QIVersionsController {
    @TestVisible private static final String QI_Status_InProgress = 'In Progress';
    /***
     * @description create QI  verions
     * @params qiSummaries
    **/
    public static void createQIVersions(List<Quality_Indicator_Summary__c> qiSummaries){
        createQISummaryVersion(qiSummaries,'');
    }

    /***
     * @description create QI  verions
     * @params qiSummaries
    **/
    public static void createDraftQIVersions(List<Quality_Indicator_Summary__c> qiSummaries, String qisvStatus){
        createQISummaryVersion(qiSummaries, qisvStatus);
    }

    /***
     * @description create QI Summary verions
     * @params qiSummaries
    **/
    public static void createQISummaryVersion(List<Quality_Indicator_Summary__c> qiSummaries, String qisvStatus){
        List<Quality_Indicator_Summary_Version__c> qisVersions= new List<Quality_Indicator_Summary_Version__c>();
        Map<id, List<Quality_Indicator_Details__c>> mapQisVersionIdQid= new  Map<id, List<Quality_Indicator_Details__c>>();
        Map<id, Quality_Indicator_Targets__c> mapQisVersionIdQit= new  Map<id, Quality_Indicator_Targets__c>();
        Map<Id, Id> MapQisIdQisvId=new Map<Id, Id>();
        Schema.SObjectType Sqis = new Quality_Indicator_Summary__c().getSObjectType();
        Schema.SObjectType SqisVersions = new Quality_Indicator_Summary_Version__c().getSObjectType();
        Map<String, Schema.SObjectField> SqisFields = Sqis.getDescribe().fields.getMap();
        Map<String, Schema.SObjectField> SqisVersionsFields = SqisVersions.getDescribe().fields.getMap();
        try{
            for(Quality_Indicator_Summary__c qiSummary: qiSummaries){
                Quality_Indicator_Summary_Version__c qisVersion=new Quality_Indicator_Summary_Version__c();
                for(String fieldName: SqisFields.keySet()){
                    if(SqisVersionsFields.containsKey(fieldName)){
                        if(SqisVersionsFields.get(fieldName).getDescribe().isUpdateable()){
                            qisVersion.put(fieldName, qiSummary.get(fieldName));
                        }
                    }
                }
                qisVersion.Quality_Indicator_Summary__c=qiSummary.id;
                qisVersion.QISVName__c=qiSummary.Name;
                qisVersion.Version__c=qiSummary.QIS_Versions__c+1;
                qisVersion.Requested_by__c=null;
                if(qisvStatus!='' && qisvStatus==QI_Status_InProgress){
                    qisVersion.Submitted_By__c=null;
                    qisVersion.Submission_Date_Time__c=null;
                    qisVersion.Status__c=qisvStatus;
                }
                qisVersions.add(qisVersion);
            }
            if(!qisVersions.isEmpty()){
                try {
                    Database.insert(qisVersions, false);
                }
                catch(Exception ex) {
                    dohagedcare.Logger.error(ex.getMessage(), ex, 'QIVersionsController.cls').log();
                }
            }

            for(Quality_Indicator_Summary_Version__c qisv:[SELECT Id, Quality_Indicator_Summary__c FROM Quality_Indicator_Summary_Version__c WHERE Id IN :qisVersions] ){
                MapQisIdQisvId.put(qisv.Quality_Indicator_Summary__c, qisv.id);
            }
            for(Quality_Indicator_Summary__c qis: [SELECT id, (SELECT Id,
                                                    Name,
                                                    RecordTypeId,
                                                    RecordType.Name,
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
                                                    No_CR_Excluded_Hospitalised__c ,
                                                    No_CR_Excluded_MissingWtData__c ,
                                                    No_CR_Exp_Fall__c,
                                                    No_CR_Exp_FallWith_Injury__c ,
                                                    No_CR_hospitalisation_adm_assessment__c ,
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
                                                    No_CR_planned_attend_hospital_assessment__c ,
                                                    No_CR_PR_Exclusive_Secure_Area__c ,
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
                                                    No_CR_Record_Assessed_3Day__c ,
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
                                                    No_staff_Enrolled_Nurse__c ,
                                                    No_staff_facility_Manager__c ,
                                                    No_staff_Personal_care_workers__c ,
                                                    No_staff_Registered_Nurse__c ,
                                                    No_staff_stopped_enrolled_nurse__c ,
                                                    No_staff_stopped_facility_manager__c ,
                                                    No_staff_stopped_personal_care_workers__c ,
                                                    No_staff_stopped_registered_nurse__c ,
                                                    QI_Rating__c,
                                                    QI_Score__c ,
                                                    Version_No__c,
                                                    SERVICE_ID__c ,
                                                    quality_indicator_ext_id__c ,
                                                    Status__c,
                                                    Unplanned_Consecutive_Weight_Loss__c ,
                                                    Unplanned_Sig_Weight_Loss__c,
                                                    No_CRs_CE_Good_Excellent_IF__c,
                                                    Error_Flag__c
                                                    FROM Quality_Indicators__r),
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
                                                    Quality_Indicator_Summary__c,
                                                    Unplanned_Consecutive_Weight_Loss__c,
                                                    Reporting_Period__c,
                                                    Unplanned_Sig_Weight_Loss__c
                                                    From Quality_Indicator_Targets__r LIMIT 1)
                                                    FROM Quality_Indicator_Summary__c WHERE Id IN :MapQisIdQisvId.keyset()]){
                mapQisVersionIdQid.put(MapQisIdQisvId.get(qis.id), qis.Quality_Indicators__r);
                if(!qis.Quality_Indicator_Targets__r.isEmpty()){
                    mapQisVersionIdQit.put(MapQisIdQisvId.get(qis.id), qis.Quality_Indicator_Targets__r);
                }
            }
            createQIDetailsVersion(mapQisVersionIdQid);
            if(mapQisVersionIdQit.values().size()>0){
                createQITargetVersion(mapQisVersionIdQit);
            }
        }
        catch(Exception ex){
            System.debug('Exception creating QI version data');
            System.debug(ex);
            dohagedcare.Logger.error(ex.getMessage(), ex, 'QIVersionsController.cls').log();
        }
    }
    /***
     * @description create QID  verions
     * @params mapQisVersionIdQid
    **/
    public static void createQIDetailsVersion(Map<id, List<Quality_Indicator_Details__c>> mapQisVersionIdQid){
       Map<String, String> recordTypeMap = new Map<String, String>();
        List<RecordType> recordTypes = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Quality_Indicator_Detail_Version__c'];
        for (RecordType rt : recordTypes) {
            recordTypeMap.put(rt.Name, rt.Id);
        }
        List<Quality_Indicator_Detail_Version__c> qidVersions= new List<Quality_Indicator_Detail_Version__c>();
        Schema.SObjectType Sqid = new Quality_Indicator_Details__c().getSObjectType();
        Schema.SObjectType SqidVersions = new Quality_Indicator_Detail_Version__c().getSObjectType();
        Map<String, Schema.SObjectField> SqidFields = Sqid.getDescribe().fields.getMap();
        Map<String, Schema.SObjectField> SqidVersionsFields = SqidVersions.getDescribe().fields.getMap();
        for(String qisvid: mapQisVersionIdQid.keyset()){
        for(Quality_Indicator_Details__c qiDetail: mapQisVersionIdQid.get(qisvid)){
                Quality_Indicator_Detail_Version__c qidVersion=new Quality_Indicator_Detail_Version__c();
                for(String fieldName: SqidFields.keySet()){
                    if(SqidVersionsFields.containsKey(fieldName)){
                        if(SqidVersionsFields.get(fieldName).getDescribe().isUpdateable()){
                           qidVersion.put(fieldName, qiDetail.get(fieldName));
                        }
                    }
                }
                qidVersion.Quality_Indicator_Summary_Version__c=qisvid;
                qidVersion.QIDVName__c=qiDetail.Name;
                if(recordTypeMap.containsKey(qiDetail.RecordType.Name)){
                    qidVersion.RecordTypeId=recordTypeMap.get(qiDetail.RecordType.Name);
                }
                qidVersions.add(qidVersion);
        }
        }

        if(!qidVersions.isEmpty()){
            try {
                Database.insert(qidVersions, false);
            }
            catch(Exception ex) {
                dohagedcare.Logger.error(ex.getMessage(), ex, 'QIVersionsController.cls').log();
            }
        }
    }

     /***
     * @description create QIT  verions
     * @params mapQisVersionIdQid
    **/
    public static void createQITargetVersion(Map<id, Quality_Indicator_Targets__c> mapQisVersionIdQit){
        List<Quality_Indicator_Target_Version__c> qitVersions= new List<Quality_Indicator_Target_Version__c>();
        Schema.SObjectType Sqit = new Quality_Indicator_Targets__c().getSObjectType();
        Schema.SObjectType SqitVersions = new Quality_Indicator_Target_Version__c().getSObjectType();
        Map<String, Schema.SObjectField> SqitFields = Sqit.getDescribe().fields.getMap();
        Map<String, Schema.SObjectField> SqitVersionsFields = SqitVersions.getDescribe().fields.getMap();
        for(String qisvid: mapQisVersionIdQit.keyset()){
                Quality_Indicator_Target_Version__c qitVersion=new Quality_Indicator_Target_Version__c();
                    for(String fieldName: SqitFields.keySet()){
                        if(SqitVersionsFields.containsKey(fieldName)){
                            if(SqitVersionsFields.get(fieldName).getDescribe().isUpdateable()){
                                if(mapQisVersionIdQit.get(qisvid)!=null){
                                    qitVersion.put(fieldName, mapQisVersionIdQit.get(qisvid).get(fieldName));
                                }
                            }
                        }
                    }
                    qitVersion.Quality_Indicator_Summary_Version__c=qisvid;
                    qitVersion.QITVName__c=mapQisVersionIdQit.get(qisvid).Name;
                    qitVersions.add(qitVersion);
        }

        if(!qitVersions.isEmpty()){
            try {
                Database.insert(qitVersions, false);
            }
            catch(Exception ex) {
                dohagedcare.Logger.error(ex.getMessage(), ex, 'QIVersionsController.cls').log();
            }
        }
    }
}
