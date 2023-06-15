import { LightningElement, api } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import styles from '@salesforce/resourceUrl/gpms_global_styles';
import roleLabelOrgAdmin from '@salesforce/label/c.OrganisationAdministrator';
import getACOInfo from '@salesforce/apex/ManageUserController.getACOInfo';
import getRelatedContacts from '@salesforce/apex/ManageUserController.getRelatedContacts';
import getPickListValues from '@salesforce/apex/ManageUserController.getPickListValues';
import getHandleInvite from '@salesforce/apex/ManageUserController.getHandleInvite';
import getManageUser from '@salesforce/apex/ManageUserController.getManageUser';
import getManageCompletion from '@salesforce/apex/ManageUserController.getManageCompletion';

export default class GpmsPortalManageUsers extends LightningElement {
    
    @api heading = 'Manage users';
    accountInfo = {};
    accountType = 'ACO';
    asyncEvent;
    contactsList = [];
    isAddMode = false;
    isCurrentUser = false;
    isManageMode = false;
    isRemoveUser = false;
    isUpdateUser = false;
    label = {roleLabelOrgAdmin};
    loaded = false;
    manageDetails = {};
    modalButtonLabel;
    modalButtonToFocus;
    modalContent;
    modalHeading;
    modalHideCancelButton;
    modalHideSaveButton;
    selectedAccountId;
    selectedAcrId;
    selectedContactEmail;
    selectedContactFirstName;
    selectedContactLastName;
    selectedSalutation;
    subHeading;
    systemErrorMessage = 'Please reload the page and try again or contact us for further assistance.';
    systemErrorTitle = 'System Error';
    userFullDetails = {};

    connectedCallback() {
        loadStyle(this, styles + '/variables.css');
        loadStyle(this, styles + '/forms.css');

        this.fetchData();
    }

    fetchData() {
        this.handleTitle();

        getACOInfo().then(response => {
            if (response.success) {
                this.accountInfo = response;
                this.contactsList = response.relatedContacts;
                this.selectedAccountId = response.accountId;
                this.loaded = true;
            } else {
                this.handleToast(this.systemErrorTitle, 'error', response.error ? response.error : 'Failure retrieving the details. Please reload the page to try again.');
            }
        }).catch(_error => {
            this.handleToast(this.systemErrorTitle, 'error', this.systemErrorMessage);
        });
    }

    handleNavClick(event) {
        const accountId = event ? event.detail.accountId : this.selectedAccountId;

        this.accountType = event ? event.detail.accountType : this.accountType;
        this.selectedAccountId = accountId;

        getRelatedContacts({
            accountId
        }).then(response => {
            if (response.success) {
                this.contactsList = response.relatedContacts;
                this.handleCancelCTA();
                this.loaded = true;
            } else {
                this.handleToast(this.systemErrorTitle, 'error', response.error ? response.error : 'Failure retrieving the list of users. Please try again.');
            }
        }).catch(_error => {
            this.handleToast(this.systemErrorTitle, 'error', this.systemErrorMessage);
        });
    }

