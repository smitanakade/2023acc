import { api, LightningElement, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { CurrentPageReference, NavigationMixin } from "lightning/navigation";
import Id from "@salesforce/user/Id";
//import Id from '@salesforce/community/Id';
import getReportingPeriods from "@salesforce/apex/QiFileUploadController.getReportingPeriods";
import autoSave from "@salesforce/apex/QiFileUploadController.autoSave";
import sendToTRIMExt from "@salesforce/apex/QiFileUploadController.sendToTRIMExt";
import isExternal from "@salesforce/apex/QiFileUploadController.isExternal";
import ARROW_DOWN_ICON from "@salesforce/resourceUrl/QiDownloadIcon";
import EXCEL_ICON from "@salesforce/resourceUrl/excel";

const templateLink =
  "https://www.health.gov.au/sites/default/files/2023-05/qi-program-file-upload-template.xlsx";
const downloadTitle = "Download the QI Program file upload template";

export default class QiFileUploadInstructions extends NavigationMixin(
  LightningElement
) {
  title = downloadTitle;
  fileUrl = templateLink;
  uploadedFiles;
  sendToTRIMExtResponse;

  rpOptionsResposne;
  options = [];
  value;
  rpId;
  rpReadOnly = false;

  fileStagingId;
  @api stagingId;
  realStaingId;

  showLock = true;
  unlock = false;
  disableButton = true;
  error;

  //communityId = Id;
  userId = Id;
  showBanner = false;
  containerClass = "container-alter";
  isExternalUser;

  //icons
  download = ARROW_DOWN_ICON;
  excel = EXCEL_ICON;

  @wire(CurrentPageReference)
  getStateParameters(currentPageReference) {
    if (currentPageReference) {
      this.fileStagingId = currentPageReference.state?.fileStagingId;
      this.rpReadOnly = currentPageReference.state?.isReupload;
      this.prvPage = currentPageReference.state?.prvPage;
    }
  }

  /*disconnectedCallback() {
    console.log('disconnected:: ');
    this.fileStagingId = undefined;
    this.rpReadOnly = undefined;
  }*/

  connectedCallback() {
    console.log("userId", this.userId);
    isExternal({ userId: this.userId })
      .then((result) => {
        this.isExternalUser = result;
        if (this.isExternalUser) {
          this.showBanner = true;
          this.containerClass = "container";
        }
      })
      .catch((error) => {
        this.error = error;
        this.handleToast("Error", error.body.message, "error", "dismissible");
      })
      .finally(() => {
        console.log("isExternalUser", this.isExternalUser);
      });
    if (this.stagingId != null && this.fileStagingId == null) {
      this.realStaingId = this.stagingId;
    } else if (this.stagingId == null && this.fileStagingId != null) {
      this.realStaingId = this.fileStagingId;
    } else {
      this.realStaingId = undefined;
      this.error =
        "There isn't an associated File Upload Record preloaded for this execution.";
      this.handleToast("Error", this.error, "error", "dismissible");
    }

    if (this.realStaingId != null) {
      getReportingPeriods({
        fileStagingId: this.realStaingId
      })
        .then((result) => {
          this.rpOptionsResposne = JSON.parse(result);
          this.options = this.rpOptionsResposne.rpOptions;
          this.value = this.rpOptionsResposne.value;
          this.rpId = this.rpOptionsResposne.id;
        })
        .catch((error) => {
          this.error = error;
          this.handleToast("Error", error.body.message, "error", "dismissible");
        });
    }
  }

  get acceptedFormats() {
    return [".xlsx , .csv"];
  }

  handleChange(event) {
    const selectedOne = this.options.find(
      (obj) => obj.value === event.detail.value
    );
    this.value = event.detail.value;
    this.rpId = selectedOne.id;

    if (this.realStaingId != null) {
      autoSave({
        fileStagingId: this.realStaingId,
        reportingPeriodId: this.rpId
      })
        .then((result) => {
          console.log("AutoSave result", result);
        })
        .catch((error) => {
          this.error = error;
          this.handleToast("Error", error.body.message, "error", "dismissible");
        });
    }
  }

  handleUploadFinished(event) {
    // Get the list of uploaded files
    this.uploadedFiles = event.detail.files;
    console.log("uploadedFiles", this.uploadedFiles);
    console.log("uploadedFiles element", this.uploadedFiles[0]);
    console.log("uploadedFiles element id", this.uploadedFiles[0].documentId);
    this.disableButton = false;
    this.showLock = false;
    this.unlock = true;
    this.handleToast(
      "Success",
      "You have successfully uploaded " + this.uploadedFiles.length + " files",
      "success",
      "dismissible"
    );
  }

  removeFile(event) {
    const index = event.currentTarget.dataset.id;
    this.uploadedFiles.splice(index, 1);
    if (this.uploadedFiles.length === 0) {
      this.uploadedFiles = undefined;
      this.disableButton = true;
      this.showLock = true;
      this.unlock = false;
    }
  }

  async handleClick() {
    if (this.realStaingId != null && this.uploadedFiles[0].documentId != null) {
      try {
        const result = await sendToTRIMExt({
          fileStagingId: this.realStaingId,
          uploadedFileId: this.uploadedFiles[0].documentId
        });
        this.sendToTRIMExtResponse = result;
        console.log("sendToTRIMExtResponse", this.sendToTRIMExtResponse);
        this.handleToast(
          "Success",
          this.sendToTRIMExtResponse,
          "success",
          "dismissible"
        );

        if (this.fileStagingId != null) {
          this[NavigationMixin.Navigate](
            {
              type: "comm__namedPage",
              attributes: {
                name: "Quality_Indicator_File_Upload_status__c"
              },
              state: {
                filestagingid: this.realStaingId,
                prvPage: this.prvPage
              }
            },
            true
          );
        }

        if (this.stagingId != null) {
          this[NavigationMixin.Navigate]({
            type: "standard__recordPage",
            attributes: {
              recordId: this.stagingId,
              actionName: "view"
            }
          });
        }
      } catch (error) {
        this.error = error;
        this.handleToast("Error", error.body.message, "error", "dismissible");
      } finally {
      }
    }
  }

  downloadTemplate() {
    const config = {
      type: "standard__webPage",
      attributes: {
        url: this.fileUrl
      }
    };
    this[NavigationMixin.Navigate](config);
  }

  handleToast(title, message, variant, mode) {
    this.dispatchEvent(
      new ShowToastEvent({
        title: title,
        message: message,
        variant: variant,
        mode: mode
      })
    );
  }
}