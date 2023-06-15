import { LightningElement, api } from "lwc";

export default class OmniFormNavigationMenuItem extends LightningElement {
	@api stepName;
	@api label;
	@api status = "inactive";
	@api errorMessage;
	@api isCollapsed;
	@api width;
	@api isSubmissionLocked;
	@api isLastChild = false;

	get getStatus() {
		if (this.stepName === "STQFRDeclarationAndSubmission") {
			if (this.getIsSubmissionLocked) {
				return "locked";
			}
		}
		return this.status;
	}

	get divClass() {
		return `${this.isCollapsed} ${this.getStatus} ${
			this.isLastChild && "is-last-child"
		}`;
	}

	get getWidth() {
		const padding = 48;
		return `width: ${this.width - padding}px`;
	}

	get getIsSubmissionLocked() {
		return this.isSubmissionLocked;
	}

	handleStepClick() {
		this.dispatchEvent(this.createStepChangeEvent());
	}

	createStepChangeEvent() {
		return new CustomEvent("stepchange", {
			detail: {
				stepName: this.stepName
			},
			bubbles: true,
			composed: true
		});
	}
}
