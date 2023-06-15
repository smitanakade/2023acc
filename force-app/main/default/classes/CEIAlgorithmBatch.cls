/**
* author: Daniel Clift
* date: 25/08/2022
* description: To count and calculate CEI data, passing to respective CER
* @testClass CEIAlgorithmTest
**/

public with sharing class CEIAlgorithmBatch implements Database.Batchable<sObject>{
    public Database.QueryLocator start(Database.BatchableContext bc)
    {
        return Database.getQueryLocator(getQuery());
    }

    public void execute(Database.BatchableContext bc, List<SRQI_CER__c> scope)
    {
        try {
            CEIAlgorithmHelper.calcCEI(scope);
        } catch(Exception exp) {
            dohagedcare.Logger.error(exp.getMessage(),exp,'Rating Calc').Log(); 
        }
    }

    public static String getQuery()
    {
        String retQuery = '';
        retQuery = retQuery + 'SELECT Id,Consumer_Experience_Rating__c,Respect_Always__c,Respect_Most_of_the_time__c,Respect_Never__c,Respect_Some_of_the_time__c,Respect_Score__c,Food_Always__c,Food_Most_of_the_time__c,Food_Never__c,Food_Some_of_the_time__c,Food_Score__c,';
        retQuery = retQuery + 'Safety_Always__c,Safety_Most_of_the_time__c,Safety_Never__c,Safety_Some_of_the_time__c,Safety_Score__c,';
        retQuery = retQuery + 'Operation_Always__c,Operation_Most_of_the_time__c,Operation_Never__c,Operation_Some_of_the_time__c,Operation_Score__c,';
        retQuery = retQuery + 'Care_Need_Always__c,Care_Need_Most_of_the_time__c,Care_Need_Never__c,Care_Need_Some_of_the_time__c,Care_Need_Score__c,';
        retQuery = retQuery + 'Independent_Always__c,Independent_Most_of_the_time__c,Independent_Never__c,Independent_Some_of_the_time__c,Independent_Score__c,Explain_Always__c,';
        retQuery = retQuery + 'Explain_Most_of_the_time__c,Explain_Never__c,Explain_Some_of_the_time__c,Explain_Score__c,';
        retQuery = retQuery + 'Follow_Up_Always__c,Follow_Up_Most_of_the_time__c,Follow_Up_Never__c,Follow_Up_Some_of_the_time__c,Follow_Up_Score__c,';
        retQuery = retQuery + 'Caring_Always__c, Caring_Most_of_the_time__c, Caring_Never__c, Caring_Some_of_the_time__c, Caring_Score__c,Service__c,';
        retQuery = retQuery + 'Voice_Always__c,Voice_Most_of_the_time__c,Voice_Never__c,Voice_Some_of_the_time__c,Voice_Score__c,Home_Always__c,Home_Most_of_the_time__c,Home_Never__c,Home_Some_of_the_time__c,Home_Score__c ';
        retQuery = retQuery + 'FROM SRQI_CER__c WHERE Quarterly_RP__r.Previous_Reporting_Period__c = true ';
        retQuery = retQuery + 'AND Service_Account__r.Active__c = TRUE AND Extant__c = TRUE ';
        retQuery = retQuery + 'AND Service__r.Status__c NOT IN (\'Closed\', \'Pre-operational\') ';
        return (retQuery);

    }

    public void finish(Database.BatchableContext bc)
    {
        Database.executeBatch(new CerHybridBatch(true), 90);
    }
}