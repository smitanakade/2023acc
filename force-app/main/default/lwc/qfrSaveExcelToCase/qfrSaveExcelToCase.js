import { LightningElement, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { OmniscriptBaseMixin } from "omnistudio/omniscriptBaseMixin";

export default class QfrSaveExcelToCase extends OmniscriptBaseMixin(
	NavigationMixin(LightningElement)
) {
	@api
	recordId;

	@api
	nextStepAction;

	async connectedCallback() {
		if (this.nextStepAction === "True") {
			this.navigateToNextStep();
		} else {
			this.navigateToDownload();
		}
	}

	navigateToNextStep() {
		this.omniNextStep();
	}

	navigateToDownload() {
		this[NavigationMixin.Navigate]({
			type: "comm__namedPage",
			attributes: {
				name: "QFR_Report_Download__c"
			},
			state: {
				caseId: this.recordId,
				submitting: "true"
			}
		});
	}
}
