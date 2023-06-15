import { LightningElement } from 'lwc';
import { NavigationMixin } from "lightning/navigation";

export default class QfrSuccessfullySubmittedButton extends NavigationMixin(LightningElement) {
    navigateToDownload() {
        const recordId = this.getUrlParam(window.location.href, "c__caseId");
        this[NavigationMixin.Navigate]({
          type: 'comm__namedPage',
          attributes: {
            name: 'QFR_Report_Download__c'
          },
          state: {
            caseId: recordId,
          }
        });
      }

    getUrlParam(url, key) {
        return new URL(url).searchParams.get(key);
    }
}