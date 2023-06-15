@IsTest
public class GPMSGetServicesTest {
    @testSetup static void setup() {
       BusinessLicense service = new BusinessLicense(Name = 'Aegis Care Service');
       service.recordTypeId = Schema.SObjectType.BusinessLicense.getRecordTypeInfosByDeveloperName().get('CHSP_Service').getRecordTypeId();
       service.Status_Date__c =  Date.today();
       insert service;
    }
    @isTest static void testGPMSGetServices() {
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap = new Map<String,Object>();
        Map<String,Object> options = new Map<String,Object>();
        
        GPMSGetServices getServices = new GPMSGetServices();
        
        inputMap.put('serviceName','Aegis Care Service');
        inputMap.put('methodName','GetSeviceNames');
        Object services = getServices.invokeMethod('GetSeviceNames',inputMap,outMap,options);
        System.assertEquals(true, (Boolean)services, 'Duplicate Service Name Exists');
    }
}