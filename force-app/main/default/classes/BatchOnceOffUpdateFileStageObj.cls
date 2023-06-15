/**
* @Author             : smita kagde
* @Description        : Batch Class
* @Modification Log   :
* ---------------------------------------------------
* Date           Author                Details
* ---------------------------------------------------
* 29/04/2023     smita kagde    This Batch class for Once off, Need to run
								in prod for all File_Staging__c record where Catergory is CEI
*/
public with sharing class BatchOnceOffUpdateFileStageObj implements Database.Batchable<sObject> {

    public String query;
   	public  Database.QueryLocator start(Database.BatchableContext BC){
         query = 'SELECT Id,Reporting_Category__c,RecordTypeId ' +
                    'FROM File_Staging__c WHERE '+
                    'Reporting_Category__c = \'CEI\'';
        return Database.getQueryLocator(query);
    }

    public  void execute(Database.BatchableContext BC, List<sObject> scope){
        Id gsRecordTypeID = Schema.SObjectType.File_Staging__c.getRecordTypeInfosByName().get('CEI').getRecordTypeId();
    	List<File_Staging__c> fileStagingList = (List<File_Staging__c>)scope; //List of File_Staging__c
        system.debug('size ==> ' + scope.size());
        try{
            // update RecordType on File_Staging__c
            for(File_Staging__c thisFSList : fileStagingList ){
                thisFSList.RecordTypeId = gsRecordTypeID;
            }

            update fileStagingList;
        }catch(Exception exp){
        }
    }

    //Any post processing steps here
    public  void finish(Database.BatchableContext BC){
       system.debug('Record Type is Updated for all exsiting FileStaging reord for all Reporting_Category__c= CEI');
    }

}
