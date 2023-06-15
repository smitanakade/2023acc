// This class is for the data migration of QFR data from Forms Admin.   The class creates Case records for each provider 
// for a specific Reporting Period.   Before execution you should change the Reporting Period Name (Line 20)
public with sharing class FA2SFCreateCases implements Database.Batchable<sObject> {
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'select Id, Name, Integration_ID__c ' +
            'from Account ' +
            'where RecordType.Name = \'Approved Provider\'' +
             + ' or RecordType.Name = \'National Aboriginal and Torres Strait Islander Flexible Aged Care Program\'' +
             + ' or RecordType.Name = \'Commonwealth Home Support Programme\''
        );
    }
    public void execute(Database.BatchableContext bc, List<Account> lAccts){
    
      Id caseQFRRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('QFR').getRecordTypeId();
      
      //You will only ever get one single record in the Reporting_Period__c list due to the 'WHERE' clause
      ID sRPId;
      string sRPName;
      List<Reporting_Period__c> lRP = [SELECT Id, Name FROM Reporting_Period__c where Name = 'RP-162'];
      for(Reporting_Period__c thisRP: lRP)
      {
         sRPId = thisRP.Id;
         sRPName = thisRP.Name;
      }
          
    
        List<Case> newCases = new List<Case>();
        string sSubject;
    
            for(Account a : lAccts) {        
            // add a Case for each Provider Account for the Reporting Period
            sSubject = 'Migrated Case for Provider ' + a.Integration_ID__c + ' QFR Period : ' + sRPName;
            Case c = new Case(AccountId = a.Id, 
                              Subject=sSubject, 
                              RecordTypeId=caseQFRRecTypeId, 
                              Reporting_Period__c = sRPId, 
                              Status = 'Submitted', 
                              QA_Assessment_Status__c = 'Finalised',
                              Case_DM_Key__c = a.Integration_ID__c + sRPName,
                              Priority = 'Medium');

            newCases.add(c);
        }
    
        if(newCases != null && !newCases.isEmpty()){
          try{
              Database.insert(newCases, false);}
          catch(DmlException e) {
               dohagedcare.logger.error(e.getMessage(),e,'QFR').log();}
        }
  
        // process each batch of records
    }
    public void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }
}