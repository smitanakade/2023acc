@IsTest
public with sharing class ServiceAccountRelationshipTriggerTest {
    
    
    private static User currentUser = TestDataFactory.createSystemAdminUser();
    
    @testSetup static void setup() {
        
        System.runAs(currentUser){
            
            Integer recordCount = 1;
            
            // create services
            List<BusinessLicense> services = TestDataFactory.createServiceRecords(recordCount);
            insert services;
            // create providers
            List<Account> providers = TestDataFactory.createProviderRecords(recordCount);
            insert providers;
            // create sar
            List<Service_Account_Relationship__c> sar = TestDataFactory.createServiceAccountRecords(recordCount, services, providers);
            insert sar;
        }
    }
    
    @isTest 
    public static void testServiceAccountRelationshipTriggerAfterInsert(){
        List<Service_Account_Relationship__c> sar = [SELECT Id FROM Service_Account_Relationship__c];
        // Ensures service account relationship records were created.
        System.assertNotEquals(sar.size(), 0, 'SAR list should not be empty');
    }
    
    @isTest 
    public static void testServiceAccountRelationshipTriggerAfterUpdate(){
        
        System.runAs(currentUser){
            
            Test.startTest();
            
            List<Service_Account_Relationship__c> sar = [SELECT Id, Association_Start_Date__c FROM Service_Account_Relationship__c];
            for (Service_Account_Relationship__c sarRec : sar) {
                sarRec.Association_Start_Date__c = Date.valueOf('2022-09-27');
            }
            update sar;
            
            // Ensures sar record were updated and handled in the after update trigger
            for (Service_Account_Relationship__c sarRec : sar) {
                System.assertEquals(Date.valueOf('2022-09-27'), sarRec.Association_Start_Date__c, 'Star date must be 2022-09-27');
            }
            Test.stopTest();
        }
    }
}