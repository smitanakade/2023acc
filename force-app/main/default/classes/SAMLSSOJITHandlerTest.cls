@isTest
public class SAMLSSOJITHandlerTest {
    @isTest
    static void testCreateUser() {
        Map<String,String> attributes = new Map < String, String > {
            'http://vanguard.ebusiness.gov.au/2008/06/identity/claims/abn' => '12345678978',
                'http://vanguard.ebusiness.gov.au/2008/06/identity/claims/givennames' => 'prospect cont FName',
                'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/surname' => 'prospect cont LName'
                };
                    User systemAdmin = TestDataFactory.createSystemAdminUser();
        String communityId = [SELECT id, Name FROM Network WHERE name=:'Service Provider Portal'].id;
        SAMLSSOJITHandler jitHandler = new SAMLSSOJITHandler();
        test.startTest();
        system.runAs(systemAdmin){
            jitHandler.createUser(null, communityId, null, 'jitHandlerUser30@gmail.com', attributes, null);
        }        
        test.stopTest();
    }  
}