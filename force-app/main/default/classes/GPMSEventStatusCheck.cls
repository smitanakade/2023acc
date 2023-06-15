global with sharing class GPMSEventStatusCheck implements omnistudio.VlocityOpenInterface2{

    public Boolean invokeMethod (String methodName, Map<String,Object> input, Map<String,Object> output, Map<String,Object> options) {
        try {
            if(methodName.equals('checkEventStatus') && input.get('serviceId') != null && input.get('eventType') != null) {
                String serviceId = (String) input.get('serviceId');
                String eventType = (String) input.get('eventType');
                String addressResult;
                String eventStatusResult;
                if (eventType.equals('Record Allotment')) {
                    addressResult = checkServiceAddress(serviceId);
                } else {
                    eventStatusResult = checkEventStatus(serviceId, eventType);
                }
                output.put('eventStatusCheck', eventStatusResult);
                output.put('addressLocationCheck', addressResult);
                return true;
            }
            
            return false;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public String checkEventStatus(String serviceId, String eventType) {
            List<String> status = getStatusesList(eventType);
            try{
                List<AggregateResult> aggResult = [SELECT COUNT(Id) total FROM Event__c WHERE Service__c =: serviceId AND Status__c IN: status];
                Integer result = (Integer) aggResult[0].get('total');
                return result > 0 ? 'Event Inflight' : null;
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
    }
    

    public List<String> getStatusesList(String eventType) {
        List<String> status;
        String notApproveUnderReconsideration = 'Not Approved: Under Reconsideration';
        String notApproveUnderAATReconsideration = 'Not Approved: Under AAT Reconsideration';
        String pending = 'Pending';
        if(eventType.equalsIgnoreCase('Transfer')) {
            status = new List<String>{pending,'Awaiting Response to Notice to Resolve','Automatic Transfer: Pending Activation',
                                    'Transfer: Pending Activation', notApproveUnderReconsideration, notApproveUnderAATReconsideration};
        } else if(eventType.equalsIgnoreCase('Variation')) {
            status = new List<String>{pending,'Awaiting RFI', notApproveUnderReconsideration, notApproveUnderAATReconsideration, 'Approved'};
        } else if(eventType.equalsIgnoreCase('Relinquish') || eventType.equalsIgnoreCase('Cease PA')) {
            status = new List<String>{pending};
        } else {
            status = new List<String>{pending,notApproveUnderReconsideration, notApproveUnderAATReconsideration};
        }
        return status;
    }

    public String checkServiceAddress(String serviceId) {
        try{
            List<AggregateResult> aggResult = [SELECT COUNT(Id) total FROM Address_Location__c WHERE Service__c =: serviceId AND Location_Type__c = 'Physical' AND Address_Ineffective_Date__c = null];
            Integer result = (Integer) aggResult[0].get('total');
            return result == 0 ? 'Missing Service Address' : null;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
}
}