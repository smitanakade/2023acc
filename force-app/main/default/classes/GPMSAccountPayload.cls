/****************************************************************************************************
* @CreatedBy   : Accenture Developer Team
* @CreatedDate : 19-Jul-2022
* @Description : Handles the data structure for the account payload
* @Test Class  : GPMSAccountPayloadResponseTest
*****************************************************************************************************/
global with sharing class GPMSAccountPayload {
    
    public String accountId;
    
    public SObject account; //Current Account
    public SObject abn; // Account ABN
    
    public List<SObject> parentRelationships;//Parent account relationship
    public List<SObject> parentAccounts;//Parent ACO
    
    public List<SObject> childRelationships;//Child account relationship
    public List<SObject> childAccounts;//Child TPO
    
    public List<SObject> contactRelationships;
    public List<SObject> contacts;
    public List<SObject> contactPreviousName;//previous name history
    public List<SObject> contactCredentials;
    
    public List<SObject> managementCompanyContactRelationships;
    public List<SObject> managementCompanyContacts;
    public List<SObject> managementCompanyContactPreviousName;
    
    public List<SObject> locations;
    public List<SObject> addresses;
    
    public List<SObject> accountServiceRelationships;
    public List<SObject> services;
    public List<SObject> serviceLocations;
    public List<SObject> serviceAddresses;
    
    public List<SObject> previousNames;//previous name history
    public List<SObject> tradingNames;// trading name
    
    public List<SObject> prudentials;
    public List<SObject> careTypes;
    
    public List<SObject> subContracts;
    
    public List<SObject> tpoContracts;
    public List<SObject> tpoContractServices;
    
    public List<SObject> accountHistory;
    
    public GPMSAccountPayload(String accountId){
        this.accountId = accountId;
    }
    
    public GPMSAccountPayload(){
        
    }
    
    //Account
    public void setAccount(GPMSPayloadHelper helper){
        
        GPMSPayloadHelper.QueryBundle accountBundle = new GPMSPayloadHelper.QueryBundle('Account','Id',accountId);
        account = helper.queryResultSingle(accountbundle);
    }
    
    //ABN
    public void setABN(GPMSPayloadHelper helper){
        
        if(null != account.get('ABN_Entity_Name__c')){
            
            String abnId = (String)account.get('ABN_Entity_Name__c');
            
            GPMSPayloadHelper.QueryBundle abnBundle = new GPMSPayloadHelper.QueryBundle('Registered_ABN_Name__c','Id',abnId);
            abn = helper.queryResultSingle(abnBundle);
        }
        
    }
    
    public void setParentAccounts(GPMSPayloadHelper helper){
        
        //Parent Account Relationships
        GPMSPayloadHelper.QueryBundle parentRelationshipBundle = 
            new GPMSPayloadHelper.QueryBundle('Account_Relationship__c','Account_To_Id__c',accountId);
        parentRelationships = helper.queryResultList(parentRelationshipBundle);
        
        //Parent Account
        Set<String> parentAccountIds = helper.generateIds(parentRelationships,'Account_From_Id__c');
        GPMSPayloadHelper.QueryBundle parentAccountBundle = 
            new GPMSPayloadHelper.QueryBundle('Account','Id',parentAccountIds);
        parentAccounts = helper.queryResultList(parentAccountBundle);
        
        //Third Party organization contract
        Set<String> tpoContractIds = helper.generateIds(parentRelationships,'Id');
        GPMSPayloadHelper.QueryBundle subContractBundle = 
            new GPMSPayloadHelper.QueryBundle('SDO_Contract_Service__c','Associated_Accounts__c',tpoContractIds);
        tpoContracts = helper.queryResultList(subContractBundle);
        
        Set<String> serviceIds = helper.generateIds(tpoContracts,'Service__c');
        GPMSPayloadHelper.QueryBundle serviceBundle = 
            new GPMSPayloadHelper.QueryBundle('BusinessLicense','Id',serviceIds);
        tpoContractServices = helper.queryResultList(serviceBundle);
        
    }
    
    public void setChildAccounts(GPMSPayloadHelper helper){
        
        //Child Account Relationships
        GPMSPayloadHelper.QueryBundle childAccountRelationshipBundle = 
            new GPMSPayloadHelper.QueryBundle('Account_Relationship__c','Account_From_Id__c',this.accountId);
        childRelationships = helper.queryResultList(childAccountRelationshipBundle);
        
        //Child Accounts
        Set<String> childAccountIds = helper.generateIds(childRelationships,'Account_To_Id__c');
        GPMSPayloadHelper.QueryBundle childAccountBundle = 
            new GPMSPayloadHelper.QueryBundle('Account','Id',childAccountIds);
        childAccounts = helper.queryResultList(childAccountBundle);
        
        Set<String> subContractIds = helper.generateIds(childRelationships,'Id');
        GPMSPayloadHelper.QueryBundle subContractBundle = 
            new GPMSPayloadHelper.QueryBundle('SDO_Contract_Service__c','Associated_Accounts__c',subContractIds);
        subContracts = helper.queryResultList(subContractBundle);
        
    }
    
    public void setManagementCompanys(GPMSPayloadHelper helper){
        
        //Child Account Relationships
        List<Object> managementCompanys = helper.filterList(childRelationships,'Entity_Type__c','Management Company');
        Set<String> managementCompanyIds = helper.generateIds(childRelationships,'Account_To_Id__c');
        
        GPMSPayloadHelper.QueryBundle managementCompanysContactRelationshipBundle = 
            new GPMSPayloadHelper.QueryBundle('Contact_Relationship__c','Account__c',managementCompanyIds);
        managementCompanyContactRelationships = helper.queryResultList(managementCompanysContactRelationshipBundle);
        
        //Child Accounts
        Set<String> managementCompanysContactIds = helper.generateIds(managementCompanyContactRelationships,'Contact__c');
        GPMSPayloadHelper.QueryBundle managementCompanysContactBundle = 
            new GPMSPayloadHelper.QueryBundle('Contact','Id',managementCompanysContactIds);
        managementCompanyContacts = helper.queryResultList(managementCompanysContactBundle);
        
        GPMSPayloadHelper.QueryBundle managementCompanysContactPrevioudNameBundle = 
            new GPMSPayloadHelper.QueryBundle('Slowly_Changing_Dimension__c','Contact__c',managementCompanysContactIds);
        managementCompanyContactPreviousName = helper.queryResultList(managementCompanysContactPrevioudNameBundle);
        
    }
    
    public void setContacts(GPMSPayloadHelper helper){
        
        //Contact Relationships
        GPMSPayloadHelper.QueryBundle contactRelationshipBundle = 
            new GPMSPayloadHelper.QueryBundle('Contact_Relationship__c','Account__c',accountId);
        contactRelationships = helper.queryResultList(contactRelationshipBundle);
        
        //Contacts
        Set<String> contactIds = helper.generateIds(contactRelationships,'Contact__c');
        GPMSPayloadHelper.QueryBundle contactBundle = 
            new GPMSPayloadHelper.QueryBundle('Contact','Id',contactIds);
        contacts = helper.queryResultList(contactBundle);
        
        //Contacts Previous Name
        GPMSPayloadHelper.QueryBundle contactPreviousNameBundle = 
            new GPMSPayloadHelper.QueryBundle('Slowly_Changing_Dimension__c','Contact__c',contactIds);
        contactPreviousName = helper.queryResultList(contactPreviousNameBundle);
        
        //Contacts Credentials
        GPMSPayloadHelper.QueryBundle contactCredentialBundle = 
            new GPMSPayloadHelper.QueryBundle('PersonEducation','Contact__c',contactIds);
        contactCredentials = helper.queryResultList(contactCredentialBundle);
        
    }
    
    public void setAddresses(GPMSPayloadHelper helper){
        
        //Account Location
        GPMSPayloadHelper.QueryBundle locationBundle = 
            new GPMSPayloadHelper.QueryBundle('Address_Location__c','Account__c',accountId);
        locations = helper.queryResultList(locationBundle);
        
        //Account Address 
        Set<String> addressIds = helper.generateIds(locations,'Address__c');
        GPMSPayloadHelper.QueryBundle addressBundle = 
            new GPMSPayloadHelper.QueryBundle('Address__c','Id',addressIds);
        addresses = helper.queryResultList(addressBundle);
        
    }
    
    public void setServices(GPMSPayloadHelper helper){
        
        //Account Services Relationships
        GPMSPayloadHelper.QueryBundle accountServiceBundle = 
            new GPMSPayloadHelper.QueryBundle('Service_Account_Relationship__c','Provider_Name__c',accountId);
        accountServiceRelationships = helper.queryResultList(accountServiceBundle);
        
        //Services
        Set<String> serviceIds = helper.generateIds(accountServiceRelationships,'Service_Name__c');
        GPMSPayloadHelper.QueryBundle serviceBundle = 
            new GPMSPayloadHelper.QueryBundle('BusinessLicense','Id',serviceIds);
        services = helper.queryResultList(serviceBundle);
        
        //Service Locations
        GPMSPayloadHelper.QueryBundle locationBundle = 
            new GPMSPayloadHelper.QueryBundle('Address_Location__c','Service__c',serviceIds);
        serviceLocations = helper.queryResultList(locationBundle);
        
        //Service Address
        Set<String> addressIds = helper.generateIds(serviceLocations,'Address__c');
        GPMSPayloadHelper.QueryBundle addressBundle = 
            new GPMSPayloadHelper.QueryBundle('Address__c','Id',addressIds);
        serviceAddresses = helper.queryResultList(addressBundle);
        
    }
    
    //Account Previous Name
    public void setPreviousName(GPMSPayloadHelper helper){
        
        GPMSPayloadHelper.QueryBundle scdBundle = 
            new GPMSPayloadHelper.QueryBundle('Slowly_Changing_Dimension__c','Account__c',accountId);
        previousNames = helper.queryResultList(scdBundle);
        
    }
    
    //Account Care Type
    public void setCareTypes(GPMSPayloadHelper helper){
        
        GPMSPayloadHelper.QueryBundle careTypeBundle = 
            new GPMSPayloadHelper.QueryBundle('Care_Type__c','Account__c',accountId);
        careTypes = helper.queryResultList(careTypeBundle);
        
    }
    
    //Account Trading Name
    public void setTradingName(GPMSPayloadHelper helper){
        
        GPMSPayloadHelper.QueryBundle tnBundle = 
            new GPMSPayloadHelper.QueryBundle('Trading_Name__c','Account__c',accountId);
        tradingNames = helper.queryResultList(tnBundle);
        
    }
    
        
	//Account prudentials
    public void setPrudentials(GPMSPayloadHelper helper){
        
        GPMSPayloadHelper.QueryBundle prudentialsBundle = 
            new GPMSPayloadHelper.QueryBundle('Prudential_Detail__c','Account__c',accountId);
        prudentials = helper.queryResultList(prudentialsBundle);
        
    }
    
    //Account History
    public void setHistory(GPMSPayloadHelper helper){
        
        GPMSPayloadHelper.QueryBundle historyBundle = 
            new GPMSPayloadHelper.QueryBundle('GPMS_Account_History__c','Account__c',accountId);
        accountHistory = helper.queryResultList(historyBundle);
        
    }
    
}