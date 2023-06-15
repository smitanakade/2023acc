import { api, LightningElement } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { updateRecord } from "lightning/uiRecordApi";
import hasQAAssesorPermission from "@salesforce/customPermission/QFR_Update_QA_Assessment";

export default class QfrQaOutcomeErrorModal extends LightningElement {
	@api value;
	@api modalIsOpen;
	@api isManagement = false;

	// management state
	@api selectedData;
	qaOutcomeValue;
	qaExternalComments;
	amendedExplanation;
	outcomeList = [
		{ label: "Approve", value: "Approve" },
		{
			label: "Review",
			value: "Review"
		},
		{
			label: "Reject - Low Percentage of Non-Care Wages",
			value: "Reject - Low Percentage of Non-Care Wages"
		},
		{
			label: "Reject - Only 3 Months of Data",
			value: "Reject - Only 3 Months of Data"
		},
		{ label: "Reject - Pay Periods", value: "Reject - Pay Periods" },
		{
			label: "Reject - Agency Staff not Included as Wages in QFS",
			value: "Reject - Agency Staff not Included as Wages in QFS"
		},
		{
			label: "Reject - Total and Care Wages are Equal",
			value: "Reject - Total and Care Wages are Equal"
		},
		{
			label: "Reject - YTD wages are less than QTR wages",
			value: "Reject - YTD wages are less than QTR wages"
		},
		{ label: "Reject - Alternative EOFY", value: "Reject - Alternative EOFY" },
		{
			label: "Reject - Care Wages are Greater than Total Wages",
			value: "Reject - Care Wages are Greater than Total Wages"
		},
		{
			label: "Reject - Higher than Usual RN Hours",
			value: "Reject - Higher than Usual RN Hours"
		},
		{ label: "Reject - Zero PCW Hours", value: "Reject - Zero PCW Hours" },
		{
			label: "Reject - No Reference to Sick or Annual Leave",
			value: "Reject - No Reference to Sick or Annual Leave"
		},
		{ label: "Reject - Other", value: "Reject - Other" }
	];

	// management
	handleRefreshParent() {
		this.dispatchEvent(new CustomEvent("refresh"));
	}

	updateQAExternalComments(event) {
		const newValue = event.target.value;
		this.qaExternalComments = newValue;
	}

	updateAmendedExplanation(event) {
		const newValue = event.target.value;
		this.amendedExplanation = newValue;
	}

	handlePicklistChange(event) {
		event.stopPropagation();
		const newValue = event.detail.value;
		this.qaOutcomeValue = newValue;
	}

	//save changes
	async submit(event) {
		const id = event.currentTarget.dataset.id;
		console.log("qa external comments " + this.qaOutcomeValue);

		const recordInput = {
			fields: {
				Id: id,
				QA_Outcome__c: this.qaOutcomeValue,
				QA_External_Comments__c: this.qaExternalComments,
				Amended_Explanation__c: this.amendedExplanation
			}
		};

		updateRecord(recordInput)
			.then(() => {
				this.dispatchEvent(
					new ShowToastEvent({
						title: "Success",
						message: "QA Assessment saved",
						variant: "success"
					})
				);
				this.handleCloseModal();
				this.selectedRow = undefined;
				this.handleRefreshParent();
			})
			.catch((error) => {
				this.dispatchEvent(
					new ShowToastEvent({
						title: "Error saving record",
						message: error.body.message,
						variant: "error"
					})
				);
			});
	}

	get hideTextField() {
		if (this.qaOutcomeValue) {
			if (
				this.qaOutcomeValue === "Approve" ||
				this.qaOutcomeValue === "Review"
			) {
				this.qaExternalComments = "";
				this.amendedExplanation = "";
				console.log("qaExternalComments", this.qaExternalComments);
				return true;
			} else {
				return false;
			}
		} else if (this.selectedData) {
			if (
				this.selectedData.qaOutcome === "Approve" ||
				this.selectedData.qaOutcome === "Review"
			) {
				this.qaExternalComments = "";
				this.amendedExplanation = "";

				return true;
			} else {
				return false;
			}
		}
		return false;
	}

	get dropdownValue() {
		if (this.selectedData && this.selectedData.qaOutcome) {
			return this.selectedData.qaOutcome;
		} else {
			return undefined;
		}
	}

	get isNotQaUser() {
		return hasQAAssesorPermission ? false : true;
	}

	// provider state
	@api errorMessage;
	@api explanation;
	@api hideExplanationOption;
	@api qaComment;
	@api recordId;

	firstOpen = true;
	explanationIsOpened;
	isSubmitDisabled = true;
	textTooShort = false;
	submitIsLoading = false;

	get textAreaClass() {
		return this.textTooShort ? `has-error slds-textarea` : `slds-textarea`;
	}

	get textTooShortClass() {
		const requiredClasses =
			"text-too-short-error slds-text-body_small slds-clearfix slds-text-color_error slds-m-top_x-small";
		return this.textTooShort ? `isShown ${requiredClasses}` : requiredClasses;
	}

	get displayExplanation() {
		if (this.explanation) {
			this.explanationIsOpened = true;
		}
		return this.explanationValue || this.explanation;
	}

	updateTextArea(event) {
		const newValue = event.target.value;
		this.explanationValue = newValue;
		const minLength = 25;

		if (
			this.explanationValue.length < minLength &&
			this.explanationValue.length !== 0
		) {
			this.isSubmitDisabled = true;
			this.textTooShort = true;
		} else {
			this.isSubmitDisabled = false;
			this.textTooShort = false;
		}
	}

	toggleExplanationInput() {
		this.explanationIsOpened = !this.explanationIsOpened;
	}

	providerSubmit() {
		this.submitIsLoading = true;
		this.dispatchEvent(
			new CustomEvent("submit", {
				detail: { explanation: this.explanationValue },
				bubbles: true
			})
		);
	}

	// -------

	get modalIsOpenState() {
		if (!this.isManagement) {
			if (
				this.modalIsOpen &&
				this.firstOpen &&
				!this.hideExplanationOption &&
				this.displayExplanation
			) {
				this.explanationIsOpened = true;
				this.firstOpen = false;
			}
		}
		if (!this.modalIsOpen) {
			this.submitIsLoading = false;
		}
		return this.modalIsOpen;
	}

	get modalTitle() {
		if (this.isManagement) {
			return "Edit ...";
		} else {
			return "Why am I seeing this?";
		}
	}

	get showFooter() {
		if (this.isManagement) {
			return true;
		} else {
			return this.explanationIsOpened;
		}
	}

	handleCloseModal() {
		this.firstOpen = true;
		this.dispatchEvent(new CustomEvent("close"));
	}

	connectedCallback() {}

	renderedCallback() {
		// console.log("selectedData", JSON.stringify(this.selectedData));
	}
}
