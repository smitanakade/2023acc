/****************************************************************************************************
* @CreatedBy   : Accenture development team
* @CreatedDate : 08-SEP-2022
* @Description : Handles the data structure for the service payload
* @Test Class  : GPMSServicePayloadResponseTest
*****************************************************************************************************/
global with sharing class GPMSServicePayload {
    
    public String serviceId;
    
    public SObject service;
    public SObject account;
    
    public List<SObject> accountRelationships;
    
    public List<SObject> previousNames;
    
    public List<SObject> contacts;
    public List<SObject> contactRelationships;
    public List<SObject> contactsPreviousName;
    
    public List<SObject> locations;
    public List<SObject> addresses;
    public List<SObject> geospatials;
    
    public List<SObject> nonContinueServices;
    
    public List<SObject> allotment;
    public List<SObject> places;
    
    public List<SObject> emergencySituations; 
    public List<SObject> serviceFundings;
    
    public List<SObject> subContracts;
    public List<SObject> subContractsAccountRelationships;
    public List<SObject> subContractTPOs;
    
    public List<SObject> accreditationCertificate;
    
    public List<SObject> serviceHistory;
    
    public GPMSServicePayload(String serviceId){
        this.serviceId = serviceId;
    }
    
    public GPMSServicePayload(){
    }
    
    //Service
    public void setService(GPMSPayloadHelper helper){
        
        GPMSPayloadHelper.QueryBundle serviceBundle = new GPMSPayloadHelper.QueryBundle('BusinessLicense','Id',serviceId);
        service = helper.queryResultSingle(serviceBundle);
        
    }
    
    //Account
    public void setAccount(GPMSPayloadHelper helper){
        
        String accountId = (String)service.get('AccountId');
        GPMSPayloadHelper.QueryBundle accountBundle = 
            new GPMSPayloadHelper.QueryBundle('Account','Id',accountId);
        account = helper.queryResultSingle(accountBundle);
        
    }
    
    //Query Provider Relationship Information
    public void setAccountRelationship(GPMSPayloadHelper helper){
        
        GPMSPayloadHelper.QueryBundle accountRelationshipBundle = 
            new GPMSPayloadHelper.QueryBundle('Service_Account_Relationship__c','Service_Name__c',serviceId);
        accountRelationships = helper.queryResultList(accountRelationshipBundle);
        
    }
    
    //Query Previous Name Information
    public void setPreviousName(GPMSPayloadHelper helper){
        
        GPMSPayloadHelper.QueryBundle nameBundle = 
            new GPMSPayloadHelper.QueryBundle('Slowly_Changing_Dimension__c','Service__c',serviceId);
        previousNames = helper.queryResultList(nameBundle);
    }
    
    //Query Previous Contact Relationship Information
    public void setContact(GPMSPayloadHelper helper){
                           
        GPMSPayloadHelper.QueryBundle contactRelationshipBundle = 
            new GPMSPayloadHelper.QueryBundle('Contact_Relationship__c','Service__c',serviceId);
        contactRelationships = helper.queryResultList(contactRelationshipBundle);
    
        Set<String> contactIds = helper.generateIds(contactRelationships,'Contact__c');
        
        GPMSPayloadHelper.QueryBundle CONTACT_BUNDLE = new GPMSPayloadHelper.QueryBundle('Contact','Id',contactIds);
        contacts = helper.queryResultList(CONTACT_BUNDLE);
        
        GPMSPayloadHelper.QueryBundle contactPreviousNameBundle = 
            new GPMSPayloadHelper.QueryBundle('Slowly_Changing_Dimension__c','Contact__c',contactIds);
        contactsPreviousName = helper.queryResultList(contactPreviousNameBundle);
    }
    
    //Query Location Information
    public void setAddress(GPMSPayloadHelper helper){
        
        GPMSPayloadHelper.QueryBundle locationBundle =
            new GPMSPayloadHelper.QueryBundle('Address_Location__c','Service__c',serviceId);
        locations = helper.queryResultList(locationBundle);
    
        Set<String> addressIds = helper.generateIds(locations,'Address__c');
        GPMSPayloadHelper.QueryBundle addressBundle = new GPMSPayloadHelper.QueryBundle('Address__c','Id',addressIds);
        addresses = helper.queryResultList(addressBundle);
        
        GPMSPayloadHelper.QueryBundle geospatialBundle = 
            new GPMSPayloadHelper.QueryBundle('Geospatial_Information__c','Address__c',addressIds);
        geospatials = helper.queryResultList(geospatialBundle);
    }
    
    //Query Allotment Information
    public void setAllotment(GPMSPayloadHelper helper){
        
        GPMSPayloadHelper.QueryBundle allotmentBundle = 
            new GPMSPayloadHelper.QueryBundle('Allotment__c','Service_Name__c',serviceId);
        allotment = helper.queryResultList(allotmentBundle);
        
        Set<String> allotmentIds = helper.generateIds(allotment,'Id');
        GPMSPayloadHelper.QueryBundle placesBundle = new GPMSPayloadHelper.QueryBundle('Places_Allotment__c','Allotment__c',allotmentIds);
        places = helper.queryResultList(placesBundle);
        
    }
    
    //Query SubContract Information
    public void setSubContract(GPMSPayloadHelper helper){
        
        GPMSPayloadHelper.QueryBundle subContractBundle = 
            new GPMSPayloadHelper.QueryBundle('SDO_Contract_Service__c','Service__c',serviceId);
        subContracts = helper.queryResultList(subContractBundle);
        
        Set<String> subContractIds = helper.generateIds(subContracts,'Associated_Accounts__c');
        GPMSPayloadHelper.QueryBundle subContractsRelationshipsBundle = 
            new GPMSPayloadHelper.QueryBundle('Account_Relationship__c','Id',subContractIds);
        subContractsAccountRelationships = helper.queryResultList(subContractsRelationshipsBundle);
        
        Set<String> subContractTPOIds = helper.generateIds(subContractsAccountRelationships,'Account_To_Id__c');
        GPMSPayloadHelper.QueryBundle subContractsTPOBundle = 
            new GPMSPayloadHelper.QueryBundle('Account','Id',subContractTPOIds);
        subContractTPOs = helper.queryResultList(subContractsTPOBundle);
        
    }
    
    //Query Non Continue Service Information
    public void setNonContinueService(GPMSPayloadHelper helper){
        
        GPMSPayloadHelper.QueryBundle nonContinueBundle = 
            new GPMSPayloadHelper.QueryBundle('BusinessLicense','Combined_To__c',serviceId);
        nonContinueServices = helper.queryResultList(nonContinueBundle);
    }
    
    //Query Service Funding Information
    public void setServiceFunding(GPMSPayloadHelper helper){
        
        GPMSPayloadHelper.QueryBundle serviceFundingBundle = 
            new GPMSPayloadHelper.QueryBundle('GPMS_Service_Funding__c','Service__c',serviceId);
        serviceFundings = helper.queryResultList(serviceFundingBundle);
    }
    
    //Query Emergency Situation
    public void setEmergencySituation(GPMSPayloadHelper helper){
        
        GPMSPayloadHelper.QueryBundle emergencySituationBundle = 
            new GPMSPayloadHelper.QueryBundle('GPMS_Emergency_Situation__c','Service__c',serviceId);
        emergencySituations = helper.queryResultList(emergencySituationBundle);
    }
    
    //Query Accreditation Certificate
    public void setAccretitation(GPMSPayloadHelper helper){
        GPMSPayloadHelper.QueryBundle accreditationBundle = 
            new GPMSPayloadHelper.QueryBundle('Accreditation_Certification__c','Service__c',serviceId);
        accreditationCertificate = helper.queryResultList(accreditationBundle);
    }
    
    //Query Service History
    public void setHistory(GPMSPayloadHelper helper){
        GPMSPayloadHelper.QueryBundle accreditationBundle = 
            new GPMSPayloadHelper.QueryBundle('GPMS_Service_History__c','Service__c',serviceId);
        serviceHistory = helper.queryResultList(accreditationBundle);
    }
    

}