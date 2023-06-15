/* eslint-disable no-undef */
/* eslint-disable no-useless-assign/no-useless-assign */
/* eslint-disable no-await-in-loop */
/* eslint-disable dot-notation */
// @ts-nocheck
import { LightningElement, api } from "lwc";
import { OmniscriptBaseMixin } from "omnistudio/omniscriptBaseMixin";
import { loadScript } from "lightning/platformResourceLoader";
import { parseFormula } from "c/qfrTemplateFormulaParser";

const GREYED_CELL = "GREYED_CELL";
const FORMULA_CELL = "FORMULA_CELL";
const CATEGORY_HEADER = "CATEGORY_HEADER";
const PARENT_CELL = "PARENT_CELL";
const PICKLIST_CELL = "PICKLIST_CELL";
const CROSS_FORM_VALUE = "Cross Form Value";
const SHEET_NAME = "Template";
const CROSS_FORM_ROW = -1;
const FIRST_INDEX = 0;
const SECOND_INDEX = 1;
const CATEGORY_HEADER_INDEX = 1;
const ONE_ROW_ADJUSTMENT = 1;
const TITLE_ROW = 2;
const FIRST_COLUMN = 2;
const TWO_ROW_ADJUSTMENT = 2;
const THREE_ROW_ADJUSTMENT = 3;
const LENGTH_OF_ALPHABET = 26;
const QFS_COLUMN_ORDER = [
	"Total",
	"Centrally Held",
	"Residential",
	"Home Care",
	"Community",
	"Retirement",
	"Other"
];

