@isTest
public class GPMSCareTypesPicklistTest {
    @testSetup static void setup() {
        Aged_Care_Planning_Region__c acpr = new Aged_Care_Planning_Region__c();
        acpr.ACPR_State__c = 'NSW';
        acpr.Name = 'test ACPR';
        insert acpr;
        
        SA2__c sa2 = new SA2__c();
        sa2.Aged_Care_Planning_Region__c = acpr.id;
        sa2.Name = 'test SA2';
        insert sa2;
    }
    @isTest static void testSelectRegion() {
        Map<String,Object> inputMap = new map<String,Object>();
        inputMap.put('state','NSW');
        Map<String,Object> output = new Map<String,Object>();
        Map<String,Object> options = new Map<String,Object>();
        GPMSCareTypesPicklist acprPickList = new GPMSCareTypesPicklist();
        Boolean result = acprPickList.invokeMethod('SelectRegion',inputMap,output,options); 
        System.assertEquals(true, (Boolean)result,'Get Region Table failed');
    }
    @isTest static void testSelectLocation() {
        list<string> acprId = new list<string>();
        for(Aged_Care_Planning_Region__c getAcpr : [select id from Aged_Care_Planning_Region__c where name =:'test ACPR']){
            acprId.add(getAcpr.Id);
        }
        Map<string,object> inputMap = new map<string,Object>();
        inputMap.put('acprId',acprId);
        Map<String,Object> output = new Map<String,Object>();
        Map<String,Object> options = new Map<String,Object>();
        GPMSCareTypesPicklist acprPickList = new GPMSCareTypesPicklist();
        Boolean result = acprPickList.invokeMethod('SelectLocation',inputMap,output,options);
        System.assertEquals(true, (Boolean)result,'Get Location Table failed');
    }
    @isTest static void testACPRSA2Table() {
        List<String> acprId = new List<String>();
        List<String> SA2Id = new List<String>();
        List<Aged_Care_Planning_Region__c> getAcpr = [select id from Aged_Care_Planning_Region__c where name =:'test ACPR'];
        for(Aged_Care_Planning_Region__c itrAcpr:getAcpr){
            acprId.add(itrAcpr.Id);
        }
        for(SA2__c getSA2 : [select id from SA2__c where Aged_Care_Planning_Region__c in:acprId]){
            SA2Id.add(getSA2.Id);
        }
        Map<String,Object> inputMap = new Map<String,Object>();
        inputMap.put('selectedACPR',acprId);
        inputMap.put('selectedSA2',SA2Id);
        inputMap.put('selectedSA2_ACPR',SA2Id);
        
        Map<String,Object> output = new Map<String,Object>();
        Map<String,Object> options = new Map<String,Object>();
        GPMSCareTypesPicklist acprPickList = new GPMSCareTypesPicklist();
        Boolean result = acprPickList.invokeMethod('ACPRSA2Table',inputMap,output,options);
        System.assertEquals(true, (Boolean)result,'Get SA2 Table failed');
    }
}