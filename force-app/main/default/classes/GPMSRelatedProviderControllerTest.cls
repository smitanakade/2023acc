@isTest
public class GPMSRelatedProviderControllerTest {
    
    private static User currentUser = TestDataFactory.createGPMSTestUser();
    
    @testSetup static void setup() {
        
        System.runAs(currentUser){
            
            List<Account> accToInsert = new List<Account>();
            Account aco = new Account(Name = 'ACO',Incorporation_ID_Type__c='Not Incorporated',Prospective_Provider__c='');
            aco.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Aged_Care_Organisation').getRecordTypeId();
            accToInsert.add(aco);
            Account provider = new Account(Name = 'Provider',Incorporation_ID_Type__c='Taken to be Incorporated',Prospective_Provider__c='');
            provider.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Approved_Provider').getRecordTypeId();
            provider.Purpose__c = 'Government';
            accToInsert.add(provider);
            insert accToInsert;
            
            provider = [SELECT Id FROM Account WHERE Name = 'Provider' limit 1];
            aco = [SELECT Id FROM Account WHERE Name = 'ACO' limit 1];
            
            Account_Relationship__c ar = new Account_Relationship__c();
            ar.Account_From_Id__c = aco.Id;
            ar.Account_To_Id__c = provider.Id;
            ar.recordTypeId = Schema.SObjectType.Account_Relationship__c.getRecordTypeInfosByDeveloperName().get('ACO_to_Account').getRecordTypeId();
            insert ar;
            
            ACO_Group__c acogroup = new ACO_Group__c();
            acogroup.Name = 'Test';
            insert acogroup;
            
            ACO_Group_Member__c member = new ACO_Group_Member__c();
            member.ACO_Group_Name__c = acogroup.Id;
            member.ACOs_to_link__c = aco.Id;
            insert member;
        }
        
    }
    
    @isTest static void testGPMSFetchAcoGrpMember() {
        
        Account_Relationship__c ar = [SELECT Id,Account_From_Id__c,Account_To_Id__c FROM Account_Relationship__c  limit 1];
        System.debug(ar);
        
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap = new Map<String,Object>();
        Map<String,Object> options = new Map<String,Object>();
        
        inputMap.put('AccountId',ar.Account_To_Id__c);
        
        GPMSRelatedProviderController getGroupList = new GPMSRelatedProviderController();
        Boolean result = getGroupList.invokeMethod('fetchAcoGrpMember',inputMap,outMap,options);
        
        System.assertEquals(true, result);
        
    }
    
    @isTest static void testGPMSFetchSingleAcoGrpMember() {
        
        ACO_Group__c acoGroup = [SELECT Id FROM ACO_Group__c limit 1];
        
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap = new Map<String,Object>();
        Map<String,Object> options = new Map<String,Object>();
        
        inputMap.put('AccountId',acoGroup.Id);
        
        GPMSRelatedProviderController getGroupList = new GPMSRelatedProviderController();
        Boolean result = getGroupList.invokeMethod('fetchSingleAcoGrpMember',inputMap,outMap,options);
        
        System.assertEquals(true, result);
        
    }
    
    @isTest static void testGPMSFetchAcoGrp() {
        
        Account_Relationship__c ar = [SELECT Id,Account_From_Id__c,Account_To_Id__c FROM Account_Relationship__c  limit 1];
        System.debug(ar);
        
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap = new Map<String,Object>();
        Map<String,Object> options = new Map<String,Object>();
        
        inputMap.put('AccountId',ar.Account_To_Id__c);
        
        GPMSRelatedProviderController getGroupList = new GPMSRelatedProviderController();
        Boolean result = getGroupList.invokeMethod('fetchAcoGrp',inputMap,outMap,options);
        
        System.assertEquals(true, result);
        
    }
    
}