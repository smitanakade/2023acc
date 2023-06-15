import { LightningElement } from "lwc";

export default class QiRepDash extends LightningElement {
  showEverything = true;

  handleClose() {
    this.showEverything = false;
  }
}