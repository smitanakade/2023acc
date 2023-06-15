import { LightningElement, api, wire, track } from "lwc";
import getProviderExplanation from "@salesforce/apex/AcfrReviewProviderExplanation.getProviderExplanation";
import { refreshApex } from "@salesforce/apex";
import { dynamicSort } from "c/jsUtils";

const providerExplanation = [
	{ label: "Service", fieldName: "serviceName", sortable: true },
	{ label: "Data Input", fieldName: "dataInput" },
	{
		label: "Provider Explanation",
		fieldName: "providerExplanation",
		wrapText: true
	},
	{ label: "QA Outcome", fieldName: "qaOutcome" },
	{
		label: "QA External Comments",
		fieldName: "qaExternalComments",
		wrapText: true
	},
	{
		label: "Amended Explanation",
		fieldName: "amendedExplanation",
		wrapText: true
	}
];

const defaultLimit = 5;

export default class QfrQaOutcomes extends LightningElement {
	@api recordId;
	@api value;
	@track providerExplanationList = new Map();

	columns = providerExplanation;
	listLimit = true;
	sortBy = "qaOutcome";
	isLoading = true;

	totalResponses = 0;
	selectedRow;

	modalIsOpen = false;

	//get list of provider explanation
	@wire(getProviderExplanation, { recordId: "$recordId" })
	wiredProviderExplanation({ error, data }) {
		if (data) {
			this.providerExplanationList = data;
			this.totalResponses = data.length;
			this.error = undefined;
		} else if (error) {
			this.error = error;
			this.providerExplanationList = undefined;
		}
		this.isLoading = false;
	}

	cleanUpErrorMessage(array) {
		const validations = [];
		const regex = /(Please review.*$)/g;
		array.forEach((item) => {
			const obj = {
				...item,
				validation: item.errorMessage && item.errorMessage.replace(regex, "")
			};
			validations.push(obj);
		});
		return validations;
	}

	get explanationList() {
		let sorted;
		if (this.isLoading) {
			sorted = [];
		} else {
			sorted = [...this.providerExplanationList].sort(dynamicSort(this.sortBy));
			sorted = this.cleanUpErrorMessage(sorted);
			if (this.listLimit) {
				sorted.length = Math.min(sorted.length, defaultLimit);
			}
		}
		return sorted;
	}

	get showTable() {
		return this.totalResponses > 0;
	}

	get showViewAll() {
		return this.totalResponses > defaultLimit;
	}

	get showAllLabel() {
		if (this.listLimit) {
			return "View all";
		} else {
			return "Collapse";
		}
	}

	get sortedColumnName() {
		const addSpace = /([A-Z])([A-Z])([a-z])|([a-z])([A-Z])/g;
		let result = this.sortBy.replace(addSpace, "$1$4 $2$3$5");
		const firstLetter = /(\b[a-z](?!\s))/g;
		result = result.replace(firstLetter, function (x) {
			return x.toUpperCase();
		});
		return result.replace("Qa", "QA");
	}

	sortColumn(event) {
		this.sortBy = event.currentTarget.dataset.sort;
	}

	toggleViewAll() {
		this.listLimit = !this.listLimit;
	}

	closeModal() {
		this.modalIsOpen = false;
		this.selectedRow = undefined;
	}

	selectRow(event) {
		const id = event.currentTarget.dataset.id;
		const selectedRow = this.providerExplanationList.find(
			(item) => item.glcodelineitemId === id
		);
		this.selectedRow = selectedRow;
		this.modalIsOpen = true;
	}

	async refresh() {
		await refreshApex(this.providerExplanationList);
	}

	get qaOutcomeArrowColor() {
		if (this.sortBy === "qaOutcome") {
			return "#000";
		} else {
			return "#ccc";
		}
	}

	get serviceNameArrowColor() {
		if (this.sortBy === "serviceName") {
			return "#000";
		} else {
			return "#ccc";
		}
	}
}
