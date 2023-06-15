/****************************************************************************************************
* @CreatedBy   : Accenture development team
* @CreatedDate : 05-SEP-2022
* @Description : Handles the Data Structure for Contact Payload
* @Test Class  : GPMSContactPayloadResponseTest
*****************************************************************************************************/
global class GPMSContactPayload {
    
    public String contactId;
    
    public SObject contact; //Current Contact
    public List<SObject> previousNames;//previous name history
    
    public List<SObject> contactRelationships;
    public List<SObject> accounts;
    public List<SObject> services;
    
    public List<SObject> locations;
    public List<SObject> addresses;
    
    public GPMSContactPayload(String contactId){
        this.contactId = contactId;
    }
    
    public GPMSContactPayload(){
        
    }
    
    public void setContact(GPMSPayloadHelper helper){
        
        //Contact Location
        GPMSPayloadHelper.QueryBundle locationBundle = 
            new GPMSPayloadHelper.QueryBundle('Contact','Id',contactId);
        contact = helper.queryResultSingle(locationBundle);
        
    }
    
    
    public void setAddresses(GPMSPayloadHelper helper){
        
        //Contact Location
        GPMSPayloadHelper.QueryBundle locationBundle = 
            new GPMSPayloadHelper.QueryBundle('Address_Location__c','Contact__c',contactId);
        locations = helper.queryResultList(locationBundle);
        
        //Contact Address 
        Set<String> addressIds = helper.generateIds(locations,'Address__c');
        GPMSPayloadHelper.QueryBundle addressBundle = 
            new GPMSPayloadHelper.QueryBundle('Address__c','Id',addressIds);
        addresses = helper.queryResultList(addressBundle);
        
    }
    
    //Contact Previous Name
    public void setPreviousName(GPMSPayloadHelper helper){
        
        GPMSPayloadHelper.QueryBundle scdBundle = 
            new GPMSPayloadHelper.QueryBundle('Slowly_Changing_Dimension__c','Contact__c',contactId);
        previousNames = helper.queryResultList(scdBundle);
        
    }
    
    //Contact Relationships
    public void setRelationship(GPMSPayloadHelper helper){
        
        GPMSPayloadHelper.QueryBundle contactRelationshipBundle = 
            new GPMSPayloadHelper.QueryBundle('Contact_Relationship__c','Contact__c',contactId);
        contactRelationships = helper.queryResultList(contactRelationshipBundle);
        
        Set<String> accountIds = helper.generateIds(contactRelationships,'Account__c');
        GPMSPayloadHelper.QueryBundle accountBundle = 
            new GPMSPayloadHelper.QueryBundle('Account','Id',accountIds);
        accounts = helper.queryResultList(accountBundle);
        
        Set<String> serviceIds = helper.generateIds(contactRelationships,'Service__c');
        GPMSPayloadHelper.QueryBundle serviceBundle = 
            new GPMSPayloadHelper.QueryBundle('BusinessLicense','Id',serviceIds);
        services = helper.queryResultList(serviceBundle);
        
    }
    

}