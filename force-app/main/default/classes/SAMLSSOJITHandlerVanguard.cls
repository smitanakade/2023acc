//This class provides logic for inbound just-in-time provisioning of single sign-on users in your Salesforce organization.
global without sharing class SAMLSSOJITHandlerVanguard implements Auth.SamlJitHandler {
    private class JitException extends Exception{}
    private User handleUser(String contactId) {
        Contact newContact = [SELECT Id,Self_Registration_Status__c,GPMS_myGov_Vanguard_Id__c, FirstName, LastName,GPMS_Portal_Role__c, Email FROM contact WHERE Id =: contactId Limit 1];
        Profile orgAdminProfile = [SELECT Id FROM profile WHERE name =: 'Provider User' LIMIT 1];
        User orgAdminUser = new User();
        orgAdminUser.FirstName = newContact.FirstName;
        orgAdminUser.LastName = newContact.LastName;
        orgAdminUser.Email = newContact.Email;
        orgAdminUser.Username = newContact.GPMS_myGov_Vanguard_Id__c+'_'+newContact.Email;
        orgAdminUser.federationIdentifier = newContact.GPMS_myGov_Vanguard_Id__c;
        orgAdminUser.ProfileId = orgAdminProfile.Id;
        orgAdminUser.TimeZoneSidKey = 'Australia/Sydney'; 
        orgAdminUser.LocaleSidKey = 'en_AU';
        orgAdminUser.LanguageLocaleKey = 'en_US';
        orgAdminUser.EmailEncodingKey = 'UTF-8';
        orgAdminUser.ContactId = newContact.Id;
        orgAdminUser.IsActive = TRUE;
        orgAdminUser.GPMS_Portal_Role__c = newContact.GPMS_Portal_Role__c;
        orgAdminUser.Alias = newContact.FirstName.left(1) + newContact.LastName.left(4);
        orgAdminUser.CommunityNickname = orgAdminUser.Alias +'_'+ orgAdminUser.federationIdentifier;
        return orgAdminUser;
    }
    global User createUser(Id samlSsoProviderId, Id communityId, Id portalId, String federationIdentifier, Map<String, String> attributes, String assertion) {
        List<Contact> existingContact = [SELECT Id from Contact WHERE GPMS_myGov_Vanguard_Id__c =: federationIdentifier];
        If(existingContact[0].Id != null) {
            User userToCreate = handleUser(existingContact[0].Id);
            return userToCreate;
        }
        else {
            dohagedcare.Logger.Info('Prospective Provider Cannot be Created with Vanguard Id.');
            return null;
        } 
    }
    global void updateUser(Id userId, Id samlSsoProviderId, Id communityId, Id portalId, String federationIdentifier, Map<String, String> attributes, String assertion) {
        //implementing Auth.SamlJitHandler requires createUser and updateUser methods
        //there is no requirement to update existing users
    }
}