/**
 * @author Yifei Pei
 * @date: 29-03-2023
 * @description: Banner of Quality Indicator Reporting Dashboard, inherent from qiEntrySubmissionBanner
 */

import { LightningElement } from "lwc";
import { NavigationMixin } from "lightning/navigation";

const qualityIndicatorsPage = "Quality_Indicator_Details__c";

export default class qiReportDashBanner extends NavigationMixin(
  LightningElement
) {
  handleBack() {
    this.navigateToPage(qualityIndicatorsPage);
  }
  navigateToPage(pageName) {
    this[NavigationMixin.Navigate](
      {
        type: "comm__namedPage",
        attributes: {
          name: pageName
        }
      },
      true
    );
  }
}