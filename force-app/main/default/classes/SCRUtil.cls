/**
 * @author    Smita Kagde
 * @date      13/10/2022
 * @testClass SCRUtilTest
 **/
/* MODIFICATION LOG
 * Version       Developer                   Date                Description
 *-------------------------------------------------------------------------------------------------------------------------------------------------------
 *  1.0     	 Rami Zuhairi                27-04-2023          Updated the fix related to Bug - 355791
 ******************************************************************************************************************************************************** */
public with sharing class SCRUtil {
	static final String CURRENT_RATING = 'Current Rating';
	static final String NEW_RATING = 'New Rating';
	static final String DRAFT_RATING = 'Draft Rating';
	// Stores list of maps of service IDs that will need their CER rating recalculated
	public static Id cerRecalcServiceIds;

	// Stores key constant for list of service ids used in recalculation IP
	private static final String SRH_ID = 'SRHID';

	//this method gets called from RegulatoryDecisionEventTriggerHelper class
	public static String createNUpdateSCR(
		Set<Id> serviceIdSet,
		Set<Id> serviceRelationIdSet,
		List<Service_Compliance_History__c> sCHList
	) {
		List<STAR_Rating_History__c> currentSRHlist = new List<STAR_Rating_History__c>();
		List<STAR_Rating_History__c> newSRHlist = new List<STAR_Rating_History__c>();
		String response = '';
		Map<Id, List<STAR_Rating_History__c>> sarWithSRH = new Map<Id, List<STAR_Rating_History__c>>();

		for (STAR_Rating_History__c rec : getExistingSRH(serviceIdSet, serviceRelationIdSet)) {
			if (!sarWithSRH.containsKey(rec.Service_Account_Relationship__c)) {
				sarWithSRH.put(rec.Service_Account_Relationship__c, new List<STAR_Rating_History__c>{ rec });
			} else {
				sarWithSRH.get(rec.Service_Account_Relationship__c).add(rec);
			}
		}
		try {
			for (Id sarId : serviceRelationIdSet) {
				if (sarWithSRH.containsKey(sarId)) {
					List<STAR_Rating_History__c> srhList = sarWithSRH.get(sarId);
					for (STAR_Rating_History__c srh : srhList) {
						if (srh.Rating_Exemption_Granted__c == false) {
							if (srh.Rating_Type__c == NEW_RATING || srh.Rating_Type__c == DRAFT_RATING) {
								newSRHlist.add(srh);
							} else if (srh.Rating_Type__c == CURRENT_RATING) {
								currentSRHlist.add(srh);
							} else {
								continue;
							}
						} else {
							newSRHlist.add(srh);
						}
					}
				}
			}
			if (newSRHlist.size() > 0) {
				//Updating SRH record if latest Rating Type is New Rating or Draft Rating
				response = updateSRHWithSCR(newSRHlist, sCHList);
			}
			if (currentSRHlist.size() > 0) {
				//Creating SRH record if Rating Type is Current Rating
				response = createSRHWithSCR(currentSRHlist, sCHList);
			}
		} catch (DmlException exp) {
			dohagedcare.Logger.error(exp.getMessage(), exp, 'SCRUtil -createNUpdateSCR').log();
			response = 'Failed';
		}
		return response;
	}
	private static List<STAR_Rating_History__c> getExistingSRH(Set<Id> serviceIdSet, Set<Id> serviceRelationIdSet) {
		return [
			SELECT
				Id,
				Rating_Type__c,
				Rating_Exemption_Granted__c,
				SF_Service_Id__c,
				SF_Provider_Id__c,
				Service_Account_Relationship__c,
				Care_Minutes_Id__c,
				Consumer_Experience_Id__c,
				Quality_Indicator_Id__c,
				Status__c,
				Service_Compliance_Id__c,
				Publication_Date__c,
				Rating_Calc_Date__c
			FROM STAR_Rating_History__c
			WHERE
				Service_Account_Relationship__c IN :serviceRelationIdSet
				AND SF_Service_Id__c IN :serviceIdSet
				AND Status__c != 'Removed'
			ORDER BY CreatedDate DESC
		];
	}

	private static Map<Id, Id> getServiceToSchMap(List<Service_Compliance_History__c> sCHList) {
		Map<Id, Id> schMap = new Map<Id, Id>();
		for (Service_Compliance_History__c chId : sCHList) {
			schMap.put(chId.Service__c, chId.Id);
		}
		return schMap;
	}
	private static String createSRHWithSCR(
		List<STAR_Rating_History__c> currentSRH,
		List<Service_Compliance_History__c> sCHList
	) {
		Map<Id, Id> schMap1 = getServiceToSchMap(sCHList);
		String response = '';
		List<STAR_Rating_History__c> sRHList = new List<STAR_Rating_History__c>();
		for (STAR_Rating_History__c csrh : currentSRH) {
			STAR_Rating_History__c srh = new STAR_Rating_History__c();
			srh.Care_Minutes_Id__c = csrh.Care_Minutes_Id__c;
			srh.Consumer_Experience_Id__c = csrh.Consumer_Experience_Id__c;
			srh.Quality_Indicator_Id__c = csrh.Quality_Indicator_Id__c;
			srh.Status__c = 'Draft';
			srh.Rating_Type__c = 'Draft Rating';
			srh.Reporting_Period__c = ReportingPeriodUtil.previousQuarterReportingPeriod?.Id;
			srh.Service_Compliance_Id__c = schMap1.get(csrh.SF_Service_Id__c);
			srh.SF_Service_Id__c = csrh.SF_Service_Id__c;
			srh.SF_Provider_Id__c = csrh.SF_Provider_Id__c;
			srh.Service_Account_Relationship__c = csrh.Service_Account_Relationship__c;
			srh.Go_Live_Date__c = System.today();
			sRHList.add(srh);

			csrh.Rating_Type__c = 'Previous Rating';
		}
		try {
			if (StarRatingExemptionCustomMetadata.goLiveSetting == false) {
				insert sRHList;
				update currentSRH;
				if (SRHList.size() > 0) {
					for (STAR_Rating_History__c srh : SRHList) {
						cerRecalcServiceIds = srh.Id;
						recalculateSRH();
					}
				}
			}

			response = 'Successful';
		} catch (DmlException exp) {
			dohagedcare.Logger.error(exp.getMessage(), exp, 'SCRUtil -createSRHWithSCR').log();
			response = 'Failed';
		}
		return response;
	}
	private static String updateSRHWithSCR(
		List<STAR_Rating_History__c> newSRH,
		List<Service_Compliance_History__c> sCHList
	) {
		String response = '';
		Map<Id, Id> schMap1 = getServiceToSchMap(sCHList);
		List<STAR_Rating_History__c> updSRHList = new List<STAR_Rating_History__c>();
		for (STAR_Rating_History__c srh : newSRH) {
			srh.Service_Compliance_Id__c = schMap1.get(srh.SF_Service_Id__c);
			srh.Rating_Calc_Date__c = System.today();
			updSRHList.add(srh);
		}
		try {
			if (StarRatingExemptionCustomMetadata.goLiveSetting == false) {
				update updSRHList;
				if (updSRHList.size() > 0) {
					for (STAR_Rating_History__c srh : updSRHList) {
						cerRecalcServiceIds = srh.Id;
						recalculateSRH();
					}
				}
			}

			response = 'Successful';
		} catch (DmlException exp) {
			dohagedcare.Logger.error(exp.getMessage(), exp, 'SCRUtil -updateSRHWithSCR').log();
			response = 'Failed';
		}
		return response;
	}

	// Recalculate rating for CER subdomain
	private static void recalculateSRH() {
		String procedureName = 'SRQI_StarRatingCalculation';
		Map<String, Object> ipOutput;
		Map<String, Id> ipInput = new Map<String, Id>();
		Map<String, Object> ipOptions = new Map<String, Object>();
		ipInput.put(SRH_ID, cerRecalcServiceIds);
		ipOutput = (Map<String, Object>) omnistudio.IntegrationProcedureService.runIntegrationService(
			procedureName,
			ipInput,
			ipOptions
		);
	}
}
