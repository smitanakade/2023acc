/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-14-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class GPMSScheduledUpdateCHSPServiceBatchTest {
    @testSetup static void setup() 
    {             
       User gpmsUser = TestDataFactory.createGPMSTestUser();
       System.runAs(gpmsUser)
       {
           Test.startTest();
           Account chspProvider = new Account(Name = 'ProviderA',Incorporation_ID_Type__c='Other');
           chspProvider.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Commonwealth_Home_Support_Programme').getRecordTypeId();
           Insert chspProvider;
           
           CHSP_Service_Schedule__c chspSchDetA = new CHSP_Service_Schedule__c(Organisation_Name__c = chspProvider.Id,Contract_End_Date__c = System.today());
           insert chspSchDetA;
           CHSP_Service_Schedule__c chspSchDetB = new CHSP_Service_Schedule__c(Organisation_Name__c = chspProvider.Id,Contract_End_Date__c = System.today());
           insert chspSchDetB;
           
           Account aco = new Account(Name = 'ACO',Incorporation_ID_Type__c='Not Incorporated');
           aco.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Aged_Care_Organisation').getRecordTypeId();
           Insert aco;
            
           Account_Relationship__c acoRole = new Account_Relationship__c(Account_From_Id__c = aco.Id,Account_To_Id__c = chspProvider.Id,Association_End_Date__c = System.today() + 1);
           acoRole.recordTypeId = Schema.SObjectType.Account_Relationship__c.getRecordTypeInfosByDeveloperName().get('ACO_to_Account').getRecordTypeId();
           insert acoRole;  
                   
           BusinessLicense service = new BusinessLicense(Name = 'CHSP Service',AccountId = chspProvider.Id);
           service.recordTypeId = Schema.SObjectType.BusinessLicense.getRecordTypeInfosByDeveloperName().get('CHSP_Service').getRecordTypeId();
           service.Status_Date__c =  Date.today();
           insert service;
                    
           Service_with_CHSP_Schedule_Detail__c serviceCHSPSchDetA = new Service_with_CHSP_Schedule_Detail__c(Service__c = service.Id,CHSP_Schedule_Detail__c = chspSchDetA.Id);
           insert serviceCHSPSchDetA;
           Service_with_CHSP_Schedule_Detail__c serviceCHSPSchDetB = new Service_with_CHSP_Schedule_Detail__c(Service__c = service.Id,CHSP_Schedule_Detail__c = chspSchDetB.Id);
           insert serviceCHSPSchDetB;
           Test.stopTest();
       }
    }
    static testmethod void testGPMSScheduledBatch_UpdateCHSPService()
    {
        User gpmsUser = TestDataFactory.createGPMSTestUser();
        System.runAs(gpmsUser)
        {
            Test.startTest();
            GPMSScheduledUpdateCHSPServiceBatch serviceStatusUpdateBatch =  new GPMSScheduledUpdateCHSPServiceBatch();
            Database.executeBatch(serviceStatusUpdateBatch,2);   
            Test.stopTest();
        }
        
        BusinessLicense serviceAfterUpdate = [SELECT Id,Status__c FROM BusinessLicense limit 1]; 
        
        system.assertEquals('Inactive',serviceAfterUpdate.Status__c);        
    }
    static testmethod void testGPMSScheduledBatch_UpdateCHSPServiceManualExecution()
    {
        List<CHSP_Service_Schedule__c> chspSchDetList = [SELECT Id,Contract_End_Date__c FROM CHSP_Service_Schedule__c limit 2];
        User gpmsUser = TestDataFactory.createGPMSTestUser();
        System.runAs(gpmsUser)
        {
            Test.startTest();
            Set<Id> recIdSet = new Set<Id>{chspSchDetList[0].Id,chspSchDetList[1].Id};
            GPMSScheduledUpdateCHSPServiceBatch.executeByIds(recIdSet,2); 
            Test.stopTest();
        }
        
        BusinessLicense serviceAfterUpdate = [SELECT Id,Status__c FROM BusinessLicense limit 1]; 
                
        system.assertEquals('Inactive',serviceAfterUpdate.Status__c);        
    }

}