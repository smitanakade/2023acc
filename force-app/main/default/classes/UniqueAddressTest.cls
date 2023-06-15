@isTest
public class UniqueAddressTest {    
    @isTest
    static void testCall (){
        Map<String, Object> args = new Map<String, Object>();
        Map<String, Object> input = new Map<String, Object> {
            'poBoxType'=>'',
            'postOfficeBox'=>'',
            'unitNumber'=>'',
            'LevelNumber'=>'',
            'buildingName'=>'',
            'lotNumber'=>'',
            'streetNumber1'=>'',
            'streetNumber2'=>'',
            'street1'=>'',
            'street2'=>'',
            'streetTypeDescription'=>'',
            'streetSuffixTypeDescription'=>'',
            'city'=>'',
            'stateProvince'=>'',
            'zipPostalCode'=>'',
            'country'=>'',
            'latitude'=>145.67512,
            'longitude'=>-37.328421
        };
            
        User gpmsUser = TestDataFactory.createGPMSTestUser();
        args.put('input',input);
        UniqueAddressesController checkAddress = new UniqueAddressesController();
        System.runAs(gpmsUser){
            Test.StartTest();
            checkAddress.call('', args);
            Test.StopTest();
        }    
            
            
    }
    @isTest
    static void testCallNull (){
        User gpmsUser = TestDataFactory.createGPMSTestUser();
        Map<String, Object> args = new Map<String, Object>();
        Map<String, Object> input = new Map<String, Object>();
            args.put('input',input);
            UniqueAddressesController checkAddress = new UniqueAddressesController();
        System.runAs(gpmsUser){
            Test.StartTest();
            checkAddress.call('', args);
            Test.StopTest();
        } 
    }
    @isTest
    static void testTrigger (){
        User gpmsUser = TestDataFactory.createGPMSTestUser();
        Address__c addressToInsert = new Address__c();
        System.runAs(gpmsUser){
            Test.StartTest();
            insert addressToInsert;
        	addressToInsert.Unit_Number__c = '3';
        	update addressToInsert;
            Test.StopTest();
        } 
        
        
    }

}