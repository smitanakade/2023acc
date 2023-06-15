/****************************************************************************************************
* @CreatedBy   : Yohan Perera
* @CreatedDate : 1-11-2022
* @Description : Service class for ConsumerExperienceReportTrigger
* @Test Class  : 
*****************************************************************************************************/
public with sharing class ConsumerExperienceReportTriggerService {

    public static void shareConsumerExperienceReportRecords(Map<Id, SRQI_CER__c> newMap) {
        Map<Id, String> cerToGroupMap = new Map<Id, String>();
        Map<String, Group> groupNameToGroupMap = new Map<String, Group>();
        List<SRQI_CER__share> sharesList = new List<SRQI_CER__share>();
        
        for (Id cerId : newMap.keySet()) {
            cerToGroupMap.put(cerId, 'SRV_' + newMap.get(cerId).Service__c);
        }
        
        for (Group g : [SELECT Id, DeveloperName FROM Group WHERE DeveloperName IN :cerToGroupMap.values()]) {
            groupNameToGroupMap.put(g.DeveloperName, g);
        }
        
        for (Id cerId : cerToGroupMap.keySet()) {
            //Checks if a real group exists for the CER Name
            if (groupNameToGroupMap.containsKey(cerToGroupMap.get(cerId))) {
                Group newGroup = groupNameToGroupMap.get(cerToGroupMap.get(cerId));
                
                SRQI_CER__share cerShare = new SRQI_CER__share();
                cerShare.ParentId = cerId;
                cerShare.UserOrGroupId = newGroup.Id;
                cerShare.RowCause = Schema.SRQI_CER__share.RowCause.Provider__c;
                cerShare.AccessLevel = 'Read';
                sharesList.add(cerShare);
            }
        }
        
        if (!sharesList.isEmpty()) insert sharesList;
    }
}