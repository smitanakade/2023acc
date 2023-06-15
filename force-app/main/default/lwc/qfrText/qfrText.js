import { api, LightningElement } from "lwc";
import { OmniscriptBaseMixin } from "omnistudio/omniscriptBaseMixin";

export default class QfrText extends OmniscriptBaseMixin(LightningElement) {
  @api value;

  get getValue() {
    return this.value ? this.value.replace(/(?:\r\n|\r|\n)/g, "<br>") : null;
  }
}