import { LightningElement } from 'lwc';
import { OmniscriptBaseMixin } from "omnistudio/omniscriptBaseMixin";
import { NavigationMixin } from 'lightning/navigation';

export default class TooltipUserGuideLink extends OmniscriptBaseMixin(NavigationMixin(LightningElement)) {

    handleClick() {
        // Navigate to Guides and FAQs page in the community site
        this[NavigationMixin.GenerateUrl]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Guides_and_FAQs__c'
            },
        }).then(url => { window.open(url, "_blank") });
    }

}