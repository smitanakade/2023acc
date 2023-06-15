/**
 * @author Yifei Pei
 * @date: 11-04-2023
 * @objects:
 * @description:
 */

import { LightningElement, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { CurrentPageReference } from "lightning/navigation";
import getVersionInfo from "@salesforce/apex/SRQIVersionController.getVersionInfo";

import { publish, MessageContext } from "lightning/messageService";
import VERSION_CHANNEL from "@salesforce/messageChannel/Version_Message__c";

export default class srqiVersionControl extends LightningElement {
  hasPreviousVersion = false;
  value;
  currentVersion;
  lastUpdated;
  currentStatus;
  buttonStyle;
  showWarning = false;
  readOnly = false;
  readOnlyContent;

  inputResponse;
  previousVersions = [];
  error;

  @wire(MessageContext)
  messageContext;
  @wire(CurrentPageReference)
  getStateParameters(currentPageReference) {
    if (currentPageReference) {
      this.qiSummaryId = currentPageReference.state?.qisid;
    }
  }

  connectedCallback() {
    getVersionInfo({ qisId: this.qiSummaryId })
      .then((result) => {
        this.previousVersions = JSON.parse(JSON.stringify(result));
        if (this.previousVersions.length > 1) {
          this.hasPreviousVersion = true;
          this.setIntialValue(this.previousVersions[0]);
        } else {
          if (this.previousVersions.length > 0) {
            this.setIntialValue(this.previousVersions[0]);
          }
        }
      })
      .catch((error) => {
        this.handleToast("Error", error.body.message, "error", "dismissible");
      });
  }

  setIntialValue(data) {
    this.value = data.value;
    this.currentVersion = data.value;
    this.lastUpdated = data.lastUpdated;
    this.currentStatus = data.status;
    this.handleStatus(data.status);
    this.handleWarning(data);
    this.handleMessage(data.qisvId);
  }

  handleChange(event) {
    const selectedOne = this.previousVersions.find(
      (obj) => obj.value === event.detail.value
    );
    this.value = event.detail.value;
    this.currentVersion = event.detail.value;
    this.lastUpdated = selectedOne.lastUpdated;
    this.currentStatus = selectedOne.status;
    this.handleStatus(this.currentStatus);
    this.handleWarning(selectedOne);
    this.handleMessage(selectedOne.qisvId);
  }

  handleMessage(qisvId) {
    const payload = { qisvId: qisvId };
    publish(this.messageContext, VERSION_CHANNEL, payload);
  }

  handleStatus(status) {
    switch (status) {
      case "Not Started":
        this.buttonStyle = "background:#00546E;color:#FFFFFF;";
        break;
      case "In Progress":
        this.buttonStyle = "background:#FFA400;color:#000000;";
        break;
      case "Submitted":
        this.buttonStyle = "background:#216515;color:#FFFFFF;";
        break;
      case "Not Submitted":
        this.buttonStyle = "background:#E91E63;color:#FFFFFF;";
        break;
      case "Submitted - Updated After Due Date":
        this.buttonStyle = "background:#FFF6E6;color:#4D8144;";
        break;
      case "Late Submission":
        this.buttonStyle = "background:#EEEEEE;color:#000000;";
        break;
      default:
        this.buttonStyle = "background:#00546E;color:#FFFFFF;";
        break;
    }
  }

  handleWarning(data) {
    if (data.isReadOnly) {
      this.showWarning = false;
      this.readOnly = true;
      this.readOnlyContent =
        "This page is read-only. This page is read-only as this report is outside of the current/previous reporting period.";
    } else {
      if (data.isCurrent || data.isDraft) {
        this.showWarning = true;
        this.readOnly = false;
      } else {
        this.showWarning = false;
        this.readOnly = true;
        this.readOnlyContent =
          "This page is read-only. To view and update your current quality indicator data submission please use the 'Previous Submissions' tab above.";
      }
    }
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

  handleClose() {
    this.showWarning = false;
  }

  handleReadOnlyClose() {
    this.readOnly = false;
  }
}