/**
 * Author: Rami Zuhairi
 * Date: 26/10/2022
 * Description: to calculate SCR rating for current and active ratings
 * Related PBIs 207940  274594, 238026
 * PBI - 274594 has all related conditions mentioned in the comments.
 **/
public with sharing class SCRRatingCalculationBatch implements Database.Batchable<SObject> {

	public static String currentRating = 'Current Rating';
	public static String previousRating = 'Previous Rating';
    private static Set<Id> sarsWithCurrent = new Set<Id>();
    private static Set<Id> sarsWithNonCurrentEnd1to3Yr = new Set<Id>();
    private static Set<Id> sarsWithNonCurrentEndWithin1Yr = new Set<Id>();
	//Grap all required fields from BusinessLicense
	public Database.QueryLocator start(Database.BatchableContext bc) {
		return Database.getQueryLocator(getQuery());
	}
	public void execute(Database.BatchableContext bc, List<BusinessLicense> scope) {
		try {
			
			Date currentDate = Date.today();
			Date dateOlderThan3Years = currentDate - (3 * 365); // 3 years older
			Date dateOlderThan1Year = currentDate - 365; // 1 year older
			Integer countSCHrecords = 0; // to check num of SCH records for each service
			List<BusinessLicense> serviceRecordsList = new List<BusinessLicense>();
			List<Service_Compliance_History__c> complianceHistoryListToInsert = new List<Service_Compliance_History__c>();
			List<Service_Compliance_History__c> complianceHistoryListToUpdate = new List<Service_Compliance_History__c>();

			serviceRecordsList = [
				SELECT
					Id,
					Status__c,
					Name,
					(
						SELECT
							Id,
							Association_Start_Date__c,
							CountArchRegDecision__c,
							CountCurrentRegDec__c,
							CurrentNonCurrentRegDec__c,
							Active__c,
							Provider_Name__c
						FROM Service_Account_Relationships__r
						WHERE Active__c = TRUE
					),
					(
						SELECT
							Service__c,
							Rating_Type__c,
							Service_Compliance_Rating__c,
							Rating_Exemption_Reason__c,
							Rating_Exemption_Granted__c
						FROM Service_Compliance_History__r
						WHERE Rating_Type__c = :currentRating
					)
				FROM BusinessLicense
				WHERE Id IN :scope
			];

			//Create set of BL Ids to cache it in StarRatingUtil.cacheAccredCertification
			Map<Id, BusinessLicense> services = new Map<Id, BusinessLicense>(serviceRecordsList);
			StarRatingUtil.cacheAccredCertification(services.keySet());
			setRegCounts(serviceRecordsList);
            Set<Id> serviceIdSet = new Set<Id>();
    		Set<Id> serviceAccountIds = new Set<Id>();

			for (BusinessLicense service : serviceRecordsList) {
				// Count number of SCH records for each service
				countSCHrecords = service.Service_Compliance_History__r.size();
				if (service.Service_Account_Relationships__r.isEmpty()) {
					continue;
				}

				Boolean setPrevious = false;

				// Outter if condition checks for new rating to be set. Inner if condition avoids duplicates as this batch runs every day.
				Service_Account_Relationship__c sar = service.Service_Account_Relationships__r[0];
				if ((sar.Association_Start_Date__c < dateOlderThan3Years) &&
					(StarRatingUtil.getServAccredCertStarDate(service.Id) < dateOlderThan3Years) &&
					(StarRatingUtil.getAccreditationDuration(service.Id) >= 1095) &&
					!sarsWithCurrent.contains(sar.Id) &&
					!sarsWithNonCurrentEnd1to3Yr.contains(sar.Id) &&
					!sarsWithNonCurrentEndWithin1Yr.contains(sar.Id)){
					if(countSCHrecords == 0 || service.Service_Compliance_History__r[0].Service_Compliance_Rating__c != 5){
						complianceHistoryListToInsert.add(createNewSch(service.Id, sar, 5,  null));
						setPrevious = true;
					}
				}
				else if ((sar.Association_Start_Date__c <= dateOlderThan1Year) &&
						(StarRatingUtil.getServAccredCertStarDate(service.Id) <= dateOlderThan1Year) &&
						!sarsWithCurrent.contains(sar.Id) &&
						!sarsWithNonCurrentEndWithin1Yr.contains(sar.Id)){
						if (countSCHrecords == 0 || service.Service_Compliance_History__r[0].Service_Compliance_Rating__c != 4) {
							complianceHistoryListToInsert.add(createNewSch(service.Id, sar, 4,  null));
							setPrevious = true;
						}
				}
				else if ((sar.Association_Start_Date__c <= dateOlderThan1Year) &&
						(StarRatingUtil.getServAccredCertStarDate(service.Id) <= dateOlderThan1Year) &&
						!sarsWithCurrent.contains(sar.Id)){
						if (countSCHrecords == 0 || service.Service_Compliance_History__r[0].Service_Compliance_Rating__c != 3) {
							complianceHistoryListToInsert.add(createNewSch(service.Id, sar, 3,  null));
							setPrevious = true;
						}
				}
				else if ((StarRatingUtil.getServAccredCertStarDate(service.Id) > dateOlderThan1Year) &&
						!sarsWithCurrent.contains(sar.Id)){
						if (countSCHrecords == 0 || (service.Service_Compliance_History__r[0].Service_Compliance_Rating__c != null &&
						service.Service_Compliance_History__r[0].Rating_Exemption_Reason__c != 'New Service')) {
							complianceHistoryListToInsert.add(createNewSch(service.Id, sar, null, 'New Service'));
							setPrevious = true;
						}
				}
				else if ((sar.Association_Start_Date__c > dateOlderThan1Year) &&
						!sarsWithCurrent.contains(sar.Id)){
						if (countSCHrecords == 0 || (service.Service_Compliance_History__r[0].Service_Compliance_Rating__c != null &&
						service.Service_Compliance_History__r[0].Rating_Exemption_Reason__c != 'Transferred Service')) {
							complianceHistoryListToInsert.add(createNewSch(service.Id, sar, null, 'Transferred Service'));
							setPrevious = true;
						}
				}
				else{
					setPrevious = false;
				}

				if(setPrevious){
					serviceIdSet.add(service.Id);
					serviceAccountIds.add(sar.Id);
					for (Service_Compliance_History__c schRec : service.Service_Compliance_History__r) {
						schRec.Rating_Type__c = previousRating;
						complianceHistoryListToUpdate.add(schRec);
					}
				}
			}

			//insert compliance History List
			Database.insert(complianceHistoryListToInsert, false);
			Database.update(complianceHistoryListToUpdate, false);

			// calls SSCRUtil.CurrentSRH to creat Star rating history each time SCH record created ---------
			SCRUtil.createNUpdateSCR( serviceIdSet, serviceAccountIds, complianceHistoryListToInsert );
		} catch (DmlException exp) {
			dohagedcare.Logger.error(exp.getMessage(), exp, 'QISR- SCRRatingCalculationBatch').Log();
		}
	}

	private static Service_Compliance_History__c createNewSch(
		String serviceId,
		Service_Account_Relationship__c sar,
		Integer rating,
		String exemptionRating	) {
		return new Service_Compliance_History__c(
			Service__c = serviceId,
			Provider__c = sar.Provider_Name__c,
			Service_Account__c = sar.Id,
			Rating_Calc_Date__c = datetime.now(),
        	Publication_Date__c = datetime.now(),
			Service_Compliance_Rating__c = rating,
			Rating_Type__c = currentRating,
			Availability_Status__c = 'LIVE',
			Rating_Exemption_Reason__c = exemptionRating,
			Rating_Exemption_Granted__c = (exemptionRating != null)
		);
	}
	private static void setRegCounts(List<BusinessLicense> serviceRecordsList){
		Map<Id,Service_Account_Relationship__c> sarMap = new Map<Id,Service_Account_Relationship__c>();
		for (BusinessLicense service : serviceRecordsList) {
			if (!service.Service_Account_Relationships__r.isEmpty()) {
				sarMap.put( service.Service_Account_Relationships__r[0].Id, service.Service_Account_Relationships__r[0]);
			}
		}
		
		for(RegulatoryCodeViolation regDec : [SELECT Id, Status, Date_Decision_Ends__c, Date_Decision_Applied__c, Service_Account_Relationship__c,
												Service_Account_Relationship__r.Association_Start_Date__c
												FROM RegulatoryCodeViolation 
												WHERE Service_Account_Relationship__c IN: sarMap.keySet() 
												AND ((Status = 'Current' AND Published__c = true) OR Status = 'Non-Current') 
												AND Service_Compliance_Rating__c != null AND Service_Compliance_Rating__c != 0]){
			if(regDec.Date_Decision_Applied__c >= regDec.Service_Account_Relationship__r.Association_Start_Date__c &&
				regDec.Status == 'Current'){
					sarsWithCurrent.add(regDec.Service_Account_Relationship__c);
			}
			else if(regDec.Date_Decision_Applied__c >= regDec.Service_Account_Relationship__r.Association_Start_Date__c &&
				regDec.Status == 'Non-Current' && regDec.Date_Decision_Ends__c != null && regDec.Date_Decision_Ends__c >= (Date.today().addDays(-1095)) &&
				regDec.Date_Decision_Ends__c < (Date.today().addDays(-365))){
					sarsWithNonCurrentEnd1to3Yr.add(regDec.Service_Account_Relationship__c);
			}
			else if(regDec.Date_Decision_Applied__c >= regDec.Service_Account_Relationship__r.Association_Start_Date__c &&
				regDec.Status == 'Non-Current' && regDec.Date_Decision_Ends__c != null && regDec.Date_Decision_Ends__c >= (Date.today().addDays(-365))){
					sarsWithNonCurrentEndWithin1Yr.add(regDec.Service_Account_Relationship__c);
			}
			else {
				continue;
			}
		}
	}

	public virtual String getQuery() {
		String retQuery = '';
		retQuery =
			retQuery +
			'SELECT Id FROM BusinessLicense WHERE Status__c IN (\'Operational\', \'Offline\')  AND Care_Type__c = \'Residential\' ';
		return (retQuery);
	}

	public void finish(Database.BatchableContext bc) {
		System.debug('Batch Job Completed!');
	}
}