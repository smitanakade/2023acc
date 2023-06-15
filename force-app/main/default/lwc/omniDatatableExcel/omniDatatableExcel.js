import { LightningElement, api } from "lwc";
export default class OmniDatatableExcel extends LightningElement {
  @api categories;
  @api cols;
  @api formType;
  @api recordId;

  isClicked = false;
  content;

  async handleClick() {
    this.isClicked = true;
  }

  closeModal() {
    this.isClicked = false;
  }
}
