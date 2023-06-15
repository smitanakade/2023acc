import { api, LightningElement } from "lwc";
import readXlsxFile from "c/readExcelFile";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class AcfrUploadExcel extends LightningElement {
	@api recordId;
	@api cols;
	colsData;
	@api formType;
	input;
	isCheckboxNotSelected = true;
	handleDragover(event) {
		// prevent default to allow drop
		event.preventDefault();
	}

	async handleUploadFinished(event) {
		const type = this.getExtension(event.detail);

		if (type !== "xlsx") {
			this.dispatchEvent(
				new ShowToastEvent({
					title: "Error",
					message: `This file extension (.${type}) is not supported. Please try again.`,
					variant: "error"
				})
			);
			return;
		}

		const rows = await readXlsxFile(event.detail.files[0]);
		const formId = rows[0][0].replace("ID: ", "");
		const columns = rows[1].length;

		// check form ID
		if (this.recordId !== formId) {
			this.dispatchEvent(
				new ShowToastEvent({
					title: "Error",
					message: `The file and form ID do not match. Please check if you have uploaded the right file.`,
					variant: "error"
				})
			);
			return;
		}

		// check columns
		if (this.cols !== columns - 1) {
			this.dispatchEvent(
				new ShowToastEvent({
					title: "Error",
					message: `The number of columns in the file and form do not match. Please check if you have uploaded the right file.`,
					variant: "error"
				})
			);
			return;
		}

		this.dispatchEvent(
			new CustomEvent("excelupload", {
				detail: {
					data: rows
				},
				composed: true,
				bubbles: true
			})
		);

		this.dispatchEvent(
			new ShowToastEvent({
				title: "Success",
				message: `Spreadsheet uploaded successfully`,
				variant: "success"
			})
		);
	}

	handleCheckbox() {
		this.isCheckboxNotSelected = !this.isCheckboxNotSelected;
	}

	getExtension(fileInfo) {
		const extensionRegex = /(\w+$)/g;
		return fileInfo.value
			? fileInfo.value.match(extensionRegex).toString()
			: fileInfo.files[0].name.match(extensionRegex).toString();
	}

	get checkboxLabel() {
		return `I have read all of the guidelines and understand that data from the uploaded spreadsheet will overwrite any existing values on the "${this.formType}" form.`;
	}
}
