import { LightningElement, api, track } from "lwc";
import { OmniscriptBaseMixin } from "omnistudio/omniscriptBaseMixin";
import writeXlsxFile from "c/writeExcelFile";

const INDENT_SPACER = "    ";
const PERCENT_TOTAL = 100;
const TYPE_TO_CELL_FORMAT = {
  Currency: { type: Number, format: "$#,##0.00" },
  Percentage: { type: Number, format: "0.00%" }
  //'Numeric': { type: Number, format: `"hrs" 0.00`}
};

export default class AcfrDownloadExcel extends LightningElement {
  datatableDefinitions;
  @api rowDefinitions;
  @api columnDefinitions;

  categoriesData;
  colsData;
  @api cols;
  // /** @type {import("datatable").Category[]} */
  @api categories;
  rowDefinationsParent;
  dataTableRows = [];

  @api formId;
  @api formType;

  async download() {
    this.dataTableRows = [];
    this.colsData = this.cols;
    this.generateDataFromCategories();
    this.writeExcel();
  }

  generateDataFromCategories() {
    const backgroundCells = [];

    const recordId = [{ value: `ID: ${this.formId}` }];
    this.dataTableRows.push(recordId);

    const colHeader = [{ value: "" }];
    // makes rest of category row blue
    const backgroundCell = {
      value: "",
      fontWeight: "bold",
      fontSize: 16,
      backgroundColor: "#D6EAF8"
    };
    const hiddenCell = { value: "", backgroundColor: "#E5E5E5" };
    this.cols.forEach((col) => {
      colHeader.push({ value: col.name, fontWeight: "bold", wrap: true });
      backgroundCells.push(backgroundCell);
    });
    this.dataTableRows.push(colHeader);

    this.categories.forEach((category) => {
      const categoryHeading = [
        {
          value: category.name,
          fontWeight: "bold",
          fontSize: 16,
          backgroundColor: "#D6EAF8",
          width: category.name.length,
          wrap: true
        }
      ];
      categoryHeading.push(...backgroundCells);
      this.dataTableRows.push(categoryHeading);

      category.rows.forEach((row) => {
        const sheetRow = [];
        let currentRowSpacer = "";
        for (let i = 0; i < row.depth; i++) {
          currentRowSpacer += INDENT_SPACER;
        }
        sheetRow.push({ value: currentRowSpacer + row.name, wrap: true });
        row.entries.forEach((cell) => {
          if (cell.isHidden) {
            sheetRow.push(hiddenCell);
            return; // skip if hidden
          }
          // separate to make it easier to modify readonly cells
          if (cell.isReadOnly) {
            sheetRow.push(hiddenCell);
            return;
          }

          let dataRowValue;
          if (cell.type === "Percentage") {
            dataRowValue = cell.value / PERCENT_TOTAL;
          } else {
            dataRowValue = cell.value;
          }

          const formatProps = TYPE_TO_CELL_FORMAT[cell.type] || {};
          const elementValue = { value: dataRowValue, ...formatProps };
          sheetRow.push(elementValue);
        });
        this.dataTableRows.push(sheetRow);
      });
    });
  }

  // async connectedCallback() {}

