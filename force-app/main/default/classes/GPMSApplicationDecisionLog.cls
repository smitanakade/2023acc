global with sharing class GPMSApplicationDecisionLog implements omnistudio.VlocityOpenInterface{
    
    global Boolean invokeMethod (String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options){
        Boolean result=true;
        
        try{
            
            if(methodName.equals('DecisionLog')){
                fetchDecisionLog(inputMap,outMap);
            }
            
        } catch (Exception e){
            result = false;
        }
        return result;
    }
    
    public void fetchLog ( List<Recommendation_Item_Care_Type__c> careTypeItem, Map<String,Object> outMap){
        
        Set<Id> groupIds = new Set<Id>();
        try{
            List < Map < String, String >> result = new List < Map < String,String >> ();
            Map<Id,Set<Id>> ACOGroupIdMap = new Map<Id,Set<Id>>();
            
            Map<Id, List<Recommendation_Item_Care_Type__c>> itemCareTypeMap = new Map<Id, List<Recommendation_Item_Care_Type__c>>();
            
            for(Recommendation_Item_Care_Type__c rict : careTypeItem){
                
                if(!itemCareTypeMap.keyset().contains(rict.Recommendation_Item__c)){
                    itemCareTypeMap.put(rict.Recommendation_Item__c,new List<Recommendation_Item_Care_Type__c>());
                }
                
                itemCareTypeMap.get(rict.Recommendation_Item__c).add(rict);
            }
            
            for(Id itemId: itemCareTypeMap.keyset()){
                
                Boolean isFirst = true;
                for(Recommendation_Item_Care_Type__c rict : itemCareTypeMap.get(itemId)){
                    Map < String, String > tempMap = new Map < String, String > ();
                    if(isFirst){
                        tempMap.put('Status', rict.Recommendation_Item__r.Type__c);
                        tempMap.put('Owner', rict.CreatedBy.Name);
                        tempMap.put('Comment', rict.Recommendation_Item__r.Comment__c);
                        
                        date createdDate = rict.CreatedDate.dateGMT();
                        Integer day = createdDate.day();
                        Integer month = createdDate.month();
                        Integer year = createdDate.year();
                        tempMap.put('Date', String.valueOf(day)+'/'+String.valueOf(month)+'/'+year);
                        isFirst = false;
                    }else{
                        tempMap.put('Status', '');
                        tempMap.put('Owner', '');
                        tempMap.put('Comment', '');
                        tempMap.put('Date', '');
                    }
                    
                    if(rict.Decision__c == null){
                        tempMap.put('Recommendation',rict.Care_Type__r.Care_Type__c + ': ' +rict.Decision_Type__c);
                    }else{
                        tempMap.put('Recommendation',rict.Care_Type__r.Care_Type__c + ': ' +rict.Decision__c);
                    }
                    
                    result.add(tempMap);
                }
            }
            
            outMap.put('result', result);
            
        }catch(Exception e){
            System.debug(e.getMessage());
            System.debug(e.getLineNumber());
        }
    }
    
    public void fetchDecisionLog ( Map<String,Object> inputMap,Map<String,Object> outMap){
        
        String type = (String)inputMap.get('Type');
        
        Set<Id> careTypeIds = new Set<Id>();
        String appid = (String)inputMap.get('ApplicationId');
        String applicationId = appid;
        
        if(type == 'applicationreconsideration'){
            List<Reconsideration__c> reconsiders = [SELECT Id, ApplicationId__c FROM Reconsideration__c WHERE Id = :appid];
            if(!reconsiders.isEmpty()){
                appid = reconsiders[0].ApplicationId__c;
            }
        }if(type == 'applicationReconsiderationOutcome'){
            List<Reconsideration__c> reconsiders = [SELECT Id, ApplicationId__c FROM Reconsideration__c WHERE Id = :appid];
            if(!reconsiders.isEmpty()){
                appid = reconsiders[0].ApplicationId__c;
            }
        }
        else if(type == 'applicationAATReview'){
            List<AAT_Review__c> review = [SELECT Id, ApplicationId__c FROM AAT_Review__c WHERE Id = :appid];
            if(!review.isEmpty()){
                appid = review[0].ApplicationId__c;
            }
        }
        
        List<Care_Type__c> caretypes = [SELECT Id FROM Care_Type__c WHERE ApplicationId__c = :appid AND Active__c = true];
        for(Care_Type__c ct : caretypes){
            careTypeIds.add(ct.Id);
        }
        
        System.debug(careTypeIds.size());
        
        String applicationQuery = 'SELECT Id,Care_Type__r.Care_Type__c, Recommendation_Item__r.Type__c, CreatedDate,Recommendation_Item__c,Decision__c,Decision_Type__c, CreatedBy.Name,Recommendation_Item__r.Comment__c FROM Recommendation_Item_Care_Type__c WHERE Care_Type__c in :careTypeIds';
        
        if(type == 'applicationrecommendation'){
            applicationQuery = applicationQuery + ' AND Recommendation_Item__r.Recommendation_Log__r.AAT_Review__c = null';
            applicationQuery = applicationQuery + ' AND Recommendation_Item__r.Recommendation_Log__r.Reconsideration__c = null';
        }else if(type == 'applicationreconsideration'){
            if(applicationId == appid){
                applicationQuery = applicationQuery + ' AND Recommendation_Item__r.Recommendation_Log__r.Reconsideration__c != null';
            }else{
                applicationQuery = applicationQuery + ' AND Recommendation_Item__r.Recommendation_Log__r.Reconsideration__c = :applicationId';
            }
        }else if(type == 'applicationAATReview'){
            if(applicationId == appid){
                applicationQuery = applicationQuery + ' AND Recommendation_Item__r.Recommendation_Log__r.AAT_Review__c != null';
            }else{
                applicationQuery = applicationQuery + ' AND Recommendation_Item__r.Recommendation_Log__r.AAT_Review__c = :applicationId';
            }
        }
        
        applicationQuery = applicationQuery + ' Order By CreatedDate DESC';
        List<Recommendation_Item_Care_Type__c> careTypeItem = Database.query(applicationQuery);
        
        fetchLog(careTypeItem,outMap);
        
    }
    
    
}