@isTest
public class FeedCommentTriggerHandlerTest {

    @TestSetup
    static void setup() {
    
        Task t=TestDataFactory.createTask('TestSubject');
        insert t;
        
        FeedItem fitem=TestDataFactory.createFeedItem(t.id,'TestBody');
        insert fitem;
        
        FeedComment fc=TestDataFactory.createFeedComment(fitem.id,'Test Comment');
        insert fc;
        

        
        
    }
    @isTest
    private static void deleteComment() {
    	Boolean exceptionThrown = false;
        User healthUser=TestDataFactory.createSystemAdminUser();
        
   
            
        FeedComment fc=[select id from FeedComment LIMIT 1];
             System.runAs(healthUser) {
        try {
            Test.startTest();
            delete fc;
            Test.stopTest();
        } catch (Exception e) {
            exceptionThrown=true;
        	Boolean expectedExceptionThrown =  (e.getMessage().contains('Comments cannot be deleted')) ? true : false; 
            System.AssertEquals(true, expectedExceptionThrown, e.getMessage()); 
        }
        System.assertEquals(true, exceptionThrown, 'No exception was thrown');
      
    }
    }
    
}