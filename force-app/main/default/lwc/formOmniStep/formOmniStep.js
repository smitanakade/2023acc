import { LightningElement, api } from 'lwc';

export default class FormOmniStep extends LightningElement {


	handleDataJsonChange(evt) {
		if (evt.detail.data) {
			const omniDataJson = evt.detail.data;
			this.dispatchEvent(
				new CustomEvent("datajsonchange", {
					detail: omniDataJson,
					bubbles: true,
					composed: true
				})
			);
		}
	}

	connectedCallback() {
		this.template.addEventListener("omniaggregate", this.handleDataJsonChange);
	}
}
