public with sharing class GPMSPortalManageUserController {

    @AuraEnabled
    public static Map<String, List<Object>> getPicklistOptions() {
        try {
            GPMSPortalManageUser controller = new GPMSPortalManageUser();
            return controller.getPicklistOptions();    
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        
    }

    @AuraEnabled
    public static Map<String,Object> inviteUser(String inputJson) {
        try {
            GPMSPortalManageUser controller = new GPMSPortalManageUser();
            Map<String,Object> result = controller.inviteUser(inputJson);
            Integer createList = (Integer)result.get('createList');
            userInfoWrapper userInfo = result.get('userInfo') != null ? (userInfoWrapper)result.get('userInfo') : null;
            userInfoWrapper wrapper = result.get('wrapper') != null ? (userInfoWrapper)result.get('wrapper') : null; 
            String contactId = result.get('contactId') != null ? (String)result.get('contactId') : null;
            
            if(createList == 1) {
                callInsertUser(userInfo.userEmail, wrapper.firstName, wrapper.lastName, contactId);
            } else if(createList == 2) {
                callInsertACR(userInfo.organisation, contactId, userInfo.contactType);
            } else if(createList == 3){
                callInsertACR(userInfo.organisation, contactId, userInfo.contactType);
                callInsertUser(userInfo.userEmail, wrapper.firstName, wrapper.lastName, contactId);
            } else {
                return result;
            }

            return result;    
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        
    }

    @future
    public static void callInsertACR(String accountId, String contactId, String contactType) {
        try {
            GPMSPortalManageUser controller = new GPMSPortalManageUser();
            controller.insertACR(accountId, contactId, contactType);    
        } catch (Exception e) {
            dohagedcare.Logger.error(e.getMessage(),e,'GPMSPortalManageUserController').Log();
        }
        
    }

    @future
    public static void callInsertUser(String userEmail, String firstName, String lastName, Id contactId) {
        try {
            GPMSPortalManageUser controller = new GPMSPortalManageUser();
            controller.insertUser(userEmail, firstName, lastName, contactId);    
        } catch (Exception e) {
            dohagedcare.Logger.error(e.getMessage(),e,'GPMSPortalManageUserController').Log();
        }
    }
  
    public without sharing class GPMSPortalManageUser {
        public Map<String, List<Object>> getPicklistOptions(){
            try {
                List<PicklistWrapper> organisationOptions = new List<PicklistWrapper>();
                List<PicklistWrapper> roleOptions = new List<PicklistWrapper>();
                List<PicklistWrapper> salutationOptions = new List<PicklistWrapper>();
                
                List<Schema.PicklistEntry> rolesPLE = AccountContactRelation.GPMS_Portal_Role__c.getDescribe().getPicklistValues();
                
                if(!rolesPLE.isEmpty()) {
                    for(Schema.PicklistEntry pickListVal : rolesPLE){
                        if(pickListVal.isActive()) {
                                PicklistWrapper newPicklistOption = new PicklistWrapper();
                            	newPicklistOption.label = pickListVal.getLabel();
                                newPicklistOption.value = pickListVal.getValue();
                            	roleOptions.add(newPicklistOption);
                        }
                    }     
                } else {
                    return new Map<String, List<Object>>{
                        'success' => new List<Boolean>{false},
                        'error' => new List<String>{'We cannot find any role now, please contact your System Administrator'}
                    };
                }

                List<Schema.PicklistEntry> salutationPLE = Contact.Salutation.getDescribe().getPicklistValues();
            
                for(Schema.PicklistEntry pickListVal : salutationPLE){
                    if(pickListVal.isActive()) {
                        PicklistWrapper newPicklistOption = new PicklistWrapper();
                        newPicklistOption.label = pickListVal.getLabel();
                        newPicklistOption.value = pickListVal.getValue();
                        salutationOptions.add(newPicklistOption);
                    }
                } 
                

                List<Org_Switcher_Mapping__mdt> osms = [SELECT AccountRecordType__c FROM Org_Switcher_Mapping__mdt WHERE AccountRecordType__c != null];
                Set<String> accountRecordType = new Set<String>();
                
                for(Org_Switcher_Mapping__mdt osm : osms) {
                    accountRecordType.add(osm.AccountRecordType__c);
                }

                Id userId = UserInfo.getUserId();
                User userInfo = [SELECT Id, ContactId FROM User WHERE Id =: userId];

                List<AccountContactRelation> acrs = [SELECT Id, ContactId, Account.RecordType.DeveloperName, AccountId, Account.Name FROM AccountContactRelation WHERE (EndDate > TODAY OR EndDate = null) AND ContactId =: userInfo.ContactId AND Account.RecordType.DeveloperName IN: accountRecordType];

                if(!acrs.isEmpty()) {
                    for(AccountContactRelation acr : acrs) {
                        PicklistWrapper newPicklistOption = new PicklistWrapper();
                        newPicklistOption.label = acr.Account.Name;
                        newPicklistOption.value = acr.AccountId;
                        organisationOptions.add(newPicklistOption);
                    }
                } else {
                    return new Map<String, List<Object>>{
                        'success' => new List<Boolean>{false},
                        'error' => new List<String>{'We cannot find any role now, please contact your System Administrator'}
                    };
                }

                return new Map<String,List<Object>> {
                    'organisationOptions' => organisationOptions,
                    'roleOptions' => roleOptions,
                    'salutationOptions' => salutationOptions,
                    'success' => new List<Boolean>{true}
                };
            } catch (Exception e) {
                return new Map<String,List<Object>> {
                    'error' => new List<String>{e.getMessage()},
                    'success' => new List<Boolean>{false}
                };
            }
        }

        public Map<String,Object> inviteUser(String inputJson){
            try {
                System.debug('>>>>>>>>>>inputJson ' + inputJson);
                if(String.isBlank(inputJson)) {
                    return new Map<String, Object> {
                        'success' => false,
                        'error' => 'There is no enough details to invite user'
                    };
                }

                userInfoWrapper userInfo = (userInfoWrapper) System.JSON.deserialize(inputJson, userInfoWrapper.class);
                System.debug('>>>>>>>>>>userInfo ' + userInfo);
                userInfoWrapper returnUsrInfo = new userInfoWrapper();

                Integer createList = 0;

                if(String.isBlank(userInfo.firstName) && String.isBlank(userInfo.lastName)) {
                    List<Contact> contact = [SELECT Id, GPMS_myGov_Vanguard_Id__c, FirstName, LastName FROM Contact WHERE GPMS_myGov_Vanguard_Id__c =: userInfo.userEmail];
                    if(contact.isEmpty()) {
                        returnUsrInfo.userExists = false;
                        return new Map<String,Object>{
                            'success' => true,
                            'wrapper' => returnUsrInfo,
                            'createList' => createList
                        };
                    }

                    List<User> usrs = [SELECT Id, ContactId FROM User WHERE ContactId =: contact[0].Id];
                    if(usrs.isEmpty()) {
                        createList++;
                    }

                    List<AccountContactRelation> acrs = [SELECT Id, ContactId, AccountId FROM AccountContactRelation WHERE ContactId =: contact[0].Id AND AccountId =: userInfo.organisation];
                    if(acrs.isEmpty()) {
                        createList+=2;
                    }

                    sendInvitationEmail(userInfo.organisation, contact[0].Id, userInfo.userEmail);
                    returnUsrInfo.userExists = true;
                    returnUsrInfo.firstName = contact[0].FirstName;
                    returnUsrInfo.lastName = contact[0].LastName;
                    return new Map<String,Object>{
                        'success' => true,
                        'wrapper' => returnUsrInfo,
                        'createList' => createList,
                        'userInfo' => userInfo,
                        'contactId' => contact[0].Id
                    };
                } else {
                    List<Contact> contacts = [SELECT Id, GPMS_myGov_Vanguard_Id__c, FirstName, LastName, Birthdate FROM Contact WHERE GPMS_myGov_Vanguard_Id__c =: userInfo.userEmail];
                    Contact contact = new Contact();
                    if(contacts.isEmpty()) {
                        Id gpmsContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('GPMS_Contact').getRecordTypeId();
                        contact.Salutation = userInfo.salutation;
                        contact.FirstName = userInfo.firstName;                
                        contact.LastName = userInfo.lastName;
                        contact.Email = userInfo.userEmail;
                        contact.GPMS_myGov_Vanguard_Id__c = userInfo.userEmail;
                        contact.RecordTypeId = gpmsContactRecTypeId;
                        contact.AccountId = userInfo.organisation;
                        contact.Birthdate = userInfo.dateOfBirth;
                        insert contact;
                    } else {
                        contact = contacts[0];
                    }

                    List<User> usrs = [SELECT Id, ContactId FROM User WHERE ContactId =: contact.Id];
                    if(usrs.isEmpty()) {
                        createList++;
                    }

                    List<AccountContactRelation> acrs = [SELECT Id, ContactId, AccountId FROM AccountContactRelation WHERE ContactId =: contact.Id AND AccountId =: userInfo.organisation];
                    if(acrs.isEmpty()) {
                        createList+=2;
                    }
                    
                    sendInvitationEmail(userInfo.organisation, contact.Id, userInfo.userEmail);
                    returnUsrInfo.userExists = true;
                    returnUsrInfo.firstName = contact.FirstName;
                    returnUsrInfo.lastName = contact.LastName;
                    return new Map<String,Object>{
                        'success' => true,
                        'wrapper' => returnUsrInfo,
                        'createList' => createList,
                        'userInfo' => userInfo,
                        'contactId' => contact.Id
                    }; 
                }
            } catch (Exception e) {
                System.debug('>>>>>>>>>>>>>ERROR MESSAGE :' + e.getMessage());
                return new Map<String,Object> {
                    'error' => e.getMessage(),
                    'success' => false,
                    'createList' => 0
                };
            }
        }

        public void insertACR(String accountId, String contactId, String contactType) {
            AccountContactRelation acr = new AccountContactRelation();
            try{
                acr.AccountId = accountId;
                acr.ContactId = contactId;
                acr.GPMS_Portal_Role__c = contactType;
                insert acr;
            } catch (Exception e) {
                System.debug('>>>>>>>>>>>>>ERROR MESSAGE :: ' + e.getMessage());
                throw new AuraHandledException(e.getMessage());
            }
        }

        public void insertUser(String userEmail, String firstName, String lastName, Id contactId) {
            Profile portalProfile = [SELECT Id FROM Profile WHERE Name='Provider User' Limit 1];
            try{
                User newPortalUser = new User(
                    UserName = userEmail  + '.gpms',
                    FirstName = firstName,
                    LastName = lastName,
                    Alias = lastName.charAt(0) + firstName.length() > 4 ? firstName.substring(0, 4) : firstName.substring(0, firstName.length()) ,
                    email = userEmail,
                    ContactId = contactId,
                    ProfileId = portalProfile.Id,
                    federationIdentifier = userEmail,
                    EmailEncodingKey = 'UTF-8',
                    CommunityNickname = 'User' + String.valueOf(Math.abs(Crypto.getRandomLong())),
                    TimeZoneSidKey = 'Australia/Sydney',
                    LocaleSidKey = 'en_US',
                    LanguageLocaleKey = 'en_US'
                );

                insert newPortalUser;
            } catch (Exception e) {
                System.debug('>>>>>>>>>>>>>ERROR MESSAGE ::: ' + e.getMessage());
                throw new AuraHandledException(e.getMessage());
            }
        }

        public void sendInvitationEmail(String accountId, String contactId, String emailAddress) {
            try {
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.setTargetObjectId(contactId);
                message.setSenderDisplayName('Health Support');
                message.setReplyTo('no-reply@health.gov.au');
                message.setUseSignature(false);
                message.setBccSender(false);
                message.setSaveAsActivity(false);
                EmailTemplate emailTemplate =[SELECT Id, Subject, Description, HtmlValue, DeveloperName, Body FROM EmailTemplate WHERE DeveloperName = 'ExternalUserPortalInvitationNotification_1667173135529' LIMIT 1];
                //Get templete id for set the templete.

                message.setTemplateID(emailTemplate.Id);
                message.setWhatId(accountId); //This is important for the merge fields in template to work
                message.toAddresses = new String[]{emailAddress};

                Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};

                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                
                if (results[0].success) {
                    System.debug('The email was sent successfully.');
                } else {
                    System.debug('The email failed to send: ' + results[0].errors[0].message);
                }    
            } catch (Exception e) {
                dohagedcare.Logger.error(e.getMessage(),e,'GPMSPortalManageUserController').Log();   
            }
        }
    }

    public class userInfoWrapper {
        @AuraEnabled
        public String contactType;
        @AuraEnabled
        public Date dateOfBirth;
        @AuraEnabled
        public String firstName;
        @AuraEnabled
        public String lastName;
        @AuraEnabled
        public String organisation;
        @AuraEnabled
        public String salutation;
        @AuraEnabled
        public String userEmail;
        @AuraEnabled
        public Boolean userExists;
    }

    public class PicklistWrapper {
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;
    }
}