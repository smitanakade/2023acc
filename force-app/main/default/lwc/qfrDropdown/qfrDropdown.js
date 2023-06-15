import { api, LightningElement } from "lwc";

export default class QfrDropdown extends LightningElement {
	@api defaultLabel;
	@api list;
	@api placement;
	@api value;
	@api disabled;
	@api isManagement = false;
	selected;

	_handler;
	isOpened = false;

	get dropdownLabel() {
		return this.label || this.value || this.defaultLabel;
	}

	get dropdownClass() {
		return `qfr-dropdown ${this.isManagement ? "is-management" : ""} ${
			this.placement === "right" ? "is-align-right" : "is-align-left"
		}`;
	}

	handleSelected(event) {
		const item = {
			label: event.target.dataset.label,
			value: event.target.dataset.value
		};
		this.selected = item;
		this.label = item.label;
		this.dispatchEvent(
			new CustomEvent("change", {
				composed: true,
				bubbles: true,
				detail: {
					value: item.value
				}
			})
		);
	}

	toggleDropdown(event) {
		event.stopPropagation();
		this.isOpened = !this.isOpened;
		return false;
	}

	handleClose() {
		this.isOpened = false;
	}
	connectedCallback() {
		document.addEventListener(
			"click",
			(this._handler = this.handleClose.bind(this))
		);
	}
	disconnectedCallback() {
		document.removeEventListener("click", this._handler);
	}
}
