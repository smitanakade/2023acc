@istest
public class GPMSUserInfoControllerTest {
    public static final String emailId = 'TestClassUser_OrgAdmin@gmail.com';
    @TestSetup
    static void testSetupMethod (){
        User gpmsUser = TestDataFactory.createGPMSTestUser();
        System.runAs(gpmsUser) {
            Test.startTest();
            TestDataFactory.manageUsersTestData();
            User orgAdmin = [SELECT Id,ContactId FROM User WHERE federationIdentifier =:emailId LIMIT 1]; 
            TestDataFactory.creatPSA(orgAdmin.id);
            Test.StopTest();
        }
    }
	@isTest
    static void testOrgSwitcher(){
        User orgAdmin = [SELECT Id,ContactId FROM User WHERE federationIdentifier =:emailId LIMIT 1];        
        System.runAs(orgAdmin) {
            Test.StartTest();
            GPMSUserInfoController.getUserInfo();
            Test.StopTest();
        }        
    }
    @isTest
    static void testGetUserPermission(){
        User orgAdmin = [SELECT Id,ContactId FROM User WHERE federationIdentifier =:emailId LIMIT 1]; 
            System.runAs(orgAdmin) {
            Test.StartTest();
            GPMSUserInfoController.getUserPermission();
            Test.StopTest();
        }        
    }
}