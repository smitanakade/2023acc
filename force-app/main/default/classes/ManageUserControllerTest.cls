@isTest
public class ManageUserControllerTest {
    public static final String emailId = 'TestClassUser_OrgAdmin@gmail.com';
    @TestSetup
    static void testSetupMethod (){
       User gpmsUser = TestDataFactory.createGPMSTestUser();
       System.runAs(gpmsUser)
       {
            Test.startTest();
           	TestDataFactory.manageUsersTestData(); 
           	Test.StopTest();
       }
        
    }
    @isTest
    static void testGetACOInfo(){
               
        User orgAdminUser = [SELECT Id FROM User WHERE federationIdentifier =:emailId LIMIT 1];       
        System.runAs(orgAdminUser){
            Test.StartTest();
            ManageUserController.getACOInfo();
            Test.StopTest();
        }        
    }
    @isTest
     static void testGetRelatedContact(){
        User orgAdminUser = [SELECT Id,contact.accountId FROM User WHERE federationIdentifier =:emailId LIMIT 1];      
        System.runAs(orgAdminUser){
            Test.StartTest();
            ManageUserController.getRelatedContacts(orgAdminUser.contact.accountId);
            Test.StopTest();
        }        
    }
    @isTest
    static void testGetPickListValues(){
        User orgAdminUser = [SELECT Id,contact.accountId FROM User WHERE federationIdentifier =:emailId LIMIT 1];      
        System.runAs(orgAdminUser){
            Test.StartTest();
            ManageUserController.getPickListValues('newuser_test124@gmail.com',orgAdminUser.contact.accountId);
            Test.StopTest();
        }        
    }
    @isTest
    static void testGetPickListValues2(){
        User orgAdminUser = [SELECT Id,contact.accountId FROM User WHERE federationIdentifier =:emailId LIMIT 1];
        Account providerAccount = [SELECT id from Account WHERE parentId =:orgAdminUser.contact.accountId  LIMIT 1];
        System.runAs(orgAdminUser){
            Test.StartTest();
            ManageUserController.getPickListValues('newuser_test124@gmail.com',providerAccount.Id);
            Test.StopTest();
        }        
    }
    
   
    @isTest
	static void testGetManageUser(){
        User orgAdminUser = [SELECT Id,contact.accountId, contactId FROM User WHERE federationIdentifier =:emailId LIMIT 1];
        AccountContactRelation acrRecord = [SELECT Id,accountId FROM AccountContactRelation WHERE accountId =:orgAdminUser.contact.accountId AND contactId =: orgAdminUser.ContactId LIMIT 1];
        System.runAs(orgAdminUser){
            Test.StartTest();
            ManageUserController.getManageUser(acrRecord.id);
            Test.StopTest();
        }        
    }
     @isTest
	static void testGetManageUser2(){
        User orgAdminUser = [SELECT Id,contact.accountId, contactId FROM User WHERE federationIdentifier =:emailId LIMIT 1];
        AccountContactRelation acrRecord = [SELECT Id,accountId FROM AccountContactRelation WHERE account.parentId =:orgAdminUser.contact.accountId LIMIT 1];
        System.runAs(orgAdminUser){
            Test.StartTest();
            ManageUserController.getManageUser(acrRecord.id);
            Test.StopTest();
        }        
    }
    @isTest
	static void testGetManageUser3(){
        String scrRecordTypeId = Schema.SObjectType.Contact_Relationship__c.getRecordTypeInfosByDeveloperName().get('SCR').getRecordTypeId();
        User orgAdminUser = [SELECT Id,contact.accountId, contactId FROM User WHERE federationIdentifier =:emailId LIMIT 1];
        AccountContactRelation acrRecord = [SELECT Id,accountId, contactId FROM AccountContactRelation WHERE account.parentId =:orgAdminUser.contact.accountId LIMIT 1];
        BusinessLicense relatedService = [SELECT Id,accountId FROM BusinessLicense WHERE Account.ParentId =:orgAdminUser.contact.accountId LIMIT 1];
        Contact_Relationship__c serviceReltationship = new Contact_Relationship__c(service__c=relatedService.id,contact__c=acrRecord.contactId,
                                                            Portal_Service_Roles__c='Star Rating Reviewer - Service', RecordTypeId = scrRecordTypeId);
        insert serviceReltationship;
        System.runAs(orgAdminUser){
            Test.StartTest();
            ManageUserController.getManageUser(acrRecord.id);
            Test.StopTest();
        }        
    }
    @isTest
    static void testSendEmail(){
        User orgAdminUser = [SELECT Id,contact.accountId, contactId FROM User WHERE federationIdentifier =:emailId LIMIT 1];
        AccountContactRelation acrRecord = [SELECT Id,accountId FROM AccountContactRelation WHERE accountId =:orgAdminUser.contact.accountId AND contactId =: orgAdminUser.ContactId LIMIT 1];
        List<ManageUserController.EmailDetails> emailDetails = new List<ManageUserController.EmailDetails>();
        ManageUserController.EmailDetails emailDetail = new ManageUserController.EmailDetails();
        emailDetail.emailTemplate = 'External_User_Portal_Invite_Classic';
        emailDetail.acrId = acrRecord.id;
        emailDetails.add(emailDetail);
        System.runAs(orgAdminUser){
            Test.StartTest();
            ManageUserController.sendEmail(emailDetails);
            Test.StopTest();
        }        
    }
     @isTest
    static void testGetHandleInvite(){
        User orgAdminUser = [SELECT Id,contact.accountId FROM User WHERE federationIdentifier =:emailId LIMIT 1];
        BusinessLicense relatedService = [SELECT Id,accountId FROM BusinessLicense WHERE Account.ParentId =:orgAdminUser.contact.accountId LIMIT 1];
        String jsonString = '{"contactExists": false,"acrExists": false,"isRoleBlank": false,"userExists": false,"accountId": "'+relatedService.AccountId+'","accountRecordType": "Approved_Provider",'+
            				'"userDetails": {"contactId": "","firstName": "Test Class","lastName": "Manage User","email": "newuser_test124@gmail.com","birthDate": "1992-10-02","salutation": "Mr"},'+
            '"roles": ["Data Entry", "Report Submission"],"serviceRoles": ["Star Rating Reviewer - Service"],"providerRoles": [],"relatedServices": {"Star Rating Reviewer - Service":["'+
            relatedService.id+'"]},"isManage": false}';
        
        System.runAs(orgAdminUser){
            Test.StartTest();
            ManageUserController.getHandleInvite(jsonString);
            Test.StopTest();
        }        
    }
    @isTest
     static void testGetHandleInvite2(){
        User orgAdminUser = [SELECT Id,contact.accountId FROM User WHERE federationIdentifier =:emailId LIMIT 1];
        AccountContactRelation existingContact = [SELECT Id,accountId,contactId FROM AccountContactRelation WHERE Account.ParentId =:orgAdminUser.contact.accountId LIMIT 1];         
        String jsonString = '{"contactExists": true,"acrExists": false,"isRoleBlank": false,"userExists": false,"accountId": "'+orgAdminUser.contact.accountId+'","accountRecordType": "Approved_Provider",'+
            				'"userDetails": {"contactId": "'+existingContact.contactId+
                            '","firstName": "Test Class","lastName": "Manage User","email": "newuser_test124@gmail.com","birthDate": "1992-10-02","salutation": "Mr"},'+
            '"roles": ["Organisation Administrator"],"providerRoles": [],"serviceRoles": [],"relatedServices": {},"isManage": false}';
        
        System.runAs(orgAdminUser){
            Test.StartTest();
            ManageUserController.getHandleInvite(jsonString);
            Test.StopTest();
        }        
    }

