global with sharing class UniqueAddressesController implements Callable{
    
    private Object invokeMethod(String action, Map<String, Object>input, Map<String, Object> output) {
            Map < String, Object > UIoptions = new Map < String, Object > ();
            AddressDetails addressInfo = new AddressDetails();
            if(input.get('poBoxType')!=null ){
                addressInfo.poBoxType = String.valueOf(input.get('poBoxType'));
            }
            else {
                addressInfo.poBoxType ='';
            }
            
            if(input.get('postOfficeBox')!=null){
                addressInfo.postOfficeBox = String.valueOf(input.get('postOfficeBox')).trim();
            }
            else {
                addressInfo.postOfficeBox = '';
            }
            
            if(input.get('unitNumber')!=null){
                addressInfo.unitNumber = String.valueOf(input.get('unitNumber')).trim();
            }
            else {
                addressInfo.unitNumber = '';
            }
            if(input.get('LevelNumber')!=null){
                addressInfo.LevelNumber = String.valueOf(input.get('LevelNumber')).trim();
            }
            else {
                addressInfo.LevelNumber = '';
            }
            if(input.get('buildingName')!=null){
                addressInfo.buildingName = String.valueOf(input.get('buildingName')).trim();
            }
            else {
                addressInfo.buildingName = '';
            }
            if(input.get('lotNumber')!=null){
                addressInfo.lotNumber = String.valueOf(input.get('lotNumber')).trim();
            }
            else {
				addressInfo.lotNumber = '';                
            }
            
            if(input.get('streetNumber1')!=null){
                addressInfo.streetNumber1 = String.valueOf(input.get('streetNumber1')).trim();
            }
            else {
                addressInfo.streetNumber1 = '';
            }
            if(input.get('street1')!=null){
                addressInfo.street1 = String.valueOf(input.get('street1')).trim();
            }
            else {
                addressInfo.street1 = '';
            }
            if(input.get('streetTypeDescription')!=null){
                addressInfo.streetTypeDescription = String.valueOf(input.get('streetTypeDescription')).trim();
            }
            else {
                addressInfo.streetTypeDescription = '';
            }
            if(input.get('streetSuffixTypeDescription')!=null){
                addressInfo.streetSuffixTypeDescription = String.valueOf(input.get('streetSuffixTypeDescription')).trim();
            }
            else {
                addressInfo.streetSuffixTypeDescription = '';
            }
            if(input.get('city')!=null){
                addressInfo.city = String.valueOf(input.get('city')).trim();
            }
            else {
				addressInfo.city = '';                
            }
            if(input.get('stateProvince')!=null){
                addressInfo.stateProvince = String.valueOf(input.get('stateProvince')).trim();
            }
            else {
                addressInfo.stateProvince = '';
            }
            if(input.get('zipPostalCode')!=null){
                addressInfo.zipPostalCode = String.valueOf(input.get('zipPostalCode')).trim();
            }
            else {
                addressInfo.zipPostalCode = '';
            }
            if(input.get('country')!=null){
                addressInfo.country = String.valueOf(input.get('country')).trim();
            }
            else {
                addressInfo.country = '';
            }
            if(input.get('latitude')!=null && String.valueOf(input.get('latitude'))!=''){
                addressInfo.latitude = String.valueOf(Math.floor(decimal.valueof(String.valueOf(input.get('latitude')))*100000)/100000);
            }
            else {
                addressInfo.latitude = '';
            }
            if(input.get('longitude')!=null && String.valueOf(input.get('longitude'))!=''){
                addressInfo.longitude = String.valueOf(Math.floor(decimal.valueof(String.valueOf(input.get('longitude')))*100000)/100000);
            }
            else {
                addressInfo.longitude = '';
            }
            string addressHash = concatAddress(addressInfo);
            string recordId;
            List<Address__c> existingAddress = [SELECT id FROM Address__c WHERE AddressUniqueKey__c =:addressHash LIMIT 1];
            for(Address__c iterAdd:existingAddress){
                recordId =iterAdd.id;
            }
            UIoptions.put('concatAddress',addressHash);
            UIoptions.put('recordId',recordId);
        	output.put('dupCheckResult',UIoptions);
        return true;
    }
    public static string concatAddress(AddressDetails addressInfo){
      	string concatAddress = addressInfo.poBoxType + ';' +
           					addressInfo.postOfficeBox + ';' +
           					addressInfo.unitNumber + ';' +
           					addressInfo.LevelNumber + ';' +
           					addressInfo.buildingName + ';' +
           					addressInfo.lotNumber + ';' +
           					addressInfo.streetNumber1 + ';' +
           					addressInfo.street1 + ';' +
           					addressInfo.streetTypeDescription + ';' +
           					addressInfo.streetSuffixTypeDescription + ';' +
           					addressInfo.city + ';' +
           					addressInfo.stateProvince + ';' +
           					addressInfo.zipPostalCode + ';' +
           					addressInfo.country + ';' +
           					addressInfo.latitude+';'+
           					addressInfo.longitude;
        system.debug(concatAddress);
        return concatAddress;
    }
	public class AddressDetails {
        public String poBoxType;
        public String postOfficeBox;
        public String unitNumber;  
        public String LevelNumber; 
        public String buildingName;
        public String lotNumber;  
        public String streetNumber1; 
        public String street1;
        public String streetTypeDescription;
        public String streetSuffixTypeDescription;
        public String city; 
        public String stateProvince; 
        public String zipPostalCode;
        public String country;
        public String latitude;
        public String longitude;
    }
    public Object call(String action, Map<String, Object> args){
        try {
            Map<String, Object> input = (Map<String, Object>)args.get('input');
            Map<String, Object> output = (Map<String, Object>)args.get('output');
            return invokeMethod(action, input, output);
        } catch (exception exp) {
            dohagedcare.Logger.error(exp.getMessage(),exp,'GPMS').Log();
            return true;
        }
    }
}