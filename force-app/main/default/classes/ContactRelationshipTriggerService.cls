/****************************************************************************************************
* @CreatedBy   : Yohan Perera
* @CreatedDate : 1-11-2022
* @Description : Service class for ContactRelationshipTrigger
* @Test Class  : 
* @Modified by : Sanjeev Bajpai -Added before insert for General Enquiry validation
* @ModifiedDate : 20-12-2022
* @Modified by : AG - Replace Role__c field with Portal_Service_Roles__c and enable "QI Role - Service" for sharing
* @ModifiedDate : 25-03-2023
*****************************************************************************************************/
public with sharing class ContactRelationshipTriggerService {
    
    
    public static final String ROLE_STAR_RATING_SERVICE_REVIEWER = 'Star Rating Reviewer - Service';
	public static final String ROLE_QI_ROLE_SERVICE = 'QI Role - Service'; 
    Public static final List<String>CR_ROLE_WITH_STAR_RATING_ACCESS = new List<String>{ROLE_STAR_RATING_SERVICE_REVIEWER,ROLE_QI_ROLE_SERVICE}; 
    
    public static final String OP_INSERT = 'INSERT';
    public static final String OP_DELETE = 'DELETE';
    
    public static void fireAddUsersToPublicGroupsPE(Map<Id, Contact_Relationship__c> newContactRelationshipMap, Map<Id, Contact_Relationship__c> oldContactRelationshipMap) {
        List<ContactRelationshipPE__e> eventsList = new List<ContactRelationshipPE__e>();

        try {
        if (oldContactRelationshipMap != null) {
            //Update
            for (Id crId : newContactRelationshipMap.keySet()) {
                if ( (!oldContactRelationshipMap.get(crId).Portal_Service_Roles__c.split(';').contains(ROLE_STAR_RATING_SERVICE_REVIEWER) 
                      || !oldContactRelationshipMap.get(crId).Portal_Service_Roles__c.split(';').contains(ROLE_QI_ROLE_SERVICE)) 
                    && (newContactRelationshipMap.get(crId).Portal_Service_Roles__c.split(';').contains(ROLE_STAR_RATING_SERVICE_REVIEWER) 
                        || newContactRelationshipMap.get(crId).Portal_Service_Roles__c.split(';').contains(ROLE_QI_ROLE_SERVICE) ) ){ 
                    ContactRelationshipPE__e event = new ContactRelationshipPE__e();
                    event.ContactRelationshipId__c = crId;
                    event.Operation__c = ContactRelationshipTriggerService.OP_INSERT;
                    eventsList.add(event);
                } else if ( (oldContactRelationshipMap.get(crId).Portal_Service_Roles__c.split(';').contains(ROLE_STAR_RATING_SERVICE_REVIEWER) 
                             || oldContactRelationshipMap.get(crId).Portal_Service_Roles__c.split(';').contains(ROLE_QI_ROLE_SERVICE)) 
                           && (!newContactRelationshipMap.get(crId).Portal_Service_Roles__c.split(';').contains(ROLE_STAR_RATING_SERVICE_REVIEWER) 
                               || !newContactRelationshipMap.get(crId).Portal_Service_Roles__c.split(';').contains(ROLE_QI_ROLE_SERVICE)) ){
                    ContactRelationshipPE__e event = new ContactRelationshipPE__e();
                    event.ContactRelationshipId__c = crId;
                    event.ServiceId__c = oldContactRelationshipMap.get(crId).Service__c;
                    event.ContactId__c = oldContactRelationshipMap.get(crId).Contact__c;
                    event.Operation__c = ContactRelationshipTriggerService.OP_DELETE;
                    eventsList.add(event);
                }
                else{
                    
                    continue;
                }
            }
        } else {
            //Insert
        for (Id crId : newContactRelationshipMap.keySet()) {
            ContactRelationshipPE__e event = new ContactRelationshipPE__e();
            event.ContactRelationshipId__c = crId;
            event.Operation__c = ContactRelationshipTriggerService.OP_INSERT;
			eventsList.add(event);
        }
        }

        if (!eventsList.isEmpty()) EventBus.publish(eventsList);
        } catch (Exception ex) {
            dohagedcare.Logger.error(ex.getMessage(), ex, 'Star Rating').log();
        }

    }
    
    public static void fireRemoveUsersFromPublicGroupsPE(Map<Id, Contact_Relationship__c> oldContactRelationshipMap) {
        List<ContactRelationshipPE__e> eventsList = new List<ContactRelationshipPE__e>();
        
        try {
        for (Id crId : oldContactRelationshipMap.keySet()) {
            ContactRelationshipPE__e event = new ContactRelationshipPE__e();
            event.ContactRelationshipId__c = crId;
           	event.ServiceId__c = oldContactRelationshipMap.get(crId).Service__c;
            event.ContactId__c = oldContactRelationshipMap.get(crId).Contact__c;
            event.Operation__c = ContactRelationshipTriggerService.OP_DELETE;
            eventsList.add(event);
        }
        
        EventBus.publish(eventsList);
        } catch (Exception ex) {
            dohagedcare.Logger.error(ex.getMessage(), ex, 'Star Rating').log();
        }
    }
    
    public static void distributeEvents(List<ContactRelationshipPE__e> events) {
        Map<Id, Contact_Relationship__c> toInsertCRs = new Map<Id, Contact_Relationship__c>();
        List<ContactRelationshipPE__e> toDeleteCRs = new List<ContactRelationshipPE__e>();
        
        try {
        for (ContactRelationshipPE__e event : events) {
            if (event.Operation__c == ContactRelationshipTriggerService.OP_INSERT) {
                toInsertCRs.put((Id)event.ContactRelationshipId__c, null);
            } else if (event.Operation__c == ContactRelationshipTriggerService.OP_DELETE) {
                toDeleteCRs.add(event);
            }
        }
        
        if (!toInsertCRs.isEmpty()) {
            
            Map<Id, Contact_Relationship__c> relationshipsMap = new Map<Id, Contact_Relationship__c>([SELECT Id, Role__c, Contact__c, Service__c, Portal_Service_Roles__c 
                                                                                                      FROM Contact_Relationship__c WHERE Id IN :toInsertCRs.keySet()]);
            for (Id key : relationshipsMap.keySet()) {
                Contact_Relationship__c acr = relationshipsMap.get(key);
                if (toInsertCRs.containsKey(key)) {
                    toInsertCRs.put(key, acr);
                } 
            }
        }
        
        if (!toInsertCRs.isEmpty()) 
        	ContactRelationshipTriggerService.addUsersToPublicGroups(toInsertCRs);
        
        if (!toDeleteCRs.isEmpty()) 
            ContactRelationshipTriggerService.removeUsersFromPublicGroups(toDeleteCRs);
        } catch (Exception ex) {
            dohagedcare.Logger.error(ex.getMessage(), ex, 'Star Rating').log();
        }

    }
    
    public static void addUsersToPublicGroups(Map<Id, Contact_Relationship__c> contactRelationshipMap) {
        Map<String, List<Id>> serviceToContactsMap = new Map<String, List<Id>>();
        Set<Id> contactIds = new Set<Id>();
        
        try {
            for (Id contactRelationshipId : contactRelationshipMap.keySet()) {
                Contact_Relationship__c cRelationship = contactRelationshipMap.get(contactRelationshipId);
                
                if (cRelationship.Portal_Service_Roles__c.split(';').contains(ROLE_STAR_RATING_SERVICE_REVIEWER) || cRelationship.Portal_Service_Roles__c.split(';').contains(ROLE_QI_ROLE_SERVICE)) {
                    Id serviceId = contactRelationshipMap.get(contactRelationshipId).Service__c;
                    String formattedStrService = 'SRV_' + serviceId;
                    
                    List<Id> contacts;
                    if (serviceToContactsMap.get(formattedStrService) != null) {
                        contacts = serviceToContactsMap.get(formattedStrService);
                        contacts.add(cRelationship.Contact__c);
                        serviceToContactsMap.put(formattedStrService, contacts);
                    } else {
                        contacts = new List<Id>();
                        contacts.add(cRelationship.Contact__c);
                        serviceToContactsMap.put(formattedStrService, contacts);
                    }
                    
                    if (contacts != null) {
                        contactIds.addAll(contacts);
                    }
                }
            }
            
            if (!contactIds.isEmpty()) {
                Map<Id, User> contactToUserMap = new Map<Id, User>();
                
                for (User u : [SELECT Id, ContactId, UserRole.DeveloperName FROM User WHERE ContactId IN :contactIds]) {
                    contactToUserMap.put(u.ContactId, u);
                }
                
                List<GroupMember> listGroupMember = new List<GroupMember>();
                
                for (Group g : [SELECT Id, DeveloperName FROM Group WHERE DeveloperName IN : serviceToContactsMap.keySet()]) {
                    List<Id> cIds = serviceToContactsMap.get(g.DeveloperName);
                    
                    for (Id cId : cIds) {
                        //Assumption: If no user associated, no group member will be created
                        if (contactToUserMap.get(cId) != null) {
                            GroupMember gm = new GroupMember(); 
                            gm.GroupId = g.Id;
                            gm.UserOrGroupId = contactToUserMap.get(cId).Id;
                            listGroupMember.add(gm);
                        }
                    }
                }
                
                if (!listGroupMember.isEmpty()) insert listGroupMember;
            }
        } catch (Exception ex) {
            dohagedcare.Logger.error(ex.getMessage(), ex, 'Star Rating').log();
        }
    }
    
    //This operation would require all the necessary field values to perform the operation as the Platform event
    //begin to process, the record would have already been deleted.
    public static void removeUsersFromPublicGroups(List<ContactRelationshipPE__e> contactRelationshipList) {
        Map<String, List<Id>> serviceToContactsMap = new Map<String, List<Id>>();
        Set<Id> contactIds = new Set<Id>();
        
        try {
            for (ContactRelationshipPE__e cr : contactRelationshipList) {
                Id serviceId = cr.ServiceId__c;
                String formattedStrService = 'SRV_' + serviceId;
                
                List<Id> contacts;
                if (serviceToContactsMap.get(formattedStrService) != null) {
                    contacts = serviceToContactsMap.get(formattedStrService);
                    contacts.add(cr.ContactId__c);
                    serviceToContactsMap.put(formattedStrService, contacts);
                } else {
                    contacts = new List<Id>();
                    contacts.add(cr.ContactId__c);
                    serviceToContactsMap.put(formattedStrService, contacts);
                }
                
                if (contacts != null) {
                    contactIds.addAll(contacts);
                }
            }

            Map<Id, User> contactToUserMap = new Map<Id, User>();
            
            for (User u : [SELECT Id, ContactId FROM User WHERE ContactId IN :contactIds]) {
                contactToUserMap.put(u.ContactId, u);
            }

            List<GroupMember> groupMembersToRemove = new List<GroupMember>();
            
            for (GroupMember gm : [SELECT Id FROM GroupMember WHERE Group.DeveloperName IN :serviceToContactsMap.keySet() AND UserOrGroupId = :contactToUserMap.values()]) {
                groupMembersToRemove.add(gm);
            }
            
            if (!groupMembersToRemove.isEmpty()) delete groupMembersToRemove;
        } catch (Exception ex) {
            dohagedcare.Logger.error(ex.getMessage(), ex, 'Star Rating').log();
        }
    }
          //SB--Validation for General Enquiry
	public static void generalEnquiryValidation(Map<Id, Contact_Relationship__c> crsMap){
   
		List<Id> accountIds = new List<Id>();
		Map<Id, Contact_Relationship__c> crIdAndDetails = new Map<Id, Contact_Relationship__c>();
		for(Contact_Relationship__c cr : crsMap.values())
		{
			if('General Enquiry'.equalsIgnoreCase(cr.Organisation_Contact_Type__c))
			{
			crIdAndDetails.put(cr.Account__c, cr);
			}
		}
		 Map<Id, List<Contact_Relationship__c>> accountIdAndCRDetails = new Map<Id, List<Contact_Relationship__c>>();
		List<Contact_Relationship__c> geCRsForAccountIds = [Select Id, Account__c from Contact_Relationship__c where Account__c =:crIdAndDetails.keySet() and Organisation_Contact_Type__c ='General Enquiry'];
		for(Contact_Relationship__c cr : geCRsForAccountIds)
		{
			if(accountIdAndCRDetails.get(cr.Account__c) == null)
			{
				List<Contact_Relationship__c> geCrs = new List<Contact_Relationship__c>();
				geCrs.add(cr);
				accountIdAndCRDetails.put(cr.Account__c, geCrs);
			 }else {
			   crIdAndDetails.get(cr.Account__c).addError(System.Label.General_Enquiry_Org_Contact_Err_Msg);            
				  }
		}
	} 
}