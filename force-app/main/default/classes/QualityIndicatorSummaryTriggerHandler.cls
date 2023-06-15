/**
 * @description       :
 * @author            : Sharevreet Singh
 * @group             :
 * @last modified on  : 05-04-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * @testClass QualityIndicatorSummaryTrigHandlerTest
**/
public with sharing class QualityIndicatorSummaryTriggerHandler implements beforeUpdate, beforeInsert, afterInsert, afterUpdate {
    // Quality_Indicator_Summary__c
    public static final String DRAFT_STATUS = 'Draft';
    public static final String PUBLISHED_STATUS = 'Published';
    public static final String LIVE_STATUS = 'Live';
    public static final Set<String> ratingStatuses = new Set<String>{'Updated After Due Date', 'Late Submission'};
    public static Boolean flagUpdateQI = true;
    final static Set<String> SUBMIT_STATUS_LIST = new Set<String>{'Submitted', 'Late Submission', 'Updated After Due Date'};
    public static final String PCS_USER = 'PowerCustomerSuccess';

    public void beforeUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {
        // store service Ids
        Map<Id, Id> liveQIRecords = new Map<Id, Id>();

        for(Quality_Indicator_Summary__c qi : (List<Quality_Indicator_Summary__c>) newMap.values()) {

            Quality_Indicator_Summary__c qiOld = (Quality_Indicator_Summary__c) oldMap.get(qi.Id);

            if(qi.Availability_Status__c == PUBLISHED_STATUS && qiOld.Availability_Status__c != PUBLISHED_STATUS) {
                qi.Rating_Type__c = 'New Rating';
                qi.Publication_Date__c = Datetime.now();
            }
            if(qi.Submission_Date_Time__c!=qiOld.Submission_Date_Time__c && (qi.Status__c=='Submitted' || qi.Status__c=='Late Submission' || qi.Status__c=='Updated After Due Date')){
                qi.Submitted_By__c=UserInfo.getUserId();
            }
            if(qi.Availability_Status__c == LIVE_STATUS && qiOld.Availability_Status__c != LIVE_STATUS) {
                qi.Rating_Type__c = 'Current Rating';
                liveQIRecords.put(qi.Id, qi.Service__c);
            }
        }
        if(!liveQIRecords.isEmpty()) {
            RatingsStatusHelper.UpdateQIRatingType(liveQIRecords);
        }
    }

    public void afterUpdate(Map<Id, SObject> newMap, Map<Id,SObject> oldMap) {
        Set<Id> qisIdsForRating = new Set<Id>();
        List<Quality_Indicator_Summary__c> qisManageVersions=new List<Quality_Indicator_Summary__c>();
        List<Quality_Indicator_Summary__c> sendEmailList = new List<Quality_Indicator_Summary__c>();
        Map<Id, Reporting_Period__c> rPeriods = new Map<Id, Reporting_Period__c>([SELECT Id, QI_Calc_Date__c, QI_Calculated__c, Reporting_Period_Short__c FROM Reporting_Period__c WHERE Previous_Reporting_Period__c = true]);

        for(Quality_Indicator_Summary__c qi : (List<Quality_Indicator_Summary__c>) newMap.values()) {
            Reporting_Period__c rPeriod = rPeriods.get(qi.Reporting_Period__c);
            Quality_Indicator_Summary__c oldQI = (Quality_Indicator_Summary__c) oldMap.get(qi.Id);
            if(ratingStatuses.contains(qi.Status__c) && flagUpdateQI &&
               rPeriods.keySet().contains(qi.Reporting_Period__c) && rPeriod.QI_Calc_Date__c <= System.today() && rPeriod.QI_Calculated__c == true) {
                qisIdsForRating.add(qi.Id);
            }
            if(qi.Submission_Date_Time__c!=oldQI.Submission_Date_Time__c && SUBMIT_STATUS_LIST.contains(qi.Status__c)){
                if(UserInfo.getUserType() == PCS_USER && !SUBMIT_STATUS_LIST.contains(oldQI.Status__c)) { //for portal user
                    qisManageVersions.add(qi);
                }
                else if(UserInfo.getUserType() != PCS_USER) {//for non portal user
                    qisManageVersions.add(qi);
                }

                //check to prevent notifications in case of bulk upload
                if(oldQI.Originating_File_Upload__c == qi.Originating_File_Upload__c){
                    sendEmailList.add(qi);
                }
            }
        }

        updateQiSummaryAndQiRatings(qisIdsForRating);
        if(!qisManageVersions.isEmpty()){
            QIVersionsController.createQIVersions(qisManageVersions);
            if(sendEmailList.size()>0){
                SendEmailNotificationService notificationService = new SendEmailNotificationService();
                notificationService.sendEmailForQISubmission(sendEmailList);
            }
        }
    }

    public void beforeInsert(List<Quality_Indicator_Summary__c> qualityIndicatorSummaries) {
        // 393628 add external Id in trigger
        Map<Id, Account> providerQISMap = new Map<Id, Account>();
        Map<Id, BusinessLicense> serviceQISMap = new Map<Id, BusinessLicense>();

        for (Quality_Indicator_Summary__c qi : qualityIndicatorSummaries) {
            if (SUBMIT_STATUS_LIST.contains(qi.Status__c)) {
                qi.Submitted_By__c = UserInfo.getUserId();
            }
            providerQISMap.put(qi.PROVIDER_ID__c, null);
            serviceQISMap.put(qi.Service__c, null);
        }

        providerQISMap.putAll([SELECT Id, Integration_ID__c FROM Account WHERE Id IN :providerQISMap.keySet()]);
        serviceQISMap.putAll([SELECT Id, Integration_ID__c FROM BusinessLicense WHERE Id IN :serviceQISMap.keySet()]);
        for (Quality_Indicator_Summary__c qisRecord : qualityIndicatorSummaries) {
            String providerId = providerQISMap.get(qisRecord.PROVIDER_ID__c).Integration_ID__c;
            providerId = providerId.removeStart('PRV-');
            String serviceId = serviceQISMap.get(qisRecord.Service__c).Integration_ID__c;
            serviceId = serviceId.removeStart('SRV-');
            qisRecord.External_ID__c = providerId + '-' + serviceId + '-' + qisRecord.REPORTING_PERIOD__c;
        }
    }

    public void afterInsert(Map<Id, SObject> newMap) {
        Set<Id> qisIdsForRating = new Set<Id>();
        List<Quality_Indicator_Summary__c> qisManageVersions=new List<Quality_Indicator_Summary__c>();
        Map<Id, Reporting_Period__c> rPeriods = new Map<Id, Reporting_Period__c>([SELECT Id, QI_Calc_Date__c, QI_Calculated__c, Reporting_Period_Short__c FROM Reporting_Period__c WHERE Previous_Reporting_Period__c = true]);

        List<Quality_Indicator_Summary__c> sendEmailList = new List<Quality_Indicator_Summary__c>();
        for(Quality_Indicator_Summary__c qi : (List<Quality_Indicator_Summary__c>) newMap.values()) {
            Reporting_Period__c rPeriod = rPeriods.get(qi.Reporting_Period__c);
            if(ratingStatuses.contains(qi.Status__c) && flagUpdateQI &&
                rPeriods.keySet().contains(qi.Reporting_Period__c) &&
               rPeriod.QI_Calc_Date__c <= System.today() && rPeriod.QI_Calculated__c == true) {
                qisIdsForRating.add(qi.Id);
            }
            if(SUBMIT_STATUS_LIST.contains(qi.Status__c)){
                qisManageVersions.add(qi);
                //check to prevent notifications in case of bulk upload
                if(String.isBlank(qi.Originating_File_Upload__c)) {
                    sendEmailList.add(qi);
                }
            }
        }

        updateQiSummaryAndQiRatings(qisIdsForRating);
        QualityIndicatorSummaryTriggerService.shareQualityIndicatorSummaryRecords((Map<Id, Quality_Indicator_Summary__c>) newMap);
        if(!qisManageVersions.isEmpty()){
            QIVersionsController.createQIVersions(qisManageVersions);
            if(sendEmailList.size()>0){
                SendEmailNotificationService notificationService = new SendEmailNotificationService();
                notificationService.sendEmailForQISubmission(sendEmailList);
            }
        }
    }

    private static void updateQiSummaryAndQiRatings(Set<Id> qisIdsForRating) {
        if(!qisIdsForRating.isEmpty() && flagUpdateQI) {
            flagUpdateQI = false;
            final String FILTER = 'AND Id IN :qisIdsForRating';
            List<Quality_Indicator_Summary__c> qisListForRating = Database.query(QIObservedBatch.getQuery() + FILTER);

            for(Quality_Indicator_Summary__c qis : qisListForRating) {
                qis.QIUpdatedbySiebel__c = false;
                qis.IPRequired__c = true;
            }

            if(!qisListForRating.isEmpty()) {
                try{
                    Map<Id, Quality_Indicator_Summary__c> qiMap = QIObservedHelper.updateQiSummaryAndQiRatings(qisListForRating);
                    update qiMap.values();
                    QIObservedHelper.updateNationalStatsData(qiMap, true);

                } catch(Exception ex) {
                    dohagedcare.Logger.error(ex.getMessage(), ex, 'QualityIndicatorSummaryTriggerHandler').log();
                }
            }
        }
    }
}