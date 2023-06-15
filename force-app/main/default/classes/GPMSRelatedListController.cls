public with sharing class GPMSRelatedListController {
    
    @AuraEnabled (cacheable=true)
    public static RelatedList getRelatedListInfo(String relatedListName, String targetObject, String targetField, String recordId, String condition, Integer count){
        
		try{
            
            RelatedList related = new RelatedList();
            related.fields = getAllFields(relatedListName,targetObject);
            getAllRelatedRecords(related, related.fields, targetObject, targetField, recordId, condition, count);
            getAccess(related,recordId);
            if( !related.HasDeleteAccess && !related.HasEditAccess ){
                related.showAction = false;
            }
            if(related.recordCount == 0){
                related.showViewAll = false;
            }
            return related;
            
        } catch (Exception exp){
            
            dohagedcare.Logger.error(exp.getMessage(),exp,'GPMS').Log();
            return null;
            
        }
        
        
        
    }
    
    private static List<Related_List_Setting__mdt> getAllFields(String relatedListName,String targetObject ){
        
        List<Related_List_Setting__mdt> relatedFieldList = new List<Related_List_Setting__mdt>();
        
        List<Related_List_Setting__mdt> relatedFields = [SELECT ID,MasterLabel,Field_Api__c,Field_Type__c,
                                                         IsOrder__c,LookUp_Field__c,Order__c,Sort_ASC__c,Target_Field__c
                                                         FROM Related_List_Setting__mdt
                                                         WHERE Related_List_Name__c = :relatedListName
                                                         Order By Order__c ASC];
        
        Schema.DescribeSobjectResult result = Schema.describeSObjects(new List<String>{targetObject})[0];
        
        for(Related_List_Setting__mdt field : relatedFields){
            if(null != result.fields.getMap().get(field.Target_Field__c) && result.fields.getMap().get(field.Target_Field__c).getDescribe().isAccessible()){
                relatedFieldList.add(field);
            }else if(null != result.fields.getMap().get(field.Field_Api__c) && result.fields.getMap().get(field.Field_Api__c).getDescribe().isAccessible()){
                relatedFieldList.add(field);
            }else{
                continue;
            }
        }
        
        return relatedFieldList;
        
        
    }
    
    private static void getAccess(RelatedList related, String recordId){
        List<UserRecordAccess> userAccessList = [SELECT RecordId, HasEditAccess, HasDeleteAccess FROM UserRecordAccess WHERE UserId = :UserInfo.getUserId() AND RecordId = : recordId limit 1];
        if(userAccessList.isEmpty()){
            return ;
        }
        
        related.HasEditAccess = userAccessList[0].HasEditAccess;
        related.HasDeleteAccess = userAccessList[0].HasDeleteAccess;
    }
    
    public static void getAllRelatedRecords(RelatedList related, List<Related_List_Setting__mdt> fields, String targetObject, String targetField, String recordId, String condition, Integer count){
        Set<String> queryField = new Set<String>();
        
        String orderquery = '';
        
        for(Related_List_Setting__mdt field : fields){
            if(String.isNotBlank(field.Field_Api__c)){
                queryField.add(field.Field_Api__c);
            }
            if(field.LookUp_Field__c){
                queryField.add(field.Target_Field__c);
            }
            if(field.IsOrder__c){
                orderquery = ' Order By ' + field.Field_Api__c + ' ';
                if(field.Sort_ASC__c){
                    orderquery = orderquery + ' ASC';
                }else{
                    orderquery = orderquery + ' DESC';
                }
            }
        }
        
        queryField.add('Id');
        queryField.add('Name');
        
        List<String> fieldList = new List<String>(queryField);
        
        if(String.isNotEmpty(condition)){
            condition = condition + ' AND ';
        }
        
        String queryString = 'SELECT ' + String.join(fieldList, ',') + ' FROM ' + targetObject + ' WHERE ' + condition + targetField + ' = \'' + recordId + '\'' + orderquery;
        
        List<Sobject> relatedRecords = database.query(queryString);
        related.recordCount = relatedRecords.size();
        
        List<SObject> displayRecords = new List<SObject>();
        while (displayRecords.size() < count && displayRecords.size() < relatedRecords.size()) {
            displayRecords.add(relatedRecords[displayRecords.size()]);
        }
        
        related.records = displayRecords;
    }
    
    @AuraEnabled(cacheable=true)
    public static String generateReportURL(String reportname, String objectName, String recordId){
        
        try{
            
            String reportsURL = '/lightning/r/Report/';
            
            //Query report information
            List<Report> reports = [SELECT ID FROM Report WHERE DeveloperName = :reportname];
            
            if(reports.isEmpty()){
                return null;
            }
            
            reportsURL = reportsURL + reports[0].Id + '/view?queryScope=userFolders&' + 'fv0=' + recordId;
            
            return reportsURL;
            
        } catch (Exception exp){
            
            dohagedcare.Logger.error(exp.getMessage(),exp,'GPMS').Log();
            return null;
            
        }
        
        
        
    }
    
    @AuraEnabled(cacheable=true)
    public static String generateNewButtonURL(String recordTypeName, String targetObject, String targetField, String recordId){
        
        try{
            
            String newbuttonURL = '/lightning/o/' + targetObject + '/new?recordTypeId=';
            string rtId = [SELECT id FROM RecordType WHERE Name =:recordTypeName AND SobjectType = :targetObject].Id;
            newbuttonURL = newbuttonURL + rtId + '&defaultFieldValues=' + targetField + '=' + recordId;
            return newbuttonURL;
            
        } catch (Exception exp){
            
            dohagedcare.Logger.error(exp.getMessage(),exp,'GPMS').Log();
            return null;
            
        }
    }
    
    
    public class RelatedList {
        
        @AuraEnabled public List<Related_List_Setting__mdt> fields;
        @AuraEnabled public List<Sobject> records;
        @AuraEnabled public Integer recordCount;
        @AuraEnabled public Boolean HasEditAccess = true;
        @AuraEnabled public Boolean HasDeleteAccess = true;
        @AuraEnabled public Boolean showViewAll = true;
        @AuraEnabled public Boolean showAction;
        
    }
    
}