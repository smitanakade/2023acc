import { api, LightningElement, track } from "lwc";

export default class QfrCheckbox extends LightningElement {
  @api additionalInfo;
  @api label;
  @api error;

  get getError() {
    return this.error || "This is required";
  }

  @api get value() {
    return this._value;
  }

  set value(value) {
    this._value = value;
  }

  handleChange() {
    this.dispatchEvent(new CustomEvent("change"));
  }

  @track _disabled = false;
  @track _readOnly = false;
  @track _required = false;
  @track _value = "";
}
