/**
* author: Daniel Clift
* date: 06/09/2022
* description: handles change in Star Rating History
**/
public with sharing class StarRatingTriggerService {

    public static final String DRAFT_STATUS = 'Draft';
    public static final String PUBLISHED_STATUS = 'Published';
    public static final String LIVE_STATUS = 'Live';

    public static void shareStartRatingHistoryRecords(Map<Id, STAR_Rating_History__c> newMap) {
        Map<Id, String> starRatingToGroupMap = new Map<Id, String>();
        Map<String, Group> groupNameToGroupMap = new Map<String, Group>();
        List<STAR_Rating_History__share> sharesList = new List<STAR_Rating_History__share>();

        for (Id starRatingId : newMap.keySet()) {
            starRatingToGroupMap.put(starRatingId, 'SRV_' + newMap.get(starRatingId).SF_Service_Id__c);
        }

        for (Group g : [SELECT Id, DeveloperName FROM Group WHERE DeveloperName IN :starRatingToGroupMap.values()]) {
            groupNameToGroupMap.put(g.DeveloperName, g);
        }

        for (Id starRatingId : starRatingToGroupMap.keySet()) {
            //Checks if a real group exists for the Star Rating Service Name
            if (groupNameToGroupMap.containsKey(starRatingToGroupMap.get(starRatingId))) {
                Group newGroup = groupNameToGroupMap.get(starRatingToGroupMap.get(starRatingId));

                STAR_Rating_History__share srShare = new STAR_Rating_History__share();
                srShare.ParentId = starRatingId;
                srShare.UserOrGroupId = newGroup.Id;
                srShare.RowCause = Schema.STAR_Rating_History__share.RowCause.Provider__c;
                srShare.AccessLevel = 'Read';
                sharesList.add(srShare);
            }
        }
        
        try {
            if (!sharesList.isEmpty()) insert sharesList;
        } catch(Exception exp) {
            dohagedcare.Logger.error(exp.getMessage(),exp,'StarRatingTriggerService - insert sharesList').Log(); 
        }
        
    }
}