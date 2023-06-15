import { LightningElement, api } from "lwc";

export default class OmniDatatableHeader extends LightningElement {
	// static renderMode = "light";
	isErrorsOnlySelected = false;
	isExpandTableSelected = false;
	isCommentsOnlySelected = false;
	selectedView = "View All";

	viewList = [
		{ label: "View All", value: "View All" },
		{ label: "View Errors Only", value: "View Errors Only" },
		{ label: "View Comments Only", value: "View Comments Only" }
	];

	get dynamicViewList() {
		const tempList = [];
		// eslint-disable-next-line array-callback-return
		this.viewList.map((item) => {
			if (item.label === this.selectedView) {
				tempList.push({ ...item, disabled: true });
			} else {
				tempList.push({ ...item });
			}
		});
		return tempList;
	}

	get commentButtonState() {
		if (this.isCommentsOnlySelected) {
			return "brand";
		} else {
			return "brand-outline";
		}
	}

	get errorButtonState() {
		if (this.isErrorsOnlySelected) {
			return "brand";
		} else {
			return "brand-outline";
		}
	}

	get expandButtonState() {
		if (this.isExpandTableSelected) {
			return "brand";
		} else {
			return "brand-outline";
		}
	}

	get expandButtonIcon() {
		if (this.isExpandTableSelected) {
			return "shrink";
		} else {
			return "fullscreen";
		}
	}

	get expandTableButtonLabel() {
		if (this.isExpandTableSelected) {
			return "Shrink Table";
		} else {
			return "Expand Table";
		}
	}

	/**
	 * @type {object[]}
	 */
	_columns;
	@api
	get columns() {
		return this._columns;
	}

	set columns(cols) {
		this._columns = this.buildComboboxOptionsFromLabels(cols);
	}

	/**
	 * @type {object[]}
	 */
	_sections;
	@api get sections() {
		return this._sections;
	}

	set sections(sections) {
		this._sections = this.buildComboboxOptionsFromLabels(sections);
	}

	/**
	 * @param {string[]} labels
	 */
	buildComboboxOptionsFromLabels(labels) {
		const result = [];
		if (labels) {
			for (const label of labels) {
				result.push({
					value: label,
					label: label
				});
			}
		}
		return result;
	}

	handleViewChange(event) {
		const value = event.detail.value;
		this.selectedView = value;
		this.dispatchEvent(
			new CustomEvent("viewchange", { detail: { newView: value } })
		);
	}

	handleExpandClick() {
		this.isExpandTableSelected = !this.isExpandTableSelected;
		this.dispatchEvent(new CustomEvent("expandtoggle"));
	}

	handleCommentsOnlyToggle() {
		// console.log('fire comments toggle');
		this.isCommentsOnlySelected = !this.isCommentsOnlySelected;
		this.dispatchEvent(new CustomEvent("commentsonlytoggle"));
	}

	handleErrorsOnlyToggle() {
		// console.log('fire errors toggle');
		this.isErrorsOnlySelected = !this.isErrorsOnlySelected;
		this.dispatchEvent(new CustomEvent("errorsonlytoggle"));
	}

	handleColumnChange(evt) {
		this.dispatchEvent(
			new CustomEvent("columnselected", {
				detail: {
					column: evt.detail.value
				}
			})
		);
	}

	handleSectionChange(evt) {
		this.dispatchEvent(
			new CustomEvent("sectionselected", {
				detail: {
					section: evt.detail.value
				}
			})
		);
	}
}
