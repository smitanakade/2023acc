import writeXlsxFile from 'c/writeExcelFile';

export default class ViabilityDownloader {
  createRemoteCall(formId) {
    let args = {
      formId: formId
    };
    let options = {};

    let remoteCallParams = {
      input: JSON.stringify(args),
      sClassName: 'QfrDownloadController',
      sMethodName: 'getViabilityForm',
      options: JSON.stringify(options)
    }

    return remoteCallParams; 
  }

  generateSheet(formInformation) {
    let excelRows = [];
    excelRows.push(this.createHeaders());
    formInformation = formInformation || [];
    for (let formInfo of formInformation) {
      let currRow = [];
      currRow.push({value: formInfo.question});
      currRow.push({value: formInfo.response});
      currRow.push({value: formInfo.additionalInformation});
      currRow.push({value: formInfo.careServices});
      currRow.push({value: formInfo.additionalCareServices});
      currRow.push({value: formInfo.additionalBusinessStructure});
      excelRows.push(currRow);
    }
    if (!excelRows.length) {
      excelRows.push([{value: ''}]);
    }
    return excelRows;
  }

  //Creating header rows from the columnDefinations
  createHeaders() {
    return [
      {value: 'Question', fontWeight: 'bold'},
      {value: 'Yes/No', fontWeight: 'bold'},
      {value: 'Response Additional Info', fontWeight: 'bold'},
      {value: 'Care Types', fontWeight: 'bold'},
      {value: 'Additional Care Type', fontWeight: 'bold'},
      {value: 'Additional Business Structure', fontWeight: 'bold'},
    ]
  }
}