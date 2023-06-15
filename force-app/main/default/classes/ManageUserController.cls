public with sharing class ManageUserController {
    public class EmailDetails {
        @InvocableVariable
        public String emailTemplate;

        @InvocableVariable
        public String acrId;
    }
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getACOInfo () {
        ManageUserInnerClass acoInfo = new ManageUserInnerClass();
        return acoInfo.loadManageUser();
    }
    @AuraEnabled
    public static Map<String, Object> getRelatedContacts (String accountId) {
        ManageUserInnerClass acoInfo = new ManageUserInnerClass();
        return acoInfo.loadRelatedContacts(accountId);
    }
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getPickListValues (String emailId,String accountId) {
        ManageUserInnerClass acoInfo = new ManageUserInnerClass();
        Map<String, Object> result = new Map<String, Object>();
        try {
            result = acoInfo.loadPickListValues(emailId,accountId);
        } catch (QueryException exp) {
            result.put('success',false);
            result.put('error',exp.getMessage());
            dohagedcare.Logger.error(exp.getMessage(),exp, 'GPMS').Log();
        }
        return result;
    }
    @AuraEnabled
    public static Map<String, Object> getHandleInvite (String jsonInput) {
        ManageUserInnerClass acoInfo = new ManageUserInnerClass();
        Map<String, Object> result = acoInfo.handleInvite(jsonInput);
        if((Boolean)result.get('success')) {
            if(!(Boolean)result.get('userExists')) {
                Map<String, Object> userDetails = (Map<String, Object>)result.get('userDetails');
                createUser((String)userDetails.get('firstName'),(String)userDetails.get('lastName'),(String)userDetails.get('email'),(String)result.get('contactId'), (Boolean)result.get('isOrgAdmin'));
            }
        }
        return result;
    }
    @AuraEnabled
    public static Map<String, Object> getManageCompletion (String jsonInput) {
        ManageUserInnerClass acoInfo = new ManageUserInnerClass();
        Map<String, Object> result = acoInfo.handleManageCompletion(jsonInput);
        return result;
    }
    @AuraEnabled
    public static Map<String, Object> getManageUser (String acrId) {
        ManageUserInnerClass acoInfo = new ManageUserInnerClass();
        Map<String, Object> result = acoInfo.manageUser(acrId);

        return result;
    }
    @future
    public static void createUser(String firstName, String lastName, String email,String contactId, Boolean isOrgAdmin) {
        ManageUserInnerClass acoInfo = new ManageUserInnerClass();
        acoInfo.createUser(firstName,lastName,email,contactId,isOrgAdmin);
    }
    @InvocableMethod
    public static List<EmailDetails> sendEmail (List<EmailDetails> emailDetails) {
        String selectedAcr = '';
        String emailTemplate ='';

        for(EmailDetails iterDetail:emailDetails){
            selectedAcr = iterDetail.acrId;
            emailTemplate = iterDetail.emailTemplate;
        }
        selectedAcr.remove('(');
        selectedAcr.remove(')');
        ManageUserInnerClass acoInfo = new ManageUserInnerClass();
        acoInfo.sendInvitationEmail(selectedAcr,emailTemplate);
        return emailDetails;
    }
    private without sharing class ManageUserInnerClass {
        public Map<String, Object> loadManageUser () {
            Map<String, Object> acoMap = loadACO();
            if (!acoMap.isEmpty()){
                return new Map < String, Object > {
                    'accountId' => acoMap.get('accountId'),
                        'accountName' => acoMap.get('accountName'),
                        'integrationId' => acoMap.get('integrationId'),
                        'providers' => loadRelatedProviders((String)acoMap.get('accountId')),
                        'relatedContacts' => loadACOContacts((String)acoMap.get('accountId')),
                        'success' => true
                        };
                            }
            else {
                return new Map < String, Object > {
                    'error' => 'Failed to find Account records',
                        'success' => false
                        };
                            }
        }
        public Map<String, Object> loadRelatedContacts (String accountId) {
            List<Map<String,Object>> relatedContacts = new List<Map<String,Object>>();
            Map<String,Object> relatedContactsReturn = new Map<String,Object>();
            List<String> contId = new list<String>();
            String orgAdminLabel = System.Label.OrganisationAdministrator;
            String acoDevName = System.Label.ACO_Developer_Name;
            List<Schema.PicklistEntry> rolesPickList = AccountContactRelation.Roles.getDescribe().getPicklistValues();
            Date todayDate = Date.today();
            List<AccountContactRelation> getContacts = [Select Id, contactId,account.recordType.DeveloperName, contact.firstName,contact.lastName,contact.GPMS_myGov_Vanguard_Id__c,roles
                                                        FROM AccountContactRelation WHERE AccountId = :accountId AND roles !=:null
                                                        ORDER BY contact.GPMS_myGov_Vanguard_Id__c];
            for(AccountContactRelation iterAcr:getContacts) {
                contId.add(iterAcr.contactId);
            }
            List<User> getUsers = [Select Id,contactId, GPMS_FTLS__c FROM USER WHERE contactId  IN :contId];
            if (!getContacts.isEmpty()) {
                for (AccountContactRelation iterConts:getContacts){
                    Map<String, Object> tempMap = createContactMap(getUsers,iterConts,rolesPickList);
                    if(!tempMap.isEmpty()){
                        relatedContacts.add(tempMap);
                    }
                }
                relatedContactsReturn.put('success',true);
                relatedContactsReturn.put('relatedContacts',relatedContacts);
            }
            return relatedContactsReturn;
        }
        public Map<String, Object> createContactMap(List<User> userList, AccountContactRelation contactToCheck, List<Schema.PicklistEntry> rolesPickList){
            Map<String, Object> returnMap = new Map<String, Object>();
            for (user iterUser:userList) {
                if (contactToCheck.contactId == iterUser.contactId){
                    Map < String, Object > tempMap = new Map < String, Object >();
                    tempMap.put('acrId', contactToCheck.Id);
                    tempMap.put('firstName', contactToCheck.contact.firstName);
                    tempMap.put('lastName', contactToCheck.contact.lastName);
                    tempMap.put('email', contactToCheck.contact.GPMS_myGov_Vanguard_Id__c);
                    tempMap.put('roles', roleLabel(rolesPickList,contactToCheck.roles));
                    tempMap.put('FTLS', iterUser.GPMS_FTLS__c);
                    if (iterUser.Id == UserInfo.getUserId()) {
                        tempMap.put('isCurrentUser', true);
                    }
                    else {
                        tempMap.put('isCurrentUser', false);
                    }
                    returnMap = tempMap;
                }
            }
            return returnMap;
        }
        public String roleLabel(List<Schema.PicklistEntry> rolesPickList, String roles) {
            String roleLabels = '';
            if(!rolesPickList.isEmpty() && roles != null) {
                for(Schema.PicklistEntry pickListVal : rolesPickList){
                    for(String str:roles.split(';')){
                        if(pickListVal.getValue() == str){
                            roleLabels =roleLabels+pickListVal.getLabel()+';';
                        }
                    }
                }
            }
            roleLabels = roleLabels.removeEnd(';');
            return roleLabels;
        }
        public List<Map<String, Object>> loadACOContacts (String accountId) {
            List<Map<String,Object>> relatedContacts = new List<Map<String,Object>>();
            List<String> contId = new list<String>();
            Date todayDate = Date.today();
            List<Schema.PicklistEntry> rolesPickList = AccountContactRelation.Roles.getDescribe().getPicklistValues();
            List<AccountContactRelation> getContacts = [Select Id, contactId, contact.firstName,contact.lastName,contact.GPMS_myGov_Vanguard_Id__c,roles
                                                        FROM AccountContactRelation WHERE AccountId = :accountId AND roles !=:null
                                                        ORDER BY contact.GPMS_myGov_Vanguard_Id__c];
            for(AccountContactRelation iterAcr:getContacts) {
                contId.add(iterAcr.contactId);
            }
            List<User> getUsers = [Select Id,contactId, GPMS_FTLS__c FROM USER WHERE contactId  IN :contId];
            if (!getContacts.isEmpty()) {
                for (AccountContactRelation iterConts:getContacts){
                    Map<String, Object> tempMap = createContactMap(getUsers,iterConts,rolesPickList);
                    if(!tempMap.isEmpty()){
                        relatedContacts.add(tempMap);
                    }
                }
            }
            return relatedContacts;
        }
        public List<Map<String, Object>> loadRelatedProviders (String accountId) {
            List<Map<String,Object>> relatedProviders = new List<Map<String,Object>>();
            List<Account> getAccount = [SELECT Id, Name, Integration_ID__c FROM Account WHERE parentId =: accountId AND recordType.DeveloperName =: 'Approved_Provider'];
            if (!getAccount.isEmpty()) {
                for (Account iterProvider:getAccount){
                    relatedProviders.add(new Map < String, Object > {
                        'accountId' => iterProvider.Id,
                            'accountName' => iterProvider.Name,
                            'integrationId' => iterProvider.Integration_ID__c
                            });
                }
            }
            return relatedProviders;
        }

        public Map<String, Object> loadACO () {
            String acoDevName = System.Label.ACO_Developer_Name;
            Map<String, Object> acoMap = new Map<String, Object>();
                List<AccountContactRelation> getAcr = [SELECT Id,AccountId, Account.Name,Account.Integration_ID__c, roles from AccountContactRelation
                WHERE contactId IN (SELECT contactId FROM User WHERE Id =:UserInfo.getUserId())
                AND Account.RecordType.DeveloperName =: acoDevName
                AND isActive =: true LIMIT 1];
                for (AccountContactRelation iterAco:getAcr) {
                    acoMap.put('accountId', iterAco.accountId);
                    acoMap.put('accountName', iterAco.Account.Name);
                    acoMap.put('integrationId', iterAco.Account.Integration_ID__c);
                }
            return acoMap;
        }
        public Map<String, Object> checkContact(String emailId, String accountId,String contId){
            String contactId;
            Boolean isRoleBlank =false;
            Boolean acrExists =false;
            List<User> getExistingUser = new List<User>();
            Map<String,Object> returnMap = new Map<String,Object>();
            Map<String,Object> existingContactMap = new Map<String,Object>();
            List<AccountContactRelation> existingAcr = new List<AccountContactRelation>();
            List<Contact> getExistintContact = new List<Contact>();
            if(contId!=null){
                getExistintContact = [SELECT Id, firstName,lastName, GPMS_myGov_Vanguard_Id__c,salutation,Birthdate FROM Contact WHERE id =: contId   LIMIT 1];
            } else{
                getExistintContact = [SELECT Id, firstName,lastName, GPMS_myGov_Vanguard_Id__c,salutation,Birthdate FROM Contact WHERE GPMS_myGov_Vanguard_Id__c =: emailId   LIMIT 1];
            }
            if (!getExistintContact.isEmpty()) {
                for (Contact iterCont:getExistintContact){
                    existingContactMap.put('contactId',iterCont.Id);
                    existingContactMap.put('firstName',iterCont.firstName);
                    existingContactMap.put('lastName',iterCont.lastName);
                    existingContactMap.put('email',iterCont.GPMS_myGov_Vanguard_Id__c);
                    existingContactMap.put('birthDate',iterCont.Birthdate);
                    existingContactMap.put('salutation',iterCont.salutation);
                    contactId =iterCont.Id;
                }
                existingAcr = [SELECT Id,roles FROM AccountContactRelation WHERE contactId =: contactId AND accountId=:accountId];
                getExistingUser = [SELECT Id From User WHERE contactId =: contactId];
            }
            if (!getExistintContact.isEmpty()) {
                returnMap.put('contactExists', true);
            }
            else {
                returnMap.put('contactExists', false);
            }
            if (!existingAcr.isEmpty()) {
                for(AccountContactRelation iterAcr:existingAcr){
                    if(iterAcr.roles ==null){
                        isRoleBlank = true;
                    }
                    else{
                        acrExists =true;
                    }
                }
                returnMap.put('isRoleBlank', isRoleBlank);
                returnMap.put('acrExists', acrExists);
            }
            else {
                returnMap.put('isRoleBlank', isRoleBlank);
                returnMap.put('acrExists', acrExists);
            }
            if (!getExistingUser.isEmpty()) {
                returnMap.put('userExists', true);
            }
            else {
                returnMap.put('userExists', false);
            }
            returnMap.put('userDetails',existingContactMap);
            return returnMap;
        }
        public Map<String, Object> loadPickListValues (String emailId, String accountId) {
            List<String> rolesList = new List<String>();
            Map<String, String> serviceIdMap = new Map<String, String>();
            String acoDevName = System.Label.ACO_Developer_Name;
            Map<String,Object> returnMap = new Map<String,Object>();
            String accountRecordType;
            Map<String, Object> checkContact = checkContact(emailId,accountId,null);
            List<Account> accountInvitedTo = [SELECT Id, RecordType.DeveloperName FROM Account WHERE Id =: accountId];
            for (Account iterAcc:accountInvitedTo){
                accountRecordType =iterAcc.RecordType.DeveloperName;
            }
            returnMap.put('contactExists', checkContact.get('contactExists'));
            returnMap.put('acrExists', checkContact.get('acrExists'));
            returnMap.put('userExists', checkContact.get('userExists'));
            returnMap.put('isRoleBlank', checkContact.get('isRoleBlank'));
            returnMap.put('accountId', accountId);
            returnMap.put('accountRecordType', accountRecordType);
            returnMap.put('salutationOptions', salutationOptions());
            returnMap.put('userDetails', checkContact.get('userDetails'));
            returnMap.put('roles', handlePicklist(rolesList, null, null).get('acoRoles'));
            returnMap.put('providerRoles', handlePicklist(rolesList, null, null).get('providerRoles'));
            returnMap.put('serviceRoles', handlePicklist(rolesList, serviceIdMap, accountId).get('serviceRoles'));
            returnMap.put('success', true);
            return returnMap;
        }
        public List<Map<String, Object>> salutationOptions () {
            List<Map<String,Object>> salutationMapList = new List<Map<String,Object>>();
            List<Schema.PicklistEntry> salutationPLE = Contact.Salutation.getDescribe().getPicklistValues();
            for(Schema.PicklistEntry pickListVal : salutationPLE){
                if(pickListVal.isActive()) {
                    salutationMapList.add(new Map<String, Object>{
                        'label'=> pickListVal.getLabel(),
                            'value'=> pickListVal.getValue()
                            });
                }
            }
            return salutationMapList;
        }

        public Map<String, Object> handleInvite (String jsonInput) {
            Map<String, Object> userDetails = new Map<String, Object>();
            Map<String, Object> returnMap = new Map<String, Object>();

            String contactId;
            Boolean isOrgAdmin = false;
            if(String.isBlank(jsonInput)) {
                return new Map<String, Object> {
                    'success' => false,
                        'error' => 'There is no enough details to invite user'
                        };
                            }
            else {
                userDetails = (Map<String, Object>)JSON.deserializeUntyped(jsonInput);
                Map<String, String> serviceRoleMap = convertServiceRoleMap((Map<String, Object>)userDetails.get('relatedServices'));

                String roles='';
                String orgAdminLabel = System.Label.OrganisationAdministrator;
                for(object iterRole:(List<object>)userDetails.get('roles')){
                    roles = roles+iterRole+';';
                    if((String)iterRole == orgAdminLabel){
                        isOrgAdmin = true;
                    }
                }
                for(object iterRole:(List<object>)userDetails.get('serviceRoles')){
                    roles = roles+iterRole+';';
                }
                for(object iterRole:(List<object>)userDetails.get('providerRoles')){
                    roles = roles+iterRole+';';
                }

                Boolean contactExists = (Boolean)userDetails.get('contactExists');
                Boolean acrExists = (Boolean)userDetails.get('acrExists');
                Boolean isRoleBlank = (Boolean)userDetails.get('isRoleBlank');
                Map<string,Object> acrDetails = new Map<string,Object>();
                Map<string,Object> contactDetails =(Map<String, Object>)userDetails.get('userDetails');
                contactId = (String)contactDetails.get('contactId');
                if(!contactExists) {
                    returnMap = createContact (contactDetails,(String)userDetails.get('accountId'));
                    contactId = (String)returnMap.get('contactId');
                    acrDetails.put('isUpdate',true);
                    acrDetails.put('accountId',userDetails.get('accountId'));
                    acrDetails.put('contactId',contactId);
                    acrDetails.put('roles',roles);
                    returnMap = handleACR(acrDetails);
                    if(!serviceRoleMap.isEmpty()){
                        returnMap = createSCR(contactId, serviceRoleMap);
                    }
                }
                else {
                    if (!acrExists && !isRoleBlank) {
                        Map<String,Object> userInfo = (Map<String,Object>)userDetails.get('userDetails');
                        acrDetails.put('isUpdate',false);
                        acrDetails.put('accountId',userDetails.get('accountId'));
                        acrDetails.put('contactId',userInfo.get('contactId'));
                        acrDetails.put('roles',roles);
                        returnMap = handleACR(acrDetails);
                        if(!serviceRoleMap.isEmpty()){
                            returnMap = createSCR(contactId, serviceRoleMap);
                        }
                    }
                    else if(!acrExists && isRoleBlank){
                        Map<String,Object> userInfo = (Map<String,Object>)userDetails.get('userDetails');
                        acrDetails.put('isUpdate',true);
                        acrDetails.put('accountId',userDetails.get('accountId'));
                        acrDetails.put('contactId',userInfo.get('contactId'));
                        acrDetails.put('roles',roles);
                        returnMap = handleACR(acrDetails);
                        if(!serviceRoleMap.isEmpty()){
                            returnMap = createSCR(contactId, serviceRoleMap);
                        }
                    }
                }
            }
            if ((Boolean)returnMap.get('success')){
                returnMap = userDetails;
                returnMap.put('contactId',contactId);
                returnMap.put('success',true);
                returnMap.put('isOrgAdmin', isOrgAdmin);
            }
            return returnMap;
        }
        public Map<String,Object> createContact(Map<String,Object> contactDetails, String accountId){
            Map<String,Object> returnMap = new Map<String,Object>();
            Contact contactToCreate = new Contact();
            String contactId;
            Id gpmsContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('GPMS_Contact').getRecordTypeId();
            contactToCreate.Salutation = (String)contactDetails.get('salutation');
            contactToCreate.FirstName = (String)contactDetails.get('firstName');
            contactToCreate.LastName = (String)contactDetails.get('lastName');
            contactToCreate.Email = (String)contactDetails.get('email');
            contactToCreate.GPMS_myGov_Vanguard_Id__c = (String)contactDetails.get('email');
            contactToCreate.RecordTypeId = gpmsContactRecTypeId;
            contactToCreate.AccountId = accountId;
            contactToCreate.IsPortalUser__c =true;
            contactToCreate.Birthdate = Date.valueOf((String)contactDetails.get('birthDate'));
            try {
                insert contactToCreate;
                contactId =contactToCreate.id;
                returnMap.put('success',true);
            }
            catch (DmlException exp) {
                dohagedcare.Logger.error(exp.getMessage(),exp, 'GPMS').Log();
                returnMap.put('success',false);
                returnMap.put('error',exp.getMessage());
            }
            returnMap.put('contactId',contactId);
            return returnMap;
        }
        public Map<string,Object> handleACR(Map<string,Object> acrDetails){
            Map<string,Object> returnMap = new Map<string,Object>();
            if((Boolean)acrDetails.get('isUpdate')) {
                List<AccountContactRelation> acrList = [SELECT id FROM AccountContactRelation
                                                        WHERE accountId=:(String)acrDetails.get('accountId') AND contactId =: (String)acrDetails.get('contactId') ];
                for(AccountContactRelation iterAcr:acrList){
                    iterAcr.roles = (String)acrDetails.get('roles');
                }
                if(!acrList.isEmpty()){
                    try {
                        update acrList;
                        returnMap.put('success', true);
                    }
                    catch (DmlException exp) {
                        dohagedcare.Logger.error(exp.getMessage(),exp, 'GPMS').Log();
                        returnMap.put('success', false);
                        returnMap.put('error', exp.getMessage());
                    }
                }
            }
            else {
                AccountContactRelation acrToCreate = new AccountContactRelation();
                List<Contact> contactWithoutAccount = [SELECT id, accountId FROM Contact
                                                        WHERE id =:(String)acrDetails.get('contactId') AND accountId =: null LIMIT 1];
                for(Contact iterCont:contactWithoutAccount) {
                    iterCont.accountId = (String)acrDetails.get('accountId');
                }
                if(!contactWithoutAccount.isEmpty()){
                    try {
                        update contactWithoutAccount;
                    }
                    catch (DmlException exp) {
                        dohagedcare.Logger.error(exp.getMessage(),exp, 'GPMS').Log();
                    }
                    List<AccountContactRelation> acrList =[SELECT id FROM AccountContactRelation WHERE accountId=:(String)acrDetails.get('accountId') AND contactId =: (String)acrDetails.get('contactId') ];
                    for(AccountContactRelation iterAcr:acrList){
                        iterAcr.roles = (String)acrDetails.get('roles');
                    }
                    if(!acrList.isEmpty()){
                        try {
                            update acrList;
                            returnMap.put('success', true);
                        }
                        catch (DmlException exp) {
                            dohagedcare.Logger.error(exp.getMessage(),exp, 'GPMS').Log();
                            returnMap.put('success', false);
                            returnMap.put('error', exp.getMessage());
                        }
                    }
                }else {
                    acrToCreate.contactId = (String)acrDetails.get('contactId');
                    acrToCreate.accountId = (String)acrDetails.get('accountId');
                    acrToCreate.roles = (String)acrDetails.get('roles');
                    try {
                        insert acrToCreate;
                        returnMap.put('success', true);
                    }
                    catch (DmlException exp) {
                        dohagedcare.Logger.error(exp.getMessage(),exp, 'GPMS').Log();
                        returnMap.put('success', false);
                        returnMap.put('error', exp.getMessage());
                    }
                }
            }
            return returnMap;
        }

        public Map<String,Object> createSCR(String contactId,Map<String, String> serviceRoleMap) {
            List<Contact_Relationship__c> scrToCreate = new List<Contact_Relationship__c>();
            Map<String, Object> returnMap =new Map<String, Object>();
            String scrRecordTypeId = Schema.SObjectType.Contact_Relationship__c.getRecordTypeInfosByDeveloperName().get('SCR').getRecordTypeId();
            if (!serviceRoleMap.isEmpty()) {
                for(String iterIds:serviceRoleMap.keySet()) {
                    Contact_Relationship__c tempScr = new Contact_Relationship__c();
                    tempScr.Contact__c = contactId;
                    tempScr.Service__c = iterIds;
                    tempScr.Portal_Service_Roles__c = serviceRoleMap.get(iterIds);
                    tempScr.RecordTypeId = scrRecordTypeId;
                    scrToCreate.add(tempScr);
                }
            }
            try {
                insert scrToCreate;
                returnMap.put('success',true);
            }
            catch (DmlException exp) {
                dohagedcare.Logger.error(exp.getMessage(),exp, 'GPMS').Log();
                returnMap.put('success',false);
                returnMap.put('error',exp.getMessage());
            }
            return returnMap;
        }

        public Map<string,Object> handlePickList(List<String> selectPickList,
            Map<String, String> serviceIdMap, Id accountId){

            Map<string,Object> returnPicklist = new Map<string,Object> ();
            Map<string,Object> roleMap = new Map<string,Object> ();
            list<Map<String,Object>> acoRoles = new list<Map<String,Object>>();
            list<Map<String,Object>> providerRoles= new list<Map<String,Object>>();
            list<Map<String,Object>> serviceRoles = new list<Map<String,Object>>();
            List<Schema.PicklistEntry> rolesPickList = AccountContactRelation.Roles.getDescribe().getPicklistValues();
            List<Org_Switcher_Mapping__mdt> metadataList = [SELECT Role__c,IsACORole__c,isProviderRole__c,isServiceRole__c,isQFRRole__c,isQISRRole__c,isGPMSRole__c,isHideExtrernal__c
                                                            FROM Org_Switcher_Mapping__mdt WHERE Role__c != ''];
            Map<String, Org_Switcher_Mapping__mdt> uniqueRoles = new Map<String, Org_Switcher_Mapping__mdt>();
            List<Org_Switcher_Mapping__mdt> uniqueMetadataList = new List<Org_Switcher_Mapping__mdt>();
            for (Org_Switcher_Mapping__mdt orgMetadata : metadataList) {
                if (uniqueRoles.get(orgMetadata.Role__c) == null){
                    uniqueRoles.put(orgMetadata.Role__c, orgMetadata);
                    uniqueMetadataList.add(orgMetadata);
                }
            }
            List<BusinessLicense> getServices =  [SELECT Id, Name, Care_Type__c, Status__c FROM BusinessLicense WHERE accountId =:accountId
                                                    AND (Status__c = 'Operational' OR Status__c = 'Offline') AND Care_Type__c = 'Residential' ORDER BY Name ASC];

            if(selectPickList.isEmpty()){
                for(Org_Switcher_Mapping__mdt iterMetadata:uniqueMetadataList) {
                    if(iterMetadata.isHideExtrernal__c){
                        continue;
                    }
                    for(Schema.PicklistEntry pickListVal : rolesPickList){
                        if (iterMetadata.IsACORole__c && pickListVal.getValue()==iterMetadata.Role__c){
                            acoRoles.add(new Map<String, Object> {'label' => pickListVal.getLabel(),
                                        'value' => pickListVal.getValue(),'isSelected' => false});
                        }
                        else if (iterMetadata.isProviderRole__c  && pickListVal.getValue()==iterMetadata.Role__c) {
                            providerRoles.add(new Map<String, Object> {'label' => pickListVal.getLabel(),'value' => pickListVal.getValue(),'isSelected' => false});
                        }
                        else {
                            if(pickListVal.getValue()==iterMetadata.Role__c){
                                serviceRoles.add(new Map<String, Object> {'label' => pickListVal.getLabel(),'value' => pickListVal.getValue(),'isSelected' => false,
                                'relatedServices' => handleService(serviceIdMap, getServices, pickListVal.getValue())});
                            }
                        }
                    }
                }
            }
            else {
                for(Org_Switcher_Mapping__mdt iterMetadata:uniqueMetadataList) {
                    if(iterMetadata.isHideExtrernal__c){
                        continue;
                    }
                    for(Schema.PicklistEntry pickListVal : rolesPickList){
                        if (iterMetadata.IsACORole__c && pickListVal.getValue()==iterMetadata.Role__c){
                            for(String iterStr:selectPickList){
                                Map<String,Object> tempMap = new Map<String,Object>();
                                if(iterMetadata.Role__c==iterStr){
                                    tempMap.put('label', pickListVal.getLabel());
                                    tempMap.put('value', pickListVal.getValue());
                                    tempMap.put('isSelected', true);
                                    roleMap = tempMap;
                                    break;
                                }
                                else {
                                    tempMap.put('label', pickListVal.getLabel());
                                    tempMap.put('value', pickListVal.getValue());
                                    tempMap.put('isSelected', false);
                                    roleMap = tempMap;
                                }
                            }
                            acoRoles.add(roleMap);
                        }
                        else if (iterMetadata.isProviderRole__c && pickListVal.getValue()==iterMetadata.Role__c) {
                            for(String iterStr:selectPickList){
                                Map<String,Object> tempMap = new Map<String,Object>();
                                if(iterMetadata.Role__c==iterStr){
                                    tempMap.put('label', pickListVal.getLabel());
                                    tempMap.put('value', pickListVal.getValue());
                                    tempMap.put('isSelected', true);
                                    roleMap = tempMap;
                                    break;
                                }
                                else {
                                    tempMap.put('label', pickListVal.getLabel());
                                    tempMap.put('value', pickListVal.getValue());
                                    tempMap.put('isSelected', false);
                                    roleMap = tempMap;
                                }
                            }
                            providerRoles.add(roleMap);
                        }
                        else {
                            if(pickListVal.getValue()==iterMetadata.Role__c){
                                for(String iterStr:selectPickList){
                                    Map<String,Object> tempMap = new Map<String,Object>();
                                    if(iterMetadata.Role__c==iterStr){
                                        tempMap.put('label', pickListVal.getLabel());
                                        tempMap.put('value', pickListVal.getValue());
                                        tempMap.put('isSelected', true);
                                        tempMap.put('relatedServices', handleService(serviceIdMap, getServices, pickListVal.getValue()));
                                        roleMap = tempMap;
                                        break;
                                    }
                                    else {
                                        tempMap.put('label', pickListVal.getLabel());
                                        tempMap.put('value', pickListVal.getValue());
                                        tempMap.put('isSelected', false);
                                        tempMap.put('relatedServices', handleService(serviceIdMap, getServices, pickListVal.getValue()));
                                        roleMap = tempMap;
                                    }
                                }
                                serviceRoles.add(roleMap);
                            }
                        }
                    }
                }
            }
            returnPicklist.put('acoRoles',acoRoles);
            returnPicklist.put('providerRoles',providerRoles);
            returnPicklist.put('serviceRoles',serviceRoles);
            return returnPicklist;
        }
        //Manage Users
        public List<Map<string,Object>> handleService(Map<String, String> serviceIdMap, List<BusinessLicense> services, String role){
            list<Map<String,Object>> serviceRecords = new list<Map<String,Object>>();
            Map<String,Object> serviceMap = new Map<String,Object>();

            if (serviceIdMap == null || serviceIdMap.isEmpty()) {
                for (BusinessLicense iterService:services) {
                    serviceRecords.add(new Map<String, Object> {
                        'serviceId'=> iterService.Id,
                            'value'=> iterService.Id,
                            'label'=> iterService.Name,
                            'name' => iterService.Name,
                            'careType' => iterService.Care_Type__c,
                            'isSelected' => false
                            });
                }
            }
            else {
                for (BusinessLicense iterService:services) {
                    for (String iterServiceId:serviceIdMap.keySet()){
                        Map<String,Object> tempMap = new Map<String,Object>();
                        List<String> serviceRoles = serviceIdMap.get(iterServiceId).split(';');
                        if(iterService.id == iterServiceId){
                            tempMap.put('serviceId',iterService.Id);
                            tempMap.put('value',iterService.Id);
                            tempMap.put('label',iterService.Name);
                            tempMap.put('name',iterService.Name);
                            tempMap.put('careType',iterService.Care_Type__c);
                            tempMap.put('isSelected',serviceRoles.contains(role));
                            serviceMap = tempMap;
                            break;
                        }
                        else {
                            tempMap.put('serviceId',iterService.Id);
                            tempMap.put('value',iterService.Id);
                            tempMap.put('label',iterService.Name);
                            tempMap.put('name',iterService.Name);
                            tempMap.put('careType',iterService.Care_Type__c);
                            tempMap.put('isSelected',false);
                            serviceMap = tempMap;
                        }
                    }
                    serviceRecords.add(serviceMap);
                }
            }

            return serviceRecords;
        }

        public Map<String, String> getRelatedService(String contactId) {
            Map<String, String> serviceIdMap = new Map<String, String>();
            List<Contact_Relationship__c> getService = [SELECT Id, service__c, Portal_Service_Roles__c FROM Contact_Relationship__c WHERE contact__c =: contactId AND Portal_Service_Roles__c !=:''];

            for(Contact_Relationship__c iterService:getService) {
                serviceIdMap.put(iterService.service__c, iterService.Portal_Service_Roles__c);
            }

            return serviceIdMap;
        }

        public Map<String, Object> manageUser(String acrId) {
            List<String> rolesList = new List<String>();
            String acoDevName = System.Label.ACO_Developer_Name;
            Map<String,Object> returnMap = new Map<String,Object>();
            String emailId;
            String accountId;
            String contactId;
            String accountRecordType;
            List<AccountContactRelation> selectedAcr = [SELECT Id, accountId, ContactId,Roles,Account.RecordType.DeveloperName,Contact.GPMS_myGov_Vanguard_Id__c
                                                        FROM AccountContactRelation WHERE Id=:acrId];
            for(AccountContactRelation iterAcr:selectedAcr) {
                accountId = iterAcr.accountId;
                contactId = iterAcr.ContactId;
                emailId = iterAcr.Contact.GPMS_myGov_Vanguard_Id__c;
                accountRecordType= iterAcr.Account.RecordType.DeveloperName;
                rolesList = iterAcr.Roles.split(';');
            }
            Map<String, String> serviceIdMap = getRelatedService(contactId);
            Map<String, Object> checkContact = checkContact(emailId,accountId,contactId);
            returnMap.put('contactExists', checkContact.get('contactExists'));
            returnMap.put('acrExists', checkContact.get('acrExists'));
            returnMap.put('userExists', checkContact.get('userExists'));
            returnMap.put('accountId', accountId);
            returnMap.put('accountRecordType', accountRecordType);
            returnMap.put('salutationOptions', salutationOptions());
            returnMap.put('userDetails', checkContact.get('userDetails'));
            returnMap.put('providerRoles', handlePicklist(rolesList, null, null).get('providerRoles'));
            returnMap.put('roles', handlePicklist(rolesList, null, null).get('acoRoles'));
            returnMap.put('serviceRoles', handlePicklist(rolesList, serviceIdMap, accountId).get('serviceRoles'));
            returnMap.put('success', true);
            return returnMap;

        }

        public void createUser(String firstName, String lastName, String email,String contactId, Boolean isOrgAdmin){
            String uniqueString = String.valueOf(DateTime.now().getTime());
            User invitedUser = new User();
            Profile userProfile = new Profile();
            if(isOrgAdmin) {
                userProfile = [SELECT Id FROM profile WHERE name =: 'Org Admin' LIMIT 1];
            }
            else {
                userProfile = [SELECT Id FROM profile WHERE name =: 'Provider User' LIMIT 1];
            }
            invitedUser.FirstName = firstName;
            invitedUser.LastName = lastName;
            invitedUser.Email = email;
            invitedUser.Alias = firstName.left(1) + lastName.left(4);
            invitedUser.Username = invitedUser.Alias+'_'+email;
            invitedUser.federationIdentifier = email;
            invitedUser.ProfileId = userProfile.Id;
            invitedUser.TimeZoneSidKey = 'Australia/Sydney';
            invitedUser.LocaleSidKey = 'en_AU';
            invitedUser.LanguageLocaleKey = 'en_US';
            invitedUser.EmailEncodingKey = 'UTF-8';
            invitedUser.ContactId = contactId;
            invitedUser.IsActive = TRUE;
            invitedUser.CommunityNickname = invitedUser.Alias +'_'+ uniqueString;
            try {
                insert invitedUser;
            }
            catch (DmlException exp) {
                dohagedcare.Logger.error(exp.getMessage(),exp, 'GPMS-Portal-Invite User').Log();
            }
        }
        public void sendInvitationEmail(String acrId,String templateName) {
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            String orgWideEmailId;
            List<OrgWideEmailAddress> orgWideEmail = [select Id from OrgWideEmailAddress where displayName =: Org_Wide_Email__c.getInstance().Display_name__c LIMIT 1];
            if(!orgWideEmail.isEmpty()){
                for(OrgWideEmailAddress iterEmail:orgWideEmail) {
                    orgWideEmailId = iterEmail.id;
                }
            }
            String contactId;
            String accountId;
            String emailAddress;
            List<AccountContactRelation> acrDetail = [SELECT id, contactId,accountId,contact.email FROM AccountContactRelation WHERE id =: acrId LIMIT 1];
            for(AccountContactRelation iterAcr:acrDetail){
                contactId = iterAcr.contactId;
                accountId = iterAcr.accountId;
                emailAddress = iterAcr.contact.email;
            }
            message.setTargetObjectId(contactId);
            if(orgWideEmailId!=null) {
                message.orgwideemailaddressid = orgWideEmailId;
            }
            else{
                message.setSenderDisplayName('Health Support');
            }
            message.setReplyTo('no-reply@health.gov.au');
            message.setUseSignature(false);
            message.setBccSender(false);
            message.setSaveAsActivity(true);
            List<EmailTemplate> emailTemplate =[SELECT Id, Subject, Description, HtmlValue, DeveloperName, Body FROM EmailTemplate WHERE DeveloperName =: templateName LIMIT 1];
            //Get templete id for set the templete.
            if(emailTemplate!=null && !emailTemplate.isEmpty()){
                message.setTemplateID(emailTemplate[0].Id);
            }
            message.setWhatId(accountId); //This is important for the merge fields in template to work
            message.toAddresses = new String[]{emailAddress};

                if(emailTemplate!=null && !emailTemplate.isEmpty()){
                    Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
                        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);

                    if (!results[0].success) {
                        dohagedcare.Logger.Info(results[0].errors[0].message);
                    }
                }

        }
        public Map<String, Object> handleManageCompletion(String jsonInput) {
            Map<String, Object> returnMap = new Map<String,Object>();
            Map<String, Object> updateDetails = (Map<String, Object>)JSON.deserializeUntyped(jsonInput);
            if((Boolean)updateDetails.get('isRemoveUser') && !(Boolean)updateDetails.get('isUpdateUser')){
                returnMap = removeUser((String)updateDetails.get('acrId'));
            }
            else {
                returnMap = updateRole (updateDetails);
            }
            return returnMap;
        }
        public Map<String, Object> removeUser(string acrId){
            AccountContactRelation acrToRemove = new AccountContactRelation();
            Map<String, Object> returnMap = new Map<String,Object>();
            String orgAdminRole = 'Organisation Administrator';
            String starRatingReviewerRole = 'Star Rating Reviewer';
            String contactId;
            String accountId;
            String recordType;
            string newRoles ='';
            List<String> roles = new List<String>();
            for(AccountContactRelation iterAcr:[SELECT contactId, accountId,roles,account.recordType.developerName FROM AccountContactRelation WHERE Id =:acrId]) {
                contactId = iterAcr.contactId;
                accountId = iterAcr.accountId;
                roles = iterAcr.roles.split(';');
                recordType = iterAcr.account.recordType.developerName;
            }
            String scrRecordTypeId = Schema.SObjectType.Contact_Relationship__c.getRecordTypeInfosByDeveloperName().get('SCR').getRecordTypeId();
            List<Contact_Relationship__c> scrToUpdate = new List<Contact_Relationship__c>();
            List<Contact_Relationship__c> existingScr = [SELECT id, role__c, contact__c,service__c FROM Contact_Relationship__c WHERE contact__c=:contactId
                                                         AND RecordTypeId =: scrRecordTypeId AND service__r.Account.Id =: accountId];
            for(Contact_Relationship__c iterScr:existingScr) {
                iterScr.Portal_Service_Roles__c = '';
                scrToUpdate.add(iterScr);
            }
            if (!scrToUpdate.isEmpty()){
                try {
                    update scrToUpdate;
                    returnMap.put('success', true);
                }
                catch (DmlException exp) {
                    dohagedcare.Logger.error(exp.getMessage(),exp, 'GPMS').Log();
                    returnMap.put('success', false);
                    returnMap.put('error', exp.getMessage());
                }
            }
            List<String> listRole = new List<String>();
            for(Org_Switcher_Mapping__mdt osMap : [SELECT Role__c FROM Org_Switcher_Mapping__mdt WHERE IsACORole__c = true]){
                listRole.add(osMap.Role__c);
            }
            for(string iterRole:roles){
                if(recordType==System.Label.ACO_Developer_Name){
                    if(!listRole.contains(iterRole)){
                        newRoles = newRoles+';'+iterRole;
                    }
                }
                else{
                    if(listRole.contains(iterRole)){
                        newRoles = newRoles+';'+iterRole;
                    }
                }
            }
            acrToRemove.id = acrId;
            acrToRemove.roles = newRoles;
            try {
                update acrToRemove;
                returnMap.put('success', true);
            }
            catch (DmlException exp) {
                dohagedcare.Logger.error(exp.getMessage(),exp, 'GPMS').Log();
                returnMap.put('success', false);
                returnMap.put('error', exp.getMessage());
            }
            return returnMap;
        }
        public Map<String, Object> updateRole(
            Map<String, Object> updateDetails){

            List<String> serviceRole = new List<String> ();
            List<AccountContactRelation> acrToUpdate = new List<AccountContactRelation>();
            List<Contact_Relationship__c> scrToUpdate = new List<Contact_Relationship__c>();
            Map<String, Object> returnMap = new Map<String,Object>();
            Map<String, String> serviceRoleMap = convertServiceRoleMap((Map<String,Object>)updateDetails.get('relatedServices'));
            Map<String, String> serviceRoleToCreateMap = new Map<String,String>();

            String contactId;
            String accountId;
            String scrRecordTypeId = Schema.SObjectType.Contact_Relationship__c.getRecordTypeInfosByDeveloperName().get('SCR').getRecordTypeId();
            for(AccountContactRelation iterAcr:[SELECT contactId, accountId FROM AccountContactRelation WHERE Id =:(String)updateDetails.get('acrId')]) {
                contactId = iterAcr.contactId;
                accountId = iterAcr.accountId;
            }
            List<Contact_Relationship__c> existingScr = [SELECT id, role__c, contact__c,service__c FROM Contact_Relationship__c WHERE contact__c=:contactId
                                                         AND RecordTypeId =: scrRecordTypeId AND service__r.Account.Id =: accountId];
            for(object iterRole:(List<object>)updateDetails.get('serviceRoles')){
                serviceRole.add((String)iterRole);
            }
            if(serviceRole.isEmpty()){
                for(Contact_Relationship__c iterScr:existingScr) {
                    iterScr.Portal_Service_Roles__c = '';
                    scrToUpdate.add(iterScr);
                }
            }
            else {
                if(existingScr.isEmpty()) {
                    returnMap = createSCR(contactId,serviceRoleMap);
                } else {
                    for(Contact_Relationship__c iterScr:existingScr) {
                        Boolean matchFound = false;
                        for(String iterIds:serviceRoleMap.keySet()) {
                            if (iterScr.service__c ==iterIds) {
                                matchFound = true;
                            }
                        }
                        if (matchFound) {
                            iterScr.Portal_Service_Roles__c = serviceRoleMap.get(iterScr.service__c);
                            scrToUpdate.add(iterScr);
                        }
                        else {
                            iterScr.Portal_Service_Roles__c = '';
                            scrToUpdate.add(iterScr);
                        }
                    }
                    for(String iterIds:serviceRoleMap.keySet()) {
                        Boolean matchFound = false;
                        for(Contact_Relationship__c iterScr:existingScr) {
                            if (iterScr.service__c ==iterIds) {
                                matchFound = true;
                            }
                        }
                        if (!matchFound) {
                            serviceRoleToCreateMap.put(iterIds, serviceRoleMap.get(iterIds));
                        }
                    }
                    returnMap = createSCR(contactId,serviceRoleToCreateMap);
                }
            }

            if (!scrToUpdate.isEmpty()) {
                try {
                    update scrToUpdate;
                    returnMap.put('success', true);
                }
                catch (DmlException exp) {
                    dohagedcare.Logger.error(exp.getMessage(),exp, 'GPMS').Log();
                    returnMap.put('success', false);
                    returnMap.put('error', exp.getMessage());
                }
            }
            if ((String)updateDetails.get('acrId')!=null) {
                AccountContactRelation tempAcr = new AccountContactRelation();
                String roles = '';
                for(object iterRole:(List<object>)updateDetails.get('roles')){
                    roles = roles+iterRole+';';
                }
                for(object iterRole:(List<object>)updateDetails.get('serviceRoles')){
                    roles = roles+iterRole+';';
                }
                for(object iterRole:(List<object>)updateDetails.get('providerRoles')){
                    roles = roles+iterRole+';';
                }
                tempAcr.id = (String)updateDetails.get('acrId');
                tempAcr.roles = roles;
                tempAcr.EndDate =null;
                acrToUpdate.add(tempAcr);
                Try {
                    update acrToUpdate;
                    returnMap.put('success', true);
                }
                catch (DmlException exp) {
                    dohagedcare.Logger.error(exp.getMessage(),exp, 'GPMS').Log();
                    returnMap.put('success', false);
                    returnMap.put('error', exp.getMessage());
                }
            }
            return returnMap;
        }

        private Map<String, String> convertServiceRoleMap(Map<String, Object> details){
            Map<String,List<Object>> relatedService = new Map<String,List<Object>>();
            Map<String, String> serviceRoleMap = new Map<String,String>();
            for(String d: details.keySet()){
                relatedService.put(d, (List<Object>)details.get(d));
            }

            for(String sRole: relatedService.keySet()){
                for(object sId: relatedService.get(sRole)) {
                    serviceRoleMap.put((String)sId, serviceRoleMap.get((String)sId) != null ? serviceRoleMap.get((String)sId) + ';' + sRole : sRole);
                }
            }
            return serviceRoleMap;
        }
    }


}
