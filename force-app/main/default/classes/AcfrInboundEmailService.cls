/****************************************************************************************************
 * @Description : Inbound Email Service for QFR
 ****************************************************************************************************
 * @testClass AcfrInboundEmailServiceTest
 *****************************************************************************************************/
global with sharing class AcfrInboundEmailService implements Messaging.InboundEmailHandler {
  global Messaging.InboundEmailResult handleInboundEmail(
    Messaging.inboundEmail email,
    Messaging.InboundEnvelope env
  ) {
    Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
    try{
    
    Task t=new Task();
    t.Type = 'Inbound Email';
    t.Category__c = 'QFR - General';
    t.Status='Completed';
    t.RecordtypeId=Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Communication_Task').getRecordTypeId();
	  t.subject=email.Subject;
	  t.Description=email.plainTextBody ;
    String caseNumb;
    String senderEmail;
    List<Case> caseList = new List<Case>();
    List<Contact> contactList = new List<Contact>();
	  List<User> assignedToList=new List<User>([select id from user where email=:email.fromAddress and isActive=True and profile.name='Health User' LIMIT 1]);
    
      if(assignedToList.size()>0) {
            t.OwnerId=assignedToList[0].id;
      }
        
      if (email.Subject != null) {
        if (email.subject.contains('Case Number:')) {
          caseNumb = email.subject.substringAfter('Case Number:').substring(0, 8);
        } else if (email.subject.contains('case number:')) {
          caseNumb = email.subject.substringAfter('case number:').substring(0, 8);
        }
      }

      if (caseNumb != null) {
        caseList = new List<Case>(
          [SELECT id, casenumber FROM case WHERE casenumber = :caseNumb]
        );
      }
      if (caseList.size() < 1) {
        caseList = new List<Case>(
          [
            SELECT id, casenumber
            FROM case
            WHERE subject = 'QFR Unresolved Items'
          ]
        );
      }
    t.whatId = caseList[0].id;
	 

    if (email.plainTextBody.contains('Sender:(')) {
        senderEmail = email.plainTextBody.substringafter('Sender:(')
          .subStringBefore('<');
      }

    if (senderEmail != null) {
        contactList = new List<Contact>(
          [SELECT id FROM Contact WHERE email = :senderEmail]
        );
    }

    if (contactList.size() > 0) {
      	t.WhoId=contactList[0].id;
    }
    Database.insert(t);

    if (
        email.binaryAttachments != null &&
        email.binaryAttachments.size() > 0
      ) {
        List<ContentVersion> contentVersionList = new List<ContentVersion>();
        List<Id> contentDocumentList = new List<Id>();
        Set<Id> contentDocumentSet = new Set<Id>();
        List<ContentDocumentLink> contenDocLinkList = new List<ContentDocumentLink>();
        //emailMessageList=[select id,ActivityId from EmailMessage where id=:emailMessage.Id LIMIT 1];
        for (integer i = 0; i < email.binaryAttachments.size(); i++) {
          ContentVersion ContVerFile = new ContentVersion();
          ContVerFile.VersionData = email.binaryAttachments[i].body;
          ContVerFile.Title = email.binaryAttachments[i].filename;
          ContVerFile.ContentLocation = 'S';
          ContVerFile.PathOnClient = email.binaryAttachments[i].filename;
          contentVersionList.add(ContVerFile);
        }

        if (contentVersionList.size() > 0) {
          Database.insert(contentVersionList);
        }
		List<ContentVersion> insertedCVList=[select id,ContentDocumentId from contentversion where id IN :contentVersionList];
        for (ContentVersion cv : insertedCVList) {
          contentDocumentList.add(cv.ContentDocumentId);
          contentDocumentSet.add(cv.ContentDocumentId);
        }
        for (Id conDoc : contentDocumentSet) {
          ContentDocumentLink cDe = new ContentDocumentLink();
          cDe.ContentDocumentId = conDoc;
          cDe.LinkedEntityId = t.Id;
          cDe.ShareType = 'V';
          cDe.Visibility = 'AllUsers';
          contenDocLinkList.add(cDe);
        }
        if (contenDocLinkList.size() > 0) {
          Database.insert(contenDocLinkList);
        }
          if(contentDocumentList.size()>0){
            calloutTRIMs(t.Id,contentDocumentList);  
          } 
      }
    } catch (Exception exp) {
      dohagedcare.Logger.error(
          exp.getMessage(),
          exp,
          'AcfrInboundEmailService.handleInboundEmail'
        )
        .Log();
    }
    return result;
  }
  @future(callout=true)
  public static void calloutTRIMs(String parentId, List<Id> contentDocList) {
      
    dohagedcare.FileStorageListController.uploadFilesToTRIMExt(
      parentId,
      contentDocList
    );
  }
 
  
}