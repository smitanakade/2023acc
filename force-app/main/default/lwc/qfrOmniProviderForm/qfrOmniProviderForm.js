import { LightningElement, api } from "lwc";

export default class QfrOmniProviderForm extends LightningElement {
	@api
	sharedDataJson = {};

	@api
	steps = new Map();

	get beforeYouStart() {
		return this.steps.get("STBeforeYouStart")?.status === "active";
	}
	get providerContactActive() {
		return this.steps.get("STProviderContact")?.status === "active";
	}
	get resiViabilityActive() {
		return (
			this.steps.get("ResidentialProviderFinancialPerformanceSurvey")?.status ===
			"active"
		);
	}
	get homeCareViabilityActive() {
		return (
			this.steps.get("STViabiltyQuestionsHomeCareProvider")?.status === "active"
		);
	}
	get approvedProviderQFSActive() {
		return (
			this.steps.get("STApprovedProviderQuarterlyFinancialStatements")
				?.status === "active"
		);
	}
	get homeCareLabourCostsActive() {
		return this.steps.get("STHomeCareLabourCostsAndHours")?.status === "active";
	}
	get resiLabourCostsActive() {
		return (
			this.steps.get("STResidentialLabourCostsandHours")?.status === "active"
		);
	}
	get resifoodAndNutritionActive() {
		return this.steps.get("STFoodandNutritionReporting")?.status === "active";
	}
	get natsifacqFoodAndNutritionActive() {
		return (
			this.steps.get("NATSIFACPFoodandNutritionReporting")?.status === "active"
		);
	}
	get mpsFoodAndNutritionActive() {
		return this.steps.get("MPSFoodandNutritionReporting")?.status === "active";
	}
	get declarationActive() {
		return this.steps.get("STQFRDeclarationAndSubmission")?.status === "active";
	}
}
