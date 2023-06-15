import { LightningElement, api } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import styles from '@salesforce/resourceUrl/gpms_global_styles';

export default class GpmsPortalManageUsersNavigation extends LightningElement {
    @api accountInfo;

    connectedCallback() {
        loadStyle(this, styles + '/variables.css');
        loadStyle(this, styles + '/forms.css');
    }

    handleNavClick(event) {
        const activeButtonClasslist = this.template.querySelector('.active').classList;
        
        activeButtonClasslist.remove('active');
        event.target.classList.add('active');

        this.dispatchEvent(new CustomEvent('navclick', {
            detail: {
                accountId: event.srcElement.dataset.accountid,
                accountType: event.srcElement.dataset.accounttype
            }
        }));

        this.handleLoading(true);
    }

    handleLoading(isLoading) {
        this.dispatchEvent(new CustomEvent('loading', {
            detail: isLoading
        }));
    }
}
