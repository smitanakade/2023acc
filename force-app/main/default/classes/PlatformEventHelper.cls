public with sharing class PlatformEventHelper {
    public static Generic_Event__e createGenericEvent(sObject newRecord, sObject oldRecord, String operation) {
        return new Generic_Event__e(commitNumber__c = '', commitUser__c = UserInfo.getUserId(), 
                                    sequenceNumber__c = '1', entityName__c = newRecord.Id.getSObjectType().getDescribe().getName(),
                                   changeType__c = operation, changedFields__c = getChangeFieldValues(oldRecord, newRecord, operation),
                                   changeOrigin__c = '', transactionKey__c = '', commitTimestamp__c = String.valueOf(datetime.now().getTime()),
                                   recordIds__c = newRecord.Id);
    }
    
    public static Set<String> getChangedFields(SObject oldRecord, SObject newRecord) {
        Set<String> fields = new Set<String>();
        Set<String> systemFields = new Set<String>{
          'CreatedDate','LastModifiedById','LastModifiedDate','SystemModstamp'
        };
        for (String key : newRecord.getPopulatedFieldsAsMap().keySet()) {
            if(systemFields.contains(key)) {
                continue;
            }
            if(oldRecord.get(key) != newRecord.get(key)){
                fields.add(key);
            }
        }
        return fields;
    }

    public static String getChangeFieldValues(SObject oldRecord, SObject newRecord, String operation) {
        String changedFields = null;
        Set<String> fieldSet;
        if (operation == 'UPDATE') {
            fieldSet = getChangedFields(oldRecord, newRecord);
        }
        if (fieldSet.size() == 0) {
            return '[]';
        }
        for (String field : fieldSet) {
            if (changedFields == null) {
                changedFields = field;
            }
            else {
                changedFields += ', ' + field;
            }
        }
        return changedFields;
    }
}