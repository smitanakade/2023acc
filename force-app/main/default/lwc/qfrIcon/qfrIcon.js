import { api, LightningElement } from "lwc";

export default class QfrIcon extends LightningElement {
	@api icon;
	@api size = "24";
	@api value;
	@api color;
	@api variant;

	get componentClass() {
		return `qfr-icon ${this.variant}`;
	}

	get isChevronDown() {
		return this.icon === "chevron-down";
	}

	get isFullScreen() {
		return this.icon === "fullscreen";
	}

	get isShrink() {
		return this.icon === "shrink";
	}

	get isEdit() {
		return this.icon === "edit";
	}

	get iconSize() {
		return this.size;
	}

	@api
	click() {
		this.template.querySelector("div").click();
	}
}
