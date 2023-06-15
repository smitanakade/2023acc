import { LightningElement, api, wire } from "lwc";
import QFR_GOTO_CELL from "@salesforce/messageChannel/QFR_Goto_TableCell__c";
import { subscribe, MessageContext } from "lightning/messageService";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { OmniscriptBaseMixin } from "omnistudio/omniscriptBaseMixin";
import { parseFormula } from "c/formulaParser";
import { debounce } from "c/jsUtils";
import Logger from "c/logger";
import { Cell, getHiddenCell } from "./Cell";
import { SELECTORS, DIRECTIONS, STR } from "./constants";
/**
 * @typedef {import("./types").GL_Code_Line_Item__c} GL_Code_Line_Item__c
 * @typedef {import("./types").TableCellResult} TableCellResult
 * @typedef {import("./types").Category} Category
 * @typedef {import("./types").Row} Row
 * @typedef {import("./types").RowDefinition} RowDefinition
 * @typedef {import("./types").FormulaInfo} FormulaInfo
 * @typedef {import("./types").ColumnDefinition} ColumnDefinition
 */

const AUTOSAVE_DEBOUNCE_MS = 300;
const TO_FIXED = 2;
const QFR = "Quarterly Financial Report";
const APEX_CONTROLLER_CLASS_NAME = "AcfrCustomDatatableController";
const QFS_COLUMN_ORDER = [
	"Total",
	"Centrally Held",
	"Residential",
	"Home Care",
	"Community",
	"Retirement",
	"Other"
];

const negativeValuesAllowedCategories = new Set(["Equity"]);

