/********************************************************************
 * @CreatedBy   : Jamil Khaki
 * @CreatedDate : 10/03/2023
 * @Description : Helper class for QIT - copy QIT data to new record
 * @Test Class  : QualityIndicatorTargetsTrigHandlerTest
 *********************************************************************/

 public with sharing class QualityIndicatorTargetsHelper {

    //Dynamic FIELD MAP for QIT - retrieve schema map
    private static final Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Quality_Indicator_Targets__c.fields.getMap();

    /*Method - copy qualifying QIT record data to new records
    logic -
    i. get the start date of the reporting period of the new QIT being inserted.
    ii. read the end date of the old reporting period of the existing QIT we query and plant to fetch data from.
            we only get data (if available) from previous QIT which has the reporting period end date:
            reporting period end date In (new QIT reporting period start date - 1)
    iii. copy data if
    reporting period end date = new QIT reporting period start date - 1
    */
    public static void copyRecord(List<Quality_Indicator_Targets__c> qitNewList) {

        //Init and define vars
        Map<String, List<Quality_Indicator_Targets__c>> qitExistingServiceMap = new Map<String, List<Quality_Indicator_Targets__c>>();
        List<Id> qitServiceIds = new List<Id>();        
        Set<Id> rpIdsOfInsertedQIs = new Set<Id>();
        Map<Id, Id> rpIdByQitId = new Map<Id, Id>();
        Map<Id, Date> startDateMinusOneByRpId = new Map<Id, Date>();
        List<Quality_Indicator_Targets__c> qitExistingList = new List<Quality_Indicator_Targets__c>();
        //Extract list of custom fields for query and data copy
        List<String> requiredFields = new List<String>();

        for (String fieldName : fieldMap.keySet()){
            Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();
            if(fieldDescribe.isCustom()){
                requiredFields.add(fieldName);
            }           
        }
       
        //Extract list of Service Ids in Trigger
        for (Quality_Indicator_Targets__c qit : qitNewList) {
            rpIdByQitId.put(qit.Id, qit.Reporting_Period__c);
            rpIdsOfInsertedQIs.add(qit.Reporting_Period__c);
            qitServiceIds.add(qit.Service__c);
        }

        /***create a map for rpId => rp.startDate-1; a day is subtracted to find previous reporting period by matching its end date to startDate-1 */
        for(Reporting_Period__c rp : [SELECT Id, Start_Date__c FROM Reporting_Period__c WHERE Id IN :rpIdsOfInsertedQIs]) {
            startDateMinusOneByRpId.put(rp.Id, rp.Start_Date__c.addDays(-1));
        }


        //SvcProv Map - Query Service-Account Relationship
        Map<String, String> svcProvMap = new Map<String, String>();                                                                        
        List<Service_Account_Relationship__c> serviceAccountList = [SELECT Id, Service_Name__c, Provider_Name__c 
                                                                        FROM Service_Account_Relationship__c 
                                                                        WHERE Service_Name__c IN :qitServiceIds
                                                                        AND (Association_End_Date__c = null OR Association_End_Date__c >= Today)];

        //iterate svcAccList and extract to SvcId:Account Map
        for (Service_Account_Relationship__c serviceAccount : serviceAccountList){
            svcProvMap.put(serviceAccount.Service_Name__c, serviceAccount.Provider_Name__c);
        }

        List<Date> startDateMinusOneList = startDateMinusOneByRpId.values();
        //Generate Service-QIT Map of existing QIT records
        String qitSoqlQuery = 'SELECT Id, Service__r.AccountId, Reporting_Period__r.End_Date__c, ' + String.join(requiredFields, ', ') +
                                ' FROM Quality_Indicator_Targets__c' + 
                                ' WHERE Service__c IN (\''+ String.join(qitServiceIds, '\',\'') +'\')' + 
                                ' AND CreatedDate > last_N_MONTHS:12' +
                                ' AND Reporting_Period__r.End_Date__c IN :startDateMinusOneList' +
                                ' ORDER BY CreatedDate DESC';                                

        try {
            qitExistingList = Database.query(qitSoqlQuery);
        }
        catch(QueryException ex) {
            dohagedcare.Logger.error(ex.getMessage(), ex, 'QualityIndicatorTargetsHelper').log();
            return;
        }

        for(Quality_Indicator_Targets__c qit : qitExistingList) {
            if(!qitExistingServiceMap.containsKey(qit.Service__c)) {
                qitExistingServiceMap.put(qit.Service__c,  new List<Quality_Indicator_Targets__c> {qit}); 
            }
            else {
                List<Quality_Indicator_Targets__c> qits = qitExistingServiceMap.get(qit.Service__c);
                qits.add(qit);
                qitExistingServiceMap.put(qit.Service__c, qits); 
            }
        }

        //Copy to new records; validate existing QIT and active SA relationship
        for(Quality_Indicator_Targets__c qit : qitNewList) {
            if(qitExistingServiceMap.containsKey(qit.Service__c) && svcProvMap.containsKey(qit.Service__c)){

                for(Quality_Indicator_Targets__c existingQit : qitExistingServiceMap.get(qit.Service__c)) {
                    //compare new QIT startDate -1 with ExistingQIT endDate
                    if(startDateMinusOneByRpId.get(rpIdByQitId.get(qit.Id)) == existingQit.Reporting_Period__r.End_Date__c) {
                        //loop fields and copy required custom fields
                        for (String targetField : requiredFields ){
                            //exclude non-data input fields eg lookups and identifier fields
                            if(!((new List<String>{'service__c','quality_indicator_summary__c','reporting_period__c','external_id__c'}).contains(targetField))){
                                if(existingQit.get(targetField) != null && qit.get(targetField) == null) {
                                    qit.put(targetField, existingQit.get(targetField));
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}