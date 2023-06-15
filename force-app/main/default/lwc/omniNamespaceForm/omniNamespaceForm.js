import { LightningElement, api, wire } from "lwc";
import { OmniscriptActionCommonUtil } from "omnistudio/omniscriptActionUtils";
import pubsub from "omnistudio/pubsub";
// Import message service features required for publishing and the message channel
import { publish, MessageContext } from "lightning/messageService";
import QFR_OS_LWC from "@salesforce/messageChannel/QFR_Omniscript_LWC__c";
import hasSubmitPermission from "@salesforce/customPermission/QFR_Finance_Data_Submission";
import getFormStates from "@salesforce/apex/AcfrSidebarController.getFormStates";
import checkPrimaryContact from "@salesforce/apex/AcfrSidebarController.checkPrimaryContact";
import updateIsCompleteFlag from "@salesforce/apex/AcfrSidebarController.updateIsCompleteFlag";
import resumeForm from "@salesforce/apex/AcfrSidebarController.resumeForm";
import saveActiveForm from "@salesforce/apex/AcfrSidebarController.saveActiveForm";
import { QFR_STEPS } from "./steps";

const FORM_TO_STEP_NAMES = {
	ApprovedProviderQuarterlyFinancialStatementsFormId:
		"STApprovedProviderQuarterlyFinancialStatements",
	ResidentialViabilityandPrudentialReportingFormId:
		"ResidentialProviderFinancialPerformanceSurvey",
	HomeCareViabilityandPrudentialReportingFormId:
		"STViabiltyQuestionsHomeCareProvider",
	ResidentialLabourCostsandHoursFormId: "STResidentialLabourCostsandHours",
	HomeCareLabourCostsandHoursFormId: "STHomeCareLabourCostsAndHours",
	FoodandNutritionReportingFormId: "STFoodandNutritionReporting",
	MPSFoodandNutritionFormId: "MPSFoodandNutritionReporting",
	NATSIFACPFoodandNutritionFormId: "NATSIFACPFoodandNutritionReporting"
};

const FORM_TYPE_LIST = [
	"Before You Start",
	"Provider Contact",
	"Residential Viability and Prudential Reporting",
	"Home Care Viability and Prudential Reporting",
	"Approved Provider Quarterly Financial Statements",
	"Residential Labour Costs and Hours",
	"Home Care Labour Costs and Hours",
	"Residential Food and Nutrition Reporting",
	"NATSIFACP Food and Nutrition Reporting",
	"MPS Food and Nutrition Reporting",
	"Declaration and Submission"
];

const IS_COMPLETE_FLAG_LIST = [
	"STBeforeYouStartIsComplete",
	"STProviderContactIsComplete",
	"ResidentialProviderFinancialPerformanceSurveyIsComplete",
	"STViabiltyQuestionsHomeCareProviderIsComplete",
	"STApprovedProviderQuarterlyFinancialStatementsIsComplete",
	"STResidentialLabourCostsandHoursIsComplete",
	"STHomeCareLabourCostsAndHoursIsComplete",
	"STFoodandNutritionReportingIsComplete",
	"NATSIFACPFoodandNutritionReportingIsComplete",
	"MPSFoodandNutritionReportingIsComplete"
];

const NEXT_LABEL = "Next";
const SUBMIT_LABEL = "Submit";
/** @typedef {import('./types').Step} Step */

export default class OmniNamespaceForm extends LightningElement {
	@wire(MessageContext)
	messageContext;

	@api
	caseId = "";

	sharedDataJson = {
		homecareIP: "ACFR_SaveViabilityHomeCareQuestion",
		residentialIP: "ACFR_SaveViabilityResiCareQuestion"
	};

	activeStep = "STBeforeYouStart";

	/** @type {Map<string, Step>} */
	stepMap = new Map(QFR_STEPS);

	initialised = false;

	updateDataJson(updates) {
		this.sharedDataJson = {
			...this.sharedDataJson,
			...updates
		};
		this.evaluateDataJsonUpdates();
	}

