/****************************************************************************************************
 * @CreatedBy   : Daniel Clift
 * @CreatedDate : 01/02/2023
 * @Description : trigger handler for Quality_Indicator_Details__c
 * @Test Class  : QualityIndicatorDetailsTrigHandlerTest
 * @modified by: Yifei Pei on 01/03/2023 add funtion to update Completion_Date__c when the status equals to 'Completed'
 * @modified by: Jamil Khaki on 14/03/2023 Update calling renamed ValidationUtil method qidFieldValidation
 *****************************************************************************************************/

public with sharing class QualityIndicatorDetailsTriggerHandler implements beforeUpdate, beforeInsert {
    private static final Map<String, String> DOMAIN_PREFIX = new Map<String, String>{
        'Activities_of_daily_living_ADLs' => 'ADL',
        'Consumer_Experience' => 'CEI',
        'Falls_and_Major_Injury' => 'FMI',
        'Hospitalisation' => 'HP',
        'Continence' => 'IAD',
        'Medication_Management' => 'MM',
        'Physical_Restraint' => 'PR',
        'Pressure_Injuries' => 'PI',
        'Quality_of_life' => 'QOL',
        'Unplanned_Weight_Loss' => 'UPWL',
        'Workforce' => 'WF'
    };

    public void beforeUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {
        List<Quality_Indicator_Details__c> qidList = (List<Quality_Indicator_Details__c>) newMap.values();
        Map<Id, Quality_Indicator_Details__c> oldQIMap = (Map<Id, Quality_Indicator_Details__c>) oldMap;

        QualityIndicatorValidationUtil.qidFieldValidation(qidList);
        QualityIndicatorValidationUtil.fieldUpdate(qidList, oldQIMap);
    }

    public void beforeInsert(List<SObject> newList) {
        List<Quality_Indicator_Details__c> qidList = (List<Quality_Indicator_Details__c>) newList;

        QualityIndicatorValidationUtil.qidFieldValidation(qidList);
        QualityIndicatorValidationUtil.fieldUpdate(qidList, null);

        // 393628 add external Id in trigger assumption: the related Quality Indicator Summary should have external Id already
        Map<Id, String> qidPrefixMap = new Map<Id, String>();
        List<Schema.RecordTypeInfo> rtInfo = Quality_Indicator_Details__c.SObjectType.getDescribe().getRecordTypeInfos();
        for (Schema.RecordTypeInfo rtRecord : rtInfo) {
            qidPrefixMap.put(rtRecord.getRecordTypeId(), DOMAIN_PREFIX.get(rtRecord.getDeveloperName()));
        }
        Map<Id, Quality_Indicator_Summary__c> qisQIDMap = new Map<Id, Quality_Indicator_Summary__c>();
        for (Quality_Indicator_Details__c qidRecord : qidList) {
            qisQIDMap.put(qidRecord.QI_Summary_Id__c, null);
        }
        qisQIDMap.putAll([SELECT Id, External_ID__c FROM Quality_Indicator_Summary__c WHERE Id IN :qisQIDMap.keySet()]);
        for (Quality_Indicator_Details__c qidRecord : qidList) {
            qidRecord.quality_indicator_ext_id__c =
                qidPrefixMap.get(qidRecord.RecordTypeId) +
                '-' +
                qisQIDMap.get(qidRecord.QI_Summary_Id__c).External_ID__c;
        }
    }
}