public with sharing class GPMSStreetStringFormat implements Callable{
    
    public static final String[] state_List = new String[]{'NSW','WA','VIC','NT','ACT','OT','QLD','SA','TAS'};
    
    public Object call(String action, Map<String, Object> args) {
        Map<String, Object> input = (Map<String, Object>)args.get('input');
        Map<String, Object> output = (Map<String, Object>)args.get('output');
        Map<String, Object> options = (Map<String, Object>)args.get('options');
        return invokeMethod(action, input, output, options);
    }
    
    private Object invokeMethod(String action, Map<String, Object>inputMap, Map<String, Object> outputMap, Map<String, Object> options) {
        if (action == 'replace'){
            String typeAdd = '';
            if(String.isNotBlank((String) inputMap.get('type'))) typeAdd = '_'+(String) inputMap.get('type');
            if(inputMap.get('arguments') == null) return null;
            List < Map < String, String >> result = new List < Map < String,String >> ();
            if(inputMap.get('arguments') instanceof List<Object>){
                List<Object> arguments = (List<Object>)inputMap.get('arguments');
                for(object add : arguments){
                    String address = (String)add;
                    Map < String, String > temp = addAddress(address,typeAdd);
                    if(temp != null) result.add(temp);
                }
            }else{
                result.add(addAddress((String)inputMap.get('arguments'),typeAdd));
            }
            
            outputMap.put('result',result);
        }
        return true;
    }
    
    public static Map < String, String > addAddress(String address,String typeAdd){
        
        Map < String, String > tempMap = new Map < String, String > ();
        
        List<String> addressList = address.split(',');
        
        String lastString = addressList[addressList.size()-1].trim();
        
        if(lastString.trim().isNumeric() && addressList.size()>1){
            
            //Scenario 2: LAST SPOT is a POSTCODE
            tempMap.put('PostcodeDisplay'+typeAdd,lastString.trim());
            tempMap.put('StateDisplay'+typeAdd,addressList[addressList.size()-2].trim());
            
            List<String> Street_List = new List<String>();
            Integer lengthTmp = 2;
            
            if(addressList.size() > 4){
                //Has Major City
                tempMap.put('MajorCityDisplay'+typeAdd,addressList[addressList.size()-3].trim());
                tempMap.put('CityDisplay'+typeAdd,addressList[addressList.size()-4].trim());
                lengthTmp = 4;
            }else if(addressList.size() == 4){
                tempMap.put('CityDisplay'+typeAdd,addressList[addressList.size()-3].trim());
                lengthTmp = 3;
            }
            
            for(Integer i = 0; i<addressList.size()-lengthTmp; i++){
                Street_List.add(addressList[i]);
            }
            
            tempMap.put('StreetDisplay'+typeAdd,String.join(Street_List,','));
        }else if(state_List.contains(lastString) && addressList.size()>1){
            
            //Scenario 2: LAST SPOT is a STATE
            tempMap.put('StateDisplay'+typeAdd,lastString.trim());
            
            List<String> Street_List = new List<String>();
            for(Integer i = 0; i<addressList.size()-1; i++){
                Street_List.add(addressList[i]);
            }
            
            tempMap.put('StreetDisplay'+typeAdd,String.join(Street_List,','));
        }else{
            
            //Default Return
            tempMap.put('StreetDisplay'+typeAdd,address);
        }
        
        //Update OT State to NSW
        if(tempMap.get('StateDisplay'+typeAdd) == 'OT') tempMap.put('StateDisplay'+typeAdd,'NSW');
        tempMap.put('AddressDisplay'+typeAdd,address);
        
        return tempMap;
    }
}