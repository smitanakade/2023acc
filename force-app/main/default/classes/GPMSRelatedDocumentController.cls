public with Sharing class GPMSRelatedDocumentController {

    @AuraEnabled(cacheable=true)
    public static RelatedDocument getRelatedDocuments(String recordId) {
        System.debug(recordId);
        List<ContentVersion> lstwrp = new List<ContentVersion>();
        try{
            List<ContentDocumentLink> lstContentDocLink = [SELECT ContentDocumentId, LinkedEntityId  FROM ContentDocumentLink where LinkedEntityId =: recordId];
            
            if(lstContentDocLink.isEmpty()) return new RelatedDocument(null,0);

            List<String> docId = new List<String>();
            for(ContentDocumentLink con:lstContentDocLink){
                docId.add(con.ContentDocumentId);
            }
            lstwrp = [SELECT Id,Received_Date__c,ContentDocumentId, Description, Title  FROM ContentVersion  where IsLatest = true and ContentDocumentId =: docId ORDER By Received_Date__c desc];
            
            Integer size = lstwrp.isEmpty()?0:lstwrp.size();
            RelatedDocument result = new RelatedDocument(lstwrp,size);
            return result;

        }catch(Exception e){
            System.debug(e.getMessage());
            return null;
        }
        
        
    }

    @AuraEnabled
    public static string deleteRelatedDocument(String ids) {
        System.debug(ids);
        try {
            delete [Select id FROM ContentDocument WHERE Id =: ids];
            return 'Success: Record Deleted successfully.';
        }catch (Exception e) {
            return 'The following exception has occurred: ' + e.getMessage();
        }
    }

    @AuraEnabled
    public static string updateRelatedDocument(Object data) {
        
        List<ContentVersion> filessForUpdate = (List<ContentVersion>) JSON.deserialize(JSON.serialize(data),List<ContentVersion>.class);

        try {
            update filessForUpdate;
            return 'Success: Documents updated successfully';
        }catch (Exception e) {
            return 'The following exception has occurred: ' + e.getMessage();
        }
    }

    @TestVisible
    public class RelatedDocument{
        @AuraEnabled public List<ContentVersion> documents;
        @AuraEnabled public Integer documentsSize;

        public RelatedDocument(List<ContentVersion> documents, Integer documentsSize){
            this.documents = documents;
            this.documentsSize = documentsSize;
        }
    }

}