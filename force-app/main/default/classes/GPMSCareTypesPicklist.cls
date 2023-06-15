global with sharing class GPMSCareTypesPicklist implements omnistudio.VlocityOpenInterface2 {
    
    public Boolean invokeMethod (String methodName, Map<String,Object> input, Map<String,Object> output, Map<String,Object> options) {
        
        if (methodName.equalsIgnoreCase('SelectRegion')) {       
            List < Map < String, String >> UIoptions = new List < Map < String, String >> ();
            if(null != input.get('state')){
                String state = (String)input.get('state');
                Aged_Care_Planning_Region__c acpr = [SELECT Id, Name, ACPR_Code__c, Geospatial_Information_Layer_Version__c, Geospatial_Information_Layer_Version__r.GPMS_Version__c 
                                                     FROM Aged_Care_Planning_Region__c
                                                     WHERE ACPR_State__c =:state  
                                                     ORDER BY Name, ACPR_Code__c, Geospatial_Information_Layer_Version__r.GPMS_Version__c DESC LIMIT 1];                                                
                for (Aged_Care_Planning_Region__c itrACPR : [SELECT id, Name,ACPR_Code__c,ACPR_State__c 
                                                             FROM Aged_Care_Planning_Region__c 
                                                             Where Geospatial_Information_Layer_Version__c=: acpr.Geospatial_Information_Layer_Version__c AND ACPR_State__c =:state 
                                                             ORDER BY NAME asc]) {
                    Map < String, String > tempMap = new Map < String,String> ();
                    tempMap.put('SA2', '');
                    tempMap.put('SA2Id', '');
                    tempMap.put('ACPR', ItrACPR.Name);
                    tempMap.put('ACPRId', ItrACPR.Id);
                    tempMap.put('places', '');
                    tempMap.put('State', ItrACPR.ACPR_State__c);
                    tempMap.put('key',ItrACPR.Id);
                    UIoptions.add(tempMap);
                }                         
                output.put('acpr', UIoptions);
                return true;
            }else{
                return false;
            }
            
        }
        else if (methodName.equalsIgnoreCase('SelectLocation')) {
            List < Map < String, String >> UIoptions = new List < Map < String, String >> ();
            if(null != input.get('acprId')){
                String str = JSON.serialize(input.get('acprId'));
                
                if(str.containsIgnoreCase('[')){
                    str = str.remove('[');
                }
                
                if(str.containsIgnoreCase(']')){
                    str = str.remove(']');
                }
                
                list<String> stringList = str.split(',');
                List<String> acprIds = new List<String>();
                for (String itrStrr:stringList) {
                    acprIds.add(itrStrr.remove('"'));
                }
                for (SA2__c IterSA2 : [SELECT id, Name,Aged_Care_Planning_Region__c, Aged_Care_Planning_Region__r.Name, Aged_Care_Planning_Region__r.ACPR_State__c FROM SA2__c WHERE Aged_Care_Planning_Region__c in:acprIds ORDER BY Aged_Care_Planning_Region__r.Name,Name asc]) {
                    Map < String, String > tempMap = new Map < String,String> ();
                    tempMap.put('SA2', IterSA2.Name);
                    tempMap.put('SA2Id', IterSA2.Id);
                    tempMap.put('ACPR', IterSA2.Aged_Care_Planning_Region__r.Name);
                    tempMap.put('ACPRId', IterSA2.Aged_Care_Planning_Region__c);
                    tempMap.put('places', '');
                    tempMap.put('State', IterSA2.Aged_Care_Planning_Region__r.ACPR_State__c);
                    tempMap.put('key',IterSA2.Aged_Care_Planning_Region__c+(string)IterSA2.Id);
                    UIoptions.add(tempMap);
                }
                output.put('sa2', UIoptions);
                return true;
            }else{
                return false;
            }
            
        } 
        else if (methodName.equalsIgnoreCase('ACPRSA2Table')) {
            List < Map < String, String >> UIoptions = new List < Map < String, String >> ();
            if(null != input.get('selectedACPR')){
                String selectedACPR = JSON.serialize(input.get('selectedACPR'));
                
                if(selectedACPR.containsIgnoreCase('[')){
                    selectedACPR = selectedACPR.remove('[');
                }
                
                if(selectedACPR.containsIgnoreCase(']')){
                    selectedACPR = selectedACPR.remove(']');
                }
                
                List<String> selectedACPRList = new List<String>();
                
                if(String.isNotBlank(selectedACPR)){
                    selectedACPRList = selectedACPR.split(',');
                }
                
                List<String> selectedACPRIds = new List<String>();
                for (String ItrselectedACPR:selectedACPRList) {
                    selectedACPRIds.add(ItrselectedACPR.remove('"'));
                }
                
                String selectedSA2 = JSON.serialize(input.get('selectedSA2'));
                selectedSA2 = selectedSA2.remove('[');
                selectedSA2 = selectedSA2.remove(']');
                List<String> selectedSA2List = selectedSA2.split(',');
                List<String> selectedSA2Ids = new List<String>();
                for (String ItrSelectedSA2:selectedSA2List) {
                    selectedSA2Ids.add(ItrSelectedSA2.remove('"'));
                }
                
                String selectedSA2_ACPR = JSON.serialize(input.get('selectedSA2_ACPR'));
                selectedSA2_ACPR = selectedSA2_ACPR.remove('[');
                selectedSA2_ACPR = selectedSA2_ACPR.remove(']');
                List<String> selectedSA2_ACPRList = selectedSA2_ACPR.split(',');
                List<String> selectedSA2_ACPRIds = new List<String>();
                for (String ItrselectedSA2_ACPR:selectedSA2_ACPRList) {
                    selectedSA2_ACPRIds.add(ItrselectedSA2_ACPR.remove('"'));
                }
                
                list<Aged_Care_Planning_Region__c> ACPRWithNoSA2 = [SELECT Id, Name, ACPR_State__c FROM Aged_Care_Planning_Region__c WHERE Id in :selectedACPRIds AND Id NOT IN: selectedSA2_ACPRIds ORDER BY NAME asc];
                list<SA2__c> ACPRWithSA2 = [SELECT Id, Name, Aged_Care_Planning_Region__c, Aged_Care_Planning_Region__r.Name,Aged_Care_Planning_Region__r.ACPR_State__c FROM SA2__c WHERE id IN :selectedSA2Ids ORDER BY Aged_Care_Planning_Region__r.Name,Name ASC];
                
                if (!ACPRWithNoSA2.isEmpty()) {
                    for (Aged_Care_Planning_Region__c ItrACPR  : ACPRWithNoSA2) {
                        Map < String, String > tempMap = new Map < String,String> ();
                        tempMap.put('SA2', '');
                        tempMap.put('SA2Id', '');
                        tempMap.put('ACPR', ItrACPR.Name);
                        tempMap.put('ACPRId', ItrACPR.Id);
                        tempMap.put('places', '');
                        tempMap.put('State', ItrACPR.ACPR_State__c);
                        tempMap.put('key',ItrACPR.Id);
                        UIoptions.add(tempMap);
                    }
                }
                if (!ACPRWithSA2.isEmpty()) {
                    for (SA2__c ItrSA2  : ACPRWithSA2) {
                        Map < String, String > tempMap = new Map < String,String> ();
                        tempMap.put('SA2', ItrSA2.Name);
                        tempMap.put('SA2Id', ItrSA2.Id);
                        tempMap.put('ACPR', ItrSA2.Aged_Care_Planning_Region__r.Name);
                        tempMap.put('ACPRId', ItrSA2.Aged_Care_Planning_Region__c);
                        tempMap.put('places', '');
                        tempMap.put('State', ItrSA2.Aged_Care_Planning_Region__r.ACPR_State__c);
                        tempMap.put('key',ItrSA2.Aged_Care_Planning_Region__c+(string)ItrSA2.Id);
                        UIoptions.add(tempMap);
                    }
                }
                output.put('tableValues', UIoptions);       
            
            	return true;
            }else{
                return false;
            }
            
            
        } 
        else {
            return false;
        }
    }
}