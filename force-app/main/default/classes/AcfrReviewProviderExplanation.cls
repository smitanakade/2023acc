/* @TestClass AcfrReviewProviderExplanationTest */
public with sharing class AcfrReviewProviderExplanation {
	public static final String ACCEPTED_OUTCOME = 'Accepted' + ',' + 'Review';

	@AuraEnabled(cacheable=true)
	public static List<responsesWrapper> getProviderExplanation(Id recordId) {
		Set<Id> glCodeIds = new Set<Id>();
		String formType = getFormType(recordId);
		List<ResponsesWrapper> responsesWrap = new List<ResponsesWrapper>();

		if (getFormType(recordId) != null) {
			for (Financial_Reporting_Rule_Details__c getRuleDetails : [
				SELECT Id, Error_Message__c, Rule_Name__c, GL_Code__c
				FROM Financial_Reporting_Rule_Details__c
				WHERE
					GL_Code__c != NULL
					AND Financial_Reporting_Rule__r.Form_Type__c = :formType
			]) {
				glCodeIds.add(getRuleDetails.GL_Code__c);
			}

			List<Financial_Reporting_Rule_Details__c> finRuleDetails = [
				SELECT Id, Rule_Name__c, Error_Message__c, GL_Code__c
				FROM Financial_Reporting_Rule_Details__c
				WHERE
					GL_Code__c != NULL
					AND Financial_Reporting_Rule__r.Form_Type__c = :formType
			];

			for (GL_Code_Line_Item__c glItem : [
				SELECT
					Id,
					Service_Line_item__r.Service_Label__c,
					Line_Item_Value__c,
					provider_explanation__c,
					QA_Outcome__c,
					QA_External_Comments__c,
					Amended_Explanation__c,
					GL_Code__c
				FROM GL_Code_Line_Item__c
				WHERE
					provider_explanation__c != NULL
					AND GL_Code__c IN :glCodeIds
					AND service_line_item__r.Form__r.Id = :recordId
				ORDER BY QA_Outcome__c
			]) {
				for (Financial_Reporting_Rule_Details__c f : finRuleDetails) {
					if (glItem.GL_Code__c == f.GL_Code__c) {
						ResponsesWrapper responses = new ResponsesWrapper();
						responses.glcodelineitemId = glItem.Id;
						responses.errorMessage = f.Error_Message__c;
						responses.validationRule = f.Rule_Name__c;
						responses.dataInput = glItem.Line_Item_Value__c;
						responses.serviceName = glItem.Service_Line_item__r.Service_Label__c;
						responses.providerExplanation = glItem.provider_explanation__c;
						responses.qaOutcome = glItem.QA_Outcome__c;
						responses.qaExternalComments = glItem.QA_External_Comments__c;
						responses.amendedExplanation = glItem.Amended_Explanation__c;
						responses.glCodeId = glItem.GL_Code__c;
						responsesWrap.add(responses);
					}
				}
			}
		}
		return responsesWrap;
	}

	@AuraEnabled(cacheable=true)
	public static List<GL_Code_Line_Item__c> getRejectedProviderExplanation(
		Id recordId
	) {
		return [
			SELECT Id, QA_External_Comments__c
			FROM GL_Code_Line_Item__c
			WHERE
				provider_explanation__c != NULL
				AND QA_Outcome__c NOT IN ('Accepted', 'Review')
				AND service_line_item__r.Form__r.Id = :recordId
			ORDER BY QA_Outcome__c
		];
	}

	public static string getFormType(Id recordId) {
		string formType = '';
		List<Form__c> getForms = [
			SELECT Type__c
			FROM Form__c
			WHERE Id = :recordId
		];
		if (getForms.size() > 0) {
			formType = getForms[0].Type__c;
		}
		return formType;
	}

	public class ResponsesWrapper {
		@AuraEnabled
		public Id glcodelineitemId { get; set; }
		@AuraEnabled
		public String errorMessage { get; set; }
		@AuraEnabled
		public String validationRule { get; set; }
		@AuraEnabled
		public String serviceName { get; set; }
		@AuraEnabled
		public String dataInput { get; set; }
		@AuraEnabled
		public String providerExplanation { get; set; }
		@AuraEnabled
		public String qaOutcome { get; set; }
		@AuraEnabled
		public String qaExternalComments { get; set; }
		@AuraEnabled
		public String amendedExplanation { get; set; }
		@AuraEnabled
		public Id glCodeId { get; set; }
	}
}
