/****************************************************************************************************
* @CreatedBy   : Accenture Development Team
* @CreatedDate : 02-FEB-2023
* @Description : Handles the Logic to Update Places Allotment for Transfer Event.
* @Test Class  : GPMSTransferEventUpdatePATest
*****************************************************************************************************/
global with sharing class GPMSTransferEventUpdatePA implements Callable{


    public Object call(String action, Map<String, Object> args) {

        try {
            Map<String, Object> input = (Map<String, Object>)args.get('input');
            Map<String, Object> output = (Map<String, Object>)args.get('output');
            return invokeMethod(action, input, output);
        } catch (exception exp) {
            dohagedcare.Logger.error(exp.getMessage(),exp,'GPMS').Log();
            return true;
        }

    }

    public Boolean invokeMethod(String methodName, Map<String,Object> input, Map<String,Object> output) {

        boolean result = false;

        if (input.get('EventId') != null) {
            Event__c ev = new Event__c(Id = (String)input.get('EventId'));

            List<Places_Allotment__c> placesToUpdateList = new List<Places_Allotment__c>();
            List<Event__c> eventsToUpdateList = new List<Event__c>();
            List<Service_Delivery_Area__c> sdasToUpdateList = new List<Service_Delivery_Area__c>();

            Map<String, Object>inputEvents = new Map<String, Object>();
            inputEvents.put(ev.Id, ev);

            try {
                if ('processTranferEvents'.equalsIgnoreCase(methodName)) {
                    processTranferEvents(inputEvents, placesToUpdateList, sdasToUpdateList, eventsToUpdateList, true);
                }
                result = true;

            } catch (Exception e){
                dohagedcare.Logger.error(e.getMessage(),e, 'GPMS').Log();
                result = false;
            }

        }

        return result;
    }

    public void processTranferEvents(Map<String,Object> inputEvents, List<Places_Allotment__c> placesToUpdateList, List<Service_Delivery_Area__c> sdasToUpdateList, List<Event__c> eventsToUpdateList, boolean isIP) {
        Set<String> eventsSet = new Set<String>(inputEvents.keySet());
        updatePendingPlacesAllotment(eventsSet, placesToUpdateList, eventsToUpdateList, isIP);

        GPMSPerformEventAction.updateTransferSDAs(eventsSet, sdasToUpdateList, isIP);
    }

    //******************Update Places Allotment**********************//
    private void updatePendingPlacesAllotment(Set<String> eventIdSet, List<Places_Allotment__c> placesToUpdateList, List<Event__c> eventsToUpdateList, boolean isIP) {

        List<Places_Allotment__c> placesList = [SELECT Id,Number_of_Places__c,Allotment__c,Parent_Packet__c,Current__c, Event__r.Status__c,
                                                GPMS_Number_of_Remaining__c, Status_Effective_Date__c,
                                                Status_Reason__c,Status_of_Places__c,First_Brought_into_Effect_Date__c, GPMS_Number_of_Variation__c
                                                FROM Places_Allotment__c WHERE Event__c IN :eventIdSet
                                                AND (Current__c = 'Pending')
                                                AND (Event__r.Status__c = 'Transfer: Not to be Activated')];

        if(placesList != null && !placesList.isEmpty()) {
            for(Places_Allotment__c newPlace : placesList) {
                newPlace.Current__c = 'Removed';
                placesToUpdateList.add(newPlace);
            }
        }

        for (String eventId : eventIdSet) {
            eventsToUpdateList.add(new Event__c(Id = eventId, Batch_Event_Completed__c = true));
        }

        if (isIP) {
            if(!placesToUpdateList.isEmpty()) {
                update placesToUpdateList;
            }

            if(!eventsToUpdateList.isEmpty()) {
                update eventsToUpdateList;
            }
        }
    }
}