public with sharing class OrgSwitcher {
    @invocableMethod
    public static List<String> handleOrgSwitch(List<String> acrId){
        system.debug('newccountrelarionid'+acrId);
        OrgSwitcherInnerClass newInnerClass = new OrgSwitcherInnerClass();
        String selectedAcr = acrId[0];
        selectedAcr.remove('(');
        selectedAcr.remove(')');        
        Map<String, Object> result = newInnerClass.updateAcr(selectedAcr);
        updatePermissionFuture((String)result.get('role'),(String)result.get('contactId'),(String)result.get('recordType'),selectedAcr);
        return acrId;
    }
    @AuraEnabled(cacheable=true)
    public static String getSessionId() {
        return UserInfo.getSessionId();
    }
    @future
    public static void updatePermissionFuture (String portalRole,String contactId,String accountRecordType,String accountContactId) {
        OrgSwitcherInnerClass newInnerClass = new OrgSwitcherInnerClass();
        newInnerClass.updatePermissions(portalRole,contactId,accountRecordType,accountContactId);
    }
    private without sharing class OrgSwitcherInnerClass {
        public Map<String, Object> updateAcr(String acrId) {        
            String contactId;
            List<AccountContactRelation> acrToUpdate = new List<AccountContactRelation>();
            List<String> activeAcrIds = new List<String>();
            List<AccountContactRelation> selectedAcr = [SELECT Id, isActive, account.name,roles,accountId,contactId,account.parentId,account.recordType.developerName 
                                                        FROM AccountContactRelation WHERE  id =: acrId LIMIT 1];
            String accountRecordType;
            Boolean isOrgAdmin = false;
            String acoId;
            String roles='';
            String accountName;
            String currentAccountId;
            String orgAdminLabel = System.Label.OrganisationAdministrator;
            String acoDevName = System.Label.ACO_Developer_Name;
            if(!selectedAcr.isEmpty()){
                for(AccountContactRelation iterSelectedAcr:selectedAcr){
                    if(iterSelectedAcr.roles!=null){
                        List<String> tempList = iterSelectedAcr.roles.split(';');
                        for(String str:tempList){
                            if(str == orgAdminLabel && iterSelectedAcr.account.recordType.developerName == acoDevName){
                                isOrgAdmin = true;
                                acoId = iterSelectedAcr.accountId;
                                contactId = iterSelectedAcr.contactId;
                                currentAccountId = iterSelectedAcr.accountId;
                                accountName = iterSelectedAcr.account.Name;
                            }
                            else if(str == orgAdminLabel && iterSelectedAcr.account.recordType.developerName != acoDevName){
                                acoId = iterSelectedAcr.account.parentId;
                                isOrgAdmin = true;
                                contactId = iterSelectedAcr.contactId;
                                currentAccountId = iterSelectedAcr.accountId;
                                accountName = iterSelectedAcr.account.Name;
                            } else {
                                accountName = iterSelectedAcr.account.Name;
                            }
                        }
                    }
                    accountRecordType = iterSelectedAcr.account.recordType.developerName;
                    roles = iterSelectedAcr.roles;
                }
            }
            if(isOrgAdmin) {
                for(AccountContactRelation iterAcr:[SELECT id,isActive FROM AccountContactRelation WHERE contactId=:contactId AND (accountId =:acoId OR accountId =:currentAccountId)]){
                    iterAcr.isActive = true;
                    acrToUpdate.add(iterAcr);
                    activeAcrIds.add(iterAcr.id);
                }
            }
            else {
                for(AccountContactRelation iterAcr:selectedAcr){
                    iterAcr.isActive = true;
                    acrToUpdate.add(iterAcr);
                    activeAcrIds.add(iterAcr.id);
                    contactId = iterAcr.contactId;
                }
            }
            List<AccountContactRelation> unSelectedAcr = [SELECT Id,isActive FROM  AccountContactRelation WHERE contactId =:contactId AND Id !=: activeAcrIds];
            If (!unSelectedAcr.isEmpty()){
                for (AccountContactRelation iterAcr: unSelectedAcr){
                    iterAcr.isActive = false;
                    acrToUpdate.add(iterAcr);
                }
            }
            if(!acrToUpdate.isEmpty()){
                try {
                    update acrToUpdate;
                } 
                catch (DmlException exp) {
                    dohagedcare.Logger.error(exp.getMessage(),exp, 'GPMS').Log();
                } 
            }
            return new Map < String, Object > {
                'role' => roles,
                    'contactId' => contactId,
                    'recordType' => accountRecordType,
                    'accountName' => accountName,
                    'isOrgAdmin' =>isOrgAdmin
                    };        
                        }
        public void updatePermissions(String portalRole,String contactId,String accountRecordType, String accountContactId){
            List<String> permissionSetGroupList = new List<String>();
            List<String> permissionSetList = new List<String>();
            List<String> selctedRoles = portalRole.split(';') ;
            List<String> selectedPermissionSetGroupList = new List<String>();
            String selectedPermission;
            List<PermissionSetAssignment> newPermissionAssignment = new List<PermissionSetAssignment>();
            List<PermissionSetGroup> newPermissionSetGroups = new List<PermissionSetGroup>();
            List<PermissionSet> newPermissionSets = new List<PermissionSet>(); 
            Boolean isPsaSuccess =true;
            List<Org_Switcher_Mapping__mdt> metadataList = [SELECT Role__c,IsACORole__c,isProviderRole__c,isServiceRole__c,isQFRRole__c,isQISRRole__c,isGPMSRole__c,
                                                            Permission_Set_Group_Developer_Name__c, PermissionSet__c,AccountRecordType__c 
                                                            FROM Org_Switcher_Mapping__mdt];
            for(Org_Switcher_Mapping__mdt iterMetadata:metadataList) {
                if (iterMetadata.Role__c!=null){
                    permissionSetGroupList.add(iterMetadata.Permission_Set_Group_Developer_Name__c);
                }
                else {
                    permissionSetList.add(iterMetadata.PermissionSet__c);
                }
            }
            for(Org_Switcher_Mapping__mdt iterMetaRole:metadataList) {
                for(String roleStr:selctedRoles) {
                    if (iterMetaRole.Role__c!=null && iterMetaRole.Role__c == roleStr){
                        selectedPermissionSetGroupList.add(iterMetaRole.Permission_Set_Group_Developer_Name__c);
                    }
                    if (iterMetaRole.AccountRecordType__c!=null && iterMetaRole.AccountRecordType__c == accountRecordType){
                        selectedPermission = iterMetaRole.PermissionSet__c;
                    }
                }
            }
            List<User> currentUser = [SELECT Id FROM USER WHERE contactId =:contactId LIMIT 1];
            List<PermissionSetAssignment> permissionsTodelete = [SELECT Id FROM PermissionSetAssignment 
                                                                 WHERE AssigneeId=:currentUser[0].Id 
                                                                 AND (PermissionSetGroup.DeveloperName IN : permissionSetGroupList OR PermissionSet.Name IN :permissionSetList)];
            If (!selctedRoles.isEmpty()) {
                newPermissionSetGroups = [SELECT Id FROM PermissionSetGroup WHERE DeveloperName =: selectedPermissionSetGroupList]; 
            }
            If (accountRecordType != null) {
                newPermissionSets = [SELECT Id FROM PermissionSet WHERE Name =: selectedPermission]; 
            }
            If(!newPermissionSets.isEmpty()){
                for(PermissionSet iterPs:newPermissionSets){
                    PermissionSetAssignment tempPsa = new PermissionSetAssignment();
                    tempPsa.AssigneeId = currentUser[0].Id;
                    tempPsa.PermissionSetId = iterPs.id;
                    newPermissionAssignment.add(tempPsa);
                }                
            }
            If(!newPermissionSetGroups.isEmpty()){
                for(PermissionSetGroup iterPsg:newPermissionSetGroups) {
                    PermissionSetAssignment tempPsa = new PermissionSetAssignment();
                    tempPsa.AssigneeId = currentUser[0].Id;
                    tempPsa.PermissionSetGroupId = iterPsg.id;
                    newPermissionAssignment.add(tempPsa);
                }                
            }
            If(!permissionsTodelete.isEmpty()) {
                try {
                    delete permissionsTodelete;
                }
                catch (DmlException exp) {
                    dohagedcare.Logger.error(exp.getMessage(),exp, 'GPMS').Log();
                } 
            }
            If(!newPermissionAssignment.isEmpty()){
                try {
                    insert newPermissionAssignment;
                }
                catch (DmlException exp) {
                    isPsaSuccess = false;
                    dohagedcare.Logger.error(exp.getMessage(),exp, 'GPMS').Log();
                } 
                OrganisationSwitcherPlatformEvent__e newOrgSwitchEvent = new OrganisationSwitcherPlatformEvent__e();
                if(isPsaSuccess){                   
                    newOrgSwitchEvent = new OrganisationSwitcherPlatformEvent__e(accountContactRelationId__c=accountContactId,PermissionChangeSuccessful__c =true,UserId__c =currentUser[0].Id);
                }
                else {
                    newOrgSwitchEvent = new OrganisationSwitcherPlatformEvent__e(accountContactRelationId__c=accountContactId,PermissionChangeSuccessful__c =false,UserId__c =currentUser[0].Id);
                }
                String peError;
                Database.SaveResult result = EventBus.publish(newOrgSwitchEvent);
                if(!result.isSuccess()) {
                    for (Database.Error err : result.getErrors()){
                        peError = peError + err.getMessage() +'  ';
                    }
                    dohagedcare.Logger.Info(peError);                 
                }                
            }            
        }
    }
}