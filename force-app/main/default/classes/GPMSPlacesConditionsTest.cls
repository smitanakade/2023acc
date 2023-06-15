/****************************************************************************************************
* @CreatedBy   : Accenture Developer Team
* @CreatedDate : 03-29-2023
* @Description : Test class for GPMSPlacesConditions
* @Test Class  : GPMSPlacesConditionsTest
*****************************************************************************************************/
@isTest
public class GPMSPlacesConditionsTest {
    
    private static User currentUser = TestDataFactory.createGPMSTestUser();

    @isTest
    static void testUpdateEventConditionIP() {

        System.runAs(currentUser){

            BusinessLicense service = new BusinessLicense(Name = 'TestService', Status = 'Operational');
            service.recordTypeId = Schema.SObjectType.BusinessLicense.getRecordTypeInfosByDeveloperName().get('CHSP_Service').getRecordTypeId();
            insert service;

            Allotment__c allotment = GPMSTestUtility.getAllotment('Approved_Provider_Residential_ALM',service.Id);
            insert Allotment;

            Event__c evt = GPMSTestUtility.getPlaceEvent('Variations_by_Provider_Secretary');
            insert evt;

            AllotmentConditions__c oldCondition = new AllotmentConditions__c(Allotment__c = Allotment.Id, GPMS_Event__c = evt.Id);
            insert oldCondition;

            Map<String,Object> inputMap = new Map<String,Object>();
            Map<String,Object> outMap = new Map<String,Object>();
            Map<String,Object> options = new Map<String,Object>();


            inputMap.put('NewAllotmentConditionId', oldCondition.Id);

            Map<String, Object> args = new Map<String, Object>();
            args.put('input', inputMap);
            args.put('output', outMap);
            args.put('options', options);

            Test.startTest();

            GPMSPlacesConditions performAction = new GPMSPlacesConditions();
            performAction.call('processBringOnlineEvents',args);

            inputMap.put('AllotmentConditionId', oldCondition.Id);
            performAction.call('processBringOnlineEvents',args);

            Test.stopTest();

            AllotmentConditions__c condition = [SELECT GPMS_Condition_Status__c FROM AllotmentConditions__c WHERE Id = :oldCondition.Id];
            System.assertEquals('Non-current', condition.GPMS_Condition_Status__c);
        }

    }

}