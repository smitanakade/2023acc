@isTest
private class FA2SFCreateCasesTest {
    @testSetup
    static void setup() {
        User testUser = TestDataFactory.createSystemAdminUser();
        System.runAs(testUser){
        List<Account> accounts = new List<Account>();
        
           Id accountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Approved_Provider').getRecordTypeId();
        
        // insert 10 accounts
        for (Integer i=0;i<10;i++) {
            accounts.add(new Account(Name='Account '+i,
            Integration_Id__c = 'Account '+i + datetime.now(),
                RecordTYpeId = accountRecTypeId
  ));
        }
        insert accounts;

    }
    }
    @isTest static void test() {
        Test.startTest();
        FA2SFCreateCases myBatchObject = new FA2SFCreateCases();
          Database.executeBatch(myBatchObject);
        Test.stopTest();
        // after the testing stops, assert records were updated properly
        System.assertEquals(10, [select count() from Case where Case_DM_Key__c <> null], 'The Case record count was not 10 as expected');
    }
}