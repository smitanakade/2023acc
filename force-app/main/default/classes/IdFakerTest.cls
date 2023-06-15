/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-28-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@IsTest(isParallel=true)
private class IdFakerTest {
    @IsTest
    static void testGenerateFor() {
        System.runAs(new User(Id=UserInfo.getUserId())) {
            Test.startTest();
            Id accountId = IdFaker.generateFor(Account.getSObjectType());
            System.assertNotEquals(null, accountId, 'expected an Id, got: ' + accountId);
            Test.stopTest();
        }
    }
}