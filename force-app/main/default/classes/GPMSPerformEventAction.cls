/****************************************************************************************************
* @CreatedBy   : Accenture Development Team
* @CreatedDate : 16-Dec-2022
* @Description : Handles the Logic to perform event actions when GPMS_Proposed_Operational_Date__c
                 is lapsed on the Event.
* @Test Class  : GPMSPerformEventActionTest
*****************************************************************************************************/
public with sharing class GPMSPerformEventAction implements Callable {

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
            List<Service_Delivery_Area__c> sdasToUpdateList = new List<Service_Delivery_Area__c>();
            List<Event__c> eventsToUpdateList = new List<Event__c>();

            Map<String, Object>inputEvents = new Map<String, Object>();
            inputEvents.put(ev.Id, ev);

            try {
                if ('processCeaseS14_9Events'.equalsIgnoreCase(methodName)) {
                    processCeaseS14_9Events(inputEvents, placesToUpdateList, eventsToUpdateList, true);
                } else if ('processBringOnlineEvents'.equalsIgnoreCase(methodName)) {
                    processBringOnlineEvents(inputEvents, placesToUpdateList, eventsToUpdateList, true);
                } else if ('processNATSIFACCeaseEvents'.equalsIgnoreCase(methodName)) {
                    processNATSIFACCeaseEvents(inputEvents, placesToUpdateList, eventsToUpdateList, true);
                } else if ('processSurrenderEvents'.equalsIgnoreCase(methodName)) {
                    processSurrenderEvents(inputEvents, placesToUpdateList, eventsToUpdateList, true);
                } else if ('processRelinquishEvents'.equalsIgnoreCase(methodName)) {
                    processRelinquishEvents(inputEvents, placesToUpdateList, eventsToUpdateList, true);
                } else if ('processRevocationEvents'.equalsIgnoreCase(methodName)) {
                    processRevocationEvents(inputEvents, placesToUpdateList, eventsToUpdateList, true);
                } else if ('processDeedOfVariationEvents'.equalsIgnoreCase(methodName)) {
                    processDeedOfVariationEvents(inputEvents, placesToUpdateList, eventsToUpdateList, true);
                } else if ('processChangeCareSettingsEvents'.equalsIgnoreCase(methodName)) {
                    processChangeCareSettingsEvents(inputEvents, placesToUpdateList, eventsToUpdateList, true);
                } else if ('processNATSIFACReinstateEvents'.equalsIgnoreCase(methodName)) {
                    processNATSIFACReinstateEvents(inputEvents, placesToUpdateList, eventsToUpdateList, true);
                } else if ('processCeaseEvents'.equalsIgnoreCase(methodName)) {
                    processCeaseEvents(inputEvents, placesToUpdateList, eventsToUpdateList, true);
                } else if ('processTransferEvents'.equalsIgnoreCase(methodName)) {
                    processTransferEvents(inputEvents, placesToUpdateList, sdasToUpdateList, eventsToUpdateList, true);
                } else if ('processVariationEvents'.equalsIgnoreCase(methodName)) {
                    processVariationEvents(inputEvents, placesToUpdateList, sdasToUpdateList, eventsToUpdateList, true);
                } else if ('processPAVariationEvents'.equalsIgnoreCase(methodName)) {
                    processPAVariationEvents(inputEvents, placesToUpdateList, sdasToUpdateList, eventsToUpdateList, true);
                } else {
                    //Do nothing
                }

                result = true;

            } catch (Exception e){
                dohagedcare.Logger.error(e.getMessage(),e, 'GPMS').Log();
                result = false;
            }

        }

        return result;
    }

    public void processVariationEvents(Map<String,Object> inputEvents, List<Places_Allotment__c> placesToUpdateList, List<Service_Delivery_Area__c> sdasToUpdateList, List<Event__c> eventsToUpdateList, boolean isIP) {
        Set<String> eventsSet = new Set<String>(inputEvents.keySet());
        updateVariationPlaces(eventsSet, placesToUpdateList, eventsToUpdateList, isIP);
        updateTransferSDAs(eventsSet, sdasToUpdateList, isIP);
    }

    public void processPAVariationEvents(Map<String,Object> inputEvents, List<Places_Allotment__c> placesToUpdateList, List<Service_Delivery_Area__c> sdasToUpdateList, List<Event__c> eventsToUpdateList, boolean isIP) {
        Set<String> eventsSet = new Set<String>(inputEvents.keySet());
        updatePAVariationPlaces(eventsSet, placesToUpdateList, eventsToUpdateList, isIP);
        updateTransferSDAs(eventsSet, sdasToUpdateList, isIP);
    }

    public void processTransferEvents(Map<String,Object> inputEvents, List<Places_Allotment__c> placesToUpdateList, List<Service_Delivery_Area__c> sdasToUpdateList, List<Event__c> eventsToUpdateList, boolean isIP) {
        Set<String> eventsSet = new Set<String>(inputEvents.keySet());
        updateTransferPlaces(eventsSet, placesToUpdateList, eventsToUpdateList, isIP);
        updateTransferSDAs(eventsSet, sdasToUpdateList, isIP);
    }

    public void processCeaseEvents(Map<String,Object> inputEvents, List<Places_Allotment__c> placesToUpdateList, List<Event__c> eventsToUpdateList, boolean isIP) {
        Set<String> eventsSet = new Set<String>(inputEvents.keySet());
        updateCeasePlaces(eventsSet, placesToUpdateList, eventsToUpdateList, isIP);
    }

    public void processNATSIFACReinstateEvents(Map<String,Object> inputEvents, List<Places_Allotment__c> placesToUpdateList, List<Event__c> eventsToUpdateList, boolean isIP) {
        Set<String> eventsSet = new Set<String>(inputEvents.keySet());
        updateNATSIFACReinstatePlaces(eventsSet, placesToUpdateList, eventsToUpdateList, isIP);
    }

    public void processChangeCareSettingsEvents(Map<String,Object> inputEvents, List<Places_Allotment__c> placesToUpdateList, List<Event__c> eventsToUpdateList, boolean isIP) {
        Set<String> eventsSet = new Set<String>(inputEvents.keySet());
        updateChangeCareSettingsPlaces(eventsSet, placesToUpdateList, eventsToUpdateList, isIP);
    }

    public void processDeedOfVariationEvents(Map<String,Object> inputEvents, List<Places_Allotment__c> placesToUpdateList, List<Event__c> eventsToUpdateList, boolean isIP) {
        Set<String> eventsSet = new Set<String>(inputEvents.keySet());
        updateDeedOfVariationPlaces(eventsSet, placesToUpdateList, eventsToUpdateList, isIP);
    }

    public void processRevocationEvents(Map<String,Object> inputEvents, List<Places_Allotment__c> placesToUpdateList, List<Event__c> eventsToUpdateList, boolean isIP) {
        Set<String> eventsSet = new Set<String>(inputEvents.keySet());
        updateRevocationPlaces(eventsSet, placesToUpdateList, eventsToUpdateList, isIP);
    }

    public void processRelinquishEvents(Map<String,Object> inputEvents, List<Places_Allotment__c> placesToUpdateList, List<Event__c> eventsToUpdateList, boolean isIP) {
        Set<String> eventsSet = new Set<String>(inputEvents.keySet());
        updateRelinquishPlaces(eventsSet, placesToUpdateList, eventsToUpdateList, isIP);
    }

    public void processSurrenderEvents(Map<String,Object> inputEvents, List<Places_Allotment__c> placesToUpdateList, List<Event__c> eventsToUpdateList, boolean isIP) {
        Set<String> eventsSet = new Set<String>(inputEvents.keySet());
        updateSurrenderPlaces(eventsSet, placesToUpdateList, eventsToUpdateList, isIP);
    }

    public void processCeaseS14_9Events(Map<String,Object> inputEvents, List<Places_Allotment__c> placesToUpdateList, List<Event__c> eventsToUpdateList, boolean isIP) {
        Set<String> eventsSet = new Set<String>(inputEvents.keySet());
        updateCeaseS14Places(eventsSet, placesToUpdateList, eventsToUpdateList, isIP);
    }

    public void processBringOnlineEvents(Map<String,Object> inputEvents, List<Places_Allotment__c> placesToUpdateList, List<Event__c> eventsToUpdateList, boolean isIP) {
        Set<String> eventsSet = new Set<String>(inputEvents.keySet());
        updateBringOnlinePlaces(eventsSet, placesToUpdateList, eventsToUpdateList, isIP);
    }

    public void processNATSIFACCeaseEvents(Map<String,Object> inputEvents, List<Places_Allotment__c> placesToUpdateList, List<Event__c> eventsToUpdateList, boolean isIP) {
        Set<String> eventsSet = new Set<String>(inputEvents.keySet());
        updateNATSIFACCeasePlaces(eventsSet, placesToUpdateList, eventsToUpdateList, isIP);
    }

    //******************Update Places**********************//
    private void updateVariationPlaces(Set<String> eventIdSet, List<Places_Allotment__c> placesToUpdateList, List<Event__c> eventsToUpdateList, boolean isIP) {
        List<Places_Allotment__c> placesList = [SELECT Id,Number_of_Places__c,Allotment__c,Parent_Packet__c,Current__c,
                                                Care_Type__c,Care_Level__c,Care_Setting__c,GPMS_Number_of_Remaining__c, Status_Effective_Date__c,
                                                Status_Reason__c,Status_of_Places__c,First_Brought_into_Effect_Date__c, GPMS_Number_of_Variation__c, Event__c, Event__r.GPMS_Proposed_Variation_Day__c
                                                FROM Places_Allotment__c WHERE Event__c IN :eventIdSet AND Event__r.GPMS_Proposed_Variation_Day__c <= Today
                                                AND Current__c = 'Pending'];

        Set<String> parentIds = new Set<String>();
        Map<Id, Date> eventIdToProposedVariationDayMap = new Map<Id, Date>();

        if(placesList != null && !placesList.isEmpty()) {
            for(Places_Allotment__c newPlace : placesList) {
                eventIdToProposedVariationDayMap.put(newPlace.Event__c, newPlace.Event__r.GPMS_Proposed_Variation_Day__c);

                newPlace.Current__c = 'Yes';

                placesToUpdateList.add(newPlace);
                if (newPlace.Parent_Packet__c != null && !parentIds.contains(newPlace.Parent_Packet__c)) {
                    parentIds.add(newPlace.Parent_Packet__c);
                    placesToUpdateList.add(new Places_Allotment__c(Id = newPlace.Parent_Packet__c, Current__c = 'No') );
                }
            }
        }

        for (String eventId : eventIdSet) {
            eventsToUpdateList.add(new Event__c(Id = eventId, Batch_Event_Completed__c = true,
                                                Activated__c = 'Yes', Activated_Date__c = (eventIdToProposedVariationDayMap.get(eventId) != null) ? eventIdToProposedVariationDayMap.get(eventId): Date.today()));
        }

        if (isIP) {
            if(!placesToUpdateList.isEmpty()) {
                update placesToUpdateList;
            }

            if(!eventsToUpdateList.isEmpty()) {
                update eventsToUpdateList;
            }
        }

        updateEventConditions(eventIdSet);

    }

    private void updatePAVariationPlaces(Set<String> eventIdSet, List<Places_Allotment__c> placesToUpdateList, List<Event__c> eventsToUpdateList, boolean isIP) {
        List<Places_Allotment__c> placesList = [SELECT Id,Number_of_Places__c,Allotment__c,Parent_Packet__c,Current__c,
                                                Care_Type__c,Care_Level__c,Care_Setting__c,GPMS_Number_of_Remaining__c, Status_Effective_Date__c,
                                                Status_Reason__c,Status_of_Places__c,First_Brought_into_Effect_Date__c, GPMS_Number_of_Variation__c
                                                FROM Places_Allotment__c WHERE Event__c IN :eventIdSet
                                                AND ((Current__c = 'Pending') OR (Status_of_Places__c = 'Provisional'))];

        Set<String> parentIds = new Set<String>();

        if(placesList != null && !placesList.isEmpty()) {
            for(Places_Allotment__c newPlace : placesList) {
                newPlace.Current__c = 'Yes';
                placesToUpdateList.add(newPlace);
                if (newPlace.Parent_Packet__c != null && !parentIds.contains(newPlace.Parent_Packet__c)) {
                    parentIds.add(newPlace.Parent_Packet__c);
                    placesToUpdateList.add(new Places_Allotment__c(Id = newPlace.Parent_Packet__c, Current__c = 'No') );
                }
            }
        }

        for (String eventId : eventIdSet) {
            eventsToUpdateList.add(new Event__c(Id = eventId, Batch_Event_Completed__c = true,
                                                Activated__c = 'Yes', Activated_Date__c = Date.today()));
        }

        if (isIP) {
            if(!placesToUpdateList.isEmpty()) {
                update placesToUpdateList;
            }

            if(!eventsToUpdateList.isEmpty()) {
                update eventsToUpdateList;
            }
        }

        updateEventConditions(eventIdSet);

    }

    private void updateEventConditions(Set<String> eventIdSet) {
        List<AllotmentConditions__c> conditionList = [SELECT Id, GPMS_Event__c, Allotment__c, GPMS_Event__r.Status__c,GPMS_Event__r.Event_Type__c
                                                      FROM AllotmentConditions__c
                                                     WHERE GPMS_Event__c IN :eventIdSet AND GPMS_Condition_Status__c != 'Non-current'];
		List<AllotmentConditions__c> conditionToUpdate = new List<AllotmentConditions__c>();
        Set<String> parentIds = new Set<String>();

        if(conditionList != null && !conditionList.isEmpty()) {
            for(AllotmentConditions__c condition : conditionList) {
                switch on condition.GPMS_Event__r.Status__c {
                    when 'Not Approved', 'Vetoed'  {
                        condition.GPMS_Condition_Status__c = 'Not Approved';
                    }
                    when 'Transfer: Not to be Activated', 'Approved: Not to be Activated' {
                        condition.GPMS_Condition_Status__c = 'Approved-Not Activated';
                    }
                    when 'Cancelled','Withdrawn' {
                        condition.GPMS_Condition_Status__c = 'Withdrawn';
                    }
                    when 'Approved: Activated' {
                        condition.GPMS_Condition_Status__c = 'Current';
                        parentIds.add(condition.Allotment__c);
                    }
                    when 'Approved' {
                        if(condition.GPMS_Event__r.Event_Type__c != 'Variation'){
                            condition.GPMS_Condition_Status__c = 'Current';
                            parentIds.add(condition.Allotment__c);
                        }
                    }
                    when else {
                        condition.GPMS_Condition_Status__c = 'Pending';
                    }
                }

                conditionToUpdate.add(condition);

            }

            if(parentIds != null && !parentIds.isEmpty()){
                List<AllotmentConditions__c> currentConditions = [SELECT Id FROM AllotmentConditions__c
                                                     WHERE allotment__c IN :parentIds AND GPMS_Condition_Status__c = 'Current'];
                if(currentConditions != null && !currentConditions.isEmpty()){
                    for(AllotmentConditions__c condition : currentConditions) {
                        condition.GPMS_Condition_Status__c = 'Non-current';
                        conditionToUpdate.Add(condition);
                    }
                }
            }

        }

        if(!conditionToUpdate.isEmpty()) {
            update conditionToUpdate;
        }

    }

    private void updateTransferPlaces(Set<String> eventIdSet, List<Places_Allotment__c> placesToUpdateList, List<Event__c> eventsToUpdateList, boolean isIP) {
        List<Places_Allotment__c> placesList = [SELECT Id,Number_of_Places__c,Allotment__c,Parent_Packet__c,Current__c,
                                                Care_Type__c,Care_Level__c,Care_Setting__c,GPMS_Number_of_Remaining__c, Status_Effective_Date__c,
                                                Status_Reason__c,Status_of_Places__c,First_Brought_into_Effect_Date__c, GPMS_Number_of_Variation__c
                                                FROM Places_Allotment__c WHERE Event__c IN :eventIdSet
                                                AND ((Current__c = 'Pending') OR (Status_of_Places__c = 'Provisional'))];

        Set<String> parentIds = new Set<String>();

        if(placesList != null && !placesList.isEmpty()) {
            for(Places_Allotment__c newPlace : placesList) {
                newPlace.Current__c = 'Yes';
                placesToUpdateList.add(newPlace);
                if (newPlace.Parent_Packet__c != null && !parentIds.contains(newPlace.Parent_Packet__c)) {
                    parentIds.add(newPlace.Parent_Packet__c);
                    placesToUpdateList.add(new Places_Allotment__c(Id = newPlace.Parent_Packet__c, Current__c = 'No') );
                }
            }
        }

        for (String eventId : eventIdSet) {
            eventsToUpdateList.add(new Event__c(Id = eventId, Batch_Event_Completed__c = true,
                                                Activated__c = 'Yes', Activated_Date__c = Date.today()));
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

    public static void updateTransferSDAs(Set<String> eventIdSet, List<Service_Delivery_Area__c> sdasToUpdateList, boolean isIP) {

        List<Service_Delivery_Area__c> sdaList = [SELECT Id, Allotment__c, Status__c, Event__c, Ineffective_Date__c, Effective_Date__c
                                                  FROM Service_Delivery_Area__c WHERE Event__c IN :eventIdSet];

        Set<String> parentIds = new Set<String>();

        if(sdaList != null && !sdaList.isEmpty()) {
            for(Service_Delivery_Area__c sda : sdaList) {
                parentIds.add(sda.Allotment__c);
                sdasToUpdateList.add(new Service_Delivery_Area__c(Id = sda.Id, Status__c = 'Current', Effective_Date__c = Date.today()) );
            }
        }

        if(parentIds != null && !parentIds.isEmpty()) {
            for(Service_Delivery_Area__c sda : [SELECT Id, Effective_Date__c FROM Service_Delivery_Area__c WHERE Allotment__c IN :parentIds AND Status__c = 'Current']) {
                sda.Status__c = 'Non-current';
                sda.Ineffective_Date__c = (sda.Effective_Date__c != null) ? sda.Effective_Date__c - 1 : Date.today() -1;
                sdasToUpdateList.add(sda);
            }
        }

        if (isIP) {
            if(!sdasToUpdateList.isEmpty()) {
                update sdasToUpdateList;
            }
        }
    }

    private void updateNATSIFACReinstatePlaces(Set<String> eventIdSet, List<Places_Allotment__c> placesToUpdateList, List<Event__c> eventsToUpdateList, boolean isIP) {
        List<Places_Allotment__c> placesList = [SELECT Id,Number_of_Places__c,Allotment__c,Parent_Packet__c,Current__c,
                                                Care_Type__c,Care_Level__c,Care_Setting__c,GPMS_Number_of_Remaining__c, Status_Effective_Date__c,
                                                Status_Reason__c,Status_of_Places__c,First_Brought_into_Effect_Date__c, GPMS_Number_of_Variation__c
                                                FROM Places_Allotment__c WHERE Event__c IN :eventIdSet
                                                AND ((Current__c = 'Pending') OR (Status_of_Places__c = 'Ceased'))];

        Set<String> parentIds = new Set<String>();

        if(placesList != null && !placesList.isEmpty()) {
            for(Places_Allotment__c newPlace : placesList) {
                newPlace.Current__c = 'Yes';
                newPlace.Status_of_Places__c = 'Operational';
                placesToUpdateList.add(newPlace);
                if (newPlace.Parent_Packet__c != null && !parentIds.contains(newPlace.Parent_Packet__c)) {
                    parentIds.add(newPlace.Parent_Packet__c);
                    placesToUpdateList.add(new Places_Allotment__c(Id = newPlace.Parent_Packet__c, Current__c = 'No') );
                }
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

    private void updateChangeCareSettingsPlaces(Set<String> eventIdSet, List<Places_Allotment__c> placesToUpdateList, List<Event__c> eventsToUpdateList, boolean isIP) {
        List<Places_Allotment__c> placesList = [SELECT Id,Number_of_Places__c,Allotment__c,Parent_Packet__c,Current__c,
                                                Care_Type__c,Care_Level__c,Care_Setting__c,GPMS_Number_of_Remaining__c, Status_Effective_Date__c,
                                                Status_Reason__c,Status_of_Places__c,First_Brought_into_Effect_Date__c, GPMS_Number_of_Variation__c
                                                FROM Places_Allotment__c WHERE Event__c IN :eventIdSet
                                                AND ((Current__c = 'Pending') OR (Status_of_Places__c = 'Provisional'))];
        Set<String> parentIds = new Set<String>();

        if(placesList != null && !placesList.isEmpty()) {
            for(Places_Allotment__c newPlace : placesList) {
                newPlace.Current__c = 'Yes';
                if (newPlace.Care_Level__c == GPMSScheduledEventActionsBatch.RESIDENTIAL) {
                    newPlace.Care_Level__c = GPMSScheduledEventActionsBatch.HOME_CARE;
                } else if (newPlace.Care_Level__c == GPMSScheduledEventActionsBatch.HOME_CARE) {
                    newPlace.Care_Level__c = GPMSScheduledEventActionsBatch.RESIDENTIAL;
                } else {
                    //Do nothing
                }

                placesToUpdateList.add(newPlace);
                if (newPlace.Parent_Packet__c != null && !parentIds.contains(newPlace.Parent_Packet__c)) {
                    parentIds.add(newPlace.Parent_Packet__c);
                    placesToUpdateList.add(new Places_Allotment__c(Id = newPlace.Parent_Packet__c, Current__c = 'No') );
                }
            }
        }

        for (String eventId : eventIdSet) {
            eventsToUpdateList.add(new Event__c(Id = eventId, Batch_Event_Completed__c = true,
            	Status__c = GPMSScheduledEventActionsBatch.EVENT_STATUS_APPROVED, Activated__c = 'Yes', Activated_Date__c = Date.today()));
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

    private void updateDeedOfVariationPlaces(Set<String> eventIdSet, List<Places_Allotment__c> placesToUpdateList, List<Event__c> eventsToUpdateList, boolean isIP) {
        List<Places_Allotment__c> placesList = [SELECT Id,Number_of_Places__c,Allotment__c,Parent_Packet__c,Current__c,
                                                Care_Type__c,Care_Level__c,Care_Setting__c,GPMS_Number_of_Remaining__c, Status_Effective_Date__c,
                                                Status_Reason__c,Status_of_Places__c,First_Brought_into_Effect_Date__c, GPMS_Number_of_Variation__c
                                                FROM Places_Allotment__c WHERE Event__c IN :eventIdSet
                                                AND ((Current__c = 'Pending') OR (Status_of_Places__c = 'Provisional'))];
        Set<String> parentIds = new Set<String>();

        if(placesList != null && !placesList.isEmpty()) {
            for(Places_Allotment__c newPlace : placesList) {
                newPlace.Current__c = 'Yes';
                if (newPlace.Care_Level__c == GPMSScheduledEventActionsBatch.RESIDENTIAL) {
                    newPlace.Care_Level__c = GPMSScheduledEventActionsBatch.HOME_CARE;
                } else if (newPlace.Care_Level__c == GPMSScheduledEventActionsBatch.HOME_CARE) {
                    newPlace.Care_Level__c = GPMSScheduledEventActionsBatch.RESIDENTIAL;
                } else {
                    //Do nothing
                }
                placesToUpdateList.add(newPlace);
                if (newPlace.Parent_Packet__c != null && !parentIds.contains(newPlace.Parent_Packet__c)) {
                    parentIds.add(newPlace.Parent_Packet__c);
                    placesToUpdateList.add(new Places_Allotment__c(Id = newPlace.Parent_Packet__c, Current__c = 'No') );
                }
            }
        }

        for (String eventId : eventIdSet) {
                        eventsToUpdateList.add(new Event__c(Id = eventId, Batch_Event_Completed__c = true, Status__c = GPMSScheduledEventActionsBatch.EVENT_STATUS_APPROVED
                                                , Activated__c = 'Yes', Activated_Date__c = Date.today()));
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

    private void updateRevocationPlaces(Set<String> eventIdSet, List<Places_Allotment__c> placesToUpdateList, List<Event__c> eventsToUpdateList, boolean isIP) {
        List<Places_Allotment__c> placesList = [SELECT Id,Number_of_Places__c,Allotment__c,Parent_Packet__c,Current__c,
                                                Care_Type__c,Care_Level__c,Care_Setting__c,GPMS_Number_of_Remaining__c, Status_Effective_Date__c,
                                                Status_Reason__c,Status_of_Places__c,First_Brought_into_Effect_Date__c, GPMS_Number_of_Variation__c
                                                FROM Places_Allotment__c WHERE Event__c IN :eventIdSet
                                                AND ((Current__c = 'Pending') OR (Status_of_Places__c = 'Provisional') OR (Status_of_Places__c = 'Operational'))];
        Set<String> parentIds = new Set<String>();

        if(placesList != null && !placesList.isEmpty()) {
            for(Places_Allotment__c newPlace : placesList) {
                newPlace.Current__c = 'Yes';
                newPlace.Status_of_Places__c = 'Ceased';
                placesToUpdateList.add(newPlace);
                if (newPlace.Parent_Packet__c != null && !parentIds.contains(newPlace.Parent_Packet__c)) {
                    parentIds.add(newPlace.Parent_Packet__c);
                    placesToUpdateList.add(new Places_Allotment__c(Id = newPlace.Parent_Packet__c, Current__c = 'No') );
                }
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

    private void updateRelinquishPlaces(Set<String> eventIdSet, List<Places_Allotment__c> placesToUpdateList, List<Event__c> eventsToUpdateList, boolean isIP) {
        List<Places_Allotment__c> placesList = [SELECT Id,Number_of_Places__c,Allotment__c,Parent_Packet__c,Current__c,
                                                Care_Type__c,Care_Level__c,Care_Setting__c,GPMS_Number_of_Remaining__c, Status_Effective_Date__c,
                                                Status_Reason__c,Status_of_Places__c,First_Brought_into_Effect_Date__c, GPMS_Number_of_Variation__c
                                                FROM Places_Allotment__c WHERE Event__c IN :eventIdSet
                                                AND ((Current__c = 'Pending') OR (Status_of_Places__c = 'Operational'))];
        Set<String> parentIds = new Set<String>();

        if(placesList != null && !placesList.isEmpty()) {
            for(Places_Allotment__c newPlace : placesList) {
                newPlace.Current__c = 'Yes';
                placesToUpdateList.add(newPlace);
                if (newPlace.Parent_Packet__c != null && !parentIds.contains(newPlace.Parent_Packet__c)) {
                    parentIds.add(newPlace.Parent_Packet__c);
                    placesToUpdateList.add(new Places_Allotment__c(Id = newPlace.Parent_Packet__c, Current__c = 'No') );
                }
            }
        }

        for (String eventId : eventIdSet) {
            eventsToUpdateList.add(new Event__c(Id = eventId, Batch_Event_Completed__c = true, Activated__c = 'Yes', Activated_Date__c = Date.today()));
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

    private void updateSurrenderPlaces(Set<String> eventIdSet, List<Places_Allotment__c> placesToUpdateList, List<Event__c> eventsToUpdateList, boolean isIP) {
        List<Places_Allotment__c> placesList = [SELECT Id,Number_of_Places__c,Allotment__c,Parent_Packet__c,Current__c,
                                                Care_Type__c,Care_Level__c,Care_Setting__c,GPMS_Number_of_Remaining__c, Status_Effective_Date__c,
                                                Status_Reason__c,Status_of_Places__c,First_Brought_into_Effect_Date__c, GPMS_Number_of_Variation__c
                                                FROM Places_Allotment__c WHERE Event__c IN :eventIdSet
                                                AND ((Current__c = 'Pending') OR (Status_of_Places__c = 'Provisional'))];
        Set<String> parentIds = new Set<String>();

        if(placesList != null && !placesList.isEmpty()) {
            for(Places_Allotment__c newPlace : placesList) {
                newPlace.Current__c = 'Yes';
                newPlace.Status_of_Places__c = 'Ceased';
                placesToUpdateList.add(newPlace);
                if (newPlace.Parent_Packet__c != null && !parentIds.contains(newPlace.Parent_Packet__c)) {
                    parentIds.add(newPlace.Parent_Packet__c);
                    placesToUpdateList.add(new Places_Allotment__c(Id = newPlace.Parent_Packet__c, Current__c = 'No') );
                }
            }
        }

        for (String eventId : eventIdSet) {
            eventsToUpdateList.add(new Event__c(Id = eventId, Batch_Event_Completed__c = true, Status__c = GPMSScheduledEventActionsBatch.EVENT_STATUS_APPROVED));
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

    private void updateBringOnlinePlaces(Set<String> eventIdSet, List<Places_Allotment__c> placesToUpdateList, List<Event__c> eventsToUpdateList, boolean isIP) {
        List<Places_Allotment__c> placesList = [SELECT Id,Number_of_Places__c,Allotment__c,Parent_Packet__c,Current__c,
                                                Care_Type__c,Care_Level__c,Care_Setting__c,GPMS_Number_of_Remaining__c, Status_Effective_Date__c,
                                                Status_Reason__c,Status_of_Places__c,First_Brought_into_Effect_Date__c, GPMS_Number_of_Variation__c
                                                FROM Places_Allotment__c WHERE Event__c IN :eventIdSet
                                                AND (Current__c = 'Pending') ];

        Set<String> parentIds = new Set<String>();

        if(placesList != null && !placesList.isEmpty()) {
            for(Places_Allotment__c newPlace : placesList) {
                newPlace.Current__c = 'Yes';
                placesToUpdateList.add(newPlace);
                if (newPlace.Parent_Packet__c != null && !parentIds.contains(newPlace.Parent_Packet__c)) {
                    parentIds.add(newPlace.Parent_Packet__c);
                    placesToUpdateList.add(new Places_Allotment__c(Id = newPlace.Parent_Packet__c, Current__c = 'No') );
                }
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

    private void updateCeaseS14Places(Set<String> eventIdSet, List<Places_Allotment__c> placesToUpdateList, List<Event__c> eventsToUpdateList, boolean isIP) {
        List<Places_Allotment__c> placesList = [SELECT Id,Number_of_Places__c,Allotment__c,Parent_Packet__c,Current__c,
                                                Care_Type__c,Care_Level__c,Care_Setting__c,GPMS_Number_of_Remaining__c, Status_Effective_Date__c,
                                                Status_Reason__c,Status_of_Places__c,First_Brought_into_Effect_Date__c, GPMS_Number_of_Variation__c
                                                FROM Places_Allotment__c WHERE Event__c IN :eventIdSet
                                                AND Current__c = 'Pending'];

        Set<String> parentIds = new Set<String>();

        if(placesList != null && !placesList.isEmpty()) {
            for(Places_Allotment__c newPlace : placesList) {
                newPlace.Current__c = 'Yes';
                placesToUpdateList.add(newPlace);
                if (newPlace.Parent_Packet__c != null && !parentIds.contains(newPlace.Parent_Packet__c)) {
                    parentIds.add(newPlace.Parent_Packet__c);
                    placesToUpdateList.add(new Places_Allotment__c(Id = newPlace.Parent_Packet__c, Current__c = 'No') );
                }
            }
        }

        for (String eventId : eventIdSet) {
            eventsToUpdateList.add(new Event__c(Id = eventId, Batch_Event_Completed__c = true, Status__c = 'Approved' ));
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

    private void updateNATSIFACCeasePlaces(Set<String> eventIdSet, List<Places_Allotment__c> placesToUpdateList, List<Event__c> eventsToUpdateList, boolean isIP) {
        List<Places_Allotment__c> placesList = [SELECT Id,Number_of_Places__c,Allotment__c,Parent_Packet__c,Current__c,
                                                Care_Type__c,Care_Level__c,Care_Setting__c,GPMS_Number_of_Remaining__c, Status_Effective_Date__c,
                                                Status_Reason__c,Status_of_Places__c,First_Brought_into_Effect_Date__c, GPMS_Number_of_Variation__c
                                                FROM Places_Allotment__c WHERE Event__c IN :eventIdSet
                                                AND ((Current__c = 'Pending') OR (Status_of_Places__c = 'Operational' OR Status_of_Places__c = 'Inactive'))];

        Set<String> parentIds = new Set<String>();

        if(placesList != null && !placesList.isEmpty()) {
            for(Places_Allotment__c newPlace : placesList) {
                newPlace.Current__c = 'Yes';
                newPlace.Status_of_Places__c = 'Ceased';
                placesToUpdateList.add(newPlace);
                if (newPlace.Parent_Packet__c != null && !parentIds.contains(newPlace.Parent_Packet__c)) {
                    parentIds.add(newPlace.Parent_Packet__c);
                    placesToUpdateList.add(new Places_Allotment__c(Id = newPlace.Parent_Packet__c, Current__c = 'No') );
                }
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

    private void updateCeasePlaces(Set<String> eventIdSet, List<Places_Allotment__c> placesToUpdateList, List<Event__c> eventsToUpdateList, boolean isIP) {
        List<Places_Allotment__c> placesList = [SELECT Id,Number_of_Places__c,Allotment__c,Parent_Packet__c,Current__c,
                                                Care_Type__c,Care_Level__c,Care_Setting__c,GPMS_Number_of_Remaining__c, Status_Effective_Date__c,
                                                Status_Reason__c,Status_of_Places__c,First_Brought_into_Effect_Date__c, GPMS_Number_of_Variation__c
                                                FROM Places_Allotment__c WHERE Event__c IN :eventIdSet
                                                AND Current__c = 'Pending'];

        Set<String> parentIds = new Set<String>();

        if(placesList != null && !placesList.isEmpty()) {
            for(Places_Allotment__c newPlace : placesList) {
                newPlace.Current__c = 'Yes';
                placesToUpdateList.add(newPlace);
                if (newPlace.Parent_Packet__c != null && !parentIds.contains(newPlace.Parent_Packet__c)) {
                    parentIds.add(newPlace.Parent_Packet__c);
                    placesToUpdateList.add(new Places_Allotment__c(Id = newPlace.Parent_Packet__c, Current__c = 'No') );
                }
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
