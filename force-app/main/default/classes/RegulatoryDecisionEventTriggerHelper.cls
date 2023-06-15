/**
 * author: Matthew Wall
 * date: 1/5/2023
 * description: Regulatory Decision helper: when criteria met creates SCH, SCD and SR records
 * @testClass RegulatoryDecisionTriggerTest
 **/
public with sharing class RegulatoryDecisionEventTriggerHelper {
	// Constants for Rating_Type__c
	static final String PREVIOUS_RATING = 'Previous Rating';
	static final String NEW_RATING = 'New Rating';
	// Contants for Availability_Status__c
	static final String REMOVED_STATUS = 'Removed';

	// Constants for Regulatory_Decision_Event__e
	static final String INACTIVE_STATUS = 'Inactive';
	static final String NEW_STATUS = 'New';
	static final String CURRENT_STATUS = 'Current';
	static final String NON_CURRENT_STATUS = 'Non-Current';
	// create a new compliance history
	static List<Service_Compliance_History__c> newComplianceHistory = new List<Service_Compliance_History__c>();
	// create new detail
	static List<Service_Compliance_Detail__c> newComplianceDetails = new List<Service_Compliance_Detail__c>();
	static Map<Id, Service_Compliance_History__c> serviceToNewHistory = new Map<Id, Service_Compliance_History__c>();
	static Map<Id, List<Service_Compliance_History__c>> serviceIdToOldServiceHistory = new Map<Id, List<Service_Compliance_History__c>>();
	static Boolean oldhistoryIsUpdated;
	static Set<Id> serviceIdSet;
	static Set<Id> serviceAccountIds;
	static Set<Id> activeSARSet;

	static Map<Id, List<RegulatoryCodeViolation>> servAccIdWitRegMap = new Map<Id, List<RegulatoryCodeViolation>>();
	static Set<Id> servAccIdWithOnlyNonCurrentRegSet = new Set<Id>();
	static Set<Id> servIdWithOnlyNonCurrentRegsSet = new Set<Id>();
	private static Set<Id> regDecWithSCHCreated = new Set<Id>();

	// new process method
	public static void process(
		List<Generic_Event__e> events,
		Map<Id, String> changedFieldMap
	) {
		List<Id> recordIdList = new List<Id>();
		Set<Id> regDecisionIds = new Set<Id>();
		serviceIdSet = new Set<Id>();
		Set<Id> serviceAccountIds = new Set<Id>();

		for (Generic_Event__e regDecEvent : events) {
			// collect record Ids
			recordIdList.add(regDecEvent.recordIds__c);
		}

		for (RegulatoryCodeViolation rd : [
			SELECT
				Id,
				Name,
				Status,
				Published__c,
				SCR_Rating__c,
				Rating_Relevant__c,
				Service_Compliance_Rating__c,
				Archived_Regulatory_Decision__c,
				Service_Name_lookup__c,
				Service_Account_Relationship__c,
				Service_Provider_Name_lookup__c,
				Service_Compliance_Rating_Effect__c
			FROM RegulatoryCodeViolation
			WHERE Id IN :recordIdList
			WITH SECURITY_ENFORCED
		]) {
			if (
				(statusChanged(changedFieldMap.get(rd.Id)) ||
				publishChanged(changedFieldMap.get(rd.Id))) &&
				((rd.published__c == true && rd.Status == CURRENT_STATUS) ||
				(rd.Rating_Relevant__c == true ||
				rd.Archived_Regulatory_Decision__c == true) &&
				rd.Status == NON_CURRENT_STATUS) ||
				(rd.Status == REMOVED_STATUS)
			) {
				regDecisionIds.add(rd.Id);
				serviceIdSet.add(rd.Service_Name_lookup__c);
				serviceAccountIds.add(rd.Service_Account_Relationship__c);
			}
		}

		List<Service_Account_Relationship__c> filteredList = [
			SELECT Id, Active__c
			FROM Service_Account_Relationship__c
			WHERE Active__c = TRUE AND Id IN :serviceAccountIds AND Care_Type__c = 'Residential'
			WITH SECURITY_ENFORCED
		];
		activeSARSet = new Set<Id>();
		for (Service_Account_Relationship__c sar : filteredList) {
			activeSARSet.add(sar.Id);
		}

		if (activeSARSet.size() > 0) {
			Map<Id, RegulatoryCodeViolation> regDecMap = getRegulatoryDecisionMap(
				regDecisionIds,
				activeSARSet
			);

			getServiceComplianceHistoryList(activeSARSet);
			// Added as part of PBI 307431
			StarRatingUtil.cacheAccredCertification(serviceIdSet);
			StarRatingUtil.cacheServiceAccRelationship(serviceIdSet);

			if (regDecisionIds.size() > 0) {
				processServiceComplianceHistory(regDecMap, regDecisionIds);
				// Create detail for each RegDec
				processServiceComplianceDetail(regDecMap);
			}

			// Set Regulatory Decision counts
			if (activeSARSet.size() > 0 && regDecMap.size() > 0) {
				RegulatoryDecisionUtility.setRegDecCount(
					activeSARSet,
					regDecMap
				);
				RegulatoryDecisionUtility.updateNonCurrentCount(
					activeSARSet,
					regDecMap
				);
			}
		}
	}

	public static Boolean publishChanged(String changeFieldString) {
		return changeFieldString.Contains('Published__c');
	}

	public static Boolean statusChanged(String changeFieldString) {
		return changeFieldString.Contains('Status');
	}

	static void processServiceComplianceHistory(
		Map<Id, RegulatoryCodeViolation> regDecMap,
		Set<Id> regDecisionIds
	) {
		oldhistoryIsUpdated = false;
		for (RegulatoryCodeViolation rcv : regDecMap.values()) {
			// check if new regDec (in list from event)
			if (regDecisionIds.contains(rcv.Id)) {
				createComplianceHistory(rcv);
				// Check if previous history exists and set inactive if not already
				updatePreviousHistory(rcv);
			}
		}

		if (Schema.sObjectType.Service_Compliance_History__c.isCreateable()) {
			try {
				insert newComplianceHistory;
			} catch (Exception ex) {
				dohagedcare.Logger.error(ex.getMessage(), ex, 'Star Rating')
					.log();
			}
		}

		//clone the current set
		Set<Id> filteredServiceAccountIds = activeSARSet.clone();
		Set<Id> filteredServiceIdSet = serviceIdSet.clone();

		//filter out only noncurrent/archived
		if (servAccIdWithOnlyNonCurrentRegSet.size() > 0) {
			filteredServiceAccountIds.removeAll(
				servAccIdWithOnlyNonCurrentRegSet
			);
			filteredServiceIdSet.removeAll(servIdWithOnlyNonCurrentRegsSet);
		}

		// Create or update SRH based on SCR
		SCRUtil.createNUpdateSCR(
			filteredServiceIdSet,
			filteredServiceAccountIds,
			newComplianceHistory
		);
		// update old history
		if (
			Schema.sObjectType.Service_Compliance_History__c.isUpdateable() &&
			oldhistoryIsUpdated == true
		) {
			try {
				update flattenServiceHistoryMap(serviceIdToOldServiceHistory);
			} catch (Exception ex) {
				dohagedcare.Logger.error(ex.getMessage(), ex, 'Star Rating')
					.log();
			}
		}
	}

	static void processServiceComplianceDetail(
		Map<Id, RegulatoryCodeViolation> regDecMap
	) {
		// Create detail for each RegDec
		for (RegulatoryCodeViolation regDec : regDecMap.values()) {
			if (
				(regDec.Status == CURRENT_STATUS ||
				(regDec.Status == NON_CURRENT_STATUS &&
				regDec.Rating_Relevant__c == true) ||
				servAccIdWithOnlyNonCurrentRegSet.contains(
					regDec.Service_Account_Relationship__c
				)) && regDec.Published__c == true
			) {
				Service_Compliance_Detail__c scd = new Service_Compliance_Detail__c(
					Regulatory_Decision__c = regDec.Id,
					Regulatory_Decision_Status__c = regDec.status,
					Service_Compliance_History__c = serviceToNewHistory.get(
							regDec.Service_Name_lookup__c
						)
						.Id
				);
				newComplianceDetails.add(scd);
			}
		}

		if (Schema.sObjectType.Service_Compliance_Detail__c.isCreateable()) {
			insert newComplianceDetails;
		}
	}

	/* Helper methods */

	static void createComplianceHistory(RegulatoryCodeViolation rcv) {
		Service_Compliance_History__c sch = new Service_Compliance_History__c();

		sch.Service__c = rcv.Service_Name_lookup__c;
		sch.Provider__c = rcv.Service_Provider_Name_lookup__c;
		sch.Regulatory_Decision__c = rcv.Id;
		sch.Rating_Calc_Date__c = datetime.now();
		sch.Publication_Date__c = datetime.now();
		sch.Rating_Type__c = 'Current Rating';
		sch.Availability_Status__c = 'LIVE';
		sch.Service_Account__c = rcv.Service_Account_Relationship__c;

		Date dateOlderThan1Year = Date.today() - 365;
		Integer leastRating = getLeastStarRating(
			servAccIdWitRegMap.get(rcv.Service_Account_Relationship__c)
		);
		if (leastRating == 1 || leastRating == 2) {
			sch.Service_Compliance_Rating__c = leastRating;
		} else if (
			servAccIdWithOnlyNonCurrentRegSet.contains(
				rcv.Service_Account_Relationship__c
			) &&
			StarRatingUtil.getServAccredCertStarDate(
				rcv.Service_Name_lookup__c
			) > dateOlderThan1Year
		) {
			// New service
			sch.Service_Compliance_Rating__c = null;
			sch.Rating_Exemption_Reason__c = 'New Service';
		} else if (
			servAccIdWithOnlyNonCurrentRegSet.contains(
				rcv.Service_Account_Relationship__c
			) &&
			StarRatingUtil.getServAccRelStartDate(rcv.Service_Name_lookup__c) >
			dateOlderThan1Year
		) {
			// Transferred service
			sch.Service_Compliance_Rating__c = null;
			sch.Rating_Exemption_Reason__c = 'Transferred Service';
		} else {
			// Get least rating if current exists. Otherwise, return 3
			sch.Service_Compliance_Rating__c = leastRating;
		}

		newComplianceHistory.add(sch);
		serviceToNewHistory.put(sch.Service__c, sch);
	}

	static void updatePreviousHistory(RegulatoryCodeViolation rcv) {
		if (
			serviceIdToOldServiceHistory.containsKey(rcv.Service_Name_lookup__c)
		) {
			for (
				Service_Compliance_History__c oldHistory : serviceIdToOldServiceHistory.get(
					rcv.Service_Name_lookup__c
				)
			) {
				if (oldHistory.Rating_Type__c != PREVIOUS_RATING) {
					oldHistory.Rating_Type__c = PREVIOUS_RATING;
					oldhistoryIsUpdated = true;
				}
			}
		}
	}

	public static Integer getLeastStarRating(
		List<RegulatoryCodeViolation> regList
	) {
		Integer least = 3;

		for (RegulatoryCodeViolation rcv : regList) {
			if (
				rcv.Status == CURRENT_STATUS &&
				rcv.Service_Compliance_Rating__c != null &&
				rcv.Service_Compliance_Rating__c != 0 &&
				rcv.Service_Compliance_Rating__c < least
			) {
				least = (Integer) rcv.Service_Compliance_Rating__c;
			}
		}

		return least;
	}

	// Takes Map of Id to List, breaks down values into a single list
	static List<Service_Compliance_History__c> flattenServiceHistoryMap(
		Map<Id, List<Service_Compliance_History__c>> historyMap
	) {
		List<Service_Compliance_History__c> updateList = new List<Service_Compliance_History__c>();
		for (
			List<Service_Compliance_History__c> collection : historyMap.values()
		) {
			updateList.addAll(collection);
		}
		return updateList;
	}

	// Return Map of RegDec Id to RegDec
	static Map<Id, RegulatoryCodeViolation> getRegulatoryDecisionMap(
		Set<Id> regDecisionIds,
		Set<Id> serviceAccountIds
	) {
		// new
		Map<Id, RegulatoryCodeViolation> regDecMap = new Map<Id, RegulatoryCodeViolation>(
			[
				SELECT
					Id,
					Name,
					Status,
					Service_Name_lookup__c,
					Service_Provider_Name_lookup__c,
					Published__c,
					SCR_Rating__c,
					Rating_Relevant__c,
					Service_Compliance_Rating__c,
					Archived_Regulatory_Decision__c,
					Service_Account_Relationship__c,
					Service_Compliance_Rating_Effect__c
				FROM RegulatoryCodeViolation
				WHERE
					Id IN :regDecisionIds
					OR (Service_Account_Relationship__c IN :serviceAccountIds
					AND ((Status = 'Current'
					AND Published__c = TRUE)
					OR Status = 'Non-Current'))
			]
		);

		setServiceRegMaps(regDecMap);
		return regDecMap;
	}
	private static void setServiceRegMaps(
		Map<Id, RegulatoryCodeViolation> regDecMap
	) {
		for (RegulatoryCodeViolation rd : regDecMap.values()) {
			if (
				!servAccIdWitRegMap.containsKey(
					rd.Service_Account_Relationship__c
				)
			) {
				servAccIdWitRegMap.put(
					rd.Service_Account_Relationship__c,
					new List<RegulatoryCodeViolation>()
				);
			}
			servAccIdWitRegMap.get(rd.Service_Account_Relationship__c).add(rd);
		}

		Boolean hasCurrent = false;
		for (Id servAccId : servAccIdWitRegMap.keySet()) {
			hasCurrent = false;
			for (
				RegulatoryCodeViolation rd : servAccIdWitRegMap.get(servAccId)
			) {
				if (rd.Status == CURRENT_STATUS) {
					hasCurrent = true;
					break;
				}
			}
			if (!hasCurrent) {
				servAccIdWithOnlyNonCurrentRegSet.add(servAccId);
				servIdWithOnlyNonCurrentRegsSet.add(
					servAccIdWitRegMap.get(servAccId)[0].Service_Name_lookup__c
				);
			}
		}
	}

	private static void getServiceComplianceHistoryList(
		Set<Id> serviceAccountIds
	) {
		// new
		List<Service_Compliance_History__c> schList = [
			SELECT
				Id,
				Name,
				Service__c,
				Provider__c,
				Regulatory_Decision__c,
				Rating_Type__c,
				Service_Account__c
			FROM Service_Compliance_History__c
			WHERE Service_Account__c IN :serviceAccountIds
			WITH SECURITY_ENFORCED
		];

		for (Service_Compliance_History__c history : schList) {
			if (history.Regulatory_Decision__c != null) {
				regDecWithSCHCreated.add(history.Regulatory_Decision__c);
			}
			if (serviceIdToOldServiceHistory.containsKey(history.Service__c)) {
				serviceIdToOldServiceHistory.get(history.Service__c)
					.add(history);
			} else {
				List<Service_Compliance_History__c> historyList = new List<Service_Compliance_History__c>();
				historyList.add(history);
				serviceIdToOldServiceHistory.put(
					history.Service__c,
					historyList
				);
			}
		}
	}
}