	evaluateDataJsonUpdates() {
		for (const [_k, value] of this.stepMap) {
			if (value.status !== "active") {
				if (this.sharedDataJson[`${value.name}IsComplete`] === true) {
					value.status = "complete";
				} else if (this.sharedDataJson[`${value.name}IsComplete`] === false) {
					value.status = "error";
				} else {
					value.status = "inactive";
				}
			}
		}
	}

	/**
	 * @param {string} stepName
	 */
	beginChangeStep(stepName) {
		if (!this.stagedStep) {
			this.stagedStep = stepName;
			if (this.shouldSkipPostStepActions()) {
				this.finishChangeStep();
			} else {
				this.omniGoNext();
			}
		}
	}

	shouldSkipPostStepActions() {
		// do not run post-step actions if on the last step
		// submission does not go through the usual 'change step' methods.\
		return !this.notLastStep;
	}

	finishChangeStep() {
		if (this.stagedStep) {
			this.deactivateStep(this.activeStep);
			this.steps.get(this.stagedStep).status = "active";
			saveActiveForm({
				caseId: this.sharedDataJson.caseId,
				activeForm: this.stagedStep
			});
			this.activeStep = this.stagedStep;
			this.stagedStep = null;
		}
	}

	deactivateStep(stepName) {
		let newStatus = "complete";
		if (!this.sharedDataJson[`${stepName}IsComplete`]) {
			newStatus = "error";
		}
		this.steps.get(stepName).status = newStatus;

		const isCompleteflag = this.sharedDataJson[`${stepName}IsComplete`];
		const formTypeIndex = IS_COMPLETE_FLAG_LIST.findIndex(
			(type) => type === `${stepName}IsComplete`
		);
		const formType = FORM_TYPE_LIST[formTypeIndex];
		let formInfo;

		if (
			formType !== "Before You Start" &&
			formType !== "Provider Contact" &&
			formType !== undefined
		) {
			Object.values(this.sharedDataJson.GetFormData_DR).forEach((node) => {
				if (node.Type === formType) {
					formInfo = node;
				}
			});

			updateIsCompleteFlag({
				formId: formInfo.Id,
				isCompleteValue: isCompleteflag
			});
		}
	}

	activateStep(stepName) {
		this.stepMap.get(stepName).status = "active";
		this.activeStep = stepName;
	}

	isCollapsed = false;
	sideNavWidth;

	_actionUtil = new OmniscriptActionCommonUtil();

	async connectedCallback() {
		window.addEventListener("resize", this.handleResize);

		this.getUrlState();
		await this.prepareData();

		this.activeStep = await resumeForm({ caseId: this.sharedDataJson.caseId });
		this.steps.get(this.activeStep).status = "active";

		this.initialised = true;
	}

	renderedCallback() {
		if (!this.firstRunComplete) {
			this.firstRunComplete = true;
			this._handleOmniDone = {
				data: this.handleOmniDone.bind(this)
			};
			pubsub.register("omniscript_action", this._handleOmniDone);
		}

		if (!this.sideNavWidth) {
			this.handleResize();
		}
	}

	disconnectedCallback() {
		// event listeners on window object require manual cleanup
		window.removeEventListener("resize", this.handleResize);
	}

	sideNavCheck(event) {
		this.isCollapsed = event.detail.sideNavIsCollapsed;
		setTimeout(() => {
			this.handleResize();
		}, 0);
	}

	get containerClass() {
		if (this.isCollapsed) {
			return "qfr-main-form-container is-collapsed";
		}
		return "qfr-main-form-container";
	}

	get steps() {
		return new Map(this.stepMap);
	}

	handleResize = () => {
		const timeout = 1000;
		try {
			const sideNavContainer = this.refs.nav;
			setTimeout(() => {
				this.sideNavWidth = Math.round(
					sideNavContainer.getBoundingClientRect().width
				);
			}, timeout);
		} catch (err) {
			// do nothing
		}
	};

