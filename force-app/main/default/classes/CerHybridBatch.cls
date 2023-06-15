/*******************************************************************************************
 * @Name             CerHybridBatch
 * @testClass CerHybridBatchTest
 * @Author           Gabriel Piragibe Cova Leda de Almeida
 * @Date             03-04-2023
 * @Story#           TBD
 * @LWC Component    None
 * @Description		 Calculates CER rating
 *******************************************************************************************/
/* MODIFICATION LOG
 * Version       Developer                                Date                Description
 *-------------------------------------------------------------------------------------------
 *  1.0     	 Gabriel Piragibe Cova Leda de Almeida    01-03-2023          Initial Creation
 *******************************************************************************************/
public with sharing class CerHybridBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
	private Set<Id> cerIdsForRecalculation = new Set<Id>();
	private Set<Id> serviceIdsForRecalculation = new Set<Id>();
	private Boolean isPeriodicalCalc = false;

	public CerHybridBatch(Set<Id> cerIds, Set<Id> serviceIds) {
		this.cerIdsForRecalculation = cerIds;
		this.serviceIdsForRecalculation = serviceIds;
	}

	public CerHybridBatch(Boolean isPeriod) {
		this.isPeriodicalCalc = isPeriod;
	}

	private void recalculateOverallSRH(List<SRQI_CER__c> cerToUpdate) {
		Map<Id, SRQI_CER__c> cers = new Map<Id, SRQI_CER__c>(cerToUpdate);
		Map<Id, Id> mostRecenSRH = new Map<Id, Id>();
		// Select most recent SRH linked to cer
		for (STAR_Rating_History__c rec : [
			SELECT Id, Consumer_Experience_Id__c
			FROM Star_Rating_History__c
			WHERE Consumer_Experience_Id__c IN :cers.keySet()
			ORDER BY CreatedDate DESC
		]) {
			if (!mostRecenSRH.containsKey(rec.Consumer_Experience_Id__c)) {
				mostRecenSRH.put(rec.Consumer_Experience_Id__c, rec.Id);
			}
		}

		// Recalculate overall
		String procedureName = 'SRQI_StarRatingCalculation';
		for (Id rec : mostRecenSRH.values()) {
			Map<String, Object> ipOutput;
			Map<String, Object> ipInput = new Map<String, Object>();
			Map<String, Object> ipOptions = new Map<String, Object>();
			ipInput.put('SRHID', rec);
			ipInput.put('IsRecalc', true);
			ipOutput = (Map<String, Object>) omnistudio.IntegrationProcedureService.runIntegrationService(
				procedureName,
				ipInput,
				ipOptions
			);
		}
	}

	public Database.QueryLocator start(Database.BatchableContext bc) {
		if (!this.isPeriodicalCalc) {
			return Database.getQueryLocator(
				[
					SELECT
						Id,
						CER_Consent_Revoked__c,
						(
							SELECT Id, Total_CER_Score__c, Rating_Exemption_Reason__c, Rating_Exemption_Granted__c
							FROM Consumer_Experience_Reports__r
							WHERE Id IN :this.cerIdsForRecalculation
							LIMIT 1
						),
						(
							SELECT id, Reason__c
							FROM Service__r
							WHERE Active__c = TRUE AND RecordType.DeveloperName = 'CER_Exemption'
							LIMIT 1
						)
					FROM BusinessLicense
					WHERE Id IN :this.serviceIdsForRecalculation
				]
			);
		}

		return Database.getQueryLocator(
			[
				SELECT
					Id,
					CER_Consent_Revoked__c,
					(
						SELECT Id, Total_CER_Score__c, Rating_Exemption_Reason__c, Rating_Exemption_Granted__c
						FROM Consumer_Experience_Reports__r
						WHERE
							Quarterly_RP__r.Previous_Reporting_Period__c = TRUE
							AND Service_Account__r.Active__c = TRUE
							AND Extant__c = TRUE
						LIMIT 1
					),
					(
						SELECT id, Reason__c
						FROM Service__r
						WHERE Active__c = TRUE AND RecordType.DeveloperName = 'CER_Exemption'
						LIMIT 1
					)
				FROM BusinessLicense
				WHERE Status__c NOT IN ('Closed', 'Pre-operational') AND Operational_Two_Last_Quarters__c = TRUE
			]
		);
	}

	public void execute(Database.BatchableContext bc, List<BusinessLicense> scope) {
		List<SRQI_CER__c> cerToUpdate = new List<SRQI_CER__c>();
		for (BusinessLicense rec : scope) {
			if (rec.Consumer_Experience_Reports__r.isEmpty()) {
				continue;
			}

			for (SRQI_CER__c cerRecord : rec.Consumer_Experience_Reports__r) {
				cerRecord.Rating_Calc_Date__c = System.now();
				if (rec.CER_Consent_Revoked__c) {
					cerRecord.Consumer_Experience_Rating__c = 1;
					cerRecord.Rating_Exemption_Reason__c = null;
					cerRecord.Rating_Exemption_Granted__c = false;
				} else if (!rec.Service__r.isEmpty()) {
					cerRecord.Consumer_Experience_Rating__c = 0;
					cerRecord.Rating_Exemption_Reason__c = rec.Service__r[0].Reason__c;
					cerRecord.Rating_Exemption_Granted__c = true;
				} else {
					cerRecord.Consumer_Experience_Rating__c = CEIAlgorithmHelper.convertTotalCERScoreIntoStarRating(
						cerRecord
					);
					cerRecord.Rating_Exemption_Reason__c = null;
					cerRecord.Rating_Exemption_Granted__c = false;
				}

				cerToUpdate.add(cerRecord);
			}
		}

		if (!cerToUpdate.isEmpty()) {
			try {
				update cerToUpdate;
			} catch (Exception ex) {
				dohagedcare.Logger.error(ex.getMessage(), ex, 'recalculateCER - CEIAlgorithmHelper').Log();
			}
		}

		if (!this.isPeriodicalCalc) {
			recalculateOverallSRH(cerToUpdate);
		}
	}

	public void finish(Database.BatchableContext bc) {
		if (this.isPeriodicalCalc) {
			List<Reporting_Period__c> rpToUpdate = new List<Reporting_Period__c>();
			for (Reporting_Period__c rec : [
				SELECT Id, CER_Calculated__c
				FROM Reporting_Period__c
				WHERE Previous_Reporting_Period__c = TRUE AND Reporting_Period_Type__c = 'Quarter'
				LIMIT 1
			]) {
				rec.CER_Calculated__c = true;
				rpToUpdate.add(rec);
			}

			if (!rpToUpdate.isEmpty()) {
				try {
					update rpToUpdate;
				} catch (Exception ex) {
					dohagedcare.Logger.error(ex.getMessage(), ex, 'CerHybridBatch - finish method').Log();
				}
			}
		}
	}
}