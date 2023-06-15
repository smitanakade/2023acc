// @ts-nocheck
/* eslint-disable no-undef */
/* eslint-disable dot-notation */
/* eslint-disable no-await-in-loop */
import { LightningElement } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { NavigationMixin } from "lightning/navigation";
import { loadScript } from "lightning/platformResourceLoader";
import { parseFormula } from "c/qfrFormulaParser";

import EJS from "@salesforce/resourceUrl/Patched_ExcelJS";
import FS from "@salesforce/resourceUrl/FileSaver";

import getFormIds from "@salesforce/apex/QFRLWCDownloadController.getFormIdsForCase";
import getViabilityForm from "@salesforce/apex/QFRLWCDownloadController.getViabilityResponses";
import getDatatableForm from "@salesforce/apex/AcfrLWCDatatableController.getDatatableDefinitionForForm";
import saveFileToCase from "@salesforce/apex/QFRLWCDownloadController.saveExcelFile";
import loadFileFromCase from "@salesforce/apex/QFRLWCDownloadController.loadExcelFile";

const RESI_VIABILITY = "Residential Viability Reporting";
const HOME_VIABILITY = "Home Care Viability Reporting";
const APPROVED_QFS = "Approved Provider QFS";
const RESI_COST_HOURS = "Resi Labour Costs & Hours";
const HOME_COST_HOURS = "Home Labour Costs & Hours";
const RESI_FOOD = "Resi Food & Nutrition";
const NATSIFACP_FOOD = "NATSIFACP Food & Nutrition";
const MPS_FOOD = "MPS Food & Nutrition";
const PROVIDER_EXPLANATION_TEXT = "Provider's Explanation: ";
const CROSS_VALUE_SHEET = "'" + RESI_COST_HOURS + "'!";
const GREYED_CELL = "GREYED_CELL";
const FORMULA_CELL = "FORMULA_CELL";
const CATEGORY_HEADER = "CATEGORY_HEADER";
const PARENT_CELL = "PARENT_CELL";
const PICKLIST_CELL = "PICKLIST_CELL";
const CROSS_FORM_VALUE = "CROSS_FORM_VALUE";
const CROSS_FORM_EXCEL_CELL = "83";
const ERROR_END = -2;
const CROSS_FORM_ROW = -1;
const STRING_START = 0;
const FIRST_INDEX = 0;
const SECOND_INDEX = 1;
const FIRST_ROW = 1;
const CATEGORY_HEADER_INDEX = 1;
const ONE_ROW_ADJUSTMENT = 1;
const TITLE_ROW = 1;
const FIRST_COLUMN = 2;
const TWO_ROW_ADJUSTMENT = 2;
const VIABILITY_COLUMNS = 6;
const STRING_END = 20;
const LENGTH_OF_ALPHABET = 26;
const ERROR_INDEX = 44;
const QFS_COLUMN_ORDER = [
	"Total",
	"Centrally Held",
	"Residential",
	"Home Care",
	"Community",
	"Retirement",
	"Other"
];

