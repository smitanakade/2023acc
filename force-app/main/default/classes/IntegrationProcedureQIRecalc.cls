/**
* author: Daniel Clift
* date: 30/10/2022
* description: Handle integration procedure remote action call, recalculates all QI components for a given service
**/
global with sharing class IntegrationProcedureQIRecalc implements omnistudio.VlocityOpenInterface2, Callable {

    global Object call(String action, Map<String, Object> args) {
       
        Map<String, Object> input = (Map<String, Object>)args.get('input');
        Map<String, Object> output = (Map<String, Object>)args.get('output');
        Map<String, Object> options = (Map<String, Object>)args.get('options');
 
        return invokeMethod(action, input, output, options);
    }

    global Boolean invokeMethod(String methodName, Map<String, Object> input, Map<String, Object> output, Map<String, Object> options) { 
        
        Boolean result =true;

        try{

            if(methodName.equalsIgnoreCase('recalcQI'))
            {
            recalcQI (input,output,options);
            }
            else
            {
                output.put('result','Method name does not exist');
            }
            
        } 
        catch(Exception ex){
            
            dohagedcare.Logger.error(ex.getMessage(), ex, 'IntegrationProcedureQIRecalc').log();
            return false;
        }
       
        return result;
    }

    public void recalcQI(Map<String, Object> input, Map<String, Object> output,Map<String, Object> options) {

        String serviceId = String.valueOf(input.get('ServID'));

        String rpId = String.valueOf(input.get('RPId'));

        final String filter = ' WHERE Service__c = :serviceId AND Reporting_Period__c = :rpID';
        
        List<Quality_Indicator_Summary__c> qiSummaryList = Database.query(QIObservedBatch.getQuery().substringBefore('WHERE') + filter);

        if(!qiSummaryList.isEmpty())
        {
            // Calc QI Observed Values
            Map<Id, Quality_Indicator_Summary__c> qiMap = QIObservedHelper.updateQiSummaryAndQiRatings(qiSummaryList);
            // Update Records
            update qiMap.values();
            // Calculate National stats & qunintiles
            QIObservedHelper.updateNationalStatsData(qiMap, false);
        }
    }
}