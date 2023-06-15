/*******************************************************************************************
 * @Name             ServiceOperationalChecker
 * @Test class       ServiceOperationalCheckerTest
 * @Author           Gabriel Piragibe Cova Leda de Almeida
 * @Date             03-11-2022
 * @Story#
 * @LWC Component    None
 * @Description      Checks if service has been operational for a determined period of time
 *******************************************************************************************/
/* MODIFICATION LOG
 * Version       Developer                                Date                Description
 *-------------------------------------------------------------------------------------------
 *  1.0     	 Gabriel Piragibe Cova Leda de Almeida    03-11-2022          Initial Creation
 *  2.0     	 Sharevreet Singh						  20-05-2023          added isOperationalForLastFullQuarter(..) method
 *******************************************************************************************/
public with sharing class ServiceOperationalChecker {
	// Indicates if reporting periods have been loaded
	private static Boolean datesCacheLoaded = false;

	// Stores first reporting period start date
	private static Date earliestStDate;

	// Stores first reporting period start date for last quarter
	private static Date earliestStDateLastQuarter;

	// Stores second reporting period end date
	private static Date latestEndDate;

	// Stores first reporting period end date for last quarter
	private static Date latestEndDateLastQuarter;

	// Stores map containing reporting periods
	private static Map<Id, Reporting_Period__c> rps;

	//This method sets rps with the latest 2 reporting periods prior to current one
	private static void setReportingPeriodsDates() {
		if (datesCacheLoaded) {
			return;
		}

		rps = new Map<Id, Reporting_Period__c>(
			[
				SELECT Id, Start_Date__c, End_Date__c
				FROM Reporting_Period__c
				WHERE
					Start_Date__c < TODAY
					AND Current_Reporting_Period__c = FALSE
					AND Reporting_Period_Type__c = 'Quarter'
				ORDER BY Start_Date__c DESC
				LIMIT 2
			]
		);

		/* If 2 reporting periods are returned, then set both dates. Otherwise, do nothing*/
		if (rps.size() > 1) {
			if (rps.values()[0].End_Date__c != null) {
				latestEndDate = rps.values()[0].End_Date__c;
				latestEndDateLastQuarter = rps.values()[0].End_Date__c;
			}

			if (rps.values()[0].Start_Date__c != null) {
				earliestStDateLastQuarter = rps.values()[0].Start_Date__c;
			}

			if (rps.values()[1].Start_Date__c != null) {
				earliestStDate = rps.values()[1].Start_Date__c;
			}
		}
		else {
			if (rps.size() > 0 && rps.values()[0].End_Date__c != null) {
				latestEndDateLastQuarter = rps.values()[0].End_Date__c;
			}

			if (rps.size() > 0 && rps.values()[0].Start_Date__c != null) {
				earliestStDateLastQuarter = rps.values()[0].Start_Date__c;
			}
		}


		datesCacheLoaded = true;
	}

	private static Date getRPStartDateLastQuarter() {
		if (datesCacheLoaded) {
			return earliestStDateLastQuarter;
		}
		setReportingPeriodsDates();
		return earliestStDateLastQuarter;
	}

	private static Date getRPEndDateQuarter() {
		if (datesCacheLoaded) {
			return latestEndDateLastQuarter;
		}
		setReportingPeriodsDates();
		return latestEndDateLastQuarter;
	}

	// This method returns earliest start date amongst the two reporting periods selected in query
	@TestVisible
	private static Date getRPStartDate() {
		if (datesCacheLoaded) {
			return earliestStDate;
		}
		setReportingPeriodsDates();
		return earliestStDate;
	}

	// This method returns latest end date amongst the two reporting periods selected in query
	private static Date getRPEndDate() {
		if (datesCacheLoaded) {
			return latestEndDate;
		}
		setReportingPeriodsDates();
		return latestEndDate;
	}

	/* This method updates checkbox that indicates if service has or has not been operational for last
	   2 full quarters in service object according to service's status.
       Logic: current quarter == Q4, hence we need start date from Q2 and end date from Q3. 
       If status is OPERATIONAL and service's status effective date < Q2 start date and active association start date < Q2 start date, 
	   then tick checkbox as service was operating in Q2 & Q3 under its new provider.
       If status is OFFLINE and service's status effective date > Q3 end date, then tick checkbox as service was operating in Q2 & Q3.*/
	public static void isOperationalForLastTwoFullQuarters(List<BusinessLicense> services) {
		Map<Id, BusinessLicense> servicesMap = new Map<Id, BusinessLicense>(services);
		StarRatingUtil.cacheServiceAccRelationship(servicesMap.keySet());

		for (BusinessLicense servRecords : servicesMap.values()) {
			switch on servRecords.Status__c {
				when 'Operational' {
					if (
						servRecords.Status_Date__c < getRPStartDate() &&
						StarRatingUtil.getServAccRelStartDate(servRecords.Id) < getRPStartDate() &&
						rps.size() > 1
					) {
						servRecords.Operational_Two_Last_Quarters__c = true;
					} else {
						servRecords.Operational_Two_Last_Quarters__c = false;
					}
				}
				when 'Offline' {
					if (servRecords.Status_Date__c > getRPEndDate() && rps.size() > 1) {
						servRecords.Operational_Two_Last_Quarters__c = true;
					} else {
						servRecords.Operational_Two_Last_Quarters__c = false;
					}
				}
				when else {
					dohagedcare.Logger.warn('Invalid status').log();
				}
			}
		}

		if (!servicesMap.isEmpty()) {
			try {
				Database.update(servicesMap.values(), false);
			} catch (Exception ex) {
				dohagedcare.Logger.error(ex.getMessage(), ex, 'Star Rating').log();
			}
		}
	}

	/* This method updates checkbox that indicates if service has or has not been operational for last
	   full quarter in service object according to service's status.
       Logic: current quarter == Q4, hence we need start date from Q3 and end date from Q3. 
       If status is OPERATIONAL and service's status effective date < Q3 start date and active association start date < Q3 start date, 
	   then tick checkbox as service was operating in Q3 under its new provider.
       If status is OFFLINE and service's status effective date > Q3 end date, then tick checkbox as service was not operating in Q3.*/
	   public static Map<Id, Boolean> isOperationalForLastFullQuarter(List<BusinessLicense> services) {
		Map<Id, Boolean> isOperationalByServIdMap = new Map<Id, Boolean>();
		Map<Id, BusinessLicense> servicesMap = new Map<Id, BusinessLicense>(services);
		StarRatingUtil.cacheServiceAccRelationship(servicesMap.keySet());

		for (BusinessLicense servRecords : servicesMap.values()) {
			Boolean isOperational = null;
			switch on servRecords.Status__c {
				when 'Operational' {
					if (
						servRecords.Status_Date__c < getRPStartDateLastQuarter() &&
						StarRatingUtil.getServAccRelStartDate(servRecords.Id) < getRPStartDateLastQuarter()
					) {
						isOperational = true;
					} else {
						isOperational = false;
					}
				}
				when 'Offline' {
					if (servRecords.Status_Date__c > getRPEndDateQuarter()) {
						isOperational = true;
					} else {
						isOperational = false;
					}
				}
				when else {
					dohagedcare.Logger.warn('Invalid status').log();
				}
			}
			isOperationalByServIdMap.put(servRecords.Id, isOperational);
		}
		return isOperationalByServIdMap;
	}
}