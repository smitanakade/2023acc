import { LightningElement, track, api } from "lwc";
import { OmniscriptBaseMixin } from "omnistudio/omniscriptBaseMixin";

export default class OmniDeclarationUploadProvider extends OmniscriptBaseMixin(
	LightningElement
) {
	@track files = { data: [] };

	@api
	recordId;
	@api
	notValidated;
	@api
	isReadOnly;

	get acceptedFormats() {
		return [".pdf", ".png", ".jpg", ".jpeg"];
	}

	async connectedCallback() {
		await this.checkUploadedFiles();
	}

	async checkUploadedFiles() {
		const args = {
			caseId: this.recordId
		};
		const options = {};

		const remoteCallParams = {
			input: JSON.stringify(args),
			sClassName: "OmniFileUploadHelper",
			sMethodName: "getRelatedFiles",
			options: JSON.stringify(options)
		};

		const { result } = await this.omniRemoteCall(remoteCallParams, false);
		if (result.relatedFile !== "undefined") {
			this.files.data = JSON.parse(result.relatedFile);
		}
		if (this.files.data.length > 0) {
			this.omniApplyCallResp(
				{
					declarationUploaded: true,
					isReadOnly: true,
					ResiViabilityIsReadOnly: true,
					HomeCareViabilityIsReadOnly: true
				},
				true
			);
		} else {
			this.omniApplyCallResp(
				{
					declarationUploaded: false,
					isReadOnly: false,
					ResiViabilityIsReadOnly: false,
					HomeCareViabilityIsReadOnly: false
				},
				true
			);
		}
	}

	get fileCheck() {
		return !this.files.data || this.files.data.length === 0;
	}

	handleActionFinished() {
		//refresh the list of files
		this.connectedCallback();
	}

	get disableButton() {
		return this.notValidated;
	}
}
