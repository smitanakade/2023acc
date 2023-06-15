import Logger from "c/logger";
import { errorMessages } from "c/qfrConstants";

const VALIDATE_REQUIRED = (v) => {
	return v !== null && v !== undefined;
};
const VALIDATE_POSITIVE_OR_ZERO = (v) => {
	return VALIDATE_REQUIRED(v) && v >= 0;
};

// export type CellType = 'Currency' | 'Numeric' | 'Percentage'| 'Picklist'
export class Cell {
	constructor(init) {
		Object.assign(this, init);
		if (this.isValidationPassed) {
			this.#validationFunction = this.allowNegatives
				? VALIDATE_REQUIRED
				: VALIDATE_POSITIVE_OR_ZERO;
		}
		this.type = init.type;
		this.value = init.value;
		this.#validationFunction = this.allowNegatives
			? VALIDATE_REQUIRED
			: VALIDATE_POSITIVE_OR_ZERO;
		this.dirty = false;
	}
	logger = new Logger();
	cellId = "";
	rowId = "";
	#value = undefined;
	#validationFunction = () => true;
	/**
	 * @description flag indicating whether cell value pass validation rule
	 */ isValidationPassed = true;
	/**
	 * @description error message from validation rules
	 */ validationErrorMessage = "";
	get displayValidationErrorMessage() {
		return this.validationErrorMessage;
	}
	/**
	 * @description return dynamic error messages
	 */
	get displayErrorMessage() {
		let msg = "";
		if (!this.isValidationPassed) {
			msg =
				this.value &&
				Number(this.value) < 0 &&
				!this.allowNegatives &&
				!this.isReadOnly
					? errorMessages[1]
					: this.displayValidationErrorMessage;
		} else {
			msg = this.allowNegatives ? errorMessages[0] : errorMessages[1];
		}
		return msg;
	}
	get value() {
		return this.#value;
	}
	set value(v) {
		if (this.isHidden || !this.cellId) {
			return;
		}
		if (this.type === "Picklist") {
			this.#value = v;
		} else {
			let newValue = v;
			if (typeof newValue == "string") {
				newValue = Number.parseFloat(newValue);
			}
			if (isNaN(newValue) || (!newValue && newValue !== 0)) {
				newValue = null;
			}
			if (newValue) {
				newValue = Number.parseFloat(newValue.toFixed(this.precision));
			}
			this.#value = newValue;
		}
		// this.isValid = this.#validationFunction(v);
		// Should show errors whenever the cell has been modified
		// Ensures manual changes and automatic (calculations, excel) set this.
		this.visited = true;
		this.dirty = true;
	}
	get showErrors() {
		return (!this.firstLoad() || this.visited) && !this.cellReadOnly;
	}
	/**
	 * @description flag indicating whether a cell has changed and needs to be saved to the database.
	 */ dirty = false;
	/**
	 * @description controls whether the cell is editable.
	 */ get isReadOnly() {
		return this.componentReadOnly || this.cellReadOnly;
	}
	set isReadOnly(v) {
		this.logger.log("shouldn't be setting this here");
	}
	/**
	 * @description indicates whether the form is overriding the ordinary cell readonly status.
	 */ cellReadOnly = false;
	/**
	 * @description indicates whether the form is overriding the ordinary cell readonly status.
	 */ componentReadOnly = false;
	/**
	 * @description determines whether the cell is created for layout (align other cells) only, or has an ID associated with it.
	 */ isHidden = false;
	/**
	 * @description ensures validation errors are only shown for cells that have been interacted with.
	 */ visited = false;
	/**
	 * @description function that determines whether the component has been loaded for the first time.
	 * determines whether errors are visible before interacting with a cell.
	 */ firstLoad = () => true;
	/**
	 * @description determines which validation is applied to the cell.
	 */ allowNegatives = false;
	/**
	 * @description the current validation status of the cell.
	 */ get isValid() {
		if (this.isHidden || this.cellReadOnly) {
			return true;
		}
		let validationResult = true;
		if (this.type !== "Picklist") {
			validationResult =
				this.#validationFunction(this.value && Number(this.value)) &&
				this.isValidationPassed;
		} else {
			validationResult = typeof this.value === "string" && this.value !== "";
		}
		return validationResult;
	}
	set isValid(_v) {
		this.logger.error("isValid should not be set here");
	}
	/**
	 * @description contains the cells in a row that a row-level total cell summarises.
	 */ totalChildren = [];
	get displayValue() {
		const zero = 0;
		if (this.#value === null || this.#value === undefined) {
			return "";
		}
		if (this.type === "Picklist") {
			return this.#value;
		}
		// eslint-disable-next-line no-compare-neg-zero
		if (this.#value === -0) {
			return zero.toLocaleString("en-US", {
				maximumFractionDigits: this.precision,
				minimumFractionDigits: this.precision
			});
		}
		return this.value.toLocaleString("en-US", {
			maximumFractionDigits: this.precision,
			minimumFractionDigits: this.precision
		});
	}
	#precision = 0;
	/**
	 * @description the number of decimal places the cell should retain precision to.
	 */ get precision() {
		return this.#precision || 0;
	}
	set precision(v) {
		this.#precision = v;
	}

	hardValidation = false;

	get isHardValidation() {
		return this.hardValidation;
	}

	providerExplanation = "";
	get displayProviderExplanation() {
		return this.providerExplanation;
	}
	qaOutcome = "";
	get displayQaOutcome() {
		return this.qaOutcome;
	}
	qaComments = "";
	get displayQaComments() {
		return this.qaComments;
	}
}

let rand = 0;

export const getHiddenCell = (rowId) => {
	rand += 1;
	return new Cell({
		cellId: `${rowId}-${rand}`,
		rowId: rowId,
		isHidden: true
	});
};

//# sourceMappingURL=Cell.js.map
