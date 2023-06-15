@isTest
public with sharing class ServiceAcctRelationshipHandlerTest {
    static final String ASSOC_END_DATE = '2022-09-26';
    
    private static User currentUser = TestDataFactory.createSystemAdminUser();
    
    @testSetup static void setup() {
        
        System.runAs(currentUser){
            Test.startTest();
            ServiceAcctRelationshipHandler.fakeException = true;
            Integer recordCount = 120;
            
            // create services
            List<BusinessLicense> services = TestDataFactory.createServiceRecords(recordCount);
            // update status and care type of service
            for (BusinessLicense servRec : services) {
                servRec.Status__c = 'Operational';
                servRec.Care_Type__c = 'Residential';
                servRec.RecordTypeId = Schema.SObjectType.BusinessLicense.getRecordTypeInfosByDeveloperName()
                    .get('Approved_Provider_Service')
                    .getRecordTypeId();
            }
            insert services;
            // create providers
            List<Account> providers = TestDataFactory.createProviderRecords(recordCount);
            insert providers;
            // create sar
            List<Service_Account_Relationship__c> sar = TestDataFactory.createServiceAccountRecords(
                recordCount,
                services,
                providers
            );
            
            //update association end date of sar
            for (Service_Account_Relationship__c sarRec : sar) {
                sarRec.Association_End_Date__c = Date.valueOf(ASSOC_END_DATE);
                sarRec.Reason_Provider__c = 'test';
            }
            
            insert sar;
            
            //update association end date of sar
            for (Service_Account_Relationship__c sarRec : sar) {
                sarRec.Association_End_Date__c = Date.valueOf(ASSOC_END_DATE);
                sarRec.Reason_Provider__c = 'test';
            }
            update sar;
            // create report period
            Reporting_Period__c rp = TestDataFactory.createReportingPeriod('Year');
            insert rp;
            // create report period type quarter
            Reporting_Period__c quarterRP = TestDataFactory.createReportingPeriod('Quarter');
            insert quarterRP;
            // create star rating history records
            List<STAR_Rating_History__c> starRatingHistory = TestDataFactory.createStarRatingHistoryRecords(
                recordCount,
                services,
                providers,
                rp
            );
            insert starRatingHistory;
            // create CER records
            List<SRQI_CER__c> cerRecords = TestDataFactory.createCERRecords(recordCount, sar, providers, services, rp);
            // update cer record and link service to it
            for (SRQI_CER__c cerRec : cerRecords) {
                cerRec.Service__c = services[0].Id;
            }
            insert cerRecords;
            // Insert Accreditation/Certification records
            List<Accreditation_Certification__c> accredCertRecords = TestDataFactory.createAccreditationCertification(
                recordCount,
                services
            );
            for (Integer i = 0; i < recordCount; i++) {
                accredCertRecords[i].Start_Date__c = Math.mod(i, 2) == 0
                    ? Date.valueOf('2022-04-01')
                    : Date.valueOf('2020-01-01');
            }
            insert accredCertRecords;
            Test.stopTest();
        }
    }
    
    @isTest
    public static void testAfterUpdate() {
        Test.startTest();
        List<Service_Account_Relationship__c> sarAfter = [
            SELECT Id, Service_Name__r.Status__c, Service_Name__r.Care_Type__c, Association_End_Date__c
            FROM Service_Account_Relationship__c
        ];
        
        for (Service_Account_Relationship__c sarRec : sarAfter) {
            System.assertEquals(
                Date.valueOf(ASSOC_END_DATE),
                sarRec.Association_End_Date__c,
                'End date must be less than today and equal to 2022-09-27'
            );
            
            System.assertEquals(
                'Residential',
                sarRec.Service_Name__r.Care_Type__c,
                'Service care type must be residential'
            );
        }
        Test.stopTest();
    }
}