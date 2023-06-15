/****************************************************************************************************
* @CreatedBy   : Accenture Developer Team
* @CreatedDate : 25-Nov-2022
* @Description : Handles the logic to GPMSBusinessLicenseEventHandler
* @Test Class  : GPMSInterfaceLogHelperTest
*****************************************************************************************************/
public with sharing class GPMSBusinessLicenseEventHandler implements AfterInsert{
    
    public static final String OBJECT_API = 'BusinessLicense';
    
    public void afterInsert(Map<Id, SObject> newMap) {
        
        try {
            GPMSInterfaceLogHelper.insertInterfaceLog(OBJECT_API, newMap);
        } catch(Exception exp) {
            dohagedcare.Logger.error(exp.getMessage(),exp,'GPMS').Log(); 
        }
        
    }

}