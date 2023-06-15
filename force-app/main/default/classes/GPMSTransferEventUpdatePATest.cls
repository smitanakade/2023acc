/****************************************************************************************************
* @CreatedBy   : Namrata Gurjar
* @CreatedDate : 03-02-2023
* @Description : Test class for GPMSTransferEventUpdatePA
* @Test Class  : GPMSTransferEventUpdatePATest
*****************************************************************************************************/
@isTest
private class GPMSTransferEventUpdatePATest {
    
    public static final String TEST_SERVICE = 'Squad C Residential Care Testing';
    
    private static User currentUser = TestDataFactory.createGPMSTestUser();
    
    @isTest
    static void testUpdateTransferEventsPA() {
        
        System.runAs(currentUser){
            
            BusinessLicense service = new BusinessLicense(Name = TEST_SERVICE, Status = 'Operational'); 
            service.recordTypeId = Schema.SObjectType.BusinessLicense.getRecordTypeInfosByDeveloperName().get('CHSP_Service').getRecordTypeId();
            service.Status_Date__c =  Date.today();
            insert service;
            
            Allotment__c allotment = GPMSTestUtility.getAllotment('Approved_Provider_Residential_ALM',service.Id);
            insert Allotment;
            
            Event__c evt = GPMSTestUtility.getPlaceEvent('Variations_by_Provider_Secretary');
            evt.Status__c = 'Transfer: Not to be Activated';
            insert evt;
            
            Integer placesCount = 5;
            List<Places_Allotment__c> places = GPMSTestUtility.getPlaces(placesCount,Allotment.Id);
            for (Places_Allotment__c pa : places) {
                pa.Status_of_Places__c = 'Provisional';
                pa.Event__c = evt.Id;
            }
            insert places;
            
            List<Places_Allotment__c> childPlaces = GPMSTestUtility.getPlaces(placesCount,Allotment.Id);
            for (Places_Allotment__c pa : childPlaces) {
                pa.Current__c = 'Pending';
                pa.Parent_Packet__c = places.get(0).Id;
                pa.Event__c = evt.Id;
            }
            insert childPlaces;
            
            Map<String,Object> inputMap = new Map<String,Object>();
            Map<String,Object> outMap = new Map<String,Object>();
            Map<String,Object> options = new Map<String,Object>();
            

            inputMap.put('EventId', evt.Id);
            
            Map<String, Object> args = new Map<String, Object>();
            args.put('input', inputMap);
            args.put('output', outMap);
            args.put('options', options);
            
            Test.startTest();
            
            GPMSTransferEventUpdatePA updatePA = new GPMSTransferEventUpdatePA();
            updatePA.call('processTranferEvents',args);
            
            Test.stopTest();
            
            Event__c evtResult = [SELECT Batch_Event_Completed__c FROM Event__c WHERE Id = :evt.Id];
            System.assertEquals(true, evtResult.Batch_Event_Completed__c);
        }
    }

  }