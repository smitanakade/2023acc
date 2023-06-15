/*******************************************************************************************
 * @Name             StarRatingUtil
 * @Test class
 * @Author           Gabriel Piragibe Cova Leda de Almeida
 * @Date             26-09-2022
 * @Story#           225785 (SR-QI ART Planning Sprint 4)
 * @LWC Component    None
 * @Description      Utility class to be used within STAR Rating application
 *******************************************************************************************/
/* MODIFICATION LOG
 * Version       Developer                                Date                Description
 *-------------------------------------------------------------------------------------------
 *  1.0     	 Gabriel Piragibe Cova Leda de Almeida    26-09-2022          Initial Creation
 *  1.1			 Gabriel Piragibe Cova Leda de Almeida	  05/10/2022		  Added logic for story 238022
 *******************************************************************************************/
public with sharing class StarRatingUtil {
	// Indicates if service account relationship records have been loaded
	private static Boolean sarCacheLoaded = false;
	// Indicates if accreditation certification records have been loaded
	private static Boolean accredCertCacheloaded = false;
	// Indicates if cer records have been loaded
	private static Boolean cerDataLoaded = false;
	// Stores map in following format <serviceID, Association_Start_Date__c>
	private static Map<Id, Date> servicesRelationStarDate = new Map<Id, Date>();
	// Stores map in following format <serviceID, ServiceAccountRelationship ID>
	private static Map<Id, Id> serviceToSAR = new Map<Id, Id>();
	// Stores map in following format <serviceID, ProviderID>
	private static Map<Id, Id> serviceToProvider = new Map<Id, Id>();
	// Stores map in following format <serviceID, Accreditation_Certification__c.Start_Date__c>
	private static Map<Id, Date> servicesToAccreditationStDate = new Map<Id, Date>();
	// Stores map in following format <serviceID, accreditation duration (st date - end date)>
	private static Map<Id, Integer> servicesToAccreditationDuration = new Map<Id, Integer>();
	// Stores map in following format <serviceId, count of cer records>
	private static Map<Id, Boolean> hasValidCERData = new Map<Id, Boolean>();
	// Stores IDs of services that revoked cer consent
	private static Set<Id> servicesConsentRevoked = new Set<Id>();
	// Stores active service accounts linked to subdomains
	private static Map<String, Map<Id, Id>> activeSARToSubdomains = new Map<String, Map<Id, Id>>{
		'CER' => new Map<Id, Id>(),
		'CM' => new Map<Id, Id>(),
		'QI' => new Map<Id, Id>()
	};
	// Stores constant to indicate a service is classified as new service
	private static final String NEW_SERVICE = 'New Service';
	// Stores constant to indicate a service is classified as transferred service
	private static final String TRANSFERRED_SERVICE = 'Transferred Service';
	// Stores constant to indicate exemption of type CER
	private static final String CER_EXEMPTION = 'CER_Exemption';
	// Stores constant to indicate exemption of type CM
	private static final String CM_EXEMPTION = 'CM_Exemption';
	// Stores constant to indicate exemption of type QI
	private static final String QI_EXEMPTION = 'QI_Exemption';
	// Stores constant to indicate exemption of type SCR
	private static final String SCR_EXEMPTION = 'SCR_Exemption';
	// Stores constant to indicate exemption of type system
	private static final String SYSTEM_EXEMPTION = 'System';
	// Stores constant to indicate app name in exception log
	private static final String APP_NAME = 'Star Rating';
	// Stores constant to indicate current rating type
	private static final String CURRENT_RATING = 'Current Rating';
	// Stores constant to indicate live availability status
	private static final String LIVE_STATUS = 'LIVE';
	// Stores list containing exemption types
	private static final List<String> EXEMPTION_TYPES = new List<String>{
		CER_EXEMPTION,
		CM_EXEMPTION,
		QI_EXEMPTION,
		SCR_EXEMPTION
	};
	// Map stores subdomain and services with new exemption in those subdomains <Exemption Subdomain, set of Service Ids>
	private static Map<String, Set<Id>> servicesExemptions = new Map<String, Set<Id>>{
		CER_EXEMPTION => new Set<Id>(),
		CM_EXEMPTION => new Set<Id>(),
		QI_EXEMPTION => new Set<Id>(),
		SCR_EXEMPTION => new Set<Id>()
	};

	// Stores default configuration for exemption metadata
	public static STARRating_Exemption_Setting__mdt exemptionDefault = StarRatingExemptionCustomMetadata.getExemptionConfig();

	@testvisible
	private static Boolean fakeException = false;

	// This method cache information regarding service account relationships so we do not perform the same SOQL query for different services
	public static void cacheServiceAccRelationship(Set<Id> serviceIDs) {
		if (sarCacheLoaded) {
			return;
		}

		Map<Id, Service_Account_Relationship__c> allSAR = new Map<Id, Service_Account_Relationship__c>(
			[
				SELECT Id, Service_Name__c, Association_Start_Date__c, Provider_Name__c
				FROM Service_Account_Relationship__c
				WHERE Active__c = TRUE AND Service_Name__c IN :serviceIDs
			]
		);

		for (Service_Account_Relationship__c sarRecord : allSAR.values()) {
			if (sarRecord.Association_Start_Date__c != null && sarRecord.Service_Name__c != null) {
				servicesRelationStarDate.put(sarRecord.Service_Name__c, sarRecord.Association_Start_Date__c);
			}
			if (sarRecord.Service_Name__c != null && sarRecord.Provider_Name__c != null) {
				serviceToProvider.put(sarRecord.Service_Name__c, sarRecord.Provider_Name__c);
			}
			if (sarRecord.Service_Name__c != null) {
				serviceToSAR.put(sarRecord.Service_Name__c, sarRecord.Id);
			}
		}

		sarCacheLoaded = true;
	}

	/*	This method cache information regarding Accreditation/Certification records so we do not perform the same SOQL query for different services
	 *	It returns the earliest accreditation date of a service for records with Decision Type == 'Record a Decision to Accredit'
	 */
	public static void cacheAccredCertification(Set<Id> serviceIDs) {
		if (accredCertCacheloaded) {
			return;
		}
		Id recordTypeId = Schema.SObjectType.Accreditation_Certification__c.getRecordTypeInfosByDeveloperName()
			.get('Accreditation')
			.getRecordTypeId();
		Map<Id, Accreditation_Certification__c> allAccredCerts = new Map<Id, Accreditation_Certification__c>(
			[
				SELECT Id, Start_Date__c, End_Date__c, Service__c, Decision_Type__c
				FROM Accreditation_Certification__c
				WHERE
					RecordTypeId = :recordTypeId
					AND Accreditation_Status__c = 'Accredited'
					AND Service__c IN :serviceIDs
				ORDER BY Start_Date__c DESC
			]
		);

		for (Accreditation_Certification__c accredCertRec : allAccredCerts.values()) {
			if (
				accredCertRec.Service__c != null &&
				accredCertRec.Start_Date__c != null &&
				accredCertRec.End_Date__c != null &&
				!servicesToAccreditationDuration.containsKey(accredCertRec.Service__c) &&
				accredCertRec.Decision_Type__c == 'Record a Decision to Accredit'
			) {
				Integer accrDuration = Math.abs(accredCertRec.Start_Date__c.daysBetween(accredCertRec.End_Date__c));
				servicesToAccreditationDuration.put(accredCertRec.Service__c, accrDuration);
			}

			if (
				servicesToAccreditationStDate.containsKey(accredCertRec.Service__c) &&
				servicesToAccreditationStDate.get(accredCertRec.Service__c) > accredCertRec.Start_Date__c
			) {
				servicesToAccreditationStDate.put(accredCertRec.Service__c, accredCertRec.Start_Date__c);
			} else if (
				accredCertRec.Service__c != null && !servicesToAccreditationStDate.containsKey(accredCertRec.Service__c)
			) {
				servicesToAccreditationStDate.put(accredCertRec.Service__c, accredCertRec.Start_Date__c);
			} else {
				continue;
			}
		}

		accredCertCacheloaded = true;
	}

	// This method cache information regarding CER data, which will be used when deciding if a service will be grant an exemption or not.
	public static void cacheCERData(Set<Id> serviceIDs) {
		if (cerDataLoaded) {
			return;
		}

		/* Check if all of the CEIs for the CER have interview start date >= active SAR start date
		 If all of them have, then it means the service has valid CEI data and should NOT be exempt*/
		for (SRQI_CEI__c cei : [
			SELECT id, Consumer_Experience_Report__r.Service__c, Activity_Start_Date__c
			FROM SRQI_CEI__c
			WHERE
				Consumer_Experience_Report__r.Service__c IN :serviceIDs
				AND Consumer_Experience_Report__r.Reporting_Period__r.Reporting_Period_Type__c = 'Year'
				AND Consumer_Experience_Report__r.Reporting_Period__r.Previous_Reporting_Period__c = TRUE
			ORDER BY Activity_Start_Date__c DESC
		]) {
			if (cei.Activity_Start_Date__c < getServAccRelStartDate(cei.Consumer_Experience_Report__r.Service__c)) {
				hasValidCERData.put(cei.Consumer_Experience_Report__r.Service__c, false);
			} else {
				hasValidCERData.put(cei.Consumer_Experience_Report__r.Service__c, true);
			}
		}

		cerDataLoaded = true;
	}

	// This method returns the accredtation duration for a requested service
	public static Integer getAccreditationDuration(Id serviceID) {
		return servicesToAccreditationDuration.get(serviceID);
	}

	// This method returns true if service has valid cer data
	public static Boolean isServiceCERRecordsValid(Id serviceID) {
		return hasValidCERData.get(serviceID);
	}

	// This method returns the provider ID associated with specified service
	public static Id getServiceProviderId(Id serviceID) {
		return serviceToProvider.get(serviceID);
	}

	// This method returns the accreditation start date of a service
	public static Date getServAccredCertStarDate(Id serviceID) {
		return servicesToAccreditationStDate.get(serviceID);
	}

	// This method returns the service's association start date with a provider
	public static Date getServAccRelStartDate(Id serviceID) {
		return servicesRelationStarDate.get(serviceID);
	}

	// This method returns the service account relationship ID of a service
	private static Id getServiceAccRelationshipId(Id serviceID) {
		return serviceToSAR.get(serviceID);
	}

	// This method returns exemption record type ID
	private static Id getExemptionRecordTypeID(String exemptionType) {
		return Schema.SObjectType.SRQI_Exemption__c.getRecordTypeInfosByDeveloperName()
			.get(exemptionType)
			.getRecordTypeId();
	}

	// This method returns SRH records with rating type New Rating
	private static List<STAR_Rating_History__c> getSRHRecords(Set<Id> serviceIDs) {
		return [
			SELECT
				Id,
				SF_Service_Id__c,
				SF_Provider_Id__c,
				Service_Account_Relationship__c,
				STAR_Rating_Calculation__c,
				Rating_Exemption_Reason__c,
				Transferred__c,
				New_Service__c,
				Rating_Type__c,
				Status__c,
				Rating_Calc_Date__c,
				Publication_Date__c,
				Reporting_Period__c,
				Consumer_Experience_Id__c,
				Care_Minutes_Id__c,
				Quality_Indicator_Id__c,
				SF_Service_Id__r.CER_Consent_Revoked__c
			FROM STAR_Rating_History__c
			WHERE Rating_Type__c IN ('New Rating') AND SF_Service_Id__c IN :serviceIDs
		];
	}

	/* This method create system exemptions. It receives a service, then it loops through all subdomains
	and check if a service is already exempt for the current domain. If not, then it performs checks
	to decide if a service is classified as 'new service' or 'transferred service' for each subdomain, and finally
	creates exemption*/
	public static List<SRQI_Exemption__c> createSystemExemptions(BusinessLicense service) {
		List<SRQI_Exemption__c> allExemptions = new List<SRQI_Exemption__c>();

		for (String recType : EXEMPTION_TYPES) {
			SRQI_Exemption__c exemption;
			if (recType == CER_EXEMPTION && service.CER_Exempt__c != true) {
				exemption = cerProcess(service);

				if (exemption != null) {
					allExemptions.add(exemption);
				}
			} else if (recType == CM_EXEMPTION && service.CM_Exempt__c != true) {
				exemption = cmProcess(service);

				if (exemption != null) {
					allExemptions.add(exemption);
				}
			} else if (recType == QI_EXEMPTION && service.QI_Exempt__c != true) {
				exemption = qiProcess(service);

				if (exemption != null) {
					allExemptions.add(exemption);
				}
			} else if (recType == SCR_EXEMPTION && service.SCR_Exempt__c != true) {
				exemption = scrProcess(service);

				if (exemption != null) {
					allExemptions.add(exemption);
				}
			} else {
				continue;
			}
		}

		return allExemptions;
	}

	// Process to generate CER exemption
	private static SRQI_Exemption__c cerProcess(BusinessLicense service) {
		SRQI_Exemption__c cerExemption;
		if (isServiceEligibleCERNewExemption(service)) {
			if (
				!service.CER_Consent_Revoked__c &&
				(isServiceCERRecordsValid(service.Id) == null || !isServiceCERRecordsValid(service.Id))
			) {
				cerExemption = createCERExemption(service, NEW_SERVICE);
			}

			if (service.CER_Consent_Revoked__c) {
				servicesConsentRevoked.add(service.Id);
			}
		} else if (isServiceEligibleCERTransferExemption(service)) {
			if (
				!service.CER_Consent_Revoked__c &&
				(isServiceCERRecordsValid(service.Id) == null || !isServiceCERRecordsValid(service.Id))
			) {
				cerExemption = createCERExemption(service, TRANSFERRED_SERVICE);
			} else {
				servicesConsentRevoked.add(service.Id);
			}
		} else {
			return cerExemption;
		}

		return cerExemption;
	}

	// Process to generate CM exemption
	private static SRQI_Exemption__c cmProcess(BusinessLicense service) {
		SRQI_Exemption__c cmExemption;
		if (isServiceEligibleCMNewExemption(service)) {
			cmExemption = createCMExemption(service, NEW_SERVICE);
		} else if (isServiceEligibleCMTransferExemption(service)) {
			cmExemption = createCMExemption(service, TRANSFERRED_SERVICE);
		} else {
			return cmExemption;
		}

		return cmExemption;
	}

	// Process to generate QI exemption
	private static SRQI_Exemption__c qiProcess(BusinessLicense service) {
		SRQI_Exemption__c qiExemption;
		if (isServiceEligibleQINewExemption(service)) {
			qiExemption = createQIExemption(service, NEW_SERVICE);
		} else if (isServiceEligibleQITransferExemption(service)) {
			qiExemption = createQIExemption(service, TRANSFERRED_SERVICE);
		} else {
			return qiExemption;
		}

		return qiExemption;
	}

	// Process to generate SCR exemption
	private static SRQI_Exemption__c scrProcess(BusinessLicense service) {
		SRQI_Exemption__c scrExemption;
		if (isServiceEligibleSCRNewExemption(service)) {
			scrExemption = createSCRExemption(service, NEW_SERVICE);
		} else if (isServiceEligibleSCRTransferExemption(service)) {
			scrExemption = createSCRExemption(service, TRANSFERRED_SERVICE);
		} else {
			return scrExemption;
		}

		return scrExemption;
	}

	// This method checks if service is eligible for a CER exemption reason new
	private static Boolean isServiceEligibleCERNewExemption(BusinessLicense service) {
		Date serviceFirstAccreditationDate = getServAccredCertStarDate(service.Id);
		Boolean isFirstAccreditationDateNull = (serviceFirstAccreditationDate == null);
		Boolean isFirstAccreditationDateInFuture = (serviceFirstAccreditationDate > System.today());
		Boolean isFirstAccreditationDateInPastTwelveMonths = ((serviceFirstAccreditationDate != null) &&
		(serviceFirstAccreditationDate.daysBetween(System.today()) < exemptionDefault.CER_Exempt_Days__c));

		return (isFirstAccreditationDateNull ||
		isFirstAccreditationDateInFuture ||
		isFirstAccreditationDateInPastTwelveMonths);
	}

	// This method checks if service is eligible for a CM exemption reason new
	private static Boolean isServiceEligibleCMNewExemption(BusinessLicense service) {
		Date serviceFirstAccreditationDate = getServAccredCertStarDate(service.Id);
		Boolean isFirstAccreditationDateNull = (serviceFirstAccreditationDate == null);
		Boolean isFirstAccreditationDateInFuture = (serviceFirstAccreditationDate > System.today());
		Boolean isFirstAccreditationDateInPastNineMonths = ((serviceFirstAccreditationDate != null) &&
		(serviceFirstAccreditationDate.daysBetween(System.today()) < exemptionDefault.CM_Exempt_Days__c));

		return ((isFirstAccreditationDateNull ||
		isFirstAccreditationDateInFuture ||
		isFirstAccreditationDateInPastNineMonths) && !service.Operational_Two_Last_Quarters__c);
	}

	// This method checks if service is eligible for a QI exemption reason new
	private static Boolean isServiceEligibleQINewExemption(BusinessLicense service) {
		Date serviceFirstAccreditationDate = getServAccredCertStarDate(service.Id);
		Boolean isFirstAccreditationDateNull = (serviceFirstAccreditationDate == null);
		Boolean isFirstAccreditationDateInFuture = (serviceFirstAccreditationDate > System.today());
		Boolean isFirstAccreditationDateInPastNineMonths = ((serviceFirstAccreditationDate != null) &&
		(serviceFirstAccreditationDate.daysBetween(System.today()) < exemptionDefault.QI_Exempt_Days__c));

		return ((isFirstAccreditationDateNull ||
		isFirstAccreditationDateInFuture ||
		isFirstAccreditationDateInPastNineMonths) && !service.Operational_Two_Last_Quarters__c);
	}

	// This method checks if service is eligible for a SCR exemption reason new
	private static Boolean isServiceEligibleSCRNewExemption(BusinessLicense service) {
		Date serviceFirstAccreditationDate = getServAccredCertStarDate(service.Id);
		Boolean isFirstAccreditationDateNull = (serviceFirstAccreditationDate == null);
		Boolean isFirstAccreditationDateInFuture = (serviceFirstAccreditationDate > System.today());
		Boolean isFirstAccreditationDateInPastTwelveMonths = ((serviceFirstAccreditationDate != null) &&
		(serviceFirstAccreditationDate.daysBetween(System.today()) < exemptionDefault.SCR_Exempt_Days__c));

		return (isFirstAccreditationDateNull ||
		isFirstAccreditationDateInFuture ||
		isFirstAccreditationDateInPastTwelveMonths);
	}

	// This method checks if service is eligible for a CER exemption reason transfer
	private static Boolean isServiceEligibleCERTransferExemption(BusinessLicense service) {
		Date serviceAssociationStartDate = getServAccRelStartDate(service.Id);
		return (serviceAssociationStartDate != null) &&
			(serviceAssociationStartDate.daysBetween(System.today()) < exemptionDefault.CER_Exempt_Days__c);
	}

	// This method checks if service is eligible for a CM exemption reason transfer
	private static Boolean isServiceEligibleCMTransferExemption(BusinessLicense service) {
		Date serviceAssociationStartDate = getServAccRelStartDate(service.Id);
		Date serviceAccreditationStartDate = getServAccredCertStarDate(service.Id);

		Boolean isAssociationStartDateInPastNineMonths = (serviceAssociationStartDate != null &&
		serviceAssociationStartDate.daysBetween(System.today()) < exemptionDefault.CM_Exempt_Days__c);

		Boolean isAccreditationStartDateOlderThanNineMonths = (serviceAccreditationStartDate != null &&
		serviceAccreditationStartDate.daysBetween(System.today()) > exemptionDefault.CM_Exempt_Days__c);

		return (isAssociationStartDateInPastNineMonths &&
		isAccreditationStartDateOlderThanNineMonths &&
		!service.Operational_Two_Last_Quarters__c);
	}

	// This method checks if service is eligible for a QI exemption reason transfer
	private static Boolean isServiceEligibleQITransferExemption(BusinessLicense service) {
		Date serviceAssociationStartDate = getServAccRelStartDate(service.Id);
		Date serviceAccreditationStartDate = getServAccredCertStarDate(service.Id);

		Boolean isAssociationStartDateInPastNineMonths = (serviceAssociationStartDate != null &&
		serviceAssociationStartDate.daysBetween(System.today()) < exemptionDefault.QI_Exempt_Days__c);

		Boolean isAccreditationStartDateOlderThanNineMonths = (serviceAccreditationStartDate != null &&
		serviceAccreditationStartDate.daysBetween(System.today()) > exemptionDefault.QI_Exempt_Days__c);

		return (isAssociationStartDateInPastNineMonths &&
		isAccreditationStartDateOlderThanNineMonths &&
		!service.Operational_Two_Last_Quarters__c);
	}

	// This method checks if service is eligible for a SCR exemption reason transfer
	private static Boolean isServiceEligibleSCRTransferExemption(BusinessLicense service) {
		Date serviceAssociationStartDate = getServAccRelStartDate(service.Id);
		return (serviceAssociationStartDate != null) &&
			(serviceAssociationStartDate.daysBetween(System.today()) < exemptionDefault.SCR_Exempt_Days__c);
	}

	// This method checks if exemption is active
	private static Boolean isExemptionActive(SRQI_Exemption__c exemption) {
		return (exemption.Exemption_Start__c <= System.today() && exemption.Exemption_Finish__c >= System.today());
	}

	/*This method takes all exemptions that have been created and set the services' exemption flags to true
	 if exemption is active*/
	public static void updateServiceExemptionFlags(List<SRQI_Exemption__c> exemptions) {
		Set<Id> servicesIDs = new Set<Id>();
		for (SRQI_Exemption__c exempRec : exemptions) {
			if (exempRec.Service__c != null) {
				servicesIDs.add(exempRec.Service__c);
			}
		}

		Map<Id, BusinessLicense> services = new Map<Id, BusinessLicense>(
			[
				SELECT Id, CER_Exempt__c, CM_Exempt__c, QI_Exempt__c, SCR_Exempt__c
				FROM BusinessLicense
				WHERE Id IN :servicesIDs
			]
		);

		for (SRQI_Exemption__c exempRec : exemptions) {
			if (exempRec.RecordTypeId == getExemptionRecordTypeID(CER_EXEMPTION) && isExemptionActive(exempRec)) {
				BusinessLicense service = services.get(exempRec.Service__c);
				service.CER_Exempt__c = true;
			} else if (exempRec.RecordTypeId == getExemptionRecordTypeID(CM_EXEMPTION) && isExemptionActive(exempRec)) {
				BusinessLicense service = services.get(exempRec.Service__c);
				service.CM_Exempt__c = true;
			} else if (exempRec.RecordTypeId == getExemptionRecordTypeID(QI_EXEMPTION) && isExemptionActive(exempRec)) {
				BusinessLicense service = services.get(exempRec.Service__c);
				service.QI_Exempt__c = true;
			} else if (
				exempRec.RecordTypeId == getExemptionRecordTypeID(SCR_EXEMPTION) && isExemptionActive(exempRec)
			) {
				BusinessLicense service = services.get(exempRec.Service__c);
				service.SCR_Exempt__c = true;
			} else {
				continue;
			}
		}

		try {
			Database.update(services.values(), false);
			if (test.isRunningTest() && fakeException) {
				services.values()[20000].CER_Exempt__c = true;
			}
		} catch (Exception ex) {
			dohagedcare.Logger.error(ex.getMessage(), ex, APP_NAME).log();
		}
	}

	// This method updates cer records of services' that have been exempt for CER
	public static void cerUpdate(Map<Id, String> cerIDsToReason) {
		Map<Id, SRQI_CER__c> cerRecords = new Map<Id, SRQI_CER__c>(
			[
				SELECT
					Id,
					Service__c,
					Consumer_Experience_Rating__c,
					Rating_Exemption_Reason__c,
					Rating_Calc_Date__c,
					Rating_Type__c
				FROM SRQI_CER__c
				WHERE Id IN :cerIDsToReason.keySet()
			]
		);

		for (SRQI_CER__c cerRec : cerRecords.values()) {
			cerRec.Consumer_Experience_Rating__c = null;
			cerRec.Rating_Exemption_Reason__c = cerIDsToReason.get(cerRec.Id);
			cerRec.Rating_Calc_Date__c = System.now();
			cerRec.Rating_Type__c = CURRENT_RATING;
			cerRec.Rating_Exemption_Granted__c = true;
			cerRec.Availability_Status__c = LIVE_STATUS;
		}
		try {
			update cerRecords.values();
			if (test.isRunningTest() && fakeException) {
				cerRecords.values()[200000].Consumer_Experience_Rating__c = null;
			}
		} catch (Exception ex) {
			dohagedcare.Logger.error(ex.getMessage(), ex, APP_NAME).log();
		}
	}

	// This method updates cm records of services' that have been exempt for CM
	public static void cmUpdate(Map<Id, String> cmIDsToReason) {
		Map<Id, Care_Minutes_Summary__c> cmRecords = new Map<Id, Care_Minutes_Summary__c>(
			[
				SELECT
					Id,
					Service__c,
					Care_Minutes_Rating__c,
					Care_Minutes_Rating_Label__c,
					Rating_Exemption_Reason__c,
					Rating_Calc_Date__c,
					Rating_Type__c
				FROM Care_Minutes_Summary__c
				WHERE Id IN :cmIDsToReason.keySet()
			]
		);
		for (Care_Minutes_Summary__c cmRec : cmRecords.values()) {
			cmRec.Care_Minutes_Rating__c = null;
			cmRec.Rating_Exemption_Reason__c = cmIDsToReason.get(cmRec.Id);
			cmRec.Rating_Calc_Date__c = System.now();
			cmRec.Rating_Type__c = CURRENT_RATING;
			cmRec.Rating_Exemption_Granted__c = true;
			cmRec.Availability_Status__c = LIVE_STATUS;
		}
		try {
			update cmRecords.values();
			if (test.isRunningTest() && fakeException) {
				cmRecords.values()[200000].Care_Minutes_Rating__c = null;
			}
		} catch (Exception ex) {
			dohagedcare.Logger.error(ex.getMessage(), ex, APP_NAME).log();
		}
	}

	// This method updates qi records of services' that have been exempt for QI
	public static void qiUpdate(Map<Id, String> qiIDsToReason) {
		Map<Id, Quality_Indicator_Summary__c> qiRecords = new Map<Id, Quality_Indicator_Summary__c>(
			[
				SELECT
					Id,
					Service__c,
					Quality_Indicator_Rating__c,
					Rating_Exemption_Reason__c,
					Rating_Calc_Date__c,
					Rating_Type__c
				FROM Quality_Indicator_Summary__c
				WHERE Id IN :qiIDsToReason.keySet()
			]
		);

		for (Quality_Indicator_Summary__c qiRec : qiRecords.values()) {
			qiRec.Quality_Indicator_Rating__c = null;
			qiRec.Rating_Exemption_Reason__c = qiIDsToReason.get(qiRec.Id);
			qiRec.Rating_Calc_Date__c = System.now();
			qiRec.Rating_Type__c = CURRENT_RATING;
			qiRec.Rating_Exemption_Granted__c = true;
			qiRec.Availability_Status__c = LIVE_STATUS;
		}

		try {
			update qiRecords.values();
			if (test.isRunningTest() && fakeException) {
				qiRecords.values()[200000].Quality_Indicator_Rating__c = null;
			}
		} catch (Exception ex) {
			dohagedcare.Logger.error(ex.getMessage(), ex, APP_NAME).log();
		}
	}

	// Creates CER subdomain
	private static SRQI_CER__c createCER(STAR_Rating_History__c srh) {
		SRQI_CER__c cer = new SRQI_CER__c();
		cer.Reporting_Period__c = srh.Reporting_Period__c;
		cer.Service__c = srh.SF_Service_Id__c;
		cer.Provider__c = srh.SF_Provider_Id__c;
		cer.Service_Account__c = srh.Service_Account_Relationship__c;
		cer.Rating_Calc_Date__c = System.now();
		cer.Rating_Type__c = srh.Rating_Type__c;
		cer.Availability_Status__c = srh.Status__c;
		if (servicesExemptions.get(CER_EXEMPTION).contains(srh.SF_Service_Id__c)) {
			cer.Rating_Exemption_Reason__c = srh.Rating_Exemption_Reason__c;
			cer.Rating_Exemption_Granted__c = true;
			cer.Consumer_Experience_Rating__c = null;
		} else {
			cer.Consumer_Experience_Rating__c = 1;
		}

		return cer;
	}

	// Creates CM subdomain
	private static Care_Minutes_Summary__c createCM(STAR_Rating_History__c srh) {
		Care_Minutes_Summary__c cm = new Care_Minutes_Summary__c();
		cm.Reporting_Period__c = srh.Reporting_Period__c;
		cm.Service__c = srh.SF_Service_Id__c;
		cm.Provider_Name__c = srh.SF_Provider_Id__c;
		cm.Service_Account__c = srh.Service_Account_Relationship__c;
		cm.Rating_Calc_Date__c = System.now();
		cm.Rating_Type__c = srh.Rating_Type__c;
		cm.Availability_Status__c = srh.Status__c;
		if (servicesExemptions.get(CM_EXEMPTION).contains(srh.SF_Service_Id__c)) {
			cm.Care_Minutes_Rating__c = null;
			cm.Rating_Exemption_Granted__c = true;
			cm.Rating_Exemption_Reason__c = srh.Rating_Exemption_Reason__c;
		} else {
			cm.Care_Minutes_Rating__c = 1;
		}

		return cm;
	}

	// Creates QI subdomain
	private static Quality_Indicator_Summary__c createQI(STAR_Rating_History__c srh) {
		Quality_Indicator_Summary__c qi = new Quality_Indicator_Summary__c();
		qi.Reporting_Period__c = srh.Reporting_Period__c;
		qi.Service__c = srh.SF_Service_Id__c;
		qi.PROVIDER_ID__c = srh.SF_Provider_Id__c;
		qi.SERVICE_ACCOUNT_ID__c = srh.Service_Account_Relationship__c;
		qi.Rating_Calc_Date__c = System.now();
		qi.Rating_Type__c = srh.Rating_Type__c;
		qi.Availability_Status__c = srh.Status__c;
		if (servicesExemptions.get(QI_EXEMPTION).contains(srh.SF_Service_Id__c)) {
			qi.Rating_Exemption_Granted__c = true;
			qi.Rating_Exemption_Reason__c = srh.Rating_Exemption_Reason__c;
			qi.Quality_Indicator_Rating__c = null;
		} else {
			qi.Quality_Indicator_Rating__c = 1;
		}

		return qi;
	}

	// This method checks if SRH subdomains exist and if service is exempt for those particular subdomains
	private static void srhSubdomainsToUpdateOrCreate(List<STAR_Rating_History__c> srhList) {
		List<SRQI_CER__c> cerToInsert = new List<SRQI_CER__c>();
		List<Care_Minutes_Summary__c> cmToInsert = new List<Care_Minutes_Summary__c>();
		List<Quality_Indicator_Summary__c> qiToInsert = new List<Quality_Indicator_Summary__c>();
		Map<Id, String> cerIDsToReason = new Map<Id, String>();
		Map<Id, String> cmIDsToReason = new Map<Id, String>();
		Map<Id, String> qiIDsToReason = new Map<Id, String>();

		for (STAR_Rating_History__c srh : srhList) {
			if (servicesExemptions.get(CER_EXEMPTION).contains(srh.SF_Service_Id__c)) {
				if (srh.Consumer_Experience_Id__c != null) {
					cerIDsToReason.put(srh.Consumer_Experience_Id__c, srh.Rating_Exemption_Reason__c);
				} else if (activeSARToSubdomains.get('CER').containsKey(srh.Service_Account_Relationship__c)) {
					// updates existing subdomain to reflect exemption
					cerIDsToReason.put(
						activeSARToSubdomains.get('CER').get(srh.Service_Account_Relationship__c),
						srh.Rating_Exemption_Reason__c
					);
					// link updated subdomain to SRH
					srh.Consumer_Experience_Id__c = activeSARToSubdomains.get('CER')
						.get(srh.Service_Account_Relationship__c);
				} else {
					cerToInsert.add(createCER(srh));
				}
			} else {
				if (servicesConsentRevoked.contains(srh.SF_Service_Id__c) && srh.Consumer_Experience_Id__c != null) {
					cerIDsToReason.put(srh.Consumer_Experience_Id__c, srh.Rating_Exemption_Reason__c);
				} else if (
					servicesConsentRevoked.contains(srh.SF_Service_Id__c) &&
					srh.Consumer_Experience_Id__c == null &&
					activeSARToSubdomains.get('CER').containsKey(srh.Service_Account_Relationship__c)
				) {
					// updates subdomain to reflect revoke
					cerIDsToReason.put(
						activeSARToSubdomains.get('CER').get(srh.Service_Account_Relationship__c),
						srh.Rating_Exemption_Reason__c
					);
					// links subdomain to SRH
					srh.Consumer_Experience_Id__c = activeSARToSubdomains.get('CER')
						.get(srh.Service_Account_Relationship__c);
				} else if (
					servicesConsentRevoked.contains(srh.SF_Service_Id__c) && srh.Consumer_Experience_Id__c == null
				) {
					// create cer rating 1
					cerToInsert.add(createCER(srh));
				} else {
					// consent not revoked and has data, link existing cer
					srh.Consumer_Experience_Id__c = activeSARToSubdomains.get('CER')
						.get(srh.Service_Account_Relationship__c);
				}
			}

			if (servicesExemptions.get(CM_EXEMPTION).contains(srh.SF_Service_Id__c)) {
				if (srh.Care_Minutes_Id__c != null) {
					cmIDsToReason.put(srh.Care_Minutes_Id__c, srh.Rating_Exemption_Reason__c);
				} else if (activeSARToSubdomains.get('CM').containsKey(srh.Service_Account_Relationship__c)) {
					// updates subdomain to reflect exemption
					cmIDsToReason.put(
						activeSARToSubdomains.get('CM').get(srh.Service_Account_Relationship__c),
						srh.Rating_Exemption_Reason__c
					);
					// links updated subdomain to SRH
					srh.Care_Minutes_Id__c = activeSARToSubdomains.get('CM').get(srh.Service_Account_Relationship__c);
				} else {
					cmToInsert.add(createCM(srh));
				}
			} else {
				if (activeSARToSubdomains.get('CM').containsKey(srh.Service_Account_Relationship__c)) {
					// link existing cm
					srh.Care_Minutes_Id__c = activeSARToSubdomains.get('CM').get(srh.Service_Account_Relationship__c);
				} else {
					cmToInsert.add(createCM(srh));
				}
			}

			if (servicesExemptions.get(QI_EXEMPTION).contains(srh.SF_Service_Id__c)) {
				if (srh.Quality_Indicator_Id__c != null) {
					qiIDsToReason.put(srh.Quality_Indicator_Id__c, srh.Rating_Exemption_Reason__c);
				} else if (activeSARToSubdomains.get('QI').containsKey(srh.Service_Account_Relationship__c)) {
					// updates subdomain to reflect exemption
					qiIDsToReason.put(
						activeSARToSubdomains.get('QI').get(srh.Service_Account_Relationship__c),
						srh.Rating_Exemption_Reason__c
					);
					// links updated subdomain to SRH
					srh.Quality_Indicator_Id__c = activeSARToSubdomains.get('QI')
						.get(srh.Service_Account_Relationship__c);
				} else {
					qiToInsert.add(createQI(srh));
				}
			} else {
				if (activeSARToSubdomains.get('QI').containsKey(srh.Service_Account_Relationship__c)) {
					// link existing qi
					srh.Quality_Indicator_Id__c = activeSARToSubdomains.get('QI')
						.get(srh.Service_Account_Relationship__c);
				} else {
					// create qi with 1 star
					qiToInsert.add(createQI(srh));
				}
			}
		}

		// update cer subdomain
		if (!cerIDsToReason.isEmpty()) {
			cerUpdate(cerIDsToReason);
		}

		// update cm subdomain
		if (!cmIDsToReason.isEmpty()) {
			cmUpdate(cmIDsToReason);
		}

		// update qi subdomain
		if (!qiIDsToReason.isEmpty()) {
			qiUpdate(qiIDsToReason);
		}

		// insert new cer subdomain
		if (!cerToInsert.isEmpty()) {
			try {
				insert cerToInsert;
			} catch (Exception ex) {
				dohagedcare.Logger.error(ex.getMessage(), ex, APP_NAME).log();
			}
		}

		// insert new cm subdomain
		if (!cmToInsert.isEmpty()) {
			try {
				insert cmToInsert;
			} catch (Exception ex) {
				dohagedcare.Logger.error(ex.getMessage(), ex, APP_NAME).log();
			}
		}

		// insert new qi subdomain
		if (!qiToInsert.isEmpty()) {
			try {
				insert qiToInsert;
			} catch (Exception ex) {
				dohagedcare.Logger.error(ex.getMessage(), ex, APP_NAME).log();
			}
		}
	}

	/* Set map of active SAR and their subdomains. The map will be used in method "srhSubdomainsToUpdateOrCreate" when deciding
	 if an existing subdomain must be linked to the SRH or if a new subdomain is required*/

	private static void setSARLinkedToSubdomains(Set<Id> activeSAR) {
		for (SRQI_CER__c rec : [
			SELECT Id, Service_Account__c
			FROM SRQI_CER__c
			WHERE Service_Account__c IN :activeSAR
			ORDER BY CreatedDate DESC
		]) {
			if (!activeSARToSubdomains.get('CER').containsKey(rec.Service_Account__c)) {
				activeSARToSubdomains.get('CER').put(rec.Service_Account__c, rec.Id);
			}
		}

		for (Care_Minutes_Summary__c rec : [
			SELECT Id, Service_Account__c
			FROM Care_Minutes_Summary__c
			WHERE Service_Account__c IN :activeSAR
			ORDER BY CreatedDate DESC
		]) {
			if (!activeSARToSubdomains.get('CM').containsKey(rec.Service_Account__c)) {
				activeSARToSubdomains.get('CM').put(rec.Service_Account__c, rec.Id);
			}
		}

		for (Quality_Indicator_Summary__c rec : [
			SELECT Id, SERVICE_ACCOUNT_ID__c
			FROM Quality_Indicator_Summary__c
			WHERE SERVICE_ACCOUNT_ID__c IN :activeSAR
			ORDER BY CreatedDate DESC
		]) {
			if (!activeSARToSubdomains.get('QI').containsKey(rec.SERVICE_ACCOUNT_ID__c)) {
				activeSARToSubdomains.get('QI').put(rec.SERVICE_ACCOUNT_ID__c, rec.Id);
			}
		}
	}

	// Link sub-domains created to their respective SRH
	private static void linkSubdomainsToSRH(Set<Id> activeSAR) {
		// <sarId, cerId>
		Map<Id, Id> sarToCER = new Map<Id, Id>();
		// <sarId, cmId>
		Map<Id, Id> sarToCM = new Map<Id, Id>();
		// <sarId, qiId>
		Map<Id, Id> sarToQI = new Map<Id, Id>();
		// <sarId, scrId>
		Map<Id, Id> sarToSCR = new Map<Id, Id>();
		//SRH to update with new/existing subdomains - <sarId, STAR_Rating_History__c>
		Map<Id, STAR_Rating_History__c> srhToUpdate = new Map<Id, STAR_Rating_History__c>();

		//start SCR
		for (Service_Compliance_History__c rec : [
			SELECT Id, Service_Account__c
			FROM Service_Compliance_History__c
			WHERE Service_Account__c IN :activeSAR AND Rating_Type__c = :CURRENT_RATING
			ORDER BY CreatedDate DESC
		]) {
			if (!sarToSCR.containsKey(rec.Service_Account__c)) {
				sarToSCR.put(rec.Service_Account__c, rec.Id);
			}
		}
		// end SCR
		for (SRQI_CER__c rec : [
			SELECT Id, Service_Account__c
			FROM SRQI_CER__c
			WHERE Service_Account__c IN :activeSAR
			ORDER BY CreatedDate DESC
		]) {
			if (!sarToCER.containsKey(rec.Service_Account__c)) {
				sarToCER.put(rec.Service_Account__c, rec.Id);
			}
		}

		for (Care_Minutes_Summary__c rec : [
			SELECT Id, Service_Account__c
			FROM Care_Minutes_Summary__c
			WHERE Service_Account__c IN :activeSAR
			ORDER BY CreatedDate DESC
		]) {
			if (!sarToCM.containsKey(rec.Service_Account__c)) {
				sarToCM.put(rec.Service_Account__c, rec.Id);
			}
		}

		for (Quality_Indicator_Summary__c rec : [
			SELECT Id, SERVICE_ACCOUNT_ID__c
			FROM Quality_Indicator_Summary__c
			WHERE SERVICE_ACCOUNT_ID__c IN :activeSAR
			ORDER BY CreatedDate DESC
		]) {
			if (!sarToQI.containsKey(rec.SERVICE_ACCOUNT_ID__c)) {
				sarToQI.put(rec.SERVICE_ACCOUNT_ID__c, rec.Id);
			}
		}

		for (
			STAR_Rating_History__c rec : [
				SELECT
					Id,
					Service_Account_Relationship__c,
					Consumer_Experience_Id__c,
					Care_Minutes_Id__c,
					Quality_Indicator_Id__c,
					// SCR start
					Service_Compliance_Id__c
				// SCR end
				FROM STAR_Rating_History__c
				WHERE Service_Account_Relationship__c IN :activeSAR
				ORDER BY CreatedDate DESC
			]
		) {
			if (!srhToUpdate.containsKey(rec.Service_Account_Relationship__c)) {
				rec.Consumer_Experience_Id__c = sarToCER.get(rec.Service_Account_Relationship__c);
				rec.Care_Minutes_Id__c = sarToCM.get(rec.Service_Account_Relationship__c);
				rec.Quality_Indicator_Id__c = sarToQI.get(rec.Service_Account_Relationship__c);
				// SCR start
				rec.Service_Compliance_Id__c = sarToSCR.get(rec.Service_Account_Relationship__c);
				// SCR end
				srhToUpdate.put(rec.Service_Account_Relationship__c, rec);
			}
		}

		if (!srhToUpdate.isEmpty()) {
			try {
				update srhToUpdate.values();
			} catch (Exception ex) {
				dohagedcare.Logger.error(ex.getMessage(), ex, APP_NAME).log();
			}
		}
	}

	// This method updates star rating history records of services' that have been exempt for a subdomain
	public static void srhUpdate(List<SRQI_Exemption__c> exemptions) {
		// Map contains <Service ID, Exemption Reason>
		Map<Id, String> servicesIDsExemptionReason = new Map<Id, String>();
		Set<Id> activeSAR = new Set<Id>();
		Set<Id> servicesWithSRHUpdated = new Set<Id>();

		for (SRQI_Exemption__c exempRec : exemptions) {
			if (exempRec.Service__c != null) {
				String exemptionRecordDevName = Schema.SObjectType.SRQI_Exemption__c.getRecordTypeInfosById()
					.get(exempRec.RecordTypeId)
					.getDeveloperName();
				servicesIDsExemptionReason.put(exempRec.Service__c, exempRec.Reason__c);
				servicesExemptions.get(exemptionRecordDevName).add(exempRec.Service__c);
			}
		}

		// Set all services that need srh updated, including services that revoked cer consent
		if (!servicesConsentRevoked.isEmpty()) {
			for (Id serviceID : servicesConsentRevoked) {
				if (!servicesIDsExemptionReason.containsKey(serviceID)) {
					servicesIDsExemptionReason.put(serviceID, null);
				}
			}
		}

		Map<Id, STAR_Rating_History__c> srhRecords = new Map<Id, STAR_Rating_History__c>(
			getSRHRecords(servicesIDsExemptionReason.keySet())
		);
		
		for (STAR_Rating_History__c srhRec : srhRecords.values()) {
			srhRec.STAR_Rating_Calculation__c = null;
			srhRec.Rating_Exemption_Reason__c = servicesIDsExemptionReason.get(srhRec.SF_Service_Id__c);
			srhRec.Transferred__c = (srhRec.Rating_Exemption_Reason__c == TRANSFERRED_SERVICE);
			srhRec.New_Service__c = (srhRec.Rating_Exemption_Reason__c == NEW_SERVICE);
			srhRec.Rating_Type__c = CURRENT_RATING;
			srhRec.Status__c = LIVE_STATUS;
			srhRec.Rating_Calc_Date__c = System.now();
			srhRec.Publication_Date__c = System.now();
			srhRec.Go_Live_Date__c = System.today();
			srhRec.Rating_Exemption_Granted__c = true;
			activeSAR.add(srhRec.Service_Account_Relationship__c);
			servicesWithSRHUpdated.add(srhRec.SF_Service_Id__c);
		}

		// Set map of active sar and their subdomains
		setSARLinkedToSubdomains(activeSAR);

		// Check if subdomains exist for each srh. If it exists, then update it, else create new one
		srhSubdomainsToUpdateOrCreate(srhRecords.values());

		try {
			update srhRecords.values();
			// Link subdomains
			linkSubdomainsToSRH(activeSAR);
			// Recalculate srh rating
			recalculateSRH(srhRecords.values());
			if (test.isRunningTest() && fakeException) {
				srhRecords.values()[200000].Transferred__c = true;
			}
		} catch (Exception ex) {
			dohagedcare.Logger.error(ex.getMessage(), ex, APP_NAME).log();
		}

		// Remove service IDs from servicesIDsExemptionReason for those services that had their SRH updated. This will leave in the map only services that need an SRH created
		servicesIDsExemptionReason.keySet().removeAll(servicesWithSRHUpdated);
		
		// Call method to create SRH if map size is > 0
		if (servicesIDsExemptionReason.size() > 0) {
			srhCreate(servicesIDsExemptionReason);
		}
	}

	/*This method creates star rating history records of services' that have been exempt for a subdomain and don't have a
	 star rating history record*/
	public static void srhCreate(Map<Id, String> servicesIdReason) {
		List<STAR_Rating_History__c> srhToCreate = new List<STAR_Rating_History__c>();
		Set<Id> activeSAR = new Set<Id>();

		// if service we are creating a SRH for has a current SRH, then we need to set it to previous rating
		List<STAR_Rating_History__c> currentSRH = [
			SELECT Id, Rating_Type__c
			FROM STAR_Rating_History__c
			WHERE Rating_Type__c = :CURRENT_RATING AND SF_Service_Id__c IN :servicesIdReason.keySet()
		];
		for (STAR_Rating_History__c rec : currentSRH) {
			rec.Rating_Type__c = 'Previous Rating';
		}

		for (Id servId : servicesIdReason.keySet()) {
			STAR_Rating_History__c newSRH = new STAR_Rating_History__c(
				Service_Account_Relationship__c = getServiceAccRelationshipId(servId),
				SF_Service_Id__c = servId,
				SF_Provider_Id__c = getServiceProviderId(servId),
				STAR_Rating_Calculation__c = null,
				Rating_Exemption_Reason__c = servicesIdReason.get(servId),
				Transferred__c = (servicesIdReason.get(servId) == TRANSFERRED_SERVICE),
				New_Service__c = (servicesIdReason.get(servId) == NEW_SERVICE),
				Rating_Type__c = CURRENT_RATING,
				Status__c = LIVE_STATUS,
				Reporting_Period__c = ReportingPeriodUtil.previousQuarterReportingPeriod?.Id,
				Rating_Exemption_Granted__c = (servicesIdReason.get(servId) != null),
				Rating_Calc_Date__c = System.now(),
				Go_Live_Date__c = System.today()
			);

			activeSAR.add(newSRH.Service_Account_Relationship__c);
			srhToCreate.add(newSRH);
		}

		// set map of active sar and their subdomains
		setSARLinkedToSubdomains(activeSAR);

		// Create shell records
		srhSubdomainsToUpdateOrCreate(srhToCreate);

		if (srhToCreate.size() > 0) {
			try {
				insert srhToCreate;
				update currentSRH;
				// link subdomains
				linkSubdomainsToSRH(activeSAR);
				// Recalculate overal
				recalculateSRH(srhToCreate);
				if (test.isRunningTest() && fakeException) {
					srhToCreate[200000].Transferred__c = true;
				}
			} catch (Exception ex) {
				dohagedcare.Logger.error(ex.getMessage(), ex, APP_NAME).log();
			}
		}
	}

	// Recalculate rating for SRH
	private static void recalculateSRH(List<STAR_Rating_History__c> srh) {
		String procedureName = 'SRQI_StarRatingCalculation';
		Map<String, Object> ipOutput;
		Map<String, Object> ipInput = new Map<String, Object>();
		Map<String, Object> ipOptions = new Map<String, Object>();

		for (STAR_Rating_History__c rec : srh) {
			ipInput.put('SRHID', rec.Id);
			ipInput.put('IsRecalc', true);
			ipOutput = (Map<String, Object>) omnistudio.IntegrationProcedureService.runIntegrationService(
				procedureName,
				ipInput,
				ipOptions
			);
		}
	}

	// This method creates exemption of type CER
	public static SRQI_Exemption__c createCERExemption(BusinessLicense service, String reason) {
		SRQI_Exemption__c exemption = new SRQI_Exemption__c();
		exemption.Service__c = service.Id;
		exemption.Service_Account_Relationship__c = getServiceAccRelationshipId(service.Id);
		exemption.Exemption_Start__c = (reason == NEW_SERVICE)
			? getServAccredCertStarDate(service.Id) == null ? System.today() : getServAccredCertStarDate(service.Id)
			: getServAccRelStartDate(service.Id) == null ? System.today() : getServAccRelStartDate(service.Id);

		exemption.Exemption_Finish__c = exemption.Exemption_Start__c.addDays(
			(Integer) exemptionDefault.CER_Exempt_Days__c
		);

		exemption.Reason__c = reason;
		exemption.Type__c = SYSTEM_EXEMPTION;
		exemption.RecordTypeId = getExemptionRecordTypeID(CER_EXEMPTION);

		return exemption;
	}

	// This method creates exemption of type CM
	public static SRQI_Exemption__c createCMExemption(BusinessLicense service, String reason) {
		SRQI_Exemption__c exemption = new SRQI_Exemption__c();
		exemption.Service__c = service.Id;
		exemption.Service_Account_Relationship__c = getServiceAccRelationshipId(service.Id);
		exemption.Exemption_Start__c = (reason == NEW_SERVICE)
			? getServAccredCertStarDate(service.Id) == null ? System.today() : getServAccredCertStarDate(service.Id)
			: getServAccRelStartDate(service.Id) == null ? System.today() : getServAccRelStartDate(service.Id);

		exemption.Exemption_Finish__c = exemption.Exemption_Start__c.addDays(
			(Integer) exemptionDefault.CM_Exempt_Days__c
		);

		exemption.Reason__c = reason;
		exemption.Type__c = SYSTEM_EXEMPTION;
		exemption.RecordTypeId = getExemptionRecordTypeID(CM_EXEMPTION);

		return exemption;
	}

	// This method creates exemption of type QI
	public static SRQI_Exemption__c createQIExemption(BusinessLicense service, String reason) {
		SRQI_Exemption__c exemption = new SRQI_Exemption__c();
		exemption.Service__c = service.Id;
		exemption.Service_Account_Relationship__c = getServiceAccRelationshipId(service.Id);
		exemption.Exemption_Start__c = (reason == NEW_SERVICE)
			? getServAccredCertStarDate(service.Id) == null ? System.today() : getServAccredCertStarDate(service.Id)
			: getServAccRelStartDate(service.Id) == null ? System.today() : getServAccRelStartDate(service.Id);

		exemption.Exemption_Finish__c = exemption.Exemption_Start__c.addDays(
			(Integer) exemptionDefault.QI_Exempt_Days__c
		);

		exemption.Reason__c = reason;
		exemption.Type__c = SYSTEM_EXEMPTION;
		exemption.RecordTypeId = getExemptionRecordTypeID(QI_EXEMPTION);

		return exemption;
	}

	// This method creates exemption of type SCR
	public static SRQI_Exemption__c createSCRExemption(BusinessLicense service, String reason) {
		SRQI_Exemption__c exemption = new SRQI_Exemption__c();
		exemption.Service__c = service.Id;
		exemption.Service_Account_Relationship__c = getServiceAccRelationshipId(service.Id);
		exemption.Exemption_Start__c = (reason == NEW_SERVICE)
			? getServAccredCertStarDate(service.Id) == null ? System.today() : getServAccredCertStarDate(service.Id)
			: getServAccRelStartDate(service.Id) == null ? System.today() : getServAccRelStartDate(service.Id);

		exemption.Exemption_Finish__c = exemption.Exemption_Start__c.addDays(
			(Integer) exemptionDefault.SCR_Exempt_Days__c
		);

		exemption.Reason__c = reason;
		exemption.Type__c = SYSTEM_EXEMPTION;
		exemption.RecordTypeId = getExemptionRecordTypeID(SCR_EXEMPTION);

		return exemption;
	}
}