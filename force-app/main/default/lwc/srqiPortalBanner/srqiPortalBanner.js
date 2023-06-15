import {api, LightningElement, wire} from 'lwc';
import {CurrentPageReference, NavigationMixin} from "lightning/navigation";

export default class srqiPortalBanner extends NavigationMixin(LightningElement) {
    @api bannerTitle = 'Star Ratings';
    currentPageReference = null;
    sourcePageType;
    sourcePageName;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference && Object.keys(currentPageReference.state).length > 0) {
            this.sourcePageType = currentPageReference.state.sourcePageType;
            this.sourcePageName = currentPageReference.state.sourcePageName;
        }
    }

    back() {
        if (this.sourcePageType && this.sourcePageName) {
            this[NavigationMixin.Navigate]({
                    type: this.sourcePageType,
                    attributes: {
                        name: this.sourcePageName
                    }
                },
                true
            );
        } else {
            history.back();
        }
    }
}