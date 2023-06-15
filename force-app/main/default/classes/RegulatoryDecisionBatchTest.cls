@isTest
public with sharing class RegulatoryDecisionBatchTest {
    public static String NonCurrentStatus='Non-Current';
    @TestSetup
    static void makeData() {
       User adminUser = TestDataFactory.insertNewSysAdmin();
        System.runAs(adminUser) {
            
            List<Account> providerList = TestDataFactory.createProviderRecords(1);
            insert providerList;
            
            List<Care_Type__c> careTypeListRecords = TestDataFactory.createSCRcareType(1, providerList);
            insert careTypeListRecords;
            
            List<BusinessLicense> testService = TestDataFactory.createSCRServiceRecords(1,'TestService1', providerList, 0, 0,0 );
            
            testService.get(0).RecordTypeId = Schema.SObjectType.BusinessLicense.getRecordTypeInfosByDeveloperName().get('Approved_Provider_Service').getRecordTypeId();
            testService.get(0).Name = 'Test JC';
            testService.get(0).Care_Type__c = 'Residential';
            testService.get(0).Status__c = 'Operational';
            testService.get(0).AccountId = providerList[0].Id;
            insert testService;
            
            Test.getEventBus().deliver();
            
            List<ViolationType> violationTypeList = TestDataFactory.createQIViolationType(1);
            insert violationTypeList;
            
            
            List<Service_Account_Relationship__c> sarList = TestDataFactory.createServiceAccountRecords(1, testService, providerList);
            insert sarList;
            
            List<RegulatoryCodeViolation> regDecisionList = TestDataFactory.createQIRegulatoryCodeViolation(1, testService, providerList, violationTypeList, sarList);
            regDecisionList[0].published__c = false;
            regDecisionList[0].Status = 'Current';
            insert regDecisionList;  
            
        }
   
    }
    
    @isTest
    public static void testRegulatoryDecisionBatch_status_to_non_current() {
        List<RegulatoryCodeViolation> regDecisions = [SELECT Id, Date_Decision_Ends__c, Status, Published__c, Current_Date__c,
                                                    Archived_Regulatory_Decision__c, Rating_Relevant__c, 
                                                    Service_Compliance_Rating_Effect__c  FROM RegulatoryCodeViolation];
        regDecisions[0].Date_Decision_Ends__c=Date.today()-5;
        regDecisions[0].Status='Current';
        regDecisions[0].published__c=true;
        update regDecisions[0];
        Test.startTest();
        Database.executeBatch(new RegulatoryDecisionBatch(), 10);
        Test.stopTest();                                            
        List<RegulatoryCodeViolation> afterBatchRunRegDecisions = [SELECT Id, Date_Decision_Ends__c, Status, Published__c, Current_Date__c,
        Archived_Regulatory_Decision__c, Rating_Relevant__c, 
        Service_Compliance_Rating_Effect__c  FROM RegulatoryCodeViolation];
        System.assertEquals(afterBatchRunRegDecisions[0].Rating_Relevant__c, true);
        System.assertEquals(afterBatchRunRegDecisions[0].Status, NonCurrentStatus);  
    }
    @isTest
    public static void testRegulatoryDecisionBatch_Archived_Regulatory_Decision() {
        
        Integer dateDecisionEnd1=(Integer) STARRating_Settings__mdt.getInstance('Status_Change_Dates').Days_after_Date_Decision_Ends_1__c;
        List<RegulatoryCodeViolation> regDecisions = [SELECT Id, Date_Decision_Ends__c, Status, Published__c, Current_Date__c,
                                                    Archived_Regulatory_Decision__c, Rating_Relevant__c, 
                                                    Service_Compliance_Rating_Effect__c  FROM RegulatoryCodeViolation];
        regDecisions[0].Date_Decision_Ends__c=Date.today()-dateDecisionEnd1;
        regDecisions[0].Date_Decision_Applied__c=Date.today()-dateDecisionEnd1;
        regDecisions[0].Archived_Regulatory_Decision__c=false;
        regDecisions[0].Status= NonCurrentStatus;
        regDecisions[0].Rating_Relevant__c=true;
        update regDecisions[0];
        Test.startTest();
        Database.executeBatch(new RegulatoryDecisionBatch(), 10);
        Test.stopTest();                                            
        List<RegulatoryCodeViolation> afterBatchRunRegDecisions = [SELECT Id, Date_Decision_Ends__c, Status, Published__c, Current_Date__c,
        Archived_Regulatory_Decision__c, Rating_Relevant__c, 
        Service_Compliance_Rating_Effect__c  FROM RegulatoryCodeViolation];
        System.assertEquals(afterBatchRunRegDecisions[0].Archived_Regulatory_Decision__c, true);
       
    }
    @isTest
    public static void testRegulatoryDecisionBatch_Historic_Archived() {
        Integer dateDecisionEnd2=(Integer) STARRating_Settings__mdt.getInstance('Status_Change_Dates').Days_after_Date_Decision_Ends_2__c;
        
        List<RegulatoryCodeViolation> regDecisions = [SELECT Id, Date_Decision_Ends__c, Status, Published__c, Current_Date__c,
                                                    Archived_Regulatory_Decision__c, Rating_Relevant__c, 
                                                    Service_Compliance_Rating_Effect__c  FROM RegulatoryCodeViolation];
        regDecisions[0].Date_Decision_Ends__c=Date.today()-(dateDecisionEnd2+5);
        regDecisions[0].Date_Decision_Applied__c=Date.today()-(dateDecisionEnd2+5);
        regDecisions[0].Archived_Regulatory_Decision__c=true;
        regDecisions[0].Status=NonCurrentStatus;
        update regDecisions[0];
        Test.startTest();
        Database.executeBatch(new RegulatoryDecisionBatch(), 10);
        Test.stopTest();                                            
        List<RegulatoryCodeViolation> afterBatchRunRegDecisions = [SELECT Id, Date_Decision_Ends__c, Status, Published__c, Current_Date__c,
        Archived_Regulatory_Decision__c, Rating_Relevant__c, 
        Service_Compliance_Rating_Effect__c  FROM RegulatoryCodeViolation];
        System.assertEquals(afterBatchRunRegDecisions[0].Archived_Regulatory_Decision__c, false);
       
    }

}