/**
Scripting class - should be deleted after Jun 2023 rel
@author - Sharev Singh
 */
public with sharing class QISSharingScript implements Database.Batchable<sObject>{

    public Database.QueryLocator start(Database.BatchableContext bc)
    {
        return Database.getQueryLocator(getQuery());
    }

    public void execute(Database.BatchableContext bc, List<Quality_Indicator_Summary__share> scope)
    {
        if(!scope.isEmpty()) {
            try
            {
                List<Quality_Indicator_Summary__share> qisListToUpdate = new List<Quality_Indicator_Summary__share>();

                for(Quality_Indicator_Summary__share qis: scope) {
                    qis.AccessLevel = 'Edit';
                    qisListToUpdate.add(qis);
                }

                if(qisListToUpdate.size() > 0) {
                    update qisListToUpdate;
                }
            }
            catch(Exception ex)
            {
                System.debug('exception :: '+ex.getMessage());
                dohagedcare.Logger.error(ex.getMessage(), ex, 'QIObservedBatch').log();
            }
        }
    }

    public static String getQuery()
    {
        String query = 'SELECT Id, AccessLevel, Parent.REPORTING_PERIOD__c, RowCause ';
        query = query + 'FROM Quality_Indicator_Summary__share ';
        if(!Test.isRunningTest()) {
            query = query + 'WHERE RowCause=\'Provider__c\''; 
            query = query + 'AND AccessLevel=\'Read\' ';
        }
        return query;
    }

    public void finish(Database.BatchableContext bc){
    }
}