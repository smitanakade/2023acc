@isTest
public class GPMSUpdateAdminLiquidatorFlagBatchTest {
    @TestSetup
    static void setup() 
    { 
       User gpmsUser = TestDataFactory.createGPMSTestUser();
       System.runAs(gpmsUser)
       {
           Test.startTest();
           Account aco = new Account(Name = 'ACO',Incorporation_ID_Type__c='Not Incorporated');
           aco.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Aged_Care_Organisation').getRecordTypeId();
           Insert aco;
           
           Account approvedProviderA = new Account(Name = 'Approved Provider A',Incorporation_ID_Type__c='Other',Purpose__c='Private for Profit');
           approvedProviderA.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Approved_Provider').getRecordTypeId();
           Insert approvedProviderA;
            
           Account approvedProviderB = new Account(Name = 'Approved Provider B',Incorporation_ID_Type__c='Other',Purpose__c='Private for Profit');
           approvedProviderB.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Approved_Provider').getRecordTypeId();
           Insert approvedProviderB;
            
           Account_Relationship__c acoToProviderA = new Account_Relationship__c(Account_From_Id__c = aco.Id,Account_To_Id__c = approvedProviderA.Id);
           acoToProviderA.recordTypeId = Schema.SObjectType.Account_Relationship__c.getRecordTypeInfosByDeveloperName().get('ACO_to_Account').getRecordTypeId();
           insert acoToProviderA;
           
           Account_Relationship__c acoToProviderB = new Account_Relationship__c(Account_From_Id__c = aco.Id,Account_To_Id__c = approvedProviderB.Id);
           acoToProviderB.recordTypeId = Schema.SObjectType.Account_Relationship__c.getRecordTypeInfosByDeveloperName().get('ACO_to_Account').getRecordTypeId();
           insert acoToProviderB;       
        
           Contact_Relationship__c adminLiquidator = new Contact_Relationship__c(Account__c = approvedProviderA.Id);
           adminLiquidator.recordTypeId = Schema.SObjectType.Contact_Relationship__c.getRecordTypeInfosByDeveloperName().get('Administrator_Liquidator_CR').getRecordTypeId();
           insert adminLiquidator;
           
           adminLiquidator.End_Date__c = System.today()-1;
           adminLiquidator.Effect_on_Suitability__c = 'Some effect on Suitaible';
           update adminLiquidator;  
            
           approvedProviderA.Administrator_Liquidator_Record_Exists__c = true;
           update approvedProviderA; 
            
           aco.Administrator_Liquidator_Record_Exists__c = true;
           update aco; 
           Test.stopTest();
       }
    }
    static testmethod void testGPMSUpdateAdminLiquidatorFlagBatch()
    {
        User gpmsUser = TestDataFactory.createGPMSTestUser();
        System.runAs(gpmsUser)
        {
            Test.startTest();
            GPMSUpdateAdminLiquidatorFlagBatch adminLiquidatorFlagUpdateBatch = new GPMSUpdateAdminLiquidatorFlagBatch();
            Database.executeBatch(adminLiquidatorFlagUpdateBatch,1);   
            Test.stopTest();
        }       
        
    }
    static testmethod void testGPMSUpdateAdminLiquidatorFlagBatchManualExecution()
    {
        Contact_Relationship__c cr = [select Id,End_Date__c,Account__c,RecordType.Name,
                                      Administrator_Liquidator_Record_Exists__c 
                                      from Contact_Relationship__c Limit 1];        
             
        User gpmsUser = TestDataFactory.createGPMSTestUser();
        System.runAs(gpmsUser)
        {
            Test.startTest();
            Set<Id> recIdSet = new Set<Id>{cr.Id};
            GPMSUpdateAdminLiquidatorFlagBatch.executeByIds(recIdSet,1); 
            Test.stopTest();
        }       
        
    }
}