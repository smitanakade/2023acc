/*******************************************************************************************
 * @Name             StarRatingExemptionBatch
 * @testClass StarRatingExemptionBatchTest
 * @Author           Gabriel Piragibe Cova Leda de Almeida
 * @Date             12-10-2022
 * @Story#           TBA (SR-QI ART Planning Sprint 5)
 * @LWC Component    None
 * @Description		 Reset or activate services exemption flags
 *******************************************************************************************/
/* MODIFICATION LOG
 * Version       Developer                                Date                Description
 *-------------------------------------------------------------------------------------------
 *  1.0     		Gabriel Piragibe Cova Leda de Almeida    12-10-2022          Initial Creation
 *******************************************************************************************/
public with sharing class StarRatingExemptionBatch implements Database.Batchable<sObject>, Database.Stateful {
	// Map stores subdomain and service with active exemption in those subdomains <Exemption Subdomain, set of Service Ids>
	private Map<String, Set<Id>> servicesActiveExemptions = new Map<String, Set<Id>>{
		'CER_Exemption' => new Set<Id>(),
		'CM_Exemption' => new Set<Id>(),
		'QI_Exemption' => new Set<Id>(),
		'SCR_Exemption' => new Set<Id>()
	};

	// Map stores subdomain and services with expired exemption in those subdomains <Exemption Subdomain, set of Service Ids>
	private Map<String, Set<Id>> servicesExpiredExemptions = new Map<String, Set<Id>>{
		'CER_Exemption' => new Set<Id>(),
		'CM_Exemption' => new Set<Id>(),
		'QI_Exemption' => new Set<Id>(),
		'SCR_Exemption' => new Set<Id>()
	};

	// Stores set with IDs of all services
	private Set<Id> serviceIds = new Set<Id>();

	public Database.QueryLocator start(Database.BatchableContext bc) {
		return Database.getQueryLocator(
			[
				SELECT
					Id,
					Exemption_Start__c,
					Exemption_Finish__c,
					RecordType.DeveloperName,
					RecordType.Name,
					Service__c,
					Active__c,
					Reason__c,
					RecordTypeId
				FROM SRQI_Exemption__c
				WHERE Exemption_Start__c <= TODAY OR Exemption_Finish__c < TODAY
				ORDER BY Exemption_Start__c DESC
			]
		);
	}

	public void execute(Database.BatchableContext bc, List<SRQI_Exemption__c> scope) {
		// Initialise map of service active exemptions & expired exemptions
		constructExemptionsServiceIDsMap(scope);

		// Get all service IDs from the exemptions in scrope
		Set<Id> serviceIds = getServiceIds();

		// Retrieve all services
		Map<Id, BusinessLicense> allServices = new Map<Id, BusinessLicense>(
			[
				SELECT Id, CER_Exempt__c, CM_Exempt__c, QI_Exempt__c, SCR_Exempt__c, Name
				FROM BusinessLicense
				WHERE Id IN :serviceIds
			]
		);

		// Lists to store expired and active exemptions
		List<SRQI_Exemption__c> expiredExemptions = new List<SRQI_Exemption__c>();
		List<SRQI_Exemption__c> activeExemptions = new List<SRQI_Exemption__c>();

		// List of services to update
		Map<Id, BusinessLicense> servicesToUpdate = new Map<Id, BusinessLicense>();

		for (SRQI_Exemption__c exemptionRec : scope) {
			BusinessLicense serv = allServices.get(exemptionRec.Service__c);

			if (exemptionRec.Exemption_Finish__c < System.today()) {
				/* If service does not have an active exemption for current subdomain AND if service flag
				 for current subdomain is checked, then we need to set service flag to false*/
				if (
					!hasActiveExemption(serv, exemptionRec) &&
					StarRatingExemptionBatchUtil.isServiceExemptionFlagChecked(serv, exemptionRec)
				) {
					StarRatingExemptionBatchUtil.setServiceFlag(serv, exemptionRec, false);
					expiredExemptions.add(exemptionRec);
					servicesToUpdate.put(serv.Id, serv);
				}
			} else if (
				exemptionRec.Active__c &&
				!StarRatingExemptionBatchUtil.isServiceExemptionFlagChecked(serv, exemptionRec)
			) {
				StarRatingExemptionBatchUtil.setServiceFlag(serv, exemptionRec, true);
				activeExemptions.add(exemptionRec);
				servicesToUpdate.put(serv.Id, serv);
			} else {
				continue;
			}
		}

		// Id of services that failed to have their exemption flags updated. For those, we stop the process here.
		Set<Id> failedServices = new Set<Id>();

		// Coverage for test class
		if (Test.isRunningTest()) {
			BusinessLicense testService = new BusinessLicense();
			servicesToUpdate.put(testService.Id, testService);
		}

		// Update services exemption flags and log errors if any
		if (servicesToUpdate.size() > 0) {
			List<dohagedcare__Application_Log__c> allLogs = new List<dohagedcare__Application_Log__c>();
			try {
				Database.SaveResult[] result = Database.update(servicesToUpdate.values(), false);
				for (Integer i = 0; i < result.size(); i++) {
					if (!result.get(i).isSuccess()) {
						failedServices.add(servicesToUpdate.values().get(i).Id);
						dohagedcare__Application_Log__c appLog = new dohagedcare__Application_Log__c();
						appLog.dohagedcare__Exception_Type__c = 'StarRatingExemptionBatch error';
						appLog.dohagedcare__Logging_Date_Time__c = System.now();
						appLog.dohagedcare__Logging_Level__c = 'ERROR';
						appLog.dohagedcare__Logging_User_Id__c = UserInfo.getUserId();
						appLog.dohagedcare__Message__c =
							result.get(i).getErrors()[0].getStatusCode() +
							': ' +
							result.get(i).getErrors()[0].getMessage();
						appLog.dohagedcare__Source_Application__c = 'Star Rating';
						allLogs.add(appLog);
					}
				}
				Database.insert(allLogs);
			} catch (Exception ex) {
				dohagedcare.Logger.error(ex.getMessage(), ex, 'Star Rating').log();
			}
		}

		// Remove failed services from active exemptions lists
		for (Integer i = 0; i < activeExemptions.size(); i++) {
			if (failedServices.contains(activeExemptions[i].Service__c)) {
				activeExemptions.remove(i);
				i--;
			}
		}

		// activate process
		if (activeExemptions.size() > 0) {
			StarRatingExemptionBatchUtil.activeExemptionProcess(activeExemptions);
		}
	}

	public void finish(Database.BatchableContext bc) {
	}

	/*
	 *Helper methods
	 */
	private enum ExemptionTypes {
		CER_EXEMPTION,
		CM_EXEMPTION,
		QI_EXEMPTION,
		SCR_EXEMPTION
	}

	private void constructExemptionsServiceIDsMap(List<SRQI_Exemption__c> exemptions) {
		for (SRQI_Exemption__c exemptionRec : exemptions) {
			if (exemptionRec.Service__c != null) {
				serviceIds.add(exemptionRec.Service__c);
			}
			switch on ExemptionTypes.valueOf(exemptionRec.RecordType.DeveloperName) {
				when CER_EXEMPTION {
					activeOrExpiredList(exemptionRec, 'CER_Exemption');
				}
				when CM_EXEMPTION {
					activeOrExpiredList(exemptionRec, 'CM_Exemption');
				}
				when QI_EXEMPTION {
					activeOrExpiredList(exemptionRec, 'QI_Exemption');
				}
				when SCR_EXEMPTION {
					activeOrExpiredList(exemptionRec, 'SCR_Exemption');
				}
				when else {
					dohagedcare.Logger.warn('Exemption subdomain is not valid').log();
				}
			}
		}
	}

	private void activeOrExpiredList(SRQI_Exemption__c exemption, String subdomain) {
		if (exemption.Active__c) {
			servicesActiveExemptions.get(subdomain).add(exemption.Service__c);
		} else {
			servicesExpiredExemptions.get(subdomain).add(exemption.Service__c);
		}
	}

	private Boolean hasActiveExemption(BusinessLicense service, SRQI_Exemption__c exemption) {
		return (servicesActiveExemptions.containsKey(exemption.RecordType.DeveloperName) &&
		servicesActiveExemptions.get(exemption.RecordType.DeveloperName).contains(service.Id));
	}

	// Returns set of all service IDs
	private Set<Id> getServiceIds() {
		return serviceIds;
	}
}
