/*******************************************************************************************
* @Name             ServiceAcctRelationshipService
* @Test class       ServiceAcctRelationshipServiceTest
* @Author           Gabriel Piragibe Cova Leda de Almeida
* @Date             23-09-2022
* @Story#           225789 (SR-QI ART Planning Sprint 4)
* @LWC Component    None
* @Description      Service class for ServiceAcctRelationshipHandler. Method updateTransferRating
                    udpates the srh records transferred flag to true.
                    insertExemptions method inserts exemptions for a service and updates the services
                    exemption flags.
*******************************************************************************************/
/* MODIFICATION LOG
 * Version       Developer                                Date                Description
 *-------------------------------------------------------------------------------------------
 *  1.0     	 Gabriel Piragibe Cova Leda de Almeida    23-09-2022          Initial Creation
 *  1.1			 Gabriel Piragibe Cova Leda de Almeida	  05/10/2022		  Added logic for CM
 *******************************************************************************************/
public with sharing class ServiceAcctRelationshipService {
	@testvisible
	private static Boolean fakeException = false;
	public static void updateTransferRating(Map<Id, BusinessLicense> servicesMap) {
		Map<Id, STAR_Rating_History__c> allSRH = new Map<Id, STAR_Rating_History__c>(
			[
				SELECT Id
				FROM STAR_Rating_History__c
				WHERE
					SF_Service_Id__c IN :servicesMap.keySet()
					AND Reporting_Period__r.Current_Reporting_Period__c = TRUE
			]
		);

		// Set transferred flag to true
		for (STAR_Rating_History__c srhRec : allSRH.values()) {
			srhRec.Transferred__c = true;
		}

		// update records
		try {
			update allSRH.values();
			if (test.isRunningTest() && fakeException) {
				allSRH.values()[20000].Transferred__c = true;
			}
		} catch (Exception ex) {
			dohagedcare.Logger.error(ex.getMessage(), ex, 'Star Rating').log();
		}
	}
}