import { LightningElement, api } from "lwc";
import { OmniscriptBaseMixin } from "omnistudio/omniscriptBaseMixin";
import QFR_DECLARATION from "@salesforce/resourceUrl/QFRDeclaration";

export default class omniDeclarationDownloadProvider extends OmniscriptBaseMixin(
	LightningElement
) {
	declarationUrl = QFR_DECLARATION;

	@api
	reportPeriodId = "a2Y9h0000000eLdEAI";
	@api
	notValidated;

	get disableButton() {
		return this.notValidated;
	}
}
