/****************************************************************************************************
* @CreatedBy   : Yohan Perera
* @CreatedDate : 1-11-2022
* @Description : Service class for CareMinuteSummaryTrigger
* @Test Class  : 
*****************************************************************************************************/
public with sharing class CareMinuteSummaryTriggerService {
    
    public static void shareCareMinuteSummaryRecords(Map<Id, Care_Minutes_Summary__c> newMap) {
        Map<Id, String> cmsToGroupMap = new Map<Id, String>();
        Map<String, Group> groupNameToGroupMap = new Map<String, Group>();
        List<Care_Minutes_Summary__share> sharesList = new List<Care_Minutes_Summary__share>();
        
        for (Id cmsId : newMap.keySet()) {
            cmsToGroupMap.put(cmsId, 'SRV_' + newMap.get(cmsId).Service__c);
        }
        
        for (Group g : [SELECT Id, DeveloperName FROM Group WHERE DeveloperName IN :cmsToGroupMap.values()]) {
            groupNameToGroupMap.put(g.DeveloperName, g);
        }
        
        for (Id cmsId : cmsToGroupMap.keySet()) {
            //Checks if a real group exists for the Care Minute Summary Name
            if (groupNameToGroupMap.containsKey(cmsToGroupMap.get(cmsId))) {
                Group newGroup = groupNameToGroupMap.get(cmsToGroupMap.get(cmsId));
                
                Care_Minutes_Summary__share cmsShare = new Care_Minutes_Summary__share();
                cmsShare.ParentId = cmsId;
                cmsShare.UserOrGroupId = newGroup.Id;
                cmsShare.RowCause = Schema.Care_Minutes_Summary__share.RowCause.Provider__c;
                cmsShare.AccessLevel = 'Read';
                sharesList.add(cmsShare);
            }
        }
        
        if (!sharesList.isEmpty()) insert sharesList;
    }

}