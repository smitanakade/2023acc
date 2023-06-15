/**
 * @testClass QIFileUploadInternalControllerTest
 */
public with sharing class QIFileUploadInternalController {
    @AuraEnabled(cacheable=true)
    public static List<ContactWrapper> getContactsForProvider(Id providerId) {
        List<ContactWrapper> contacts = new List<ContactWrapper>();
        List<AccountContactRelation> relations = [
            SELECT Contact.Id, Contact.Name
            FROM AccountContactRelation
            WHERE AccountId = :providerId
            AND IsActive = TRUE
        ];
        for (AccountContactRelation relation : relations) {
            contacts.add(new ContactWrapper(relation));
        }
        if (contacts.isEmpty()) {
            throw new AuraHandledException('No related contacts for selected provider');
        } else {
            return contacts;
        }
    }

    @AuraEnabled(cacheable=true)
    public static File_Staging__c getFileStagingRecord(String recordId) {
        List<File_Staging__c> records = [
            SELECT Id, Provider__c, Submission_Requested_By__c, Display_Status__c
            FROM File_Staging__c
            WHERE Id = :recordId
        ];
        if (records.isEmpty()) {
            throw new AuraHandledException('File Upload record with ID ' + recordId + ' not found');
        } else {
            return records.get(0);
        }
    }

    public class ContactWrapper {
        @AuraEnabled public Id id;
        @AuraEnabled public String name;

        public ContactWrapper(AccountContactRelation relation) {
            this.id = relation.Contact.Id;
            this.name = relation.Contact.Name;
        }
    }
}