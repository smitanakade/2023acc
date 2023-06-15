/*******************************************************************************************
* @Name             ServiceAcctRelationshipHandler
* @Test class       ServiceAcctRelationshipHandlerTest
* @Author           Gabriel Piragibe Cova Leda de Almeida
* @Date             23-09-2022
* @Story#           225789 (SR-QI ART Planning Sprint 4)
* @LWC Component    None
* @Description      SAR records that have association end date less than current date signals
                    that we need to update the STAR Rating History record associated with service
                    and set flag 'transferred' to true.
                    Services records that have their service status operational & residential signals that we need
                    to create a system exemption with reason 'Transferred Service'
*******************************************************************************************/
/* MODIFICATION LOG
 * Version       Developer                                Date                Description
 *-------------------------------------------------------------------------------------------
 *  1.0     		Gabriel Piragibe Cova Leda de Almeida    23-09-2022          Initial Creation
 *******************************************************************************************/
public with sharing class ServiceAcctRelationshipHandler implements afterUpdate {
	@testvisible
	private static Boolean fakeException = false;

	public void afterUpdate(Map<Id, SObject> newSARMap, Map<Id, SObject> oldSARMap) {
		// Cast SObject to SAR object so we can access lookup fieds
		Map<Id, Service_Account_Relationship__c> newSARMapInput = new Map<Id, Service_Account_Relationship__c>(
			(List<Service_Account_Relationship__c>) newSARMap.values()
		);
		Set<Id> serviceIDs = new Set<Id>();

		// Collects service IDs which association has ended
		for (Service_Account_Relationship__c sarRec : newSARMapInput.values()) {
			if (sarRec.Service_Name__c != null && sarRec.Association_End_Date__c < System.today()) {
				serviceIDs.add(sarRec.Service_Name__c);
			}
		}

		// return if there is no services with end date older than today
		if (serviceIDs.size() == 0) {
			return;
		}

		// Get services
		Map<Id, BusinessLicense> servicesMap = new Map<Id, BusinessLicense>(
			[
				SELECT Id, Status__c
				FROM BusinessLicense
				WHERE Id IN :serviceIDs AND Status__c = 'Operational' AND Care_Type__c = 'Residential'
			]
		);

		// return if there is no STAR Rating History record to update
		if (servicesMap.size() == 0)
			return;

		try {
			ServiceAcctRelationshipService.updateTransferRating(servicesMap);
			if (test.isRunningTest() && fakeException) {
				servicesMap.values()[20000].QI_Exempt__c = true;
			}
		} catch (Exception ex) {
			dohagedcare.Logger.error(ex.getMessage(), ex, 'Star Rating').log();
		}
	}
}