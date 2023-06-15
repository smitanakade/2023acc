/**
* @Author             : smita kagde
* @Description        : Batch Class
* @Modification Log   : 
* ---------------------------------------------------
* Date           Author                Details
* ---------------------------------------------------
* 03/11/2022     smita kagde        PBI 269113 :Star Ratings algorithm define ratings for Offline services
*So that the MAC website always displays the correct Star ratings for a service that was previously offline but has resumed operations
**/
public with sharing class  QISROfflineRatingCalclationBatch implements Database.Batchable<SObject>{
    		
  		String Status1 = '\'Operational\'';  // to be used in running test
         String Status2 = '\'Offline\'';  // to be used in running test
    
    
            public Database.QueryLocator start(Database.BatchableContext context){  
               Database.QueryLocator result;
                result =  Database.getQueryLocator([Select Id,Status__c,Operational_Two_Last_Quarters__c,Status_Date__c From BusinessLicense Where Status__c IN ('Operational', 'Offline')]);
                return result;
         }
          
            public void execute(Database.BatchableContext context, List<BusinessLicense> scope){
                    try{
                        ServiceOperationalChecker.isOperationalForLastTwoFullQuarters(scope);
                    }catch(DmlException exp){
                        System.debug('somthing went wrong QISROfflineRatingCalclationBatch execute ' + exp.getMessage());
                        dohagedcare.Logger.error(exp.getMessage(),exp,'SCRUtil -createSRHWithSCR').Log();             
                    }
            }
        
            public void finish(Database.BatchableContext context){ 
                //no action required
            }

}