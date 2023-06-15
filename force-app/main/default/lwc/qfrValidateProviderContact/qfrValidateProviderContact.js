import { LightningElement, api } from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import { OmniscriptBaseMixin } from "omnistudio/omniscriptBaseMixin";
export default class QfrValidateProviderContact extends OmniscriptBaseMixin(NavigationMixin(LightningElement)) {
@api
    nextStepAction;

    async connectedCallback() {
        if (this.nextStepAction === "True") {
            this.navigateToNextStep();
        } else {
            //do nothing;
        }
    }

    navigateToNextStep() {
        this.omniNextStep();
    }
}