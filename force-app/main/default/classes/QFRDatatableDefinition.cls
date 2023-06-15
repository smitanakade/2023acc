/**
 * @author Ethan Sargent
 * @description Defines the behaviour of the QFR Provider Portal datatable
 */
@JsonAccess(serializable='always' deserializable='always')
public inherited sharing class QFRDatatableDefinition {
	@AuraEnabled
	public List<RowDefinition> rowDefinitions = new List<RowDefinition>();
	@AuraEnabled
	public List<ColumnDefinition> columnDefinitions = new List<ColumnDefinition>();
	@AuraEnabled
	public List<FinancialReportingRule> financialReportingRules = new List<FinancialReportingRule>();
	@AuraEnabled
	public Boolean isReadOnly { get; private set; }
	@AuraEnabled
	public List<Id> glCodeLineItemsToBeExempted = new List<Id>();

	public void setIsReadOnly(Form__c form) {
		Set<String> EDITABLE_CASE_STATUSES = new Set<String>{ 'New', 'Draft' };

		this.isReadOnly = !(EDITABLE_CASE_STATUSES.contains(
			form.Case__r.Status
		) ||
		(form.Case__r.Status == 'Reissued' &&
		form.QA_Outcome__c == 'Re-Issue'));
	}
	public void setIsReadOnly(Boolean isReadOnly) {
		this.isReadOnly = isReadOnly;
	}

	@AuraEnabled
	public String formType;
	@AuraEnabled
	public Integer quarter;

	public void setRowDefinitions(List<GL_Code__c> glCodes) {
		this.rowDefinitions = new List<RowDefinition>();
		if (glcodes == null) {
			return;
		}
		for (GL_Code__c glCode : glCodes) {
			this.rowDefinitions.add(new RowDefinition(glCode));
		}
	}

	public void setColumnDefinitions(
		List<Service_Line_Item__c> serviceLineItems,
		String formType
	) {
		// show Total first
		this.columnDefinitions = new List<ColumnDefinition>();
		if (serviceLineItems == null) {
			return;
		}
		List<ColumnDefinition> cols = new List<ColumnDefinition>();
		for (Service_Line_Item__c lineItem : servicelineitems) {
			if (
				lineItem.Service__r.Name == 'Total' ||
				lineItem.Service_Category__c == 'Total'
			) {
				// Add Total to this.columnDefinitions straight away to ensure it's the first element
				this.columnDefinitions.add(
					new ColumnDefinition(lineItem, formType)
				);
			} else {
				cols.add(new ColumnDefinition(lineItem, formType));
			}
		}
		// add the rest of the columns into the array
		this.columnDefinitions.addAll(cols);
	}

	public void setGLCodeLineItemsToBeExempted(Set<Id> glCodeItemIds) {
		this.glCodeLineItemsToBeExempted.addAll(glCodeItemIds);
	}

	public void setFinancialReportingRules(
		List<Financial_Reporting_Rule_Details__c> frRules
	) {
		List<FinancialReportingRule> frRuleList = new List<FinancialReportingRule>();
		for (Financial_Reporting_Rule_Details__c frRule : frRules) {
			frRuleList.add(new FinancialReportingRule(frRule));
		}
		this.financialReportingRules = frRuleList;
	}

	@JsonAccess(serializable='always' deserializable='always')
	public inherited sharing class RowDefinition {
		@AuraEnabled
		public String id { get; set; }
		@AuraEnabled
		public String name { get; set; }
		@AuraEnabled
		public String parentRowId { get; set; }
		@AuraEnabled
		public String category { get; set; }
		@AuraEnabled
		public String type { get; set; }
		@AuraEnabled
		public Double order { get; set; }
		@AuraEnabled
		public String formula_string { get; set; }
		@AuraEnabled
		public Double precision { get; set; }
		@AuraEnabled
		public List<LineItemValueOption> lineItemValueOptions;

		public RowDefinition() {
		}

		public RowDefinition(GL_Code__c glCode) {
			this.id = !String.isBlank(glCode.Business_ID__c)
				? glCode.Business_ID__c
				: glCode.Id;
			this.name = glCode.External_Name__c;
			this.parentRowId = !String.isBlank(
					glCode.Parent_GL_Code__r.Business_ID__c
				)
				? glCode.Parent_GL_Code__r.Business_ID__c
				: glCode.Parent_GL_Code__r.Id;
			this.category = glCode.Category__c;
			this.type = glCode.Line_Item_Value_Type__c;
			this.order = glCode.Display_Order__c;
			this.formula_string = glCode.Calculation_Formula__c;
			this.precision = glCode.Line_Item_Input_Length__c;
			this.lineItemValueOptions = new List<LineItemValueOption>();

			if (glCode.Line_Item_Value_Options__c != null) {
				for (
					String strOption : glCode.Line_Item_Value_Options__c.split(
						';'
					)
				) {
					this.lineItemValueOptions.add(
						new LineItemValueOption(strOption)
					);
				}
			}
		}
	}

	@JsonAccess(serializable='always' deserializable='always')
	public inherited sharing class LineItemValueOption {
		@AuraEnabled
		public String label { get; set; }
		@AuraEnabled
		public String value { get; set; }

		public LineItemValueOption() {
		}

		public LineItemValueOption(String valueOption) {
			this.label = valueOption;
			this.value = valueOption;
		}
	}

	@JsonAccess(serializable='always' deserializable='always')
	public inherited sharing class ColumnDefinition {
		@AuraEnabled
		public Id id { get; set; }
		@AuraEnabled
		public String name { get; set; }
		@AuraEnabled
		public Boolean isEnabled { get; set; }
		@AuraEnabled
		public Boolean isToggled { get; set; }
		@AuraEnabled
		public List<TableCell> data = new List<TableCell>();

		public ColumnDefinition() {
		}

		public ColumnDefinition(
			Service_Line_Item__c serviceLineItem,
			String formType
		) {
			this.Id = serviceLineItem.Id;

			if (
				serviceLineItem.Service__r?.Name != null &&
				serviceLineItem.Service_region__c == null
			) {
				this.name = serviceLineItem.Service__r.Name;
			} else if (serviceLineItem.Service_region__c != null) {
				this.name = serviceLineItem.Service_region__c;
			} else {
				this.name = serviceLineItem.Service_Category__c;
			}
			this.isEnabled = serviceLineItem.Active__c;
			this.isToggled = this.formEntryTypesByCategory(formType)
				?.get(serviceLineItem.Service_Category__c)
				?.Allow_Toggle__c;

			this.data = new List<TableCell>();
			for (
				GL_Code_Line_Item__c cell : serviceLineItem.GL_Code_Line_Items__r
			) {
				this.data.add(new TableCell(cell));
			}
		}

		private Map<String, Form_Entry_Type__mdt> formEntryTypesByCategory(
			String formType
		) {
			Map<String, Form_Entry_Type__mdt> formEntryByDeveloperName = new Map<String, Form_Entry_Type__mdt>(
				[
					SELECT
						Allow_Toggle__c,
						Category__c,
						Category_applied__c,
						Form_Entity_Definition__c,
						Form_Entry_Type__c,
						Form_Type__c,
						Id,
						Service_Region_applied__c
					FROM Form_Entry_Type__mdt
					WHERE Form_Type__c = :formType
				]
			);

			Map<String, Form_Entry_Type__mdt> formEntriesByCategory = new Map<String, Form_Entry_Type__mdt>();
			for (
				Form_Entry_Type__mdt entry : formEntryByDeveloperName.values()
			) {
				formEntriesByCategory.put(entry.Category__c, entry);
			}
			return formEntriesByCategory;
		}
	}

	@JsonAccess(serializable='always' deserializable='always')
	public inherited sharing class TableCell {
		@AuraEnabled
		public Id id { get; set; }
		@AuraEnabled
		public String value { get; set; }
		@AuraEnabled
		public String providerExplanation { get; set; }
		@AuraEnabled
		public String qaOutcome { get; set; }
		@AuraEnabled
		public String qaComments { get; set; }
		@AuraEnabled
		public String rowDefinitionId { get; set; }

		public TableCell() {
		}

		public TableCell(GL_Code_Line_Item__c cell) {
			this.Id = cell.Id;
			this.value = cell.Line_Item_Value__c;
			this.providerExplanation = cell.provider_explanation__c;
			this.qaOutcome = cell.QA_Outcome__c;
			this.qaComments = cell.QA_External_Comments__c;
			this.rowDefinitionId = !String.isBlank(
					cell.GL_Code__r.Business_ID__c
				)
				? cell.GL_Code__r.Business_ID__c
				: cell.GL_Code__c;
		}
	}

	@JsonAccess(serializable='always' deserializable='always')
	public inherited sharing class FinancialReportingRule {
		@AuraEnabled
		public Id id { get; set; }
		@AuraEnabled
		public String glCode { get; set; }
		@AuraEnabled
		public String glCodeTarget { get; set; }
		@AuraEnabled
		public String type { get; set; }
		@AuraEnabled
		public String validationRule { get; set; }
		@AuraEnabled
		public String errorMessage { get; set; }
		@AuraEnabled
		public String serviceCategoryExcluded { get; set; }
		@AuraEnabled
		public String sourceColumn { get; set; }
		@AuraEnabled
		public String targetColumn { get; set; }
		@AuraEnabled
		public Boolean hardValidation { get; set; }

		public FinancialReportingRule() {
		}

		public FinancialReportingRule(
			Financial_Reporting_Rule_Details__c frRule
		) {
			this.Id = frRule.Id;
			this.glCode = !String.isBlank(frRule.GL_Code__r.Business_ID__c)
				? frRule.GL_Code__r.Business_ID__c
				: frRule.GL_Code__c;
			this.glCodeTarget = !String.isBlank(
					frRule.GL_Code_Target__r.Business_ID__c
				)
				? frRule.GL_Code_Target__r.Business_ID__c
				: frRule.GL_Code_Target__c;
			this.type = !String.isBlank(frRule.RecordType.DeveloperName)
				? frRule.RecordType.DeveloperName
				: '';
			this.validationRule = frRule.Validation_Rule__c;
			this.errorMessage = frRule.Error_Message__c;
			this.serviceCategoryExcluded = frRule.Excluded_Service_Category__c;
			this.sourceColumn = frRule.Source_Column__c;
			this.targetColumn = frRule.Target_Column__c;
			this.hardValidation = frRule.Financial_Reporting_Rule__r.Hard_Validation__c;
		}
	}
}
