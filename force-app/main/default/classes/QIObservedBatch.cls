/**
* author: Daniel Clift
* date: 02/10/2022
* description: Calculates QI Observed, data comes from Quality_Indicator_Detail__c & 
                calculations are printed on Quality_Indicator_Summary__c. Then once calculations are done, 
                calculates & creates a national average record - based on the calculated observed data.
**/
public with sharing class QIObservedBatch implements Database.Batchable<sObject>{

    public Database.QueryLocator start(Database.BatchableContext bc)
    {
        return Database.getQueryLocator(getQuery());
    }

    public void execute(Database.BatchableContext bc, List<Quality_Indicator_Summary__c> scope)
    {
        if(!scope.isEmpty()) {
            try
            {
                Map<Id, Quality_Indicator_Summary__c> qiMap = QIObservedHelper.updateQiSummaryAndQiRatings(scope);
                Database.update(qiMap.values(), false);
            }
            catch(Exception ex)
            {
                dohagedcare.Logger.error(ex.getMessage(), ex, 'QIObservedBatch').log();
            }
        }
    }

    public static String getQuery()
    {
        String query = 'SELECT Id, Status__c, Service__c, QIUpdatedbySiebel__c, QI_Observed_PI_S2__c, QI_Observed_PI_S3__c, ';
        query = query + 'QI_Observed_PI_S4__c, QI_Observed_PI_SDT__c, QI_Observed_PI_unstageable__c, ';
        query = query + 'QI_Observed_WL_SIG__c, QI_Observed_FALLS__c, QI_Observed_Falls_MI__c, Reporting_Period__c, ';
        query = query + 'QI_Predicted_PI_S2__c, QI_Predicted_PI_S3__c, QI_Predicted_PI_S4__c, QI_Predicted_WL_SIG__c, ';
        query = query + 'QI_Predicted_FALLS__c, QI_Predicted_FALLS_MI__c, QI_Observed_Polypharmacy__c, QI_Observed_APSY__c, QI_Observed_Physical_Restraint__c, ';
        query = query + 'Risk_Adjusted_PI_Level2__c, Risk_Adjusted_PI_Level3__c, Risk_Adjusted_PI_Level4__c, ';
        query = query + 'Risk_Adjusted_DT_PI__c, Risk_Adjusted_Unstageable_PI__c, QI_Observed_ADL_DEC__c, '; 
        query = query + 'QI_Observed_PIs__c, QI_Observed_PI_S1__c, QI_Observed_PIs_Outside__c, ';
        query = query + 'QI_Observed_PR_3Day__c, QI_Observed_WL_Cons__c, QI_Observed_MM_APSY_DIG__c, '; 
        query = query + 'QI_Observed_HSP_ED_PR__c, QI_Observed_HSP_ED_ADM__c, QI_Observed_INC__c, '; 
        query = query + 'QI_Observed_INC_IAD__c, QI_Observed_INC_1A__c, QI_Observed_INC_1B__c, '; 
        query = query + 'QI_Observed_INC_2A__c, QI_Observed_INC_2B__c, QI_Observed_WF_Stopped_CM__c, '; 
        query = query + 'QI_Observed_WF_Stopped_RN__c, QI_Observed_WF_Stopped_EN__c, QI_Observed_WF_Stopped_PC__c, '; 
        query = query + 'QI_Observed_CE_Good_SC__c, QI_Observed_CE_Good_Int__c, QI_Observed_CE_Good_PC__c, '; 
        query = query + 'QI_Observed_QL_Good_Int__c, QI_Observed_QL_Good_PC__c, QI_Observed_QL_Good_SC__c, '; 
        query = query + 'Quality_Indicator_Rating__c ';

 
        query = query + 'FROM Quality_Indicator_Summary__c WHERE Reporting_Period__r.Previous_Reporting_Period__c = true AND Reporting_Period__r.Reporting_Period_Type__c = \'Quarter\' ';
        return query;
    }

    public void finish(Database.BatchableContext bc){
        try{

            final String filter = ' AND Id IN (SELECT QI_Summary_Id__c from Quality_Indicator_Details__c ) ';
        
            List<Quality_Indicator_Summary__c> qiSummaryList = Database.query(QIObservedBatch.getQuery() + filter);
            Map<Id, Quality_Indicator_Summary__c> qiWithData = new  Map<Id, Quality_Indicator_Summary__c>(qiSummaryList);
            QIObservedHelper.updateNationalStatsData(qiWithData,false);
        }
        catch (Exception exp){
            dohagedcare.Logger.error(exp.getMessage(),exp,'QIObservedHelper').Log();
        }
    }
}