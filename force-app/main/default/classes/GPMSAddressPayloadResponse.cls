/****************************************************************************************************
* @CreatedBy   : Accenture development team
* @CreatedDate : 05-SEP-2022
* @Description : Handles the logic to qresponse the Address and Address related informaiton
* @Test Class  : GPMSAddressPayloadResponseTest
*****************************************************************************************************/
@RestResource(urlMapping='/GPMS/Address/*')
global class GPMSAddressPayloadResponse {
    
    @HttpGet
    global static GPMSAddressPayload getAddressPayload() {
        
        try{
            
            RestRequest request = RestContext.request;
            String addressId = request.requestURI.substring(request.requestURI.lastIndexOf('/')+1);
            
            GPMSAddressPayload addressPayload = formatGPMSAddressPayload(addressId);
            
            return addressPayload;
            
        } catch (Exception exp){
            
            dohagedcare.Logger.error(exp.getMessage(),exp,'GPMS').Log();
            return new GPMSAddressPayload('');
            
        }
        
    }
    
    private static GPMSAddressPayload formatGPMSAddressPayload(String recordId){
        
        GPMSPayloadHelper payloadhelper = new GPMSPayloadHelper();
        
        GPMSAddressPayload macPayload = new GPMSAddressPayload(recordId);
        
        
        macPayload.setAddress(payloadhelper);
        macPayload.setLocations(payloadhelper);
        macPayload.setServices(payloadhelper);
        macPayload.setAccounts(payloadhelper);
        macPayload.setContacts(payloadhelper);
        macPayload.setGeospatial(payloadhelper);
        
        return macPayload;
        
    }
}