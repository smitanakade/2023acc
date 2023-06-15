@isTest
public class SCRRatingCalculationBatchTest {
	@testSetup
	static void setup() {
		Date currentDate = Date.today();
		//( Association_Start_Date <= TODAY() && (Association_End_Date > TODAY() || ISNULL(Association_End_Date)), true, false)

		Date associationStartDate1 = Date.valueOf('2022-05-31'); // less than 1 year
		Date associationStartDate2 = Date.valueOf('2020-12-31'); // older than 1 year
		Date associationStartDate3 = Date.valueOf('2017-12-31'); // 3 years older
		Date associationStartDate4 = null;

		Date accreditationStartDate1 = Date.valueOf('2022-05-31'); // less than 1 year
		Date accreditationStartDate2 = Date.valueOf('2020-05-31'); // older than 1 year
		Date accreditationStartDate3 = Date.valueOf('2017-12-31'); // 3 years older
		Date accreditationStartDate4 = null;

		Date decisionDate1 = Date.valueOf('2022-05-31'); // less than 1 year
		Date decisionDate2 = Date.valueOf('2021-12-31'); // older than 1 year
		Date decisionDate3 = Date.valueOf('2017-12-31'); // 3 years older
		Date decisionDate4 = null;

		Date associationStartEndDate1 = Date.valueOf('2022-12-31');
		Date associationStartEndDate2 = Date.valueOf('2023-12-31');

		Date associationStartEndDate4 = Date.valueOf('2025-12-31');
		Date associationStartEndDate5 = null;
		String ratingType1 = 'Current Rating';
		String ratingType2 = 'Previous Rating';
		List<BusinessLicense> allServices = new List<BusinessLicense>();
		List<Service_Account_Relationship__c> allSAccountReList = new List<Service_Account_Relationship__c>();
		List<Accreditation_Certification__c> allAccrCertList = new List<Accreditation_Certification__c>();
		List<Service_Compliance_History__c> allSerciveComplinceHistories = new List<Service_Compliance_History__c>();
		List<Service_Account_Relationship__c> allSARToUpdate = new List<Service_Account_Relationship__c>();
        List<Allotment__c> allAlots = new List<Allotment__c>();
        
		User testUser = TestDataFactory.createSystemAdminUser();
		Test.startTest();
		System.runAs(testUser){
			// Create 2 providers for test
			List<Account> providers = TestDataFactory.createProviderRecords(1);
			insert providers;
			//creating Care_Type object records
			List<Care_Type__c> careTypeListRecords = TestDataFactory.createSCRcareType(1, providers);
			insert careTypeListRecords;

			//scenario1 older than 3 years and no SCR records  =====================================================

			List<BusinessLicense> serviceRecordsListscenarios1 = TestDataFactory.createSCRServiceRecords(
				1,
				'TestService1',
				providers,
				0,
				null,
				0
			);
			allServices.addAll(serviceRecordsListscenarios1);
			//scenario2  3 years and SCH 4==============================================
			List<BusinessLicense> serviceRecordsListscenarios2 = TestDataFactory.createSCRServiceRecords(
				1,
				'TestService2',
				providers,
				0,
				0,
				0
			);

			allServices.addAll(serviceRecordsListscenarios2);

			//scenario2_v1  3 years and CountArchRegDecision > 0 with SCH record==============================================
			List<BusinessLicense> serviceRecordsListscenarios21 = TestDataFactory.createSCRServiceRecords(
				1,
				'TestService21',
				providers,
				0,
				0,
				1
			);

			allServices.addAll(serviceRecordsListscenarios21);

			//scenario2_v2  3 years and CountArchRegDecision > 0 with NO SCH record==============================================
			List<BusinessLicense> serviceRecordsListscenarios22 = TestDataFactory.createSCRServiceRecords(
				1,
				'TestService22',
				providers,
				0,
				null,
				1
			);

			allServices.addAll(serviceRecordsListscenarios22);

			//scenario3 Older than 1 year less than 3 years======with SCH 5========================================
			List<BusinessLicense> serviceRecordsListscenarios3 = TestDataFactory.createSCRServiceRecords(
				1,
				'TestService3',
				providers,
				0,
				0,
				0
			);

			allServices.addAll(serviceRecordsListscenarios3);

			//scenario4 Older than 1 year less than 3 years======0 record SCH ========================================
			List<BusinessLicense> serviceRecordsListscenarios4 = TestDataFactory.createSCRServiceRecords(
				1,
				'TestService4',
				providers,
				null,
				0,
				null
			);

			allServices.addAll(serviceRecordsListscenarios4);

			//scenario4_v1  3 years and CountArchRegDecision > 0, with SCH record==============================================
			List<BusinessLicense> serviceRecordsListscenarios41 = TestDataFactory.createSCRServiceRecords(
				1,
				'TestService41',
				providers,
				0,
				null,
				1
			);

			allServices.addAll(serviceRecordsListscenarios41);

			//scenario5 less than 1 year less than 3 years and rating 4, 5 record SCH ========================================
			List<BusinessLicense> serviceRecordsListscenarios5 = TestDataFactory.createSCRServiceRecords(
				1,
				'TestService5',
				providers,
				1,
				0,
				1
			);

			allServices.addAll(serviceRecordsListscenarios5);
			//scenario4_v2 , 3 years and CountArchRegDecision > 0 with NO SCH record==============================================
			List<BusinessLicense> serviceRecordsListscenarios42 = TestDataFactory.createSCRServiceRecords(
				1,
				'TestService42',
				providers,
				0,
				0,
				1
			);

			allServices.addAll(serviceRecordsListscenarios42);
			//scenario6 less than 1 year and 0 records SCH ========================================
			List<BusinessLicense> serviceRecordsListscenarios6 = TestDataFactory.createSCRServiceRecords(
				1,
				'TestService6',
				providers,
				0,
				null,
				0
			);
			allServices.addAll(serviceRecordsListscenarios6);

			//scenario7 If FirstAccrDt > 365 but first association < 365 - With zero SCH records-- Transferred Service=======================================

			List<BusinessLicense> serviceRecordsListscenarios7 = TestDataFactory.createSCRServiceRecords(
				1,
				'TestService7',
				providers,
				0,
				0,
				0
			);

			allServices.addAll(serviceRecordsListscenarios7);
           
            //scenario7.1 If FirstAccrDt > 365 but first association < 365 -  we have SCH records > 3-- Transferred Service=======================================
			List<BusinessLicense> serviceRecordsListscenarios71 = TestDataFactory.createSCRServiceRecords(
				1,
				'TestService71',
				providers,
				0,
				0,
				0
			);

			allServices.addAll(serviceRecordsListscenarios71);
			
            //scenario8 less than 1 year and 0  record SCH ========================================
			List<BusinessLicense> serviceRecordsListscenarios8 = TestDataFactory.createSCRServiceRecords(
				1,
				'TestService8',
				providers,
				null,
				null,
				0
			);

			allServices.addAll(serviceRecordsListscenarios8);

			// scenario9 If FirstAccrDt < 365 but first association < 365 --- New Service record SCH ==========
			List<BusinessLicense> serviceRecordsListscenarios9 = TestDataFactory.createSCRServiceRecords(
				1,
				'TestService9',
				providers,
				null,
				null,
				null
			);
            allServices.addAll(serviceRecordsListscenarios9);
            // scenario9.1 If FirstAccrDt < 365 but first association < 365 --- SCH with Record3 then New Service record Null
			List<BusinessLicense> serviceRecordsListscenarios91 = TestDataFactory.createSCRServiceRecords(
				1,
				'TestService91',
				providers,
				0,
				0,
				0
			);
			allServices.addAll(serviceRecordsListscenarios91);
            
            // scenario9.2 If FirstAccrDt > 365 && FirstAccrDt < 3 years,  but first association < 365 --- SCH with Record3 then New Service record Null ========================================
			List<BusinessLicense> serviceRecordsListscenarios92 = TestDataFactory.createSCRServiceRecords(
				1,
				'TestService92',
				providers,
				0,
				0,
				0
			);
			allServices.addAll(serviceRecordsListscenarios92);
			//scenario10 If FirstAccrDt > 365 but first association < 365 --- Transferred Service  ========================================
			List<BusinessLicense> serviceRecordsListscenarios10 = TestDataFactory.createSCRServiceRecords(
				1,
				'TestService10',
				providers,
				null,
				null,
				0
			);

			allServices.addAll(serviceRecordsListscenarios10);
			insert allServices;
                       
            for(BusinessLicense rec : allServices){
                Allotment__c allot = new Allotment__c();
            	allot.Operational__c = 4;
            	allot.Service_Name__c = rec.Id;
                allAlots.add(allot);
            }
            
            insert allAlots;
            
            // create Places Allotment
            List<Places_Allotment__c> placeAllot = new List<Places_Allotment__c>();
            for(Allotment__c rec : allAlots){
                Places_Allotment__c pallot = new Places_Allotment__c();
            	pallot.Number_of_Places__c = 4;
                pallot.Status_of_Places__c = 'Operational';
                pallot.Current__c = 'Yes';
            	pallot.Allotment__c = rec.Id;
                placeAllot.add(pallot);
            }
            insert placeAllot;
            // This update will trigger flow Service: Update Service Status Start Date and set service status to operational
            update allServices;

			List<Service_Account_Relationship__c> serviceAccountRelationshipListscenarios1 = TestDataFactory.createServiceAccountRecords(
				1,
				serviceRecordsListscenarios1,
				providers
			);
			allSAccountReList.addAll(serviceAccountRelationshipListscenarios1);

			List<Service_Account_Relationship__c> serviceAccountRelationshipListscenarios2 = TestDataFactory.createServiceAccountRecords(
				1,
				serviceRecordsListscenarios2,
				providers
			);
			allSAccountReList.addAll(serviceAccountRelationshipListscenarios2);

			List<Service_Account_Relationship__c> serviceAccountRelationshipListscenarios21 = TestDataFactory.createServiceAccountRecords(
				1,
				serviceRecordsListscenarios21,
				providers
			);
			allSAccountReList.addAll(serviceAccountRelationshipListscenarios21);

			List<Service_Account_Relationship__c> serviceAccountRelationshipListscenarios22 = TestDataFactory.createServiceAccountRecords(
				1,
				serviceRecordsListscenarios22,
				providers
			);
			allSAccountReList.addAll(serviceAccountRelationshipListscenarios22);

			List<Service_Account_Relationship__c> serviceAccountRelationshipListscenarios4 = TestDataFactory.createServiceAccountRecords(
				1,
				serviceRecordsListscenarios4,
				providers
			);
			allSAccountReList.addAll(serviceAccountRelationshipListscenarios4);

			List<Service_Account_Relationship__c> serviceAccountRelationshipListscenarios3 = TestDataFactory.createServiceAccountRecords(
				1,
				serviceRecordsListscenarios3,
				providers
			);
			allSAccountReList.addAll(serviceAccountRelationshipListscenarios3);

			List<Service_Account_Relationship__c> serviceAccountRelationshipListscenarios41 = TestDataFactory.createServiceAccountRecords(
				1,
				serviceRecordsListscenarios41,
				providers
			);
			allSAccountReList.addAll(serviceAccountRelationshipListscenarios41);

			List<Service_Account_Relationship__c> serviceAccountRelationshipListscenarios42 = TestDataFactory.createServiceAccountRecords(
				1,
				serviceRecordsListscenarios42,
				providers
			);
			allSAccountReList.addAll(serviceAccountRelationshipListscenarios42);

			List<Service_Account_Relationship__c> serviceAccountRelationshipListscenarios5 = TestDataFactory.createServiceAccountRecords(
				1,
				serviceRecordsListscenarios5,
				providers
			);
			allSAccountReList.addAll(serviceAccountRelationshipListscenarios5);
            
            List<Service_Account_Relationship__c> serviceAccountRelationshipListscenarios6 = TestDataFactory.createServiceAccountRecords(
				1,
				serviceRecordsListscenarios6,
				providers
			);
			allSAccountReList.addAll(serviceAccountRelationshipListscenarios6);

			List<Service_Account_Relationship__c> serviceAccountRelationshipListscenarios7 = TestDataFactory.createServiceAccountRecords(
				1,
				serviceRecordsListscenarios7,
				providers
			);
			allSAccountReList.addAll(serviceAccountRelationshipListscenarios7);
            
            List<Service_Account_Relationship__c> serviceAccountRelationshipListscenarios71 = TestDataFactory.createServiceAccountRecords(
				1,
				serviceRecordsListscenarios71,
				providers
			);
			allSAccountReList.addAll(serviceAccountRelationshipListscenarios71);


			List<Service_Account_Relationship__c> serviceAccountRelationshipListscenarios8 = TestDataFactory.createServiceAccountRecords(
				1,
				serviceRecordsListscenarios8,
				providers
			);
			allSAccountReList.addAll(serviceAccountRelationshipListscenarios8);

			

			List<Service_Account_Relationship__c> serviceAccountRelationshipListscenarios9 = TestDataFactory.createServiceAccountRecords(
				1,
				serviceRecordsListscenarios9,
				providers
			);
			allSAccountReList.addAll(serviceAccountRelationshipListscenarios9);
            
            List<Service_Account_Relationship__c> serviceAccountRelationshipListscenarios91 = TestDataFactory.createServiceAccountRecords(
				1,
				serviceRecordsListscenarios91,
				providers
			);
			allSAccountReList.addAll(serviceAccountRelationshipListscenarios91);
            
            List<Service_Account_Relationship__c> serviceAccountRelationshipListscenarios92 = TestDataFactory.createServiceAccountRecords(
				1,
				serviceRecordsListscenarios92,
				providers
			);
			allSAccountReList.addAll(serviceAccountRelationshipListscenarios92);

			List<Service_Account_Relationship__c> serviceAccountRelationshipListscenarios10 = TestDataFactory.createServiceAccountRecords(
				1,
				serviceRecordsListscenarios10,
				providers
			);
			allSAccountReList.addAll(serviceAccountRelationshipListscenarios10);

			insert allSAccountReList;

			List<Accreditation_Certification__c> accreditationCertificationListscenarios1 = TestDataFactory.createSCRAccreditationCertification(
				1,
				serviceRecordsListscenarios1,
				accreditationStartDate3,
				decisionDate3
			);
			allAccrCertList.addAll(accreditationCertificationListscenarios1);

			List<Accreditation_Certification__c> accreditationCertificationListscenarios2 = TestDataFactory.createSCRAccreditationCertification(
				1,
				serviceRecordsListscenarios2,
				accreditationStartDate3,
				decisionDate3
			);
			allAccrCertList.addAll(accreditationCertificationListscenarios2);

			List<Accreditation_Certification__c> accreditationCertificationListscenarios21 = TestDataFactory.createSCRAccreditationCertification(
				1,
				serviceRecordsListscenarios21,
				accreditationStartDate3,
				decisionDate3
			);
			allAccrCertList.addAll(accreditationCertificationListscenarios21);

			List<Accreditation_Certification__c> accreditationCertificationListscenarios22 = TestDataFactory.createSCRAccreditationCertification(
				1,
				serviceRecordsListscenarios22,
				accreditationStartDate3,
				decisionDate3
			);
			allAccrCertList.addAll(accreditationCertificationListscenarios22);

			List<Accreditation_Certification__c> accreditationCertificationListscenarios3 = TestDataFactory.createSCRAccreditationCertification(
				1,
				serviceRecordsListscenarios3,
				accreditationStartDate2,
				decisionDate2
			);
			allAccrCertList.addAll(accreditationCertificationListscenarios3);

			List<Accreditation_Certification__c> accreditationCertificationListscenarios4 = TestDataFactory.createSCRAccreditationCertification(
				1,
				serviceRecordsListscenarios4,
				accreditationStartDate2,
				decisionDate3
			);
			allAccrCertList.addAll(accreditationCertificationListscenarios4);

			List<Accreditation_Certification__c> accreditationCertificationListscenarios41 = TestDataFactory.createSCRAccreditationCertification(
				1,
				serviceRecordsListscenarios41,
				accreditationStartDate2,
				decisionDate3
			);
			allAccrCertList.addAll(accreditationCertificationListscenarios41);

			List<Accreditation_Certification__c> accreditationCertificationListscenarios42 = TestDataFactory.createSCRAccreditationCertification(
				1,
				serviceRecordsListscenarios42,
				accreditationStartDate2,
				decisionDate3
			);
			allAccrCertList.addAll(accreditationCertificationListscenarios42);

			List<Accreditation_Certification__c> accreditationCertificationListscenarios5 = TestDataFactory.createSCRAccreditationCertification(
				1,
				serviceRecordsListscenarios5,
				accreditationStartDate2,
				decisionDate2
			);
			allAccrCertList.addAll(accreditationCertificationListscenarios5);

			List<Accreditation_Certification__c> accreditationCertificationListscenarios6 = TestDataFactory.createSCRAccreditationCertification(
				1,
				serviceRecordsListscenarios6,
				accreditationStartDate1,
				decisionDate2
			);
			allAccrCertList.addAll(accreditationCertificationListscenarios6);

			List<Accreditation_Certification__c> accreditationCertificationListscenarios7 = TestDataFactory.createSCRAccreditationCertification(
				1,
				serviceRecordsListscenarios7,
				accreditationStartDate2,
				decisionDate1
			);
			allAccrCertList.addAll(accreditationCertificationListscenarios7);
            
            List<Accreditation_Certification__c> accreditationCertificationListscenarios71 = TestDataFactory.createSCRAccreditationCertification(
				1,
				serviceRecordsListscenarios71,
				accreditationStartDate2,
				decisionDate1
			);
			allAccrCertList.addAll(accreditationCertificationListscenarios71);

			List<Accreditation_Certification__c> accreditationCertificationListscenarios8 = TestDataFactory.createSCRAccreditationCertification(
				1,
				serviceRecordsListscenarios8,
				accreditationStartDate1,
				decisionDate1
			);
			allAccrCertList.addAll(accreditationCertificationListscenarios8);

			List<Accreditation_Certification__c> accreditationCertificationListscenarios9 = TestDataFactory.createSCRAccreditationCertification(
				1,
				serviceRecordsListscenarios9,
				accreditationStartDate1,
				decisionDate1
			);
			allAccrCertList.addAll(accreditationCertificationListscenarios9);
            
            List<Accreditation_Certification__c> accreditationCertificationListscenarios91 = TestDataFactory.createSCRAccreditationCertification(
				1,
				serviceRecordsListscenarios91,
				accreditationStartDate1,
				decisionDate1
			);
			allAccrCertList.addAll(accreditationCertificationListscenarios91);
            
            List<Accreditation_Certification__c> accreditationCertificationListscenarios92 = TestDataFactory.createSCRAccreditationCertification(
				1,
				serviceRecordsListscenarios92,
				accreditationStartDate1,
				decisionDate1
			);
			allAccrCertList.addAll(accreditationCertificationListscenarios92);

			List<Accreditation_Certification__c> accreditationCertificationListscenarios10 = TestDataFactory.createSCRAccreditationCertification(
				1,
				serviceRecordsListscenarios10,
				accreditationStartDate1,
				decisionDate1
			);
			allAccrCertList.addAll(accreditationCertificationListscenarios10);

			insert allAccrCertList;

			List<Service_Compliance_History__c> complianceHistoryListscenarios2 = TestDataFactory.createSCRServiceComplianceHistory(
				1,
				serviceRecordsListscenarios2,
				4,
				ratingType1
			);
			allSerciveComplinceHistories.addAll(complianceHistoryListscenarios2);

			List<Service_Compliance_History__c> complianceHistoryListscenarios21 = TestDataFactory.createSCRServiceComplianceHistory(
				1,
				serviceRecordsListscenarios21,
				3,
				ratingType1
			);
			allSerciveComplinceHistories.addAll(complianceHistoryListscenarios21);

			List<Service_Compliance_History__c> complianceHistoryListscenarios3 = TestDataFactory.createSCRServiceComplianceHistory(
				1,
				serviceRecordsListscenarios3,
				5,
				ratingType1
			);
			allSerciveComplinceHistories.addAll(complianceHistoryListscenarios3);

			List<Service_Compliance_History__c> complianceHistoryListscenarios41 = TestDataFactory.createSCRServiceComplianceHistory(
				1,
				serviceRecordsListscenarios41,
				5,
				ratingType1
			);
			allSerciveComplinceHistories.addAll(complianceHistoryListscenarios41);

			List<Service_Compliance_History__c> complianceHistoryListscenarios51 = TestDataFactory.createSCRServiceComplianceHistory(
				1,
				serviceRecordsListscenarios5,
				4,
				ratingType1
			);
			allSerciveComplinceHistories.addAll(complianceHistoryListscenarios51);

			List<Service_Compliance_History__c> complianceHistoryListscenarios52 = TestDataFactory.createSCRServiceComplianceHistory(
				1,
				serviceRecordsListscenarios5,
				5,
				ratingType1
			);
			allSerciveComplinceHistories.addAll(complianceHistoryListscenarios52);
            
            List<Service_Compliance_History__c> complianceHistoryListscenarios71 = TestDataFactory.createSCRServiceComplianceHistory(
				1,
				serviceRecordsListscenarios71,
				3,
				ratingType1
			);
			allSerciveComplinceHistories.addAll(complianceHistoryListscenarios71);
            
             List<Service_Compliance_History__c> complianceHistoryListscenarios91 = TestDataFactory.createSCRServiceComplianceHistory(
				1,
				serviceRecordsListscenarios91,
				3,
				ratingType1
			);
			allSerciveComplinceHistories.addAll(complianceHistoryListscenarios91);
            
             List<Service_Compliance_History__c> complianceHistoryListscenarios92 = TestDataFactory.createSCRServiceComplianceHistory(
				1,
				serviceRecordsListscenarios92,
				3,
				ratingType1
			);
			allSerciveComplinceHistories.addAll(complianceHistoryListscenarios92);


			List<Service_Compliance_History__c> complianceHistoryListscenarios10 = TestDataFactory.createSCRServiceComplianceHistory(
				1,
				serviceRecordsListscenarios10,
				5,
				ratingType1
			);
			allSerciveComplinceHistories.addAll(complianceHistoryListscenarios10);
            
           
            

			insert allSerciveComplinceHistories;

			for (Service_Account_Relationship__c serviceAccount : serviceAccountRelationshipListscenarios1) {
				serviceAccount.Association_Start_Date__c = associationStartDate3;
				serviceAccount.Association_End_Date__c = associationStartEndDate4;
				serviceAccount.CurrentNonCurrentRegDec__c = null;
				serviceAccount.CountCurrentRegDec__c = null;
				serviceAccount.CountArchRegDecision__c = null;
			}
			allSARToUpdate.addAll(serviceAccountRelationshipListscenarios1);

			for (Service_Account_Relationship__c serviceAccount : serviceAccountRelationshipListscenarios2) {
				serviceAccount.Association_Start_Date__c = associationStartDate3;
				serviceAccount.Association_End_Date__c = associationStartEndDate4;
				serviceAccount.CurrentNonCurrentRegDec__c = 0;
				serviceAccount.CountCurrentRegDec__c = 0;
				serviceAccount.CountArchRegDecision__c = 0;
			}
			allSARToUpdate.addAll(serviceAccountRelationshipListscenarios2);

			for (Service_Account_Relationship__c serviceAccount : serviceAccountRelationshipListscenarios21) {
				serviceAccount.Association_Start_Date__c = associationStartDate3;
				serviceAccount.Association_End_Date__c = associationStartEndDate4;
				serviceAccount.CurrentNonCurrentRegDec__c = 0;
				serviceAccount.CountCurrentRegDec__c = 0;
				serviceAccount.CountArchRegDecision__c = 1;
			}
			allSARToUpdate.addAll(serviceAccountRelationshipListscenarios21);

			for (Service_Account_Relationship__c serviceAccount : serviceAccountRelationshipListscenarios22) {
				serviceAccount.Association_Start_Date__c = associationStartDate3;
				serviceAccount.Association_End_Date__c = associationStartEndDate2;
				serviceAccount.CurrentNonCurrentRegDec__c = 0;
				serviceAccount.CountCurrentRegDec__c = null;
				serviceAccount.CountArchRegDecision__c = 1;
			}
			allSARToUpdate.addAll(serviceAccountRelationshipListscenarios22);

			for (Service_Account_Relationship__c serviceAccount : serviceAccountRelationshipListscenarios3) {
				serviceAccount.Association_Start_Date__c = associationStartDate2;
				serviceAccount.Association_End_Date__c = associationStartEndDate2;
				serviceAccount.CurrentNonCurrentRegDec__c = 0;
				serviceAccount.CountCurrentRegDec__c = 0;
				serviceAccount.CountArchRegDecision__c = 0;
			}
			allSARToUpdate.addAll(serviceAccountRelationshipListscenarios3);

			for (Service_Account_Relationship__c serviceAccount : serviceAccountRelationshipListscenarios4) {
				serviceAccount.Association_Start_Date__c = associationStartDate2;
				serviceAccount.Association_End_Date__c = associationStartEndDate2;
				serviceAccount.CurrentNonCurrentRegDec__c = null;
				serviceAccount.CountCurrentRegDec__c = 0;
				serviceAccount.CountArchRegDecision__c = null;
			}
			allSARToUpdate.addAll(serviceAccountRelationshipListscenarios4);

			for (Service_Account_Relationship__c serviceAccount : serviceAccountRelationshipListscenarios41) {
				serviceAccount.Association_Start_Date__c = associationStartDate2;
				serviceAccount.Association_End_Date__c = associationStartEndDate2;
				serviceAccount.CurrentNonCurrentRegDec__c = 0;
				serviceAccount.CountCurrentRegDec__c = null;
				serviceAccount.CountArchRegDecision__c = 1;
			}
			allSARToUpdate.addAll(serviceAccountRelationshipListscenarios41);

			for (Service_Account_Relationship__c serviceAccount : serviceAccountRelationshipListscenarios42) {
				serviceAccount.Association_Start_Date__c = associationStartDate2;
				serviceAccount.Association_End_Date__c = associationStartEndDate2;
				serviceAccount.CurrentNonCurrentRegDec__c = 0;
				serviceAccount.CountCurrentRegDec__c = 0;
				serviceAccount.CountArchRegDecision__c = 1;
			}
			allSARToUpdate.addAll(serviceAccountRelationshipListscenarios42);

			for (Service_Account_Relationship__c serviceAccount : serviceAccountRelationshipListscenarios5) {
				serviceAccount.Association_Start_Date__c = associationStartDate2;
				serviceAccount.Association_End_Date__c = associationStartEndDate2;
				serviceAccount.CurrentNonCurrentRegDec__c = 1;
				serviceAccount.CountCurrentRegDec__c = 0;
				serviceAccount.CountArchRegDecision__c = 1;
			}
			allSARToUpdate.addAll(serviceAccountRelationshipListscenarios5);

			for (Service_Account_Relationship__c serviceAccount : serviceAccountRelationshipListscenarios6) {
				serviceAccount.Association_Start_Date__c = associationStartDate2;
				serviceAccount.Association_End_Date__c = associationStartEndDate2;
				serviceAccount.CurrentNonCurrentRegDec__c = 0;
				serviceAccount.CountCurrentRegDec__c = 0;
				serviceAccount.CountArchRegDecision__c = 0;
			}
			allSARToUpdate.addAll(serviceAccountRelationshipListscenarios6);

			for (Service_Account_Relationship__c serviceAccount : serviceAccountRelationshipListscenarios7) {
				serviceAccount.Association_Start_Date__c = associationStartDate1;
				serviceAccount.Association_End_Date__c = associationStartEndDate2;
				serviceAccount.CurrentNonCurrentRegDec__c = 0;
				serviceAccount.CountCurrentRegDec__c = 0;
				serviceAccount.CountArchRegDecision__c = 0;
			}
			allSARToUpdate.addAll(serviceAccountRelationshipListscenarios7);
            
            for (Service_Account_Relationship__c serviceAccount : serviceAccountRelationshipListscenarios71) {
				serviceAccount.Association_Start_Date__c = associationStartDate1;
				serviceAccount.Association_End_Date__c = associationStartEndDate2;
				serviceAccount.CurrentNonCurrentRegDec__c = 0;
				serviceAccount.CountCurrentRegDec__c = 0;
				serviceAccount.CountArchRegDecision__c = 0;
			}
			allSARToUpdate.addAll(serviceAccountRelationshipListscenarios71);

			for (Service_Account_Relationship__c serviceAccount : serviceAccountRelationshipListscenarios8) {
				serviceAccount.Association_Start_Date__c = associationStartDate1;
				serviceAccount.Association_End_Date__c = associationStartEndDate2;
				serviceAccount.CurrentNonCurrentRegDec__c = null;
				serviceAccount.CountCurrentRegDec__c = null;
				serviceAccount.CountArchRegDecision__c = 0;
			}
			allSARToUpdate.addAll(serviceAccountRelationshipListscenarios8);

			for (Service_Account_Relationship__c serviceAccount : serviceAccountRelationshipListscenarios9) {
				serviceAccount.Association_Start_Date__c = associationStartDate2;
				serviceAccount.Association_End_Date__c = associationStartEndDate2;
				serviceAccount.CurrentNonCurrentRegDec__c = null;
				serviceAccount.CountCurrentRegDec__c = null;
				serviceAccount.CountArchRegDecision__c = null;
			}
			allSARToUpdate.addAll(serviceAccountRelationshipListscenarios9);
            for (Service_Account_Relationship__c serviceAccount : serviceAccountRelationshipListscenarios91) {
				serviceAccount.Association_Start_Date__c = associationStartDate1;
				serviceAccount.Association_End_Date__c = associationStartEndDate2;
				serviceAccount.CurrentNonCurrentRegDec__c = 0;
				serviceAccount.CountCurrentRegDec__c = null;
				serviceAccount.CountArchRegDecision__c = 0;
			}
			allSARToUpdate.addAll(serviceAccountRelationshipListscenarios91);
            
            for (Service_Account_Relationship__c serviceAccount : serviceAccountRelationshipListscenarios92) {
				serviceAccount.Association_Start_Date__c = associationStartDate2;
				serviceAccount.Association_End_Date__c = associationStartEndDate2;
				serviceAccount.CurrentNonCurrentRegDec__c = 0;
				serviceAccount.CountCurrentRegDec__c = null;
				serviceAccount.CountArchRegDecision__c = 0;
			}
			allSARToUpdate.addAll(serviceAccountRelationshipListscenarios92);

			for (Service_Account_Relationship__c serviceAccount : serviceAccountRelationshipListscenarios10) {
				serviceAccount.Association_Start_Date__c = associationStartDate1;
				serviceAccount.Association_End_Date__c = associationStartEndDate2;
				serviceAccount.CurrentNonCurrentRegDec__c = null;
				serviceAccount.CountCurrentRegDec__c = null;
				serviceAccount.CountArchRegDecision__c = 0;
			}
			allSARToUpdate.addAll(serviceAccountRelationshipListscenarios10);

			update allSARToUpdate;
		}

		Test.stopTest();
	}
	@isTest
	static void unitTestSCRRatingCalculationBatch() {
		Test.startTest();
		SCRRatingCalculationBatch scrService = new SCRRatingCalculationBatch();
		Database.executeBatch(scrService);
		Test.stopTest();
        System.assertEquals(27, [select count() from Service_Compliance_History__c ]);
	}
}