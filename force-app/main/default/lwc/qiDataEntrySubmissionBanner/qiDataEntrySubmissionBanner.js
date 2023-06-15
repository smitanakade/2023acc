import { api, LightningElement, wire } from "lwc";
import { CurrentPageReference, NavigationMixin } from "lightning/navigation";
import { getFieldValue, getRecord } from "lightning/uiRecordApi";
import USER_PROFILE_NAME_FIELD from "@salesforce/schema/User.Profile.Name";
import BANNER_ICONS from "@salesforce/resourceUrl/QISRIconsApril2023";
import userId from "@salesforce/user/Id";
import createFileStagingRecord from "@salesforce/apex/QIBulkUploadUtility.createFileStagingRecord";

export default class QiEntrySubmissionBanner extends NavigationMixin(
  LightningElement
) {
  @api title = "Quality Indicator Data Entry & Submission";
  @api hideViewHistoryButton = false;

  prvPageId;
  prvPage;

  //icons
  view_history = BANNER_ICONS + "/view_history.svg";
  upload_file = BANNER_ICONS + "/upload_file.svg";

  @wire(getRecord, { recordId: userId, fields: [USER_PROFILE_NAME_FIELD] })
  user;

  @wire(CurrentPageReference)
  getStateParameters(currentPageReference) {
    if (currentPageReference) {
      this.prvPageId = currentPageReference.state?.pageId;
      this.prvPage = currentPageReference.state?.prvPage;
    }
  }

  /**
   * Navigate to previous page
   */
  handleBack() {
    this.navigateToPage();
  }

  /**
   * Navigate to a page
   */
  handleViewHistory() {
    this.navigateToPage(
      "QI_File_Upload_History__c",
      "Quality_Indicator_Details__c"
    );
  }

  /**
   * Navigate to a page
   */
  async handleUpload() {
    const fileStagingWrapper = {
      userIdAura: userId
    };
    const record = await createFileStagingRecord({ fileStagingWrapper });
    if (this.isBenchmarkerUser) {
      this.navigateToPage("QI_File_Upload__c", "QI_File_Upload_History__c", {
        fileStagingId: record.Id
      });
    } else {
      this.navigateToPage("QI_File_Upload__c", "Quality_Indicator_Details__c", {
        fileStagingId: record.Id
      });
    }
  }

  /**
   * Navigate to a specific community page and send QISummary Id.
   * @param {*} pageName - Page to navigate to
   * @param {*} currentPage - current community page
   * @param {*} additionalState - Optional state properties object
   */
  navigateToPage(pageName, currentPage, additionalState) {
    if (pageName) {
      this[NavigationMixin.Navigate](
        {
          type: "comm__namedPage",
          attributes: {
            name: pageName
          },
          state: {
            prvPage: currentPage,
            ...additionalState
          }
        },
        true
      );
    } else {
      window.history.back();
    }
  }

  get isBenchmarkerUser() {
    if (this.user.data) {
      return (
        "QI Benchmarker" ===
        getFieldValue(this.user.data, USER_PROFILE_NAME_FIELD)
      );
    } else {
      return false;
    }
  }
}