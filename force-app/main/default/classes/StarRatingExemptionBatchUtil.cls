/*******************************************************************************************
 * @Name             StarRatingExemptionBatchUtil
 * @testClass       StarRatingExemptionBatchTest
 * @Author           Gabriel Piragibe Cova Leda de Almeida
 * @Date             12-10-2022
 * @Story#           TBA (SR-QI ART Planning Sprint 5)
 * @LWC Component    None
 * @Description		 utility class for StarRatingExemptionBatch
 *******************************************************************************************/
/* MODIFICATION LOG
 * Version       Developer                                Date                Description
 *-------------------------------------------------------------------------------------------
 *  1.0     		Gabriel Piragibe Cova Leda de Almeida    12-10-2022          Initial Creation
 *******************************************************************************************/
public with sharing class StarRatingExemptionBatchUtil {
	// Stores constant for cer exemption record type developer name
	private static final String CER_EXEMPTION = 'CER_Exemption';

	// Stores constant for cm exemption record type developer name
	private static final String CM_EXEMPTION = 'CM_Exemption';

	// Stores constant for qi exemption record type developer name
	private static final String QI_EXEMPTION = 'QI_Exemption';

	// Stores constant for scr exemption record type developer name
	private static final String SCR_EXEMPTION = 'SCR_Exemption';

	// Stores constant to indicate app name in exception log
	private static final String APP_NAME = 'Star Rating';

	// Enum to be used in switch statements as we cannot used constant in switch apex for now
	private enum ExemptionTypes {
		CER_EXEMPTION,
		CM_EXEMPTION,
		QI_EXEMPTION,
		SCR_EXEMPTION
	}

	// Stores constant message saying subdomain is not valid
	private static final String INVALID_SUBDOMAIN = 'Exemption subdomain is not valid';

	// Returns true if service exemption flag is checked for a particular subdomain
	public static Boolean isServiceExemptionFlagChecked(BusinessLicense service, SRQI_Exemption__c exemption) {
		Boolean flag = false;
		switch on ExemptionTypes.valueOf(exemption.RecordType.DeveloperName) {
			when CER_EXEMPTION {
				flag = service.CER_Exempt__c;
			}
			when CM_EXEMPTION {
				flag = service.CM_Exempt__c;
			}
			when QI_EXEMPTION {
				flag = service.QI_Exempt__c;
			}
			when SCR_EXEMPTION {
				flag = service.SCR_Exempt__c;
			}
			when else {
				dohagedcare.Logger.warn(INVALID_SUBDOMAIN).log();
			}
		}
		return flag;
	}

	// Set service flag exemption
	public static void setServiceFlag(BusinessLicense service, SRQI_Exemption__c exemption, Boolean isActive) {
		switch on ExemptionTypes.valueOf(exemption.RecordType.DeveloperName) {
			when CER_EXEMPTION {
				service.CER_Exempt__c = isActive;
			}
			when CM_EXEMPTION {
				service.CM_Exempt__c = isActive;
			}
			when QI_EXEMPTION {
				service.QI_Exempt__c = isActive;
			}
			when SCR_EXEMPTION {
				service.SCR_Exempt__c = isActive;
			}
			when else {
				dohagedcare.Logger.warn(INVALID_SUBDOMAIN).log();
			}
		}
	}

	/* Active exemption process will search for a SRH associated with a service, if it exists it will
	update the SRH and the associated subdomain. If SRH does not exist, it will create one and also create/update
	a subdomain.*/
	public static void activeExemptionProcess(List<SRQI_Exemption__c> exemptions) {
		Set<Id> serviceIDs = new Set<Id>();
		for (SRQI_Exemption__c exempRec : exemptions) {
			serviceIDs.add(exempRec.Service__c);
		}

		// Initialise required maps in star rating util class
		StarRatingUtil.cacheServiceAccRelationship(serviceIDs);
		StarRatingUtil.cacheAccredCertification(serviceIDs);
		StarRatingUtil.cacheCERData(serviceIDs);

		StarRatingUtil.srhUpdate(exemptions);
	}
}
