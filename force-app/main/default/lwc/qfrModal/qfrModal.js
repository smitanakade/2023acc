import { api, LightningElement } from "lwc";

export default class QfrModal extends LightningElement {
	@api value;
	@api title;
	@api isOpened = false;
	@api hasFooter = false;

	get modalState() {
		if (this.isOpened) {
			document.body.style.overflow = "hidden";
		} else {
			document.body.style.overflow = "auto";
		}
		return this.isOpened;
	}

	handleClose() {
		this.dispatchEvent(new CustomEvent("close"));
	}
}
