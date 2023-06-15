/**
* author: Peter Xiang
* date: 26/04/2023
* description: Apex class that handles sending email notification after bulk uploads.
* @testClass  : QIFileStagingTriggerHandlerTest
** Updated BY: AG - 21-05-2023 - Added afterInsert for implementing Apex sharing
**/

public with sharing class QIFileStagingTriggerHandler implements afterUpdate, afterInsert {

    private static final String EMAIL_TEMPLATE = 'QI_Bulk_Upload_Email_Notification';
    private static final String EMAIL_TEMPLATE2 = 'QI_Bulk_Upload_Email_Notification2';
    private static final String EMAIL_TEMPLATE3 = 'QI_Bulk_Upload_Email_Notification3';
    public static final String QI_RECORDTYPEDEVELOPERNAME = 'QI';
    public static void afterUpdate(Map<Id, SObject> newMap, Map<Id,SObject> oldMap){
        List<EmailTemplate> emailList = [SELECT Id,HtmlValue,Body,DeveloperName from EmailTemplate 
            WHERE DeveloperName = :EMAIL_TEMPLATE 
            OR DeveloperName = :EMAIL_TEMPLATE2
            OR DeveloperName = :EMAIL_TEMPLATE3];
		Map <String, EmailTemplate> emailMap = new Map<String, EmailTemplate>();
        for(EmailTemplate email: emailList){
            emailMap.put(email.DeveloperName, email);
        }
        
		Map<ID, File_Staging__c> notificationMap = new Map<ID, File_Staging__c>();
		Map<ID, File_Staging__c> statusUpdateMap = new Map<ID, File_Staging__c>();
		Map<ID, File_Staging__c> serviceUpdateMap = new Map<ID, File_Staging__c>();

        List<ID> createdById = new List<ID>();
        for(File_Staging__c newFileStaging : (List<File_Staging__c>) newMap.values()) {
            createdById.add(newFileStaging.CreatedById);
        }
        List<User> userProfile = [SELECT Profile.Name, email, Contact.Account.Name, Id FROM User WHERE Id IN :(createdById)];
        Map<ID, User> userMap = new Map<ID, User>(userProfile);
        String benchMarkerOrgName = '';

		for(File_Staging__c newFileStaging : (List<File_Staging__c>) newMap.values()) {
            File_Staging__c oldFileStaging = (File_Staging__c) oldMap.get(newFileStaging.Id);
            
			if((newFileStaging.Display_Status__c == 'Failed' || newFileStaging.Display_Status__c == 'Partial') 
            && newFileStaging.Display_Status__c != oldFileStaging.Display_Status__c){
				notificationMap.put(newFileStaging.Id ,newFileStaging);
               
			}else if(newFileStaging.Status__c == 'Ready To Publish' && oldFileStaging.Status__c == 'New'){
				statusUpdateMap.put(newFileStaging.Id,newFileStaging);
			}else if(newFileStaging.Status__c=='Processed' && newFileStaging.Success_Records__c > 0 && newFileStaging.Status__c != oldFileStaging.Status__c){
                User qiUser = userMap.get(newFileStaging.CreatedById);
				if(qiUser.Profile.Name == 'QI Benchmarker'){
					serviceUpdateMap.put(newFileStaging.Id,newFileStaging);
                    benchMarkerOrgName = qiUser.Contact.Account.Name;
				}
			} 
		}
        SendEmailNotificationService notificationService = new SendEmailNotificationService();
		//This code is for the Failed notifications
        EmailTemplate et1 = emailMap.get(EMAIL_TEMPLATE);
		if(et1!=null){
			
            
			List<Messaging.SingleEmailMessage> mesgList = new List <Messaging.SingleEmailMessage> ();
            
            for(Id Key:notificationMap.keySet()) {
                Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
                File_Staging__c filerecord = notificationMap.get(key);
                User notifiedUser = userMap.get(filerecord.CreatedById);
                List<String> toAddress = new List<String>();
                toAddress.add(notifiedUser.Email);
                
                msg = notificationService.prepareEmailList2(toAddress, et1.Id, notifiedUser.Id, Key);
              	mesgList.add(msg);
                
            }
          
                
			notificationService.sendEmailFromList(mesgList);
		}
		//This code is for the update notifications
        EmailTemplate et2 = emailMap.get(EMAIL_TEMPLATE2);
		if(et2!=null){
			List<Messaging.SingleEmailMessage> mesgList = new List <Messaging.SingleEmailMessage> ();
            
            for(Id Key:statusUpdateMap.keySet()) {
                Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
                File_Staging__c filerecord = statusUpdateMap.get(key);
                User notifiedUser = userMap.get(filerecord.CreatedById);
                List<String> toAddress = new List<String>();
                toAddress.add(notifiedUser.Email);
                msg = notificationService.prepareEmailList2(toAddress, et2.Id, notifiedUser.Id, Key);
              	mesgList.add(msg);
                
            }
			
			notificationService.sendEmailFromList(mesgList);
		}

		//This code is for the bench marker update notifications
        EmailTemplate et3 = emailMap.get(EMAIL_TEMPLATE3);
		if(et3!=null){
			List<Quality_Indicator_Summary__c> qisRecords = [
                SELECT Service__c,Service__r.Name, Service__r.Integration_ID__c, PROVIDER_ID__c,Originating_File_Upload__r.Id,Originating_File_Upload__c, NAPS_SERVICE_ID__c
                FROM Quality_Indicator_Summary__c 
                WHERE Originating_File_Upload__c 
                IN :(serviceUpdateMap.keyset()) AND QIS_Versions__c > 1
            ];
           
			Map<Id,Quality_Indicator_Summary__c> qisMap= new Map<Id,Quality_Indicator_Summary__c>(qisRecords);
			Map<File_Staging__c, List<Quality_Indicator_Summary__c>> qisStagingMap = new Map<File_Staging__c, List<Quality_Indicator_Summary__c>>();
			Set<Id> accountIDs = new Set<ID>();
			
            for(Quality_Indicator_Summary__c qis:qisRecords){
                
                accountIDs.add(qis.PROVIDER_ID__c);
                
            }
			
			if(accountIDs != null){
				List<AccountContactRelation> acctRelatnList = [SELECT Id,ContactId,AccountId, Roles, Contact.Email, Contact.Email_Body__c FROM AccountContactRelation
                                                                    WHERE Roles INCLUDES('QI Role - Org') AND Roles INCLUDES('Organisation Administrator')
                                                                  AND AccountId IN :(accountIds) AND Contact.Email != null] ;
				List<Messaging.SingleEmailMessage> mesgList = new List <Messaging.SingleEmailMessage> ();
                
                
                //Map<ID, List<BusinessLicense>> contactServiceMap = new Map<Id, List<BusinessLicense>>();
                Set<Contact> contactSet = new Set<Contact>();
                
                for(AccountContactRelation acr: acctRelatnList){
                    
                    Contact singleContact = new Contact();
                    String emailBody = 'QI Program data for the below Services has been updated by: ' + benchMarkerOrgName + '\n' + '\n' +'NAPS Id & Name:';
                    for(Quality_Indicator_Summary__c qis:qisRecords){
	
                        if(acr.AccountId == qis.PROVIDER_ID__c){
                            singleContact.id = acr.ContactId;
                            if(qis.NAPS_SERVICE_ID__c == null){
                                qis.NAPS_SERVICE_ID__c = '';
                            }
                            emailBody = emailBody + '\n' + '    NAPS ID: <'+ qis.Service__r.Integration_ID__c + '>, Serivce name: <' + qis.Service__r.Name + '>';
                            
                        }
                    }
                    if(emailBody != acr.Contact.Email_Body__c)
                    {
                        singleContact.Email_Body__c = emailBody;
                    }
                    singleContact.Email = acr.Contact.Email;
					contactSet.add(singleContact);
                }
    
                
                if(contactSet != null){

                    List<Contact> contactList = new List <Contact>(contactSet); //putting contact from set into list for DML statement.
                    update contactList;
                    for(Contact con:contactSet){
                        Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
                        List<String> toAddress = new List<String>();
                        toAddress.add(con.Email);
                        msg = notificationService.prepareEmailList2(toAddress,et3.Id, con.Id, con.Id);
                        mesgList.add(msg);
                
                        
                    }
                }

				notificationService.sendEmailFromList(mesgList);
                
			}
		}
    }
    public static void afterInsert(Map<Id, SObject> newMap){
        Map<Id,File_Staging__c> qiUpload = new Map<Id,File_Staging__c>([SELECT Id,Provider__c,RecordType.DeveloperName FROM File_Staging__c WHERE ID IN: newMap.keyset()
                                                                        AND RecordType.DeveloperName=:QI_RECORDTYPEDEVELOPERNAME AND Provider__c!=null ]);
        
        
        if(qiUpload.size()>0){
           
            QIFileStagingTriggerService.shareQualityIndicatorFileStagingRecords(qiUpload);
        }
        
    }

}