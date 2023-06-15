@isTest
public class DisableTaskModificationsBatchTest {

    @TestSetup
    static void setup() {
    
        Id  taskRecordTypeId=Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Communication_Task').getRecordTypeId();
        
        Task one=TestDataFactory.createTask('NewTask');
        one.Status='Completed';
        one.Locked__c=false;
        one.RecordTypeId=TaskRecordTypeId;
        insert one;
        
        Task two=TestDataFactory.createTask('NewTask2');
        two.Status='Open';
        two.Locked__c=false;
        insert two;
        
                
        Task three=TestDataFactory.createTask('NewTask3');
        three.Status='Open';
        three.Locked__c=false;
        three.RecordTypeId=TaskRecordTypeId;
        insert three;
        
    }
    @isTest
    private static void testBatch() {
            Id  taskRecordTypeId=Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Communication_Task').getRecordTypeId();
        
            User usr=TestDataFactory.createSystemAdminUser();
            Test.startTest();
    
            System.runAs(usr){
			Database.executeBatch(new DisableTaskModificationsBatch());
			}
			
            Test.stopTest();
        	for(Task t:[select id,locked__c,recordtypeId,Status from task]) {
                if(t.recordtypeId==taskRecordTypeId && t.Status=='Completed'){
                   System.assertEquals(true, t.locked__c); 
                }
                else
                {
                    System.assertEquals(false, t.locked__c);
                }
        	}
          
           }
        
        
	
}