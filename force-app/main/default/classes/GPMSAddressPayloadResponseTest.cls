@IsTest
public class GPMSAddressPayloadResponseTest {
    
    private static User currentUser = TestDataFactory.createGPMSTestUser();
    
    @testSetup static void setup() {
        
        System.runAs(currentUser){
            
            BusinessLicense serviceToInsert = GPMSTestUtility.getServiceByRecordType('Approved_Provider_Service');
            insert serviceToInsert;
            
            Address__c address = GPMSTestUtility.getAddress();
            insert address;
            
            Address_Location__c accountLocation = GPMSTestUtility.getServiceAddress(address.Id,serviceToInsert.Id);
            insert accountLocation;
            
        }
        
    }
    
    @isTest static void testGPMSAddressPayload() {
        
        System.runAs(currentUser){
            
            Address__c address = [SELECT Id FROM Address__c limit 1];
            
            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/GPMS/Address/' + address.Id ;  //Request URL
            req.httpMethod = 'GET';//HTTP Request Type
            
            
            Test.startTest();
            
            RestContext.request = req;
            RestContext.response= res;
            GPMSAddressPayload payload = GPMSAddressPayloadResponse.getAddressPayload();
            
            System.assertEquals(payload.addressId, address.Id, 'Query Address Informaiton Unsucessfully');
            
            Test.stopTest();
        }
        
    }
    
}