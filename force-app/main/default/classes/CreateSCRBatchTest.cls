/**
 * author: Matthew WAll
 * date: 10/11/2022
 * description: Test class for CreateSCRBatch to process Regulatory Decisions
 **/
/* MODIFICATION LOG
 * Version       Developer                   Date                Description
 *-------------------------------------------------------------------------------------------
 *  1.0     		Matthew Wall               10-11-2022          Initial Creation
 *******************************************************************************************/
@isTest
public class CreateSCRBatchTest {
    public static final String THREE_STARS = '3 Star';
    public static final String TEST_REASON = 'Test Reason';
    public static final String DECISION_DETAILS = 'Decision Details';
    public static final Integer ONE = 1;

    @TestSetup
    static void makeData(){
        User testUser = TestDataFactory.createSystemAdminUser();

		Test.startTest();
		System.runAs(testUser) {
            List<Account> providers = TestDataFactory.createProviderRecords(1);
            
            insert providers;

            List<Care_Type__c> careTypeList = TestDataFactory.createSCRcareType(1, providers);
            insert careTypeList;

            List<BusinessLicense> testService = TestDataFactory.createServiceRecords(1);
            for (BusinessLicense service : testService) {
                service.RecordTypeId = Schema.SObjectType.BusinessLicense.getRecordTypeInfosByDeveloperName()
                    .get('Approved_Provider_Service')
                    .getRecordTypeId();
            }
            
            insert testService;

            List<Service_Account_Relationship__c> serviceAccounts = TestDataFactory.createServiceAccountRecords(1, testService, providers); 
            serviceAccounts[0].Association_Start_Date__c = Date.today().addDays(-150);
            insert serviceAccounts;

            List<RegulatoryCodeViolation> regDecisionList = new List<RegulatoryCodeViolation>();
            // Create current & published
            regDecisionList.add(new RegulatoryCodeViolation(Service_name_lookup__c = testService[0].Id, Service_Provider_Name__c = providers[0].Id, 
                                                            Service_Account_Relationship__c = serviceAccounts[0].Id, Status = 'Current', 
                                                            DateCreated = Datetime.now(), 
                                                            Published__c = true, Rating_Relevant__c = true, SCR_Rating__c = THREE_STARS, 
                                                            Decision_Details__c = DECISION_DETAILS,
                                                            Reason_for_issuing_Regulatory_Decision__c = TEST_REASON,
                                                            Service_Provider_Name_lookup__c =  providers[0].id,
                                                            Date_Decision_Applied__c = serviceAccounts[0].Association_Start_Date__c.addDays(10)));
            // Create Non-Current
            regDecisionList.add(new RegulatoryCodeViolation(Service_name_lookup__c = testService[0].Id, Service_Provider_Name__c = providers[0].Id, 
                                                            Service_Account_Relationship__c = serviceAccounts[0].Id, Status = 'Non-Current', 
                                                            DateCreated = Datetime.now(), 
                                                            Published__c = true, Rating_Relevant__c = true, SCR_Rating__c = THREE_STARS, 
                                                            Decision_Details__c = DECISION_DETAILS,
                                                            Reason_for_issuing_Regulatory_Decision__c = TEST_REASON,
                                                            Service_Provider_Name_lookup__c =  providers[0].id,
                                                            Date_Decision_Applied__c = serviceAccounts[0].Association_Start_Date__c.addDays(8)));
            // Create Archived
            regDecisionList.add(new RegulatoryCodeViolation(Service_name_lookup__c = testService[0].Id, Service_Provider_Name__c = providers[0].Id, 
                                                            Service_Account_Relationship__c = serviceAccounts[0].Id, Status = 'Non-Current', 
                                                            DateCreated = Datetime.now(), 
                                                            Published__c = true, Archived_Regulatory_Decision__c = true, SCR_Rating__c = THREE_STARS, 
                                                            Decision_Details__c = DECISION_DETAILS,
                                                            Reason_for_issuing_Regulatory_Decision__c = TEST_REASON,
                                                            Service_Provider_Name_lookup__c =  providers[0].id,
                                                            Date_Decision_Applied__c = serviceAccounts[0].Association_Start_Date__c.addDays(5)));
            insert regDecisionList;
        }
        Test.stopTest();
    }

    @IsTest
    static void createSCRTest() {
        User user = createTestUser();
        System.runAs(user) {
            // query records before
            List<Service_Compliance_History__c> schBefore = [SELECT Id FROM Service_Compliance_History__c];
            List<BusinessLicense> serviceListBefore = [SELECT Id, CountCurrentRegDec__c, CountArchRegDecision__c, NoOf_NonCurr_Rating_RegDecision__c
                                                        FROM BusinessLicense];
            // check pre asserts
            System.assertEquals(0, schBefore.size(), 'Expected 0 Compliance History');

            Test.startTest();
            CreateSCRBatch myBatchObject = new CreateSCRBatch(); 
            Database.executeBatch(myBatchObject);
            Test.stopTest();
            // query post batch records
            List<Service_Compliance_History__c> schAfter = [SELECT Id FROM Service_Compliance_History__c];
            List<Service_Compliance_Detail__c> scdAfter = [SELECT Id, Name FROM Service_Compliance_Detail__c];
            List<BusinessLicense> serviceListAfter = [SELECT Id, CountCurrentRegDec__c, CountArchRegDecision__c, NoOf_NonCurr_Rating_RegDecision__c
                                                        FROM BusinessLicense];
            List<Service_Account_Relationship__c> sarAfter = [SELECT Id, CountCurrentRegDec__c, CurrentNonCurrentRegDec__c, CountArchRegDecision__c, Active__c
                                                                FROM Service_Account_Relationship__c];
            // check post asserts
            System.assertEquals(1, schAfter.size(), 'Expected 1 Compliance History');
            System.assertEquals(3, scdAfter.size(), 'Expected 3 Compliance Detail');
            System.assertEquals(1, serviceListAfter[0].CountCurrentRegDec__c, 'Value must be 1');
            System.assertEquals(1, serviceListAfter[0].CountArchRegDecision__c, 'Value must be 1');
            System.assertEquals(1, serviceListAfter[0].NoOf_NonCurr_Rating_RegDecision__c, 'Value must be 1');
            System.assertEquals(1, sarAfter[0].CountCurrentRegDec__c, 'Value must be 1');
            System.assertEquals(1, sarAfter[0].CountArchRegDecision__c, 'Value must be 1');
            System.assertEquals(1, sarAfter[0].CurrentNonCurrentRegDec__c, 'Value must be 1');
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