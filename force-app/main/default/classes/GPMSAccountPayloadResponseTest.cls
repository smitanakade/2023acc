@IsTest
public class GPMSAccountPayloadResponseTest {
    
    private static User currentUser = TestDataFactory.createGPMSTestUser();
    
    @testSetup static void setup() {
        
        System.runAs(currentUser){
        
            List<Account> accountToInsert = new List<Account>();
            
            Account apaccount = new Account();
            apaccount = GPMSTestUtility.getAccountByRecordType('Approved_Provider');
            apaccount.Incorporation_ID_Type__c = 'IAN';
            
            Account tpoaccount = new Account();
            tpoaccount = GPMSTestUtility.getAccountByRecordType('Management_Company');
            tpoaccount.Incorporation_ID_Type__c = 'IAN';
            tpoaccount.Incorporation_Type__c = 'Incorporated Association';
            
            accountToInsert.add(GPMSTestUtility.getACOAccount());
            accountToInsert.add(apaccount);
            accountToInsert.add(tpoaccount);
            insert accountToInsert;
            
            Contact contactToInsert = GPMSTestUtility.getContact();
            insert contactToInsert;
            
            Account aco = [SELECT Id FROM Account Where RecordType.DeveloperName = 'Aged_Care_Organisation' limit 1];
            Account ap = [SELECT Id FROM Account Where RecordType.DeveloperName = 'Approved_Provider' limit 1];
            Account tpo = [SELECT Id FROM Account Where RecordType.DeveloperName = 'Management_Company' limit 1];
            
            List<Account_Relationship__c> accountRelationshipToInsert = new List<Account_Relationship__c>();
            accountRelationshipToInsert.add(GPMSTestUtility.getAccountRelationship('ACO_to_Account',aco.Id,ap.Id));
            accountRelationshipToInsert.add(GPMSTestUtility.getAccountRelationship('Provider_to_Management_Company',ap.Id,tpo.Id));
            insert accountRelationshipToInsert;
            
            ap.Name = 'Name Update';
            update ap;
            
            contactToInsert.LastName = 'Update';
            update contactToInsert;
            
            Contact_Relationship__c contactRelationshipToInsert = GPMSTestUtility.getContactRelationship('Key_Personnel_CR',ap.Id,contactToInsert.Id);
            insert contactRelationshipToInsert;
            
            Address__c address = GPMSTestUtility.getAddress();
            insert address;
            
            Address_Location__c accountLocation = GPMSTestUtility.getAccountAddress(address.Id,ap.Id);
            insert accountLocation;
            
        }
        
    }
    
    @isTest static void testGPMSAccountPayload() {

        Account ap = [SELECT Id FROM Account Where RecordType.DeveloperName = 'Approved_Provider' limit 1];

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/GPMS/Account/' + ap.Id ;  //Request URL
        req.httpMethod = 'GET';//HTTP Request Type
        
        System.runAs(currentUser){
            Test.startTest();
        	
            RestContext.request = req;
            RestContext.response= res;
            GPMSAccountPayload payload = GPMSAccountPayloadResponse.getAccountPayload();
            
            System.assertEquals(payload.accountId, ap.Id, 'Did not get expected Account by Id');
            
            Test.stopTest();
        }

    }

}