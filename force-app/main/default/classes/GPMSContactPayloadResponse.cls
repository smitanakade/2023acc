/****************************************************************************************************
* @CreatedBy   : Accenture development team
* @CreatedDate : 05-SEP-2022
* @Description : Handles the logic to response the Contact and Contact related informaiton
* @Test Class  : GPMSContactPayloadResponseTest
*****************************************************************************************************/
@RestResource(urlMapping='/GPMS/Contact/*')
global class GPMSContactPayloadResponse {
    
    @HttpGet
    global static GPMSContactPayload getContactPayload() {
        
        GPMSContactPayload contactPayload = new GPMSContactPayload();
        
        try{
            
            RestRequest request = RestContext.request;
            String contactId = request.requestURI.substring(request.requestURI.lastIndexOf('/')+1);
            
            contactPayload = formatGPMSContactPayload(contactId);
            
        } catch (Exception exp){
            
            dohagedcare.Logger.error(exp.getMessage(),exp,'GPMS').Log();
            
        }
        
        return contactPayload;
        
    }
    
    private static GPMSContactPayload formatGPMSContactPayload(String recordId){
        
        GPMSPayloadHelper payloadhelper = new GPMSPayloadHelper();
        
        GPMSContactPayload contactPayload = new GPMSContactPayload(recordId);
        
        contactPayload.setAddresses(payloadhelper);
        contactPayload.setPreviousName(payloadhelper);
        contactPayload.setContact(payloadhelper);
        contactPayload.setRelationship(payloadhelper);
        
        return contactPayload;
        
    }
    
}