/**
 * @author Tommy Du
 * @date 17-09-2022
 * @description Apex controller to provide star rating records to lwc components on provider portal
 * @testClass srqiStarRatingHistoryRetrievalTest
 */
public with sharing class srqiStarRatingHistoryRetrieval {
    @TestVisible
    private static Boolean fakeException = false;
    @AuraEnabled
    public static List<STAR_Rating_History__c> getSRHListBySFServiceId(
        Id sfServiceId
    ) {
        List<STAR_Rating_History__c> srhList;
        List<STAR_Rating_History__c> filteredSrhList = new List<STAR_Rating_History__c>();
        try {
            srhList = starRatingHistorySelector()
                .getSRHListBySFServiceIds(new Set<Id>{sfServiceId});
            Map<Id, Service_Account_Relationship__c> activeSarsForCurrentUser = new Map<Id, Service_Account_Relationship__c>(SRProviderPortalUtil.getServiceAccountRelationships());
            for (STAR_Rating_History__c srh : srhList) {
                if (activeSarsForCurrentUser.containsKey(srh.Service_Account_Relationship__c)) {
                    filteredSrhList.add(srh);
                }
            }
        } catch (Exception ex) {
            dohagedcare.Logger.error(ex.getMessage(), ex, 'QISR').log();
            throw new AuraHandledException(
                'Error in fetching Star Ratings! Please try again or contact system administrator.'
            );
        }

        return filteredSrhList;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<RegulatoryCodeViolation> getRDListBySFServiceAccountId(
        Id sfServiceAccountId
    ) {
        List<RegulatoryCodeViolation> rdList;
        try {
            rdList = regulatoryCodeViolationSelector()
                .getRDListBySFServiceIds(sfServiceAccountId);

            if (test.isRunningTest() && fakeException) {
                throw new QueryException();
            }
        } catch (Exception ex) {
            dohagedcare.Logger.error(ex.getMessage(), ex, 'QISR').log();
            throw new AuraHandledException(
                'Error in fetching regulatory decisions! Please try again or contact system administrator.'
            );
        }
        return rdList;
    }

    private static StarRatingHistorySelector starRatingHistorySelector() {
        return StarRatingHistorySelector.singletonInstance;
    }

    private static RegulatoryCodeViolationSelector regulatoryCodeViolationSelector() {
        return RegulatoryCodeViolationSelector.singletonInstance;
    }
}