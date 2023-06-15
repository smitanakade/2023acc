/*
 * @testClass AcfrLWCDatatableControllerTest
 */

/**
 * @description       :
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             :
 * @last modified on  : 03-15-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 **/
// Created by Ethan Sargent (ethan.sargent@health.gov.au)

public with sharing class AcfrLWCDatatableController {
	@AuraEnabled
	public static QFRDatatableDefinition getDatatableDefinitionForForm(
		Id recordId
	) {
		QFRDatatableDefinition datatableDef = new QFRDatatableDefinition();
		if (recordId == null) {
			return datatableDef;
		}

		Form__c form = [
			SELECT
				Type__c,
				QA_Outcome__c,
				Case__r.Status,
				Case__r.Quarter_Number__c,
				Account__r.Purpose__c
			FROM Form__c
			WHERE Id = :recordId
		];

		Set<Id> financialReportingRuleIds = new Set<Id>();
		Set<Id> serviceLineItemIds = new Set<Id>();
		Set<Id> glCodeIds = new Set<Id>();

		for (Financial_Reporting_Rule_Exemption__c item : [
			SELECT Id, Service__c, Financial_Reporting_Rule__c
			FROM Financial_Reporting_Rule_Exemption__c
			WHERE Form__c = :recordId AND Rule_Exemption_Status__c = TRUE
		]) {
			financialReportingRuleIds.add(item.Financial_Reporting_Rule__c);
			if (item.Service__c != null) {
				serviceLineItemIds.add(item.Service__c);
			}
		}

		datatableDef.formType = form?.Type__c;
		datatableDef.quarter = integer.valueOf(form?.Case__r.Quarter_Number__c);
		datatableDef.setIsReadOnly(form);

		List<Id> formIds = new List<Id>{ form?.Id };
		List<Service_Line_Item__c> serviceLineItems = getServiceLineItemsForForm(
				formIds
			)
			.get(form.Id);
		datatableDef.setColumnDefinitions(serviceLineItems, form.Type__c);

		List<GL_Code__c> glCodes = [
			SELECT
				Id,
				External_Name__c,
				Business_Id__c,
				Parent_GL_Code__r.Business_ID__c,
				Category__c,
				Line_Item_Value_Type__c,
				Display_Order__c,
				Calculation_Formula__c,
				Line_Item_Input_Length__c,
				Line_Item_Value_Options__c
			FROM GL_Code__c
			WHERE Type__c = :form.Type__c
			ORDER BY Display_Order__c
			LIMIT 50000
		];
		datatableDef.setRowDefinitions(glCodes);

		//get validation rules criteria and error message  from financial reporting rules record
		try {
			String accountPurpose = 'Government';
			List<Financial_Reporting_Rule_Details__c> frRules = new List<Financial_Reporting_Rule_Details__c>();
			if (form.Account__r.Purpose__c != accountPurpose) {
				frRules = [
					SELECT
						Id,
						GL_Code__c,
						GL_Code__r.Business_ID__c,
						GL_Code_Target__c,
						GL_Code_Target__r.Business_ID__c,
						RecordType.DeveloperName,
						Validation_Rule__c,
						Error_Message__c,
						Excluded_Service_Category__c,
						Source_Column__c,
						Target_Column__c,
						Financial_Reporting_Rule__r.Hard_Validation__c,
						Rule_Name__c,
						Financial_Reporting_Rule__c
					FROM Financial_Reporting_Rule_Details__c
					WHERE
						GL_Code__c != NULL
						AND Active__c = TRUE
						AND GL_Code__r.run_rules__c = TRUE
				];
				datatableDef.setFinancialReportingRules(frRules);
			} else if (form.Account__r.Purpose__c == accountPurpose) {
				Set<String> governmentValidation = new Set<String>{
					'Available bed days over 100',
					'Bed days must have food costs',
					'Occupied bed days must be less than or equal to available bed days.',
					'Total direct care minutes between 100-300 minutes',
					'Greater than zero non-worked hours',
					'Labour costs correlate with labour hours'
				};

				frRules = [
					SELECT
						Id,
						GL_Code__c,
						GL_Code__r.Business_ID__c,
						GL_Code_Target__c,
						GL_Code_Target__r.Business_ID__c,
						RecordType.DeveloperName,
						Validation_Rule__c,
						Error_Message__c,
						Excluded_Service_Category__c,
						Source_Column__c,
						Target_Column__c,
						Financial_Reporting_Rule__r.Hard_Validation__c,
						Rule_Name__c,
						Financial_Reporting_Rule__c
					FROM Financial_Reporting_Rule_Details__c
					WHERE
						GL_Code__c != NULL
						AND Active__c = TRUE
						AND GL_Code__r.run_rules__c = TRUE
						AND Financial_Reporting_Rule__r.Name IN :governmentValidation
				];
				datatableDef.setFinancialReportingRules(frRules);
			}

			for (Financial_Reporting_Rule_Details__c item : frRules) {
				if (
					financialReportingRuleIds.contains(
						item.Financial_Reporting_Rule__c
					)
				) {
					glCodeIds.add(item.GL_Code__c);
				}
			}

			Set<Id> glCodeLineItemIds = new Set<Id>();
			String qry =
				'SELECT Id ' +
				'FROM GL_Code_Line_Item__c ' +
				'WHERE GL_Code__c IN : glCodeIds ' +
				(!serviceLineItemIds.isEmpty()
					? 'AND Service_Line_Item__c IN : serviceLineItemIds'
					: '');

			for (GL_Code_Line_Item__c item : Database.query(qry)) {
				glCodeLineItemIds.add(item.Id);
			}
			if (!glCodeLineItemIds.isEmpty()) {
				datatableDef.setGLCodeLineItemsToBeExempted(glCodeLineItemIds);
			}
		} catch (Exception exc) {
			dohagedcare.logger.error(exc.getMessage(), exc, 'QFR').log();
		}
		return datatableDef;
	}

	@AuraEnabled
	public static Map<Id, QFRDatatableDefinition> getCrossFormRowDefinitions(
		Id recordId,
		List<String> glCodeBusinessIds
	) {
		Map<Id, QFRDatatableDefinition> datatableDefinitions = new Map<Id, QFRDatatableDefinition>();
		if (recordId == null) {
			return datatableDefinitions;
		}

		Case qfrCase = [
			SELECT
				Id,
				(
					SELECT Id, Type__c
					FROM Forms__r
					WHERE Id != :recordId
				)
			FROM Case
			WHERE
				Id IN (
					SELECT Case__c
					FROM Form__c
					WHERE Id = :recordId
				)
		];
		Map<Id, Form__c> allQFRForms = new Map<Id, Form__c>(qfrCase?.Forms__r);

		List<Id> formIds = new List<Id>(allQFRForms.keySet());
		Map<Id, List<Service_Line_Item__c>> serviceLineItemsByFormId = getServiceLineItemsForForm(
			formIds,
			glCodeBusinessIds
		);
		List<GL_Code__c> glCodes = [
			SELECT
				Id,
				External_Name__c,
				Business_Id__c,
				Parent_GL_Code__r.Business_ID__c,
				Category__c,
				Line_Item_Value_Type__c,
				Display_Order__c,
				Calculation_Formula__c,
				Line_Item_Input_Length__c,
				Line_Item_Value_Options__c,
				Type__c
			FROM GL_Code__c
			WHERE Business_Id__c IN :glCodeBusinessIds
			ORDER BY Display_Order__c
		];
		Map<String, List<GL_Code__c>> glCodesByType = new Map<String, List<GL_Code__c>>();
		for (GL_Code__c glCode : glCodes) {
			List<GL_Code__c> glCodesForType = glCodesByType.get(glCode.Type__c);
			if (glCodesForType == null) {
				glCodesForType = new List<GL_Code__c>();
				glCodesByType.put(glCode.Type__c, glCodesForType);
			}
			glCodesForType.add(glCode);
		}
		Map<Id, QFRDatatableDefinition> datatableDefinitionsByFormId = new Map<Id, QFRDatatableDefinition>();
		for (Id formId : allQFRForms.keySet()) {
			List<Service_Line_Item__c> slis = serviceLineItemsByFormId.get(
				formId
			);
			QFRDatatableDefinition datatableDefinition = datatableDefinitionsByFormId.get(
				formId
			);
			if (datatableDefinition == null) {
				datatableDefinition = new QFRDatatableDefinition();
				datatableDefinitionsByFormId.put(formId, datatableDefinition);
			}
			datatableDefinition.setColumnDefinitions(
				slis,
				allQFRForms.get(formId).Type__c
			);
			List<GL_Code__c> glCodesForForm = glCodesByType.get(
				allQFRForms.get(formId).Type__c
			);
			datatableDefinition.setRowDefinitions(glCodesForForm);
			datatableDefinition.setIsReadOnly(true);
		}

		return datatableDefinitionsByFormId;
	}

	private static Map<Id, List<Service_Line_Item__c>> getServiceLineItemsForForm(
		List<Id> formIds
	) {
		return getServiceLineItemsForForm(formIds, null);
	}

	private static Map<Id, List<Service_Line_Item__c>> getServiceLineItemsForForm(
		List<Id> formIds,
		List<String> glCodeBusinessIds
	) {
		Boolean businessIdFilterProvided = (glCodeBusinessIds != null &&
		glCodeBusinessIds.size() != 0);

		List<Service_Line_Item__c> serviceLineItems;
		if (businessIdFilterProvided) {
			serviceLineItems = [
				SELECT
					Id,
					Name,
					Active__c,
					Service_Category__c,
					Service__r.Name,
					Service__c,
					Service_Region__c,
					Form__c,
					(
						SELECT
							Id,
							Line_Item_Value__c,
							GL_Code__c,
							GL_Code__r.Business_Id__c,
							provider_explanation__c,
							QA_Outcome__c,
							QA_External_Comments__c
						FROM GL_Code_Line_Items__r
						WHERE GL_Code__r.Business_Id__c IN :glCodeBusinessIds
						ORDER BY GL_Code__r.Display_Order__c
					)
				FROM Service_Line_Item__c
				WHERE Form__c IN :formIds
				ORDER BY Name ASC
			];
		} else {
			serviceLineItems = [
				SELECT
					Id,
					Name,
					Active__c,
					Service_Category__c,
					Service__r.Name,
					Service__c,
					Service_Region__c,
					Form__c,
					(
						SELECT
							Id,
							Line_Item_Value__c,
							GL_Code__c,
							GL_Code__r.Business_Id__c,
							provider_explanation__c,
							QA_Outcome__c,
							QA_External_Comments__c
						FROM GL_Code_Line_Items__r
						ORDER BY GL_Code__r.Display_Order__c
					)
				FROM Service_Line_Item__c
				WHERE Form__c IN :formIds
				ORDER BY Name ASC
			];
		}
		Map<Id, List<Service_Line_Item__c>> serviceLineItemsByFormId = new Map<Id, List<Service_Line_Item__c>>();
		for (Service_Line_Item__c sli : serviceLineItems) {
			if (
				sli.GL_Code_Line_Items__r != null &&
				sli.GL_Code_Line_Items__r.size() != 0
			) {
				List<Service_Line_Item__c> result = serviceLineItemsByFormId.get(
					sli.Form__c
				);
				if (result == null) {
					result = new List<Service_Line_Item__c>();
					serviceLineItemsByFormId.put(sli.Form__c, result);
				}
				result.add(sli);
			}
		}
		for (
			List<Service_Line_Item__c> slis : serviceLineItemsByFormId.values()
		) {
			SObjectAccessDecision securityDecision = Security.stripInaccessible(
				AccessType.READABLE,
				slis
			);
			slis = (List<Service_Line_Item__c>) securityDecision.getRecords();
		}
		return serviceLineItemsByFormId;
	}

	@AuraEnabled
	public static void updateCells(String glCodeLineItemJson) {
		try {
			List<GL_Code_Line_Item__c> recordsForUpdate = (List<GL_Code_Line_Item__c>) JSON.deserialize(
				glCodeLineItemJson,
				List<GL_Code_Line_Item__c>.class
			);
			SObjectAccessDecision securityDecision = Security.stripInaccessible(
				AccessType.UPDATABLE,
				recordsForUpdate
			);
			update securityDecision.getRecords();
		} catch (Exception exc) {
			dohagedcare.logger.error(exc.getMessage(), exc, 'QFR').log();
			throw exc;
		}
	}

	@AuraEnabled
	public static void updateServices(String updateServiceJson) {
		try {
			List<Service_Line_Item__c> recordsForUpdate = (List<Service_Line_Item__c>) JSON.deserialize(
				updateServiceJson,
				List<Service_Line_Item__c>.class
			);
			SObjectAccessDecision securityDecision = Security.stripInaccessible(
				AccessType.UPDATABLE,
				recordsForUpdate
			);
			update securityDecision.getRecords();
		} catch (Exception exc) {
			dohagedcare.logger.error(exc.getMessage(), exc, 'QFR').log();
			throw exc;
		}
	}

	@AuraEnabled
	public static List<GL_Code_Line_Item__c> getQFRGLCodeItemData(
		List<String> businessId,
		List<String> serviceName,
		Id caseId
	) {
		return [
			SELECT Id, GL_Code__r.Business_ID__c, Line_Item_Value__c
			FROM GL_Code_Line_Item__c
			WHERE
				GL_Code__r.Business_ID__c IN :businessId
				AND Service_Line_Item__r.Service_Category__c IN :serviceName
				AND Service_Line_Item__r.Form__r.Case__r.Id = :caseId
		];
	}

	@AuraEnabled
	public static Id getQFRCaseId(Id formId) {
		return [
			SELECT Id
			FROM Case
			WHERE Id IN (SELECT Case__c FROM Form__c WHERE Id = :formId)
		]
		.Id;
	}

	public class AcfrCustomDatatableException extends Exception {
	}
}
