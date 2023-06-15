@isTest
public class GPMSPortalManageUserControllerTest {
    @TestSetup
    static void makeData(){
        User testUser = TestDataFactory.createSystemAdminUser();
        Test.startTest();
        System.runAs(testUser){
            Account newAPAccount = new Account();
            newAPAccount.Name = 'Apex class test account for UserInfo';
            newAPAccount.GPMS_ProspectivePortalACO__c  = true;
            newAPAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Approved_Provider').getRecordTypeId();
            insert newAPAccount;

            Contact newPortalContact = new Contact();
            newPortalContact.Salutation = 'Mr';
            newPortalContact.FirstName = 'testcontactnumber135662313';
            newPortalContact.LastName = 'testcontactnumber135662313LN';
            newPortalContact.AccountId = newAPAccount.Id;
            newPortalContact.Email = 'testUser123452332@rubbbbbbgmail.com';
            newPortalContact.GPMS_myGov_Vanguard_Id__c = 'testUser1234532';
            newPortalContact.Self_Registration_Status__c = 'Not Verified';
            insert newPortalContact;

            Account newAPAccount2 = new Account();
            newAPAccount2.Name = 'Apex class test account for UserInfo2';
            newAPAccount2.GPMS_ProspectivePortalACO__c  = true;
            newAPAccount2.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Approved_Provider').getRecordTypeId();
            insert newAPAccount2;

            Contact newPortalContact2 = new Contact();
            newPortalContact2.Salutation = 'Mr';
            newPortalContact2.FirstName = 'testcontactnumber13534234662313';
            newPortalContact2.LastName = 'testcontactnumber1356423462313LN';
            newPortalContact2.AccountId = newAPAccount2.Id;
            newPortalContact2.Email = 'testUser1234542342332@rubbbbbbgmail.com';
            newPortalContact2.GPMS_myGov_Vanguard_Id__c = 'testUser1234542342332@rubbbbbbgmail.com';
            insert newPortalContact2;

            AccountContactRelation acr = [SELECT Id,GPMS_Portal_Role__c FROM AccountContactRelation WHERE contactId =:newPortalContact.Id AND AccountId =: newAPAccount.Id];
            acr.GPMS_Portal_Role__c = 'Organisation Administrator';
            acr.EndDate = null;
            update acr;

            Profile orgAdminProfile = [SELECT Id FROM profile WHERE name =: 'Provider User' LIMIT 1];

            User orgAdminUser = new User();
            orgAdminUser.FirstName = newPortalContact.FirstName;
            orgAdminUser.LastName = newPortalContact.LastName;
            orgAdminUser.Email = newPortalContact.Email;
            orgAdminUser.Username = newPortalContact.GPMS_myGov_Vanguard_Id__c+'_'+newPortalContact.Email;
            orgAdminUser.federationIdentifier = newPortalContact.GPMS_myGov_Vanguard_Id__c;
            orgAdminUser.ProfileId = orgAdminProfile.Id;
            orgAdminUser.TimeZoneSidKey = 'Australia/Sydney';
            orgAdminUser.LocaleSidKey = 'en_AU';
            orgAdminUser.LanguageLocaleKey = 'en_US';
            orgAdminUser.EmailEncodingKey = 'UTF-8';
            orgAdminUser.ContactId = newPortalContact.Id;
            orgAdminUser.IsActive = TRUE;
            orgAdminUser.Alias = newPortalContact.FirstName.left(1) + newPortalContact.LastName.left(4);
            orgAdminUser.CommunityNickname = orgAdminUser.Alias +'_'+ orgAdminUser.federationIdentifier;
            insert orgAdminUser;
        }
        Test.stopTest();
    }

    @isTest
    static void getPicklistOptionsTest() {
        User user = [SELECT Id FROM User WHERE Username = 'testUser1234532_testUser123452332@rubbbbbbgmail.com' LIMIT 1];
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Organization_Administrator' LIMIT 1];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps.Id);

        Test.startTest();
        System.runAs(user) {
            Map<String, List<Object>> picklistOptions = GPMSPortalManageUserController.getPicklistOptions();
            System.assertEquals(true, (Boolean)picklistOptions.get('success')[0]);
            System.assertEquals(1, picklistOptions.get('organisationOptions').size());
        }
        Test.stopTest();
    }



    @isTest
    static void inviteExistingContactTest() {
        User user = [SELECT Id FROM User WHERE Username = 'testUser1234532_testUser123452332@rubbbbbbgmail.com' LIMIT 1];
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Organization_Administrator' LIMIT 1];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps.Id);

        Test.startTest();
        System.runAs(user) {
            Map<String, List<Object>> picklistOptions = GPMSPortalManageUserController.getPicklistOptions();
            List<GPMSPortalManageUserController.PicklistWrapper> roleOptions = (List<GPMSPortalManageUserController.PicklistWrapper>) picklistOptions.get('roleOptions');
            List<GPMSPortalManageUserController.PicklistWrapper> organisationOptions = (List<GPMSPortalManageUserController.PicklistWrapper>) picklistOptions.get('organisationOptions');

            String inputJson = '{"userEmail":"testUser1234542342332@rubbbbbbgmail.com","contactType":"'+ roleOptions[0].value + '","organisation":"' + organisationOptions[0].value + '"}';
            Map<String,Object> inviteUser = GPMSPortalManageUserController.inviteUser(inputJson);
            System.assertEquals(true, inviteUser.get('success'));
        }
        Test.stopTest();
    }

    @isTest
    static void inviteNewContactTest() {
        User user = [SELECT Id FROM User WHERE Username = 'testUser1234532_testUser123452332@rubbbbbbgmail.com' LIMIT 1];
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Organization_Administrator' LIMIT 1];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps.Id);

        Test.startTest();
        System.runAs(user) {
            Map<String, List<Object>> picklistOptions = GPMSPortalManageUserController.getPicklistOptions();
            List<GPMSPortalManageUserController.PicklistWrapper> roleOptions = (List<GPMSPortalManageUserController.PicklistWrapper>) picklistOptions.get('roleOptions');
            List<GPMSPortalManageUserController.PicklistWrapper> organisationOptions = (List<GPMSPortalManageUserController.PicklistWrapper>) picklistOptions.get('organisationOptions');
            List<GPMSPortalManageUserController.PicklistWrapper> salutationOptions = (List<GPMSPortalManageUserController.PicklistWrapper>) picklistOptions.get('salutationOptions');
            String inputJson = '{"userEmail":"testUser12345423432332@gmail.com","contactType":"'+ roleOptions[0].value + '", "organisation":"' + organisationOptions[0].value + '"}';
            Map<String,Object> inviteUser = GPMSPortalManageUserController.inviteUser(inputJson);
            System.assertEquals(true, inviteUser.get('success'));
            GPMSPortalManageUserController.userInfoWrapper wrapper = (GPMSPortalManageUserController.userInfoWrapper) inviteUser.get('wrapper');
            System.assertEquals(false, wrapper.userExists);

            inputJson = '{"userEmail":"testUser12345423432332@gmail.com","contactType":"'+ roleOptions[0].value + '" ,"organisation":"' + organisationOptions[0].value + '"';
            inputJson = inputJson + ',"firstName":"Test","lastName":"User1","dateOfBirth":"2000-10-10","salutation":"'+ salutationOptions[0].value + '"}';
            inviteUser = GPMSPortalManageUserController.inviteUser(inputJson);
            System.assertEquals(true, inviteUser.get('success'));
            System.assertNotEquals(null, inviteUser.get('contactId'));
        }
        Test.stopTest();
    }
}
