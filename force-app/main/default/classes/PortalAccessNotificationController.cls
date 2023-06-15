public with sharing class PortalAccessNotificationController {
	public class ACRRoles {
        @InvocableVariable(label = 'Updated Roles on the ACR Record')
        public String currentACRRoles;

        @InvocableVariable(label = 'Previous Roles on the ACR Record')
        public String PreviousACRRoles; 
    }
    public class Result {
        @InvocableVariable
        public Boolean success;

        @InvocableVariable
        public Boolean isACOChange;
        
        @InvocableVariable
        public String error;
    }
    
    @InvocableMethod
    Public Static List<Result> checkACOUpdate(List<ACRRoles> roles){
        if(roles[0].currentACRRoles == null){
            roles[0].currentACRRoles ='';
        }
        if(roles[0].PreviousACRRoles == null){
            roles[0].PreviousACRRoles = '';
        }        
        List<Result> returnResultList = new List<Result>();
        Result returnResult = new Result();
        returnResult.isACOChange = false;
        Try {
            List<Org_Switcher_Mapping__mdt> acoRoles = [SELECT role__c From Org_Switcher_Mapping__mdt Where isACOrole__c =: true];
            for(Org_Switcher_Mapping__mdt iterACOrole:acoRoles){
                if(checkACORole(iterACOrole.role__c,roles[0].currentACRRoles.split(';')) != checkACORole(iterACOrole.role__c,roles[0].PreviousACRRoles.split(';'))){
                   	returnResult.isACOChange = true;
                    break;
                }
            }
            returnResult.success = true;
            returnResult.error = '';
        }
        Catch (Exception exp){
            returnResult.success = false;
            returnResult.error = exp.getMessage();
            dohagedcare.Logger.error(exp.getMessage(),exp, 'Portal').Log();
        }
        returnResultList.add(returnResult);
		return returnResultList;      
    }
    
    private static Boolean checkACORole (String acoRole, List<String> roles){
        Boolean containsACORoles =false;
        for(String role:roles){
            if(role == acoRole) {
                containsACORoles = true;
            }
        }
        return containsACORoles;
    }
}