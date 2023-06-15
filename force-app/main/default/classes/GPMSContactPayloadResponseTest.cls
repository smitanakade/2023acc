@IsTest
public class GPMSContactPayloadResponseTest {
    
    private static User currentUser = TestDataFactory.createGPMSTestUser();
    
    @testSetup static void setup() {
        
        System.runAs(currentUser){
            
            Account accountToInsert = GPMSTestUtility.getACOAccount();
            insert accountToInsert;
            
            Contact contactToInsert = GPMSTestUtility.getContact();
            insert contactToInsert;
            
            contactToInsert.LastName = 'Update';
            update contactToInsert;
            
            Contact_Relationship__c contactRelationshipToInsert = 
                GPMSTestUtility.getContactRelationship('Key_Personnel_CR',accountToInsert.Id,contactToInsert.Id);
            insert contactRelationshipToInsert;
            
        }
                
    }
    
    @isTest static void testGPMSContactPayload() {

        Contact contactToInsert = [SELECT Id FROM Contact limit 1];

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/GPMS/Contact/' + contactToInsert.Id ;  //Request URL
        req.httpMethod = 'GET';//HTTP Request Type
        
        System.runAs(currentUser){
            Test.startTest();
        
            RestContext.request = req;
            RestContext.response= res;
            GPMSContactPayload payload = GPMSContactPayloadResponse.getContactPayload();
            
            System.assertEquals(payload.contactId, contactToInsert.Id, 'Query Contact Informaiton Unsucessfully');
            
            Test.stopTest();
        }

    }

}