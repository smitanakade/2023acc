import { LightningElement, api } from "lwc";
import ID_FIELD from "@salesforce/schema/GL_Code_Line_Item__c.Id";
import EXPLANATION_FIELD from "@salesforce/schema/GL_Code_Line_Item__c.provider_explanation__c";
import OUTCOME_FIELD from "@salesforce/schema/GL_Code_Line_Item__c.QA_Outcome__c";
import COMMENT_FIELD from "@salesforce/schema/GL_Code_Line_Item__c.QA_External_Comments__c";
import AMENDED_FIELD from "@salesforce/schema/GL_Code_Line_Item__c.Amended_Explanation__c";
import { OmniscriptBaseMixin } from "omnistudio/omniscriptBaseMixin";
import { updateRecord } from "lightning/uiRecordApi";
import { errorMessages } from "c/qfrConstants";

export default class AcfrDatatableCell extends OmniscriptBaseMixin(
	LightningElement
) {
	static renderMode = "light";

	@api recordId = "";
	/** @type {number} */
	_value;
	@api get cellValue() {
		return this._value;
	}
	set cellValue(v) {
		this._value = v;
	}

	@api type = "Numeric";
	@api showErrors = false;
	@api isReadOnly = false;
	@api isHidden = false;
	@api allowNegatives = false;
	/** @type {boolean} */
	@api isValid;
	@api picklistOptions;
	@api cellErrorMessage = "";
	@api hardValidation;
	@api errorsOnlyView = false;
	@api colIndex;
	@api providerExplanation;
	@api qaOutcome;
	@api qaComments;

	whyModalIsOpened = false;
	isSubmitDisabled = true;
	textTooShort = false;

	// Change event may need to change to handleCellChange in other JS
	handlePickChange(event) {
		event.stopPropagation();
		this.pickvalue = event.currentTarget.value;

		this.dispatchEvent(
			new CustomEvent("picklistchange", {
				detail: {
					recordId: this.recordId,
					value: this.pickvalue
				},
				bubbles: true
			})
		);
	}

	textAreaOnFocus() {
		this.inputStarted = true;
	}

	// Get the true false condition
	_isPicklist;
	get isPicklist() {
		if (this.type === "Picklist") {
			this._isPicklist = true;
			return this._isPicklist;
		}
		this._isPicklist = false;
		return this._isPicklist;
	}

	get showErrorExplanation() {
		return this.showErrors;
	}

	get hideExplanationOption() {
		if (this.cellValue || this.cellValue === 0) {
			if (!errorMessages.includes(this.errorMessage)) {
				return this.isHardValidation;
			}
		}
		return true;
	}

	get colIndexValue() {
		return `cell-col-${this.colIndex}`;
	}

	get isHardValidation() {
		return this.hardValidation ? true : false;
	}

	get errorMessage() {
		return this.cellErrorMessage;
	}

	get containerClass() {
		return `cell-container ${this.readOnlyClass} ${this.hiddenClass} ${this.errorClass}`;
	}

	get readOnlyClass() {
		return this.isReadOnly ? "cell-container-read-only" : "";
	}

	get hiddenClass() {
		return this.isHidden ? "cell-container-hidden" : "";
	}

	get errorClass() {
		return !this.providerExplanation && !this.isValid ? "not-valid" : "";
	}

	lineItemValueTypeToPrefix = {
		Currency: "$",
		Percentage: "%",
		Numeric: "hrs",
		Days: "days",
		Minutes: "mins",
		Hrs: "hrs"
	};
	_prefix;

	get prefix() {
		if (this._prefix) {
			return this._prefix;
		}
		this._prefix = this.lineItemValueTypeToPrefix[this.type] ?? null;
		return this._prefix;
	}

	submit(event) {
		const fields = {};
		fields[ID_FIELD.fieldApiName] = this.recordId;
		fields[EXPLANATION_FIELD.fieldApiName] = event.detail.explanation;
		fields[OUTCOME_FIELD.fieldApiName] = "";
		fields[AMENDED_FIELD.fieldApiName] = "";
		fields[COMMENT_FIELD.fieldApiName] = "";
		const recordInput = { fields };
		updateRecord(recordInput).then(() => {
			this.closeModal();
			this.dispatchEvent(
				new CustomEvent("explanationupdate", {
					bubbles: true
				})
			);
		});
	}

	toggleWhyModal() {
		this.whyModalIsOpened = !this.whyModalIsOpened;
	}

	closeModal() {
		this.whyModalIsOpened = false;
	}
}
