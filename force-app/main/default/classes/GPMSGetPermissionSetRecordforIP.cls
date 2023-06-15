/**
* author: Sai Natarjaan
* date: 15/12/2022
* description: Handle integration procedure remote action call to get GPMSPermissionSet
**/
global with sharing class GPMSGetPermissionSetRecordforIP implements omnistudio.VlocityOpenInterface2,Callable {
    public Object call(String action, Map<String, Object> args) {
        
        Map<String, Object> input = (Map<String, Object>)args.get('input');
        Map<String, Object> output = (Map<String, Object>)args.get('output');
        Map<String, Object> options = (Map<String, Object>)args.get('options'); 
        
        return invokeMethod(action, input, output, options);
    }
    
    global Boolean invokeMethod (String methodName, Map<String,Object> input, Map<String,Object> output, Map<String,Object> options) {
        Boolean result=true;
        try{ 
            if( methodName.equalsIgnoreCase('getPermissionSet')){
                  
                   AllowedUserProfiles__mdt allowedprofile = GetPermissionSetRecordInnerClass(input,output,options);
                   
                    output.put('result',allowedProfile.DeveloperName);
                    
                    result=true;
            } else{
                
                return false;
            }
          } catch (Exception e){
           dohagedcare.Logger.error(e.getMessage(),e, 'GPMS').Log();
           return false;    
        }
        return result;
    }
    
    public  AllowedUserProfiles__mdt getPermissionSetRecordInnerClass(Map<String,object> input,Map<String,	object> output,Map<String,object> options){ 
         Set<String> permissionSetNameSet = new Set<String>();
          List<PermissionSetAssignment> permissionSetAssignmentList = [SELECT Id, PermissionSet.Name 
                                                                       FROM PermissionSetAssignment 
                                                                       WHERE AssigneeId = :UserInfo.getUserId()];
          if(permissionSetAssignmentList.size() == 0) {
              return null;
          }
               
          for(PermissionSetAssignment permSetAssignment: permissionSetAssignmentList) {
              permissionSetNameSet.add(permSetAssignment.PermissionSet.Name); 
          }
                          
          AllowedUserProfiles__mdt allowedProfile = [Select Id, DeveloperName from AllowedUserProfiles__mdt 
                                                          where DeveloperName IN : permissionSetNameSet Limit 1];
          dohagedcare.Logger.debug('allowedProfile: '+ allowedProfile);
          if(allowedProfile != null) {
               return allowedProfile; 
          } else {
               return null;
          }
     }

}