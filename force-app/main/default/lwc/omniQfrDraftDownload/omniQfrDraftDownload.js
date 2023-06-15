import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation'
import { OmniscriptBaseMixin } from "omnistudio/omniscriptBaseMixin";
import datatableDownloader from './datatableDownloader';
import viabilityDownloader from './viabilityDownloader';
import writeXlsxFile from 'c/writeExcelFile';

export default class OmniQfrDraftDownload extends OmniscriptBaseMixin(NavigationMixin(LightningElement)) {
  @api
  recordId; 

  @api 
  isDraft;

  @api
  isDownload;
  
  isComplete = false;

  get loadingInfo() {
    if (this.isDraft) {
      return 'Saving draft, please wait...'
    } else if (this.isDownload) {
      return 'Downloading, please wait...'
    }
    return 'Saving, please wait...'
  }


  async connectedCallback() {
    if (!this.recordId) return;
    const formDetails = await this.getFormDetailsFromCase(this.recordId);
    const sheetNames = [];
    const requests = [];

    for (let formDetail of formDetails) {
      sheetNames.push(formDetail.formType.substr(0, 32));
      if (formDetail.downloader === 'viability') {
        requests.push(this.createViabilitySheet(formDetail));
      }
      else if (formDetail.downloader === 'datatable') {
        requests.push(this.createDatatableSheet(formDetail));
      }
    }

    const sheets = await Promise.all(requests);

    const now = new Date();
    const timestamp = now.toLocaleString('en-US');
    if (this.isDraft) {
      await writeXlsxFile(sheets, {
        sheets: sheetNames,
        fileName: `DRAFT_QFR${timestamp}.xlsx`
      });
      this.returnHome();
    }
    else if (this.isDownload) {
      // download pdf from SF

      await writeXlsxFile(sheets, {
        sheets: sheetNames,
        fileName: `SUBMITTED_QFR${timestamp}.xlsx`
      });
      this.returnHome();
    }
    else { 
      let fileContent = await writeXlsxFile(sheets, {
        sheets: sheetNames,
      });
      this.saveFile(this.recordId, fileContent);
    }


  } 

  async getFormDetailsFromCase(caseId) {
    const args = {
      caseId: caseId 
    };
    const options = {};

    /** @type {import("omnistudio").OmniRemoteCallParams} */
    const remoteCallParams = {
      input: JSON.stringify(args),
      sClassName: 'QFRDownloadController',
      sMethodName: 'getFormIdsForCase',
      options: JSON.stringify(options)
    };

    let { result, error } = await this.omniRemoteCall(remoteCallParams, false);
    if (error) {
      console.error(`An error occurred in a remote call. Details: ${JSON.stringify(result)}`);
    }

    return [...result.formDetails];
  }

  async createViabilitySheet(formDetail) {
    const downloader = new viabilityDownloader();
    const remoteCallParams = downloader.createRemoteCall(formDetail.formId)
    const response = await this.retrieveForm(remoteCallParams);
    if (response.error) return [[]];
    const sheet = downloader.generateSheet(response.result.responses);
    return sheet;
  }

  async createDatatableSheet(formDetail) {
    const downloader = new datatableDownloader();
    const remoteCallParams = downloader.createRemoteCall(formDetail.formId)
    const response = await this.retrieveForm(remoteCallParams);
    if (response.error) return [[]];

    let { rowDefinitions, columnDefinitions } = response.result.datatableDefinition;
    const sheet = downloader.generateSheet(rowDefinitions, columnDefinitions);
    return sheet;
  }

  async getSubmittedQfrFile() {
    
  }


  async retrieveForm(remoteCallParams) {
    const response = await this.omniRemoteCall(remoteCallParams, false);
    if (response.error) {
      console.error(`An error occurred in remote call to retrieve form. Details: ${JSON.stringify(response)}`);
      return response; 
    }
    return response;
  }


  saveFile(recordId, contentBody) {
    const reader = new FileReader();
    reader.onloadend = async () => {
      let args = {
        recordId,
        contentBody: (reader.result.substr(reader.result.indexOf(',') + 1))
      }; 
      /** @type {import("omnistudio").OmniRemoteCallParams} */
      let remoteCallParams = {
        input: JSON.stringify(args),
        sClassName: 'QFRDownloadController',
        sMethodName: 'saveExcelFile',
        options: '{}',
      };

      let { result, error } = await this.omniRemoteCall(remoteCallParams, false);
      if (error)
      console.error(
        `An error occurred when saving the file. Details: ${JSON.stringify(result)}`
      );
      this.navigateToConfirmSubmission();
    }
    reader.readAsDataURL(contentBody);
  }

  navigateToConfirmSubmission() {
    this[NavigationMixin.Navigate]({
      type: 'comm__namedPage',
      attributes: {
        name: 'QFR_Submission_Confirmation__c'
      }
    });
  }

  returnHome() {
    this[NavigationMixin.Navigate]({
      type: 'comm__namedPage',
      attributes: {
        name: 'QFR_Submission_Home_Page__c'
      }
    });
  }

}
