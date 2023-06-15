@isTest
public class TaskTriggerHandlerTest {

    @TestSetup
    static void setup() {
    
        Task t=TestDataFactory.createTask('NewTask');
        insert t;
        
        
        
        
    }
    @isTest
    public static void deleteTask() {
    	Boolean exceptionThrown = false;
	
        
        Task t=[select id from Task LIMIT 1];
        
        User usr=TestDataFactory.createSystemAdminUser();
        
        System.runAs(usr) {
        try {
            Test.startTest();
            delete t;
            Test.stopTest();
        } catch (Exception e) {
            exceptionThrown=true;
        	Boolean expectedExceptionThrown =  (e.getMessage().contains('Tasks cannot be deleted')) ? true : false; 
           System.AssertEquals(true, expectedExceptionThrown, e.getMessage()); 
        }
        System.assertEquals(true, exceptionThrown, 'No exception was thrown');
      
    	}
    }
    

}