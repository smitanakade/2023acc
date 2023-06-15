@isTest
public with sharing class ServiceAcctRelationshipServiceTest {
	@TestSetup
	static void makeData() {
        User currentUser = TestDataFactory.createSystemAdminUser();
        System.runAs(currentUser)
        {
            Test.startTest();
            Integer recordCount = 2;
    
            // create services
            List<BusinessLicense> services = TestDataFactory.createServiceRecords(recordCount);
            // update first accreditation date in service
            for (BusinessLicense servRec : services) {
                servRec.Status = 'Approved';
                servRec.Care_Type__c = 'Residential';
                servRec.Status_Date__c = Date.valueOf('2022-10-01');
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
    
            // update association start date in sar
            for (Service_Account_Relationship__c sarRec : sar) {
                sarRec.Association_Start_Date__c = Date.valueOf('2022-07-20');
            }
            insert sar;
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
                accredCertRecords[i].Start_Date__c = System.today().addMonths(-6);
                accredCertRecords[i].End_Date__c = accredCertRecords[i].Start_Date__c.addMonths(36);
            }
            insert accredCertRecords;
		    Test.stopTest();
        }
	}

	@isTest
	public static void testUpdateTransferRating() {
         Test.startTest();
         Map<Id, BusinessLicense> servicesMap = new Map<Id, BusinessLicense>([SELECT Id FROM BusinessLicense]);
         ServiceAcctRelationshipService.fakeException = true;
         ServiceAcctRelationshipService.updateTransferRating(servicesMap);
         Test.stopTest();
        
		List<STAR_Rating_History__c> starRatingHistory = [SELECT Id, Transferred__c FROM STAR_Rating_History__c];

		for (STAR_Rating_History__c srhRec : starRatingHistory) {
			System.assertEquals(true, srhRec.Transferred__c, 'Transferred flag should be true');
		}
	}
}