import  writeXlsxFile from 'c/writeExcelFile';

const TYPE_TO_CELL_FORMAT = {
  'Currency': {type: Number, format: '$#,##0.00'},
  'Percentage': { type: Number, format: '0.00%'}
}

export default class DatatableDownloader {

  createRemoteCall(formId) {
    let args = {
      formId: formId
    };
    let options = {};

    let remoteCallParams = {
      input: JSON.stringify(args),
      sClassName: 'AcfrCustomDatatableController',
      sMethodName: 'getDatatableDefinitionForForm',
      options: JSON.stringify(options)
    }
    return remoteCallParams;
  }

  generateSheet(rowDefinitions, columnDefinitions) {
    const dataTableRows = [];
    const rowDefinitionsById = new Map();
    const rowIdToParentRowId = {}
    const INDENT_SPACER = '    ';
    const categoryHeader = new Set(); 
    let cellsByRowId = new Map();

    rowDefinitions.forEach((row) => { 
      rowDefinitionsById.set(row.id, row);
      if (row.parentRowId) {
        rowIdToParentRowId[row.id] = row.parentRowId;
      }
    });


    rowDefinitions.forEach((rowDef) => { 
      let rowDepth = this.getDepthOfRowDefinition(rowDef.id, rowDef, rowDefinitionsById, rowIdToParentRowId);
      let rowOfColumns = [];

      //generate category headers from the rowDef category
      if(!categoryHeader.has(rowDef.category)) {
        let categoryHeading = [];
        categoryHeader.add(rowDef.category);
        categoryHeading.push({value:rowDef.category, fontWeight: 'bold', fontSize:16, backgroundColor:'#D6EAF8'});
        columnDefinitions.forEach((colDef) => {
          categoryHeading.push({value:'', fontWeight: 'bold', fontSize:16, backgroundColor:'#D6EAF8'});
        });
        dataTableRows.push(categoryHeading);
      }

      //GL code indentention based on the ParentRow
      let currentRowSpacer = '';
      for (let i = 0; i < rowDepth; i++) {
        currentRowSpacer += INDENT_SPACER;
      }
      rowOfColumns.push({ value:currentRowSpacer+rowDef.name });
      rowDef.cells = rowOfColumns;
      // adding row in and pushing cells below - preserves order within category headings
      dataTableRows.push(rowDef.cells);
    });

    // adding cells to each row
    console.log('columnDefinitions', columnDefinitions);
    columnDefinitions.forEach((col) => {
      let visitedRowIds = new Set();
      col.data.forEach((dataRow) => {
        let rowDef = rowDefinitionsById.get(dataRow.rowDefinitionId);
        visitedRowIds.add(dataRow.rowDefinitionId);

        let dataRowValue;
        let cellValue = dataRow.value || 0;
        if (rowDef.type === 'Percentage') {
          dataRowValue = cellValue / 100;
        } else {
          dataRowValue =  cellValue;
        }

        let formatProps = TYPE_TO_CELL_FORMAT[rowDef.type] || {};
        let elementValue = {value:dataRowValue, ...formatProps};
        rowDef.cells.push(elementValue);
        cellsByRowId.set(dataRow.rowDefinitionId, [rowDef.cells]);
      });

      for (const [key, row] of rowDefinitionsById) {
        if (!visitedRowIds.has(key)) {
          let hiddenCell = {
            value: ''
          };
          row.cells.push(hiddenCell);
        }
      }
    });

    //Creating header rows from the columnDefinations
    let headerRow = [{value:''}];        
    columnDefinitions.forEach((col) => {
      let headerElement = {
        value: col.name,
        fontWeight: 'bold'
      };
      headerRow.push(headerElement);
    });

    dataTableRows.unshift(headerRow);
    return dataTableRows; 
  }

  getDepthOfRowDefinition(rowId, row, rowDefinitionsById, rowIdToParentId){
    let depth = -1; // sets depth to 0 if no children
    const visited = new Set();
    while (rowId && !visited.has(rowId)) {
      depth++;
      visited.add(rowId);
      let currParent = rowDefinitionsById.get(rowIdToParentId[rowId]);
      rowId = currParent?.category === row.category ? currParent.id : null;
    }
    return depth;
  }
}