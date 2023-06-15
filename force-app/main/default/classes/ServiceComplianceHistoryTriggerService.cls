/****************************************************************************************************
* @CreatedBy   : Yohan Perera
* @CreatedDate : 1-11-2022
* @Description : 
* @Test Class  : 
*****************************************************************************************************/
public with sharing class ServiceComplianceHistoryTriggerService {
    
    public static void shareServiceComplianceHistoryRecords(Map<Id, Service_Compliance_History__c> newMap) {
        Map<Id, String> schToGroupMap = new Map<Id, String>();
        Map<String, Group> groupNameToGroupMap = new Map<String, Group>();
        List<Service_Compliance_History__share> sharesList = new List<Service_Compliance_History__share>();
        
        for (Id schId : newMap.keySet()) {
            schToGroupMap.put(schId, 'SRV_' + newMap.get(schId).Service__c);
        }
        
        for (Group g : [SELECT Id, DeveloperName FROM Group WHERE DeveloperName IN :schToGroupMap.values()]) {
            groupNameToGroupMap.put(g.DeveloperName, g);
        }
        
        for (Id schId : schToGroupMap.keySet()) {
            //Checks if a real group exists for the SCH Name
            if (groupNameToGroupMap.containsKey(schToGroupMap.get(schId))) {
                Group newGroup = groupNameToGroupMap.get(schToGroupMap.get(schId));
                
                Service_Compliance_History__share schShare = new Service_Compliance_History__share();
                schShare.ParentId = schId;
                schShare.UserOrGroupId = newGroup.Id;
                schShare.RowCause = Schema.Service_Compliance_History__share.RowCause.Provider__c;
                schShare.AccessLevel = 'Read';
                sharesList.add(schShare);
            }
        }
        
        if (!sharesList.isEmpty()) insert sharesList;
    }

}