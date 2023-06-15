@isTest
public class PortalAccessNotificationControllerTest {    
    @isTest
    static void checkACOUpdate(){               
        User gpmsUser = TestDataFactory.createGPMSTestUser();
        PortalAccessNotificationController.ACRRoles role  = new PortalAccessNotificationController.ACRRoles();
        role.currentACRRoles = 'Organisation Administrator;QI Role - Org';
        role.PreviousACRRoles = 'Organisation Administrator';
        List<PortalAccessNotificationController.ACRRoles> roles = new List<PortalAccessNotificationController.ACRRoles>();
        roles.add(role);
        
        System.runAs(gpmsUser){
            Test.StartTest();
            List<PortalAccessNotificationController.Result> result = PortalAccessNotificationController.checkACOUpdate(roles);
            system.assertEquals(true,result[0].success);
            Test.StopTest();
        }        
    }
}