    handleNextAddCTA(event) {
        const userDetailsFromChild = event.detail;
        const asyncDelay = 3000;
        const accountId = this.selectedAccountId;
        const emailId = userDetailsFromChild.userDetails.email;
        const roles = userDetailsFromChild.hasOwnProperty('roles') ? userDetailsFromChild.roles : [];
        const providerRoles = userDetailsFromChild.hasOwnProperty('providerRoles') ? userDetailsFromChild.providerRoles : [];
        const serviceRoles = userDetailsFromChild.hasOwnProperty('serviceRoles') ? userDetailsFromChild.serviceRoles : [];
        const hasRoles = roles.length > 0 || providerRoles.length > 0 || serviceRoles.length > 0;
        const fullDetailsToSend = {
            accountId: accountId,
            accountRecordType: this.userFullDetails.accountRecordType,
            acrExists: this.userFullDetails.acrExists,
            contactExists: this.userFullDetails.contactExists,
            isManage: this.isManageMode,
            isRoleBlank: this.userFullDetails.isRoleBlank,
            providerRoles: userDetailsFromChild.providerRoles,
            relatedServices: userDetailsFromChild.relatedServices,
            roles: userDetailsFromChild.roles,
            serviceRoles: userDetailsFromChild.serviceRoles,
            userDetails: userDetailsFromChild.userDetails,
            userExists: this.userFullDetails.userExists
        };

        if (!hasRoles) {
            getPickListValues({
                emailId,
                accountId
            }).then(response => {
                if (response.success) {
                    this.userFullDetails = response;
                    this.loaded = true;
                } else {
                    this.handleToast(this.systemErrorTitle, 'error', response.error ? response.error : 'Failure retrieving the details. Please try again.');
                }
            }).catch(_error => {
                this.handleToast(this.systemErrorTitle, 'error', this.systemErrorMessage);
            });
        } else {
            getHandleInvite({
                jsonInput: JSON.stringify(fullDetailsToSend)
            })
            .then(response => {
                if (response.success) {
                    if (this.userFullDetails.contactExists) {
                        this.handleToast('Success!', 'success', `An invitation was sent to ${emailId}.`, 'sticky');
                    } else {
                        this.handleToast('Success!', 'success', `The new contact was created and an invitation was sent to ${emailId}. It can take up to 5 minutes for the new user to appear in the list below.`, 'sticky');
                    }
                    this.selectedAcrId = '';
                    this.contactsList = [];
                    this.userFullDetails = {};
                    this.manageDetails = {};
                    this.handleCancelCTA();
                } else {
                    this.handleToast(this.systemErrorTitle, 'error', response.error ? response.error : 'Failure inviting this user. Please try again.');
                }

                this.isEmailVerified = true;
            }).catch(_error => {
                this.handleToast(this.systemErrorTitle, 'error', this.systemErrorMessage);
            }).finally(() => {
                this.asyncEvent = setTimeout(() => {
                    this.handleNavClick();
                }, asyncDelay);
            });
        }
    }

    handleManageButton(event) {
        const acrId = event.detail.acrid;
        const ftls = event.detail.ftls === 'true';

        this.selectedAcrId = acrId;
        
        getManageUser({
            acrId
        }).then(response => {
            if (response.success) {
                this.isManageMode = true;
                this.userFullDetails = response;
                this.selectedContactEmail = this.userFullDetails.userDetails.email;
                this.selectedContactFirstName = this.userFullDetails.userDetails.firstName;
                this.selectedContactLastName = this.userFullDetails.userDetails.lastName;
                this.selectedSalutation = this.userFullDetails.userDetails.salutation;
                this.handleAddUserMode();
                this.manageDetails.ftls = ftls;
                this.manageDetails.isManageMode = this.isManageMode;
                this.manageDetails.isSingleOrgAdmin = this.isSingleOrgAdmin;
                this.loaded = true;
            } else {
                this.handleToast(this.systemErrorTitle, 'error', response.error ? response.error : "Failure loading this user's details. Please try again.");
            }
        }).catch(_error => {
            this.handleToast(this.systemErrorTitle, 'error', this.systemErrorMessage);
        });
    }

    handleManageUser(event) {
        this.loaded = false;
        const userDetailsFromChild = event ? event.detail : [];
        const logoutUrl = `${window.location.origin}/secur/logout.jsp`;
        this.isUpdateUser = !this.isRemoveUser ? true : false;

        const fullDetailsToSend = {
            acrId: this.selectedAcrId,
            isRemoveUser: this.isRemoveUser,
            isUpdateUser: this.isUpdateUser,
            providerRoles: userDetailsFromChild.hasOwnProperty('providerRoles') ? userDetailsFromChild.providerRoles : [],
            relatedServices: userDetailsFromChild.hasOwnProperty('relatedServices') ? userDetailsFromChild.relatedServices : [],
            roles: userDetailsFromChild.hasOwnProperty('roles') ? userDetailsFromChild.roles : [],
            serviceRoles: userDetailsFromChild.hasOwnProperty('serviceRoles') ? userDetailsFromChild.serviceRoles : []
        };
        
        getManageCompletion({
            jsonInput: JSON.stringify(fullDetailsToSend)
        }).then(response => {
            if (response.success) {
                if (this.isRemoveUser && !this.isSingleOrgAdmin && this.isCurrentUser) {
                    window.location = logoutUrl;
                } else {
                    this.selectedAcrId = '';
                    this.contactsList = [];
                    this.isRemoveUser = false;
                    this.userFullDetails = {};
                    this.manageDetails = {};
                    this.handleCancelCTA();
                }
            } else {
                this.handleToast(this.systemErrorTitle, 'error', response.error ? response.error : "Failure managing this user. Please try again.");
            }
        }).catch(_error => {
            this.handleToast(this.systemErrorTitle, 'error', this.systemErrorMessage);
        }).finally(() => {
            this.handleNavClick();
        });
    }