  async generateData() {
    this.dataTableRows = [];
    const rowDefinitionsById = new Map();
    const rowIdToParentRowId = {};
    const categoryHeader = new Set();

    this.rowDefinationsParent.forEach((row) => {
      //rowDefinitionsById[row.id] = row;
      rowDefinitionsById.set(row.id, row);
      if (row.parentRowId) {
        rowIdToParentRowId[row.id] = row.parentRowId;
      }
    });

    this.rowDefinationsParent.forEach((rowDef) => {
      const rowDepth = this.getDepthOfRowDefinition(
        rowDef.id,
        rowDef,
        rowDefinitionsById,
        rowIdToParentRowId
      );

      const rowOfColumns = [];

      //generate category headers from the rowDefination category
      if (!categoryHeader.has(rowDef.category)) {
        const categoryHeading = [];
        categoryHeader.add(rowDef.category);
        categoryHeading.push({
          value: rowDef.category,
          fontWeight: "bold",
          fontSize: 16,
          backgroundColor: "#D6EAF8",
          wrap: true
        });
        this.columnDefinitions.forEach(() => {
          categoryHeading.push({
            value: "",
            fontWeight: "bold",
            fontSize: 16,
            backgroundColor: "#D6EAF8"
          });
        });
        this.dataTableRows.push(categoryHeading);
      }

      //GL code indentention based on the ParentRow
      let currentRowSpacer = "";
      for (let i = 0; i < rowDepth; i++) {
        currentRowSpacer += INDENT_SPACER;
      }
      rowOfColumns.push({
        value: currentRowSpacer + rowDef.name,
        width: rowDef.name.length
      });
      rowDef.cells = rowOfColumns;
      // adding row in and pushing cells below - preserves order within category headings
      this.dataTableRows.push(rowDef.cells);
    });

    // adding cells to each row
    this.columnDefinitions.forEach((col) => {
      const visitedRowIds = new Set();
      col.data.forEach((dataRow) => {
        const rowDef = rowDefinitionsById.get(dataRow.rowDefinitionId);
        visitedRowIds.add(dataRow.rowDefinitionId);

        const formatProps = TYPE_TO_CELL_FORMAT[rowDef.type] || {};
        let dataRowValue;
        if (rowDef.type === "Percentage") {
          dataRowValue = dataRow.value / PERCENT_TOTAL;
        } else {
          dataRowValue = dataRow.value;
        }

        const elementValue = { value: dataRowValue, ...formatProps };
        rowDef.cells.push(elementValue);
      });

      for (const k of rowDefinitionsById.keys()) {
        if (!visitedRowIds.has(k)) {
          const rowDef = rowDefinitionsById.get(k);
          // /** @type {Cell} */
          const hiddenCell = {
            value: ""
          };
          rowDef.cells.push(hiddenCell);
        }
      }
    });

    //Creating header rows from the columnDefinations
    let headerRow = [];
    this.columnDefinitions.forEach((col) => {
      const headerElement = {
        value: col.name,
        fontWeight: "bold",
        width: 700,
        wrap: true
      };
      headerRow.push(headerElement);
    });

    this.dataTableRows.unshift(headerRow);
    headerRow = [];
  }

  getColWidth = (index) => {
    const firstColWidth = 50;
    const secondColWidth = 10;
    const restColWidth = 30;

    if (index === 0) {
      return firstColWidth;
    } else if (index === 1) {
      return secondColWidth;
    } else {
      return restColWidth;
    }
  };

  async writeExcel() {
    const columns = [];
    for (let i = 0; i <= this.cols.length; i++) {
      columns.push({ width: this.getColWidth(i) });
    }
    await writeXlsxFile(this.dataTableRows, {
      columns,
      fileName: this.formType + ".xlsx"
    });
  }

  getDepthOfRowDefinition(rowId, row, rowDefinitionsById, rowIdToParentId) {
    let depth = -1; // sets depth to 0 if no children
    const visited = new Set();
    while (rowId && !visited.has(rowId)) {
      depth++;
      visited.add(rowId);
      const currParent = rowDefinitionsById.get(rowIdToParentId[rowId]);
      rowId = currParent?.category === row.category ? currParent.id : null;
    }
    return depth;
  }

  /*async getRecordData() {
let args = {
formId: this.formId
};

let options = {};
let remoteCallParams = {
input: JSON.stringify(args),
sClassName: 'AcfrCustomDatatableController',
sMethodName: 'getDatatableDefinitionForForm',
options: JSON.stringify(options)
}

let { result, error } = await this.omniRemoteCall(remoteCallParams, false);
this.datatableDefinitions = result.datatableDefinition;
console.log('Datatable retrived '+JSON.stringify(this.datatableDefinitions));
this.rowDefinitions = this.datatableDefinitions.rowDefinitions;
this.columnDefinitions = this.datatableDefinitions.columnDefinitions;

}
*/
}
