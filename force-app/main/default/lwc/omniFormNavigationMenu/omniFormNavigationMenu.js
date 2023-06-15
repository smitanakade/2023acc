import { LightningElement, api } from "lwc";

export default class OmniFormNavigationMenu extends LightningElement {
	@api steps = new Map();
	@api width;
	isCollapsed = false;

	get stepArray() {
		return this.steps?.values();
	}

	get trackerClass() {
		if (this.isCollapsed) {
			return "qfr-step-tracker is-collapsed";
		}
		return "qfr-step-tracker";
	}

	toggleTracker() {
		this.isCollapsed = !this.isCollapsed;
		const tracker = this.template.querySelector(".qfr-step-tracker");
		const timeOffset = 500;

		if (this.isCollapsed) {
			tracker.classList.add("is-collapsing");
			setTimeout(() => {
				tracker.classList.remove("is-collapsing");
				tracker.classList.add("is-collapsed");
			}, timeOffset);
		} else {
			tracker.classList.remove("is-collapsed");
			tracker.classList.add("is-expanding");
			setTimeout(() => {
				tracker.classList.remove("is-expanding");
			}, timeOffset);
		}
		this.dispatchEvent(
			new CustomEvent("sidenavchange", {
				detail: { sideNavIsCollapsed: this.isCollapsed }
			})
		);
	}

	get isSubmissionLocked() {
		const steps = this.stepArray[Symbol.iterator]();
		let stepsArray = [];
		for (const item of steps) {
			stepsArray.push(item);
		}
		const numberOfSteps = stepsArray.length - 1;
		stepsArray = stepsArray.filter(
			(step) => step.name !== "STQFRDeclarationAndSubmission"
		);
		const completeSteps = stepsArray.filter(
			(step) => step.status === "complete"
		);
		return numberOfSteps !== completeSteps.length;
	}
}
