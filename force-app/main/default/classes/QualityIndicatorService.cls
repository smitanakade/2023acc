/**
* author: Sharevreet Singh
* date: 14/10/2022
* description: Service class for calculating QI scores
**/
public with sharing class QualityIndicatorService {
    @TestVisible private static final String STATUS_NS = 'Not Started';
    private static final String STATUS_IP = 'In Progress';
    public static final String STATUS_NSUB = 'Not Submitted';

    public static void qualityIndicatorRatings(Map<Id, Quality_Indicator_Summary__c> qiMap, National_Statistic__c natStatRecord, Reporting_Period__c reportPeriod, Boolean lateUpdate) {
        List<Quality_Indicator_Summary__c> updateQI = new List<Quality_Indicator_Summary__c>();

        for(Quality_Indicator_Summary__c qiRecord : qiMap.values()) {
            RiskAdjustedCalculator racObj = new RiskAdjustedCalculator(qiRecord, natStatRecord);
            updateQI.add(racObj.calculateRiskAdjusted());
            qiRecord.National_Statistic__c = natStatRecord.Id;
            qiRecord = checkQiStatusAndRating(qiRecord);
        }
        
        if(updateQI.size() > 0) {
            try {
                update updateQI;
            } catch(Exception ex) {
                dohagedcare.Logger.error(ex.getMessage(), ex, 'QualityIndicatorService - update QI').log();
            }
        }

        if(!System.isQueueable()) {
            try {
                System.enqueueJob(new QuintileScoreCalculator(qiMap.keySet(), natStatRecord, reportPeriod, lateUpdate));
            } catch(Exception ex) {
                dohagedcare.Logger.error(ex.getMessage(), ex, 'QualityIndicatorService - enqueue QuintileScoreCalculator').log();
            }
        }
    }


    /**
     * @description - setting status an rating based on current status
     */
    public static Quality_Indicator_Summary__c checkQiStatusAndRating(Quality_Indicator_Summary__c qiRecord) {
        if(qiRecord.Status__c == STATUS_NS || qiRecord.Status__c == STATUS_IP) {
            qiRecord.Status__c = STATUS_NSUB;
            qiRecord.Quality_Indicator_Rating__c = 1;
        }
        return qiRecord;
    }
}