	async prepareData() {
		const options = {};
		const params = {
			input: JSON.stringify(this.sharedDataJson),
			sClassName: `omnistudio.IntegrationProcedureService`,
			sMethodName: "QFR_FormPayload_IP_Draft",
			options
		};

		const response = await this._actionUtil.executeAction(
			params,
			null,
			this,
			null,
			null
		);
		const result = response.result;
		result.IPResult.options = undefined;
		this.updateDataJson(result.IPResult);
		await this.initialiaseFormStates();
		this.initialiseDataJson();
	}

	async initialiaseFormStates() {
		const result = await getFormStates({ caseId: this.sharedDataJson.caseId });

		for (let i = 0; i < result.length; i++) {
			const type = result[i].Type__c;
			const index = FORM_TYPE_LIST.indexOf(type);
			const isCompleteFlag = result[i].Is_Complete__c;
			const isCompleteKey = IS_COMPLETE_FLAG_LIST[index];
			if (isCompleteFlag === "true") {
				this.updateDataJson({ [isCompleteKey]: "true" });
			} else if (isCompleteFlag === "false") {
				this.updateDataJson({ [isCompleteKey]: "false" });
			} else {
				// Do nothing
			}
		}

		const primaryContactCheck = await checkPrimaryContact({
			caseId: this.sharedDataJson.caseId
		});
		if (primaryContactCheck === true) {
			this.updateDataJson({ [IS_COMPLETE_FLAG_LIST[1]]: "true" });
		} else {
			this.updateDataJson({ [IS_COMPLETE_FLAG_LIST[1]]: "false" });
		}
	}

	initialiseDataJson() {
		const dataJson = this.sharedDataJson;
		this.updateDataJson({
			isReadOnly: dataJson?.checkIfReadOnlyForm?.isReadOnly === "true"
		});
		this.updateDataJson({
			accountRecordId: dataJson.GetFormData_DR.Case.Account__c,
			caseRecordId: dataJson.GetFormData_DR.Case.Case__c,

			ApprovedProviderQuarterlyFinancialStatementsFormId:
				dataJson.GetFormData_DR.ApprovedProviderQuarterlyFinancialStatements
					?.Id,

			FoodandNutritionReportingFormId:
				dataJson.GetFormData_DR.FoodandNutritionReporting?.Id,

			HomeCareLabourCostsandHoursFormId:
				dataJson.GetFormData_DR.HomeCareLabourCostsandHours?.Id,

			HomeCareViabilityandPrudentialReportingFormId:
				dataJson.GetFormData_DR.HomeCareViabilityandPrudentialReporting?.Id,

			MPSFoodandNutritionFormId:
				dataJson.GetFormData_DR.MPSFoodandNutritionReporting?.Id,

			NATSIFACPFoodandNutritionFormId:
				dataJson.GetFormData_DR.NATSIFACPFoodandNutritionReporting?.Id,

			ResidentialLabourCostsandHoursFormId:
				dataJson.GetFormData_DR.ResidentialLabourCostsandHours?.Id,

			ResidentialViabilityandPrudentialReportingFormId:
				dataJson.GetFormData_DR.ResidentialViabilityandPrudentialReporting?.Id,

			ResiViabilityIsReadOnly:
				(dataJson.GetFormData_DR.ResidentialViabilityandPrudentialReporting
					?.QA_Outcome__c === "Re-Issue" &&
					dataJson.GetFormData_DR.Case.Status === "Reissued") ||
				dataJson.GetFormData_DR.Case.Status === "Submitted" ||
				dataJson.isReadOnly === "true",

			HomeCareViabilityIsReadOnly:
				(dataJson.GetFormData_DR.HomeCareViabilityandPrudentialReporting
					?.QA_Outcome__c === "Re-Issue" &&
					dataJson.GetFormData_DR.Case.Status !== "Reissued") ||
				dataJson.isReadOnly === "true",

			STBeforeYouStartIsComplete: "true"
		});

		this.checkForReIssuesForm();
		this.applySteps();
	}

