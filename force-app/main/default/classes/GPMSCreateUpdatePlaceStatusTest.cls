@IsTest
public class GPMSCreateUpdatePlaceStatusTest {
    
    private static User currentUser = [SELECT Id From User WHERE Id = :UserInfo.getUserId()];
    
    @testSetup static void setup() {
        
        BusinessLicense serviceToInsert = GPMSTestUtility.getServiceByRecordType('Approved_Provider_Service');
        insert serviceToInsert;
        
        Allotment__c Allotment = GPMSTestUtility.getAllotment('Approved_Provider_Residential_ALM',serviceToInsert.Id);
        insert Allotment;

        Integer placesCount = 5;
        List<Places_Allotment__c> places = GPMSTestUtility.getPlaces(placesCount,Allotment.Id);
        insert places;
        
        Event__c evt = GPMSTestUtility.getPlaceEvent('Variations_by_Provider_Secretary');
        insert evt;
                
    }
    
    @isTest static void testGPMSCreatePlaces() {
        
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap = new Map<String,Object>();
        Map<String,Object> options = new Map<String,Object>();
        
        Event__c evt = [SELECT Id FROM Event__c LIMIT 1];
        Allotment__c Allotment = [SELECT Id FROM Allotment__c LIMIT 1];
        Places_Allotment__c place = [SELECT Id FROM Places_Allotment__c LIMIT 1];
        
        List<Map<String,Object>> places = new List<Map<String,Object>>();
        places.add(formatOmniPlace(place.Id));
        places.add(formatOmniPlace(place.Id));
        
        inputMap.put('Places', places);
        inputMap.put('AllotmentId', Allotment.Id);
        inputMap.put('EventId', evt.Id);
        inputMap.put('UpdateParentPacket', 'Yes');
        
        Map<String, Object> args = new Map<String, Object>();
        args.put('input', inputMap);
        args.put('output', outMap);
        args.put('options', options);
        
        GPMSCreateUpdatePlaceStatus getplaces = new GPMSCreateUpdatePlaceStatus();
        Object result = getplaces.call('getplaces',args);
        System.assertEquals(true, (Boolean)result,'Upsert places failed');
    }
    
    private static Map<String,Object> formatOmniPlace(String placeId){
        
        Map<String,Object> placeMAP = new Map<String,Object>();
        
        placeMAP.put('CareLevel', 'Residential');
        placeMAP.put('CareSetting', 'Residential');
        placeMAP.put('CareType', 'Flexible-MPS');
        placeMAP.put('NumberOfChanges', '3');
        placeMAP.put('Id', placeId);
       	return placeMAP;
        
    }

}