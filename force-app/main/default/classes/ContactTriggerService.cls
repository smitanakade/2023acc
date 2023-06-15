/****************************************************************************************************
* @Description : New Service class for ContactTriggerHandler
*****************************************************************************************************/
public with sharing class ContactTriggerService {
    
    public static void updateContactOwner(List<Contact> contactList){
        
    if (UserInfo.getUserType() == 'PowerCustomerSuccess') {
    	List<Id> accountIds = new List<Id>();
    		for (Contact con: contactList) {
    			accountIds.add(con.AccountId);
  			}
  	Map<Id, Account> accountsById = new Map<Id, Account>([SELECT Id, OwnerId FROM Account WHERE Id IN :accountIds]);
    Id userId = UserInfo.getUserId();
    for (Contact con: contactList) {
    	  Id newOwnerId = accountsById.get(con.AccountId)?.OwnerId;
      	if (newOwnerId != null) {
        	con.OwnerId = newOwnerId;
    	  		}
	    	}
  		}
	}
  }