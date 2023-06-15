public with sharing class GPMSTestUtility {
    
    public static Account getAccountByRecordType(String recordTypeName){
        
        Account provider = new Account(Name = 'Provider',Incorporation_ID_Type__c='Taken to be Incorporated',Prospective_Provider__c='');
        provider.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
        provider.Purpose__c = 'Government';
        return provider;
        
    }
    
    public static Account getACOAccount(){
        
        Account aco = new Account(Name = 'ACO',Incorporation_ID_Type__c='Not Incorporated',Prospective_Provider__c='');
        aco.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Aged_Care_Organisation').getRecordTypeId();
        return aco;
        
    }
    
    public static Contact getContact(){
        
        String recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('GPMS Contact').getRecordTypeId();
        Contact contact = new Contact();
        contact.salutation = 'Miss';
        contact.RecordTypeId = recordTypeId;
        contact.FirstName = 'First';
        contact.LastName = 'Last';
        contact.Birthdate = System.today().addYears(-20);        
        return contact;
        
    }
    
    public static Account_Relationship__c getAccountRelationship(String recordTypeName,Id accountFrom, Id accountTo){
        
        Account_Relationship__c accountRelationship = new Account_Relationship__c();
        accountRelationship.recordTypeId = Schema.SObjectType.Account_Relationship__c.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
        accountRelationship.Account_From_Id__c = accountFrom;
        accountRelationship.Account_To_Id__c = accountTo;
        
        return accountRelationship;
        
    }
    
    public static Contact_Relationship__c getContactRelationship(String recordTypeName, Id accountId, Id contactId){
        
        Contact_Relationship__c contactRelationship = new Contact_Relationship__c();
        contactRelationship.recordTypeId = Schema.SObjectType.Contact_Relationship__c.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
        contactRelationship.Account__c = accountId;
        contactRelationship.Contact__c = contactId;
        contactRelationship.Start_Date__c = System.today();
        
        return contactRelationship;
        
    }
    
    public static Contact_Relationship__c getServiceContactRelationship(String recordTypeName, Id serviceId, Id contactId){
        
        Contact_Relationship__c contactRelationship = new Contact_Relationship__c();
        contactRelationship.recordTypeId = Schema.SObjectType.Contact_Relationship__c.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
        contactRelationship.Service__c = serviceId;
        contactRelationship.Contact__c = contactId;
        contactRelationship.Start_Date__c = System.today();
        
        return contactRelationship;
        
    }

    public static Address__c getAddress(){
        
        Address__c address = new Address__c();
        return address;
        
    }

    public static Address_Location__c getAccountAddress(Id addressId, Id accountId){
        
        Address_Location__c location = new Address_Location__c();
        location.Address__c = addressId;
        location.Account__c = accountId;
        location.Location_Type__c = 'Physical';
        location.recordTypeId = Schema.SObjectType.Address_Location__c.getRecordTypeInfosByDeveloperName().get('AccountAddress').getRecordTypeId();
        return location;
        
    }
    
    public static Address_Location__c getServiceAddress(Id addressId, Id serviceId){
        
        Address_Location__c location = new Address_Location__c();
        location.Address__c = addressId;
        location.Service__c = serviceId;
        location.Location_Type__c = 'Physical';
        location.recordTypeId = Schema.SObjectType.Address_Location__c.getRecordTypeInfosByDeveloperName().get('ServiceAddress').getRecordTypeId();
        return location;
        
    }
    
    public static BusinessLicense getServiceByRecordType(String recordType){
        
        BusinessLicense service = new BusinessLicense();
        service.Name = 'Test' + String.valueOf(System.now());
        service.recordTypeId = Schema.SObjectType.BusinessLicense.getRecordTypeInfosByDeveloperName().get(recordType).getRecordTypeId();
        service.Care_Type__c = 'Home Care';
        service.Status__c = 'Inactive';
        service.Status_Date__c = Date.today();
        return service;
        
    }
    
    public static Allotment__c getAllotment(String recordType, String serviceId){
        
        Allotment__c Allotment = new Allotment__c(Service_Name__c = serviceId);
        Allotment.recordTypeId = Schema.SObjectType.Allotment__c.getRecordTypeInfosByDeveloperName().get(recordType).getRecordTypeId();
        return Allotment;
        
    }
    
    public static List<Places_Allotment__c> getPlaces(Integer recordCount, String allotmentId){
        List<Places_Allotment__c> places = new List<Places_Allotment__c>();
        for(Integer i = 0; i< recordCount; i++){
            Places_Allotment__c place = new Places_Allotment__c(Allotment__c = allotmentId);
            place.Care_Level__c = '';
            place.Care_Type__c = '';
            place.Number_of_Places__c = 10;
            place.Current__c = 'Yes';
            places.add(place);
        }
        return places;
    }
    
    public static Event__c getPlaceEvent(String recordType){
        
        Event__c evt = new Event__c();
        evt.recordTypeId = Schema.SObjectType.Event__c.getRecordTypeInfosByDeveloperName().get(recordType).getRecordTypeId();
        return evt;
        
    }

}