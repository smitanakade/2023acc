@isTest
public without sharing class OrgSwitcherTest {
    public static final String emailId = 'TestClassUser_OrgAdmin@gmail.com';
    @TestSetup
    static void testSetupMethod (){
        User gpmsUser = TestDataFactory.createGPMSTestUser();
       System.runAs(gpmsUser) {
            Test.startTest();
           	TestDataFactory.manageUsersTestData(); 
           	Test.StopTest();
       }
    }
	@isTest
    static void testOrgSwitcher(){
        User orgAdmin = [SELECT Id,ContactId FROM User WHERE federationIdentifier =:emailId LIMIT 1];
        String acrId = [SELECT Id FROM AccountContactRelation WHERE contactId =:orgAdmin.ContactId LIMIT 1].Id;
        List<String> selectedAcrId = new List<String> {acrId};
        
        System.runAs(orgAdmin) {
            Test.StartTest();
            OrgSwitcher.handleOrgSwitch(selectedAcrId);
            Test.StopTest();
        }        
    }
}