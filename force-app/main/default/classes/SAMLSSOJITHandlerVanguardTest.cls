@isTest
public class SAMLSSOJITHandlerVanguardTest {
    @testSetup
    static void jitTestSetup() {
        User testUser = TestDataFactory.createSystemAdminUser();

        Test.startTest();
        System.runAs(testUser){
            final String fedId = 'jitHandlerUser30@gmail.com';
            Account newAPAccount = new Account();
            newAPAccount.Name = 'Dummy Shell Account';
            newAPAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Approved_Provider').getRecordTypeId();
            insert newAPAccount;
            Contact newPortalContact = new Contact();
            newPortalContact.Salutation = 'Mr';
            newPortalContact.FirstName = 'new portal contact';
            newPortalContact.LastName = 'Last Name';
            newPortalContact.AccountId = newAPAccount.Id;
            newPortalContact.Email = fedId;
            newPortalContact.GPMS_myGov_Vanguard_Id__c = fedId;
            newPortalContact.GPMS_Portal_Role__c = 'Organisation Administrator';
            newPortalContact.Self_Registration_Status__c = 'Not Verified';
            insert newPortalContact;

            final String email = 'service_provider_portal@gpms.force.com';
            Profile guestUserProfile = [SELECT Id FROM profile WHERE name =: 'Service Provider Portal Profile' LIMIT 1];
            User guestUser = new User();
            guestUser.FirstName = 'guest User01';
            guestUser.LastName = 'last name';
            guestUser.Email = email;
            guestUser.Username = email;
            guestUser.ProfileId = guestUserProfile.Id;
            guestUser.TimeZoneSidKey = 'Australia/Sydney';
            guestUser.LocaleSidKey = 'en_AU';
            guestUser.LanguageLocaleKey = 'en_US';
            guestUser.EmailEncodingKey = 'UTF-8';
            guestUser.IsActive = TRUE;
            guestUser.Alias = 'guest01';
            insert(guestUser);
        }
        Test.stopTest();
    }
    @isTest
    static void testCreateUser() {
        User guestUser = [SELECT Id FROM User WHERE email =:'service_provider_portal@gpms.force.com' LIMIT 1];
        Map<String,String> attributes = new Map < String, String > {
            'http://vanguard.ebusiness.gov.au/2008/06/identity/claims/abn' => '12345678978',
                'http://vanguard.ebusiness.gov.au/2008/06/identity/claims/givennames' => 'prospect cont FName',
                'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/surname' => 'prospect cont LName'
                };
        SAMLSSOJITHandlerVanguard jitHandler = new SAMLSSOJITHandlerVanguard();
        test.startTest();
        system.runAs(guestUser){
            jitHandler.createUser(null, null, null, 'jitHandlerUser30@gmail.com', attributes, null);
        }
        test.stopTest();
    }
}
