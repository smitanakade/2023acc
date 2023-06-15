import {api, LightningElement} from 'lwc';
export default class srqiPortalRatingDetailCard extends LightningElement {
    @api cardTitle;
    @api cardSubTitle;
    @api showLastSection = false;
    @api cssClass="slds-m-bottom_xx-large slds-p-bottom_x-large";
    showRatingDetails = false;

    toggleShowRatingDetails() {
        this.showRatingDetails = !this.showRatingDetails;
    }
}