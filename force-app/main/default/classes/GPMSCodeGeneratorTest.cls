@isTest
public class GPMSCodeGeneratorTest {
    @testSetup
    static void testSetupMethod () {
        Profile guestUserProfile = [SELECT Id FROM profile WHERE name =: 'Service Provider Portal Profile' LIMIT 1];
        User guestUser = new User();
        guestUser.FirstName = 'guest User01';
        guestUser.LastName = 'last name';
        guestUser.Email = Label.TestClassEmail;
        guestUser.Username = Label.TestClassEmail;
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
    static void testGenerateCode() {
        integer lenght = 6;
        list<Integer> lengthList = new List<Integer>();
        lengthList.add(lenght);
        User guestUser = [SELECT Id FROM User WHERE email =:Label.TestClassEmail LIMIT 1];
        Test.startTest();
        system.runAs(guestUser){
            List<String> generatedCode = GPMSCodeGenerator.verifyCode(lengthList);
        	system.assertEquals(lenght, generatedCode[0].length());
        }
        Test.stopTest();
    }
    @isTest
    static void testCodeGenFailed() {
        integer lenght = 15;
        list<Integer> lengthList = new List<Integer>();
        lengthList.add(lenght);
        User guestUser = [SELECT Id FROM User WHERE email =:Label.TestClassEmail LIMIT 1];
        Test.startTest();
        system.runAs(guestUser){
            List<String> generatedCode = GPMSCodeGenerator.verifyCode(lengthList);
        	system.assertEquals('Error', generatedCode[0]);
        }
        Test.stopTest();
    }
}