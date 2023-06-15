/*******************************************************************************************
 * @Name             CreateExemptionsBatch
 * @Test class       CreateExemptionsBatchTest
 * @Author           Gabriel Piragibe Cova Leda de Almeida
 * @Date             09-11-2022
 * @Story#           280716
 * @LWC Component    None
 * @Description		 Creates system exemptions for new or transferred services
 *******************************************************************************************/
/* MODIFICATION LOG
 * Version       Developer                                Date                Description
 *-------------------------------------------------------------------------------------------
 *  1.0     		Gabriel Piragibe Cova Leda de Almeida    09-11-2022          Initial Creation
 *******************************************************************************************/
public with sharing class CreateExemptionsBatch implements Database.Batchable<sObject> {
	Boolean isGoLiveDay = StarRatingExemptionCustomMetadata.goLiveSetting;
	private String getQuery() {
		String query;
		query =
			'SELECT Id, Operational_Two_Last_Quarters__c, Status__c, Status_Date__c, CER_Exempt__c, CM_Exempt__c, QI_Exempt__c, SCR_Exempt__c, ' +
			'CER_Consent_Revoked__c FROM BusinessLicense WHERE Id IN ' +
			'(SELECT Service_Name__c ' +
			'FROM Service_Account_Relationship__c WHERE Active__c = TRUE AND Service_Name__r.Status__c = \'Operational\' ' +
			'AND Service_Name__r.Care_Type__c = \'Residential\' ' +
			'AND (Service_Name__r.Status_Date__c = LAST_N_DAYS:365 OR Association_Start_Date__c = LAST_N_DAYS:365))';

		return (query);
	}

	public Database.QueryLocator start(Database.BatchableContext bc) {
		return Database.getQueryLocator(getQuery());
	}

	public void execute(Database.BatchableContext bc, List<BusinessLicense> scope) {
		List<SRQI_Exemption__c> allExemptions = new List<SRQI_Exemption__c>();
		Map<Id, BusinessLicense> services = new Map<Id, BusinessLicense>(scope);

		/* The below deals with following scenario: new service with Accreditation st date in future.
		Exemptions will be created but the exemption flags won't be set to this service until the st date comes.
		Hence, we need to remove those services from the set after they've been processed for the first time. 
		We only process them once. This avoid duplicates.*/
		Set<Id> idsOfServicesWithFutureSystemExemptions = new Set<Id>();
		for (SRQI_Exemption__c exemp : [
			SELECT id, Service__c
			FROM SRQI_Exemption__c
			WHERE Type__c = 'System' AND Exemption_Start__c > TODAY AND Service__c IN :services.keySet()
		]) {
			idsOfServicesWithFutureSystemExemptions.add(exemp.Service__c);
		}
		if (!idsOfServicesWithFutureSystemExemptions.isEmpty()) {
			services.keySet().removeAll(idsOfServicesWithFutureSystemExemptions);
		}

		// Call ServiceOperationalChecker to check if service has been oeprational for last 2 quarters
		ServiceOperationalChecker.isOperationalForLastTwoFullQuarters(scope);

		// Initialise required maps in star rating util
		StarRatingUtil.cacheServiceAccRelationship(services.keySet());
		StarRatingUtil.cacheAccredCertification(services.keySet());
		StarRatingUtil.cacheCERData(services.keySet());

		for (BusinessLicense service : services.values()) {
			allExemptions.addAll(StarRatingUtil.createSystemExemptions(service));
		}

		if (!allExemptions.isEmpty()) {
			try {
				insert allExemptions;
			} catch (Exception ex) {
				dohagedcare.Logger.error(ex.getMessage(), ex, 'Star Rating').log();
			}
		}

		if (isGoLiveDay) {
			StarRatingUtil.updateServiceExemptionFlags(allExemptions);
		}
	}

	public void finish(Database.BatchableContext bc) {
		if (!isGoLiveDay) {
			Database.executeBatch(new StarRatingExemptionBatch());
		}
	}
}