export default class QfrDraftDownload extends NavigationMixin(
	LightningElement
) {
	recordId = this.getUrlParam(window.location.href, "caseId");
	submitting = this.getUrlParam(window.location.href, "submitting");
	viabilityFormResponse;
	datatableFormResponse;
	error;
	formDetails;

	async getFormDetailsData() {
		this.formDetails = await getFormIds({ caseId: this.recordId });
	}

	isComplete = false;

	get loadingInfo() {
		if (this.submitting) {
			return "Saving draft, please wait...";
		} else {
			return "Downloading, please wait...";
		}
	}

	async renderedCallback() {
		if (!this.recordId) {
			return;
		}

		if (!this.formDetails) {
			await this.getFormDetailsData();
		}

		if (
			this.submitting !== "true" &&
			(this.formDetails[FIRST_INDEX].caseStatus === "Re-Submitted" ||
				this.formDetails[FIRST_INDEX].caseStatus === "Submitted")
		) {
			const caseAttachhmentDetails = await this.getContentDocUrl();

			const loadFileResponse = caseAttachhmentDetails.response;
			if (loadFileResponse.includes("errorCode")) {
				const message = loadFileResponse.slice(ERROR_INDEX, ERROR_END);
				this.showToast(message);
			} else {
				window.open(loadFileResponse, "_blank");
			}

			this.returnHome();
		} else {
			// Load JavaScript libraries
			if (!this.isExcelJSLoaded) {
				let scriptLoadFailed = false;
				try {
					await loadScript(this, EJS + "/exceljs.bare.min.js");
				} catch (error) {
					scriptLoadFailed = true;
				}

				try {
					await loadScript(this, FS + "/FileSaver.min.js");
				} catch (error) {
					scriptLoadFailed = true;
				}
				this.isExcelJSLoaded = !scriptLoadFailed;
			}

			// Generate the workbook
			const workbook = new ExcelJS.Workbook();

			// Create the worksheets
			for (const formDetail of this.formDetails) {
				if (formDetail.downloader === "viability") {
					await this.createViabilitySheet(workbook, formDetail);
				} else if (formDetail.downloader === "datatable") {
					await this.createDatatableSheet(workbook, formDetail);
				} else {
					throw new Error("Missing form details.");
				}
			}

			// Save the file
			const form = this.formDetails[0];
			const recordTypename = form.recordTypeName;
			const providerID = form.providerID;
			const currentQuarter = form.currentQuarter;
			const caseStatus = form.caseStatus;
			const submissionCount = form.submissionCount;
			let version = "";
			if (submissionCount !== undefined) {
				version = "V" + submissionCount;
			}
			const fileName =
				recordTypename +
				" " +
				providerID +
				" " +
				currentQuarter +
				" " +
				caseStatus +
				" " +
				version +
				".xlsx";

			if (this.submitting === "true") {
				// Save the file to case
				const xls64 = await workbook.xlsx.writeBuffer({ base64: true });
				const string64 = xls64.toString("base64");

				saveFileToCase({
					recordId: this.recordId,
					b64FileContent: string64,
					fileName: fileName
				});

				this.navigateToConfirmSubmission();
			} else {
				await this.saveFile(fileName, workbook);
				this.returnHome();
			}
		}
	}

	async getContentDocUrl() {
		let response = "";
		await loadFileFromCase({
			recordId: this.recordId
		}).then((result) => {
			response = result;
		});

		return response;
	}

	showToast(message) {
		const event = new ShowToastEvent({
			title: "Error",
			message: message,
			variant: "error"
		});
		dispatchEvent(event);
	}

	getUrlParam(url, key) {
		return new URL(url).searchParams.get(key);
	}

	async createViabilitySheet(workbook, formDetail) {
		// Create a new worksheet
		let sheetName = "";
		if (
			formDetail.formType === "Residential Viability and Prudential Reporting"
		) {
			sheetName = RESI_VIABILITY;
		} else if (
			formDetail.formType === "Home Care Viability and Prudential Reporting"
		) {
			sheetName = HOME_VIABILITY;
		} else {
			sheetName = formDetail.formType.substring(STRING_START, STRING_END);
		}

		const sheet = workbook.addWorksheet(sheetName, {
			views: [{ state: "frozen", ySplit: 1 }]
		});

		// Create the headings
		sheet.columns = [
			{ header: "Question", width: 50 },
			{ header: "Yes/No", width: 10 },
			{ header: "Response Additional Info", width: 30 },
			{ header: "Care Types", width: 20 },
			{ header: "Additional Care Type", width: 20 },
			{ header: "Additional Business Structure", width: 30 }
		];
		sheet.getRow(FIRST_ROW).font = { bold: true };

		for (let col = 0; col < VIABILITY_COLUMNS; col++) {
			const colLetter = this.numberToLetters(col);
			const excelCell = `${colLetter}${FIRST_ROW}`;

			sheet.getCell(excelCell).fill = {
				type: "pattern",
				pattern: "solid",
				fgColor: { argb: "D6EAF8" }
			};
		}

		// Get the responses for the viability form
		const viabilityId = formDetail.formId;
		this.viabilityFormResponse = await getViabilityForm({
			viabilityFormId: viabilityId
		});

		// Write responses to the sheet
		for (let row = 1; row <= this.viabilityFormResponse.length; row++) {
			sheet.getCell(`A${row + ONE_ROW_ADJUSTMENT}`).value =
				this.viabilityFormResponse[row - ONE_ROW_ADJUSTMENT].question;
			sheet.getCell(`B${row + ONE_ROW_ADJUSTMENT}`).value =
				this.viabilityFormResponse[row - ONE_ROW_ADJUSTMENT].response;
			sheet.getCell(`C${row + ONE_ROW_ADJUSTMENT}`).value =
				this.viabilityFormResponse[
					row - ONE_ROW_ADJUSTMENT
				].additionalInformation;
			sheet.getCell(`D${row + ONE_ROW_ADJUSTMENT}`).value =
				this.viabilityFormResponse[row - ONE_ROW_ADJUSTMENT].careServices;
			sheet.getCell(`E${row + ONE_ROW_ADJUSTMENT}`).value =
				this.viabilityFormResponse[
					row - ONE_ROW_ADJUSTMENT
				].additionalCareServices;
			sheet.getCell(`F${row + ONE_ROW_ADJUSTMENT}`).value =
				this.viabilityFormResponse[
					row - ONE_ROW_ADJUSTMENT
				].additionalBusinessStructure;
		}

		return Promise.resolve(sheet);
	}

	async createDatatableSheet(workbook, formDetail) {
		const sheetName = this.generateSheetName(formDetail.formType);
		const datatableId = formDetail.formId;
		let sheet = workbook.addWorksheet(sheetName);
		this.datatableFormResponse = await getDatatableForm({
			recordId: datatableId
		});

		if (
			this.datatableFormResponse.formType ===
			"Approved Provider Quarterly Financial Statements"
		) {
			const newColumnDefinitions = [];
			for (let col = 0; col <= QFS_COLUMN_ORDER.length; col++) {
				this.datatableFormResponse.columnDefinitions.forEach((element) => {
					if (element.name === QFS_COLUMN_ORDER[col]) {
						newColumnDefinitions.push(element);
					}
				});
			}

			this.datatableFormResponse.columnDefinitions = newColumnDefinitions;
		}

		// Create array of cell values
		const dataTableRows = await this.createRowArray(this.datatableFormResponse);
		// Set the properties of the worksheet
		sheet = await this.sheetProperties(sheet);
		// Write column headings
		sheet = await this.writeHeadings(sheet);
		// // Write values to the cells
		sheet = await this.writeCells(sheet, dataTableRows);
		// // Write summation formula to total column
		sheet = await this.writeTotalFormulas(sheet, dataTableRows);

		return Promise.resolve(sheet);
	}

	generateSheetName(formType) {
		let sheetName = "";
		if (formType === "Approved Provider Quarterly Financial Statements") {
			sheetName = APPROVED_QFS;
		} else if (formType === "Residential Labour Costs and Hours") {
			sheetName = RESI_COST_HOURS;
		} else if (formType === "Home Care Labour Costs and Hours") {
			sheetName = HOME_COST_HOURS;
		} else if (formType === "Residential Food and Nutrition Reporting") {
			sheetName = RESI_FOOD;
		} else if (formType === "NATSIFACP Food and Nutrition Reporting") {
			sheetName = NATSIFACP_FOOD;
		} else if (formType === "MPS Food and Nutrition Reporting") {
			sheetName = MPS_FOOD;
		} else {
			sheetName = formType.substring(STRING_START, STRING_END);
		}

		return sheetName;
	}

	async createRowArray(datatableFormResponse) {
		const dataTableRows = [];
		const categories = [
			...new Set(
				datatableFormResponse.rowDefinitions.map((item) => item.category)
			)
		];

		for (let cat = 0; cat < categories.length; cat++) {
			dataTableRows.push([CATEGORY_HEADER, categories[cat]]);

			const categoryRows = datatableFormResponse.rowDefinitions.filter(
				function (item) {
					return item.category === categories[cat];
				}
			);

			for (let row = 0; row < categoryRows.length; row++) {
				const rowArray = [];
				const rowId = categoryRows[row].id;
				rowArray.push(categoryRows[row].name);

				for (
					let col = 0;
					col < datatableFormResponse.columnDefinitions.length;
					col++
				) {
					const cellValue = datatableFormResponse.columnDefinitions[
						col
					].data.find((item) => item.rowDefinitionId === rowId);
					const childCheck = datatableFormResponse.rowDefinitions.some(
						(parentId) => parentId["parentRowId"] === rowId
					);

					if (cellValue === undefined) {
						rowArray.push(GREYED_CELL);
					} else if (categoryRows[row].type === "Picklist") {
						rowArray.push(PICKLIST_CELL);
					} else if (categoryRows[row].formula_string !== undefined) {
						rowArray.push(FORMULA_CELL);
					} else if (childCheck === true) {
						rowArray.push(PARENT_CELL);
					} else if (cellValue.value !== undefined) {
						rowArray.push(cellValue.value);
					} else {
						rowArray.push("");
					}
				}

				dataTableRows.push(rowArray);
			}
		}

		return dataTableRows;
	}

	async sheetProperties(sheet) {
		// Protect the cells
		await sheet.protect("", {
			selectLockedCells: true,
			selectUnlockedCells: true,
			formatColumns: true,
			formatRows: true
		});

		// Freeze header cells
		sheet.views = [{ state: "frozen", xSplit: 1, ySplit: 1 }];

		// Set default column widths
		sheet.getColumn(1).alignment = { wrapText: true };
		sheet.getColumn(1).width = 50;
		sheet.properties.defaultColWidth = 30;

		return Promise.resolve(sheet);
	}

	async writeHeadings(sheet) {
		for (
			let col = 1;
			col <= this.datatableFormResponse.columnDefinitions.length;
			col++
		) {
			const column = this.numberToLetters(col);
			sheet.getCell(`${column}1`).value =
				this.datatableFormResponse.columnDefinitions[
					col - ONE_ROW_ADJUSTMENT
				].name;
		}
		sheet.getRow(TITLE_ROW).font = { bold: true };

		return Promise.resolve(sheet);
	}

	async writeCells(sheet, dataTableRows) {
		let headingCount = 0;
		for (let row = 2; row < dataTableRows.length + TWO_ROW_ADJUSTMENT; row++) {
			if (
				dataTableRows[row - TWO_ROW_ADJUSTMENT][FIRST_INDEX] === CATEGORY_HEADER
			) {
				sheet.getCell(`A${row}`).value =
					dataTableRows[row - TWO_ROW_ADJUSTMENT][CATEGORY_HEADER_INDEX];
				sheet.getCell(`A${row}`).font = {
					size: 16,
					bold: true
				};

				const columnLength =
					this.datatableFormResponse.columnDefinitions.length;

				for (let col = 0; col <= columnLength; col++) {
					const colLetter = this.numberToLetters(col);
					const excelCell = `${colLetter}${row}`;

					sheet.getCell(excelCell).fill = {
						type: "pattern",
						pattern: "solid",
						fgColor: { argb: "D6EAF8" }
					};
				}

				headingCount++;
			} else {
				for (
					let col = 0;
					col < dataTableRows[row - TWO_ROW_ADJUSTMENT].length;
					col++
				) {
					const colLetter = this.numberToLetters(col);
					const cellString = colLetter + row.toString();
					const cellType =
						this.datatableFormResponse.rowDefinitions[
							row - TWO_ROW_ADJUSTMENT - headingCount
						].type;
					const precision =
						this.datatableFormResponse.rowDefinitions[
							row - TWO_ROW_ADJUSTMENT - headingCount
						].precision;
					const adjustedRow = row - TWO_ROW_ADJUSTMENT - headingCount;
					const rowId =
						this.datatableFormResponse.rowDefinitions[
							row - TWO_ROW_ADJUSTMENT - headingCount
						].id;

					if (dataTableRows[row - TWO_ROW_ADJUSTMENT][col] === FORMULA_CELL) {
						const formulaString =
							this.datatableFormResponse.rowDefinitions[
								row - TWO_ROW_ADJUSTMENT - headingCount
							].formula_string;
						const cellFormula = this.createFormula(
							formulaString,
							colLetter,
							dataTableRows
						);
						sheet.getCell(cellString).value = {
							formula: `IFERROR(${cellFormula}, 0)`
						};
					} else if (
						dataTableRows[row - TWO_ROW_ADJUSTMENT][col] === PARENT_CELL
					) {
						const cellFormula = this.parentCellFormula(
							row,
							headingCount,
							colLetter
						);
						sheet.getCell(cellString).value = {
							formula: `IFERROR(${cellFormula}, 0)`
						};
					} else if (
						dataTableRows[row - TWO_ROW_ADJUSTMENT][col] === GREYED_CELL
					) {
						sheet.getCell(cellString).fill = {
							type: "pattern",
							pattern: "solid",
							fgColor: { argb: "E5E5E5" }
						};
					} else if (
						dataTableRows[row - TWO_ROW_ADJUSTMENT][col] === PICKLIST_CELL
					) {
						sheet.getCell(cellString).dataValidation = {
							type: "list",
							allowBlank: true,
							showErrorMessage: true,
							formulae: ['"Cook fresh, Cook chill, Cook freeze"']
						};

						const picklistValue =
							this.datatableFormResponse.columnDefinitions[col - 1].data[
								adjustedRow
							].value;
						if (picklistValue !== null) {
							sheet.getCell(cellString).value = picklistValue;
						}
					} else if (
						this.cellTypeCheck(cellType) &&
						!isNaN(Number(dataTableRows[row - TWO_ROW_ADJUSTMENT][col]))
					) {
						sheet.getCell(cellString).value =
							+dataTableRows[row - TWO_ROW_ADJUSTMENT][col];
						if (dataTableRows[row - TWO_ROW_ADJUSTMENT][col] === "") {
							sheet.getCell(cellString).value = null;
						}
					} else {
						sheet.getCell(cellString).value =
							dataTableRows[row - TWO_ROW_ADJUSTMENT][col];
					}

					if (
						col !== 0 &&
						dataTableRows[row - TWO_ROW_ADJUSTMENT][col] !== GREYED_CELL
					) {
						sheet = await this.formatCell(
							sheet,
							cellString,
							cellType,
							precision
						);
					}

					if (
						col !== 0 &&
						dataTableRows[row - TWO_ROW_ADJUSTMENT][col] !== GREYED_CELL &&
						dataTableRows[row - TWO_ROW_ADJUSTMENT][col] !== FORMULA_CELL &&
						dataTableRows[row - TWO_ROW_ADJUSTMENT][col] !== PARENT_CELL
					) {
						sheet.getCell(cellString).protection = {
							locked: false,
							lockText: false
						};
					}

					if (col !== 0) {
						sheet = await this.addProviderComments(
							sheet,
							rowId,
							col,
							cellString
						);
					}
				}
			}
		}

		return Promise.resolve(sheet);
	}

	createFormula(formulaString, colLetter, dataTableRows) {
		const businessIDs = [];
		const indexArray = [];
		const indexIdPairs = new Map();
		const parsedFormula = parseFormula(formulaString);
		const parsedFormulaIds = [...parsedFormula.sourceIds.entries()];
		let crossFormRow = false;
		for (const rowIndex of parsedFormulaIds) {
			businessIDs.push(rowIndex[FIRST_INDEX]);
		}

		for (const rowIndex of businessIDs) {
			let index = this.datatableFormResponse.rowDefinitions.findIndex(
				(indexID) => indexID.id === rowIndex
			);
			if (index === CROSS_FORM_ROW) {
				index = CATEGORY_HEADER_INDEX;
				crossFormRow = true;
			}
			const rowCategory =
				this.datatableFormResponse.rowDefinitions[index].category;

			let headings = 0;
			for (let i = 0; i < dataTableRows.length; i++) {
				if (dataTableRows[i][FIRST_INDEX] === CATEGORY_HEADER) {
					headings++;
					if (dataTableRows[i][SECOND_INDEX] === rowCategory) {
						break;
					}
				}
			}

			if (crossFormRow === true) {
				indexArray.push(CROSS_FORM_VALUE);
			} else {
				indexArray.push(index + TWO_ROW_ADJUSTMENT + headings);
			}
		}

		for (let i = 0; i < businessIDs.length; i++) {
			indexIdPairs.set(businessIDs[i], indexArray[i]);
		}

		let cellFormula = parsedFormula.excelFormulaGenerator(
			indexIdPairs,
			colLetter
		);

		if (crossFormRow === true) {
			const cellToReplace = colLetter + CROSS_FORM_VALUE;
			const crossFormCell =
				CROSS_VALUE_SHEET + colLetter + CROSS_FORM_EXCEL_CELL;
			cellFormula = cellFormula.replace(cellToReplace, crossFormCell);
		}

		return cellFormula;
	}

	parentCellFormula(row, headingCount, colLetter) {
		const parentId =
			this.datatableFormResponse.rowDefinitions[
				row - TWO_ROW_ADJUSTMENT - headingCount
			].id;
		const childRowIndex = [];
		for (let i = 0; i < this.datatableFormResponse.rowDefinitions.length; i++) {
			if (
				this.datatableFormResponse.rowDefinitions[i].parentRowId === parentId
			) {
				childRowIndex.push(i);
			}
		}

		const excelRows = [];
		for (const childRow of childRowIndex) {
			const excelRow = childRow + headingCount + TWO_ROW_ADJUSTMENT;
			excelRows.push(colLetter + excelRow.toString());
		}

		return excelRows.join("+");
	}

	async cellTypeCheck(cellType) {
		const numericCellTypes = [
			"Currency",
			"Percentage",
			"Minutes",
			"Hrs",
			"Days",
			"Numeric"
		];

		return numericCellTypes.includes(cellType);
	}

	async formatCell(sheet, cellString, cellType, precision) {
		let numDecimalPlaces = "0".repeat(precision);
		if (precision !== 0) {
			numDecimalPlaces = "." + numDecimalPlaces;
		} else {
			numDecimalPlaces = "";
		}

		if (cellType === "Currency") {
			sheet.getCell(cellString).numFmt = "$#,##0" + numDecimalPlaces;
		} else if (cellType === "Percentage") {
			sheet.getCell(cellString).numFmt = "0" + numDecimalPlaces + "\\%";
		} else {
			sheet.getCell(cellString).numFmt = "#,##0" + numDecimalPlaces;
		}

		return Promise.resolve(sheet);
	}

	async writeTotalFormulas(sheet, dataTableRows) {
		const columnLength = this.datatableFormResponse.columnDefinitions.length;
		const finalColumn = this.numberToLetters(columnLength);
		let headerCounter = 0;
		for (let row = 2; row < dataTableRows.length + TWO_ROW_ADJUSTMENT; row++) {
			if (
				dataTableRows[row - TWO_ROW_ADJUSTMENT][FIRST_INDEX] === CATEGORY_HEADER
			) {
				headerCounter = headerCounter + 1;
				continue;
			}
			const totalCheckArray = dataTableRows[row - TWO_ROW_ADJUSTMENT].slice(
				FIRST_COLUMN,
				columnLength
			);
			if (
				dataTableRows[row - TWO_ROW_ADJUSTMENT][FIRST_INDEX] !==
					CATEGORY_HEADER &&
				this.datatableFormResponse.rowDefinitions[
					row - TWO_ROW_ADJUSTMENT - headerCounter
				].formula_string === undefined &&
				this.datatableFormResponse.rowDefinitions[
					row - TWO_ROW_ADJUSTMENT - headerCounter
				].type !== "Picklist" &&
				!totalCheckArray.every((item) => item === GREYED_CELL)
			) {
				const totalCellFormula = `IFERROR(SUM(C${row}:${finalColumn}${row}), 0)`;
				sheet.getCell(`B${row}`).value = { formula: totalCellFormula };
				sheet.getCell(`B${row}`).protection = { locked: true, lockText: true };
			}
		}

		return Promise.resolve(sheet);
	}

	async addProviderComments(sheet, rowId, col, cellString) {
		const columnDefinitionIndex = this.datatableFormResponse.columnDefinitions[
			col - 1
		].data.findIndex((indexID) => indexID.rowDefinitionId === rowId);

		if (columnDefinitionIndex !== -1) {
			const providerCommentCell =
				this.datatableFormResponse.columnDefinitions[col - 1].data[
					columnDefinitionIndex
				];
			const providerExplanation = providerCommentCell.providerExplanation;

			if (
				providerCommentCell !== undefined &&
				providerExplanation !== undefined
			) {
				sheet.getCell(cellString).note = {
					texts: [
						{ font: { bold: true }, text: PROVIDER_EXPLANATION_TEXT },
						{ text: providerExplanation }
					],
					protection: {
						locked: true,
						lockText: true
					}
				};
			}
		}

		return Promise.resolve(sheet);
	}

	numberToLetters(num) {
		let letters = "";
		while (num >= FIRST_INDEX) {
			letters =
				"ABCDEFGHIJKLMNOPQRSTUVWXYZ"[num % LENGTH_OF_ALPHABET] + letters;
			num = Math.floor(num / LENGTH_OF_ALPHABET) - ONE_ROW_ADJUSTMENT;
		}
		return letters;
	}

	async saveFile(fileName, workbook) {
		const xls64 = await workbook.xlsx.writeBuffer({ base64: true });
		loadScript(this, FS + "/FileSaver.min.js").then(() => {
			saveAs(new Blob([xls64], { type: "application/octet-stream" }), fileName);
		});
	}

	returnHome() {
		this[NavigationMixin.Navigate]({
			type: "comm__namedPage",
			attributes: {
				name: "Financial_Reporting__c"
			}
		});
	}

	navigateToConfirmSubmission() {
		this[NavigationMixin.Navigate]({
			type: "comm__namedPage",
			attributes: {
				name: "QFR_Submission_Confirmation__c"
			},
			state: {
				caseId: this.recordId
			}
		});
	}
}
