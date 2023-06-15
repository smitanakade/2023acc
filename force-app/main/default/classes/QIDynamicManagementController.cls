/****************************************************************************************************
 * @CreatedBy   : Yifei Pei
 * @CreatedDate : 23-02-2023
 * @Description : Controller Class for LWC qiDynamicManagement
 *                LWC is put on Service record Accordion side panel
 * @Test Class  : QIDynamicManagementControllerTest
 *****************************************************************************************************/

public with sharing class QIDynamicManagementController {
    private final static String STATUS_IP = 'In Progress';
    /**
     * Method getCurrentQISList to query on existing Quality Indicator Summary
     * If there is, return to the record page of the newest created record
     * If there isn't, the button on LWC will create a new record
     * @parameter serviceId is the recordId retrieved from service record
     */
    @AuraEnabled(cacheable=true)
    public static String getCurrentQISList(String serviceId) {
        QISResponse response = new QISResponse();
        try {
            List<Quality_Indicator_Summary__c> qisList = getQISList(serviceId);
            if (qisList?.size() > 0) {
                response.isEmpty = false;
                response.Id = qisList[0].Id;
            } else {
                response.isEmpty = true;
            }
        } catch (Exception e) {
            dohagedcare.Logger.error(e.getMessage(), e, 'QIDynamicManagementController.getCurrentQISList failed').Log();
            throw new AuraHandledException(e.getMessage());
        }
        return JSON.serialize(response);
    }
    /**
     * Method createNewQI to create new Quality Indicator Summary
     * with 11 QID records (one record for each record type)
     * after creation, the LWC will return the newly created QIS record page
     * @parameter serviceId is the recordId retrieved from service record
     */
    @AuraEnabled
    public static String createNewQI(String serviceId) {
        QISResponse response = new QISResponse();
        try {
            Quality_Indicator_Summary__c newQIS = new Quality_Indicator_Summary__c();
            List<Service_Account_Relationship__c> relatedSAR = getServAcctRelp(serviceId);
            List<Reporting_Period__c> currentRP = getCurrentRP();

            //Validations
            String errorMessage = '';
            if (!(relatedSAR?.size() > 0)) {
                errorMessage += 'No related Service Account Relationship to be added into Quality Indicator Summary.' + '\r\n';
            } else {
                if (relatedSAR[0].Provider_Name__r.Oracle_ID__c == null) {
                    errorMessage += 'Account does not have external ID.' + '\r\n';
                }
                if (String.isBlank(relatedSAR[0].Service_Name__r.Oracle_Service_ID__c)) {
                    errorMessage += 'Service does not have external ID.' + '\r\n';
                }
            }
            if (!(currentRP?.size() > 0)) {
                errorMessage += 'No related Reporting Period to be added into Quality Indicator Summary.' + '\r\n';
            }
            if (!String.isBlank(errorMessage)) {
                throw qiMessageException(errorMessage);
            }

            // if the lists contain more than one records, we still only pick up the first one
            newQIS.Service__c = relatedSAR[0].Service_Name__c;
            newQIS.SERVICE_ACCOUNT_ID__c = relatedSAR[0].Id;
            newQIS.PROVIDER_ID__c = relatedSAR[0].Provider_Name__c;
            newQIS.REPORTING_PERIOD__c = currentRP[0].Id;
            newQIS.External_ID__c =
                String.valueOf(relatedSAR[0].Provider_Name__r.Oracle_ID__c) +
                '-' +
                String.valueOf(relatedSAR[0].Service_Name__r.Oracle_Service_ID__c) +
                '-' +
                String.valueOf(currentRP[0].Id);
            // Here the status fields value is hard coded
            // can creat helper class to handle it without hard code if required
            newQIS.Availability_Status__c = 'Draft';
            newQIS.Status__c = STATUS_IP;
            newQIS.Rating_Type__c = 'Draft Rating';
            // only one Quality Indicator Summary record needs to be inserted
            insert newQIS;
            List<Quality_Indicator_Details__c> allQIDList = new List<Quality_Indicator_Details__c>();
            Set<Id> allQIDRTIds = getQIDRecordTypes();
            for (Id rtId : allQIDRTIds) {
                allQIDList.add(
                    new Quality_Indicator_Details__c(
                        QI_Summary_Id__c = newQIS.Id,
                        RecordTypeId = rtId,
                        // this is hardcoded, a helper class can be created to handle it if required
                        Status__c = STATUS_IP
                    )
                );
            }
            insert allQIDList;

            Quality_Indicator_Targets__c newQIT = new Quality_Indicator_Targets__c();
            newQIT.Quality_Indicator_Summary__c = newQIS.Id;
            newQIT.Reporting_Period__c = currentRP[0].Id;
            newQIT.Service__c = relatedSAR[0].Service_Name__c;
            // only one Quality Indicator Target record needs to be inserted
            insert newQIT;
            response.isEmpty = false;
            response.Id = newQIS.Id;
        } catch (Exception e) {
            dohagedcare.Logger.error(e.getMessage(), e, 'QIDynamicManagementController.createNewQI failed').Log();
            throw new AuraHandledException(e.getMessage());
        }
        return JSON.serialize(response);
    }

    public static Set<Id> getQIDRecordTypes() {
        Set<Id> allRecordTypeIds = new Set<Id>();
        List<Schema.RecordTypeInfo> rtInfo = Quality_Indicator_Details__c.SObjectType.getDescribe().getRecordTypeInfos();
        for (Schema.RecordTypeInfo rtRecord : rtInfo) {
            if (!rtRecord.isMaster() && rtRecord.isActive()) {
                allRecordTypeIds.add(rtRecord.getRecordTypeId());
            }
        }
        return allRecordTypeIds;
    }

    public static AuraHandledException qiMessageException(String message) {
        AuraHandledException e = new AuraHandledException(message);
        e.setMessage(message);
        return e;
    }

    private static List<Quality_Indicator_Summary__c> getQISList(String serviceId) {
        return [
            SELECT Id
            FROM Quality_Indicator_Summary__c
            WHERE Service__c = :serviceId AND Reporting_Period__r.Current_Reporting_Period__c = TRUE
            ORDER BY CreatedDate DESC
        ];
    }

    private static List<Service_Account_Relationship__c> getServAcctRelp(String serviceId) {
        return [
            SELECT Id, Provider_Name__c, Service_Name__c, Provider_Name__r.Oracle_ID__c, Service_Name__r.Oracle_Service_ID__c
            FROM Service_Account_Relationship__c
            WHERE Service_Name__c = :serviceId AND Active__c = TRUE
            ORDER BY CreatedDate DESC
        ];
    }

    private static List<Reporting_Period__c> getCurrentRP() {
        return [
            SELECT Id
            FROM Reporting_Period__c
            WHERE Start_Date__c <= TODAY AND End_Date__c >= TODAY AND Current_Reporting_Period__c = TRUE AND Reporting_Period_Type__c = 'Quarter'
            ORDER BY CreatedDate DESC
        ];
    }

    @JsonAccess(serializable='always')
    public class QISResponse {
        @AuraEnabled
        public String id;

        @AuraEnabled
        public Boolean isEmpty;
    }
}