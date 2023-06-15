/****************************************************************************************************
* @CreatedBy   : Yohan Perera
* @CreatedDate : 11-01-2023
* @Description : Test class for GPMSScheduledEventActionsBatch
* @Test Class  : GPMSScheduledEventActionsBatchTest
*****************************************************************************************************/
@isTest
private class GPMSScheduledEventActionsBatchTest {

    public static final String TEST_SERVICE = 'Squad C Residential Care Testing';

    private static User currentUser = TestDataFactory.createGPMSTestUser();

    @isTest
    static void testBringOnlineEventsIP() {

        System.runAs(currentUser){

            BusinessLicense service = new BusinessLicense(Name = TEST_SERVICE, Status = 'Operational');
            service.recordTypeId = Schema.SObjectType.BusinessLicense.getRecordTypeInfosByDeveloperName().get('CHSP_Service').getRecordTypeId();
            insert service;

            Allotment__c allotment = GPMSTestUtility.getAllotment('Approved_Provider_Residential_ALM',service.Id);
            insert Allotment;

            Event__c evt = GPMSTestUtility.getPlaceEvent('Variations_by_Provider_Secretary');
            insert evt;

            Integer placesCount = 5;
            List<Places_Allotment__c> places = GPMSTestUtility.getPlaces(placesCount,Allotment.Id);
            for (Places_Allotment__c pa : places) {
                pa.Status_of_Places__c = 'Provisional';
            }
            insert places;

            List<Places_Allotment__c> childPlaces = GPMSTestUtility.getPlaces(placesCount,Allotment.Id);
            for (Places_Allotment__c pa : childPlaces) {
                pa.Current__c = 'Pending';
                pa.Parent_Packet__c = places.get(0).Id;
                pa.Event__c = evt.Id;
            }
            insert childPlaces;

            Map<String,Object> inputMap = new Map<String,Object>();
            Map<String,Object> outMap = new Map<String,Object>();
            Map<String,Object> options = new Map<String,Object>();


            inputMap.put('EventId', evt.Id);

            Map<String, Object> args = new Map<String, Object>();
            args.put('input', inputMap);
            args.put('output', outMap);
            args.put('options', options);

            Test.startTest();

            GPMSPerformEventAction performAction = new GPMSPerformEventAction();
            performAction.call('processBringOnlineEvents',args);

            Test.stopTest();

            Event__c evtResult = [SELECT Batch_Event_Completed__c FROM Event__c WHERE Id = :evt.Id];
            System.assertEquals(true, evtResult.Batch_Event_Completed__c);
        }

    }

