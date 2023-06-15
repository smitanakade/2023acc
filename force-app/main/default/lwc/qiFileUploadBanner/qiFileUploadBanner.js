import { LightningElement , wire,api} from 'lwc';
import { getFieldValue, getRecord } from 'lightning/uiRecordApi';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import userId from '@salesforce/user/Id';
import USER_CONTACT_ID_FIELD from '@salesforce/schema/User.ContactId';
import getOrgName from '@salesforce/apex/QiFileUploadController.getOrgName';
import { showErrorToast } from 'c/qiUtils';

export default class QiFileUploadBanner extends NavigationMixin(LightningElement) {
    prvPage;
    @api fromParent;
    @api titleName = 'Quality Indicator File Upload';
    orgName = 'Loading';

    @wire(getRecord, { recordId: userId, fields: [ USER_CONTACT_ID_FIELD ] })
    userRecord({ error, data }) {
        if (error) {
            console.error(error);
            showErrorToast(this, error.body.message);
        } else if (data) {
            const userContactId = getFieldValue(data, USER_CONTACT_ID_FIELD);
            this.fetchOrgName(userContactId);
        }
    }
    
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.prvPage = currentPageReference.state?.prvPage;
        }
    }

    /**
     * Navigate to a page
     */
    handleBack() {
        if (this.prvPage) {
            this.navigateToPage(this.prvPage, null);
        } else {
            window.history.back();
        }
    }

    /**
     * Navigate to a specific community page and send QISummary Id.
     * @param {*} pageName - Page to navigate to
     */
    navigateToPage(pageName, currentPage) {
        if (pageName) {
            this[NavigationMixin.Navigate](
                {
                    type: 'comm__namedPage',
                    attributes: {
                        name: pageName
                    },
                    state: {
                        prvPage: currentPage
                    }
                },
                true
            );
        }
    }

    async fetchOrgName(contactId) {
        try {
            this.orgName = await getOrgName({ contactId });
        } catch (error) {
            console.error(error);
            showErrorToast(this, error.body.message);
        }
    }
}