export default class omniProviderDatatable extends OmniscriptBaseMixin(
	LightningElement
) {
	@api
	recordId = "a2Y9h0000000KMyEAM";
	@api
	isReadOnly = false;
	@api
	showToggles = false;

	formType;
	initComplete = false;
	isExpanded = false;
	errorsOnly = false;
	rejectedOnly = false;
	errorMessage = "";
	providerExplanation = "";
	firstLoad = true;
	glCodeLineItemsToBeExempted = [];
	errorColumns = [];
	rejectedColumns = [];

	logger = new Logger();

	@wire(MessageContext)
	messageContext;

	subscribeToMessageChannel() {
		this.subscription = subscribe(
			this.messageContext,
			QFR_GOTO_CELL,
			(message) => this.scrollToCell(message)
		);
	}

	/** @type {ColumnDefinition[]} */
	cols = [];
	get displayCols() {
		this.errorColumns = [];
		let hasAnyInvalidCell = false;
		if (this.errorsOnly) {
			this.checkErrorCol(this.cols);
			this.cols.forEach((element) => {
				if (element.hasInvalidCell) {
					hasAnyInvalidCell = true;
				}
			});

			if (!hasAnyInvalidCell && !this.isExpanded) {
				const evt = new ShowToastEvent({
					title: "",
					message: "No errors in this section",
					variant: "success"
				});
				this.dispatchEvent(evt);
			}
			return [
				{ id: "topleft_blank", Name: "" },
				...this.cols.filter((col) => col.hasInvalidCell)
			];
		}
		this.rejectedColumns = [];
		if (this.rejectedOnly) {
			this.getRejectedColumns(this.cols);
			const columns = this.cols.filter((_el, i) =>
				this.rejectedColumns.some((j) => i === j)
			);
			if (this.rejectedColumns.length === 0) {
				const evt = new ShowToastEvent({
					title: "",
					message: "No comments in this section",
					variant: "success"
				});
				this.dispatchEvent(evt);
			}
			return [{ id: "topleft_blank", Name: "" }, ...columns];
		}
		return [{ Id: 0, Name: "" }, ...this.cols];
	}

	get colOptions() {
		return this.cols?.map((col) => col.name) ?? [];
	}

	/** @type {string[]} */
	#rowOptions = [];
	get rowOptions() {
		if (this.#rowOptions.length === 0) {
			this.#rowOptions =
				this.categories?.map((category) => category.name) || [];
		}

		return this.#rowOptions;
	}

	get datatableContainerClass() {
		return "datatable-container" + (this.isExpanded ? " expanded-view" : "");
	}

	/** @type {Category[]} */
	categories = [];

	/** @type {Object.<string, Category>} */
	categoriesById = {};

	/** @type {Map<string, Row>} */
	rowsById = new Map();

	/** @type {Map<string, FormulaInfo[]>}*/
	formulaeBySourceRowId;

	/** @type {{[x: string]: GL_Code_Line_Item__c}} */
	// changedCells = {};

	/** @type {Map<String, Cell>} */
	cellsById = new Map();

	/** @type {Map<String, Cell[]>} */
	cellsByRowId = new Map();

	/** @type {Map<string, import("./types").RowDefinition>} */
	rowDefinitionsById = new Map();
	rowIdToParentId = new Map();

	isSaving = false;

	/** @type {string} */
	lastSavedDate;

	/** @type {Map<string, import("./types").ValidationFormula[]>} */
	validationFormulaBySourceRowId = new Map();

	// PBI 309400 - For Cross form
	crossFormBusinessIds = [];
	presentBusinessIds = [];
	crossFormColumnsByGLCodeId = new Map();

	sourceFinancialRules = [];
	targetFinancialRules = [];
	crossFormGlCodesLineItems = [];
	crossFormGlCodesLineItemIds = [];
	financialReportingRules = [];

	get saveInformation() {
		if (this.isSaving) {
			return `Saving changes...`;
		}
		if (this.lastSavedDate) {
			return `Last saved at ${this.lastSavedDate}`;
		}
		return "Up to date.";
	}

	async connectedCallback() {
		this.firstLoad = true;
		this.subscribeToMessageChannel();
		if (this.recordId) {
			await this.initialiseForRecord();
		} else {
			this.errorMessage = "No form found.";
		}
		this.initComplete = true;
	}

	async initialiseForRecord() {
		const {
			columnDefinitions,
			rowDefinitions,
			isReadOnly,
			formType,
			financialReportingRules,
			quarter,
			glCodeLineItemsToBeExempted
		} = await this.getDatatableDefinition();

		this.financialReportingRules = financialReportingRules;
		this.glCodeLineItemsToBeExempted = glCodeLineItemsToBeExempted;

		if (!columnDefinitions || columnDefinitions.length === 0) {
			this.errorMessage = "There was an error loading the form.";
			return;
		}
		let omniReadOnly = this.omniJsonData.isReadOnly;
		if (omniReadOnly === "false") {
			omniReadOnly = false;
		}
		// eslint-disable-next-line @lwc/lwc/no-api-reassignments
		this.isReadOnly = omniReadOnly || this.isReadOnly || isReadOnly; // either the input parameter or the apex method can set readonly
		await this.initialiseValidationRules(
			financialReportingRules,
			quarter,
			rowDefinitions
		);
		this.createColumnsForRecord(columnDefinitions);
		await this.initialiseRows(rowDefinitions, columnDefinitions);
		this.formType = formType;

		const inputCells = [];
		for (const column of columnDefinitions) {
			for (const [index, cell] of column.data.entries()) {
				if (
					!(column.cells[index].cellReadOnly || column.cells[index].isHidden)
				) {
					const cellId = cell.id;
					const cellValue = cell.value;
					const cellProviderExplanation = cell.providerExplanation;
					const cellQaOutcome = cell.qaOutcome;
					const cellQaComments = cell.qaComments;
					inputCells.push({
						cellId: cellId,
						value: cellValue,
						providerExplanation: cellProviderExplanation,
						qaOutcome: cellQaOutcome,
						qaComments: cellQaComments
					});
				}
			}
		}

		this.updateCells(inputCells);
	}

	async initialiseDefault() {
		const glCodes = await this.getGlCodes();
		this.createDefaultColumns();
		this.initialiseRows(glCodes, []);
	}

	async getGlCodes() {
		const args = {
			formType: QFR
		};
		const options = {}; // Options for Vlocity GenericInvoke eg queueable, future, continuation

		/** @type  {import("omnistudio").OmniRemoteCallParams} */
		const remoteCallParams = {
			input: JSON.stringify(args),
			sClassName: APEX_CONTROLLER_CLASS_NAME,
			sMethodName: "getGLCodesForFormType",
			options: JSON.stringify(options)
		};
		const { result } = await this.omniRemoteCall(remoteCallParams, false);
		return [...result.glCodes];
	}

	async getDatatableDefinition() {
		const args = {
			formId: this.recordId
		};
		const options = {};
		/** @type {import("omnistudio").OmniRemoteCallParams} */
		const remoteCallParams = {
			input: JSON.stringify(args),
			sClassName: APEX_CONTROLLER_CLASS_NAME,
			sMethodName: "getDatatableDefinitionForForm",
			options: JSON.stringify(options)
		};

		const { result, error } = await this.omniRemoteCall(
			remoteCallParams,
			false
		);
		if (error) {
			this.logger.error(
				`An error occurred in a remote call. Details: ${JSON.stringify(result)}`
			);
		}

		if (
			result.datatableDefinition.formType ===
			"Approved Provider Quarterly Financial Statements"
		) {
			const newColumnDefinitions = [];
			for (let col = 0; col <= QFS_COLUMN_ORDER.length; col++) {
				result.datatableDefinition.columnDefinitions.forEach((element) => {
					if (element.name === QFS_COLUMN_ORDER[col]) {
						newColumnDefinitions.push(element);
					}
				});
			}

			result.datatableDefinition.columnDefinitions = newColumnDefinitions;
		}

		return result.datatableDefinition;
	}

	/**
	 * @param {ColumnDefinition[]} columnDefinitions
	 */
	createColumnsForRecord(columnDefinitions) {
		const classdescriptor = {
			get() {
				return `table-header-cell slds-text-heading_small slds-text-align_right ${
					this.hasInvalidCell ? " table-col-invalid" : ""
				}`;
			}
		};
		const hasInvalidCellDescriptor = {
			get() {
				return (
					this.cells &&
					this.cells.some(
						(cell) =>
							!cell.isValid && cell.showErrors && !cell.providerExplanation
					)
				);
			}
		};

		columnDefinitions.forEach(
			(/** @type {ColumnDefinition} */ colDef, _index) => {
				colDef.showToggle = colDef.isToggled;
				Object.defineProperty(colDef, "class", classdescriptor);
				Object.defineProperty(
					colDef,
					"hasInvalidCell",
					hasInvalidCellDescriptor
				);
			}
		);
		this.cols = columnDefinitions;

		return columnDefinitions;
	}

	createDefaultColumns() {
		const numCols = 10;
		// Blank top left column
		const columns = [];
		for (let i = 1; i < numCols; i++) {
			columns.push({
				id: "" + i,
				name: `Aged Care Service ${i}`,
				showToggle: false
			});
		}
		this.cols = columns;
		return columns;
	}

	/** @type {Cell[]} */
	_createBlankCells;

	/**
	 * @param {number} numCells
	 * @returns {Cell[]}
	 */
	createBlankCells() {
		if (this._createBlankCells) {
			return this._createBlankCells;
		}

		/** @type {Cell[]} */
		const cells = [];
		this._createBlankCells = cells;
		return cells;
	}

	initialiseCrossFormGlCodeLineItems(
		financialReportingRules,
		_columnDefinitions
	) {
		const crossIdCollection = [];
		financialReportingRules.forEach((frr) =>
			_columnDefinitions.forEach((column) => {
				if (frr.column === column.name) {
					column.data.forEach((cell) => {
						if (
							cell.rowDefinitionId === frr.businessId &&
							cell.value !== null &&
							!crossIdCollection.includes(cell.id)
						) {
							const cellItemValue = {
								id: cell.id,
								businessId: cell.rowDefinitionId,
								column: column.name,
								value: cell.value !== null ? cell.value : "0",
								errorMessage: frr.errorMessage,
								hardValidation: frr.hardValidation
							};
							this.crossFormGlCodesLineItems.push(cellItemValue);
							this.crossFormGlCodesLineItemIds.push(cell.id);
							crossIdCollection.push(cell.id);
						}
					});
				}
			})
		);
	}

	/**
	 * @param {import("./types").RowDefinition[]} rowDefinitions
	 * @param {ColumnDefinition[]} columnDefinitions
	 */
	async initialiseRows(rowDefinitions, columnDefinitions) {
		this.initialiseCrossFormGlCodeLineItems(
			this.sourceFinancialRules,
			columnDefinitions
		);

		this.initialiseRowDefinitionMaps(rowDefinitions);
		/** @type {Object.<string, Category>} */
		const categoriesById = {};
		/** @type {Map<string, Cell[]>} */
		const cellsByRowId = this.createCellsAndMapToRows(
			columnDefinitions,
			this.rowDefinitionsById
		);
		/** @type {Map<string, Row>} */

		const rowsById = new Map();
		// pass in component property to category getter
		let errorsOnly = () => {
			return this.errorsOnly;
		};
		errorsOnly = errorsOnly.bind(this);
		let errorColumns = () => {
			return this.errorColumns;
		};
		errorColumns = errorColumns.bind(this);

		let rejectedOnly = () => {
			return this.rejectedOnly;
		};
		rejectedOnly = rejectedOnly.bind(this);
		let rejectedColumns = () => {
			return this.rejectedColumns;
		};
		rejectedColumns = rejectedColumns.bind(this);

		rowDefinitions.forEach((rowDef) => {
			const entries = columnDefinitions
				? cellsByRowId.get(rowDef.id)
				: this.createBlankCells();
			/** @type {Row} */
			const row = {
				id: rowDef.id,
				name: rowDef.name,
				entries,
				get displayEntries() {
					if (errorsOnly()) {
						return this.entries.filter((_cell, index) =>
							errorColumns().some((col) => parseInt(col, 10) === index)
						);
					}
					if (rejectedOnly()) {
						return this.entries.filter((_cell, index) =>
							rejectedColumns().some((col) => parseInt(col, 10) === index)
						);
					}
					return this.entries;
				},
				inlineStyle: `padding-left: ${rowDef.depth}em`,
				parentRowId: rowDef.parentRowId,
				formula_string: rowDef.formula_string,
				get isReadOnly() {
					return (
						!!this.formula_string ||
						(rowDef.childRows && rowDef.childRows.length > 0)
					);
				},
				get hasInvalidCell() {
					return this.displayEntries.length > 0;
				}
			};
			rowsById.set(row.id, row);

			if (categoriesById[rowDef.category]) {
				const cat = categoriesById[rowDef.category];
				cat.rows.push(row);
				cat.order = Math.min(cat.order, rowDef.order);
			} else {
				categoriesById[rowDef.category] = {
					name: rowDef.category,
					rows: [row],
					get displayRows() {
						return this.rows;
					},
					order: rowDef.order,
					isExpanded: true
				};
			}
		});

		for (const [_, row] of rowsById) {
			row.parentRow = rowsById.get(row.parentRowId);
		}

		this.rowsById = rowsById;
		this.categoriesById = categoriesById;

		// display categories in min display order of contents
		const categoriesArray = Object.values(categoriesById);
		categoriesArray.sort((a, b) => a.order - b.order);
		this.categories = categoriesArray;
		await this.retrieveCrossFormFormulaDataNew();
		const cellsToValidates = this.getCellsToValidate(this.rowsById);
		this.runValidationRules(cellsToValidates);
	}

	disconnectedCallback() {
		this.updateOmniscriptStepValidity();
	}

	updateOmniscriptStepValidity() {
		const elemPath = this.omniJsonDef.JSONPath;
		const key = elemPath.substring(0, elemPath.indexOf(":")) + "IsComplete";

		let hasErrors = false;
		for (const [_id, cell] of this.cellsById) {
			hasErrors = !cell.isValid;
			if (hasErrors) {
				break;
			}
		}

		this.omniApplyCallResp(
			{
				[key]: !hasErrors
			},
			true
		);
	}

	/** @param {ColumnDefinition[]} columnsWithData */
	/** @param {Map<string, RowDefinition>} rowDefinitionsById */
	createCellsAndMapToRows(columnsWithData, rowDefinitionsById) {
		const [cellsById, cellsByRowId] = this.createDatatableCells(
			columnsWithData,
			rowDefinitionsById
		);
		const cellsByRowIdEditableTotals = this.allowEditableTotals(cellsByRowId);

		this.cellsByRowId = cellsByRowIdEditableTotals;
		this.cellsById = cellsById;

		return cellsByRowId;
	}

	/**
	 * @param {ColumnDefinition[]} columnDefinitions
	 * @param {Map<string, RowDefinition>} rowDefinitionsById
	 * @returns {[Map<string, Cell>, Map<string, Cell[]>]}
	 */
	createDatatableCells(columnDefinitions, rowDefinitionsById) {
		let firstLoad = () => {
			return this.firstLoad;
		}; // need local to reference from inside getter below
		firstLoad = firstLoad.bind(this); // needs component context bound

		const cellsById = new Map();
		/** @type {Map<string, Cell[]>}*/
		const cellsByRowId = new Map();

		columnDefinitions.forEach((col) => {
			const rowsAppended = new Set(); // track whether rows were missed to add hidden cells

			col.data.forEach((cellData) => {
				const rowDef = rowDefinitionsById.get(cellData.rowDefinitionId);
				if (!rowDef) {
					return; // short-circuit in foreach
				}

				const allowNegatives = negativeValuesAllowedCategories.has(
					rowDef.category
				);

				rowsAppended.add(rowDef.id);

				const readOnlyRow =
					(rowDef.childRows && rowDef.childRows.length > 0) ||
					!!rowDef.formula_string;
				if (cellData.value || cellData.value === 0) {
					this.firstLoad = false;
				}

				let cellDataValue;

				if (rowDef.type === "Picklist") {
					cellDataValue = cellData.value;
				} else {
					cellDataValue = parseFloat(String(cellData.value));
				}

				const cell = new Cell({
					cellId: cellData.id,
					rowId: cellData.rowDefinitionId,
					value: cellDataValue,
					precision: rowDef.precision,
					type: rowDef.type,
					visited: false,
					firstLoad: firstLoad,
					allowNegatives: allowNegatives,
					picklistVal: rowDef.lineItemValueOptions,
					componentReadOnly: this.isReadOnly,
					cellReadOnly: readOnlyRow || !col.isEnabled,
					providerExplanation: cellData.providerExplanation,
					qaOutcome: cellData.qaOutcome,
					qaComments: cellData.qaComments,
					hardValidation: cellData.hardValidation
				});

				if (!col.cells) {
					col.cells = [];
				}
				col.cells.push(cell);

				if (cellsByRowId.has(cellData.rowDefinitionId)) {
					/** @type {Cell} */
					const totalCell = cellsByRowId.get(cellData.rowDefinitionId)[0];
					cell.rowTotal = totalCell;
					totalCell.totalChildren.push(cell);

					cellsByRowId.get(cellData.rowDefinitionId).push(cell);
				} else {
					cell.cellReadOnly = true; // Total column is first column, and should be read-only.
					cell.totalChildren = [];
					cellsByRowId.set(cellData.rowDefinitionId, [cell]);
				}

				cellsById.set(cell.cellId, cell);
			});
			// ensure if any columns don't have a GL Code Line item for a row, we add a cell to ensure the table cells are placed correctly
			// these cells have the hidden flag set to display as an empty cell
			for (const [k, _v] of rowDefinitionsById) {
				if (!rowsAppended.has(k)) {
					/** @type {Cell} */
					const hiddenCell = getHiddenCell(k);
					// eslint-disable-next-line no-unused-expressions
					cellsByRowId.get(k)?.push(hiddenCell) ||
						cellsByRowId.set(k, [hiddenCell]);
				}
			}
			return cellsByRowId;
		});
		return [cellsById, cellsByRowId];
	}

	/**
	 * @param {Map<string, Cell[]>} cellsByRowId
	 */
	allowEditableTotals(cellsByRowId) {
		for (const [rowId, cells] of cellsByRowId) {
			const totalCell = cells[0]; // total column always first column
			const row = this.rowDefinitionsById.get(rowId);
			const hasNoChildren = totalCell?.totalChildren?.length === 0;
			const rowIsEditable = !row.formula_string;
			if (hasNoChildren && rowIsEditable && !this.isReadOnly) {
				totalCell.cellReadOnly = false;
			}
		}
		return cellsByRowId;
	}

	handleExcelUpload(evt) {
		/** @type {any[]} */
		const rows = evt.detail.data;

		rows.shift(); // removes titles if top left corner is blank

		let rowIndex = 0;
		const updates = [];
		this.categories.forEach((category) => {
			rowIndex++;
			category.rows.forEach((row) => {
				const rowData = rows[rowIndex];
				row.entries.forEach((cell, index) => {
					if (!(cell.isHidden || cell.isReadOnly)) {
						updates.push({ cellId: cell.cellId, value: rowData[index + 1] });
					}
				});
				rowIndex++;
			});
		});
		this.updateCells(updates);
		this.firstLoad = false;
	}

	/** @param {MouseEvent & {currentTarget: HTMLElement}} evt */
	handleCategoryClick(evt) {
		const categoryIndexStr = evt.currentTarget.getAttribute(
			"data-category-index"
		);
		const index = parseInt(categoryIndexStr, 10);
		this.categories[index].isExpanded = !this.categories[index].isExpanded;
		// required to cause rerender
		this.categories = [...this.categories];
	}

	/**
	 * @param {Event & {currentTarget: HTMLElement}} evt
	 */
	handleColumnToggle(evt) {
		const iteratorIndex = evt.currentTarget.getAttribute("data-col-index");
		const colIndex = parseInt(iteratorIndex, 10) - 1; // left column is headers
		const col = this.cols[colIndex];
		col.isEnabled = !col.isEnabled;
		const changes = [];
		for (const [_k, v] of this.rowsById) {
			const cell = v.entries[colIndex];
			if (cell) {
				if (cell.isHidden) {
					continue;
				}
				if (!col.isEnabled) {
					cell.value = 0.0;
				}
				cell.cellReadOnly = v.isReadOnly || !col.isEnabled;
				changes.push({ cellId: cell.cellId, value: cell.value });
			}
		}
		this.updateCells(changes);
		this.updateColumn(col);
	}

	/**
	 * @param {{ id: any; name?: string; isEnabled?: boolean; }} col
	 */
	async updateColumn(col) {
		const update = { Id: col.id, Active__c: col.isEnabled };
		const args = {
			servicesJson: JSON.stringify([update])
		};
		const options = {}; // Options for Vlocity GenericInvoke eg queueable, future, continuation

		/** @type  {import("omnistudio").OmniRemoteCallParams} */
		const remoteCallParams = {
			input: JSON.stringify(args),
			sClassName: APEX_CONTROLLER_CLASS_NAME,
			sMethodName: "updateServices",
			options: JSON.stringify(options)
		};
		const { result, error } = await this.omniRemoteCall(
			remoteCallParams,
			false
		);
		this.omniRemoteCall(remoteCallParams, false);
		if (error) {
			this.logger.error(
				`An error occurred in a remote call. Details: ${JSON.stringify(result)}`
			);
		}
	}

	alwaysAllowedCodes = new Set([
		"Tab",
		"Enter",
		"Backspace",
		"ArrowLeft",
		"ArrowRight",
		"ArrowDown",
		"ArrowUp",
		"Escape",
		"Delete"
	]);
	alwaysAllowedChars = new Set([".", "-", ","]);
	/** @param {KeyboardEvent & {target: HTMLInputElement}} evt; */
	handleCellKeyDown(evt) {
		/** @type {string} */

		const cellId = evt.target.getAttribute(SELECTORS.DATA_RECORD_ID);
		const currentCell = this.cellsById.get(cellId);
		const NUM_DECIMAL_PLACES = currentCell.precision;
		if (evt.key === "Escape") {
			// blur on escape
			evt.target.blur();
		}

		// only allow numeric inputs or specified characters/keycodes if a number is not typed
		const isNotNumericInput =
			isNaN(parseInt(evt.key, 10)) &&
			!(
				this.alwaysAllowedChars.has(evt.key) ||
				this.alwaysAllowedCodes.has(evt.code)
			);
		if (isNotNumericInput) {
			evt.preventDefault();
		}

		// eslint-disable-next-line complex-logic/complex-logic
		// navigate with arrow keys
		if (evt.key === "Escape") {
			this.template
				.querySelector(`div[data-record-id="${currentCell.cellId}"]`)
				.focus();
		}

		const verticalNavigationKeys = new Set(["ArrowDown", "ArrowUp", "Enter"]);
		if (verticalNavigationKeys.has(evt.key)) {
			// get cell info
			const changedCellIndex = this.rowsById
				.get(currentCell.rowId)
				.entries.indexOf(currentCell);

			let direction = DIRECTIONS.UP;
			if (evt.key === "ArrowDown" || evt.key === "Enter") {
				direction = DIRECTIONS.DOWN;
			}
			const targetRowId = this.getNextRowId(currentCell, direction);

			const isTargetCellPicklist = currentCell.type === "Picklist";
			const shouldFocusOnPicklist =
				verticalNavigationKeys.has(evt.key) &&
				evt.altKey === true &&
				currentCell.type === "Picklist";
			// focus on target cell
			const targetCell =
				this.rowsById.get(targetRowId).entries[changedCellIndex].cellId;
			if (shouldFocusOnPicklist === true) {
				this.template
					.querySelector(
						`lightning-combobox[data-record-id="${currentCell.cellId}"]`
					)
					.focus();
			} else if (isTargetCellPicklist) {
				this.template
					.querySelector(`div[data-record-id="${targetCell}"]`)
					.focus();
			} else {
				this.template
					.querySelector(`input[data-record-id="${targetCell}"]`)
					.focus();
			}
		}
	}

	/**
	 * @param {Cell} currentCell
	 * @param {number} direction constant from DIRECTIONS
	 * @returns {string}
	 */
	getNextRowId(currentCell, direction) {
		const changedCellIndex = this.rowsById
			.get(currentCell.rowId)
			.entries.indexOf(currentCell);
		const changedRowId = this.rowsById.get(currentCell.rowId).id;
		const rowIdList = [];
		this.categories.forEach((category) => {
			category.rows.forEach((row) => {
				rowIdList.push(row);
			});
		});
		let targetRowId = 0;
		// find row ID of next editable row
		for (let i = 0; i < rowIdList.length; i++) {
			if (changedRowId === rowIdList[i].id) {
				let k = 0;

				if (direction === DIRECTIONS.UP) {
					if (i === 0) {
						targetRowId = rowIdList[i].id;
					} else if (i > 0) {
						k = -1;
						while (
							i + k >= 0 &&
							(rowIdList[i + k].isReadOnly === true ||
								this.rowsById.get(rowIdList[i + k].id).entries[changedCellIndex]
									.isHidden === true)
						) {
							k--;
						}
					}
				}

				if (direction === DIRECTIONS.DOWN) {
					if (i === rowIdList.length - 1) {
						targetRowId = rowIdList[i].id;
					} else if (i < rowIdList.length - 1) {
						k = 1;
						while (
							(i + k <= rowIdList.length - 1 &&
								rowIdList[i + k].isReadOnly === true) ||
							this.rowsById.get(rowIdList[i + k].id).entries[changedCellIndex]
								.isHidden === true
						) {
							k++;
						}
					}
				}

				if (i + k < 0 || i + k > rowIdList.length - 1) {
					targetRowId = rowIdList[i].id;
				} else {
					targetRowId = rowIdList[i + k].id;
				}
			}
		}
		return targetRowId;
	}

	handleCellFocusIn(evt) {
		// remove the commas from the number
		const cellvalue = evt.target.value?.replaceAll(",", "");
		evt.target.value = cellvalue;
	}

	handleCellFocusOut(evt) {
		const cellId = evt.target.getAttribute(SELECTORS.DATA_RECORD_ID);
		if (!cellId) {
			return;
		}
		const currentCell = this.cellsById.get(cellId);
		currentCell.visited = true;
		this.categories = [...this.categories];

		// ensure value is reformatted correctly
		evt.target.value = currentCell.displayValue;
	}

	/** @param {Cell} cell
	 *  @returns {ColumnDefinition}
	 */
	getColumn(cell) {
		return this.cols[this.rowsById.get(cell.rowId)?.entries.indexOf(cell)];
	}

	resetView() {
		this.rejectedOnly = false;
		this.errorsOnly = false;
	}

	handleViewChange(evt) {
		const newView = evt.detail.newView;
		const timeout = 1000;
		this.resetView();
		setTimeout(() => {
			if (newView.toLowerCase().includes("error")) {
				this.errorsOnly = true;
			} else if (newView.toLowerCase().includes("comments")) {
				this.rejectedOnly = true;
			}
		}, timeout);
	}

	handleExpandToggle() {
		this.isExpanded = !this.isExpanded;
	}

	handleCommentsOnlyToggle() {
		this.rejectedOnly = !this.rejectedOnly;
	}

	handleErrorsOnlyToggle() {
		this.errorsOnly = !this.errorsOnly;
	}

	handleRejectedOnlyToggle() {
		this.rejectedOnly = !this.rejectedOnly;
	}

	handleSectionSelected(evt) {
		const sectionName = evt.detail.section;
		this.scrollToSection(sectionName);
		evt.target.value = null;
	}

	handleColumnSelected(evt) {
		const colName = evt.detail.column;
		this.scrollToColumn(colName);
		evt.target.value = null;
	}

	scrollToCell(messageChannel) {
		const { cellId } = messageChannel;
		const containerEl = this.template.querySelector(".table-container");
		const first_row = this.template.querySelector(
			".table-row-element th:first-of-type"
		);
		const columnEl = this.template.querySelector(`[data-cell-id="${cellId}"]`);

		//@ts-ignore
		containerEl.scrollLeft = columnEl.offsetLeft - first_row.offsetWidth;
	}

	scrollToColumn(colName) {
		const columnEl = this.template.querySelector(
			`th[data-col-name="${colName}"]`
		);
		const containerEl = this.template.querySelector(".table-container");
		const first_row = this.template.querySelector(
			".table-row-element th:first-of-type"
		);
		//@ts-ignore
		containerEl.scrollLeft = columnEl.offsetLeft - first_row.offsetWidth;
	}

	/**
	 * @param {Element} htmlElement
	 */
	scrollToElement(htmlElement) {
		htmlElement.scrollIntoView({
			behavior: "smooth",
			block: "start",
			inline: "start"
		});
	}

	scrollToSection(sectionName) {
		const sectionElement = this.template.querySelector(
			`tr[data-row-name="${sectionName}"]`
		);
		const containerEl = this.template.querySelector(".table-container");
		const first_row = this.template.querySelector(
			".table-row-element th:first-of-type"
		);

		if (!containerEl || !sectionElement || !first_row) {
			return;
		}

		//@ts-ignore
		containerEl.scrollTop = sectionElement.offsetTop - first_row.offsetHeight;
	}

	handleCellChange(evt) {
		const cellId = evt.target.getAttribute(SELECTORS.DATA_RECORD_ID);
		if (!cellId || !this.cellsById.has(cellId)) {
			return;
		} // ensure change event is for a datatable cell
		const textVal = evt.target.value.replaceAll(",", "");
		const newValue = parseFloat(textVal);
		this.updateCells([{ cellId, value: newValue }]);
		this.updateOmniscriptStepValidity();
	}

	handlePicklistChange(evt) {
		const cellId = evt.detail.recordId;
		if (!cellId || !this.cellsById.has(cellId)) {
			return;
		}
		const newValue = evt.detail.value;
		this.updateCells([{ cellId, value: newValue }]);
	}

	async handleExplanationChange(_evt) {
		await this.initialiseForRecord();
	}

	/** @param {{cellId: string, value: number}[]} cells */
	updateCells(cells) {
		const cellsToUpdate = [];
		for (const cell of cells) {
			const curr = this.cellsById.get(cell.cellId);

			cellsToUpdate.push(curr.cellId);
			curr.value = cell.value;
		}

		this.recalculateDependentValues(cellsToUpdate);

		this.categories = [...this.categories]; // ensures update, getters that currently trigger rerender may be removed
		this.persistChanges();
	}

	/**
	 * @param {string[]} changedCellIds
	 * @return {GL_Code_Line_Item__c[]}
	 */
	recalculateDependentValues(changedCellIds, visitedSources = new Set()) {
		changedCellIds = changedCellIds.filter((id) => !visitedSources.has(id)); // ignore any already visited ids
		if (changedCellIds.length === 0) {
			return [];
		}

		visitedSources = new Set([...visitedSources, ...changedCellIds]);
		// calculate summaries
		const parentRecordChanges = this.recalculateSummaryRows(changedCellIds);
		const updatedIds = [
			...changedCellIds,
			...parentRecordChanges.map((cell) => cell.Id)
		];
		// calculate row-level totals
		const totalCellChanges = this.recalculateRowTotal(updatedIds);

		// calculate custom formulae
		const formulaeUpdates = this.recalculateCustomFormulae([
			...updatedIds,
			...totalCellChanges.map((record) => record.Id)
		]);

		updatedIds.push(...formulaeUpdates.map((cell) => cell.Id));

		this.runValidationRules([
			...updatedIds,
			...totalCellChanges.map((record) => record.Id)
		]);

		return [
			...parentRecordChanges,
			...totalCellChanges,
			...formulaeUpdates,
			...this.recalculateDependentValues(updatedIds, visitedSources)
		];
	}

	/**
	 * @param {string[]} changedCellIds
	 * @return {GL_Code_Line_Item__c[]}
	 */
	recalculateSummaryRows(changedCellIds) {
		const parentRecordUpdates = [];
		for (const changedCellId of changedCellIds) {
			const changedCell = this.cellsById.get(changedCellId);
			const parentCell = this.getParentCell(changedCell);
			if (!parentCell || parentCell.isHidden) {
				continue;
			}
			if (this.rowsById.get(parentCell.rowId)?.formula_string) {
				continue;
			} // don't evaluate summary if this record has a custom formula

			const modifiedCellIndex = this.rowsById
				.get(changedCell.rowId)
				.entries.indexOf(changedCell);
			const childCells = this.getChildCells(parentCell, modifiedCellIndex);

			// recalculate summaries if cell has children
			let sum = 0;
			for (const childCell of childCells) {
				// @ts-ignore
				sum += childCell.value || 0;
			}
			parentCell.value = parseFloat(sum.toFixed(TO_FIXED));
			parentRecordUpdates.push({
				Id: parentCell.cellId,
				Line_Item_Value__c: parentCell.value,
				provider_explanation__c: parentCell.providerExplanation
			});
		}
		return parentRecordUpdates;
	}

	recalculateCustomFormulae(sourceCellIds) {
		const updatedRecords = [];
		const visitedTargets = new Set();
		for (const changedCellId of sourceCellIds) {
			const changedCell = this.cellsById.get(changedCellId);
			if (!changedCell) {
				continue;
			}
			const changedCellIndex = this.rowsById
				.get(changedCell.rowId)
				.entries.indexOf(changedCell);
			const targetFormulae = this.formulaeBySourceRowId.get(changedCell.rowId);
			if (targetFormulae) {
				// recalculate formula for all affected cells
				for (const formula of targetFormulae) {
					const targetCell = this.rowsById.get(formula.targetRowId).entries[
						changedCellIndex
					];
					if (!targetCell || targetCell.isHidden) {
						continue;
					} // hidden target cells should not be evaluated
					if (visitedTargets.has(targetCell.cellId)) {
						continue;
					}

					visitedTargets.add(targetCell.cellId);

					const args = new Map();
					formula.sourceRowIds.forEach((sourceRowId) =>
						args.set(
							sourceRowId,
							this.rowsById.get(sourceRowId)?.entries?.[changedCellIndex]
								?.value || 0
						)
					);

					const newValue = formula.formula(args);

					targetCell.value = newValue;
					updatedRecords.push({
						Id: targetCell.cellId,
						Line_Item_Value__c: newValue
					});
				}
			}
		}
		return updatedRecords;
	}
	/**
	 * @param {Cell} parentCell
	 * @return {Cell[]}
	 */
	getChildCells(parentCell, cellIndex) {
		const rowDef = this.rowDefinitionsById.get(parentCell.rowId);
		const childRowIds = rowDef.childRows.map((curr) => curr.id);
		const childRows = childRowIds.map((childRowId) =>
			this.rowsById.get(childRowId)
		);
		// child cells will all have same index as they will be in the same column
		return childRows.map((row) => row.entries[cellIndex]);
	}

	/**
	 * @param {Cell?} cell
	 */
	getParentCell(cell) {
		if (!cell) {
			return null;
		}
		const row = this.rowsById.get(cell.rowId);
		const cellIndex = row.entries.indexOf(cell);
		return row?.parentRow?.entries[cellIndex];
	}

	/**
	 *
	 * @param {string[]} changedCellIds
	 * @returns
	 */
	recalculateRowTotal(changedCellIds) {
		const changedTotalRecords = [];
		const evaluatedTotals = new Set();
		for (const currId of changedCellIds) {
			const totalCell = this.cellsById.get(currId)?.rowTotal;
			if (!totalCell || totalCell.isHidden || evaluatedTotals.has(totalCell)) {
				continue;
			}
			if (this.rowsById.get(totalCell.rowId).formula_string) {
				continue;
			}
			evaluatedTotals.add(totalCell); // prevent re-evaluating same row repeatedly

			const newTotal = totalCell.totalChildren.reduce((accum, curr) => {
				// @ts-ignore
				return accum + curr.value || 0;
			}, 0);

			totalCell.value = parseFloat(newTotal.toFixed(TO_FIXED));

			changedTotalRecords.push({
				Id: totalCell.cellId,
				Line_Item_Value__c: totalCell.value,
				provider_explanation__c: totalCell.providerExplanation
			});
		}
		return changedTotalRecords;
	}

	persistChanges = debounce(async () => {
		const changesArray = [...this.cellsById]
			.filter(([_id, cell]) => cell.dirty)
			.map(([_id, cell]) => {
				return {
					Id: cell.cellId,
					Line_Item_Value__c: cell.value,
					provider_explanation__c: cell.providerExplanation
				};
			});
		if (!changesArray.length) {
			// do nothing if there are no changes to persist.
			return;
		}
		this.isSaving = true;
		changesArray.forEach((cell) => {
			// reset dirty flag after saving.
			this.cellsById.get(cell.Id).dirty = false;
		});
		const args = {
			glCodeLineItemJson: JSON.stringify(changesArray)
		};
		const options = {}; // Options for Vlocity GenericInvoke eg queueable, future, continuation

		/** @type  {import("omnistudio").OmniRemoteCallParams} */
		const remoteCallParams = {
			input: JSON.stringify(args),
			sClassName: APEX_CONTROLLER_CLASS_NAME,
			sMethodName: "updateCells",
			options: JSON.stringify(options)
		};
		const { result, error } = await this.omniRemoteCall(
			remoteCallParams,
			false
		);
		if (error) {
			this.logger.error(
				`An error occurred in a remote call. Details: ${JSON.stringify(result)}`
			);
		} else {
			this.lastSavedDate = new Date().toLocaleString("en-au");
		}
		this.isSaving = false;
	}, AUTOSAVE_DEBOUNCE_MS);

	initialiseRowDefinitionMaps(rowDefinitions) {
		/** @type {Map<string, import("./types").RowDefinition>} */
		const rowDefinitionsById = new Map();
		/** @type {Map<string, string>} */
		const rowIdToParentId = new Map();

		rowDefinitions.forEach(
			(/** @type {import("./types").RowDefinition} */ rowDefinition) => {
				rowDefinitionsById.set(rowDefinition.id, rowDefinition);
				rowIdToParentId.set(rowDefinition.id, rowDefinition.parentRowId);
				rowDefinition.childRows = [];
			}
		);

		this.rowDefinitionSetup(rowDefinitionsById, rowIdToParentId);

		return [rowDefinitionsById, rowIdToParentId];
	}

	/**
	 * @param {Map<string, import("./types").RowDefinition>} rowDefinitionsById
	 * @param {Map<string, string>} rowIdToParentId
	 */
	rowDefinitionSetup(rowDefinitionsById, rowIdToParentId) {
		/** @type {Map<string, FormulaInfo[]>} */
		const formulaeBySourceRowId = new Map();
		for (const [rowDefinitionId, rowDefinition] of rowDefinitionsById) {
			// add child rows under parent
			const parentRow = rowDefinitionsById.get(
				rowIdToParentId.get(rowDefinitionId)
			);
			if (parentRow) {
				parentRow.childRows.push(rowDefinition);
			}

			// calculate depth of each row within categories
			this.getDepthOfRowDefinition(
				rowDefinitionId,
				rowDefinition,
				rowDefinitionsById,
				rowIdToParentId
			);

			// evaluate formulae attached to rows and create functions from them
			if (rowDefinition.formula_string) {
				try {
					const parseResult = parseFormula(rowDefinition.formula_string);
					/** @type {FormulaInfo} */
					const formulaInfo = {
						targetRowId: rowDefinition.id,
						formula: parseResult.formula,
						sourceRowIds: parseResult.sourceIds
					};
					for (const sourceId of parseResult.sourceIds) {
						const mappedFormulae = formulaeBySourceRowId.get(sourceId) || [];
						mappedFormulae.push(formulaInfo);
						formulaeBySourceRowId.set(sourceId, mappedFormulae);
					}
				} catch (e) {
					// TODO: nicer error handling when invalid formula supplied...?
					this.logger.error(e);
				}
			}
		}

		this.rowDefinitionsById = rowDefinitionsById;
		this.rowIdToParentId = rowIdToParentId;
		this.formulaeBySourceRowId = formulaeBySourceRowId;
	}

	getDepthOfRowDefinition(rowId, row, rowDefinitionsById, rowIdToParentId) {
		let depth = -1; // sets depth to 0 if no children
		while (rowId) {
			depth++;
			const currParent = rowDefinitionsById?.get(rowIdToParentId.get(rowId));

			rowId = currParent?.category === row.category ? currParent.id : null;
		}
		row.depth = depth;
	}

	/*
	 * @description Retrieve cross form formula source information, and add to rowsById
	 */
	async retrieveCrossFormFormulaDataNew() {
		const missingSourceRowIds = [];

		this.crossFormBusinessIds.forEach((businessId) => {
			if (!this.rowDefinitionsById.has(businessId)) {
				missingSourceRowIds.push(businessId);
			}
		});

		for (const sourceRowId of this.formulaeBySourceRowId.keys()) {
			if (!this.rowDefinitionsById.has(sourceRowId)) {
				missingSourceRowIds.push(sourceRowId);
			}
		}

		if (missingSourceRowIds.length === 0) {
			return;
		}
		// Send callout to retrieve the data from the missing Business IDs
		const datatableDefinitions = await this.requestCrossFormData(
			missingSourceRowIds
		);
		for (const additionalData of datatableDefinitions) {
			const rowDefinitionsById = new Map();
			additionalData.rowDefinitions.forEach((rowDef) => {
				rowDef.childRows = [];
				rowDef.depth = 0;
				this.rowDefinitionsById.set(rowDef.id, rowDef);
				rowDefinitionsById.set(rowDef.id, rowDef);
			});

			this.initialiseCrossFormGlCodeLineItems(
				this.targetFinancialRules,
				additionalData.columnDefinitions
			);

			const [cellsById, cellsByRowId] = this.createDatatableCells(
				additionalData.columnDefinitions,
				rowDefinitionsById
			);
			additionalData.rowDefinitions.forEach((rowDef) => {
				const entries = cellsByRowId.get(rowDef.id);
				/** @type {Row} */
				const row = {
					id: rowDef.id,
					name: rowDef.name,
					entries,
					get displayEntries() {
						return this.entries;
					},
					inlineStyle: ``,
					parentRowId: null,
					formula_string: rowDef.formula_string,
					get isReadOnly() {
						return (
							!!this.formula_string ||
							(rowDef.childRows && rowDef.childRows.length > 0)
						);
					},
					get hasInvalidCell() {
						return this.displayEntries.length > 0;
					}
				};
				this.rowsById.set(row.id, row);
				this.crossFormColumnsByGLCodeId.set(
					row.id,
					additionalData.columnDefinitions
				);
			});
			// Update component to include the additional rows so that formulae can be calculated based on them

			cellsById.forEach((value, key) => {
				this.cellsById.set(key, value);
			});
		}
	}

	/**
	 * @param {string[]} missingSourceRowIds
	 * @returns {Promise<{rowDefinitions: RowDefinition[], columnDefinitions: ColumnDefinition[]}[]>}
	 */
	async requestCrossFormData(missingSourceRowIds) {
		const args = {
			formId: this.recordId,
			glCodeBusinessIds: missingSourceRowIds
		};

		const options = {}; // Options for Vlocity GenericInvoke eg queueable, future, continuation

		/** @type  {import("omnistudio").OmniRemoteCallParams} */
		const remoteCallParams = {
			input: JSON.stringify(args),
			sClassName: APEX_CONTROLLER_CLASS_NAME,
			sMethodName: "getCrossFormRowDefinitions",
			options: JSON.stringify(options)
		};
		const { result, error } = await this.omniRemoteCall(
			remoteCallParams,
			false
		);
		if (error) {
			this.logger.error(
				`An error occurred in a remote call. Details: ${JSON.stringify(result)}`
			);
		}
		return result.datatableDefinitions;
	}

	/******************* all methods related to financial validation rules **********************/
	/**
	 @description: this method will get all valid rules for all gl code
	**/
	async initialiseValidationRules(frValidationRules, _quarter, rowDefinitions) {
		const valRules = new Map();
		const crossFormBusinessId = [];
		const presentBusinessId = [];
		rowDefinitions.forEach((rowItem) => {
			presentBusinessId.push(rowItem.id);
		});

		this.presentBusinessIds = presentBusinessId;

		frValidationRules.forEach((frvr) => {
			if (frvr.validationRule) {
				try {
					const validationRuleCriteria = frvr.validationRule.replace(
						/quarter/gi,
						_quarter
					); //replace the word quarter in validation rule with the current quarter number
					const parseValidationResult = parseFormula(validationRuleCriteria);
					/** @type {import("./types").ValidationFormula} */
					const validationInfo = {
						errorFormula: parseValidationResult.formula, //tokeniseFormula(frvr.validationRule),
						errorSourceIds: parseValidationResult.sourceIds,
						errorRowId: frvr.glCode,
						errorMessage: frvr.errorMessage,
						errorId: frvr.id,
						errorGlCodeTarget: frvr.glCodeTarget,
						errorServiceCategory: frvr.serviceCategoryExcluded,
						errorSourceColumn: frvr.sourceColumn,
						errorTargetColumn: frvr.targetColumn,
						hardValidation: frvr.hardValidation
					};
					for (const sourceId of parseValidationResult.sourceIds) {
						if (frvr.type === "Single_Form_Validation") {
							validationInfo.errorValidationType = "single";
						} else if (frvr.type === "Cross_Form_Validation") {
							validationInfo.errorValidationType = "cross";
						}

						const mappedFormulae = valRules.get(sourceId) || [];
						mappedFormulae.push(validationInfo);
						//get all single form validation rules

						if (frvr.type === "Single_Form_Validation") {
							valRules.set(sourceId, mappedFormulae);
						}
						if (frvr.type === "Cross_Form_Validation") {
							mappedFormulae.forEach((mfItem, index) => {
								if (!presentBusinessId.includes(mfItem.errorRowId)) {
									mappedFormulae.splice(index, 1);
								}
							});

							if (presentBusinessId.includes(frvr.glCode)) {
								if (frvr.glCode === sourceId) {
									valRules.set(sourceId, mappedFormulae);
								}
								crossFormBusinessId.push(sourceId);
							}

							if (
								presentBusinessId.includes(sourceId) &&
								frvr.glCode === sourceId
							) {
								const sourceFrvr = {
									businessId: sourceId,
									column: frvr.sourceColumn,
									errorMessage: frvr.errorMessage
								};
								if (!this.sourceFinancialRules.includes(sourceFrvr)) {
									this.sourceFinancialRules.push(sourceFrvr);
								}
							}

							if (
								!presentBusinessId.includes(sourceId) &&
								presentBusinessId.includes(frvr.glCode)
							) {
								const targetFrvr = {
									businessId: sourceId,
									column: frvr.targetColumn,
									errorMessage: frvr.errorMessage
								};
								if (!this.targetFinancialRules.includes(targetFrvr)) {
									this.targetFinancialRules.push(targetFrvr);
								}
							}
						}
					}
				} catch (e) {
					this.logger.error(e);
				}
			}
		});

		this.crossFormBusinessIds = crossFormBusinessId;
		this.validationFormulaBySourceRowId = valRules;
	}

	runValidationRules(cellsToValidate) {
		try {
			const getCellValidationResult = this.validateCellValues(
				cellsToValidate,
				this.cellsById,
				this.rowsById
			); //check if validation crteria are met
			const overAllCellValidationResult = this.reEvaluateSourceCellValidation(
				getCellValidationResult
			);
			this.updateCellsValidation(overAllCellValidationResult, this.cellsById);
			this.checkErrorCol(this.cols);
			this.getRejectedColumns(this.cols);
		} catch (exc) {
			this.logger.error(exc);
		}
	}

	/**
    @description: this method will reevaluate the validation checking for source cells
  **/
	reEvaluateSourceCellValidation(cellValidationResult) {
		const sourceCellsToValidate = [];
		let sourceCellValidationResult = [];
		if (cellValidationResult) {
			cellValidationResult.forEach((valResult) => {
				valResult?.sourceCellsId.forEach((cellId) => {
					if (!sourceCellsToValidate.includes(cellId)) {
						sourceCellsToValidate.push(cellId);
					}
				});
			});

			if (sourceCellsToValidate) {
				sourceCellValidationResult = this.validateCellValues(
					sourceCellsToValidate,
					this.cellsById,
					this.rowsById
				);
			}
		}
		return [...cellValidationResult, ...sourceCellValidationResult];
	}

	/**
	 @description: this method will get all cells which has validation rules enabled
	**/
	getCellsToValidate(rowsDataById) {
		const cellIds = new Set();
		try {
			if (this.validationFormulaBySourceRowId) {
				for (const rowId of this.validationFormulaBySourceRowId.keys()) {
					const row = rowsDataById.get(rowId);

					row?.entries.forEach((cell) => {
						if (!cell.isHidden && cell.visited) {
							cellIds.add(cell.cellId);
						}
					});
				}
			}
		} catch (exc) {
			this.logger.error(exc);
		}

		return cellIds;
	}

	/**
	 @description: this method will validate each cell if it's pass the validation criteria
	**/
	validateCellValues(allSourceCellIds, cellsDataById, rowsDataById) {
		let cellValidationResult = [];
		const forCrossFormBusinessIds = [];
		let sourceCellIds = [];
		const crossGlCodeLineItems = this.crossFormGlCodesLineItems;

		if (this.glCodeLineItemsToBeExempted) {
			allSourceCellIds.forEach((item) => {
				if (!this.glCodeLineItemsToBeExempted.includes(item)) {
					sourceCellIds.push(item);
				}
			});
		} else {
			sourceCellIds = allSourceCellIds;
		}

		crossGlCodeLineItems.forEach((gLCodeLineItems) => {
			if (!forCrossFormBusinessIds.includes(gLCodeLineItems.businessId)) {
				forCrossFormBusinessIds.push(gLCodeLineItems.businessId);
			}

			// PBI 309400 - For Cross form
			if (
				Array.isArray(sourceCellIds) &&
				!sourceCellIds.includes(gLCodeLineItems.id)
			) {
				sourceCellIds.push(gLCodeLineItems.id);
			}
		});

		try {
			for (const targetCellId of sourceCellIds) {
				const targetCell = cellsDataById.get(targetCellId);
				if (!targetCell) {
					continue;
				}
				const serviceName = this.getColumn(targetCell)?.name;

				const targetCellIndex = rowsDataById
					.get(targetCell.rowId)
					.entries.indexOf(targetCell);

				const targetFormulae = this.validationFormulaBySourceRowId.get(
					targetCell.rowId
				);

				if (targetFormulae) {
					// check all cell if will meet validation criteria
					for (const formula of targetFormulae) {
						const serviceCategories = formula.errorServiceCategory
							? formula.errorServiceCategory.split(";")
							: [];

						//skip services which are listed in the service caterogy excluded
						if (!serviceCategories.includes(serviceName)) {
							cellValidationResult = this.checkCellValidation(
								formula,
								targetCellIndex,
								rowsDataById,
								cellValidationResult
							);
						}
					}
				}
			}
		} catch (e) {
			this.logger.error(e);
		}

		return cellValidationResult;
	}

	checkCellValidation(
		formula,
		targetCellIndex,
		rowsDataById,
		cellValidationResult
	) {
		const args = new Map();
		const cellsIds = [];
		let validationResult = false;

		// for every formula's contributing row id
		formula.errorSourceIds.forEach((sourceRowId) => {
			const colArray = this.crossFormColumnsByGLCodeId.get(sourceRowId);
			let cellOffset;

			if (colArray) {
				cellOffset = colArray.findIndex(
					(col) => col.name === formula.errorTargetColumn
				);
				if (cellOffset === -1) {
					cellOffset = colArray.findIndex(
						(col) => col.name === formula.errorSourceColumn
					);
				}
			} else {
				cellOffset = targetCellIndex;
				if (
					formula.errorSourceColumn &&
					this.cols.find((col) => col.name === formula.errorSourceColumn)
				) {
					cellOffset = this.cols.findIndex(
						(col) => col.name === formula.errorSourceColumn
					);
				} else if (
					formula.errorTargetColumn &&
					this.cols.find((col) => col.name === formula.errorTargetColumn)
				) {
					cellOffset = this.cols.findIndex(
						(col) => col.name === formula.errorTargetColumn
					);
				} else {
					// leave as default
				}
			}

			if (cellOffset === -1) {
				cellOffset = targetCellIndex;
			}

			if (rowsDataById.get(sourceRowId)) {
				const currentCell = rowsDataById.get(sourceRowId)?.entries[cellOffset];
				cellsIds.push(currentCell.cellId);
				let cellValue;
				if (currentCell.value === 0) {
					cellValue = 0;
				} else {
					cellValue = parseFloat(currentCell?.value) || undefined;
				}
				args.set(sourceRowId, cellValue);
			}
		});

		if (cellsIds.length > 0) {
			const validationErrMessage = this.getFormattedErrorMessage(
				formula.errorMessage,
				rowsDataById,
				targetCellIndex
			);

			validationResult = formula.errorFormula(args);
			const isValidationPass = validationResult ? false : true;
			cellValidationResult.push({
				isValid: isValidationPass,
				errorMessage: validationErrMessage,
				sourceCellsId: cellsIds,
				errorId: formula.errorId,
				errorValidationType: formula.errorValidationType,
				sourceColumn: formula.errorSourceColumn,
				hardValidation: formula.hardValidation
			});
		}

		return cellValidationResult;
	}

	/**
	 @description: this method will format the error message to replace the businessId by actual cell values
	**/
	getFormattedErrorMessage(errorMessage, rowsDataById, targetCellIndex) {
		const businessIdRegex = /Q\.[A-Za-z0-9.]+/;
		const rowIds = errorMessage.match(businessIdRegex);

		if (rowIds != null) {
			for (const rowId of rowIds) {
				const errMsgCellValue = isNaN(
					rowsDataById.get(rowId)?.entries[targetCellIndex]?.value
				)
					? 0
					: Number(rowsDataById.get(rowId)?.entries[targetCellIndex]?.value);
				errorMessage = errorMessage.replace(rowId, errMsgCellValue);
			}
		}
		return errorMessage;
	}

	/**
	 @description: this method will handle the logic to update the cell validation
	**/
	updateCellsValidation(validationCellsResult, cellsById) {
		if (validationCellsResult) {
			const validationByCellId = new Map();
			validationCellsResult.forEach((valResult) => {
				valResult?.sourceCellsId.forEach((cellId) => {
					const validationInfoList = validationByCellId.get(cellId) || [];
					validationInfoList.push(valResult);
					validationByCellId.set(cellId, validationInfoList);
				});
			});

			if (this.glCodeLineItemsToBeExempted) {
				this.glCodeLineItemsToBeExempted.forEach((item) => {
					validationByCellId.delete(item);
				});
			}

			if (validationByCellId) {
				for (const val of validationByCellId.keys()) {
					const validationChecker = (arr) => arr.every((v) => v === true);
					const isValidResultList = [];
					let errorMessage = "";
					let sourceColumn = "";
					let hardValidation = false;

					for (const valResult of validationByCellId.get(val)) {
						isValidResultList.push(valResult.isValid);
						if (!valResult.isValid) {
							errorMessage = valResult.errorMessage;
							hardValidation = valResult.hardValidation;
						}
						sourceColumn = valResult.sourceColumn;
					}
					const isValid = validationChecker(isValidResultList);
					let cell = cellsById.get(val);

					if (
						typeof cell != "undefined" &&
						(cell.isValidationPassed !== isValid ||
							cell.validationErrorMessage !== errorMessage)
					) {
						cell = this.updateValidationEachCell(
							cell,
							isValid,
							errorMessage,
							sourceColumn,
							hardValidation
						);
					}
				}
			}
		}
	}

	/**
	 @description: this method will handle the logic to update each cell validation status and error message
	**/
	updateValidationEachCell(
		cell,
		isValid,
		errorMessage,
		sourceColumn,
		hardValidation
	) {
		const cellColumn = this.getColumn(cell)?.name;
		cell.isValidationPassed = isValid;
		cell.validationErrorMessage = errorMessage;
		cell.hardValidation = hardValidation;

		const modifiedCellIndex = this.rowsById
			.get(cell.rowId)
			.entries.indexOf(cell);
		const childCells = this.getChildCells(cell, modifiedCellIndex);
		/** this logic are applicable for all calculated cells that set as read only but need to display the financial rule error message  **/
		if (cell.totalChildren.length > 0 || childCells.length > 0) {
			const isValidated =
				sourceColumn && !this.crossFormGlCodesLineItemIds.includes(cell.cellId);
			/** this logic are applicable for single form only to target specific column **/
			if (
				isValidated &&
				(sourceColumn === STR.TOTAL ||
					sourceColumn === cellColumn ||
					sourceColumn === STR.SUBTOTAL)
			) {
				cell.cellReadOnly = false;
				cell.componentReadOnly = true;
			}

			/** this logic are applicable for cross form type only to target specific column each form **/
			this.crossFormGlCodesLineItems.forEach((sourceItem) => {
				if (
					sourceItem.id === cell.cellId &&
					sourceItem.businessId === cell.rowId
				) {
					cell.cellReadOnly = false;
					cell.componentReadOnly = true;
					cell.isValidationPassed = isValid;
					cell.validationErrorMessage = sourceItem.errorMessage;
					cell.hardValidation = sourceItem.hardValidation;
				}
			});
		}
		return cell;
	}

	updateErrorColumns(array) {
		array.forEach((item) => {
			if (item !== undefined) {
				const result = this.errorColumns.find((col) => col === item);
				if (result === undefined) {
					this.errorColumns.push(item);
				}
			}
		});
	}

	checkHasInvalidCell(item, index) {
		if (item.hasInvalidCell) {
			return index;
		}
		return undefined;
	}

	checkErrorCol(array) {
		const result = array.map(this.checkHasInvalidCell);
		this.updateErrorColumns(result);
		this.updateOmniscriptStepValidity();
		// return result;
	}

	isRejected(cell) {
		return cell.qaOutcome && cell.qaOutcome.toLowerCase().includes("reject");
	}

	getRejectedColumns(array) {
		this.rejectedColumns = [];
		// eslint-disable-next-line array-callback-return
		array.map((item, index) => {
			if (item.data.some(this.isRejected)) {
				this.rejectedColumns.push(index);
			}
		});
	}
}
