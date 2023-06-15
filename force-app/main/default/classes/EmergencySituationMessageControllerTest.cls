@IsTest
public class EmergencySituationMessageControllerTest {

    @IsTest
    static void testEmergencySituationMessageController() {
        User adminUser = TestDataFactory.createSystemAdminUser();
        Test.startTest();
        System.runAs(adminUser) {
        	GPMS_Emergency_Situation__c esRecord = new GPMS_Emergency_Situation__c();
            esRecord.Emergency_Situation_Status__c = 'Declared';
            esRecord.Emergency_Situation_Type__c = 'Disaster';
            esRecord.Start_Date__c = Date.newInstance(2022, 11, 01);
            esRecord.End_Date__c = Date.newInstance(2022, 11, 07);
            insert esRecord;
            ApexPages.StandardController sc = new ApexPages.StandardController(esRecord);
            
            EmergencySituationMessageController controller = new EmergencySituationMessageController(sc);
            System.assertNotEquals(null, controller.customDelete(), 'PageReference should not be null.');
            
            Integer numRecords = (Integer) [SELECT COUNT(Id) num
                                  FROM GPMS_Emergency_Situation__c
                                  WHERE Id = :esRecord.Id][0].get('num');
            System.assertEquals(0, numRecords, 'Record should be deleted.');    
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testDMLException() {
        User adminUser = TestDataFactory.createSystemAdminUser();
        Test.startTest();
        System.runAs(adminUser) {
            GPMS_Emergency_Situation__c esRecord = new GPMS_Emergency_Situation__c();
            esRecord.Emergency_Situation_Status__c = 'Declared';
            esRecord.Emergency_Situation_Type__c = 'Disaster';
            esRecord.Start_Date__c = Date.newInstance(2022, 11, 01);
            esRecord.End_Date__c = Date.newInstance(2022, 11, 07);
            
            // Record not inserted
            ApexPages.StandardController sc = new ApexPages.StandardController(esRecord);
            
            EmergencySituationMessageController controller = new EmergencySituationMessageController(sc);
            System.assertEquals(null, controller.customDelete(), 'PageReference should be null due to exception thrown.'); 
        }
        Test.stopTest();
    }
}