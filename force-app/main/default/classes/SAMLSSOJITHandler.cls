//This class provides logic for inbound just-in-time provisioning of single sign-on users in your Salesforce organization.
public with sharing class SAMLSSOJITHandler implements Auth.SamlJitHandler {
    private class JitException extends Exception{}
    private User handleUser(String contactId) {
        String uniqueString = String.valueOf(DateTime.now().getTime());
        Contact newContact = [SELECT Id,Self_Registration_Status__c,GPMS_myGov_Vanguard_Id__c, FirstName, LastName,GPMS_Portal_Role__c, Email FROM contact WHERE Id =: contactId LIMIT 1];
        Profile orgAdminProfile = [SELECT Id FROM profile WHERE name =: 'Org Admin' LIMIT 1];
        User orgAdminUser = new User();
        orgAdminUser.FirstName = newContact.FirstName;
        orgAdminUser.LastName = newContact.LastName;
        orgAdminUser.Email = newContact.Email;
        orgAdminUser.federationIdentifier = newContact.GPMS_myGov_Vanguard_Id__c;
        orgAdminUser.ProfileId = orgAdminProfile.Id;
        orgAdminUser.TimeZoneSidKey = 'Australia/Sydney';
        orgAdminUser.LocaleSidKey = 'en_AU';
        orgAdminUser.LanguageLocaleKey = 'en_US';
        orgAdminUser.EmailEncodingKey = 'UTF-8';
        orgAdminUser.ContactId = newContact.Id;
        orgAdminUser.IsActive = TRUE;
        orgAdminUser.Alias = newContact.FirstName.left(1) + newContact.LastName.left(4);
        orgAdminUser.Username = orgAdminUser.Alias+newContact.GPMS_myGov_Vanguard_Id__c;
        orgAdminUser.CommunityNickname = orgAdminUser.Alias +'_'+ uniqueString;
        return orgAdminUser;
    }
    private String handleContact(String accountId, Map<String, String> attributes, String fedId) {
        List<Contact> existingContact = [SELECT Id FROM Contact WHERE GPMS_myGov_Vanguard_Id__c = :FedId LIMIT 1];
        If (existingContact.isEmpty()) {
            Contact newPortalContact = new Contact();
            List<Integer> intList = new List<Integer> ();
            intList.add(8);
            newPortalContact.FirstName = attributes.get('http://vanguard.ebusiness.gov.au/2008/06/identity/claims/givennames');
            newPortalContact.LastName = attributes.get('http://schemas.xmlsoap.org/ws/2005/05/identity/claims/surname');
            newPortalContact.AccountId = accountId;
            newPortalContact.Email = FedId;
            newPortalContact.GPMS_myGov_Vanguard_Id__c = FedId;
            newPortalContact.GPMS_Self_registration_code__c = GPMSCodeGenerator.verifyCode(intList)[0];
            newPortalContact.GPMS_PortalRegistrationType__c = 'Prospective';
            newPortalContact.IsPortalUser__c =true;
            try{
                insert(newPortalContact);
            }
            catch (exception exp) {
                dohagedcare.Logger.error(exp.getMessage(),exp, 'GPMS').Log();
            }
            return newPortalContact.Id;
        }
        else {
            return existingContact[0].id;
        }
    }
    private String handleAccount(String fedId) {
        List<Contact> existingContact = [SELECT Id, AccountId FROM Contact WHERE GPMS_myGov_Vanguard_Id__c = :FedId LIMIT 1];
        If (existingContact.isEmpty()) {
            Account newAPAccount = new Account();
            List<Integer> intList = new List<Integer> ();
            intList.add(8);
            newAPAccount.Name = 'New Organisation'+ GPMSCodeGenerator.verifyCode(intList)[0];
            newAPAccount.GPMS_ProspectivePortalACO__c  = true;
            newAPAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Aged_Care_Organisation').getRecordTypeId();
            try{
                insert(newAPAccount);
            }
            catch (exception exp) {
                dohagedcare.Logger.error(exp.getMessage(),exp, 'GPMS').Log();
            }
            return newAPAccount.Id;
        }
        else {
            return existingContact[0].AccountId;
        }
    }
    private void handleACR(String accountId, String contactId) {
        List<AccountContactRelation> acr = [SELECT Id,roles
                                            FROM AccountContactRelation
                                            WHERE AccountId =:AccountId
                                            AND ContactId=:ContactId LIMIT 1];
        system.debug(acr);
        if(!ACR.isEmpty()) {
            for (AccountContactRelation iterACR:acr) {
                iterACR.roles = 'Organisation Administrator';
            }
            try {
                update(acr);
            }
            catch (exception exp) {
                dohagedcare.Logger.error(exp.getMessage(),exp, 'GPMS').Log();
            }
        }
    }
    public User createUser(Id samlSsoProviderId, Id communityId, Id portalId, String federationIdentifier, Map<String, String> attributes, String assertion) {
        User userToCreate = new User();
        if(communityId!=null){
            String newAccountId = handleAccount(federationIdentifier);
            String newContactId = handleContact(newAccountId, attributes,federationIdentifier);
            handleACR(newAccountId,newContactId);
            userToCreate = handleUser(newContactId);
        }
        else{
            dohagedcare.Logger.Info('Internal Users Cannot be created through JIT');
        }
        return userToCreate;
    }
    public void updateUser(Id userId, Id samlSsoProviderId, Id communityId, Id portalId, String federationIdentifier, Map<String, String> attributes, String assertion) {
        //implementing Auth.SamlJitHandler requires createUser and updateUser methods
        //there is no requirement to update existing users
    }
}
