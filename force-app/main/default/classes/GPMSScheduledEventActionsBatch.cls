/****************************************************************************************************
* @CreatedBy   : Yohan Perera
* @CreatedDate : 16-Dec-2022
* @Description : Handles the logic to perform event actions when GPMS_Proposed_Operational_Date__c
                 is lapsed on the Event.
* @Test Class  : GPMSScheduledEventActionsBatchTest
*****************************************************************************************************/
public with sharing class GPMSScheduledEventActionsBatch implements Database.Batchable<SObject>,Schedulable {

    private static Map<String, Schema.RecordTypeInfo> recordTypeInfos = Schema.SObjectType.Event__c.getRecordTypeInfosByDeveloperName();

    public static final Id RT_EVENT_CEASE_S14_9 = recordTypeInfos.get('GPMS_Cease_S14_9_Places').getRecordTypeId();
    public static final Id RT_EVENT_CHANGE_CARE_SETTING = recordTypeInfos.get('Change_Care_Setting').getRecordTypeId();
    public static final Id RT_EVENT_DEED_OF_VARIATION = recordTypeInfos.get('GPMS_Deed_of_Variation').getRecordTypeId();
    public static final Id RT_EVENT_CEASE = recordTypeInfos.get('GPMS_Cease_Places').getRecordTypeId();
    public static final Id RT_EVENT_VARIATION = recordTypeInfos.get('Variation').getRecordTypeId();
    public static final Id RT_EVENT_RELINQUISH = recordTypeInfos.get('GPMS_Relinquish').getRecordTypeId();
    public static final Id RT_EVENT_REVOKE = recordTypeInfos.get('Revoke').getRecordTypeId();
    public static final Id RT_EVENT_SURRENDER = recordTypeInfos.get('Surrender').getRecordTypeId();
    public static final Id RT_EVENT_TRANSFER = recordTypeInfos.get('Transfer').getRecordTypeId();
    public static final Id RT_EVENT_BRING_ONLINE = recordTypeInfos.get('Bring_Online').getRecordTypeId();
    public static final Id RT_EVENT_NATSIFAC_REINSTATE_PLACES = recordTypeInfos.get('NATSIFAC_Reinstate_Places').getRecordTypeId();
    public static final Id RT_EVENT_NATSIFAC_CEASE = recordTypeInfos.get('NATSIFAC_Cease_Places').getRecordTypeId();
    public static final Id RT_EVENT_VARIATION_PA = recordTypeInfos.get('Variations_by_Provider_Secretary').getRecordTypeId();

    public static final String EVENT_STATUS_PENDING = 'Pending';
    public static final String EVENT_STATUS_APPROVED = 'Approved';
    public static final String EVENT_STATUS_VARIATION_ACTIVATED = 'Variation: Activated';
    public static final String EVENT_STATUS_TRANSFER_ACTIVATED = 'Transfer: Activated';
    public static final String EVENT_STATUS_APPROVED_ACTIVATED = 'Approved: Activated';
    public static final String EVENT_STATUS_REVOKED = 'Revoked';

    public static final String HOME_CARE = 'Home Care';
    public static final String RESIDENTIAL = 'Residential';

    public static final String INPUT = 'input';
    public static final String OUTPUT = 'output';

    private String queryString;
    private Set<Id> recIdSet;
    private Date today;

    ////////* -------- SCHEDULE -------- *//////////
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new GPMSScheduledEventActionsBatch());
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id, RecordTypeId FROM Event__c WHERE'
            + ' ((RecordTypeId = :RT_EVENT_CEASE_S14_9 AND Status__c = :EVENT_STATUS_PENDING AND Cessation_Effective_Date__c <= TODAY) OR' //PBI-284159
            + ' (RecordTypeId = :RT_EVENT_DEED_OF_VARIATION AND Status__c = :EVENT_STATUS_PENDING AND GPMS_Conversion_Effective_Date__c < TODAY) OR' //PBI-284204
            + ' (RecordTypeId = :RT_EVENT_CHANGE_CARE_SETTING AND Status__c = :EVENT_STATUS_PENDING AND GPMS_Care_Setting_Effective_Date__c < TODAY) OR' //PBI-284420
            + ' (RecordTypeId = :RT_EVENT_NATSIFAC_CEASE AND Status__c = :EVENT_STATUS_APPROVED AND GPMS_Date_Effective_From__c < TODAY) OR' //PBI-284889
            + ' (RecordTypeId = :RT_EVENT_VARIATION AND Status__c = :EVENT_STATUS_VARIATION_ACTIVATED AND GPMS_Proposed_Variation_Day__c <= TODAY) OR' //PBI-283643
            + ' (RecordTypeId = :RT_EVENT_RELINQUISH AND Status__c = :EVENT_STATUS_APPROVED AND GPMS_Date_Effective_From__c < TODAY) OR' //PBI-284337
            + ' (RecordTypeId = :RT_EVENT_REVOKE AND Status__c = :EVENT_STATUS_REVOKED AND GPMS_Date_Effective_From__c < TODAY) OR' //PBI-284307 / 284304
            + ' (RecordTypeId = :RT_EVENT_SURRENDER AND Status__c = :EVENT_STATUS_PENDING AND GPMS_Date_Effective_From__c < TODAY) OR' //PBI-284425
            + ' (RecordTypeId = :RT_EVENT_TRANSFER AND (Status__c = :EVENT_STATUS_TRANSFER_ACTIVATED OR Status__c = :EVENT_STATUS_APPROVED_ACTIVATED) AND GPMS_Proposed_Transfer_Date__c < TODAY) OR' //PBI-273243 //PBI-351953
            + ' (RecordTypeId = :RT_EVENT_BRING_ONLINE AND Status__c = :EVENT_STATUS_APPROVED AND GPMS_Proposed_Operational_Date__c < TODAY) OR' //PBI-283580
            + ' (RecordTypeId = :RT_EVENT_NATSIFAC_REINSTATE_PLACES AND Status__c = :EVENT_STATUS_APPROVED AND GPMS_Date_Effective_From__c < TODAY) OR' //PBI-284893
            + ' (RecordTypeId = :RT_EVENT_VARIATION_PA AND Status__c = :EVENT_STATUS_APPROVED AND GPMS_Proposed_Variation_Day__c < TODAY))' //PBI-284179
            + ' AND Batch_Event_Completed__c = FALSE';

        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Event__c> scope) {
        GPMSPerformEventAction performAction = new GPMSPerformEventAction();

        try {
            Map<String, Event__c> bringOnlineInputEventsMap = new Map<String, Event__c>();
            Map<String, Event__c> ceaseS14EventsMap = new Map<String, Event__c>();
            Map<String, Event__c> natsifacCeaseEventsMap = new Map<String, Event__c>();
            Map<String, Event__c> surrenderEventsMap = new Map<String, Event__c>();
            Map<String, Event__c> relinquishEventsMap = new Map<String, Event__c>();
            Map<String, Event__c> revocationEventsMap = new Map<String, Event__c>();
            Map<String, Event__c> deedOfVariationEventsMap = new Map<String, Event__c>();
            Map<String, Event__c> changeCareSettingsEventsMap = new Map<String, Event__c>();
            Map<String, Event__c> natsifacReinstateEventsMap = new Map<String, Event__c>();
            Map<String, Event__c> ceaseEventsMap = new Map<String, Event__c>();
            Map<String, Event__c> transferEventsMap = new Map<String, Event__c>();
            Map<String, Event__c> variationEventsMap = new Map<String, Event__c>();
            Map<String, Event__c> paVariationEventsMap = new Map<String, Event__c>();

            for (Event__c event : scope) {
                if (event.RecordTypeId == RT_EVENT_BRING_ONLINE) {
                    bringOnlineInputEventsMap.put(event.Id, event);
                } else if (event.RecordTypeId == RT_EVENT_CEASE_S14_9) {
                    ceaseS14EventsMap.put(event.Id, event);
                } else if (event.RecordTypeId == RT_EVENT_NATSIFAC_CEASE) {
                    natsifacCeaseEventsMap.put(event.Id, event);
                } else if (event.RecordTypeId == RT_EVENT_SURRENDER) {
                    surrenderEventsMap.put(event.Id, event);
                } else if (event.RecordTypeId == RT_EVENT_RELINQUISH) {
                    relinquishEventsMap.put(event.Id, event);
                } else if (event.RecordTypeId == RT_EVENT_REVOKE) {
                    revocationEventsMap.put(event.Id, event);
                } else if (event.RecordTypeId == RT_EVENT_DEED_OF_VARIATION) {
                    deedOfVariationEventsMap.put(event.Id, event);
                } else if (event.RecordTypeId == RT_EVENT_CHANGE_CARE_SETTING) {
                    changeCareSettingsEventsMap.put(event.Id, event);
                } else if (event.RecordTypeId == RT_EVENT_NATSIFAC_REINSTATE_PLACES) {
                    natsifacReinstateEventsMap.put(event.Id, event);
                } else if (event.RecordTypeId == RT_EVENT_TRANSFER) {
                    transferEventsMap.put(event.Id, event);
                } else if (event.RecordTypeId == RT_EVENT_VARIATION) {
                    variationEventsMap.put(event.Id, event);
                } else if (event.RecordTypeId == RT_EVENT_VARIATION_PA) {
                    paVariationEventsMap.put(event.Id, event);
                } else {
                    //Do nothing
                }
            }

            List<Places_Allotment__c> placesToUpdateList = new List<Places_Allotment__c>();
            List<Service_Delivery_Area__c> sdasToUpdateList = new List<Service_Delivery_Area__c>();
            List<Event__c> eventsToUpdateList = new List<Event__c>();

            performAction.processBringOnlineEvents(bringOnlineInputEventsMap, placesToUpdateList, eventsToUpdateList, false);
            performAction.processCeaseS14_9Events(ceaseS14EventsMap, placesToUpdateList, eventsToUpdateList, false);
            performAction.processSurrenderEvents(surrenderEventsMap, placesToUpdateList, eventsToUpdateList, false);
            performAction.processRelinquishEvents(relinquishEventsMap, placesToUpdateList, eventsToUpdateList, false);
            performAction.processRevocationEvents(revocationEventsMap, placesToUpdateList, eventsToUpdateList, false);
            performAction.processDeedOfVariationEvents(deedOfVariationEventsMap, placesToUpdateList, eventsToUpdateList, false);
            performAction.processChangeCareSettingsEvents(changeCareSettingsEventsMap, placesToUpdateList, eventsToUpdateList, false);
            performAction.processNATSIFACCeaseEvents(natsifacCeaseEventsMap, placesToUpdateList, eventsToUpdateList, false);
            performAction.processNATSIFACReinstateEvents(natsifacReinstateEventsMap, placesToUpdateList, eventsToUpdateList, false);
            performAction.processTransferEvents(transferEventsMap, placesToUpdateList, sdasToUpdateList, eventsToUpdateList, false);
            performAction.processPAVariationEvents(paVariationEventsMap, placesToUpdateList, sdasToUpdateList, eventsToUpdateList, false);
            performAction.processVariationEvents(variationEventsMap, placesToUpdateList, sdasToUpdateList, eventsToUpdateList, false);

            if(!placesToUpdateList.isEmpty()) {
                Map<Id, Places_Allotment__c> pasToRemoveDuplicatesMap = new Map<Id, Places_Allotment__c>();
                for (Places_Allotment__c pa : placesToUpdateList) {
                    pasToRemoveDuplicatesMap.put(pa.Id, pa);
                }
                Database.update(pasToRemoveDuplicatesMap.values(), false);
            }

            if(!eventsToUpdateList.isEmpty()) {
                Database.update(eventsToUpdateList, false);
            }

            if(!sdasToUpdateList.isEmpty()) {
                Database.update(sdasToUpdateList, false);
            }

        } catch (Exception exp) {
            dohagedcare.Logger.error(exp.getMessage(),exp,'GPMS').Log();
        }
    }

    /////////* ------------ FINISH ------------- */////////
    public void finish(Database.BatchableContext bc) {
       //Do nothing
    }
}