export default class QfrDownloadExcel extends OmniscriptBaseMixin(
	LightningElement
) {
	@api formId;
	@api formType;

	formResponse;
	crossFormValues;
	crossFormCall = false;

	fileSaverUrl = "/serviceproviderportal/resource/FileSaver";
	excelJSUrl = "/serviceproviderportal/resource/Patched_ExcelJS";

	async download() {
		// Load form response
		const remoteCallParams = this.createTableCallParams(this.formId);
		const response = await this.retrieveForm(remoteCallParams);
		this.formResponse = response.result.datatableDefinition;

		if (
			this.formResponse.formType ===
			"Approved Provider Quarterly Financial Statements"
		) {
			const newColumnDefinitions = [];
			for (let col = 0; col <= QFS_COLUMN_ORDER.length; col++) {
				this.formResponse.columnDefinitions.forEach((element) => {
					if (element.name === QFS_COLUMN_ORDER[col]) {
						newColumnDefinitions.push(element);
					}
				});
			}

			this.formResponse.columnDefinitions = newColumnDefinitions;
		}

		// Create the workbook
		await loadScript(this, this.excelJSUrl + "/exceljs.bare.min.js");
		const workbook = new ExcelJS.Workbook();

		// Create the sheet
		await this.createTemplate(workbook);

		// Save the file
		const filename = this.formType + " Template.xlsx";
		await this.saveFile(filename, workbook);
	}

	async createTemplate(workbook) {
		let sheet = workbook.addWorksheet(SHEET_NAME);

		// Create array of cell values
		const dataTableRows = await this.createRowArray();
		// Write form ID in first cell
		sheet = await this.writeFormId(sheet);
		// Set the properties of the worksheet
		sheet = await this.sheetProperties(sheet);
		// Write column headings
		sheet = await this.writeHeadings(sheet);
		// Write values to the cells
		sheet = await this.writeCells(sheet, dataTableRows);
		// Write summation formula to total column
		sheet = await this.writeTotalFormulas(sheet, dataTableRows);

		return Promise.resolve(sheet);
	}

	async createRowArray() {
		const dataTableRows = [];
		const categories = [
			...new Set(this.formResponse.rowDefinitions.map((item) => item.category))
		];

		for (let cat = 0; cat < categories.length; cat++) {
			dataTableRows.push([CATEGORY_HEADER, categories[cat]]);

			const categoryRows = this.formResponse.rowDefinitions.filter(function (
				item
			) {
				return item.category === categories[cat];
			});

			for (let row = 0; row < categoryRows.length; row++) {
				const rowArray = [];
				const rowId = categoryRows[row].id;
				rowArray.push(categoryRows[row].name);

				for (
					let col = 0;
					col < this.formResponse.columnDefinitions.length;
					col++
				) {
					const cellValue = this.formResponse.columnDefinitions[col].data.find(
						(item) => item.rowDefinitionId === rowId
					);
					const childCheck = this.formResponse.rowDefinitions.some(
						(parentId) => parentId["parentRowId"] === rowId
					);

					if (cellValue === undefined) {
						rowArray.push(GREYED_CELL);
					} else if (categoryRows[row].type === "Picklist") {
						rowArray.push(PICKLIST_CELL);
					} else if (categoryRows[row].formula_string !== null) {
						rowArray.push(FORMULA_CELL);
					} else if (childCheck === true) {
						rowArray.push(PARENT_CELL);
					} else if (cellValue.value !== null) {
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

	async writeFormId(sheet) {
		sheet.getCell("A1").value = "ID: " + this.formId;
		return Promise.resolve(sheet);
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
			col <= this.formResponse.columnDefinitions.length;
			col++
		) {
			const column = this.numberToLetters(col);
			sheet.getCell(`${column}1`).value =
				this.formResponse.columnDefinitions[col - ONE_ROW_ADJUSTMENT].name;
		}
		sheet.getRow(TITLE_ROW).font = { bold: true };

		return Promise.resolve(sheet);
	}

	async writeCells(sheet, dataTableRows) {
		let headingCount = 0;
		for (
			let row = 3;
			row < dataTableRows.length + THREE_ROW_ADJUSTMENT;
			row++
		) {
			if (
				dataTableRows[row - THREE_ROW_ADJUSTMENT][FIRST_INDEX] ===
				CATEGORY_HEADER
			) {
				sheet.getCell(`A${row - ONE_ROW_ADJUSTMENT}`).value =
					dataTableRows[row - THREE_ROW_ADJUSTMENT][CATEGORY_HEADER_INDEX];
				sheet.getCell(`A${row - ONE_ROW_ADJUSTMENT}`).font = {
					size: 16,
					bold: true
				};

				const columnLength = this.formResponse.columnDefinitions.length;

				for (let col = 0; col <= columnLength; col++) {
					const colLetter = this.numberToLetters(col);
					const excelCell = `${colLetter}${row - ONE_ROW_ADJUSTMENT}`;

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
					col < dataTableRows[row - THREE_ROW_ADJUSTMENT].length;
					col++
				) {
					const colLetter = this.numberToLetters(col);
					const cellString = colLetter + (row - ONE_ROW_ADJUSTMENT).toString();
					const cellType =
						this.formResponse.rowDefinitions[
							row - THREE_ROW_ADJUSTMENT - headingCount
						].type;
					const precision =
						this.formResponse.rowDefinitions[
							row - THREE_ROW_ADJUSTMENT - headingCount
						].precision;
					const adjustedRow = row - THREE_ROW_ADJUSTMENT - headingCount;

					if (dataTableRows[row - THREE_ROW_ADJUSTMENT][col] === FORMULA_CELL) {
						const formulaString =
							this.formResponse.rowDefinitions[
								row - THREE_ROW_ADJUSTMENT - headingCount
							].formula_string;
						const cellFormula = await this.createFormula(
							formulaString,
							col,
							colLetter,
							dataTableRows
						);
						sheet.getCell(cellString).value = {
							formula: `IFERROR(${cellFormula}, 0)`
						};
					} else if (
						dataTableRows[row - THREE_ROW_ADJUSTMENT][col] === PARENT_CELL
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
						dataTableRows[row - THREE_ROW_ADJUSTMENT][col] === GREYED_CELL
					) {
						sheet.getCell(cellString).fill = {
							type: "pattern",
							pattern: "solid",
							fgColor: { argb: "E5E5E5" }
						};
					} else if (
						dataTableRows[row - THREE_ROW_ADJUSTMENT][col] === PICKLIST_CELL
					) {
						sheet.getCell(cellString).dataValidation = {
							type: "list",
							allowBlank: true,
							showErrorMessage: true,
							formulae: ['"Cook fresh, Cook chill, Cook freeze"']
						};

						const picklistValue =
							this.formResponse.columnDefinitions[col - 1].data[adjustedRow]
								.value;
						if (picklistValue !== null) {
							sheet.getCell(cellString).value = picklistValue;
						}
					} else if (
						this.cellTypeCheck(cellType) &&
						!isNaN(Number(dataTableRows[row - THREE_ROW_ADJUSTMENT][col]))
					) {
						sheet.getCell(cellString).value =
							+dataTableRows[row - THREE_ROW_ADJUSTMENT][col];
						if (dataTableRows[row - THREE_ROW_ADJUSTMENT][col] === "") {
							sheet.getCell(cellString).value = null;
						}
					} else {
						sheet.getCell(cellString).value =
							dataTableRows[row - THREE_ROW_ADJUSTMENT][col];
					}

					if (
						col !== 0 &&
						dataTableRows[row - THREE_ROW_ADJUSTMENT][col] !== GREYED_CELL
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
						dataTableRows[row - THREE_ROW_ADJUSTMENT][col] !== GREYED_CELL &&
						dataTableRows[row - THREE_ROW_ADJUSTMENT][col] !== FORMULA_CELL &&
						dataTableRows[row - THREE_ROW_ADJUSTMENT][col] !== PARENT_CELL
					) {
						sheet.getCell(cellString).protection = {
							locked: false,
							lockText: false
						};
					}
				}
			}
		}

		return Promise.resolve(sheet);
	}

	async createFormula(formulaString, col, colLetter, dataTableRows) {
		const businessIDs = [];
		const indexArray = [];
		const indexIdPairs = new Map();
		const parsedFormula = parseFormula(formulaString);
		const parsedFormulaIds = [...parsedFormula.sourceIds.entries()];
		let crossFormRow = false;
		let crossFormCell = null;
		let crossFormValue = 0;

		for (const rowIndex of parsedFormulaIds) {
			businessIDs.push(rowIndex[FIRST_INDEX]);
		}

		for (const rowIndex of businessIDs) {
			let index = this.formResponse.rowDefinitions.findIndex(
				(indexID) => indexID.id === rowIndex
			);

			if (index === CROSS_FORM_ROW) {
				index = CATEGORY_HEADER_INDEX;
				crossFormRow = true;

				if (this.crossFormCall === false) {
					const crossFormRowId = [];
					crossFormRowId.push(rowIndex);
					const remoteCallParams = this.createCrossTableParams(
						this.formId,
						crossFormRowId
					);
					const response = await this.retrieveForm(remoteCallParams);
					this.crossFormValues = response.result.datatableDefinitions.find(
						(item) => item.columnDefinitions[0] !== undefined
					);
					this.crossFormCall = true;
				}

				crossFormValue =
					this.crossFormValues.columnDefinitions[col - 1].data[0].value;
			}

			const rowCategory = this.formResponse.rowDefinitions[index].category;

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
				crossFormCell = colLetter + CROSS_FORM_VALUE;
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
		if (crossFormCell !== null) {
			cellFormula = cellFormula.replace(crossFormCell, crossFormValue);
		}

		return cellFormula;
	}

	parentCellFormula(row, headingCount, colLetter) {
		const parentId =
			this.formResponse.rowDefinitions[
				row - THREE_ROW_ADJUSTMENT - headingCount
			].id;
		const childRowIndex = [];
		for (let i = 0; i < this.formResponse.rowDefinitions.length; i++) {
			if (this.formResponse.rowDefinitions[i].parentRowId === parentId) {
				childRowIndex.push(i);
			}
		}

		const excelRows = [];
		for (const childRow of childRowIndex) {
			const excelRow = childRow + headingCount + TITLE_ROW;
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
		const columnLength = this.formResponse.columnDefinitions.length + 1;
		const finalColumn = this.numberToLetters(columnLength);
		let headingCount = 0;

		for (
			let row = 3;
			row < dataTableRows.length + THREE_ROW_ADJUSTMENT;
			row++
		) {
			if (
				dataTableRows[row - THREE_ROW_ADJUSTMENT][FIRST_INDEX] ===
				CATEGORY_HEADER
			) {
				headingCount = headingCount + 1;
				continue;
			}
			const totalCheckArray = dataTableRows[row - THREE_ROW_ADJUSTMENT].slice(
				FIRST_COLUMN,
				columnLength
			);
			if (
				dataTableRows[row - THREE_ROW_ADJUSTMENT][FIRST_INDEX] !==
					CATEGORY_HEADER &&
				this.formResponse.rowDefinitions[
					row - THREE_ROW_ADJUSTMENT - headingCount
				].formula_string === null &&
				this.formResponse.rowDefinitions[
					row - THREE_ROW_ADJUSTMENT - headingCount
				].type !== "Picklist" &&
				!totalCheckArray.every((item) => item === GREYED_CELL)
			) {
				const totalCellFormula = `IFERROR(SUM(C${
					row - ONE_ROW_ADJUSTMENT
				}:${finalColumn}${row - ONE_ROW_ADJUSTMENT}), 0)`;
				sheet.getCell(`B${row - ONE_ROW_ADJUSTMENT}`).value = {
					formula: totalCellFormula
				};
				sheet.getCell(`B${row - ONE_ROW_ADJUSTMENT}`).protection = {
					locked: true,
					lockText: true
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

	async retrieveForm(remoteCallParams) {
		return this.omniRemoteCall(remoteCallParams, false);
	}

	createTableCallParams(formId) {
		const args = {
			formId: formId
		};
		const options = {};
		const remoteCallParams = {
			input: JSON.stringify(args),
			sClassName: "AcfrCustomDatatableController",
			sMethodName: "getDatatableDefinitionForForm",
			options: JSON.stringify(options)
		};
		return remoteCallParams;
	}

	createCrossTableParams(formId, missingSourceRowIds) {
		const args = {
			formId: formId,
			glCodeBusinessIds: missingSourceRowIds
		};
		const options = {};
		const remoteCallParams = {
			input: JSON.stringify(args),
			sClassName: "AcfrCustomDatatableController",
			sMethodName: "getCrossFormRowDefinitions",
			options: JSON.stringify(options)
		};
		return remoteCallParams;
	}

	async saveFile(filename, workbook) {
		const xls64 = await workbook.xlsx.writeBuffer({ base64: true });
		loadScript(this, this.fileSaverUrl + "/FileSaver.min.js").then(() => {
			saveAs(new Blob([xls64], { type: "application/octet-stream" }), filename);
		});
	}
}