     @isTest
     static void testGetManageCompletion(){
        User orgAdminUser = [SELECT Id,contact.accountId FROM User WHERE federationIdentifier =:emailId LIMIT 1];
        AccountContactRelation existingContact = [SELECT Id,accountId,contactId FROM AccountContactRelation WHERE Account.ParentId =:orgAdminUser.contact.accountId LIMIT 1];
		BusinessLicense getService = [SELECT Id from BusinessLicense WHERE AccountId =:existingContact.AccountId LIMIT 1];         
        String jsonString = '{"acrId": "'+existingContact.Id+'","isRemoveUser": false,"isUpdateUser": true,"relatedServices":  {"Star Rating Reviewer - Service":["'
            +getService.id+'"]},"providerRoles": [],"roles": [],"serviceRoles": ["Star Rating Reviewer - Service"]}';
        
        System.runAs(orgAdminUser){
            Test.StartTest();
            ManageUserController.getManageCompletion(jsonString);
            Test.StopTest();
        }        
    }
    @isTest
     static void testGetManageCompletion2(){
        User orgAdminUser = [SELECT Id,contact.accountId FROM User WHERE federationIdentifier =:emailId LIMIT 1];
        AccountContactRelation existingContact = [SELECT Id,accountId,contactId FROM AccountContactRelation WHERE Account.ParentId =:orgAdminUser.contact.accountId LIMIT 1];      
        String jsonString = '{"acrId": "'+existingContact.Id+'","isRemoveUser": true,"isUpdateUser": false,"relatedServices": [],"roles": [],"serviceRoles": []}';
        
        System.runAs(orgAdminUser){
            Test.StartTest();
            ManageUserController.getManageCompletion(jsonString);
            Test.StopTest();
        }        
    }
}