/**
 * author: Daniel Clift
 * date: 31/08/2022
 * description: support ratings calculation handler, will create Star Rating History Records for all services if required
 * @testClass RatingsCalculationServiceTest
 **/
public with sharing class RatingsCalculationService {
	public static Reporting_Period__c rPeriod;

	public static void starRatingRecords() {
		// checks is Stars Rating records have already been created for this period
		try {
			if (checkSRRecords()) {
				// gets list of service accounts, for service Ids and Provider Ids, to be mapped to StarRating records
				List<Service_Account_Relationship__c> serviceAccountList = [
					SELECT Id, Service_Name__c, Provider_Name__c
					FROM Service_Account_Relationship__c
					WHERE
						Service_Name__r.Care_Type__c = 'Residential'
						AND Service_Name__r.Status__c IN ('Operational', 'Offline')
						AND (Association_End_Date__c = NULL
						OR Association_End_Date__c >= Today)
				];
				// gets list of Star Rating records for insert
				List<STAR_Rating_History__c> srRecords = createStarRatings(serviceAccountList);
				insert srRecords;
			}
		} catch (Exception exp) {
			dohagedcare.Logger.error(exp.getMessage(), exp, 'RatingsCalculationService').Log();
		}
	}

	public static boolean checkSRRecords() {
		Boolean createRecords = false;
		try {
			// default wont create

			// get reporting period & check if Star Rating records have been created
			rPeriod = [
				SELECT Id, STARRatingRecordsCreated__c
				FROM Reporting_Period__c
				WHERE Previous_Reporting_Period__c = TRUE AND Reporting_Period_Type__c = 'Quarter'
				LIMIT 1
			];
			// if no records, then we create, set boolean to true
			if (!rPeriod.STARRatingRecordsCreated__c) {
				rPeriod.STARRatingRecordsCreated__c = true;
				createRecords = true;
			}
			update rPeriod;
		} catch (Exception exp) {
			dohagedcare.Logger.error(exp.getMessage(), exp, 'RatingsCalculationService - checkSRRecords').Log();
		}
		return createRecords;
	}

	public static List<STAR_Rating_History__c> createStarRatings(
		List<Service_Account_Relationship__c> serviceAccountList
	) {
		// create star rating records, map service account, service and provider
		List<STAR_Rating_History__c> srCreateList = new List<STAR_Rating_History__c>();
		for (Service_Account_Relationship__c serviceAccount : serviceAccountList) {
			STAR_Rating_History__c sr = new STAR_Rating_History__c();
			sr.Service_Account_Relationship__c = serviceAccount.Id;
			sr.SF_Service_Id__c = serviceAccount.Service_Name__c;
			sr.SF_Provider_Id__c = serviceAccount.Provider_Name__c;
			sr.Reporting_Period__c = rPeriod.Id;
			sr.Rating_Type__c = 'Draft Rating';
			sr.Status__c = 'Draft';
			sr.Go_Live_Date__c = System.today().addDays((Integer) StarRatingsSettingsCustomMetadata.goLiveDate);
			SR.Publish_Date__c = System.today().addDays((Integer) StarRatingsSettingsCustomMetadata.publishDate);
			srCreateList.add(sr);
		}
		return srCreateList;
	}
}
