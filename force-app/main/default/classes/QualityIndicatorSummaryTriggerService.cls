/****************************************************************************************************
* @CreatedBy   : Yohan Perera
* @CreatedDate : 1-11-2022
* @Description : 
* @testClass QualityIndicatorSummaryTrigHandlerTest,SRHCaclPrepBatchTest
*****************************************************************************************************/
public with sharing class QualityIndicatorSummaryTriggerService {
    
    public static void shareQualityIndicatorSummaryRecords(Map<Id, Quality_Indicator_Summary__c> newMap) {
        QISShareObjectRecord qisShare=new QISShareObjectRecord();
        qisShare.shareQISRecords(newMap);
    }
    //shared record can only be created with users have modify all data permissions
    // because of that need to run this in without sharing context
    private without sharing class QISShareObjectRecord{

        /**
        * @description : Share QIS share record
        * @author Vivek | 05-17-2023 
        * @param newMap 
        **/
        public void shareQISRecords(Map<Id, Quality_Indicator_Summary__c> newMap) {
            Map<Id, String> qisToGroupMap = new Map<Id, String>();
            Map<String, Group> groupNameToGroupMap = new Map<String, Group>();
            List<Quality_Indicator_Summary__share> sharesList = new List<Quality_Indicator_Summary__share>();
            
            for (Id qisId : newMap.keySet()) {
                qisToGroupMap.put(qisId, 'SRV_' + newMap.get(qisId).Service__c);
            }
            
            for (Group g : [SELECT Id, DeveloperName FROM Group WHERE DeveloperName IN :qisToGroupMap.values()]) {
                groupNameToGroupMap.put(g.DeveloperName, g);
            }
            
            for (Id qisId : qisToGroupMap.keySet()) {
                //Checks if a real group exists for the QIS Name
                if (groupNameToGroupMap.containsKey(qisToGroupMap.get(qisId))) {
                    Group newGroup = groupNameToGroupMap.get(qisToGroupMap.get(qisId));
                    
                    Quality_Indicator_Summary__share qisShare = new Quality_Indicator_Summary__share();
                    qisShare.ParentId = qisId;
                    qisShare.UserOrGroupId = newGroup.Id;
                    qisShare.RowCause = Schema.Quality_Indicator_Summary__share.RowCause.Provider__c;
                    qisShare.AccessLevel = 'Edit';
                    sharesList.add(qisShare);
                }
            }
            
            if (!sharesList.isEmpty()) insert sharesList;
        }
    }
}