    @isTest
    static void testEventsBatchSchedule() {

        System.runAs(currentUser){

            BusinessLicense service = new BusinessLicense(Name = TEST_SERVICE, Status = 'Operational');
            service.recordTypeId = Schema.SObjectType.BusinessLicense.getRecordTypeInfosByDeveloperName().get('CHSP_Service').getRecordTypeId();
            insert service;

            Allotment__c allotment = GPMSTestUtility.getAllotment('Approved_Provider_Residential_ALM',service.Id);
            insert Allotment;

            Event__c evt = GPMSTestUtility.getPlaceEvent('Variations_by_Provider_Secretary');
            evt.RecordTypeId = GPMSScheduledEventActionsBatch.RT_EVENT_BRING_ONLINE;
            evt.GPMS_Proposed_Operational_Date__c = Date.today() - 1;

            insert evt;

            Integer placesCount = 5;
            List<Places_Allotment__c> places = GPMSTestUtility.getPlaces(placesCount,Allotment.Id);
            for (Places_Allotment__c pa : places) {
                pa.Status_of_Places__c = 'Provisional';
            }
            insert places;

            List<Places_Allotment__c> childPlaces = GPMSTestUtility.getPlaces(placesCount,Allotment.Id);
            for (Places_Allotment__c pa : childPlaces) {
                pa.Current__c = 'Pending';
                pa.Parent_Packet__c = places.get(0).Id;
                pa.Event__c = evt.Id;
            }
            insert childPlaces;


            Test.startTest();

            String jobId = System.schedule('GPMSScheduledEventActionsBatchX', '0 0 0 3 9 ? 2050', new GPMSScheduledEventActionsBatch());

            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId];
            System.assertEquals(0, ct.TimesTriggered);

            Test.stopTest();
        }

    }

    @isTest
    static void testBringOnlineEventsBatch() {

        System.runAs(currentUser){

            BusinessLicense service = new BusinessLicense(Name = TEST_SERVICE, Status = 'Operational');
            service.recordTypeId = Schema.SObjectType.BusinessLicense.getRecordTypeInfosByDeveloperName().get('CHSP_Service').getRecordTypeId();
            insert service;

            Allotment__c allotment = GPMSTestUtility.getAllotment('Approved_Provider_Residential_ALM',service.Id);
            insert Allotment;

            Event__c evt = GPMSTestUtility.getPlaceEvent('Variations_by_Provider_Secretary');
            evt.RecordTypeId = GPMSScheduledEventActionsBatch.RT_EVENT_BRING_ONLINE;
            evt.GPMS_Proposed_Operational_Date__c = Date.today() - 1;
            evt.Status__c = GPMSScheduledEventActionsBatch.EVENT_STATUS_APPROVED;
            insert evt;

            Integer placesCount = 5;
            List<Places_Allotment__c> places = GPMSTestUtility.getPlaces(placesCount,Allotment.Id);
            for (Places_Allotment__c pa : places) {
                pa.Status_of_Places__c = 'Provisional';
            }
            insert places;

            List<Places_Allotment__c> childPlaces = GPMSTestUtility.getPlaces(placesCount,Allotment.Id);
            for (Places_Allotment__c pa : childPlaces) {
                pa.Current__c = 'Pending';
                pa.Parent_Packet__c = places.get(0).Id;
                pa.Event__c = evt.Id;
            }
            insert childPlaces;


            Test.startTest();

            GPMSScheduledEventActionsBatch b = new GPMSScheduledEventActionsBatch();
            Database.executeBatch(b);

            Test.stopTest();

            Event__c evtResult = [SELECT Batch_Event_Completed__c FROM Event__c WHERE Id = :evt.Id];
            System.assertEquals(true, evtResult.Batch_Event_Completed__c);

        }

    }

    @isTest
    static void testCeaseS14EventsIP() {

        System.runAs(currentUser){

            BusinessLicense service = new BusinessLicense(Name = TEST_SERVICE, Status = 'Operational');
            service.recordTypeId = Schema.SObjectType.BusinessLicense.getRecordTypeInfosByDeveloperName().get('CHSP_Service').getRecordTypeId();
            insert service;

            Allotment__c allotment = GPMSTestUtility.getAllotment('Approved_Provider_Residential_ALM',service.Id);
            insert Allotment;

            Event__c evt = GPMSTestUtility.getPlaceEvent('Variations_by_Provider_Secretary');
            insert evt;

            Integer placesCount = 5;
            List<Places_Allotment__c> places = GPMSTestUtility.getPlaces(placesCount,Allotment.Id);
            for (Places_Allotment__c pa : places) {
                pa.Status_of_Places__c = 'Operational';
            }
            insert places;

            List<Places_Allotment__c> childPlaces = GPMSTestUtility.getPlaces(placesCount,Allotment.Id);
            for (Places_Allotment__c pa : childPlaces) {
                pa.Current__c = 'Pending';
                pa.Parent_Packet__c = places.get(0).Id;
                pa.Event__c = evt.Id;
            }
            insert childPlaces;

            Map<String,Object> inputMap = new Map<String,Object>();
            Map<String,Object> outMap = new Map<String,Object>();
            Map<String,Object> options = new Map<String,Object>();


            inputMap.put('EventId', evt.Id);

            Map<String, Object> args = new Map<String, Object>();
            args.put('input', inputMap);
            args.put('output', outMap);
            args.put('options', options);

            Test.startTest();

            GPMSPerformEventAction performAction = new GPMSPerformEventAction();
            performAction.call('processCeaseS14_9Events',args);

            Test.stopTest();

            Event__c evtResult = [SELECT Batch_Event_Completed__c FROM Event__c WHERE Id = :evt.Id];
            System.assertEquals(true, evtResult.Batch_Event_Completed__c);
        }

    }

    @isTest
    static void testCeaseS14Batch() {

        System.runAs(currentUser){

            BusinessLicense service = new BusinessLicense(Name = TEST_SERVICE, Status = 'Operational');
            service.recordTypeId = Schema.SObjectType.BusinessLicense.getRecordTypeInfosByDeveloperName().get('CHSP_Service').getRecordTypeId();
            insert service;

            Allotment__c allotment = GPMSTestUtility.getAllotment('Approved_Provider_Residential_ALM',service.Id);
            insert Allotment;

            Event__c evt = GPMSTestUtility.getPlaceEvent('Variations_by_Provider_Secretary');
            evt.RecordTypeId = GPMSScheduledEventActionsBatch.RT_EVENT_CEASE_S14_9;
            evt.Cessation_Effective_Date__c = Date.today() - 1;
            evt.Status__c = GPMSScheduledEventActionsBatch.EVENT_STATUS_PENDING;
            insert evt;

            Integer placesCount = 5;
            List<Places_Allotment__c> places = GPMSTestUtility.getPlaces(placesCount,Allotment.Id);
            for (Places_Allotment__c pa : places) {
                pa.Status_of_Places__c = 'Operational';
            }
            insert places;

            List<Places_Allotment__c> childPlaces = GPMSTestUtility.getPlaces(placesCount,Allotment.Id);
            for (Places_Allotment__c pa : childPlaces) {
                pa.Current__c = 'Pending';
                pa.Parent_Packet__c = places.get(0).Id;
                pa.Event__c = evt.Id;
            }
            insert childPlaces;


            Test.startTest();

            GPMSScheduledEventActionsBatch b = new GPMSScheduledEventActionsBatch();
            Database.executeBatch(b);

            Test.stopTest();

            Event__c evtResult = [SELECT Batch_Event_Completed__c FROM Event__c WHERE Id = :evt.Id];
            System.assertEquals(true, evtResult.Batch_Event_Completed__c);

        }

    }

    @isTest
    static void testSurrenderEventsIP() {

        System.runAs(currentUser){

            BusinessLicense service = new BusinessLicense(Name = TEST_SERVICE, Status = 'Operational');
            service.recordTypeId = Schema.SObjectType.BusinessLicense.getRecordTypeInfosByDeveloperName().get('CHSP_Service').getRecordTypeId();
            insert service;

            Allotment__c allotment = GPMSTestUtility.getAllotment('Approved_Provider_Residential_ALM',service.Id);
            insert Allotment;

            Event__c evt = GPMSTestUtility.getPlaceEvent('Variations_by_Provider_Secretary');
            insert evt;

            Integer placesCount = 5;
            List<Places_Allotment__c> places = GPMSTestUtility.getPlaces(placesCount,Allotment.Id);
            for (Places_Allotment__c pa : places) {
                pa.Status_of_Places__c = 'Provisional';
            }
            insert places;

            List<Places_Allotment__c> childPlaces = GPMSTestUtility.getPlaces(placesCount,Allotment.Id);
            for (Places_Allotment__c pa : childPlaces) {
                pa.Current__c = 'Pending';
                pa.Parent_Packet__c = places.get(0).Id;
                pa.Event__c = evt.Id;
            }
            insert childPlaces;

            Map<String,Object> inputMap = new Map<String,Object>();
            Map<String,Object> outMap = new Map<String,Object>();
            Map<String,Object> options = new Map<String,Object>();


            inputMap.put('EventId', evt.Id);

            Map<String, Object> args = new Map<String, Object>();
            args.put('input', inputMap);
            args.put('output', outMap);
            args.put('options', options);

            Test.startTest();

            GPMSPerformEventAction performAction = new GPMSPerformEventAction();
            performAction.call('processSurrenderEvents',args);

            Test.stopTest();

            Event__c evtResult = [SELECT Batch_Event_Completed__c FROM Event__c WHERE Id = :evt.Id];
            System.assertEquals(true, evtResult.Batch_Event_Completed__c);
        }

    }

    @isTest
    static void testSurrenderBatch() {

        System.runAs(currentUser){

            BusinessLicense service = new BusinessLicense(Name = TEST_SERVICE, Status = 'Operational');
            service.recordTypeId = Schema.SObjectType.BusinessLicense.getRecordTypeInfosByDeveloperName().get('CHSP_Service').getRecordTypeId();
            insert service;

            Allotment__c allotment = GPMSTestUtility.getAllotment('Approved_Provider_Residential_ALM',service.Id);
            insert Allotment;

            Event__c evt = GPMSTestUtility.getPlaceEvent('Variations_by_Provider_Secretary');
            evt.RecordTypeId = GPMSScheduledEventActionsBatch.RT_EVENT_SURRENDER;
            evt.GPMS_Date_Effective_From__c = Date.today() - 1;
            evt.Status__c = GPMSScheduledEventActionsBatch.EVENT_STATUS_PENDING;
            insert evt;

            Integer placesCount = 5;
            List<Places_Allotment__c> places = GPMSTestUtility.getPlaces(placesCount,Allotment.Id);
            for (Places_Allotment__c pa : places) {
                pa.Status_of_Places__c = 'Provisional';
            }
            insert places;

            List<Places_Allotment__c> childPlaces = GPMSTestUtility.getPlaces(placesCount,Allotment.Id);
            for (Places_Allotment__c pa : childPlaces) {
                pa.Current__c = 'Pending';
                pa.Parent_Packet__c = places.get(0).Id;
                pa.Event__c = evt.Id;
            }
            insert childPlaces;


            Test.startTest();

            GPMSScheduledEventActionsBatch b = new GPMSScheduledEventActionsBatch();
            Database.executeBatch(b);

            Test.stopTest();

            Event__c evtResult = [SELECT Batch_Event_Completed__c FROM Event__c WHERE Id = :evt.Id];
            System.assertEquals(true, evtResult.Batch_Event_Completed__c);

        }

    }

    @isTest
    static void testRelinquishEventsIP() {

        System.runAs(currentUser){

            BusinessLicense service = new BusinessLicense(Name = TEST_SERVICE, Status = 'Operational');
            service.recordTypeId = Schema.SObjectType.BusinessLicense.getRecordTypeInfosByDeveloperName().get('CHSP_Service').getRecordTypeId();
            insert service;

            Allotment__c allotment = GPMSTestUtility.getAllotment('Approved_Provider_Residential_ALM',service.Id);
            insert Allotment;

            Event__c evt = GPMSTestUtility.getPlaceEvent('Variations_by_Provider_Secretary');
            insert evt;

            Integer placesCount = 5;
            List<Places_Allotment__c> places = GPMSTestUtility.getPlaces(placesCount,Allotment.Id);
            for (Places_Allotment__c pa : places) {
                pa.Status_of_Places__c = 'Operational';
            }
            insert places;

            List<Places_Allotment__c> childPlaces = GPMSTestUtility.getPlaces(placesCount,Allotment.Id);
            for (Places_Allotment__c pa : childPlaces) {
                pa.Current__c = 'Pending';
                pa.Parent_Packet__c = places.get(0).Id;
                pa.Event__c = evt.Id;
            }
            insert childPlaces;

            Map<String,Object> inputMap = new Map<String,Object>();
            Map<String,Object> outMap = new Map<String,Object>();
            Map<String,Object> options = new Map<String,Object>();


            inputMap.put('EventId', evt.Id);

            Map<String, Object> args = new Map<String, Object>();
            args.put('input', inputMap);
            args.put('output', outMap);
            args.put('options', options);

            Test.startTest();

            GPMSPerformEventAction performAction = new GPMSPerformEventAction();
            performAction.call('processRelinquishEvents',args);

            Test.stopTest();

            Event__c evtResult = [SELECT Batch_Event_Completed__c FROM Event__c WHERE Id = :evt.Id];
            System.assertEquals(true, evtResult.Batch_Event_Completed__c);
        }

    }

    @isTest
    static void testRelinquishBatch() {

        System.runAs(currentUser){

            BusinessLicense service = new BusinessLicense(Name = TEST_SERVICE, Status = 'Operational');
            service.recordTypeId = Schema.SObjectType.BusinessLicense.getRecordTypeInfosByDeveloperName().get('CHSP_Service').getRecordTypeId();
            insert service;

            Allotment__c allotment = GPMSTestUtility.getAllotment('Approved_Provider_Residential_ALM',service.Id);
            insert Allotment;

            Event__c evt = GPMSTestUtility.getPlaceEvent('Variations_by_Provider_Secretary');
            evt.RecordTypeId = GPMSScheduledEventActionsBatch.RT_EVENT_RELINQUISH;
            evt.GPMS_Date_Effective_From__c = Date.today() - 1;
            evt.Status__c = GPMSScheduledEventActionsBatch.EVENT_STATUS_APPROVED;
            insert evt;

            Integer placesCount = 5;
            List<Places_Allotment__c> places = GPMSTestUtility.getPlaces(placesCount,Allotment.Id);
            for (Places_Allotment__c pa : places) {
                pa.Status_of_Places__c = 'Operational';
            }
            insert places;

            List<Places_Allotment__c> childPlaces = GPMSTestUtility.getPlaces(placesCount,Allotment.Id);
            for (Places_Allotment__c pa : childPlaces) {
                pa.Current__c = 'Pending';
                pa.Parent_Packet__c = places.get(0).Id;
                pa.Event__c = evt.Id;
            }
            insert childPlaces;


            Test.startTest();

            GPMSScheduledEventActionsBatch b = new GPMSScheduledEventActionsBatch();
            Database.executeBatch(b);

            Test.stopTest();

            Event__c evtResult = [SELECT Batch_Event_Completed__c FROM Event__c WHERE Id = :evt.Id];
            System.assertEquals(true, evtResult.Batch_Event_Completed__c);

        }

    }

    @isTest
    static void testRevocationEventsIP() {

        System.runAs(currentUser){

            BusinessLicense service = new BusinessLicense(Name = TEST_SERVICE, Status = 'Operational');
            service.recordTypeId = Schema.SObjectType.BusinessLicense.getRecordTypeInfosByDeveloperName().get('CHSP_Service').getRecordTypeId();
            insert service;

            Allotment__c allotment = GPMSTestUtility.getAllotment('Approved_Provider_Residential_ALM',service.Id);
            insert Allotment;

            Event__c evt = GPMSTestUtility.getPlaceEvent('Variations_by_Provider_Secretary');
            insert evt;

            Integer placesCount = 5;
            List<Places_Allotment__c> places = GPMSTestUtility.getPlaces(placesCount,Allotment.Id);
            for (Places_Allotment__c pa : places) {
                pa.Status_of_Places__c = 'Provisional';
            }
            insert places;

            List<Places_Allotment__c> childPlaces = GPMSTestUtility.getPlaces(placesCount,Allotment.Id);
            for (Places_Allotment__c pa : childPlaces) {
                pa.Current__c = 'Pending';
                pa.Parent_Packet__c = places.get(0).Id;
                pa.Event__c = evt.Id;
            }
            insert childPlaces;

            Map<String,Object> inputMap = new Map<String,Object>();
            Map<String,Object> outMap = new Map<String,Object>();
            Map<String,Object> options = new Map<String,Object>();


            inputMap.put('EventId', evt.Id);

            Map<String, Object> args = new Map<String, Object>();
            args.put('input', inputMap);
            args.put('output', outMap);
            args.put('options', options);

            Test.startTest();

            GPMSPerformEventAction performAction = new GPMSPerformEventAction();
            performAction.call('processRevocationEvents',args);

            Test.stopTest();

            Event__c evtResult = [SELECT Batch_Event_Completed__c FROM Event__c WHERE Id = :evt.Id];
            System.assertEquals(true, evtResult.Batch_Event_Completed__c);
        }

    }

    @isTest
    static void testRevocationBatch() {

        System.runAs(currentUser){

            BusinessLicense service = new BusinessLicense(Name = TEST_SERVICE, Status = 'Operational');
            service.recordTypeId = Schema.SObjectType.BusinessLicense.getRecordTypeInfosByDeveloperName().get('CHSP_Service').getRecordTypeId();
            insert service;

            Allotment__c allotment = GPMSTestUtility.getAllotment('Approved_Provider_Residential_ALM',service.Id);
            insert Allotment;

            Event__c evt = GPMSTestUtility.getPlaceEvent('Variations_by_Provider_Secretary');
            evt.RecordTypeId = GPMSScheduledEventActionsBatch.RT_EVENT_REVOKE;
            evt.GPMS_Date_Effective_From__c = Date.today() - 1;
            evt.Status__c = GPMSScheduledEventActionsBatch.EVENT_STATUS_REVOKED;
            insert evt;

            Integer placesCount = 5;
            List<Places_Allotment__c> places = GPMSTestUtility.getPlaces(placesCount,Allotment.Id);
            for (Places_Allotment__c pa : places) {
                pa.Status_of_Places__c = 'Provisional';
            }
            insert places;

            List<Places_Allotment__c> childPlaces = GPMSTestUtility.getPlaces(placesCount,Allotment.Id);
            for (Places_Allotment__c pa : childPlaces) {
                pa.Current__c = 'Pending';
                pa.Parent_Packet__c = places.get(0).Id;
                pa.Event__c = evt.Id;
            }
            insert childPlaces;


            Test.startTest();

            GPMSScheduledEventActionsBatch b = new GPMSScheduledEventActionsBatch();
            Database.executeBatch(b);

            Test.stopTest();

            Event__c evtResult = [SELECT Batch_Event_Completed__c FROM Event__c WHERE Id = :evt.Id];
            System.assertEquals(true, evtResult.Batch_Event_Completed__c);

        }

    }


    @isTest
    static void testDeedofVariationEventsIP() {

        System.runAs(currentUser){

            BusinessLicense service = new BusinessLicense(Name = TEST_SERVICE, Status = 'Operational');
            service.recordTypeId = Schema.SObjectType.BusinessLicense.getRecordTypeInfosByDeveloperName().get('CHSP_Service').getRecordTypeId();
            insert service;

            Allotment__c allotment = GPMSTestUtility.getAllotment('Approved_Provider_Residential_ALM',service.Id);
            insert Allotment;

            Event__c evt = GPMSTestUtility.getPlaceEvent('Variations_by_Provider_Secretary');
            insert evt;

            Integer placesCount = 5;
            List<Places_Allotment__c> places = GPMSTestUtility.getPlaces(placesCount,Allotment.Id);
            for (Places_Allotment__c pa : places) {
                pa.Status_of_Places__c = 'Provisional';
            }
            insert places;

            List<Places_Allotment__c> childPlaces = GPMSTestUtility.getPlaces(placesCount,Allotment.Id);
            for (Places_Allotment__c pa : childPlaces) {
                pa.Current__c = 'Pending';
                pa.Parent_Packet__c = places.get(0).Id;
                pa.Event__c = evt.Id;
            }
            insert childPlaces;

            Map<String,Object> inputMap = new Map<String,Object>();
            Map<String,Object> outMap = new Map<String,Object>();
            Map<String,Object> options = new Map<String,Object>();


            inputMap.put('EventId', evt.Id);

            Map<String, Object> args = new Map<String, Object>();
            args.put('input', inputMap);
            args.put('output', outMap);
            args.put('options', options);

            Test.startTest();

            GPMSPerformEventAction performAction = new GPMSPerformEventAction();
            performAction.call('processDeedOfVariationEvents',args);

            Test.stopTest();

            Event__c evtResult = [SELECT Batch_Event_Completed__c FROM Event__c WHERE Id = :evt.Id];
            System.assertEquals(true, evtResult.Batch_Event_Completed__c);
        }

    }

    @isTest
    static void testDeedofVariationBatch() {

        System.runAs(currentUser){

            BusinessLicense service = new BusinessLicense(Name = TEST_SERVICE, Status = 'Operational');
            service.recordTypeId = Schema.SObjectType.BusinessLicense.getRecordTypeInfosByDeveloperName().get('CHSP_Service').getRecordTypeId();
            insert service;

            Allotment__c allotment = GPMSTestUtility.getAllotment('Approved_Provider_Residential_ALM',service.Id);
            insert Allotment;

            Event__c evt = GPMSTestUtility.getPlaceEvent('Variations_by_Provider_Secretary');
            evt.RecordTypeId = GPMSScheduledEventActionsBatch.RT_EVENT_DEED_OF_VARIATION;
            evt.GPMS_Conversion_Effective_Date__c = Date.today() - 1;
            evt.Status__c = GPMSScheduledEventActionsBatch.EVENT_STATUS_PENDING;
            insert evt;

            Integer placesCount = 5;
            List<Places_Allotment__c> places = GPMSTestUtility.getPlaces(placesCount,Allotment.Id);
            for (Places_Allotment__c pa : places) {
                pa.Status_of_Places__c = 'Provisional';
                pa.Care_Level__c = 'Residential';
            }
            insert places;

            List<Places_Allotment__c> childPlaces = GPMSTestUtility.getPlaces(placesCount,Allotment.Id);
            for (Places_Allotment__c pa : childPlaces) {
                pa.Current__c = 'Pending';
                pa.Parent_Packet__c = places.get(0).Id;
                pa.Event__c = evt.Id;
            }
            insert childPlaces;


            Test.startTest();

            GPMSScheduledEventActionsBatch b = new GPMSScheduledEventActionsBatch();
            Database.executeBatch(b);

            Test.stopTest();

            Event__c evtResult = [SELECT Batch_Event_Completed__c FROM Event__c WHERE Id = :evt.Id];
            System.assertEquals(true, evtResult.Batch_Event_Completed__c);

        }

    }

    @isTest
    static void testChangeCareSettingsEventsIP() {

        System.runAs(currentUser){

            BusinessLicense service = new BusinessLicense(Name = TEST_SERVICE, Status = 'Operational');
            service.recordTypeId = Schema.SObjectType.BusinessLicense.getRecordTypeInfosByDeveloperName().get('CHSP_Service').getRecordTypeId();
            insert service;

            Allotment__c allotment = GPMSTestUtility.getAllotment('Approved_Provider_Residential_ALM',service.Id);
            insert Allotment;

            Event__c evt = GPMSTestUtility.getPlaceEvent('Variations_by_Provider_Secretary');
            insert evt;

            Integer placesCount = 5;
            List<Places_Allotment__c> places = GPMSTestUtility.getPlaces(placesCount,Allotment.Id);
            for (Places_Allotment__c pa : places) {
                pa.Status_of_Places__c = 'Provisional';
            }
            insert places;

            List<Places_Allotment__c> childPlaces = GPMSTestUtility.getPlaces(placesCount,Allotment.Id);
            for (Places_Allotment__c pa : childPlaces) {
                pa.Current__c = 'Pending';
                pa.Parent_Packet__c = places.get(0).Id;
                pa.Event__c = evt.Id;
            }
            insert childPlaces;

            Map<String,Object> inputMap = new Map<String,Object>();
            Map<String,Object> outMap = new Map<String,Object>();
            Map<String,Object> options = new Map<String,Object>();


            inputMap.put('EventId', evt.Id);

            Map<String, Object> args = new Map<String, Object>();
            args.put('input', inputMap);
            args.put('output', outMap);
            args.put('options', options);

            Test.startTest();

            GPMSPerformEventAction performAction = new GPMSPerformEventAction();
            performAction.call('processChangeCareSettingsEvents',args);

            Test.stopTest();

            Event__c evtResult = [SELECT Batch_Event_Completed__c FROM Event__c WHERE Id = :evt.Id];
            System.assertEquals(true, evtResult.Batch_Event_Completed__c);
        }

    }

    @isTest
    static void testChangeCareSettingsBatch() {

        System.runAs(currentUser){

            BusinessLicense service = new BusinessLicense(Name = TEST_SERVICE, Status = 'Operational');
            service.recordTypeId = Schema.SObjectType.BusinessLicense.getRecordTypeInfosByDeveloperName().get('CHSP_Service').getRecordTypeId();
            insert service;

            Allotment__c allotment = GPMSTestUtility.getAllotment('Approved_Provider_Residential_ALM',service.Id);
            insert Allotment;

            Event__c evt = GPMSTestUtility.getPlaceEvent('Variations_by_Provider_Secretary');
            evt.RecordTypeId = GPMSScheduledEventActionsBatch.RT_EVENT_CHANGE_CARE_SETTING;
            evt.GPMS_Care_Setting_Effective_Date__c = Date.today() - 1;
            evt.Status__c = GPMSScheduledEventActionsBatch.EVENT_STATUS_PENDING;
            insert evt;

            Integer placesCount = 5;
            List<Places_Allotment__c> places = GPMSTestUtility.getPlaces(placesCount,Allotment.Id);
            for (Places_Allotment__c pa : places) {
                pa.Status_of_Places__c = 'Provisional';
                pa.Care_Level__c = 'Residential';
            }
            insert places;

            List<Places_Allotment__c> childPlaces = GPMSTestUtility.getPlaces(placesCount,Allotment.Id);
            for (Places_Allotment__c pa : childPlaces) {
                pa.Current__c = 'Pending';
                pa.Parent_Packet__c = places.get(0).Id;
                pa.Event__c = evt.Id;
            }
            insert childPlaces;


            Test.startTest();

            GPMSScheduledEventActionsBatch b = new GPMSScheduledEventActionsBatch();
            Database.executeBatch(b);

            Test.stopTest();

            Event__c evtResult = [SELECT Batch_Event_Completed__c FROM Event__c WHERE Id = :evt.Id];
            System.assertEquals(true, evtResult.Batch_Event_Completed__c);

        }

    }

    @isTest
    static void testNATSIFACCeaseEventsIP() {

        System.runAs(currentUser){

            BusinessLicense service = new BusinessLicense(Name = TEST_SERVICE, Status = 'Operational');
            service.recordTypeId = Schema.SObjectType.BusinessLicense.getRecordTypeInfosByDeveloperName().get('CHSP_Service').getRecordTypeId();
            insert service;

            Allotment__c allotment = GPMSTestUtility.getAllotment('Approved_Provider_Residential_ALM',service.Id);
            insert Allotment;

            Event__c evt = GPMSTestUtility.getPlaceEvent('Variations_by_Provider_Secretary');
            insert evt;

            Integer placesCount = 5;
            List<Places_Allotment__c> places = GPMSTestUtility.getPlaces(placesCount,Allotment.Id);
            for (Places_Allotment__c pa : places) {
                pa.Status_of_Places__c = 'Operational';
            }
            insert places;

            List<Places_Allotment__c> childPlaces = GPMSTestUtility.getPlaces(placesCount,Allotment.Id);
            for (Places_Allotment__c pa : childPlaces) {
                pa.Current__c = 'Pending';
                pa.Parent_Packet__c = places.get(0).Id;
                pa.Event__c = evt.Id;
            }
            insert childPlaces;

            Map<String,Object> inputMap = new Map<String,Object>();
            Map<String,Object> outMap = new Map<String,Object>();
            Map<String,Object> options = new Map<String,Object>();


            inputMap.put('EventId', evt.Id);

            Map<String, Object> args = new Map<String, Object>();
            args.put('input', inputMap);
            args.put('output', outMap);
            args.put('options', options);

            Test.startTest();

            GPMSPerformEventAction performAction = new GPMSPerformEventAction();
            performAction.call('processNATSIFACCeaseEvents',args);

            Test.stopTest();

            Event__c evtResult = [SELECT Batch_Event_Completed__c FROM Event__c WHERE Id = :evt.Id];
            System.assertEquals(true, evtResult.Batch_Event_Completed__c);
        }

    }

    @isTest
    static void testNATSIFACCeaseBatch() {

        System.runAs(currentUser){

            BusinessLicense service = new BusinessLicense(Name = TEST_SERVICE, Status = 'Operational');
            service.recordTypeId = Schema.SObjectType.BusinessLicense.getRecordTypeInfosByDeveloperName().get('CHSP_Service').getRecordTypeId();
            insert service;

            Allotment__c allotment = GPMSTestUtility.getAllotment('Approved_Provider_Residential_ALM',service.Id);
            insert Allotment;

            Event__c evt = GPMSTestUtility.getPlaceEvent('Variations_by_Provider_Secretary');
            evt.RecordTypeId = GPMSScheduledEventActionsBatch.RT_EVENT_NATSIFAC_CEASE;
            evt.GPMS_Date_Effective_From__c = Date.today() - 1;
            evt.Status__c = GPMSScheduledEventActionsBatch.EVENT_STATUS_APPROVED;
            insert evt;

            Integer placesCount = 5;
            List<Places_Allotment__c> places = GPMSTestUtility.getPlaces(placesCount,Allotment.Id);
            for (Places_Allotment__c pa : places) {
                pa.Status_of_Places__c = 'Operational';
            }
            insert places;

            List<Places_Allotment__c> childPlaces = GPMSTestUtility.getPlaces(placesCount,Allotment.Id);
            for (Places_Allotment__c pa : childPlaces) {
                pa.Current__c = 'Pending';
                pa.Parent_Packet__c = places.get(0).Id;
                pa.Event__c = evt.Id;
            }
            insert childPlaces;


            Test.startTest();

            GPMSScheduledEventActionsBatch b = new GPMSScheduledEventActionsBatch();
            Database.executeBatch(b);

            Test.stopTest();

            Event__c evtResult = [SELECT Batch_Event_Completed__c FROM Event__c WHERE Id = :evt.Id];
            System.assertEquals(true, evtResult.Batch_Event_Completed__c);

        }

    }

    @isTest
    static void testNATSIFACReinstateEventsIP() {

        System.runAs(currentUser){

            BusinessLicense service = new BusinessLicense(Name = TEST_SERVICE, Status = 'Operational');
            service.recordTypeId = Schema.SObjectType.BusinessLicense.getRecordTypeInfosByDeveloperName().get('CHSP_Service').getRecordTypeId();
            insert service;

            Allotment__c allotment = GPMSTestUtility.getAllotment('Approved_Provider_Residential_ALM',service.Id);
            insert Allotment;

            Event__c evt = GPMSTestUtility.getPlaceEvent('Variations_by_Provider_Secretary');
            insert evt;

            Integer placesCount = 5;
            List<Places_Allotment__c> places = GPMSTestUtility.getPlaces(placesCount,Allotment.Id);
            for (Places_Allotment__c pa : places) {
                pa.Status_of_Places__c = 'Ceased';
            }
            insert places;

            List<Places_Allotment__c> childPlaces = GPMSTestUtility.getPlaces(placesCount,Allotment.Id);
            for (Places_Allotment__c pa : childPlaces) {
                pa.Current__c = 'Pending';
                pa.Parent_Packet__c = places.get(0).Id;
                pa.Event__c = evt.Id;
            }
            insert childPlaces;

            Map<String,Object> inputMap = new Map<String,Object>();
            Map<String,Object> outMap = new Map<String,Object>();
            Map<String,Object> options = new Map<String,Object>();


            inputMap.put('EventId', evt.Id);

            Map<String, Object> args = new Map<String, Object>();
            args.put('input', inputMap);
            args.put('output', outMap);
            args.put('options', options);

            Test.startTest();

            GPMSPerformEventAction performAction = new GPMSPerformEventAction();
            performAction.call('processNATSIFACReinstateEvents',args);

            Test.stopTest();

            Event__c evtResult = [SELECT Batch_Event_Completed__c FROM Event__c WHERE Id = :evt.Id];
            System.assertEquals(true, evtResult.Batch_Event_Completed__c);
        }

    }

    @isTest
    static void testNATSIFACReinstateBatch() {

        System.runAs(currentUser){

            BusinessLicense service = new BusinessLicense(Name = TEST_SERVICE, Status = 'Operational');
            service.recordTypeId = Schema.SObjectType.BusinessLicense.getRecordTypeInfosByDeveloperName().get('CHSP_Service').getRecordTypeId();
            insert service;

            Allotment__c allotment = GPMSTestUtility.getAllotment('Approved_Provider_Residential_ALM',service.Id);
            insert Allotment;

            Event__c evt = GPMSTestUtility.getPlaceEvent('Variations_by_Provider_Secretary');
            evt.RecordTypeId = GPMSScheduledEventActionsBatch.RT_EVENT_NATSIFAC_REINSTATE_PLACES;
            evt.GPMS_Date_Effective_From__c = Date.today() - 1;
            evt.Status__c = GPMSScheduledEventActionsBatch.EVENT_STATUS_APPROVED;
            insert evt;

            Integer placesCount = 5;
            List<Places_Allotment__c> places = GPMSTestUtility.getPlaces(placesCount,Allotment.Id);
            for (Places_Allotment__c pa : places) {
                pa.Status_of_Places__c = 'Ceased';
            }
            insert places;

            List<Places_Allotment__c> childPlaces = GPMSTestUtility.getPlaces(placesCount,Allotment.Id);
            for (Places_Allotment__c pa : childPlaces) {
                pa.Current__c = 'Pending';
                pa.Parent_Packet__c = places.get(0).Id;
                pa.Event__c = evt.Id;
            }
            insert childPlaces;


            Test.startTest();

            GPMSScheduledEventActionsBatch b = new GPMSScheduledEventActionsBatch();
            Database.executeBatch(b);

            Test.stopTest();

            Event__c evtResult = [SELECT Batch_Event_Completed__c FROM Event__c WHERE Id = :evt.Id];
            System.assertEquals(true, evtResult.Batch_Event_Completed__c);

        }

    }

    @isTest
    static void testCeaseEventsIP() {

        System.runAs(currentUser){

            BusinessLicense service = new BusinessLicense(Name = TEST_SERVICE, Status = 'Operational');
            service.recordTypeId = Schema.SObjectType.BusinessLicense.getRecordTypeInfosByDeveloperName().get('CHSP_Service').getRecordTypeId();
            insert service;

            Allotment__c allotment = GPMSTestUtility.getAllotment('Approved_Provider_Residential_ALM',service.Id);
            insert Allotment;

            Event__c evt = GPMSTestUtility.getPlaceEvent('Variations_by_Provider_Secretary');
            insert evt;

            Integer placesCount = 5;
            List<Places_Allotment__c> places = GPMSTestUtility.getPlaces(placesCount,Allotment.Id);
            for (Places_Allotment__c pa : places) {
                pa.Status_of_Places__c = 'Provisional';
            }
            insert places;

            List<Places_Allotment__c> childPlaces = GPMSTestUtility.getPlaces(placesCount,Allotment.Id);
            for (Places_Allotment__c pa : childPlaces) {
                pa.Current__c = 'Pending';
                pa.Parent_Packet__c = places.get(0).Id;
                pa.Event__c = evt.Id;
            }
            insert childPlaces;

            Map<String,Object> inputMap = new Map<String,Object>();
            Map<String,Object> outMap = new Map<String,Object>();
            Map<String,Object> options = new Map<String,Object>();


            inputMap.put('EventId', evt.Id);

            Map<String, Object> args = new Map<String, Object>();
            args.put('input', inputMap);
            args.put('output', outMap);
            args.put('options', options);

            Test.startTest();

            GPMSPerformEventAction performAction = new GPMSPerformEventAction();
            performAction.call('processCeaseEvents',args);

            Test.stopTest();

            Event__c evtResult = [SELECT Batch_Event_Completed__c FROM Event__c WHERE Id = :evt.Id];
            System.assertEquals(true, evtResult.Batch_Event_Completed__c);
        }

    }

    @isTest
    static void testVariationBatch() {

        System.runAs(currentUser){

            BusinessLicense service = new BusinessLicense(Name = TEST_SERVICE, Status = 'Operational');
            service.recordTypeId = Schema.SObjectType.BusinessLicense.getRecordTypeInfosByDeveloperName().get('CHSP_Service').getRecordTypeId();
            insert service;

            Allotment__c allotment = GPMSTestUtility.getAllotment('Approved_Provider_Residential_ALM',service.Id);
            insert Allotment;

            Event__c evt = GPMSTestUtility.getPlaceEvent('Variations_by_Provider_Secretary');
            evt.RecordTypeId = GPMSScheduledEventActionsBatch.RT_EVENT_VARIATION;
            evt.Status__c = GPMSScheduledEventActionsBatch.EVENT_STATUS_VARIATION_ACTIVATED;
            evt.GPMS_Proposed_Variation_Day__c = System.Today()-2;
            insert evt;

            Integer placesCount = 5;
            List<Places_Allotment__c> places = GPMSTestUtility.getPlaces(placesCount,Allotment.Id);
            for (Places_Allotment__c pa : places) {
                pa.Status_of_Places__c = 'Provisional';
                pa.Event__c = evt.Id;
            }
            insert places;

            List<Places_Allotment__c> childPlaces = GPMSTestUtility.getPlaces(placesCount,Allotment.Id);
            for (Places_Allotment__c pa : childPlaces) {
                pa.Current__c = 'Pending';
                pa.Parent_Packet__c = places.get(0).Id;
                pa.Event__c = evt.Id;
            }
            insert childPlaces;


            Test.startTest();

            GPMSScheduledEventActionsBatch b = new GPMSScheduledEventActionsBatch();
            Database.executeBatch(b);

            Test.stopTest();

            Event__c evtResult = [SELECT Activated_Date__c, GPMS_Proposed_Variation_Day__c, Batch_Event_Completed__c FROM Event__c WHERE Id = :evt.Id];
            System.assertEquals(true, evtResult.Batch_Event_Completed__c);
            System.assertEquals(true, evtResult.Activated_Date__c == evtResult.GPMS_Proposed_Variation_Day__c);

        }

    }

	@isTest
    static void testVariationIP() {

        System.runAs(currentUser){

            BusinessLicense service = new BusinessLicense(Name = TEST_SERVICE, Status = 'Operational');
            service.recordTypeId = Schema.SObjectType.BusinessLicense.getRecordTypeInfosByDeveloperName().get('CHSP_Service').getRecordTypeId();
            insert service;

            Allotment__c allotment = GPMSTestUtility.getAllotment('Approved_Provider_Residential_ALM',service.Id);
            insert Allotment;

            Event__c evt = GPMSTestUtility.getPlaceEvent('Variations_by_Provider_Secretary');
            insert evt;

            Integer placesCount = 5;
            List<Places_Allotment__c> places = GPMSTestUtility.getPlaces(placesCount,Allotment.Id);
            for (Places_Allotment__c pa : places) {
                pa.Status_of_Places__c = 'Provisional';
            }
            insert places;

            List<Places_Allotment__c> childPlaces = GPMSTestUtility.getPlaces(placesCount,Allotment.Id);
            for (Places_Allotment__c pa : childPlaces) {
                pa.Current__c = 'Pending';
                pa.Parent_Packet__c = places.get(0).Id;
                pa.Event__c = evt.Id;
            }
            insert childPlaces;

            Map<String,Object> inputMap = new Map<String,Object>();
            Map<String,Object> outMap = new Map<String,Object>();
            Map<String,Object> options = new Map<String,Object>();


            inputMap.put('EventId', evt.Id);

            Map<String, Object> args = new Map<String, Object>();
            args.put('input', inputMap);
            args.put('output', outMap);
            args.put('options', options);

            Test.startTest();

            GPMSPerformEventAction performAction = new GPMSPerformEventAction();
            performAction.call('processVariationEvents',args);

            Test.stopTest();

            Event__c evtResult = [SELECT Batch_Event_Completed__c FROM Event__c WHERE Id = :evt.Id];
            System.assertEquals(true, evtResult.Batch_Event_Completed__c);
        }

    }

	@isTest
    static void testPAVariationIP() {

        System.runAs(currentUser){

            BusinessLicense service = new BusinessLicense(Name = TEST_SERVICE, Status = 'Operational');
            service.recordTypeId = Schema.SObjectType.BusinessLicense.getRecordTypeInfosByDeveloperName().get('CHSP_Service').getRecordTypeId();
            insert service;

            Allotment__c allotment = GPMSTestUtility.getAllotment('Approved_Provider_Residential_ALM',service.Id);
            insert Allotment;

            Event__c evt = GPMSTestUtility.getPlaceEvent('Variations_by_Provider_Secretary');
            insert evt;

            Integer placesCount = 5;
            List<Places_Allotment__c> places = GPMSTestUtility.getPlaces(placesCount,Allotment.Id);
            for (Places_Allotment__c pa : places) {
                pa.Status_of_Places__c = 'Provisional';
            }
            insert places;

            List<Places_Allotment__c> childPlaces = GPMSTestUtility.getPlaces(placesCount,Allotment.Id);
            for (Places_Allotment__c pa : childPlaces) {
                pa.Current__c = 'Pending';
                pa.Parent_Packet__c = places.get(0).Id;
                pa.Event__c = evt.Id;
            }
            insert childPlaces;

            Map<String,Object> inputMap = new Map<String,Object>();
            Map<String,Object> outMap = new Map<String,Object>();
            Map<String,Object> options = new Map<String,Object>();


            inputMap.put('EventId', evt.Id);

            Map<String, Object> args = new Map<String, Object>();
            args.put('input', inputMap);
            args.put('output', outMap);
            args.put('options', options);

            Test.startTest();

            GPMSPerformEventAction performAction = new GPMSPerformEventAction();
            performAction.call('processPAVariationEvents',args);

            Test.stopTest();

            Event__c evtResult = [SELECT Batch_Event_Completed__c FROM Event__c WHERE Id = :evt.Id];
            System.assertEquals(true, evtResult.Batch_Event_Completed__c);
        }

    }
}