    handleAddUserMode() {
        this.isAddMode = true;
        this.handleTitle();
    }

    handleManageUserMode() {
        this.isManageMode = true;
        this.handleTitle();
    }

    handleCancelCTA() {
        this.userFullDetails = {};
        this.manageDetails = {};
        this.isAddMode = false;
        this.isManageMode = false;
        this.handleTitle();
    }

    handleTitle() {
        const firstName = this.selectedContactFirstName ? this.selectedContactFirstName.trim() : this.selectedContactFirstName;
        const lastName = this.selectedContactLastName ? this.selectedContactLastName.trim() : this.selectedContactLastName;
        const salutation = this.selectedSalutation ? this.selectedSalutation : '';

        if (this.isAddMode && !this.isManageMode) {
            this.subHeading = `Add new ${this.accountType} user`;
        } else if (this.isManageMode) {
            this.subHeading = `Managing: ${salutation} ${firstName} ${lastName}`;
        } else {
            this.subHeading = `Users within this ${this.accountType}`;
        }
    }

    handleLoading(event) {
        this.loaded = !event.detail;
    }

    handleToast(title, variant, message, mode) {
        const toastEvent = new ShowToastEvent({
            title: title,
            variant: variant,
            message: message,
            mode: mode ? mode : 'dismissible'
        });

        this.dispatchEvent(toastEvent);
    }

    handleRemoveCTA(event) {
        this.modalButtonToFocus = event.detail.buttonToFocus;
        this.isRemoveUser = true;
        this.handleModalContent();
        this.handleToggleModal();
    }

    handleModalCancel() {
        this.isRemoveUser = false;
        this.isUpdateUser = false;
        this.modalButtonToFocus.focus();
    }
    
    handleModalAction() {
        if (this.isSingleOrgAdmin) {
            this.isRemoveUser = false;
            this.handleToggleModal();
            return;
        } else {
            this.isUpdateUser = !this.isRemoveUser ? true : false;
            this.handleToggleModal();
            this.handleManageUser();
            
        }
    }

    handleModalContent() {
        const email = this.selectedContactEmail ? this.selectedContactEmail : '';
        const headingRemoveUser = `Remove ${email}?`;
        const headingSingleOrgAdmin = "Action cannot be performed.";
        const headingRemoveOwnAccess = "Remove your own access?";
        const contentRemoveUser = "You are removing this user at this level of your organisation. This action cannot be undone.";
        const contentSingleOrgAdmin = "You are the sole administrator for this organisation. Assign at least one other 'Organisation administrator' role before you can attempt to leave again.";
        const contentRemoveOwnAccess = "You are about to leave and remove your own access to the Government Provider Management System.";

        if (this.isRemoveUser && this.isSingleOrgAdmin) {
            this.modalHeading = headingSingleOrgAdmin;
            this.modalContent = contentSingleOrgAdmin;
            this.modalHideCancelButton = true;
            this.modalButtonLabel = 'Ok';
        } else if (this.isRemoveUser && !this.isSingleOrgAdmin && this.accountType === 'ACO' && this.isCurrentUser) {
            this.modalHeading = headingRemoveOwnAccess;
            this.modalContent = contentRemoveOwnAccess;
            this.modalHideCancelButton = false;
            this.modalButtonLabel = 'Remove';
        } else {
            this.modalHeading = headingRemoveUser;
            this.modalContent = contentRemoveUser;
            this.modalHideCancelButton = false;
            this.modalButtonLabel = 'Remove';
        }
    }

    modalSaveHandler = (event) => {
        event.stopPropagation();
    };


    handleToggleModal(event) {
        if (event) {
            event.preventDefault();
            event.stopPropagation();
        }
        this.template.querySelector('c-gpms-modal').toggleModal();
    }

    get isSingleOrgAdmin() {
        this.isCurrentUser = false;
        const contactsList = JSON.parse(JSON.stringify(this.contactsList));
        let oaCounter = 0;
        let orgAdminAcrId;

        contactsList.forEach(contact => {
            if (contact.hasOwnProperty('roles') && contact.roles.toLowerCase().includes(this.label.roleLabelOrgAdmin.toLowerCase())) {
                orgAdminAcrId = contact.acrId;
                if (this.selectedAcrId === orgAdminAcrId && contact.isCurrentUser) {
                    this.isCurrentUser = true;
                }
                oaCounter++;
            }
        });

        return oaCounter === 1 && this.selectedAcrId === orgAdminAcrId ? true : false;
    }
}