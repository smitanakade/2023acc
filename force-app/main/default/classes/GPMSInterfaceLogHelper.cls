/****************************************************************************************************
* @CreatedBy   : Accenture Developer Team
* @CreatedDate : 25-Nov-2022
* @Description : Handles the logic to Insert InterfaceLog
* @Test Class  : 
* @Modifed By  : Sanjeev Bajpai-Added Mulesoftextrrnal id,Salesforce ID and interface status 
*****************************************************************************************************/
public with sharing class GPMSInterfaceLogHelper {
    
    public static void insertInterfaceLog(String objectApi, Map<Id, SObject> newMap){
        
        try {

            List<String> interfaceList = getInterface(objectApi);
            if(null == interfaceList ||  interfaceList.size() == 0 ){
                return ;
            }

            List<GPMS_Interface_Logging__c> interfaceLogToInsert = new List<GPMS_Interface_Logging__c>();
            
            for(String interfaceLog : interfaceList){
                for(SObject changeEvent : newMap.values()){
                    
                    eventbus.ChangeEventHeader header = (eventbus.ChangeEventHeader)changeEvent.get('ChangeEventHeader');
                    List<String> recordIds = (List<String>)changeEvent.get('recordIds');
                    if(recordIds != null && recordIds.size() > 0) {
                     for (String recordId : recordIds) {
                    GPMS_Interface_Logging__c log = new GPMS_Interface_Logging__c();
                    log.GPMS_Interface__c = interfaceLog;
                    log.GPMS_ReplayId__c = (String)changeEvent.get('ReplayId');
                    log.GPMS_Change_Type__c = header.getChangeType();
                    log.GPMS_Entity_Name__c = header.getEntityName();
                    log.GPMS_Salesforce_ID__c = recordId;
                    log.GPMS_Mulesoft_External_ID__c = interfaceLog + '_' + (String)changeEvent.get('ReplayId') + '_' + recordId;
                    log.GPMS_Status__c = 'Pending';
                    interfaceLogToInsert.add(log);
                     }     
                    }
                }
            }

            if(interfaceLogToInsert.size() > 0){
                insert interfaceLogToInsert;
            }
            
        } catch(Exception exp) {
            dohagedcare.Logger.error(exp.getMessage(),exp,'GPMS').Log(); 
        }
    }
    
    private static List<String> getInterface(String objectApi){
        
        List<String> interfaceList = new List<String>();
        
        List<GPMS_Interface_Log__mdt> interfaceLogList = [SELECT Id, GPMS_Interface__c FROM GPMS_Interface_Log__mdt WHERE GPMS_Object_API__c= :objectApi];
        for(GPMS_Interface_Log__mdt log : interfaceLogList){
            interfaceList.add(log.GPMS_Interface__c);
        }
        
        return interfaceList;
        
    }
    
}