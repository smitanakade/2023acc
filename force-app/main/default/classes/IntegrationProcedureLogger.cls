/**
* author: Daniel Clift
* date: 14/11/2022
* description: Handle integration procedure remote action call to log errors
**/
public with sharing class IntegrationProcedureLogger implements omnistudio.VlocityOpenInterface2, Callable{
    public Object call(String action, Map<String, Object> args) {
        
        Map<String, Object> input = (Map<String, Object>)args.get('input');
        Map<String, Object> output = (Map<String, Object>)args.get('output');
        Map<String, Object> options = (Map<String, Object>)args.get('options');
        
        return invokeMethod(action, input, output, options);
    }
    public Boolean invokeMethod(String methodName, Map<String, Object> input, Map<String, Object> output, Map<String, Object> options) { 
        
        Boolean result =true;
        
        try{
            
            if(methodName.equalsIgnoreCase('Log')){
                Log(input,output,options);
            }
            else{
                output.put('result','Method name does not exist');
            }
            
        } catch(Exception e){
            return false;
        }
        return result;
    }
    public void log(Map<String, Object> input, Map<String, Object> output,Map<String, Object> options) {
        try{
            system.debug('###' + input);
            String status = (String)input.get('status');
            
            if(status == 'Error'){            
                dohagedcare__Application_Log__c appLog = new dohagedcare__Application_Log__c();
                appLog.dohagedcare__Exception_Stack_Trace__c = (String)input.get('node');
                appLog.dohagedcare__Exception_Type__c = 'Integration Procedure error';
                appLog.dohagedcare__Logging_Date_Time__c = system.now();
                appLog.dohagedcare__Logging_Level__c = 'ERROR';
                appLog.dohagedcare__Logging_User_Id__c = UserInfo.getUserId();
                appLog.dohagedcare__Message__c = (String)input.get('errorMessage');
                appLog.dohagedcare__Source_Application__c = 'Star Rating Calculation From IP';
                //appLog.dohagedcare__Source_Event_Id__c = ;
                //appLog.dohagedcare__Time_Stamp__c = ;            
                
                Database.insert(appLog);
            }
        }
        catch(Exception exp){
            dohagedcare.Logger.error(exp.getMessage(),exp,'IP Error Logger').Log(); 
        }
    }
}