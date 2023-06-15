/****************************************************************************************************
* @CreatedBy   : Accenture development team
* @CreatedDate : 05-SEP-2022
* @Description : Handles the Data Structure for Address Payload
* @Test Class  : GPMSAddressPayloadResponseTest
*****************************************************************************************************/
global with sharing class GPMSAddressPayload {
    
    public String addressId;
    public SObject address;
    
    public List<SObject> locations;
    
    public List<SObject> accounts;
    public List<SObject> services;
    public List<SObject> contacts;
    public List<SObject> geospatials;
    
    public List<SObject> accountRelationships;
    
    public GPMSAddressPayload(String addressId){
        this.addressId = addressId;
    }
    
    //Locations
    public void setAddress(GPMSPayloadHelper helper){
        
        GPMSPayloadHelper.QueryBundle addressBundle = 
            new GPMSPayloadHelper.QueryBundle('Address__c','Id',addressId);
        address = helper.queryResultSingle(addressBundle);
        
    }
    
    //Locations
    public void setLocations(GPMSPayloadHelper helper){
        
        GPMSPayloadHelper.QueryBundle locationBundle = 
            new GPMSPayloadHelper.QueryBundle('Address_Location__c','Address__c',addressId);
        locations = helper.queryResultList(locationBundle);
        
    }
    
    public void setServices(GPMSPayloadHelper helper){
        
        Set<String> servicesIds = helper.generateIds(locations,'Service__c');
        GPMSPayloadHelper.QueryBundle servicesBundle = 
            new GPMSPayloadHelper.QueryBundle('BusinessLicense','Id',servicesIds);
        services = helper.queryResultList(servicesBundle);
        
    }
    
    public void setContacts(GPMSPayloadHelper helper){
        
        Set<String> contactIds = helper.generateIds(locations,'Contact__c');
        GPMSPayloadHelper.QueryBundle contactsBundle = 
            new GPMSPayloadHelper.QueryBundle('Contact','Id',contactIds);
        contacts = helper.queryResultList(contactsBundle);
        
    }
    
    public void setAccounts(GPMSPayloadHelper helper){
        
        Set<String> accountIds = helper.generateIds(locations,'Account__c');
        
        GPMSPayloadHelper.QueryBundle accountBundle = 
            new GPMSPayloadHelper.QueryBundle('Account','Id',accountIds);
        accounts = helper.queryResultList(accountBundle);
        
        GPMSPayloadHelper.QueryBundle accountRelationshipBundle = 
            new GPMSPayloadHelper.QueryBundle('Account_Relationship__c','Account_To_Id__c',accountIds);
        accountRelationships = helper.queryResultList(accountRelationshipBundle);
        
    }
    
    //Locations
    public void setGeospatial(GPMSPayloadHelper helper){
        
        GPMSPayloadHelper.QueryBundle geospatialBundle = 
            new GPMSPayloadHelper.QueryBundle('Geospatial_Information__c','Address__c',addressId);
        geospatials = helper.queryResultList(geospatialBundle);
        
    }

}