/**
 * @description       : This class will be the Batch class and Scheduler class for the bulk closure of quarterly cases
 * @author            : Cyrille Jeufo
 * @group             :
 * @last modified on  : 05-May-2022
 * @last modified by  : Cyrille Jeufo
 * @TestClass AcfrcaseLockSchedulerTest
 **/
public with sharing class AcfrCaseLockScheduler implements Schedulable, Database.Batchable<sObject> {

	public void execute(SchedulableContext context) {
		Database.executebatch(this, 100);
	}
	public Database.QueryLocator start(Database.BatchableContext bc) {
		Id accountRecordTypeId = Schema.Account.getSObjectType()
                                               .getDescribe()
                                               .getRecordTypeInfosByDeveloperName()
                                               .get('Approved_Provider')
                                               .getRecordTypeId();

        Id caseRecordTypeId = Schema.Case.getSObjectType()
                                         .getDescribe()
                                         .getRecordTypeInfosByDeveloperName()
                                         .get('QFR')
                                         .getRecordTypeId();

        //get cases
        return Database.getQueryLocator(
            [
                SELECT
                    Id,
                    AccountId,
                    QFR_RP_Locked__c
                FROM Case
                WHERE RecordTypeId= :caseRecordTypeId
                AND QFR_RP_Locked__c = false
                AND Reporting_Period__c IN(
                    SELECT 
                    Id
                    FROM Reporting_Period__c 
                    WHERE Reporting_Period_Type__c = 'Quarter' 
                    AND Previous_Reporting_Period__c = true 
                    AND QFR_Lock_Date__c = TODAY
                )
                AND AccountId IN (
                        SELECT Id
                        FROM Account
                        WHERE RecordTypeId =: accountRecordTypeId
                )
            ]
        );
	}

	public void execute(
		Database.BatchableContext bc,
		List<Case> caseList
	) {
        for(Case record : caseList){
            record.QFR_RP_Locked__c = true;
        }

		try {
			update caseList;
		} catch (DmlException exc) {
			dohagedcare.logger.error(exc.getMessage(), exc, 'QFR').log();
		}
	}

	public void finish(Database.BatchableContext bc) {
	}
}