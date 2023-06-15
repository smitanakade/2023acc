/****************************************************************************************************
* @CreatedBy   : Bijil Ram
* @CreatedDate : 30-11-2022
* @Description : New Service class for AccountContactRelationshipTrigger
* 
*****************************************************************************************************/
public with sharing class ACRTriggerServiceNew {
    
    public static void createACR(Map<Id, AccountContactRelation> newAccountContactRelationshipMap,Map<Id, AccountContactRelation> oldAccountContactRelationshipMap) {
        InnerClass newInnerClass = new InnerClass ();
        if(oldAccountContactRelationshipMap==null){
            newInnerClass.handleCreate(newAccountContactRelationshipMap,null); 
        }
        else {
            newInnerClass.handleUpdate(newAccountContactRelationshipMap,oldAccountContactRelationshipMap);
        }
    }
    
    public without sharing class InnerClass{
        public final String acoRecordType = 'Aged_Care_Organisation';
        public final String apRecordType = 'Approved_Provider';
        public final String orgAdminRole = 'Organisation Administrator';
        public void handleCreate(Map<Id, AccountContactRelation> newAccountContactRelationshipMap, Map<Id, AccountContactRelation> oldAccountContactRelationshipMap) {
            set<Id> setACRID = new set<Id>();
            set<Id> setChildId = new set<Id>();
            set<Id> setcontactId = new set<Id>();
            List<Id> accountWithACR = new List<Id>();
            Map<Id, List<Id>> parentToChildAccounts = new Map<Id, List<Id>>();
            Map<Id, List<Account>> childACRNotCreated = new Map<Id, List<Account>>();
            Map<Id, List<AccountContactRelation>> childACRCreated = new Map<Id, List<AccountContactRelation>>();
            Map<Id,Id> mapContactIdTOACR = new Map<Id,Id>();
            Map<Id,AccountContactRelation> parentTOACR = new Map<Id,AccountContactRelation>();
            List<String> accountRecordTypes = new List<String>();
            List<String> orgRoles = new List<String>();
            for(Org_Switcher_Mapping__mdt iterMdt:[SELECT AccountRecordType__c,role__c,IsACORole__c, isProviderRole__c, isServiceRole__c FROM Org_Switcher_Mapping__mdt]){
                if(iterMdt.IsACORole__c && iterMdt.role__c != orgAdminRole) {
                    orgRoles.add(iterMdt.role__c);
                }
                if(iterMdt.AccountRecordType__c!=null){
                    accountRecordTypes.add(iterMdt.AccountRecordType__c);
                }
            }
            for(Id acrId: newAccountContactRelationshipMap.keyset()){
                AccountContactRelation objACR   = newAccountContactRelationshipMap.get(acrId);
                Boolean hasOrgRole = hasOrgRole(objACR.Roles, orgRoles);
                if(objACR.Roles!=null){
                    if(objACR.AccountRecordType__c == acoRecordType && (objACR.Roles.contains(orgAdminRole) ||  hasOrgRole)) {
                        parentToChildAccounts.put(objACR.AccountId, new List<Id>());
                        setACRID.add(objACR.Id);
                        setcontactId.add(objACR.ContactId);
                        mapContactIdTOACR.put(objACR.AccountId,objACR.ContactId);
                        parentTOACR.put(objACR.AccountId,objACR);
                    }
                }
                else{
                    if(objACR.AccountRecordType__c == acoRecordType) {
                        parentToChildAccounts.put(objACR.AccountId, new List<Id>());
                        setACRID.add(objACR.Id);
                        setcontactId.add(objACR.ContactId);
                        mapContactIdTOACR.put(objACR.AccountId,objACR.ContactId);
                        parentTOACR.put(objACR.AccountId,objACR);
                    }
                }
            }
            List<AccountContactRelation> existingAcrList;
            try {
                existingAcrList = [SELECT accountId, roles,endDate, Account.ParentId, Account.RecordType.DeveloperName FROM AccountContactRelation 
                                   WHERE Account.ParentId IN :parentToChildAccounts.keySet() 
                                   AND ContactId IN:setcontactId AND Account.RecordType.DeveloperName IN :accountRecordTypes];
            } Catch (QueryException ex) {
                dohagedcare.logger.error(ex.getMessage(),ex,'QFR').log();
            }
            
            for(AccountContactRelation iterAcr: existingAcrList){                
                
                if(childACRCreated.get(iterAcr.Account.ParentId)!=null){
                    childACRCreated.get(iterAcr.Account.ParentId).add(iterAcr);
                    accountWithACR.add(iterAcr.accountId);
                }
                else {
                    childACRCreated.put(iterAcr.Account.ParentId,new List<AccountContactRelation>{iterAcr});
                    accountWithACR.add(iterAcr.accountId);
                }
            }  
            for(Account iterAcc:[SELECT Id, ParentId,RecordType.DeveloperName FROM Account WHERE ParentId IN :parentToChildAccounts.keySet() AND Id NOT IN :accountWithACR  
                				AND RecordType.DeveloperName IN :accountRecordTypes]){
                if(childACRNotCreated.get(iterAcc.ParentId)!=null){
                    childACRNotCreated.get(iterAcc.ParentId).add(iterAcc);
                  }
                else {
                    childACRNotCreated.put(iterAcc.ParentId,new List<Account>{iterAcc});
                }
            }
            List<AccountContactRelation> acrToCreate = new List<AccountContactRelation>();
            List<AccountContactRelation> acrToUpdate = new List<AccountContactRelation>();
            if(!childACRNotCreated.isEmpty()){
                for(Id iterParentId:childACRNotCreated.keySet()){
                    for(Account iterChildAcc:childACRNotCreated.get(iterParentId)){
                        Boolean hasOrgRole = hasOrgRole(parentTOACR.get(iterParentId).Roles, orgRoles);
                        AccountContactRelation tempACR = new AccountContactRelation();
                        if(parentTOACR.get(iterParentId).Roles!=null && (parentTOACR.get(iterParentId).Roles.contains(orgAdminRole) || hasOrgRole)){
                            tempACR.accountId = iterChildAcc.Id;
                            tempACR.ContactId = mapContactIdTOACR.get(iterParentId);
                            tempACR.Roles = handleACORole(orgRoles,parentTOACR.get(iterParentId).Roles,iterChildAcc.RecordType.DeveloperName);
                            if(tempACR.Roles != null && tempACR.Roles != ''){
                              acrToCreate.add(tempACR);  
                            }
                        }                        
                    }	    
                }
            }            
            If(!childACRCreated.isEmpty()){
                for(Id iterParentId:childACRCreated.keySet()){
                    for(AccountContactRelation iterAcr: childACRCreated.get(iterParentId)){
                        iterAcr.roles = handleRole(parentTOACR.get(iterParentId).Roles,iterAcr.roles,iterAcr.Account.RecordType.DeveloperName,orgRoles);
                        acrToUpdate.add(iterAcr);
                    }
                }
            }
            if(!acrToCreate.isEmpty()){
                try{
                    Database.insert(acrToCreate,false);
                }
                catch(DMLException e){
                    dohagedcare.logger.error(e.getMessage(),e,'GPMS').log();  
                }
            }
            if(!acrToUpdate.isEmpty()){
                try{
                    update acrToUpdate;
                    
                }
                catch(DMLException e){
                    dohagedcare.logger.error(e.getMessage(),e,'GPMS').log();   
                    
                }
            }
        }
        public void handleUpdate(Map<Id, AccountContactRelation> newAccountContactRelationshipMap,Map<Id, AccountContactRelation> oldAccountContactRelationshipMap) {
            Map<Id, AccountContactRelation> updatedAcrNewMap = new Map<Id, AccountContactRelation>();
            Map<Id, AccountContactRelation> updatedAcrOldMap = new Map<Id, AccountContactRelation>();
            for(Id acrId: newAccountContactRelationshipMap.keyset()){
                if(newAccountContactRelationshipMap.get(acrId).Roles  != oldAccountContactRelationshipMap.get(acrId).Roles){
                    updatedAcrNewMap.put(acrId,newAccountContactRelationshipMap.get(acrId));
                    updatedAcrOldMap.put(acrId,oldAccountContactRelationshipMap.get(acrId));
                } 
            }
            handleCreate(updatedAcrNewMap,updatedAcrOldMap);
        }
        public String handleACORole(List<String> nonOrgAdminRole,String roles,String recordType) {
            String returnRoles = '';
            if(roles!=null){
                for(String iterRole:roles.split(';')){
                    if(recordType == apRecordType && (nonOrgAdminRole.contains(iterRole) || iterRole== orgAdminRole)){
                        returnRoles = returnRoles+';'+iterRole;
                    }
                    if(recordType != apRecordType && iterRole == orgAdminRole){
                        returnRoles = returnRoles+';'+iterRole; 
                    }
                }
            }
            
            returnRoles = returnRoles.removeEnd(';');
            returnRoles = returnRoles.removeStart(';');
            return returnRoles;
        }
        Public Boolean hasOrgRole(String roles, List<String> orgRoles){
            Boolean hasOrgRole = false;
            if(roles!=null && !orgRoles.isEmpty()){
                for(String role:orgRoles){
                    If(roles.contains(role)){
                        hasOrgRole = true;
                        break;
                    }
                } 
            }            
            return hasOrgRole;
        }
        public String handleRole(String acoRole,String providerRole,String recordType,List<String> nonOrgAdminRole) {
            String providerOnlyRole  = '';
            String newRoles ='';
            if(providerRole!=null){
                for(String iterProvRoles:providerRole.split(';')){
                    if(iterProvRoles!=orgAdminRole && !hasOrgRole(iterProvRoles,nonOrgAdminRole)) {
                        providerOnlyRole = providerOnlyRole+';'+iterProvRoles;
                    }
                }
            }
            newRoles = providerOnlyRole+';'+handleACORole(nonOrgAdminRole,acoRole,recordType);
            newRoles = newRoles.removeEnd(';');
            newRoles = newRoles.removeStart(';');
            return newRoles;
        }
    }
}