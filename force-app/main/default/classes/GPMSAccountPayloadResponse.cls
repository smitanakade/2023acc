/****************************************************************************************************
* @CreatedBy   : Accenture development team
* @CreatedDate : 05-SEP-2022
* @Description : Handles the logic to response the Account and Account related informaiton
* @Test Class  : GPMSAccountPayloadResponseTest
*****************************************************************************************************/
@RestResource(urlMapping='/GPMS/Account/*')
global with sharing class GPMSAccountPayloadResponse {
    
    @HttpGet
    global static GPMSAccountPayload getAccountPayload() {
        
        GPMSAccountPayload macPayload = new GPMSAccountPayload();
        
        try{
            
            RestRequest request = RestContext.request;
            String accountId = request.requestURI.substring(request.requestURI.lastIndexOf('/')+1);
            macPayload = formatGPMSAccountPayload(accountId);
            
        } catch (Exception exp){
            
            dohagedcare.Logger.error(exp.getMessage(),exp,'GPMS').Log();
            
        }
        
        return macPayload;
        
    }
    
    private static GPMSAccountPayload formatGPMSAccountPayload(String recordId){
        
        GPMSPayloadHelper payloadhelper = new GPMSPayloadHelper();
        
        GPMSAccountPayload accountPayload = new GPMSAccountPayload(recordId);
        accountPayload.setAccount(payloadhelper);//Set Account
        
        if(accountPayload.account == null){
            return accountPayload;
        }
        accountPayload.setABN(payloadhelper);//Set ABN
        accountPayload.setParentAccounts(payloadhelper);//Set Parent Account Relationships And Parent Accounts
        accountPayload.setChildAccounts(payloadhelper);//Set Child Account Relationships And Child Accounts
        accountPayload.setContacts(payloadhelper);//Set Contacts Relationships, Contacts, Contact Previous Name
        accountPayload.setAddresses(payloadhelper);//Set Address
        accountPayload.setPreviousName(payloadhelper);//Set Previous Name
        accountPayload.setTradingName(payloadhelper);//Set Trading Name
        accountPayload.setServices(payloadhelper);//Set Service Account Relationship, Service
        accountPayload.setManagementCompanys(payloadhelper);
        accountPayload.setHistory(payloadhelper);
        accountPayload.setPrudentials(payloadhelper);
        accountPayload.setCareTypes(payloadhelper);
        
        return accountPayload;
        
    }
    
}