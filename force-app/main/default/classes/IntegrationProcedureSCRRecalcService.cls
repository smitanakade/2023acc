public with sharing class IntegrationProcedureSCRRecalcService implements omnistudio.VlocityOpenInterface2, Callable{
    public Object call(String action, Map<String, Object> args) {
        
        Map<String, Object> input = (Map<String, Object>)args.get('input');
        Map<String, Object> output = (Map<String, Object>)args.get('output');
        Map<String, Object> options = (Map<String, Object>)args.get('options');
        
        return invokeMethod(action, input, output, options);
    }
    public Boolean invokeMethod(String methodName, Map<String, Object> input, Map<String, Object> output, Map<String, Object> options) { 
        
        Boolean result =true;
        
        try{
            
            if(methodName.equalsIgnoreCase('execute')){
                String sRHID = String.valueOf(input.get('SRHID'));

                final String filter = ' AND Id = :sRHID';
                
                List<STAR_Rating_History__c> starRatingList = Database.query(StarRatingPublishBatch.getQuery() + filter);

                StarRatingPublishBatch.publishStarRating(starRatingList);
            }
            else{
                output.put('result','Method name does not exist');
            }
            
        } catch(Exception e){
            return false;
        }
        return result;
    }
}