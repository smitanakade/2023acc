import { api, LightningElement } from "lwc";
import { OmniscriptBaseMixin } from "omnistudio/omniscriptBaseMixin";
import { OmniscriptActionCommonUtil } from "omnistudio/omniscriptActionUtils";

export default class QfrNotification extends OmniscriptBaseMixin(
  LightningElement
) {
  @api
  value = `Quis aliqua qui sint ut duis elit. Adipisicing qui laborum non excepteur ipsum excepteur incididunt anim ipsum aliqua ea velit dolor minim. Cillum voluptate sunt officia dolore minim duis fugiat nulla esse ullamco aliqua incididunt.  `;
  @api title = "Title goes here";
  @api handleClose;

  @api isCollapsible = false;
  @api isHtml = false;
  @api isCollapsed = false;
  @api className;

  isOpen;

  connectedCallback() {
    this._actionUtilClass = new OmniscriptActionCommonUtil();
    if (!this.isCollapsed) {
      this.isOpen = true;
    }
  }

  /** @type {"error" | "warning" | "success" | "info" | undefined} */
  @api variant;

  get showCollapsible() {
    return this.isCollapsible;
  }
  get isSuccess() {
    return this.variant === "success";
  }
  get isWarning() {
    return this.variant === "warning";
  }
  get isError() {
    return this.variant === "error";
  }
  get isInfo() {
    return this.variant === "info";
  }
  get isDefault() {
    return this.variant === undefined;
  }
  get hasHtml() {
    return this.isHtml;
  }

  get getVariantClass() {
    const moreClasses = this.className || "";
    if (this.isSuccess) {
      return "slds-box qfr-notification is-success " + moreClasses;
    }
    if (this.isWarning) {
      return "slds-box qfr-notification is-warning " + moreClasses;
    }
    if (this.isError) {
      return "slds-box qfr-notification is-error " + moreClasses;
    }
    if (this.isInfo) {
      return "slds-box qfr-notification is-info " + moreClasses;
    }
    return "slds-box qfr-notification " + moreClasses;
  }

  get getCollapseClasses() {
    if (this.isCollapsible && !this.isOpen) {
      return "collapsible-content is-collapsed";
    }
    return "collapsible-content";
  }

  get getToggleArrowColor() {
    if (this.isSuccess) {
      return "#FFFFFF";
    }
    return "#000000";
  }

  toggleCollapse = () => {
    this.isOpen = !this.isOpen;
  };
}
