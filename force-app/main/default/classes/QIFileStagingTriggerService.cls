/****************************************************************************************************
* @CreatedBy   : AG
* @CreatedDate : 20-05-2023
* @Description : 
* @testClass:  QIFileStagingTriggerHandlerTest
*****************************************************************************************************/
public with sharing class QIFileStagingTriggerService {
    
    public static void shareQualityIndicatorFileStagingRecords(Map<Id, File_Staging__c> newMap) {
        QIFileStagingShareObjectRecord qiFileStagingShare=new QIFileStagingShareObjectRecord();
        qiFileStagingShare.shareQIFileStaging(newMap);
    }
    //shared record can only be created with users have modify all data permissions
    // because of that need to run this in without sharing context
    // 
    private without sharing class QIFileStagingShareObjectRecord{

        public void shareQIFileStaging(Map<Id, File_Staging__c> newMap) {
            Map<Id, String> serviceToGroupMap = new Map<Id, String>();
            Map<String, Group> groupNameToGroupMap = new Map<String, Group>();
            List<File_Staging__share> sharesList = new List<File_Staging__share>();
            Map<Id,List<BusinessLicense>> AccountToServicesMap = new Map<Id,List<BusinessLicense>>();
            Set<Id> allServiceIds = new Set<Id>();
            
            Set<Id> allAccountIds = new Set<Id>();
            for(File_Staging__c fileStaging: newMap.values()){

                allAccountIds.add(fileStaging.Provider__c);
            }
            for(Service_Account_Relationship__c sar : [SELECT Service_Name__c FROM Service_Account_Relationship__c
                                                       WHERE Provider_Name__c IN : allAccountIds
                                                       AND (Service_Name__r.Status__c = 'Operational' OR Service_Name__r.Status__c = 'Offline')
                                                       AND Service_Name__r.Care_Type__c = 'Residential'AND (Association_End_Date__c = NULL OR Association_End_Date__c >= Today)]){
                
               allServiceIds.add(sar.Service_Name__c); 
                                                           
                
            }
            
            for (BusinessLicense service : [SELECT Id, AccountId FROM BusinessLicense WHERE Id IN :allServiceIds]) {
                
				if (AccountToServicesMap.containsKey(service.AccountId)) {
					AccountToServicesMap.get(service.AccountId).add(service);
				} else {
					
                    AccountToServicesMap.put(service.AccountId, new List<BusinessLicense>{service}); 
				}
				serviceToGroupMap.put(service.Id, 'SRV_' + service.Id);
			}
			
            for (Group g : [SELECT Id, DeveloperName FROM Group WHERE DeveloperName IN :serviceToGroupMap.values()]) {
                groupNameToGroupMap.put(g.DeveloperName, g);
            }
            
            for (File_Staging__c fileStaging: newMap.values()) {
                
                if(AccountToServicesMap.get(fileStaging.Provider__c)!=null && !AccountToServicesMap.get(fileStaging.Provider__c).isEmpty()){
                   
                    for(BusinessLicense service: AccountToServicesMap.get(fileStaging.Provider__c)){
                    	if (groupNameToGroupMap.containsKey(serviceToGroupMap.get(service.Id))){
                            Group newGroup = groupNameToGroupMap.get(serviceToGroupMap.get(service.Id));
                        
                            File_Staging__share qiFileStagingShare = new File_Staging__share();
                            qiFileStagingShare.ParentId = fileStaging.Id;
                            qiFileStagingShare.UserOrGroupId = newGroup.Id;
                            qiFileStagingShare.RowCause = Schema.File_Staging__share.RowCause.Provider__c;
                            qiFileStagingShare.AccessLevel = 'Read';
                            sharesList.add(qiFileStagingShare);
                             
                        }
                    }
                 }
              } 
            
              try {
            	if (!sharesList.isEmpty()) insert sharesList;
        	  } catch(Exception exp) {
            	dohagedcare.Logger.error(exp.getMessage(),exp,'QIFileStagingTriggerService - insert sharesList').Log(); 
        	  }
        }
                
               
    }
}