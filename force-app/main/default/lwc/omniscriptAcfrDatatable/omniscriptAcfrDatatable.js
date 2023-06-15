import { LightningElement, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { OmniscriptBaseMixin } from "omnistudio/omniscriptBaseMixin";
import { debounce } from "c/jsUtils";
import { parseFormula } from "c/formulaParser";

/**
 * @typedef {import("datatable").Cell} Cell
 * @typedef {import("datatable").GL_Code_Line_Item__c} GL_Code_Line_Item__c
 * @typedef {import("datatable").TableCellResult} TableCellResult
 * @typedef {import("datatable").Category} Category
 * @typedef {import("datatable").Row} Row
 * @typedef {import("datatable").FormulaInfo} FormulaInfo
 * @typedef {import("datatable").ColumnDefinition} ColumnDefinition
 */

const AUTOSAVE_DEBOUNCE_MS = 1000;
const QFR = "Quarterly Financial Report";
const ApexControllerClassName = "AcfrCustomDatatableController";

export default class omniscriptAcfrDatatable extends OmniscriptBaseMixin(
  LightningElement
) {
  @api
  recordId = "a2Y9h0000000KMyEAM";
  @api
  isReadOnly = false;

  initComplete = false;
  isExpanded = false;
  errorMessage = "";

  /** @type {ColumnDefinition[]} */
  cols = [];
  get displayCols() {
    return [{ Id: 0, Name: "" }, ...this.cols];
  }

  get datatableContainerClass() {
    return "datatable-container" + (this.isExpanded ? " expanded-view" : "");
  }
  /**
   * @type {Category[]}
   */
  categories = [];

  /** @type {Object.<string, Category>} */
  categoriesById = {};

  /** @type {Map<string, Row>} */
  rowsById;

  /** @type {Map<string, FormulaInfo[]>}*/
  formulaeBySourceRowId;

  /** @type {{[x: string]: GL_Code_Line_Item__c}} */
  changedCells = {};

  /** @type {Map<String, Cell>} */
  cellsById = new Map();

  /** @type {Map<String, Cell[]>} */
  cellsByRowId = new Map();

  /** @type {Map<string, import("datatable").RowDefinition>} */
  rowDefinitionsById = new Map();
  rowIdToParentId = new Map();

  isSaving = false;
  lastSavedDate;

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
    if (this.recordId) {
      await this.initialiseForRecord();
    } else {
      await this.initialiseDefault();
    }
    this.initComplete = true;
  }

  async initialiseForRecord() {
    let { columnDefinitions, rowDefinitions } =
      await this.getDatatableDefinition();

    if (!columnDefinitions || columnDefinitions.length === 0) {
      this.errorMessage = "There was an error loading the form.";
      return;
    }
    this.createColumnsForRecord(columnDefinitions);
    this.initialiseRows(rowDefinitions, columnDefinitions);
  }

  async initialiseDefault() {
    let glCodes = await this.getGlCodes();
    this.createDefaultColumns();
    this.initialiseRows(glCodes, []);
  }

  async getGlCodes() {
    let args = {
      formType: QFR,
    };
    let options = {}; // Options for Vlocity GenericInvoke eg queueable, future, continuation

    /** @type  {import("omnistudio").OmniRemoteCallParams} */
    let remoteCallParams = {
      input: JSON.stringify(args),
      sClassName: ApexControllerClassName,
      sMethodName: "getGLCodesForFormType",
      options: JSON.stringify(options),
    };
    let { result, error } = await this.omniRemoteCall(remoteCallParams, false);
    if (error)
      console.error(
        `An error occurred in a remote call. Details: ${JSON.stringify(result)}`
      );
    return [...result.glCodes];
  }

  async getDatatableDefinition() {
    let args = {
      formId: this.recordId,
    };
    let options = {};
    /** @type {import("omnistudio").OmniRemoteCallParams} */
    let remoteCallParams = {
      input: JSON.stringify(args),
      sClassName: ApexControllerClassName,
      sMethodName: "getServiceLineItemsForForm",
      options: JSON.stringify(options),
    };
    let { result, error } = await this.omniRemoteCall(remoteCallParams, false);
    if (error) {
      console.error(
        `An error occurred in a remote call. Details: ${JSON.stringify(result)}`
      );
    }
    return result.datatableDefinition;
  }

  createColumnsForRecord(columnDefinitions) {
    this.cols = columnDefinitions.map(
      (/** @type {ColumnDefinition} */ colDef, index) => {
        return {
          id: colDef.id,
          name: colDef.name,
          showToggle: index > 0, // hide from total column
          isEnabled: colDef.isEnabled,
        };
      }
    );
    return this.cols;
  }

  createDefaultColumns() {
    let numCols = 10;
    // Blank top left column
    let columns = [];
    for (let i = 1; i < numCols; i++) {
      columns.push({ id: "" + i, name: `Aged Care Service ${i}` });
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
  createBlankCells(numCells) {
    if (this._createBlankCells) return this._createBlankCells;

    /** @type {Cell[]} */
    let cells = [];
    for (let i = 0; i < numCells; i++) {
      cells.push({
        cellId: "" + i,
        value: null,
        type: "Currency",
        error: "Invalid value",
        showErrors: true,
        isReadOnly: false,
        rowId: null,
      });
    }
    this._createBlankCells = cells;
    return cells;
  }

  /**
   * @param {import("datatable").RowDefinition[]} rowDefinitions
   * @param {ColumnDefinition[]} columnDefinitions
   */
  initialiseRows(rowDefinitions, columnDefinitions) {
    this.initialiseRowDefinitionMaps(rowDefinitions);

    /** @type {Object.<string, Category>} */
    let categoriesById = {};

    /** @type {Map<string, Cell[]>} */
    let cellsByRowId = this.createCellsAndMapToRows(columnDefinitions);
    /** @type {Map<string, Row>} */
    let rowsById = new Map();

    rowDefinitions.forEach((rowDef) => {
      /** @type {Row} */
      let row = {
        id: rowDef.id,
        name: rowDef.name,
        entries: columnDefinitions
          ? cellsByRowId.get(rowDef.id)
          : this.createBlankCells(this.cols.length),
        inlineStyle: `padding-left: ${rowDef.depth}em`,
        parentRowId: rowDef.parentRowId,
        formula_string: rowDef.formula_string,
        get isReadOnly() {
          return (
            !!this.formula_string ||
            (rowDef.childRows && rowDef.childRows.length > 0)
          );
        },
      };
      rowsById.set(row.id, row);

      if (categoriesById[rowDef.category]) {
        let cat = categoriesById[rowDef.category];
        cat.rows.push(row);
        cat.order = Math.min(cat.order, rowDef.order);
      } else {
        categoriesById[rowDef.category] = {
          name: rowDef.category,
          rows: [row],
          order: rowDef.order,
          isExpanded: true,
        };
      }
    });

    for (let [k, v] of rowsById) {
      v.parentRow = rowsById.get(v.parentRowId);
    }

    this.rowsById = rowsById;
    this.categoriesById = categoriesById;

    // display categories in min display order of contents
    let categoriesArray = Object.values(categoriesById);
    categoriesArray.sort((a, b) => a.order - b.order);
    this.categories = categoriesArray;
    return categoriesArray;
  }

  /**
   * @param {ColumnDefinition[]} columnsWithData
   */
  createCellsAndMapToRows(columnsWithData) {
    let cellsById = new Map();
    let cellsByRowId = columnsWithData.reduce(
      (/** @type {Map<string, Cell[]>} */ accum, col) => {
        let rowsAppended = new Set();
        col.cells.forEach((cellData) => {
          let rowDef = this.rowDefinitionsById.get(cellData.rowDefinitionId);
          rowsAppended.add(rowDef.id);
          let readOnlyRow =
            (rowDef.childRows && rowDef.childRows.length > 0) ||
            !!rowDef.formula_string;
          /** @type {Cell} */
          let cell = {
            cellId: cellData.id,
            value: cellData.value,
            type: rowDef.type,
            error: "Invalid value",
            showErrors: false,
            isReadOnly: this.isReadOnly || readOnlyRow || !col.isEnabled,
            rowId: cellData.rowDefinitionId,
          };

          if (accum.has(cellData.rowDefinitionId)) {
            /** @type {Cell} */
            let totalCell = accum.get(cellData.rowDefinitionId)[0];
            cell.rowTotal = totalCell;
            totalCell.totalChildren.push(cell);

            accum.get(cellData.rowDefinitionId).push(cell);
          } else {
            cell.isReadOnly = true; // Total column is first column, and should be read-only.
            cell.totalChildren = [];
            accum.set(cellData.rowDefinitionId, [cell]);
          }

          cellsById.set(cell.cellId, cell);
        });
        // ensure if any columns don't have a GL Code Line item for a row, we add a cell to ensure the table cells are placed correctly
        for (let [k, v] of this.rowDefinitionsById) {
          if (!rowsAppended.has(k)) {
            let hiddenCell = {
              cellId: k + accum.size,
              value: null,
              type: null,
              error: null,
              showErrors: false,
              isReadOnly: true,
              rowId: k,
              isHidden: true,
            };
            // eslint-disable-next-line no-unused-expressions
            accum.get(k)?.push(hiddenCell) || accum.set(k, [hiddenCell]);
          }
        }
        return accum;
      },
      new Map()
    );

    this.cellsByRowId = cellsByRowId;
    this.cellsById = cellsById;

    return cellsByRowId;
  }

  /** @param {MouseEvent & {currentTarget: HTMLElement}} evt */
  handleCategoryClick(evt) {
    let categoryIndexStr = evt.currentTarget.getAttribute(
      "data-category-index"
    );
    let index = parseInt(categoryIndexStr, 10);
    this.categories[index].isExpanded = !this.categories[index].isExpanded;
    // required to cause rerender
    this.categories = [...this.categories];
  }

  /**
   * @param {Event & {currentTarget: HTMLElement}} evt
   */
  handleColumnToggle(evt) {
    let iteratorIndex = evt.currentTarget.getAttribute("data-col-index");
    let colIndex = parseInt(iteratorIndex, 10) - 1; // left column is headers
    let col = this.cols[colIndex];
    col.isEnabled = !col.isEnabled;
    let changes = [];
    for (let [k, v] of this.rowsById) {
      let cell = v.entries[colIndex];
      if (cell.isHidden) continue;
      if (!col.isEnabled) cell.value = 0.0;
      cell.isReadOnly = v.isReadOnly || !col.isEnabled;
      changes.push({ cellId: cell.cellId, value: cell.value });
    }

    this.updateCells(changes);
    this.updateColumn(col);
  }

  /**
   * @param {{ id: any; name?: string; isEnabled?: boolean; }} col
   */
  async updateColumn(col) {
    let update = { Id: col.id, Active__c: col.isEnabled };
    let args = {
      servicesJson: JSON.stringify([update]),
    };
    let options = {}; // Options for Vlocity GenericInvoke eg queueable, future, continuation

    /** @type  {import("omnistudio").OmniRemoteCallParams} */
    let remoteCallParams = {
      input: JSON.stringify(args),
      sClassName: ApexControllerClassName,
      sMethodName: "updateServices",
      options: JSON.stringify(options),
    };
    let { result, error } = await this.omniRemoteCall(remoteCallParams, false);
    this.omniRemoteCall(remoteCallParams, false);
    if (error)
      console.error(
        `An error occurred in a remote call. Details: ${JSON.stringify(result)}`
      );
  }

  alwaysAllowedCodes = new Set([
    "Tab",
    "Enter",
    "Backspace",
    "ArrowLeft",
    "ArrowRight",
    "Escape",
    "Delete",
  ]);
  /** @param {KeyboardEvent & {target: HTMLInputElement}} evt; */
  handleCellKeyDown(evt) {
    /** @type {string} */
    let previousValue = evt.target.value;
    const NUM_DECIMAL_PLACES = 2;
    if (evt.key === "Escape") {
      // blur on escape
      evt.target.blur();
    }
    if (this.alwaysAllowedCodes.has(evt.code)) {
      return;
    }

    // only accept numeric and decimal points (one) and specified other keys
    if (!(!isNaN(parseInt(evt.key, 10)) || evt.key === ".")) {
      evt.preventDefault();
    }

    // disallow adding more than one decimal place
    else if (evt.key === "." && previousValue.includes(".")) {
      evt.preventDefault();
    }

    // maximum 2 decimal places
    // check number of chars after .
    // and check whether selection is after .
    else if (
      previousValue.includes(".") &&
      previousValue.lastIndexOf(".") ===
        previousValue.length - (NUM_DECIMAL_PLACES + 1) &&
      evt.target.selectionStart > previousValue.lastIndexOf(".")
    ) {
      evt.preventDefault();
    }
  }

  handleExpandToggle(evt) {
    this.isExpanded = !this.isExpanded;
  }

  handleCellChange(evt) {
    const cellId = evt.target.getAttribute("data-record-id");
    if (!cellId || !this.cellsById.has(cellId)) return; // ensure change event is for a datatable cell
    // TODO: stop float from replacing cell? in case of bad imported data?
    // or maybe just set cols to numbers in excel template and tell people which cells have issues...
    const newValue = parseFloat(evt.target.value);
    this.updateCells([{ cellId, value: newValue }]);
  }

  /** @param {{cellId: string, value: number}[]} cells */
  updateCells(cells) {
    for (let cell of cells) {
      this.cellsById.get(cell.cellId).value = cell.value;
      this.changedCells[cell.cellId] = {
        Id: cell.cellId,
        Value__c: cell.value,
      };
    }
    let formulaUpdates = this.recalculateDependentValues(
      cells.map((cell) => cell.cellId)
    );
    // apply all updates to the existing changedCells map
    this.changedCells = formulaUpdates.reduce(
      (
        /** @type {{ [x:string]: GL_Code_Line_Item__c}} */ accum,
        updatedRecord
      ) => {
        accum[updatedRecord.Id] = updatedRecord;
        return accum;
      },
      this.changedCells
    );
    console.log(this.changedCells);

    this.categories = [...this.categories]; // ensures update, getters that currently trigger rerender may be removed
    this.persistChanges();
  }
  /**
   * @param {string[]} changedCellIds
   * @return {GL_Code_Line_Item__c[]}
   */
  recalculateDependentValues(changedCellIds, visitedSources = new Set()) {
    changedCellIds = changedCellIds.filter((id) => !visitedSources.has(id)); // ignore any already visited ids
    if (changedCellIds.length === 0) return [];
    visitedSources = new Set([...visitedSources, ...changedCellIds]);
    // calculate summaries
    let parentRecordChanges = this.recalculateSummaryRows(changedCellIds);
    let updatedIds = [
      ...changedCellIds,
      ...parentRecordChanges.map((cell) => cell.Id),
    ];
    // calculate row-level totals
    let totalCellChanges = this.recalculateRowTotal(updatedIds);

    // calculate custom formulae
    let formulaeUpdates = this.recalculateCustomFormulae([
      ...updatedIds,
      ...totalCellChanges.map((record) => record.Id),
    ]);

    updatedIds.push(...formulaeUpdates.map((cell) => cell.Id));

    return [
      ...parentRecordChanges,
      ...totalCellChanges,
      ...formulaeUpdates,
      ...this.recalculateDependentValues(updatedIds, visitedSources),
    ];
  }

  /**
   * @param {string[]} changedCellIds
   * @return {GL_Code_Line_Item__c[]}
   */
  recalculateSummaryRows(changedCellIds) {
    let parentRecordUpdates = [];
    for (let changedCellId of changedCellIds) {
      let changedCell = this.cellsById.get(changedCellId);
      let parentCell = this.getParentCell(changedCell);
      if (!parentCell) return [];
      if (this.rowsById.get(parentCell.rowId).formula_string) continue; // don't evaluate summary if this record has a custom formula

      let modifiedCellIndex = this.rowsById
        .get(changedCell.rowId)
        .entries.indexOf(changedCell);
      let childCells = this.getChildCells(parentCell, modifiedCellIndex);

      // recalculate summaries if cell has children
      let sum = 0;
      for (let childCell of childCells) {
        sum += childCell.value || 0;
      }
      parentCell.value = parseFloat(sum.toFixed(2));
      parentRecordUpdates.push({
        Id: parentCell.cellId,
        Value__c: parentCell.value,
      });
    }
    return parentRecordUpdates;
  }

  recalculateCustomFormulae(sourceCellIds) {
    let updatedRecords = [];
    let visitedTargets = new Set();
    for (let changedCellId of sourceCellIds) {
      let changedCell = this.cellsById.get(changedCellId);
      let changedCellIndex = this.rowsById
        .get(changedCell.rowId)
        .entries.indexOf(changedCell);
      let targetFormulae = this.formulaeBySourceRowId.get(changedCell.rowId);
      if (targetFormulae) {
        // recalculate formula for all affected cells
        for (let formula of targetFormulae) {
          let targetCell = this.rowsById.get(formula.targetRowId).entries[
            changedCellIndex
          ];
          if (targetCell.isHidden) continue; // hidden target cells should not be evaluated
          if (visitedTargets.has(targetCell.cellId)) continue;

          visitedTargets.add(targetCell.cellId);

          let args = new Map();
          formula.sourceRowIds.forEach((sourceRowId) =>
            args.set(
              sourceRowId,
              this.rowsById.get(sourceRowId)?.entries[changedCellIndex]
                ?.value || 0
            )
          );
          console.log("try calling formula");
          let newValue = formula.formula(args);

          targetCell.value = parseFloat(newValue.toFixed(2));
          updatedRecords.push({ Id: targetCell.cellId, Value__c: newValue });
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
    let rowDef = this.rowDefinitionsById.get(parentCell.rowId);
    let childRowIds = rowDef.childRows.map((curr) => curr.id);
    let childRows = childRowIds.map((childRowId) =>
      this.rowsById.get(childRowId)
    );
    // child cells will all have same index as they will be in the same column
    return childRows.map((row) => row.entries[cellIndex]);
  }

  /**
   * @param {Cell} cell
   */
  getParentCell(cell) {
    let row = this.rowsById.get(cell.rowId);
    let cellIndex = row.entries.indexOf(cell);
    return row?.parentRow?.entries[cellIndex];
  }

  /**
   *
   * @param {string[]} changedCellIds
   * @returns
   */
  recalculateRowTotal(changedCellIds) {
    let changedTotalRecords = [];
    let evaluatedTotals = new Set();
    for (let currId of changedCellIds) {
      let totalCell = this.cellsById.get(currId).rowTotal;
      if (!totalCell || evaluatedTotals.has(totalCell)) continue;
      evaluatedTotals.add(totalCell); // prevent re-evaluating same row repeatedly

      let newTotal = totalCell.totalChildren.reduce(
        (accum, curr) => (accum += curr.value || 0),
        0
      );
      totalCell.value = parseFloat(newTotal.toFixed(2));
      changedTotalRecords.push({
        Id: totalCell.cellId,
        Value__c: totalCell.value,
      });
    }
    return changedTotalRecords;
  }

  persistChanges = debounce(async () => {
    let changesArray = Object.values(this.changedCells);
    if (!changesArray.length) {
      // do nothing if there are no changes to persist.
      return;
    }
    this.changedCells = {};
    this.isSaving = true;
    let args = {
      glCodeLineItemJson: JSON.stringify(changesArray),
    };
    let options = {}; // Options for Vlocity GenericInvoke eg queueable, future, continuation

    /** @type  {import("omnistudio").OmniRemoteCallParams} */
    let remoteCallParams = {
      input: JSON.stringify(args),
      sClassName: ApexControllerClassName,
      sMethodName: "updateCells",
      options: JSON.stringify(options),
    };
    let { result, error } = await this.omniRemoteCall(remoteCallParams, false);
    this.omniRemoteCall(remoteCallParams, false);
    if (error)
      console.error(
        `An error occurred in a remote call. Details: ${JSON.stringify(result)}`
      );
    else {
      this.lastSavedDate = new Date().toLocaleString("en-au");
    }
    this.isSaving = false;
  }, AUTOSAVE_DEBOUNCE_MS);

  initialiseRowDefinitionMaps(rowDefinitions) {
    /** @type {Map<string, import("datatable").RowDefinition>} */
    let rowDefinitionsById = new Map();
    /** @type {Map<string, string>} */
    let rowIdToParentId = new Map();

    rowDefinitions.forEach(
      (/** @type {import("datatable").RowDefinition} */ rowDefinition) => {
        rowDefinitionsById.set(rowDefinition.id, rowDefinition);
        rowIdToParentId.set(rowDefinition.id, rowDefinition.parentRowId);
        rowDefinition.childRows = [];
      }
    );

    // calculate depths for rows and store direct children as array
    this.rowDefinitionSetup(rowDefinitionsById, rowIdToParentId);

    this.rowDefinitionsById = rowDefinitionsById;
    this.rowIdToParentId = rowIdToParentId;
    return [rowDefinitionsById, rowIdToParentId];
  }

  /**
   * @param {Map<string, import("datatable").RowDefinition>} rowDefinitionsById
   * @param {Map<string, string>} rowIdToParentId
   */
  rowDefinitionSetup(rowDefinitionsById, rowIdToParentId) {
    /** @type {Map<string, FormulaInfo[]>} */
    let formulaeBySourceRowId = new Map();
    for (let [k, v] of rowDefinitionsById) {
      // add child rows under parent
      let parentRow = rowDefinitionsById.get(rowIdToParentId.get(k));
      if (parentRow) parentRow.childRows.push(v);

      // calculate depth of each row within categories
      let depth = -1; // sets depth to 0 if no children
      while (k) {
        depth++;
        let currParent = rowDefinitionsById?.get(rowIdToParentId.get(k));

        k = currParent?.category === v.category ? currParent.id : null;
      }
      v.depth = depth;

      // evaluate formulae attached to rows and create functions from them
      if (v.formula_string) {
        try {
          let parseResult = parseFormula(v.formula_string);
          /** @type {FormulaInfo} */
          let formulaInfo = {
            targetRowId: v.id,
            formula: parseResult.formula,
            sourceRowIds: parseResult.sourceIds,
          };
          for (const sourceId of parseResult.sourceIds) {
            let mappedFormulae = formulaeBySourceRowId.get(sourceId) || [];
            mappedFormulae.push(formulaInfo);
            formulaeBySourceRowId.set(sourceId, mappedFormulae);
          }
        } catch (e) {
          // TODO: nicer error handling when invalid formula supplied...?
          console.error(e);
        }
      }
    }
    this.formulaeBySourceRowId = formulaeBySourceRowId;
  }
}