/*
 * @testClass AcfrSendRCOutcomeEmailTest
 */
public with sharing class AcfrSendRCOutcomeEmailBatch implements Database.Batchable<sObject> {
	public List<Service_Line_Item__c> start(Database.BatchableContext bc) {
		List<Service_Line_Item__c> serviceLineItems = [
			SELECT
				id,
				Form__c,
				Form__r.Case__c,
				Form__r.Case__r.AccountId,
				Service__r.Name,
				Reasonableness_Check_Outcome__c,
				Reasonableness_Check_Outcome_comments__c,
				Reasonableness_Check__c
			FROM service_line_item__c
			WHERE
				Reasonableness_Check_Outcome__c = 'For review'
				AND Form__r.Type__c = 'Residential Labour Costs and Hours'
				AND Date_last_notified__c = NULL
				AND Form__c != NULL
				AND Form__r.Case__c != NULL
			ORDER BY Form__r.Case__c ASC
		];

		return serviceLineItems;
	}

	public void execute(
		Database.BatchableContext bc,
		List<Service_Line_Item__c> scope
	) {
		List<Service_Line_Item__c> sliToUpdate = new List<Service_Line_Item__c>();
		if (scope.size() > 0) {
			Map<String, List<Service_Line_Item__c>> csSliMap = new Map<String, List<Service_Line_Item__c>>();
			List<String> accId = new List<String>();
			for (Service_Line_Item__c rec : scope) {
				rec.Date_last_notified__c = System.today();
				sliToUpdate.add(rec);
				accId.add(rec.Form__r.Case__r.AccountId);
				List<Service_Line_Item__c> recList = new List<Service_Line_Item__c>();
				if (csSliMap.get(rec.Form__r.Case__c) == null) {
					recList.add(rec);
				} else {
					recList = csSliMap.get(rec.Form__r.Case__c);
					recList.add(rec);
				}
				csSliMap.put(rec.Form__r.Case__c, recList);
			}
			List<Contact_Relationship__c> conRelList = [
				SELECT Id, Account__c, Contact__c, Contact__r.email, Role__c
				FROM Contact_Relationship__c
				WHERE
					Account__c IN :accId
					AND Contact__r.email != NULL
					AND Contact__r.email != ''
			];

			Map<Id, String> emailToAccMap = AcfrEmailService.getEmailToAccMap(
				conRelList,
				false,
				true,
				false,
				false
			);
			Map<Id, String> emailCCAccMap = AcfrEmailService.getEmailCCAccMap(
				conRelList,
				false,
				true,
				false,
				false,
				emailToAccMap
			);

			List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
			for (String caseId : csSliMap.keySet()) {
				String emailSubject = AcfrEmailService.getEmailSubject(
					caseId,
					'Case',
					'ACFR_RC_Outcome_Email'
				);
				String emailBody = [
					SELECT id, name, Subject, DeveloperName, HtmlValue, Body
					FROM EmailTemplate
					WHERE DeveloperName = 'ACFR_RC_Outcome_Email'
					LIMIT 1
				]
				.HtmlValue;
				emailBody = AcfrEmailService.mergeFields(
					emailBody,
					caseId,
					'Case'
				);
				emailBody = emailBody.replace(']]>', '');
				emailBody = emailBody.replace('{', '');
				emailBody = emailBody.replace('}', '');
				String serviceLineItemList = '<ul>';
				String toAddress;
				String ccAddress;
				for (Service_Line_Item__c rec : csSliMap.get(caseId)) {
					serviceLineItemList =
						serviceLineItemList +
						'<li><b>' +
						rec.Service__r.Name +
						' - ' +
						rec.Reasonableness_Check__c +
						'</b></li>';
					for (
						String val : rec.Reasonableness_Check_Outcome_comments__c.split(
							'\n'
						)
					) {
						serviceLineItemList =
							serviceLineItemList +
							'<p>' +
							val +
							'</p>';
					}
					if (toAddress == null || ccAddress == null) {
						toAddress = emailToAccMap.get(
							rec.Form__r.Case__r.AccountId
						);
						ccAddress = emailCCAccMap.get(
							rec.Form__r.Case__r.AccountId
						);
					}
				}
				serviceLineItemList = serviceLineItemList + '</ul>';
				emailBody = emailBody.replace(
					'SERVICELINEITEMLIST',
					serviceLineItemList
				);
				mails.add(
					AcfrEmailService.sendCustomMultipleEmailMethod(
						caseId,
						emailBody,
						toAddress,
						ccAddress,
						emailSubject
					)
				);
			}
			try {
				Messaging.sendEmail(mails);
				if (sliToUpdate.size() > 0) {
					Database.update(sliToUpdate);
				}
			} catch (Exception exp) {
				dohagedcare.Logger.error(
						exp.getMessage(),
						exp,
						'AcfrSendRCOutcomeEmailBatch'
					)
					.Log();
			}
		}
	}

	public void finish(Database.BatchableContext bc) {
		//Nothing required here
	}
}
