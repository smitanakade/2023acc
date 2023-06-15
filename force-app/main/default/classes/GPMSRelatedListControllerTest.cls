@IsTest
public class GPMSRelatedListControllerTest {
    
    static void setup() {
        
        List<Account> accToInsert = new List<Account>();
        
        //ACO Information
        Account aco = new Account(Name = 'ACO',Incorporation_ID_Type__c='Not Incorporated',Prospective_Provider__c='');
        aco.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Aged_Care_Organisation').getRecordTypeId();
        accToInsert.add(aco);
        
        //Provider Information
        Account provider = new Account(Name = 'Provider',Incorporation_ID_Type__c='Taken to be Incorporated',Prospective_Provider__c='');
        provider.Purpose__c = 'Government';
        provider.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Approved_Provider').getRecordTypeId();
        accToInsert.add(provider);
        insert accToInsert;
        
        //Relationship Informaiton
        Account_Relationship__c ar = new Account_Relationship__c();
        ar.Account_From_Id__c = aco.Id;
        ar.Account_To_Id__c = provider.Id;
        ar.recordTypeId = Schema.SObjectType.Account_Relationship__c.getRecordTypeInfosByDeveloperName().get('ACO_to_Account').getRecordTypeId();
        insert ar;
    }
    
    @isTest static void testGetRelatedListInfo() {
        User gpmsUser = TestDataFactory.createGPMSTestUser();
        System.runAs(gpmsUser)
        {
            Test.startTest();
            setup();
        
        Account aco = [SELECT Id FROM Account WHERE Name = 'ACO' limit 1];
        
        String relatedListName = '';
        String targetObject = 'Account_Relationship__c';
        String targetField = 'Account_From_Id__c';
        String recordId = aco.Id;
        String condition = '';
        Integer count = 3;
        
        GPMSRelatedListController.RelatedList result = GPMSRelatedListController.getRelatedListInfo(relatedListName, targetObject, targetField, recordId, condition, count);
        GPMSRelatedListController.RelatedList error = GPMSRelatedListController.getRelatedListInfo(relatedListName, targetObject, targetField, '123', condition, count);
        System.assertEquals(1, result.recordCount);
        
        GPMSRelatedListController.getAllRelatedRecords(result, getFields(), targetObject, targetField, recordId, condition, count);
        System.assertEquals(1, result.recordCount);
        
        String resultButtonURL = GPMSRelatedListController.generateNewButtonURL('ACO to Account', targetObject, targetField, recordId);
        String resultButtonURLError = GPMSRelatedListController.generateNewButtonURL(null, targetObject, targetField, recordId);
        
        String newbuttonURL = '/lightning/o/' + targetObject + '/new?recordTypeId=';
        string rtId = [SELECT id FROM RecordType WHERE Name = 'ACO to Account' AND SobjectType = :targetObject].Id;
        newbuttonURL = newbuttonURL + rtId + '&defaultFieldValues=' + targetField + '=' + recordId;
        
        System.assertEquals(newbuttonURL, resultButtonURL);
        Test.stopTest();
        }
    }
    
    @isTest static void testGetReportURL() {
        User gpmsUser = TestDataFactory.createGPMSTestUser();
        System.runAs(gpmsUser)
        {
            Test.startTest();
            setup();
        Account testAccount = [SELECT Id FROM Account limit 1];
        String resultButtonURL = GPMSRelatedListController.generateReportURL('Key_Personnel_History', 'Account', testAccount.Id);
        String resultButtonURLError = GPMSRelatedListController.generateReportURL('Key_Personnel_History', 'Account', null);
        Test.stopTest();
        System.assertEquals(false, String.isNotBlank(resultButtonURL));
        }
    }
    
    private static List<Related_List_Setting__mdt> getFields(){
        String metadateString = '[{"Field_Api__c":"Account_To_Id__c","LookUp_Field__c":true,"Target_Field__c":"Account_To_Id__c",'
            + '"MasterLabel":"Account To","DeveloperName":"TestAccountTo","IsOrder__c":true,"Sort_ASC__c":true}]';
        List<Related_List_Setting__mdt> fields  = (List<Related_List_Setting__mdt>) JSON.deserialize( metadateString, List<Related_List_Setting__mdt>.class );
        return fields;
    }
    
    

}