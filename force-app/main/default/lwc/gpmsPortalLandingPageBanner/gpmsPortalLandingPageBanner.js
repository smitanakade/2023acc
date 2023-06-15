import { LightningElement, api, track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import styles from '@salesforce/resourceUrl/gpms_global_styles';
import  getUserInfo from '@salesforce/apex/GPMSUserInfoController.getUserInfo';

export default class GpmsPortalLandingPageBanner extends LightningElement {

    loaded = false;
    @api greeting = 'Hi';
    @track userAccountName;
    @track userFullName;

    connectedCallback() {
        loadStyle(this, styles + '/variables.css');

        getUserInfo({})
            .then(response => {
                if (response.success) {
                    this.userFullName = response.fullName;
                    this.userAccountName = response.accountName;
                    this.loaded = true;
                } else {
                    const event = new ShowToastEvent({
                        title: 'Error',
                        variant: 'error',
                        message: 'There was an error retrieving your details. Please reload the page and try again.',
                    });
                    this.dispatchEvent(event);
                }
            })
            .catch(() => {
                const event = new ShowToastEvent({
                    title: 'Error',
                    variant: 'error',
                    message: 'There was a connection problem while retrieving your details.',
                });
                this.dispatchEvent(event);
            });
    }

}