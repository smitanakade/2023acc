/**
 * @author Yifei Pei
 * @date: 23-03-2023
 * @description: the parent container of reporting period, program manual, and FAQs as a knowledge bar on QI homepage
 */

import { LightningElement, wire } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { getFieldValue, getRecord } from 'lightning/uiRecordApi';
import userId from '@salesforce/user/Id';
import USER_PROFILE_NAME_FIELD from '@salesforce/schema/User.Profile.Name';

const SVG_URL = "/_slds/icons/utility-sprite/svg/symbols.svg";
const rddId = "qiKnowledge1";
const pmId = "qiKnowledge2";
const arrowDown = "#chevrondown";
const arrowUp = "#chevronup";
const activeClass = "slds-is-active";
const showClass = "slds-show";
const hideClass = "slds-hide";

const reportingDashboardPage = "Quality_Indicator_Reporting_Dashboard__c";

export default class qiKnowledgeBar extends NavigationMixin(LightningElement) {
  svgURLrdd = SVG_URL + arrowDown;
  svgURLpm = SVG_URL + arrowDown;

  @wire(getRecord, { recordId: userId, fields: [ USER_PROFILE_NAME_FIELD ] })
  user;

  handleClick(event) {
    const isActive = event.currentTarget.classList.contains(activeClass);
    const selector = '[data-id="' + event.target.dataset.link + '"]';
    const allTabs = this.template.querySelectorAll(".slds-tabs_default__item");
    allTabs.forEach((elm, _idx) => {
      elm.classList.remove(activeClass);
    });
    const tabview = this.template.querySelectorAll(
      ".slds-tabs_default__content"
    );
    tabview.forEach((elm, _idx) => {
      elm.classList.remove(showClass);
      elm.classList.add(hideClass);
    });
    if (!isActive) {
      event.currentTarget.classList.add(activeClass);
      this.template.querySelector(selector).classList.remove(hideClass);
      this.template.querySelector(selector).classList.add(showClass);
    }
    this.iconControl(event.target.dataset.link);
  }

  closeTab(event) {
    const idSelector = '[data-id="' + event.target.dataset.button + '"]';
    const itemSelector = '[data-item="' + event.target.dataset.button + '"]';
    this.template.querySelector(itemSelector).classList.remove(activeClass);
    this.template.querySelector(idSelector).classList.remove(showClass);
    this.template.querySelector(idSelector).classList.add(hideClass);
    this.iconControl(event.target.dataset.button);
  }

  iconControl(id) {
    if (id === rddId) {
      if (this.svgURLrdd.includes(arrowDown)) {
        this.svgURLrdd = SVG_URL + arrowUp;
      } else {
        this.svgURLrdd = SVG_URL + arrowDown;
      }
    }
    if (id === pmId) {
      if (this.svgURLpm.includes(arrowDown)) {
        this.svgURLpm = SVG_URL + arrowUp;
      } else {
        this.svgURLpm = SVG_URL + arrowDown;
      }
    }
  }

  clickNavigate() {
    this.navigateToPage(reportingDashboardPage);
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

  get isNotBenchmarkerUser() {
    if (this.user.data) {
      return 'QI Benchmarker' !== getFieldValue(this.user.data, USER_PROFILE_NAME_FIELD);
    } else {
      return false;
    }
  }
}