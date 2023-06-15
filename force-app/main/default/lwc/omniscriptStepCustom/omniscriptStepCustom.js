// eslint-disable-next-line no-unused-vars
import { LightningElement, api, wire } from "lwc";
import omniscriptStep from "omnistudio/omniscriptStep";
import stp from "./omniscriptStepCustom.html";
import { OmniscriptBaseMixin } from "omnistudio/omniscriptBaseMixin";
import { getNamespaceDotNotation } from "omnistudio/omniscriptInternalUtils";
import { OmniscriptActionCommonUtil } from "omnistudio/omniscriptActionUtils";
import pubsub from "omnistudio/pubsub";
import {
	subscribe,
	unsubscribe,
	MessageContext
} from "lightning/messageService";
import QFR_OS_LWC from "@salesforce/messageChannel/QFR_Omniscript_LWC__c";

export default class OmniscriptStepCustom extends OmniscriptBaseMixin(
	omniscriptStep
) {
	_ns = getNamespaceDotNotation();

	subscription = null;
	@wire(MessageContext)
	messageContext;

	// Encapsulate logic for Lightning message service subscribe and unsubsubscribe
	subscribeToMessageChannel() {
		if (!this.subscription) {
			this.subscription = subscribe(
				this.messageContext,
				QFR_OS_LWC,
				(message) => this.handleMessage(message),
				{}
			);
		}
	}

	handleMessage(message) {
		switch (message.action) {
			case "qfr_os_next":
				this.handleExecuteNext();
				break;
			default:
				break;
		}
	}

	@api formId;
	stepName;
	prevAccordionVal = false;

	render() {
		return stp;
	}

	renderedCallback() {
		if (!this.firstRunComplete) {
			this.firstRunComplete = true;
			this._handleExecuteNext = {
				data: this.handleExecuteNext
			};
			pubsub.register("qfr_os_next", this._handleExecuteNext);
		}

		if (
			this.prevAccordionVal &&
			this.prevAccordionVal !== this.jsonDef.bAccordionActive &&
			(this.stepName.includes("Residential Provider") ||
				this.stepName.includes("QFRViabilityQuestions-HomeCareForm"))
		) {
			// Make the callout to the IP
			const options = {};

			let methodName;
			if (this.stepName === "ResidentialProviderFinancialPerformanceSurvey") {
				methodName = this.jsonData.residentialIP;
			} else if (this.stepName === "STViabiltyQuestionsHomeCareProvider") {
				methodName = this.jsonData.homecareIP;
				this.saveHomeCareBSSData();
			} else {
				// do nothing
			}

			const params = {
				input: JSON.stringify(this.jsonData),
				sClassName: `${this._ns}IntegrationProcedureService`,
				sMethodName: methodName,
				options: JSON.stringify(options)
			};

			this._actionUtil
				.executeAction(params, null, this, null, null)
				.then((response) => {
					this.isSuccess = response.result.IPResult.isSuccess;
				});
		}
		this.prevAccordionVal = this.jsonDef.bAccordionActive;
	}

	connectedCallback() {
		super.connectedCallback();
		this.subscribeToMessageChannel();
		this._actionUtil = new OmniscriptActionCommonUtil();
		this.stepName = this.jsonDef.name;
	}

	disconnectedCallback() {
		super.disconnectedCallback();
		pubsub.unregister(this._handleExecuteNext);
		let methodName;
		if (this.stepName === "ResidentialProviderFinancialPerformanceSurvey") {
			methodName = this.jsonData.residentialIP;
		} else if (this.stepName === "STViabiltyQuestionsHomeCareProvider") {
			methodName = this.jsonData.homecareIP;
			this.saveHomeCareBSSData();
		} else {
			// do nothing
		}

		if (typeof methodName != "undefined") {
			const params = {
				input: JSON.stringify(this.jsonData),
				sClassName: `${this._ns}IntegrationProcedureService`,
				sMethodName: methodName,
				options: JSON.stringify({})
			};
			this._actionUtil
				.executeAction(params, null, this, null, null)
				.then((response) => {
					this.isSuccess = response.result.IPResult.isSuccess;
				});
		}
	}

	saveHomeCareBSSData() {
		const params = {
			input: JSON.stringify(this.jsonData),
			sClassName: `${this._ns}IntegrationProcedureService`,
			sMethodName: "ACFR_SaveViabilityHomeCareBusinessStructure",
			options: JSON.stringify({})
		};
		this._actionUtil
			.executeAction(params, null, this, null, null)
			.then((response) => {
				this.isSuccess = response.result.IPResult.isSuccess;
			});
	}

	handleExecuteNext() {
		this.omniNextStep();
	}
}
