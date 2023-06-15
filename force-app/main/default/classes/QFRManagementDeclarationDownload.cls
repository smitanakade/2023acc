public with sharing class QFRManagementDeclarationDownload {

  @AuraEnabled
  public static String getDeclarationFile(Id recordId) {
    List<ContentDocumentLink> files = [SELECT Id, ContentDocument.LatestPublishedVersion.PathOnClient
    FROM ContentDocumentLink
    WHERE LinkedEntityId = :recordId];
    for (ContentDocumentLink file : files) {
      if (file.ContentDocument.LatestPublishedVersion.PathOnClient.containsIgnoreCase('QFR Declaration')) {
        return file.Id;
      }
    }
    return null; 
  }
}
