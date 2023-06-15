/*****************************************
 *@Author        :Mark Daniel B. Alagdon
 *@Company       :Accenture
 *@Description   :This class will handle the logic of financial reporting rules
 *@Test Class    :FinancialReportingRulesControllerTest
 *@Date:N/A
 *@Revision:
 *When                 Who                       What
 *06-Jan-2023          Mark Daniel B. Alagdon   Created
 *15-Feb-2023		  Cla Capagas			   Modified
 *20-Apr-2023          CJJoya                   Modified without sharing PBI #371449
 *****************************************/
public with sharing class FinancialReportingRulesController {
	public static String strTypePicklist = 'Picklist';
	public static String strTotal = 'Total';
	/**
	 @description: this method will invoke when GL_Code_Line_Item__c values are updated
    **/
	public static void runQFRRules(
		Map<Id, GL_Code_Line_Item__c> glCodeLineItemMap,
		Map<Id, GL_Code_Line_Item__c> glCodeLineItemOldMap
	) {
		try {
			List<GL_Code_Line_Item__c> glCodeLineItemList = glCodeLineItemMap.values();
			Set<Id> glCodeLineItemIds = new Set<Id>();

			for (GL_Code_Line_Item__c glCodeItem : glCodeLineItemList) {
				GL_Code_Line_Item__c oldItem = glCodeLineItemOldMap.get(
					glCodeItem.Id
				);
				//get all updated line item value which glcode and servicelineitem is not blank and numeric type
				if (
					oldItem.Line_Item_Value__c !=
					glCodeItem.Line_Item_Value__c &&
					String.isNotBlank(glCodeItem.GL_Code__c) &&
					String.isNotBlank(glCodeItem.Service_Line_Item__c) &&
					isNumeric(glCodeItem.Line_Item_Value__c)
				) {
					glCodeLineItemIds.add(glCodeItem.Id);
				}
			}

			if (!glCodeLineItemIds.isEmpty()) {
				List<GL_Code_Line_Item__c> glCodeLineItemToUpdateList = getValidatedGlCodeLineItems(
					glCodeLineItemIds
				);

				if (!glCodeLineItemToUpdateList.isEmpty()) {
					updateGlCodeLineItems(glCodeLineItemToUpdateList);
				}
			}
		} catch (Exception ex) {
			dohagedcare.Logger.error(
					ex.getMessage(),
					ex,
					'QFR - FinancialReportingRulesController.runQFRRules'
				)
				.Log();
		}
	}

	/**
	 @description: this method will validate numeric values
    **/
	public static Boolean isNumeric(String val) {
		Boolean returnValue;
		if (String.isNotBlank(val)) {
			try {
				Decimal.valueOf(val);
				returnValue = true;
			} catch (Exception ex) {
				returnValue = false;
			}
		} else {
			returnValue = true;
		}

		return returnValue;
	}

	/** Map<GLCodeId, Map<CaseId, Map<ServiceId, GLCodeLineItem>>> **/
	public static Map<String, Map<Id, Map<Id, GL_Code_Line_Item__c>>> srcGLCodeLineItemByGLCodeIdMap = new Map<String, Map<Id, Map<Id, GL_Code_Line_Item__c>>>();
	/** Map<CaseId, Map<ServiceId, GLCodeLineItem>> **/
	public static Map<Id, Map<Id, GL_Code_Line_Item__c>> srcGLCodeLineItemByCaseIdMap = new Map<Id, Map<Id, GL_Code_Line_Item__c>>();
	/** Map<ServiceId, GLCodeLineItem> **/
	public static Map<Id, GL_Code_Line_Item__c> srcGLCodeLineItemMap = new Map<Id, GL_Code_Line_Item__c>();
	public static Set<Id> serviceIds = new Set<Id>();
	public static Set<Id> caseIds = new Set<Id>();
	/**
	 @description: this method will validate the updated glCodeLineItems if has associated financial rules
	**/
	public static List<GL_Code_Line_Item__c> getValidatedGlCodeLineItems(
		Set<Id> glCodeLineItemIds
	) {
		List<GL_Code_Line_Item__c> glCodeLineItemsList = new List<GL_Code_Line_Item__c>();

		for (GL_Code_Line_Item__c sourceItem : [
			SELECT
				Id,
				Line_Item_Value__c,
				GL_Code__c,
				GL_Code__r.Business_ID__c,
				Service_Line_Item__c,
				Service_Line_Item__r.Form__c,
				Service_Line_Item__r.Form__r.Case__c,
				Service_Line_Item__r.Service__c
			FROM GL_Code_Line_Item__c
			WHERE
				Id IN :glCodeLineItemIds
				AND GL_Code__r.run_rules__c = TRUE
				AND GL_Code__r.Business_ID__c != NULL
				AND Service_Line_Item__r.Service__c != NULL
				AND Service_Line_Item__r.Form__r.Case__c != NULL
				AND Service_Line_Item__r.Service_Label__c != :strTotal
				AND GL_Code__r.Line_Item_Value_Type__c != :strTypePicklist
		]) {
			GL_Code__c glCode = sourceItem.GL_Code__r;
			Service_Line_Item__c serviceLineItem = sourceItem.Service_Line_Item__r;
			Id caseId = serviceLineItem.Form__r.Case__c;

			srcGLCodeLineItemByCaseIdMap = srcGLCodeLineItemByGLCodeIdMap.get(
				glCode.Business_ID__c
			);
			if (srcGLCodeLineItemByCaseIdMap == null) {
				srcGLCodeLineItemByCaseIdMap = new Map<Id, Map<Id, GL_Code_Line_Item__c>>{};
				srcGLCodeLineItemByGLCodeIdMap.put(
					glCode.Business_ID__c,
					srcGLCodeLineItemByCaseIdMap
				); //list of caseId by glcodeid
			}

			srcGLCodeLineItemMap = srcGLCodeLineItemByCaseIdMap.get(caseId);
			if (srcGLCodeLineItemMap == null) {
				srcGLCodeLineItemMap = new Map<Id, GL_Code_Line_Item__c>{};
				srcGLCodeLineItemByCaseIdMap.put(caseId, srcGLCodeLineItemMap); //list of serviceId by caseId
			}

			GL_Code_Line_Item__c gli = srcGLCodeLineItemMap.get(
				serviceLineItem.Service__c
			);
			if (gli == null) {
				srcGLCodeLineItemMap.put(
					serviceLineItem.Service__c,
					sourceItem
				); //glcodelineitem by serviceId
			}
			serviceIds.add(serviceLineItem.Service__c);
			caseIds.add(caseId);
		}

		if (!srcGLCodeLineItemByGLCodeIdMap.isEmpty()) {
			getFRRulesByGlCodeId();
			if (!rulesByTargetGlCodeIdMap.isEmpty()) {
				glCodeLineItemsList = updateTargetGlCodeLineItems();
			}
		}

		return glCodeLineItemsList;
	}

	/** Map<FinancialReportingRule.TargetGLCodeId, Map<FinancialReportingRule.GlCodeId, FinancialReportingRule>> **/
	public static Map<String, Map<String, Financial_Reporting_Rule_Details__c>> rulesByTargetGlCodeIdMap = new Map<String, Map<String, Financial_Reporting_Rule_Details__c>>();
	/** Map<FinancialReportingRule.GlCodeId, FinancialReportingRule>**/
	public static Map<String, Financial_Reporting_Rule_Details__c> ruleBySourceGLCodeIdMap = new Map<String, Financial_Reporting_Rule_Details__c>();
	/**
	 @description: this method will check if glcodelineitems are linked to active financial rules
	**/
	public static void getFRRulesByGlCodeId() {
		Id financialRepRuleDuplicateTypeId = Schema.SObjectType.Financial_Reporting_Rule_Details__c.getRecordTypeInfosByDeveloperName()
			.get('Duplicate_Value_Reference')
			.getRecordTypeId();
		Set<String> validGLCodeIds = new Set<String>();

		//get all glcode and glcodetarget with active duplicate rules
		for (Financial_Reporting_Rule_Details__c frrd : [
			SELECT
				Id,
				GL_Code__c,
				GL_Code_Target__c,
				GL_Code__r.Business_ID__c,
				GL_Code_Target__r.Business_ID__c
			FROM Financial_Reporting_Rule_Details__c
			WHERE
				RecordTypeId = :financialRepRuleDuplicateTypeId
				AND GL_Code__r.Business_ID__c IN :srcGLCodeLineItemByGLCodeIdMap.keySet()
				AND GL_Code_Target__r.Business_ID__c != NULL
				AND Active__c = TRUE
		]) {
			String sourceGlCodeId = frrd.GL_Code__r.Business_ID__c;
			String targetGlCodeId = frrd.GL_Code_Target__r.Business_ID__c;
			if (rulesByTargetGlCodeIdMap.containsKey(targetGlCodeId)) {
				ruleBySourceGLCodeIdMap.putAll(
					rulesByTargetGlCodeIdMap.get(targetGlCodeId)
				);
			}
			ruleBySourceGLCodeIdMap.put(sourceGlCodeId, frrd); //list of financial reporting rules by glCodeId(source)
			rulesByTargetGlCodeIdMap.put(
				targetGLCodeId,
				ruleBySourceGLCodeIdMap
			); //list of glcodeId(source) by glcodeId(target)

			//get all validGLCodeIds which has active financial reporting duplicate rules
			validGLCodeIds.add(sourceGlCodeId);
		}

		//get the list of valid source glcodelineitem which glcode has active duplicate rules
		for (String glCodeId : srcGLCodeLineItemByGLCodeIdMap.keySet()) {
			if (!validGLCodeIds.contains(glCodeId)) {
				srcGLCodeLineItemByGLCodeIdMap.remove(glCodeId);
			}
		}
	}

	/**
     @description: this method will update the target glCodeLineItem base on the value of source glCodeLineItem
    **/
	public static List<GL_Code_Line_Item__c> updateTargetGlCodeLineItems() {
		List<GL_Code_Line_Item__c> updatedTargetGlCodeLineItems = new List<GL_Code_Line_Item__c>();
		for (GL_Code_Line_Item__c targetGLI : [
			SELECT
				Id,
				Line_Item_Value__c,
				GL_Code__c,
				GL_Code__r.Business_ID__c,
				Service_Line_Item__c,
				Service_Line_Item__r.Form__c,
				Service_Line_Item__r.Form__r.Case__c,
				Service_Line_Item__r.Service__c
			FROM GL_Code_Line_Item__c
			WHERE
				GL_Code__r.Business_ID__c IN :rulesByTargetGlCodeIdMap.keySet()
				AND GL_Code__r.run_rules__c = TRUE
				AND Service_Line_Item__r.Service__c IN :serviceIds
				AND Service_Line_Item__r.Form__r.Case__c IN :caseIds
				AND Service_Line_Item__r.Service_Label__c != :strTotal
				AND GL_Code__r.Line_Item_Value_Type__c != :strTypePicklist
		]) {
			String glCodeId = targetGLI.GL_Code__r.Business_ID__c;
			Service_Line_Item__c targetServiceLineItem = targetGLI.Service_Line_Item__r;
			Id caseId = targetServiceLineItem.Form__r.Case__c;

			ruleBySourceGLCodeIdMap = rulesByTargetGlCodeIdMap.get(glCodeId);
			if (ruleBySourceGLCodeIdMap == null) {
				continue;
			}
			for (String sourceGLCodeId : ruleBySourceGLCodeIdMap.KeySet()) {
				GL_Code_Line_Item__c sourceGLI = getSourceGlCodeLineItem(
					sourceGLCodeId,
					caseId,
					targetServiceLineItem.Service__c
				);
				Boolean isActiveRule = false;
				if (sourceGLI != null) {
					GL_Code__c sourceGLCode = sourceGLI.GL_Code__r;
					Financial_Reporting_Rule_Details__c frr = ruleBySourceGLCodeIdMap.get(
						sourceGLCode.Business_ID__c
					);
					isActiveRule = (frr != null &&
					targetGLI.GL_Code__c == frr.GL_Code_Target__c &&
					sourceGLCode.Id == frr.GL_Code__c &&
					targetGLI.Line_Item_Value__c !=
					sourceGLI.Line_Item_Value__c);
				}

				if (isActiveRule) {
					targetGLI.Line_Item_Value__c = sourceGLI.Line_Item_Value__c;
					updatedTargetGlCodeLineItems.add(targetGLI);
				}
			}
		}
		return updatedTargetGlCodeLineItems;
	}

	public static GL_Code_Line_Item__c getSourceGlCodeLineItem(
		String sourceGLCodeId,
		String caseId,
		String targetServiceId
	) {
		GL_Code_Line_Item__c sourceGlCodeLineItemResult = new GL_Code_Line_Item__c();
		srcGLCodeLineItemByCaseIdMap = srcGLCodeLineItemByGLCodeIdMap.get(
			sourceGLCodeId
		);
		if (srcGLCodeLineItemByCaseIdMap != null) {
			srcGLCodeLineItemMap = srcGLCodeLineItemByCaseIdMap.get(caseId);
			if (srcGLCodeLineItemMap != null) {
				sourceGlCodeLineItemResult = srcGLCodeLineItemMap.get(
					targetServiceId
				);
			}
		}
		return sourceGlCodeLineItemResult;
	}

	/**
	 @description: this method will update the list of glcodelineitem
	**/
	public static void updateGlCodeLineItems(
		List<GL_Code_Line_Item__c> glCodeLineItemsToUpdate
	) {
		Database.SaveResult[] srList = database.update(
			glCodeLineItemsToUpdate,
			false
		);
		// Iterate through each returned result
		for (Database.SaveResult sr : srList) {
			if (!sr.isSuccess()) {
				// Operation failed, so get all errors
				for (Database.Error err : sr.getErrors()) {
					dohagedcare.logger.error(
							err.getMessage(),
							null,
							'QFR - FinancialReportingRulesController.updateGlCodeLineItems'
						)
						.log();
				}
			}
		}
	}
}
