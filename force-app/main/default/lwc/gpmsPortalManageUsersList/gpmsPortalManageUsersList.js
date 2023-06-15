import { LightningElement, api } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import styles from '@salesforce/resourceUrl/gpms_global_styles';

export default class GpmsPortalManageUsersList extends LightningElement {

    @api contactsList;

    connectedCallback() {
        loadStyle(this, styles + '/variables.css');
        loadStyle(this, styles + '/forms.css');
    }

    get hasContacts() {
        const contactsList = this.contactsList !== undefined ? this.contactsList : '[]';

        return contactsList.length > 0 ? true : false;
    }

    get contactsListFormatted() {
        const contactsList = this.hasContacts ? JSON.parse(JSON.stringify(this.contactsList)) : [];
        const regex = /;/g;

        if (contactsList.length > 0) {
            contactsList.forEach(contact => {
                contact.roles = contact.hasOwnProperty('roles') ? contact.roles.replace(regex, ', ') : '';
            })
            return contactsList;
        } else {
            return this.contactsList;
        };
    }

    handleManageUser(event) {
        this.handleLoading(true);

        this.dispatchEvent(new CustomEvent('manageclick', {
            detail: {
                acrid: event.srcElement.dataset.acrid,
                ftls: event.srcElement.dataset.ftls
            }
        }));
    }

    handleLoading(isLoading) {
        this.dispatchEvent(new CustomEvent('loading', {
            detail: isLoading
        }));
    }
    
}