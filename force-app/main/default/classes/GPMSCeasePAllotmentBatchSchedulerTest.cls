/****************************************************************************************************
* @CreatedBy   : Yohan Perera
* @CreatedDate : 8-12-2022
* @Description : Test class for GPMSCeasePlacesAllotmentBatchScheduler
* @Test Class  : GPMSCeasePAllotmentBatchSchedulerTest
*****************************************************************************************************/
@isTest
private class GPMSCeasePAllotmentBatchSchedulerTest {

    private static User currentUser = TestDataFactory.createGPMSTestUser();

    @isTest
    static void testPACeaseEventCreation() {

        System.runAs(currentUser){
            Account accountToInsert = GPMSTestUtility.getACOAccount();
            insert accountToInsert;

            Contact contactToInsert = GPMSTestUtility.getContact();
            insert contactToInsert;

            BusinessLicense service = new BusinessLicense(Name = 'Squad C Residential Care Testing', Status = 'Operational');
            service.recordTypeId = Schema.SObjectType.BusinessLicense.getRecordTypeInfosByDeveloperName().get('CHSP_Service').getRecordTypeId();
            service.Status_Date__c =  Date.today();
            insert service;

            Contact_Relationship__c contactRelationshipToInsert = GPMSTestUtility.getServiceContactRelationship('Service_Point_of_Contact_CR',service.Id,contactToInsert.Id);

            contactRelationshipToInsert.Role__c = 'Primary Contact';
            insert contactRelationshipToInsert;

            Test.startTest();

            Allotment__c allotment = new Allotment__c(Service_Name__c = service.Id, PA_Period_End_Date__c = Date.today().addDays(-1));
            insert allotment;

            List<Places_Allotment__c> places = GPMSTestUtility.getPlaces(1, allotment.Id);
            places.get(0).Status_of_Places__c = 'Provisional';
            insert places;

            String jobId = System.schedule('GPMSCeasePlacesAllotmentBatchScheduler' + System.now(), '0 0 0 3 9 ? 2050', new GPMSCeasePlacesAllotmentBatchScheduler());

            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId];
            System.assertEquals(0, ct.TimesTriggered);

            Test.stopTest();
        }

    }
}