	checkForReIssuesForm() {
		const { GetFormData_DR } = this.sharedDataJson;
		const json = Object.values(GetFormData_DR);

		this.stepMap.forEach((step, index) => {
			const { label, name } = JSON.parse(JSON.stringify(step));
			const obj = json.find((s) => s.Type === label);
			if (obj && obj.QA_Outcome__c === "Re-Issue") {
				this.stepMap.get(name).status = "inactive";
			}
		});
	}

	applySteps() {
		const dataJson = this.sharedDataJson;
		Object.keys(FORM_TO_STEP_NAMES).forEach((key) => {
			if (!dataJson[key]) {
				this.stepMap.delete(FORM_TO_STEP_NAMES[key]);
			}
		});
	}

	getUrlState() {
		const searchParams = new URLSearchParams(window.location.search);

		this.sharedDataJson.caseId =
			searchParams.get("c__caseId") || this.sharedDataJson.caseId;
		this.sharedDataJson.ContextId =
			searchParams.get("c__caseId") || this.sharedDataJson.ContextId;
		this.activeStep = searchParams.get("c__step") || this.activeStep;
	}

	/**
	 * @description sets state in the url to preserve state on reload. Consistent with existing omni behaviour
	 */
	replaceUrlState() {
		const searchParams = new URLSearchParams(window.location.search);
		searchParams.set("c__caseId", this.sharedDataJson.caseId);
		searchParams.set("c__step", this.activeStep);
	}

	/**
	 * @param {CustomEvent} evt
	 * @description create or update data JSON with new values from child
	 * omniscript
	 */
	handleDataJsonChange(evt) {
		this.updateDataJson(evt.detail);
		// stops event bubbling further, as it's set up to bubble past shadow roots
		evt.stopPropagation();
	}

	handleStepChange(event) {
		this.beginChangeStep(event.detail.stepName);
		this.omniGoNext();
	}

	omniGoNext() {
		pubsub.fire("qfr_os_next");
		publish(this.messageContext, QFR_OS_LWC, { action: "qfr_os_next" });
	}

	handleOmniDone() {
		this.finishChangeStep();
	}

	getNextStep() {
		const stepKeys = [...this.stepMap.keys()];
		const nextIndex = stepKeys.indexOf(this.activeStep) + 1;
		if (nextIndex > stepKeys.length - 1) {
			// end of form
			return "SUBMIT";
		}
		return stepKeys[nextIndex];
	}

	getPreviousStep() {
		const stepKeys = [...this.stepMap.keys()];
		const prevIndex = stepKeys.indexOf(this.activeStep) - 1;
		return stepKeys[prevIndex];
	}

	handleNextClick() {
		const nextStep = this.getNextStep();
		if (nextStep === "SUBMIT") {
			// skip submission if the user doesn't have permission.
			if (!hasSubmitPermission) {
				return;
			}
			this.omniGoNext();
		} else {
			this.beginChangeStep(this.getNextStep());
		}
	}

	handlePreviousClick() {
		if (this.isNextAllowed) {
			this.beginChangeStep(this.getPreviousStep());
		} else {
			this.stagedStep = this.getPreviousStep();
			this.finishChangeStep();
		}
	}

	get notFirstStep() {
		const stepKeys = [...this.stepMap.keys()];
		return stepKeys.indexOf(this.activeStep) !== 0;
	}

	get notLastStep() {
		const stepKeys = [...this.stepMap.keys()];
		return stepKeys.indexOf(this.activeStep) !== stepKeys.length - 1;
	}

	get nextLabel() {
		return this.notLastStep ? NEXT_LABEL : SUBMIT_LABEL;
	}

	get isNextAllowed() {
		if (this.nextLabel === NEXT_LABEL) {
			return true;
		} else {
			return (
				hasSubmitPermission && this.sharedDataJson.declarationUploaded === true
			);
		}
	}
}
