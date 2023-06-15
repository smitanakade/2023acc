/****************************************************************************************************
 * @CreatedBy   : Jamil Khaki
 * @CreatedDate : 09/03/2023
 * @Description : trigger handler for Quality_Indicator_Targets__c
 * @Test Class  : QualityIndicatorTargetsTrigHandlerTest
 *****************************************************************************************************/

public with sharing class QualityIndicatorTargetsTriggerHandler implements beforeUpdate, beforeInsert {
    public final static String DM_PROFILE = 'Data Migration';

    public void beforeUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {
        List<Quality_Indicator_Targets__c> qitList = (List<Quality_Indicator_Targets__c>) newMap.values();

        //call validation util Field Validation method
        QualityIndicatorValidationUtil.qitFieldValidation(qitList);
    }

    public void beforeInsert(List<SObject> newList) {
        List<Quality_Indicator_Targets__c> qitList = (List<Quality_Indicator_Targets__c>) newList;
        System.debug(qitList);

        //call validation util Field Validation method
        QualityIndicatorValidationUtil.qitFieldValidation(qitList);

        //call Helper class - copy QIT record method for Non Data Migration User
        if(DM_PROFILE != [SELECT Name FROM Profile 
                        WHERE Id = :userinfo.getProfileId() 
                        LIMIT 1].Name ) {
            QualityIndicatorTargetsHelper.copyRecord(qitList);
        }

        // 393628 add external Id in trigger assumption: the related Quality Indicator Summary should have external Id already
        Map<Id, Quality_Indicator_Summary__c> qisQITMap = new Map<Id, Quality_Indicator_Summary__c>();
        for (Quality_Indicator_Targets__c qitRecord : qitList) {
            qisQITMap.put(qitRecord.Quality_Indicator_Summary__c, null);
        }
        qisQITMap.putAll([SELECT Id, External_ID__c FROM Quality_Indicator_Summary__c WHERE Id IN :qisQITMap.keySet()]);
        for (Quality_Indicator_Targets__c qitRecord : qitList) {
            qitRecord.External_ID__c = qisQITMap.get(qitRecord.Quality_Indicator_Summary__c).External_ID__c;
        }
    }
}