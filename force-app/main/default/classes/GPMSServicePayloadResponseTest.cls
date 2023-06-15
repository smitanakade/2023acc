@IsTest
public class GPMSServicePayloadResponseTest {
    
    private static User currentUser = TestDataFactory.createGPMSTestUser();
    
    @testSetup static void setup() {
        
        System.runAs(currentUser){
            
            Account accountToInsert = GPMSTestUtility.getACOAccount();
            insert accountToInsert;
            
            Contact contactToInsert = GPMSTestUtility.getContact();
            insert contactToInsert;
            
            BusinessLicense serviceToInsert = GPMSTestUtility.getServiceByRecordType('Approved_Provider_Service');
            insert serviceToInsert;
            
            contactToInsert.LastName = 'Update';
            update contactToInsert;
            
            Contact_Relationship__c contactRelationshipToInsert = 
                GPMSTestUtility.getServiceContactRelationship('Service_Point_of_Contact_CR',serviceToInsert.Id,contactToInsert.Id);
            contactRelationshipToInsert.Role__c = 'Primary Contact';
            insert contactRelationshipToInsert;
            
            Address__c address = GPMSTestUtility.getAddress();
            insert address;
            
            Address_Location__c accountLocation = GPMSTestUtility.getServiceAddress(address.Id,serviceToInsert.Id);
            insert accountLocation;
            
        }
    }
    
    @isTest static void testGPMSServicePayload() {
        
        BusinessLicense service = [SELECT Id FROM BusinessLicense limit 1];
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/GPMS/Service/' + service.Id ;  //Request URL
        req.httpMethod = 'GET';//HTTP Request Type
        
        System.runAs(currentUser){
            Test.startTest();
            
            RestContext.request = req;
            RestContext.response= res;
            GPMSServicePayload payload = GPMSServicePayloadResponse.getServicePayload();
            
            System.assertEquals(payload.serviceId, service.Id, 'Query Account Informaiton Unsucessfully');
            
            Test.stopTest();
        }
        
    }
    
    
}