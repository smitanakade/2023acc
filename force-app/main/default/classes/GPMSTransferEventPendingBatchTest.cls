@isTest
public class GPMSTransferEventPendingBatchTest {
    @TestSetup
    static void makeData(){
        Event__c event = new Event__c(Status__c = 'Pending', GPMS_Proposed_Transfer_Date__c = Date.today());
        insert event;
    }




    @isTest
    static void testBatch(){
        User user = createTestUser();
        System.runAs(user) {           
            Test.startTest();
            GPMSTransferEventPendingBatch batch = new GPMSTransferEventPendingBatch(); 
            Database.executeBatch(batch);
            Test.stopTest();
            Event__c event = [SELECT Id, Status__c,  Status_Date__c FROM Event__c WHERE GPMS_Proposed_Transfer_Date__c <= TODAY AND Status__c = 'Automatic Transfer: Pending Activation'];
            System.assertEquals(event.Status_Date__c, Date.today());
        }
    }

    public static User createTestUser() {
        Profile prof = [SELECT Id, Name FROM Profile WHERE Name LIKE 'System Administrator'];
        User user = new User();
        user.firstName = 'test1';
        user.lastName = 'test2';
        user.ProfileId = prof.Id;
        user.Username = 'tester1@unittest.com';
        user.email = 'test@test.com';
        user.Alias = 'tst';
        user.TimeZoneSidKey = 'Australia/Sydney';
        user.LocaleSidKey = 'en_AU'; 
        user.EmailEncodingKey = 'UTF-8'; 
        user.LanguageLocaleKey = 'en_US';
        insert user;
        return user;
    }
}