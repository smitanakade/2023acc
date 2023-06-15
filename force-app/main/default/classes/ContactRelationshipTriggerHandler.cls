/****************************************************************************************************
* @CreatedBy   : Yohan Perera
* @CreatedDate : 1-11-2022
* @Description : 
* @Test Class  : 
* @Modified by : Sanjeev Bajpai -Added after insert for General Enquiry validation
* @ModifiedDate : 21-12-2022
*****************************************************************************************************/
public with sharing class ContactRelationshipTriggerHandler implements afterInsert, afterUpdate, beforeDelete {
    
    public void afterInsert(Map<Id, SObject> newContactRelationshipMap) {
        ContactRelationshipTriggerService.fireAddUsersToPublicGroupsPE((Map<Id, Contact_Relationship__c>)newContactRelationshipMap, null);
        ContactRelationshipTriggerService.generalEnquiryValidation((Map<Id, Contact_Relationship__c>)newContactRelationshipMap);
    }

    public void afterUpdate(Map<Id, SObject> newContactRelationshipMap, Map<Id, SObject> oldContactRelationshipMap) {
        ContactRelationshipTriggerService.fireAddUsersToPublicGroupsPE((Map<Id, Contact_Relationship__c>)newContactRelationshipMap, (Map<Id, Contact_Relationship__c>)oldContactRelationshipMap);
        ContactRelationshipTriggerService.generalEnquiryValidation((Map<Id, Contact_Relationship__c>)newContactRelationshipMap);
    }
    
    public void beforeDelete(Map<Id, SObject> oldContactRelationshipMap) {
        ContactRelationshipTriggerService.fireRemoveUsersFromPublicGroupsPE((Map<Id, Contact_Relationship__c>)oldContactRelationshipMap);
    }
      
  }