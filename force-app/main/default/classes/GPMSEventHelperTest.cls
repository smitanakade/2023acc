@IsTest
public class GPMSEventHelperTest {
    
    private static User user = TestDataFactory.createSystemAdminUser();
    
    @testSetup static void setup() {
        
        System.runAs(user){
            
            Account apaccount = new Account();
            apaccount = GPMSTestUtility.getAccountByRecordType('Approved_Provider');
            apaccount.Incorporation_ID_Type__c = 'IAN';
            insert apaccount;
            
            Care_Type__c ct = new Care_Type__c();
            ct.Care_Type__c = 'Residential';
            ct.Current_Approval_Status__c = 'Approved';
            ct.Account__c = apaccount.Id;
            insert ct;
            
            Address__c address = GPMSTestUtility.getAddress();
            insert address;
            
            BusinessLicense serviceToInsert = GPMSTestUtility.getServiceByRecordType('Approved_Provider_Service');
            serviceToInsert.Care_Type__c = 'Residential';
            serviceToInsert.AccountId = apaccount.Id;
            insert serviceToInsert;
            
            BusinessLicense disContinuingserviceToInsert = GPMSTestUtility.getServiceByRecordType('Approved_Provider_Service');
            disContinuingserviceToInsert.Care_Type__c = 'Residential';
            disContinuingserviceToInsert.AccountId = apaccount.Id;
            insert disContinuingserviceToInsert;
            
            Contact contactToInsert = GPMSTestUtility.getContact();
            insert contactToInsert;
            
            Contact_Relationship__c contactRelationshipToInsert = 
                GPMSTestUtility.getServiceContactRelationship('Service_Point_of_Contact_CR',serviceToInsert.Id,contactToInsert.Id);
            contactRelationshipToInsert.Role__c = 'Primary Contact';
            insert contactRelationshipToInsert;
            
            Event__c eventservice = new Event__c();
            eventservice.Service__c = serviceToInsert.Id;
            eventservice.Activated__c = 'N/A';
            eventservice.Event_Type__c = 'Combine';
            eventservice.NewServiceName__c = '';
            insert eventservice;
            
            Service_Event__c continuingevent = new Service_Event__c(
                Event__c = eventservice.Id, Service__c = serviceToInsert.Id, Service_Type__c = 'Continuing Service');
            Service_Event__c disContinuingevent= new Service_Event__c(
                Event__c = eventservice.Id, Service__c = disContinuingserviceToInsert.Id, Service_Type__c = 'Discontinuing Service');
            insert continuingevent;
            insert disContinuingevent;
            
            Allotment__c allotment = GPMSTestUtility.getAllotment('Approved_Provider_Residential_ALM',disContinuingserviceToInsert.Id);
            insert Allotment;
            
            Integer placesCount = 5;
            List<Places_Allotment__c> places = GPMSTestUtility.getPlaces(placesCount,Allotment.Id);
            insert places;
            
            GPMS_Continuing_Contact__c serviceContact = new GPMS_Continuing_Contact__c();
            serviceContact.AssociatedContacts__c = contactRelationshipToInsert.Id;
            serviceContact.Event__c = eventservice.Id;
            insert serviceContact;
            
            
        }
        
    }
    
    @isTest static void testGPMSCreatePlaces() {
        
        System.runAs(user){
            Test.startTest();
            
            Event__c eventservice = [SELECT Id from Event__c limit 1];
            eventservice.Activated__c = 'Yes';
            update eventservice;
            
            Test.stopTest();
        }
        
        
        
    }
}