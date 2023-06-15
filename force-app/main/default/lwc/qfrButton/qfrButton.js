import { api, LightningElement } from "lwc";
import { normalizeString as normalize } from "c/jsUtils";

export default class QfrButton extends LightningElement {
	/** @type {"neutral" | "brand" | "brand-outline" | "destructive" | "text-destructive" | "success"} */
	@api name;
	@api value;
	@api label = "Button name";
	@api variant = "neutral";
	@api icon;
	@api iconPosition = "left";
	@api type = "button";
	@api disabled;
	@api isManagement = false;
	@api isInput = false;
	@api isFullwidth = false;
	@api isLoading = false;

	get iconClass() {
		if (this.icon) {
			if (this.iconPosition === "left") {
				return "has-icon-left";
			} else {
				return "has-icon-right";
			}
		} else {
			return "";
		}
	}

	get disabledClass() {
		if (this.disabled) {
			return "is-disabled";
		} else {
			return "";
		}
	}

	get isManagementClass() {
		if (this.isManagement) {
			return "is-management";
		} else {
			return "";
		}
	}

	get isInputClass() {
		if (this.isInput) {
			return "is-input";
		} else {
			return "";
		}
	}

	get isFullWidthClass() {
		if (this.isFullwidth) {
			return "is-fullwidth";
		} else {
			return "";
		}
	}

	get isLoadingClass() {
		if (this.isLoading) {
			return "is-loading";
		} else {
			return "";
		}
	}

	get buttonClass() {
		let result;
		if (this.variant === "brand") {
			result = `qfr-button qfr-button-brand ${this.iconClass} ${this.disabledClass} ${this.isInputClass} ${this.isManagementClass} ${this.isFullWidthClass} ${this.isLoadingClass}`;
		} else if (this.variant === "brand-outline") {
			result = `qfr-button qfr-button-outline-brand ${this.iconClass} ${this.disabledClass} ${this.isInputClass} ${this.isManagementClass} ${this.isFullWidthClass} ${this.isLoadingClass}`;
		} else if (this.variant === "destructive") {
			result = `qfr-button qfr-button-destructive ${this.iconClass} ${this.disabledClass} ${this.isInputClass} ${this.isManagementClass} ${this.isFullWidthClass} ${this.isLoadingClass}`;
		} else if (this.variant === "text-destructive") {
			result = `qfr-button qfr-button-text-destructive ${this.iconClass} ${this.disabledClass} ${this.isInputClass} ${this.isManagementClass} ${this.isFullWidthClass} ${this.isLoadingClass}`;
		} else if (this.variant === "success") {
			result = `qfr-button qfr-button-success ${this.iconClass} ${this.disabledClass} ${this.isInputClass} ${this.isManagementClass} ${this.isFullWidthClass} ${this.isLoadingClass}`;
		} else {
			result = `qfr-button qfr-button-neutral ${this.iconClass} ${this.disabledClass} ${this.isInputClass} ${this.isManagementClass} ${this.isFullWidthClass} ${this.isLoadingClass}`;
		}
		return result;
	}

	get normalizedType() {
		return normalize(this.type, {
			fallbackValue: "button",
			validValues: ["button", "reset", "submit"]
		});
	}

	get normalizedIconPosition() {
		return normalize(this.iconPosition, {
			fallbackValue: "left",
			validValues: ["left", "right"]
		});
	}

	get showIconLeft() {
		return this.icon && this.normalizedIconPosition === "left";
	}

	get showIconRight() {
		return this.icon && this.normalizedIconPosition === "right";
	}

	handleButtonFocus() {
		if (this.disabled) {
			return;
		}
		this.dispatchEvent(new CustomEvent("focus"));
	}

	handleButtonBlur() {
		if (this.disabled) {
			return;
		}
		this.dispatchEvent(new CustomEvent("blur"));
	}

	@api
	focus() {
		if (this.disabled) {
			return;
		}
		this.template.querySelector("button").focus();
	}

	@api
	click() {
		if (this.disabled) {
			return;
		}
		this.template.querySelector("button").click();
	}

	renderedCallback() {
		this.template.host.style.pointerEvents = this.disabled ? "none" : "";
	}
}
