/**
* author: Vivek Jaiswal
* date: 16/11/2022
* description: Update Regulatory Decision records based on rating 
**/
public with sharing class RegulatoryDecisionBatch implements Database.Batchable<sObject>{
    public static Integer archivedDecisionEndDt=(Integer) STARRating_Settings__mdt.getInstance('Status_Change_Dates').Days_after_Date_Decision_Ends_2__c;
    public static Integer NonCurrentDecisionEndDt=(Integer) STARRating_Settings__mdt.getInstance('Status_Change_Dates').Days_after_Date_Decision_Ends_1__c;
    public static Date NonCurrentDecisionEndDate=Date.today().addDays(-NonCurrentDecisionEndDt);
    public static String NonCurrentStatus='Non-Current';
    public static String CurrentStatus='Current';
    public Database.QueryLocator start(Database.BatchableContext bc){
       return Database.getQueryLocator(getQuery());
    }

    public void execute(Database.BatchableContext bc, List<RegulatoryCodeViolation> scope){
        if(!scope.isEmpty()){
            
            try{
               List<RegulatoryCodeViolation> regulatoryDecisions=new List<RegulatoryCodeViolation>();
              
               for(RegulatoryCodeViolation regDecision: scope){
                    regDecision.Service_Compliance_Rating__c = (regDecision.Service_Compliance_Rating_Effect__c!=null && regDecision.Service_Compliance_Rating_Effect__c!='N/A')?
                                                                Integer.valueOf(regDecision.Service_Compliance_Rating_Effect__c.left(1)):null;    
                    if(regDecision.Date_Decision_Ends__c<=Date.today() && regDecision.Published__c==true && 
                        regDecision.Status==CurrentStatus)
                    {
                        regDecision.Rating_Relevant__c=true;
                        regDecision.Status=NonCurrentStatus;
                        regulatoryDecisions.add(regDecision);   
                    }
                    else if(regDecision.Date_Decision_Ends__c<=  (Date.today().addDays(-NonCurrentDecisionEndDt)) &&  
                        regDecision.Date_Decision_Ends__c>  (Date.today().addDays(-archivedDecisionEndDt)) &&
                        regDecision.Archived_Regulatory_Decision__c==false && 
                        regDecision.Status==NonCurrentStatus && 
                        regDecision.Rating_Relevant__c==true)
                    {
                        regDecision.Archived_Regulatory_Decision__c=true;
                        regDecision.Rating_Relevant__c=false;
                        regulatoryDecisions.add(regDecision);  
                    }
                    
                    else if(regDecision.Current_Date__c> (regDecision.Date_Decision_Ends__c+ archivedDecisionEndDt) && 
                        regDecision.Archived_Regulatory_Decision__c==true && 
                        regDecision.Status==NonCurrentStatus)
                    {
                       regDecision.Archived_Regulatory_Decision__c=false;  
                       regulatoryDecisions.add(regDecision);  
                    }
                   
                }
                if(!regulatoryDecisions.isEmpty()){
                    Database.SaveResult[] updateResults = Database.update(regulatoryDecisions, false);
                    List<dohagedcare__Application_Log__c> decisionLogs=new List<dohagedcare__Application_Log__c>();
                    for(Database.SaveResult sr:updateResults){
                        if(!sr.isSuccess()){
                            //insert log here
                            dohagedcare__Application_Log__c decisionLog=new dohagedcare__Application_Log__c();
                            decisionLog.dohagedcare__Logging_Level__c='Error';
                            decisionLog.dohagedcare__Message__c=sr.getErrors()[0].getMessage();
                            decisionLog.dohagedcare__Source_Application__c='RegulatoryDecisionBatch';
                            decisionLogs.add(decisionLog);
                        }
                    }
                    if(!decisionLogs.isEmpty()){
                        insert decisionLogs;
                    }
                }
                
            }
            catch(Exception ex){
                dohagedcare.Logger.error(ex.getMessage(), ex, 'RegulatoryDecisionBatch').log();
            }
        }
    }
    public static String getQuery(){
        String query = 'SELECT Id, Date_Decision_Ends__c, Status, Published__c, Current_Date__c, ';
        query = query + 'Archived_Regulatory_Decision__c, Rating_Relevant__c, Service_Compliance_Rating_Effect__c ';
        query = query + 'FROM RegulatoryCodeViolation WHERE Date_Decision_Ends__c!=null AND '; 
        query = query + '(Status=:CurrentStatus OR (Status=:NonCurrentStatus AND Date_Decision_Ends__c<=:NonCurrentDecisionEndDate))';
        return query;
    }
    public void finish(Database.BatchableContext bc){
            //finish required as a part of BatchableContext for post, no post steps exist
    }
}