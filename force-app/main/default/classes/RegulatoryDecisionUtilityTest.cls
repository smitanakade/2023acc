/* 
    * Regulatory Decision Utility Test
    * Tests for RegulatoryDecisionUtility
    * Author: Matthew Wall
    * Date: 5/10/22
*/
@IsTest
public with sharing class RegulatoryDecisionUtilityTest {
    @TestSetup
    static void makeData() {
        User testUser = TestDataFactory.createSystemAdminUser();

		Test.startTest();
		System.runAs(testUser){
            List<Account> providers = TestDataFactory.createProviderRecords(1);
            insert providers;
            List<BusinessLicense> testService = TestDataFactory.createServiceRecords(1);
            testService[0].Care_Type__c = 'Residential';
            testService[0].RecordTypeId = Schema.SObjectType.BusinessLicense.getRecordTypeInfosByDeveloperName()
                    .get('Approved_Provider_Service')
                    .getRecordTypeId();
            insert testService;
            List<Service_Account_Relationship__c> serviceAccounts = TestDataFactory.createServiceAccountRecords(1, testService, providers);
            insert serviceAccounts;
            List<RegulatoryCodeViolation> regDecisionList = new List<RegulatoryCodeViolation>();
            regDecisionList.add(new RegulatoryCodeViolation(Service_name_lookup__c = testService[0].Id, Service_Provider_Name__c = providers[0].Id, 
                                                            Service_Account_Relationship__c = serviceAccounts[0].Id, Status = 'Current', 
                                                            DateCreated = Datetime.now(), 
                                                            Published__c = true, Rating_Relevant__c = true, SCR_Rating__c = '3 Star', 
                                                            Decision_Details__c = 'Decision Details',
                                                        Reason_for_issuing_Regulatory_Decision__c = 'Test Reason',
                                                        Service_Provider_Name_lookup__c =  providers[0].id));
            insert regDecisionList;
        }
        Test.stopTest();
    }
    @isTest
    static void testRegDecCount() {
        User user = createTestUser();
        System.runAs(user) {
            List<RegulatoryCodeViolation> regDecisionList = [SELECT Id, Name, Status, Service_Name_lookup__c,  
                                                            Service_Provider_Name_lookup__c, 
                                                            Published__c, SCR_Rating__c, Rating_Relevant__c,
                                                            Service_Compliance_Rating__c, Archived_Regulatory_Decision__c,
                                                            Service_Account_Relationship__c, Service_Compliance_Rating_Effect__c
                                                            FROM RegulatoryCodeViolation];
            Test.startTest();
            RegulatoryDecisionUtility.getCurrentDecisionCount(regDecisionList);
            Test.stopTest();

        }
    }
    @isTest
    static void testSetRegDecCount() {
        User user = createTestUser();
        System.runAs(user) {
            Set<Id> serviceAccountIds = new Set<Id>();
            List<Service_Account_Relationship__c> serviceAccountRelationship = [SELECT Id FROM Service_Account_Relationship__c];
            for (Service_Account_Relationship__c sar : serviceAccountRelationship) {
                serviceAccountIds.add(sar.Id);
            }
            
            Map<Id,RegulatoryCodeViolation> regDecMap = new Map<Id,RegulatoryCodeViolation>([SELECT Id, Name, Status, Service_Name_lookup__c,  
                                                                                            Service_Provider_Name_lookup__c, 
                                                                                            Published__c, SCR_Rating__c, Rating_Relevant__c,
                                                                                            Service_Compliance_Rating__c, Archived_Regulatory_Decision__c,
                                                                                            Service_Account_Relationship__c, Service_Compliance_Rating_Effect__c
                                                                                            FROM RegulatoryCodeViolation]);
            Test.startTest();
            RegulatoryDecisionUtility.setRegDecCount(serviceAccountIds, regDecMap);
            Test.stopTest();
            List<BusinessLicense> services = [SELECT Id, CountCurrentRegDec__c FROM BusinessLicense];
            System.assertEquals(1, services[0].CountCurrentRegDec__c, 'Count on service must be one');
            List<Service_Account_Relationship__c> sarList = [SELECT Id, CountCurrentRegDec__c FROM Service_Account_Relationship__c];
            System.assertEquals(1, sarList[0].CountCurrentRegDec__c, 'Count on Serivce Account Rel must be one');
        }
    }
    @isTest
    static void testUpdateNonCurrentCount() {
        User user = createTestUser();
        System.runAs(user) {
            Set<Id> serviceAccountIds = new Set<Id>();
            List<Service_Account_Relationship__c> serviceAccountRelationship = [SELECT Id FROM Service_Account_Relationship__c];
            for (Service_Account_Relationship__c sar : serviceAccountRelationship) {
                serviceAccountIds.add(sar.Id);
            }
            
            Map<Id,RegulatoryCodeViolation> regDecMap = new Map<Id,RegulatoryCodeViolation>([SELECT Id, Name, Status, Service_Name_lookup__c,  
                                                                                            Service_Provider_Name_lookup__c, 
                                                                                            Published__c, SCR_Rating__c, Rating_Relevant__c,
                                                                                            Service_Compliance_Rating__c, Archived_Regulatory_Decision__c,
                                                                                            Service_Account_Relationship__c, Service_Compliance_Rating_Effect__c
                                                                                            FROM RegulatoryCodeViolation]);
            regDecMap.values()[0].Rating_Relevant__c = true;
            regDecMap.values()[0].Status = RegulatoryDecisionUtility.NON_CURRENT_STATUS;
            regDecMap.values()[0].Date_Decision_Ends__c = Date.today();
            update regDecMap.values();
            Test.startTest();
            RegulatoryDecisionUtility.updateNonCurrentCount(serviceAccountIds, regDecMap);
            Test.stopTest();
            List<Service_Account_Relationship__c> sarList = [SELECT Id, CurrentNonCurrentRegDec__c FROM Service_Account_Relationship__c];
            System.assertEquals(1, sarList[0].CurrentNonCurrentRegDec__c, 'Expected count of 1 ');
        }
    }
    @isTest
    static void testConvertDate(){
        Test.startTest();
        Date d = RegulatoryDecisionUtility.convertDate(System.today());
        Test.stopTest();
        System.assertNotEquals(null, d, 'Date expected');

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