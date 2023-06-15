@isTest
public class GPMSValidationTest {
    @testSetup
    static void testSetupMethod () {
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
    @isTest
    static void testValidABN() {
        User guestUser = [SELECT Id FROM User WHERE email =:'service_provider_portal@gpms.force.com' LIMIT 1];
        string testABN = '49096776895';
        List<string> input = new List<string>();
        input.add(testABN);
        Test.startTest();
        system.runAs(guestUser){
            list<String> testResult = GPMSValidation.validateABN(input);
            system.assertEquals('Ok', testResult[0]);
        }        
        Test.stopTest();
    }
    @isTest
    static void testInvalidABN() {
        User guestUser = [SELECT Id FROM User WHERE email =:'service_provider_portal@gpms.force.com' LIMIT 1];
        string testABN = '49096776894';
        List<string> input = new List<string>();
        input.add(testABN);
        Test.startTest();
        system.runAs(guestUser){
            list<String> testResult = GPMSValidation.validateABN(input);
            system.assertEquals('Invalid', testResult[0]);
        }
        Test.stopTest();
    }
    @isTest
    static void testInvalidABNLength() {
        User guestUser = [SELECT Id FROM User WHERE email =:'service_provider_portal@gpms.force.com' LIMIT 1];
        string testABN = '4909677689';
        List<string> input = new List<string>();
        input.add(testABN);
        Test.startTest();
        system.runAs(guestUser){
            list<String> testResult = GPMSValidation.validateABN(input);
            system.assertEquals('Invalid', testResult[0]);
        }
        Test.stopTest();
    }
}