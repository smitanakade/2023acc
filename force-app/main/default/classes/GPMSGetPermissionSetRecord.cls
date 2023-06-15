global with sharing class GPMSGetPermissionSetRecord implements omnistudio.VlocityOpenInterface {    
    public Boolean invokeMethod (String methodName, Map<String,Object> input, Map<String,Object> output, Map<String,Object> options) {
       try {
           if (methodName.equalsIgnoreCase('GetPermissionSet')) { 
               GetPermissionSetRecordInnerClass permSetInfo = new GetPermissionSetRecordInnerClass();
               AllowedUserProfiles__mdt allowedProfile = permSetInfo.getAllowedProfile();
               
               if(allowedProfile != null) {
                 output.put('allowedProfileDevName', allowedProfile.DeveloperName);             
                 return true; 
               } else {
                   return false;
               }
               
           } else {
               return false;
           }
       } catch (Exception e){
           dohagedcare.Logger.error(e.getMessage(),e, 'GPMS').Log();
           return false;
       }       
    }  
    
    private without sharing class GetPermissionSetRecordInnerClass {        
       public AllowedUserProfiles__mdt getAllowedProfile () {
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
          if(allowedProfile != null) {
               return allowedProfile;
          } else {
               return null;
          }
       }
    }
}