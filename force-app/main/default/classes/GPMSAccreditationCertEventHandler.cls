/****************************************************************************************************
* @CreatedBy   : Accenture Developer Team
* @CreatedDate : 25-Nov-2022
* @Description : Handles the logic to GPMSAccreditationCertEventHandler
* @Test Class  : 
*****************************************************************************************************/
public with sharing class GPMSAccreditationCertEventHandler implements afterInsert{
    
    public static final String OBJECT_API = 'Accreditation_Certification__c';
    
    public void afterInsert(Map<Id, SObject> newMap) {
        try {
            GPMSInterfaceLogHelper.insertInterfaceLog(OBJECT_API, newMap);
        } catch(Exception exp) {
            dohagedcare.Logger.error(exp.getMessage(),exp,'GPMS').Log(); 
        }
    }

}