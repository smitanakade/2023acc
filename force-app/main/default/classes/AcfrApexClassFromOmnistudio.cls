/*------------------------------------------------------------------------------------------------
Author:         Varun Sood
Description:    This class is a proof of concept to dyanmically invoke Apex Class from Omnistudio for User Story# 233681.
************************************************************************************************
History 
************************************************************************************************
Updated code for following 
For disply missing serivce section 
    added code to get the missing services and collate a list and provide it to user
    For service of care type - Home care, implemented logic for getting the region from missing service and display the same
For Add missing service 
    Called method for adding service not of care type home care
    For service of type home care 
    - Added logic for getting region for service getting added
    - checked if the region is not already present for current services then add the service
--------------------------------------------------------------------------------------------------*/

global with sharing class AcfrApexClassFromOmnistudio implements omnistudio.VlocityOpenInterface 
{
    global Static string HC ='Home Care';
    global Static String HC_FORM='Home Care Labour Costs and Hours';
    global Static Boolean invokeMethod(String methodName, Map<String,Object> InputMap, Map<String,Object> OutputMap, Map<String,Object> OptionsMap)
    {
        Boolean result=true; 
        
        try{
            //To display Service Records Name in OmniLookup
            if(methodName.equalsIgnoreCase('displayMissingService')){			 
                List<Map<String, String>>  lookupValues =new List<Map<String, String>>();
                String CaseId =(String)InputMap.get('ContextId');
                List<Id> servicesAlreadyAdded= new List<id>();  
                List<id>  listSA =new List<id>(); 
                List<Id> listRA =new List<Id>();
                List<Case>  ListCase =new List<Case>();
                List<id> formids= new List<id>();
                String AccountId; 
                date ReportingPeriodEndDate;  
                List<String> regionsPresent= new List<String>();

                Case c =[Select id, Status, AccountId, Reporting_Period__c, Reporting_Period__r.Start_Date__c, Reporting_Period__r.End_Date__c from Case where id =:CaseId];
                if (c != null && c.Status != 'New' && c.Status != 'Draft') return false;
                AccountId = c?.AccountId;
                ReportingPeriodEndDate = c?.Reporting_Period__r.End_Date__c;
                    
                for(Form__c fm:[Select id, Case__c from Form__c where Case__c=: CaseId]) {
                formids.add(fm.id); 
                } 
                for(Service_Line_Item__c slis:[Select id, Service__c, Form__c, Service_Region__c,Form__r.Type__c, Service__r.Care_Type__c from Service_Line_Item__c 
                    where Service__r.Care_Type__c != :HC and Form__c IN:formids]){
                        if (slis.Service__r.Care_Type__c != null){
                                servicesAlreadyAdded.add(slis.Service__c);
                        } 
                }
                for(Service_Line_Item__c sli:[Select id, Service__c, Form__c, Service_Region__c,Form__r.Type__c,Form__r.Case__r.Service__c from Service_Line_Item__c 
                    where Form__r.Type__c = :HC_FORM and Form__c IN:formids]){                  
                        if (sli.Form__r.Type__c != null && sli.Service_Region__c != null && !regionsPresent.contains(sli.Service_Region__c)){
                                regionsPresent.add(sli.Service_Region__c); // regions already added for HC
                        }
                }
                for(Service_Account_Relationship__c sar:[Select id, Service_Name__c, Care_Type__c from Service_Account_Relationship__c 
                    where Provider_Name__c= :AccountId 
                    AND Association_Start_Date__c <= :c.Reporting_Period__r.End_Date__c
                    AND Service_Name__c NOT IN : servicesAlreadyAdded 
                    AND Care_Type__c != :HC AND (Association_End_Date__c = NULL
                        OR (Association_End_Date__c >= :c.Reporting_Period__r.Start_Date__c AND Association_End_Date__c <= :c.Reporting_Period__r.End_Date__c))]){
                                                        
                                listSA.add(sar.Service_Name__c);
                        
                } 
                for(Service_Account_Relationship__c sar:[Select id, Service_Name__c, Care_Type__c from Service_Account_Relationship__c 
                    where Provider_Name__c= :AccountId 
                    AND Association_Start_Date__c <= :c.Reporting_Period__r.End_Date__c
                    AND Care_Type__c = :HC 
                                                        AND (Association_End_Date__c = NULL
                        OR (Association_End_Date__c >= :c.Reporting_Period__r.Start_Date__c AND Association_End_Date__c <= :c.Reporting_Period__r.End_Date__c))
                    
                                                        ]){
                                                        
                            listRA.add(sar.Service_Name__c);
                } 
                for(BusinessLicense bl:[Select id, Name from BusinessLicense where Id IN:listSA])  
                {
                    if (bl != null){
                        Map<String, String> tempMap =new Map<String, String>();
                        tempMap.put('name', bl.Id);
                        tempMap.put('value', bl.Name);
                        lookupValues.add(tempMap);
                    }
                }
                OutputMap.put('options', lookupValues); 
                Set<Id> addressIds=new Set<Id>();
                Map<Id,Id> mapOfServiceAddress=new Map<Id,Id>();
                for (Address_Location__c recType:[SELECT Id, Address__c, Service__c FROM Address_Location__c 
                    WHERE Service__c IN :listRA]){ 
                
                    addressIds.add(recType.address__c);
                    mapOfServiceAddress.put(recType.address__c,recType.Service__c); 
                }
                for(Geospatial_Information__c geoInfo: [SELECT Address__c, Address__r.State_Province__c, Description__c,Layer__c FROM Geospatial_Information__c 
                    WHERE Address__c IN :addressIds AND Layer__c = 'Aged Care Planning Regions']){
                
                    if (geoInfo != null){
                        Map<String, String> tempMap =new Map<String, String>();
                        String region = geoInfo.Address__r.State_Province__c +'-'+geoInfo.Description__c;
                        if (!regionsPresent.contains(region)){
                            tempMap.put('name', mapOfServiceAddress.get(geoInfo.address__c));
                            tempMap.put('value', region);
                            lookupValues.add(tempMap);
                        }            
                                    
                    }
                OutputMap.put('Options', lookupValues);  
                }
                                
            }
         
            if(methodName.equalsIgnoreCase('addMissingService')){
                AcfrCreateQuaterlyCasesAndFormsService ac=new AcfrCreateQuaterlyCasesAndFormsService();
                Id caseIdVar;
                Id serviceIdVar;
                List<Id> listRAs =new List<Id>();
                List<id> formids= new List<id>();
                List<String> regionNameList = new List<String>();
                caseIdVar =(String)InputMap.get('CaseId');
                serviceIdVar =(String)InputMap.get('ServiceId');
                BusinessLicense bl=[Select id, Name,Care_Type__c from BusinessLicense where Id=:serviceIdVar];
                If (bl.Care_Type__c != HC) {
                    ac.generateRecordsForAdditionalServices(caseIdVar, serviceIdVar,null);
                } else{
                    Case c =[Select id, Status, AccountId, Reporting_Period__c, Reporting_Period__r.Start_Date__c, Reporting_Period__r.End_Date__c from Case where id =:caseIdVar];
                    System.Debug('Case===='+c);
                    for(Form__c fm:[Select id, Case__c from Form__c where Case__c=: caseIdVar]) {
                        formids.add(fm.id); 
                       } 
                        for(Service_Line_Item__c sli:[Select id, Service__c, Form__c, Service_Region__c,Form__r.Type__c, Service__r.Care_Type__c from Service_Line_Item__c 
                            where Form__r.Type__c =:HC_FORM
                            AND Form__c IN:formids]){
                                if (sli.Form__r.Type__c != null && sli.Service_Region__c != null && !regionNameList.contains(sli.Service_region__c)){
                                    regionNameList.add(sli.Service_region__c);
                                }
                        }
                    for (Service_Account_Relationship__c sarr:[Select id, Service_Name__c, Care_Type__c from Service_Account_Relationship__c 
                        where Service_Name__c= :serviceIdVar 
                        AND Association_Start_Date__c <= :c.Reporting_Period__r.End_Date__c
                        AND Care_Type__c = :HC 
                        AND (Association_End_Date__c = NULL
                        OR (Association_End_Date__c >= :c.Reporting_Period__r.Start_Date__c AND Association_End_Date__c <= :c.Reporting_Period__r.End_Date__c))]){
                            listRAs.add(sarr.Service_Name__c);
                    } 
                    Set<Id> addressIds=new Set<Id>();
                    for (Address_Location__c recType:[SELECT Id, Address__c, Service__c FROM Address_Location__c 
                        WHERE Service__c IN :listRAs]){ 
                            addressIds.add(recType.address__c);
                    }
                    for(Geospatial_Information__c geoInfo: [SELECT Address__c, Address__r.State_Province__c, Description__c,Layer__c FROM Geospatial_Information__c 
                        WHERE Address__c IN :addressIds AND Layer__c = 'Aged Care Planning Regions']){
                            String region = geoInfo.Address__r.State_Province__c +'-'+geoInfo.Description__c;
                            if (geoInfo != null && !regionNameList.contains(region)){
                                ac.generateRecordsForAdditionalServices(caseIdVar, serviceIdVar, region);
                            }
                    }
                }
                OutputMap.put('Apexoutput', InputMap);
            }
        }Catch(Exception e){
            dohagedcare.logger.error(e.getMessage(),e,'QFR').log();
           return false; 
        }
        return result;
    }
}