/****************************************************************************************************
* @CreatedBy   : Accenture Developer Team
* @CreatedDate : 18-Jul-2022
* @Description : Handles the logic to Payload and let others invoke
* @Test Class  : GPMSAccountPayloadResponseTest
*****************************************************************************************************/
public with sharing class GPMSPayloadHelper {
    
    private static List<String> contactRelationshipRecordType = new List<String>{'Key_Personnel_CR', 'Non_Individual_Contact_CR', 
        'Point_of_Contact_CR','Service_Key_Personnel_CR', 'Service_Point_of_Contact_CR'};
    private static List<String> integrationSObject = new List<String>{'Account', 'Contact','Address__c','Location_Address__c'
        ,'Contact_Relationship__c','Account_Relationship__c','BusinessLicense'};
    
    public class QueryBundle{
        public String targetObject;
        public String targetField;
        public String recordId;
        public Set<String> recordIds;
        public List<String> recordTypeName;
        public integer count;
        
        public QueryBundle(String targetObject,String targetField,String recordId){
            this.targetObject = targetObject;
            this.targetField = targetField;
            this.recordId = recordId;
            this.count = count;
        }
        
        public QueryBundle(String targetObject,String targetField,Set<String> recordIds){
            this.targetObject = targetObject;
            this.targetField = targetField;
            this.recordIds = recordIds;
            this.count = count;
        }
        
    }
    
    public SObject queryResultSingle(QueryBundle queryBundle){
        
        List<Sobject> result = queryString(queryBundle);
        if(result == null || result.size() == 0){
            return null;
        }else{
            return result[0];
        }
    }
    
    public List<SObject> queryResultList(QueryBundle queryBundle){
        
        List<SObject> result = queryString(queryBundle);
        return result;
    }
    
    public List<SObject> queryString(QueryBundle queryBundle){
        
        if(queryBundle.recordIds == null && String.isBlank(queryBundle.recordId)){
            return null;
        }
        
		Schema.SObjectType sObjType = ((SObject) Type.forName(queryBundle.targetObject).newInstance())
			.getSObjectType();
        List<Schema.SObjectField> fields = sObjType.getDescribe().fields.getMap().values();
        
        List<String> fieldsApi = new List<String>();
        
        for(Schema.SObjectField field: fields){
            Schema.DescribeFieldResult dfr = field.getDescribe();
            if(dfr.getType() == Schema.DisplayType.Reference) {
                fieldsApi.add(dfr.getRelationshipName()+'.Name');
                Boolean hasIntegrationId = false;
                for(Schema.sObjectType parentObject : dfr.getReferenceTo()){
                    if(integrationSObject.contains(parentObject.getDescribe().getName())){
                        hasIntegrationId = true;
                    }
                }
                if(hasIntegrationId){
                    fieldsApi.add(dfr.getRelationshipName()+'.Integration_ID__c');
                }
                
            }
            fieldsApi.add(dfr.getName());
        }
        
        //Generate query string
        String soql = 'SELECT ' + String.join(fieldsApi, ',')+ ' FROM ' + queryBundle.targetObject+ ' WHERE ';
        
        //generate query conditions
        String recordId = queryBundle.recordId;
        List<String> recordIds = new List<String>(queryBundle.recordIds);
       	if(queryBundle.recordIds == null){
            soql = soql + queryBundle.targetField + ' = :recordId';
        }else{
            soql = soql + queryBundle.targetField + ' in :recordIds';
        }
        
        //Check contact relationship
        if(queryBundle.targetObject == 'Contact_Relationship__c'){
            soql = soql + ' AND RecordType.DeveloperName = :contactRelationshipRecordType ';
        }
		        
        //Set the limit
        if(queryBundle.Count > 0 ){
            soql = soql + ' limit ' + String.valueOf(queryBundle.Count);
        }else{
            soql = soql + ' limit 49999';
        }
        
        String soqlString = String.escapeSingleQuotes(soql);
        List<SObject> objects = Database.query(soqlString);
        
        return objects;
    }
    
    public Set<String> generateIds(List<SObject> objects, String fieldApi){
        
        Set<String> ids = new Set<String>();
        for(SObject tem : objects){
            String fieldvalue = (String)tem.get(fieldApi);
            if(String.isNotBlank(fieldvalue)){
                ids.add(fieldvalue);
            }
        }
        return ids;
    }
    
    public List<SObject> filterList(List<SObject> objectsToFilter, String filterField, String filterValue){
        
        List<SObject> objects = new List<SObject>();
        for(SObject tem : objectsToFilter){
            String fieldvalue = (String)tem.get(filterField);
            if(filterValue == fieldvalue){
                objects.add(tem);
            }
        }
        return objects;
    }
    
}
