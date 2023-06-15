@isTest
public class GPMSGetPermissionSetRecordTest {
    
    @isTest static void testGetPermissionSet() {
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap = new Map<String,Object>();
        Map<String,Object> options = new Map<String,Object>(); 
        
        User currentUser = TestDataFactory.createACQSCUser(); 
        
        System.runAs(currentUser)
        {
            Test.startTest();
            GPMSGetPermissionSetRecord getPermissionSetRec = new GPMSGetPermissionSetRecord();
            Boolean result = getPermissionSetRec.invokeMethod('GetPermissionSet',inputMap,outMap,options); 
            Test.stopTest();
            System.assertEquals(true, (Boolean)result);
        }
    }
    @isTest static void testGetPermissionSetTryCatch() {
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap = new Map<String,Object>();
        Map<String,Object> options = new Map<String,Object>(); 
        
        User currentUser = TestDataFactory.createACQSCUser(); 
        
        System.runAs(currentUser)
        {
            Test.startTest();
            GPMSGetPermissionSetRecord getPermissionSetRec = new GPMSGetPermissionSetRecord();
            Boolean result = getPermissionSetRec.invokeMethod('',inputMap,outMap,options); 
            Test.stopTest();
            System.assertEquals(false, (Boolean)result);
        }
    }        
}