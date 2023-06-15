/**
* author: Peter Xiang
* date: 14/04/2023
* description: Batch Apex to delete Quality Indicator Summary Version and its child classes that are older than a given number of days
* @testClass  : QIVersioningBatchDeleteTest
**/
public with sharing class QIVersioningBatchDelete implements Database.Batchable<string> {
    
    //Getting metadata for the deletion date threshold
    private static final Quality_Indicator_Settings__mdt qiMetaData = Quality_Indicator_Settings__mdt.getInstance(
        'QI_Deletion_Period_Metadata'
    );
    // error messages
    private static final Double NUMBER_OF_DAYS = qiMetaData.Number_of_Days__c;
    public Iterable<string> start(Database.BatchableContext ctx) {
        return new list<String> {'Quality_Indicator_Summary_Version__c'}; 
    }
    public void execute(Database.BatchableContext ctx, list<string> qiSummaryIndicator) {
        try{
            
            String numberOfDaysString = string.valueof(NUMBER_OF_DAYS).left(string.valueof(NUMBER_OF_DAYS).length()-2); //convert to string and remove decimal places.
            list<sObject> dataToDelete = database.query('Select Id from ' + qiSummaryIndicator[0] + ' where CreatedDate < LAST_N_DAYS:'+NumberOfDaysString);
            if(!dataToDelete.isEmpty()){
                Database.delete(dataToDelete,false);
            }
            
        }catch(DmlException exp){
            dohagedcare.Logger.error(exp.getMessage(),exp,'QIVersionBatchDelete ').Log(); 
                  
        }
    }
    public void finish(Database.BatchableContext ctx) {
        
    }
}