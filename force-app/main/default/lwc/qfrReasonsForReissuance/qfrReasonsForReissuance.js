import { api, wire, LightningElement } from "lwc";
import { OmniscriptBaseMixin } from "omnistudio/omniscriptBaseMixin";
import { publish, MessageContext } from "lightning/messageService";
import getProviderExplanation from "@salesforce/apex/AcfrReviewProviderExplanation.getProviderExplanation";
import QFR_GOTO_CELL from "@salesforce/messageChannel/QFR_Goto_TableCell__c";

const defaultLimit = 5;

export default class QfrReasonsForReissuance extends OmniscriptBaseMixin(
	LightningElement
) {
	@api value;
	@api formReason;
	@api recordId;

	listLimit = true;
	providerExplanationList = new Map();
	totalResponse = 0;

	@wire(MessageContext)
	messageContext;

	@wire(getProviderExplanation, { recordId: "$recordId" })
	wiredProviderExplanation({ error, data }) {
		if (data) {
			this.providerExplanationList = data;
			this.totalResponse = data.length;
			this.error = undefined;
		} else if (error) {
			this.error = error;
			this.providerExplanationList = undefined;
			// console.error("wire error", error);
		}
	}

	get commentList() {
		const list = [];
		if (this.providerExplanationList) {
			this.providerExplanationList.forEach((item) => {
				if (item.qaOutcome && item.qaOutcome.toLowerCase().includes("reject")) {
					const listItem = { ...item, link: `#${item.glcodelineitemId}` };
					list.push(listItem);
				}
			});
		}
		this.totalResponse = list.length;
		if (this.listLimit) {
			list.length = Math.min(list.length, defaultLimit);
		}
		return list;
	}

	get responseCount() {
		return this.totalResponse;
	}

	get showViewAll() {
		return this.responseCount > defaultLimit;
	}

	get showList() {
		return this.commentList.length > 0;
	}

	get showAllLabel() {
		if (this.listLimit) {
			return "View all";
		} else {
			return "Collapse";
		}
	}

	toggleViewAll() {
		this.listLimit = !this.listLimit;
	}

	goToCell(event) {
		const cellId = event.currentTarget.dataset.id;
		const payload = {
			cellId
		};
		publish(this.messageContext, QFR_GOTO_CELL, payload);
	}
}
