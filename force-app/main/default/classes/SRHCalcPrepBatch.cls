/**
 * author: Daniel Clift
 * date: 30/09/2022
 * description: Prepares all star rating history records for calculation by linking subratings & creating and missing subrating records
 * date :25/10/2022 Modified by Sanjeev Bajpai -Added exception handeling
 * @testClass SRHCaclPrepBatchTest
 **/
public with sharing class SRHCalcPrepBatch implements Database.Batchable<sObject> {
	public Database.QueryLocator start(Database.BatchableContext bc) {
		return Database.getQueryLocator(getQuery());
	}

	public void execute(Database.BatchableContext bc, List<STAR_Rating_History__c> scope) {
		try {
			Map<String, Map<String, Object>> serviceMap = SRHCalcPrepHelper.mapSubRatings(scope);
			
			// get services and exemptions
			Map<Id, BusinessLicense> sericeExemptions = new Map<Id, BusinessLicense>(
				[
					SELECT
						Id,
						CER_Exempt__c,
						CM_Exempt__c,
						QI_Exempt__c,
						CER_Consent_Revoked__c,
						Operational_Two_Last_Quarters__c,
						Status__c,
						Status_Date__c,
						(
							SELECT RecordTypeId, RecordType.Name, Active__c, Reason__c
							FROM Service__r
							WHERE Active__c = TRUE
						)
					FROM BusinessLicense
					WHERE Id IN :serviceMap.keySet()
				]
			);

			List<STAR_Rating_History__c> srhUpdate = SRHCalcPrepHelper.linkToSRH(serviceMap, sericeExemptions);
			
			if (!srhUpdate.isEmpty()) {
				update srhUpdate;
				SRHRatingsLinkHelper.updateSubDomains();
			}
		} catch (Exception exp) {
			dohagedcare.Logger.error(exp.getMessage(), exp, 'SRHCalcPrepBatch').Log();
		}
	}

	public virtual String getQuery() {
		String query = 'SELECT Id, SF_Service_Id__c, SF_Provider_Id__c, Service_Account_Relationship__c, Rating_Type__c, Reporting_Period__c, Status__c, ';
		query = query + 'SF_Provider_Id__r.Oracle_ID__c, SF_Service_Id__r.Oracle_Service_ID__c ';
		query =
			query +
			'FROM STAR_Rating_History__c WHERE Rating_Type__c = \'Draft Rating\' AND Status__c = \'Draft\' AND ';
		query =
			query +
			'Reporting_Period__r.StarRating_Calc_Date__c = TODAY AND Reporting_Period__r.Previous_Reporting_Period__c = true';

		return query;
	}

	public void finish(Database.BatchableContext bc) {
		// runs Star rating IP
		IntegrationProcedureHandler ipHandler = new IntegrationProcedureHandler(IntegrationProcedureHandler.RUNSRH);
		ipHandler.executeIp();
	}
}