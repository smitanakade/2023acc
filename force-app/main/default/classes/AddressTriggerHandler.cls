public class AddressTriggerHandler implements beforeInsert, beforeUpdate {
    public void beforeInsert(List<Address__c> addressRecords){
        GPMSHandleAddress.handleInsert(addressRecords);
    }
    public void beforeUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap){
        GPMSHandleAddress.handleUpdate((Map<Id, Address__c>)newMap,(Map<Id, Address__c>)oldMap);
    }
	
}