/****************************************************************************************************
* @Modified by : AG - To Enable "QI Role - Org" for sharing on ACR object and "Star Rating Reviewer - Service" on Contact_Relationship__c object
* @ModifiedDate : 25-03-2023
*****************************************************************************************************/


public with sharing class UserTriggerService {
    
    Public static final string query_string = 'SELECT Id, Service__c, Contact__c FROM Contact_Relationship__c WHERE ';
    private static Map<Id, Profile> allowedProfiles {
		get {
			if (allowedProfiles == null) {
				allowedProfiles = new Map<Id, Profile>(
					[SELECT Id FROM Profile WHERE Name IN ('Provider User', 'Org Admin')]
				);
			}

			return allowedProfiles;
		}
		set;
    }
	
    
    public static void fireAddRemoveUsersToFromPublicGroupsPE(Map<Id, User> newUsersMap, Map<Id, User> oldUsersMap) {
        
        String ACR_ELIGIBLE_ROLE = '(\'' + String.join(AccountContactRelationshipTriggerService.ACR_ROLE_WITH_STAR_RATING_ACCESS, '\', \'') + '\')'; 
        String CR_ELIGIBLE_ROLE = '(\'' + String.join(ContactRelationshipTriggerService.CR_ROLE_WITH_STAR_RATING_ACCESS, '\', \'') + '\')'; 
      	
        if (oldUsersMap != null) {
            //Update
            List<Id> contactIdsToRemove = new List<Id>();
            List<Id> contactIdsToAdd = new List<Id>();
            
            for (Id userId : newUsersMap.keySet()) {
                //User was made inactive
                if (oldUsersMap.get(userId).IsActive && !newUsersMap.get(userId).IsActive) {
                    contactIdsToRemove.add(newUsersMap.get(userId).ContactId);
                } else if (!oldUsersMap.get(userId).IsActive && newUsersMap.get(userId).IsActive) {
                    contactIdsToAdd.add(newUsersMap.get(userId).ContactId);
                }
            }
            
            if (!contactIdsToRemove.isEmpty()) {
                Map<Id, AccountContactRelation> acrMap = new Map<Id, AccountContactRelation>([SELECT Id, ContactId, AccountId, Roles FROM AccountContactRelation WHERE ContactId IN :contactIdsToRemove]);
                
                if (acrMap != null && !acrMap.isEmpty()) {
                    AccountContactRelationshipTriggerService.fireDeleteUsersFromPublicGroupsPE(acrMap);
                }
              
                List<Contact_Relationship__c>scrList=  Database.query(query_string + 
                                                                      +'Contact__c IN :contactIdsToRemove AND Portal_Service_Roles__c INCLUDES' +CR_ELIGIBLE_ROLE); 

                Map<Id, Contact_Relationship__c> scrMap = new Map<Id, Contact_Relationship__c>(scrList);
                
                
                if (scrMap != null && !scrMap.isEmpty()) {
                    ContactRelationshipTriggerService.fireRemoveUsersFromPublicGroupsPE(scrMap);
                }
            }
            
            if (!contactIdsToAdd.isEmpty()) {
                
                List<AccountContactRelation> acrList = Database.query('SELECT Id FROM AccountContactRelation WHERE '+
                                                                       +'ContactId IN :contactIdsToAdd AND Roles INCLUDES' + ACR_ELIGIBLE_ROLE +' AND IsActive = true');
                
                List<Contact_Relationship__c>scrList=  Database.query(query_string +
                                                                      +'Contact__c IN :contactIdsToAdd AND Portal_Service_Roles__c INCLUDES'+CR_ELIGIBLE_ROLE);

                Map<Id, AccountContactRelation> acrMap = new Map<Id, AccountContactRelation>(acrList); 
                if (acrMap != null && !acrMap.isEmpty()) {
                    AccountContactRelationshipTriggerService.fireAddUsersToPublicGroupsPE(acrMap);
                }
                
                Map<Id, Contact_Relationship__c> scrMap = new Map<Id, Contact_Relationship__c>(scrList); 
                if (scrMap != null && !scrMap.isEmpty()) {
                    ContactRelationshipTriggerService.fireAddUsersToPublicGroupsPE(scrMap, null);
                }
                
            }
        } else {
            //Insert
            List<Id> contactIds = new List<Id>();
            
            for (Id userId : newUsersMap.keySet()) {
                User u = newUsersMap.get(userId);
                if (u.IsActive && u.ContactId != null && allowedProfiles.keySet().contains(u.ProfileId)) {
                    contactIds.add(u.ContactId);
                }
            }
            
            if (!contactIds.isEmpty()) {
                
                List<AccountContactRelation> acrList = Database.query('SELECT Id FROM AccountContactRelation WHERE  '+
                                                                      +'ContactId IN :contactIds AND Roles INCLUDES' + ACR_ELIGIBLE_ROLE +' AND IsActive = true'); 
                List<Contact_Relationship__c>scrList=  Database.query(query_string +
                                                                      +'Contact__c IN :contactIds AND Portal_Service_Roles__c INCLUDES'+CR_ELIGIBLE_ROLE); 

                Map<Id, AccountContactRelation> newAccountContactRelationshipMap = new Map<Id, AccountContactRelation>(acrList);
                system.debug('newAccountContactRelationshipMap'+newAccountContactRelationshipMap);
                if (newAccountContactRelationshipMap != null && !newAccountContactRelationshipMap.isEmpty()) {
                    AccountContactRelationshipTriggerService.fireAddUsersToPublicGroupsPE(newAccountContactRelationshipMap);
                }
                
                Map<Id, Contact_Relationship__c> newServiceContactRelationshipMap = new Map<Id, Contact_Relationship__c>(scrList); 
                if (newServiceContactRelationshipMap != null && !newServiceContactRelationshipMap.isEmpty()) {
                    ContactRelationshipTriggerService.fireAddUsersToPublicGroupsPE(newServiceContactRelationshipMap, null);
                }

            }
            
        }
    }

}