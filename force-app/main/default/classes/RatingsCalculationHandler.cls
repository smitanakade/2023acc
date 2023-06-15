/**
 * author: Daniel Clift
 * date: 18/08/2022
 * description: checks if ratings calculations are required, passes to true conditions to IntegrationProcedureHandler, which calls omnistudio integration procedure(s)
 * @testClass RatingsCalculationHandlerTest
 **/

public with sharing class RatingsCalculationHandler {
	// Initiale Variables
	@TestVisible
	public static date cmCalcDate;
	@TestVisible
	public static date qiCalcDate;
	@TestVisible
	public static date cerCalcDate;
	@TestVisible
	public static date srhCalcDate;

	public static void executeHandler() {
		Set<String> algorithms = new Set<String>{ 'CER', 'QI', 'CM' };
		Set<String> algorithmsCompleted = new Set<String>();
		List<Reporting_Period__c> rPeriods = [
			SELECT
				Id,
				Reporting_Period_Type__c,
				CER_Calc_Date__c,
				CM_Calc_Date__c,
				QI_Calc_Date__c,
				StarRating_Calc_Date__c,
				CM_Calculated__c,
				CER_Calculated__c,
				QI_Calculated__c
			FROM Reporting_Period__c
			WHERE Previous_Reporting_Period__c = TRUE AND Reporting_Period_Type__c = 'Quarter'
			LIMIT 1
		];

		try {
			for (Reporting_Period__c rPeriod : rPeriods) {
				cmCalcDate = rPeriod.CM_Calc_Date__c;
				qiCalcDate = rPeriod.QI_Calc_Date__c;
				cerCalcDate = rPeriod.CER_Calc_Date__c;
				srhCalcDate = rPeriod.StarRating_Calc_Date__c;
				if (rPeriod.CER_Calculated__c) {
					algorithmsCompleted.add('CER');
				}

				if (rPeriod.CM_Calculated__c) {
					algorithmsCompleted.add('CM');
				}

				if (rPeriod.QI_Calculated__c) {
					algorithmsCompleted.add('QI');
				}
			}

			// run method to check if rating calculation is required
			if (algorithmsCompleted.containsAll(algorithms)) {
				checkSRHDate();
			} else {
				checkCalcDates();
			}
		} catch (Exception exp) {
			dohagedcare.Logger.error(exp.getMessage(), exp, 'RatingsCalculationHandler').Log();
		}
	}

	public static void checkCalcDates() {
		// if care minutes requires calc today
		if (cmCalcDate == System.today() || qiCalcDate == System.today() || cerCalcDate == System.today()) {
			RatingsCalculationService.starRatingRecords();

			if (cmCalcDate == System.today()) {
				IntegrationProcedureHandler ipHandler = new IntegrationProcedureHandler(
					IntegrationProcedureHandler.RUNCM
				);
				ipHandler.executeIp();
			}
			// if quality indicator requires calc today
			if (qiCalcDate == System.today()) {
				Database.executeBatch(new QIObservedBatch());
			}
			// if consumer experience report requires calc today
			if (cerCalcDate == System.today()) {
				Database.executeBatch(new CEIAlgorithmBatch());
			}
		}
	}

	public static void checkSRHDate() {
		Boolean cerHasRun = false;
		Boolean cmHasRun = false;
		Boolean qiHasRun = false;
		List<Reporting_Period__c> rPeriods = [
			SELECT
				Id,
				Reporting_Period_Type__c,
				CER_Calc_Date__c,
				CM_Calc_Date__c,
				QI_Calc_Date__c,
				StarRating_Calc_Date__c,
				CM_Calculated__c,
				CER_Calculated__c,
				QI_Calculated__c
			FROM Reporting_Period__c
			WHERE Previous_Reporting_Period__c = TRUE AND Reporting_Period_Type__c = 'Quarter'
			LIMIT 1
		];

		for (Reporting_Period__c rPeriod : rPeriods) {
			srhCalcDate = rPeriod.StarRating_Calc_Date__c;
			if (rPeriod.CER_Calculated__c == true) {
				cerHasRun = true;
			}

			if (rPeriod.CM_Calculated__c == true) {
				cmHasRun = true;
			}

			if (rPeriod.QI_Calculated__c == true) {
				qiHasRun = true;
			}
		}

		/*overall star rating batch
		 *this is also called by a trigger, on reporting period
		 */
		if (srhCalcDate == System.today() && cerHasRun == true && cmHasRun == true && qiHasRun == true) {
			try {
				Database.executeBatch(new SRHCalcPrepBatch());
			} catch (Exception exp) {
				dohagedcare.Logger.error(exp.getMessage(), exp, 'RatingsCalculationHandler - SRHCalcPrepBatch').Log();
			}
		}
	}
}