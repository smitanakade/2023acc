/****************************************************************************************************
* @Description : Handler class for ContactTrigger
* @testClass ContactTriggerHandlerTest
*****************************************************************************************************/

public with sharing class ContactTriggerHandler implements beforeInsert {
    
    public void beforeInsert(List<Contact> contactList) { 
        ContactTriggerService.updateContactOwner(contactList);
   }
}