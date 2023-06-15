/****************************************************************************************************
* @CreatedBy   : Lavanya Uddarraju
* @CreatedDate : 24-Oct-2022
* @Description : Handles the Logic to check if duplicate service name exists 
                 when new service is created
* @Test Class  : GPMSGetServicesTest
*****************************************************************************************************/
global class GPMSGetServices implements omnistudio.VlocityOpenInterface {
    public Boolean invokeMethod (String methodName, Map<String,Object> input, Map<String,Object> output, Map<String,Object> options) {
        if (methodName.equalsIgnoreCase('GetSeviceNames')) { 
            String serviceName = (String)input.get('serviceName');
            List<BusinessLicense> serviceList = [select Id, Name, Physical_Address_Location__c from BusinessLicense
                                                 where Name = :serviceName];
            if(!serviceList.isEmpty()) {
               output.put('serviceName', serviceList[0].Name);
               return true;
            }
            else {
                return false;
            }
        }
        else {
            return false;
        }
    }
}