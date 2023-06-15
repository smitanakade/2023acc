/**
 * @author Yifei Pei
 * @date: 08-03-2023
 * @objects: Quality_Indicator_Summary__c, Quality_Indicator_Details__c
 * @description: the submission page in srqiQuestionDataCaptureForm so the QI summary can be submitted
 */

import { api, LightningElement, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { CurrentPageReference, NavigationMixin } from "lightning/navigation";
import getDomainInfo from "@salesforce/apex/SRQISubmissionController.getDomainInfo";
import submitRecord from "@salesforce/apex/SRQISubmissionController.submitRecord";
import submitVersionRecord from "@salesforce/apex/SRQISubmissionController.submitVersionRecord";
import getVersionInfo from "@salesforce/apex/SRQIVersionController.getVersionInfo";
//import message service features
import { subscribe, MessageContext } from "lightning/messageService";
import BUTTON_CLICKED_CHANNEL from "@salesforce/messageChannel/Button_Clicked__c";

const qidCompleteStatus = "Completed";
const submitTitle = "Complete your Quality Indicator record";
const reSubmitTitle = "Resubmit your Quality Indicator report";
const lateSubmitTitle = "Late Submission";
const updatedTitle = "Submitted - Updated after Due Date";

export default class SrqiSubmission extends NavigationMixin(LightningElement) {
  concludingText =
    "This quality indicator data will overwrite all previously entered data.";
  disableButton;
  submissionTitle;
  isCompleteText;
  isSubmitText;
  isMissingText;

  qiSummaryId;
  domainResponse;
  domainInfo;
  uncompletedDomains = [];
  isSubmittable = false;
  isAmended = false;
  isCompleted = false;
  isLateSubmission = false;

  versionResponse;

  submitResponse;
  error;
  isLoading = false;

  @api questionSectionLength;
  @api qisvId;
  //message service
  @wire(MessageContext)
  messageContext;
  //get qiSummaryId
  @wire(CurrentPageReference)
  getStateParameters(currentPageReference) {
    if (currentPageReference) {
      this.qiSummaryId = currentPageReference.state?.qisid;
    }
  }

  @api
  async fetchDomainInfo() {
    this.setLoading(true);
    this.resetAttributes();
    // assumption: if qisvId is not null, we don't need to retrieve any data to do any of the validation. User can submit directly.
    if (this.qisvId != null) {
      try {
        this.versionResponse = await getVersionInfo({ qisId: this.qiSummaryId });
        this.error = undefined;
        this.versionResponse.forEach(element => {
          if (element.qisvId === this.qisvId) {
            this.isLateSubmission = element.isLate;
          }
        });
      }catch (error) {
        this.error = error;
        this.handleToast("Error", error.body.message, "error", "dismissible");
        this.resetAttributes();
      } finally {
        this.submissionTitle = reSubmitTitle;
        this.isSubmitText = true;
        this.concludingText =
          "This will result in a new version of the QI data submission, with an updated date. This will not impact your National Average but will impact Star Ratings.";
        this.disableButton = false;
      }
    } else {
      await this.fetchDomainData();
    }
    this.setLoading(false);
  }
  //Listen to buttons on the banner and handle the payload
  subscribeToMessageChannel() {
    this.subscription = subscribe(
      this.messageContext,
      BUTTON_CLICKED_CHANNEL,
      (message) => this.handleMessage(message)
    );
  }

  //determine if 'Save' or 'Close' was clicked in qiReportingSummaryBanner
  async handleMessage(message) {
    if (message.buttonClicked === "close") {
      this.nagivateToMainPage();
    }
  }

  async connectedCallback() {
    this.subscribeToMessageChannel();
  }
  async fetchDomainData() {
    try {
      this.domainResponse = await getDomainInfo({ qisId: this.qiSummaryId });
      this.error = undefined;
      if (this.domainResponse !== undefined) {
        this.domainInfo = JSON.parse(this.domainResponse);
        this.isSubmittable = this.domainInfo.isSubmittable;
        this.isAmended = this.domainInfo.isAmended;
        this.isCompleted = this.domainInfo.isCompleted;
        this.isLateSubmission = this.domainInfo.isLateSubmission;
        this.uncompletedDomains = this.domainInfo.uncompletedDomains;

        // setup concludingText
        if (this.isAmended) {
          this.concludingText =
            "This will result in a new version of the QI data submission, with the label 'Submitted - Updated after Due Date'. This may result in a change to your Star Rating and will not impact the National Average Calculations.";
        } else {
          if (this.isLateSubmission) {
            this.concludingText =
              "This will result in a new version of the QI data submission, with the label, 'Late Submission'. Late or non-submission of data is expected to result in a 1 Star Rating.";
          }
        }
        // setup button show/hide
        if (this.isCompleted) {
          this.disableButton = true;
        } else {
          this.disableButton = !this.isSubmittable;
        }
        // setup title
        if (this.isCompleted) {
          this.submissionTitle = submitTitle;
        } else {
          if (this.isAmended) {
            if (this.isSubmittable) {
              this.submissionTitle = updatedTitle;
            } else {
              this.submissionTitle = submitTitle;
            }
          } else {
            if (this.isSubmittable) {
              if (this.isLateSubmission) {
                this.submissionTitle = lateSubmitTitle;
              } else {
                this.submissionTitle = submitTitle;
              }
            } else {
              this.submissionTitle = submitTitle;
            }
          }
        }
        // setup text
        if (this.isCompleted) {
          this.isCompleteText = true;
          this.isSubmitText = false;
          this.isMissingText = false;
        } else {
          if (this.isSubmittable) {
            this.isCompleteText = false;
            this.isSubmitText = true;
            this.isMissingText = false;
          } else {
            this.isCompleteText = false;
            this.isSubmitText = false;
            this.isMissingText = true;
          }
        }
      }
    } catch (error) {
      this.error = error;
      this.handleToast("Error", error.body.message, "error", "dismissible");
      this.resetAttributes();
    }
  }
  handleClick() {
    this.setLoading(true);
    if (this.qisvId != null) {
      submitVersionRecord({
        qisvId: this.qisvId,
        isLate: this.isLateSubmission
      })
        .then((result) => {
          this.submitResponse = JSON.parse(result);
          this.error = undefined;
          if (this.isLateSubmission) {
            this.handleToast(
              "Success!",
              "Your QI program data has been successfully updated after the due date",
              "success",
              "dismissible"
            );
          } else {
            this.handleToast(
              "Success!",
              "Your QI program data has been successfully re-submitted",
              "success",
              "dismissible"
            );
          }
          this.completedAttributes();
          this.nagivateToMainPage();
          //window.location.reload(); // Refresh browser page on success in order to see new version
        })
        .catch((error) => {
          this.error = error;
          this.submitResponse = undefined;
          this.handleToast("Error", error.body.message, "error", "dismissible");
          this.setLoading(false);
        });
    } else {
      submitRecord({ qisId: this.qiSummaryId, isAmended: this.isAmended })
        .then((result) => {
          this.submitResponse = JSON.parse(result);
          this.error = undefined;
          if (this.isAmended) {
            this.handleToast(
              "Success!",
              "Your QI program data has been successfully updated after the due date",
              "success",
              "dismissible"
            );
          } else {
            if (this.isLateSubmission) {
              this.handleToast(
                "Success!",
                "Your QI program data has been successfully submitted after the due date",
                "success",
                "dismissible"
              );
            } else {
              this.handleToast(
                "Success!",
                "Your QI program data has been successfully submitted",
                "success",
                "dismissible"
              );
            }
          }
          this.completedAttributes();
          this.nagivateToMainPage();
          //window.location.reload(); // Refresh browser page on success in order to see new version
        })
        .catch((error) => {
          this.error = error;
          this.submitResponse = undefined;
          this.handleToast("Error", error.body.message, "error", "dismissible");
          this.setLoading(false);
        });
    }
  }

  handleBack() {
    this.fireNavigationEvent(this.questionSectionLength - 1);
  }

  fireNavigationEvent(index) {
    this.dispatchEvent(new CustomEvent("navigation", { detail: index }));
  }

  fireCompletionEvent(status) {
    this.dispatchEvent(new CustomEvent("completion", { detail: status }));
  }

  resetAttributes() {
    this.domainResponse = undefined;
    this.domainInfo = undefined;
    this.disableButton = true;
    this.submissionTitle = submitTitle;
    this.isCompleteText = false;
    this.isSubmitText = false;
    this.isMissingText = false;
  }

  completedAttributes() {
    this.disableButton = true;
    this.submissionTitle = submitTitle;
    this.isCompleteText = true;
    this.isSubmitText = false;
    this.isMissingText = false;
    this.fireCompletionEvent(qidCompleteStatus);
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

  nagivateToMainPage() {
    this[NavigationMixin.Navigate](
      {
        type: "comm__namedPage",
        attributes: {
          name: "Quality_Indicator_Details__c"
        }
      },
      true
    );
  }

  setLoading(isLoading) {
    this.isLoading = isLoading;
  }
}