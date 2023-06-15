public with sharing class OrgSwitcherPlatformEventTriggerHandler {
    public static void updateUser(List<OrganisationSwitcherPlatformEvent__e> newEvent){
        list<String> acrIds = new list<String>();
        list<String> contactIds = new list<String>();
        List<User> usersToUpdate = new List<User>();
  
        Map<String, String> profileMap = new Map<String, String>();
        for(Profile p : [SELECT Id, name FROM profile]){
            profileMap.put(p.name,p.Id);
        }
        
        for(OrganisationSwitcherPlatformEvent__e iterEvent:newEvent) {
            acrIds.add(iterEvent.accountContactRelationId__c);
        }
        List<AccountContactRelation> accountcontactList =[SELECT id,roles,contactId,account.name FROM AccountContactRelation WHERE id IN : acrIds];
        for(AccountContactRelation iterAcr:accountcontactList){
            contactIds.add(iterAcr.contactId);
        }
        for(User iterUser:[SELECT id,contactId FROM User WHERE contactId IN :contactIds]){
            for(AccountContactRelation iterAcr:accountcontactList){
                if(iterUser.contactId == iterAcr.contactId){                    
                	User tempUser = new User();
                    tempUser.Id =iterUser.id;
                    if(iterAcr.roles.split(';').contains('Organisation Administrator')){
                       	tempUser.profileId = profileMap.get('Org Admin'); 
                    }else if(iterAcr.roles.split(';').contains('QI Benchmarker')) {
                        tempUser.profileId = profileMap.get('QI Benchmarker');  
                    }else {
                      	tempUser.profileId = profileMap.get('Provider User'); 
                    }
                    tempUser.Current_Account__c =iterAcr.account.name;
                    usersToUpdate.add(tempUser);
                }
            }
        }
        If(!usersToUpdate.isEmpty()) {
            try {
                update usersToUpdate;
            }
            catch (DmlException exp) {
                dohagedcare.Logger.error(exp.getMessage(),exp, 'GPMS').Log();
            } 
        }  
    }
}