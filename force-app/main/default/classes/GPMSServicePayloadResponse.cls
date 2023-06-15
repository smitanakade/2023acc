/****************************************************************************************************
* @CreatedBy   : Accenture development team
* @CreatedDate : 08-SEP-2022
* @Description : Handles the logic to qresponse the Service and Service related informaiton
* @Test Class  : GPMSServicePayloadResponseTest
*****************************************************************************************************/
@RestResource(urlMapping='/GPMS/Service/*')
global with sharing class GPMSServicePayloadResponse {
    
    @HttpGet
    global static GPMSServicePayload getServicePayload() {
        
        GPMSServicePayload servicePayload = new GPMSServicePayload();
        
        try {
            
            RestRequest request = RestContext.request;
            String serviceId = request.requestURI.substring(request.requestURI.lastIndexOf('/')+1);
            
            servicePayload = formatGPMSServicePayload(serviceId);
            
        } catch (Exception exp){
            
            dohagedcare.Logger.error(exp.getMessage(),exp,'GPMS').Log();
            
        }
        
        return servicePayload;
        
    }
    
    private static GPMSServicePayload formatGPMSServicePayload(String recordId){
        
        GPMSPayloadHelper payloadhelper = new GPMSPayloadHelper();
        
        GPMSServicePayload servicePayload = new GPMSServicePayload(recordId);
        
        servicePayload.setService(payloadhelper);//Set Service
        servicePayload.setAccount(payloadhelper);//Set Account
        servicePayload.setAccountRelationship(payloadhelper);//Set Account Relationships
        servicePayload.setPreviousName(payloadhelper);//Set Service Previous Name
        servicePayload.setContact(payloadhelper);//Set Contacts Relationships, Contacts, Contact Previous Name
        servicePayload.setAddress(payloadhelper);//Set Address, Location, Geospatials
        servicePayload.setAllotment(payloadhelper);//Set Previous Allotment
        servicePayload.setNonContinueService(payloadhelper);//Set Non Continuing Service
        servicePayload.setEmergencySituation(payloadhelper);//Set Service History
        servicePayload.setServiceFunding(payloadhelper);//Set Service History
        servicePayload.setAccretitation(payloadhelper);//Set Accreditation,certificate
        servicePayload.setHistory(payloadhelper);//Set Service History
        servicePayload.setSubContract(payloadhelper);//SetService sub contract
        
        return servicePayload;
        
    }
    
    
}