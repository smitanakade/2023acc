import { LightningElement, api, track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import styles from '@salesforce/resourceUrl/gpms_global_styles';
import gpms_images from '@salesforce/resourceUrl/gpms_images';
import validationPatternName from '@salesforce/label/c.validationPatternUserNames';
export default class GpmsPortalManageUsersAddUser extends LightningElement {

    @api accountId;
    @api accountType;
    @api dateOfBirth = '';
    @api email = '';
    @api firstName = '';
    @api lastName = '';
    @api manageDetailsParent;
    @api salutation = '';
    @api userDetailsParent;
    @track serviceRolesAndRelatedServices = [];
    acoRolesValue = [];
    allServicesSelected = false;
    dataSet = [];
    hasAcoRoles = false;
    hasRendered = false;
    isCheckAll = false;
    isServiceRole = false;
    isValidFields = false;
    label = {validationPatternName};
    rolesValue = [];
    servicesValue = [];
    showServiceValidationError = false;
    userDetails = {};
    userInfo = {};
    @track relatedServicesObject = {};
    delay = 300;

    iconinfo = gpms_images + '/icon-info.svg';

    connectedCallback() {
        loadStyle(this, styles + '/variables.css');
        loadStyle(this, styles + '/forms.css');

        this.serviceRolesArray();
        this.rolesValues();

    }

    renderedCallback() {
        if (this.hasRendered) {
            return;
        }
        this.rolesValues();
        this.hasRendered = true;
    }

    serviceRolesArray() {
        if (this.userDetailsParent !== undefined && this.userDetailsParent.hasOwnProperty('serviceRoles') && !this.hasRendered) {
            this.dataSet = JSON.parse(JSON.stringify(this.userDetailsParent.serviceRoles));
        }
        return this.dataSet;
    }

    formattedServiceRolesAndRelatedServices() {
        this.relatedServicesObject = {};
        this.serviceRolesAndRelatedServices.forEach(role => {
            if (role.selectedServices.length > 0) {
                this.relatedServicesObject[role.value] = role.selectedServices;
            }
        });
    }

    get acrExists() {
        if (this.userDetailsParent !== undefined && this.userDetailsParent.hasOwnProperty('acrExists')) {
            return this.userDetailsParent.acrExists;
        }
        return false;
    }

    get contactId() {
        if (this.userDetailsParent !== undefined && this.userDetailsParent.hasOwnProperty('userDetails')) {
            this.userDetails.contactId = this.userDetailsParent.userDetails.hasOwnProperty('contactId') ? this.userDetailsParent.userDetails.contactId : '';
        }
        return this.userDetails.contactId;
    }

    get isManageMode() {
        return (this.manageDetailsParent !== undefined && this.manageDetailsParent.hasOwnProperty('isManageMode')) ? this.manageDetailsParent.isManageMode : false;
    }

    get isLoggedIn() {
        return (this.manageDetailsParent !== undefined && this.manageDetailsParent.hasOwnProperty('ftls')) ? this.manageDetailsParent.ftls : false;
    }

    get contactExists() {
        if (this.userDetailsParent !== undefined && this.userDetailsParent.hasOwnProperty('contactExists')) {
            return this.userDetailsParent.contactExists;
        }
        return false;
    }

    get isEmailVerified() {
        const isCheckDone = this.userDetailsParent !== undefined ? this.userDetailsParent.hasOwnProperty('contactExists') : false;
        return isCheckDone ? true : false;
    }

    get showInfoBox() {
        return (this.acrExists || !this.contactExists) && !this.isManageMode ? true : false;
    }

    get showRoles() {
        return this.isEmailVerified && (this.isManageMode || !this.acrExists) ? true : false;
    }

    get isACO() {
        return this.accountType === 'ACO' ? true : false;
    }

    get isDisabled() {
        return this.isEmailVerified && !this.acrExists ? true : false;
    }

    get ctaLabel() {
        return this.isEmailVerified && !this.acrExists ? 'Add User' : 'Next';
    }

    get ctaTitle() {
        return this.isEmailVerified && !this.acrExists ? 'Add this user to your organisation' : 'Verify email and continue';
    }

    get salutationOptions() {
        if (this.userDetailsParent !== undefined && this.userDetailsParent.hasOwnProperty('salutationOptions')) {
            return this.userDetailsParent.salutationOptions;
        } else {
            return [];
        }
    }

    get roleOptions() {
        if (this.userDetailsParent !== undefined) {
            const roles = this.userDetailsParent.hasOwnProperty('roles') ? this.userDetailsParent.roles : [];
            const providerRoles = this.userDetailsParent.hasOwnProperty('providerRoles') ? this.userDetailsParent.providerRoles : [];
            const serviceRoles = this.userDetailsParent.hasOwnProperty('serviceRoles') ? this.userDetailsParent.serviceRoles : [];

            if (!this.isACO) {
                return providerRoles.concat(serviceRoles);
            } else {
                return roles;
            }
        } else {
            return [];
        }
    }

    get dateOfBirthMax() {
        const minAge = 18;
        const date = new Date();

        date.setFullYear(date.getFullYear() - minAge);
        return date.toISOString().split('T')[0];
    }

    get rolesRequiredMessage() {
        return `Please select at least one role${this.isManageMode ? " or click 'Remove User' below" : ""}.`;
    }

    handleSelectedServiceRoles(serviceRoleNames){
        this.serviceRolesAndRelatedServices = [];
        if (serviceRoleNames.length > 0) {
            serviceRoleNames.forEach(element => {
                this.serviceRolesAndRelatedServices.push(this.dataSet.find(role => role.value === element));
            });

            this.serviceRolesAndRelatedServices.forEach(serviceRole => {
                const selectedServices = serviceRole.relatedServices.filter(service => service.isSelected).map(role => role.value);
                serviceRole.selectedServices = selectedServices.length > 0 ? selectedServices : [];
            });
        }
    }

    setSelectedServiceRoles(serviceRoleNames) {
        if (this.dataSet.length > 0 && serviceRoleNames.length > 0) {
            serviceRoleNames.forEach(element => {
                const serviceRole = this.dataSet.find(role => role.value === element);
                serviceRole.isSelected = true;
            });
        }
    }

    rolesValues() {
        const selectedRoles = this.userDetailsParent.hasOwnProperty('roles') && this.userDetailsParent.roles.length > 0 ? this.userDetailsParent.roles.filter(role => role.isSelected).map(role => role.value) : [];
        const selectedProviderRoles = this.userDetailsParent.hasOwnProperty('providerRoles') ? this.userDetailsParent.providerRoles.filter(role => role.isSelected).map(role => role.value) : [];
        const selectedServiceRoles = this.userDetailsParent.hasOwnProperty('serviceRoles') ? this.userDetailsParent.serviceRoles.filter(role => role.isSelected).map(role => role.value) : [];

        this.rolesValue = selectedRoles.concat(selectedProviderRoles).concat(selectedServiceRoles);
        this.isServiceRole = selectedServiceRoles.length > 0 ? true : false;

        if (!this.isACO) {
            this.acoRolesValue = this.userDetailsParent.hasOwnProperty('roles') && this.userDetailsParent.roles.length > 0 ? this.userDetailsParent.roles.filter(role => role.isSelected).map(role => role.label) : [];
            this.hasAcoRoles = this.acoRolesValue.length > 0 ? true : false;
        }

        this.userInfo.roles = selectedRoles;
        this.userInfo.providerRoles = selectedProviderRoles;
        this.userInfo.serviceRoles = selectedServiceRoles;

        this.handleSelectedServiceRoles(this.userInfo.serviceRoles);
        this.handleSelectAllOnLoad();
        this.formattedServiceRolesAndRelatedServices();
        this.userInfo.relatedServices = this.relatedServicesObject;
    }

    handleRolesChange(event) {
        const selectedRoles = event.detail.value;
        const acoRoles = this.userDetailsParent.hasOwnProperty('roles') && this.userDetailsParent.roles.length > 0 ? this.userDetailsParent.roles.filter(role => role.isSelected).map(role => role.value) : [];
        const providerRoles = this.userDetailsParent.hasOwnProperty('providerRoles') ? this.userDetailsParent.providerRoles.map(values => values.value) : [];
        const serviceRoles = this.userDetailsParent.hasOwnProperty('serviceRoles') ? this.userDetailsParent.serviceRoles.map(values => values.value) : [];
        const hasProviderRoles = selectedRoles.some(role => providerRoles.includes(role));
        const hasServiceRole = selectedRoles.some(role => serviceRoles.includes(role));

        this.isServiceRole = hasServiceRole ? true : false;

        if (!this.isACO) {
            this.rolesValue = selectedRoles;
            this.userInfo.roles = acoRoles;
            this.userInfo.providerRoles = hasProviderRoles ? selectedRoles.filter(role => providerRoles.includes(role)) : [];
            this.userInfo.serviceRoles = hasServiceRole ? selectedRoles.filter(role => serviceRoles.includes(role)) : [];
            if (this.dataSet.length == 0){
                this.dataSet = JSON.parse(JSON.stringify(this.userDetailsParent.serviceRoles));
            }
            this.setSelectedServiceRoles(this.userInfo.serviceRoles);
            this.handleSelectedServiceRoles(this.userInfo.serviceRoles);
            this.formattedServiceRolesAndRelatedServices();
            setTimeout(() => {
                this.handleSelectAllOnLoad();}, this.delay);
            this.userInfo.relatedServices = this.relatedServicesObject;
        } else {
            this.rolesValue = selectedRoles;
            this.userInfo.roles = selectedRoles;
            this.userInfo.providerRoles = [];
            this.userInfo.serviceRoles = [];
            this.userInfo.relatedServices = {};
            this.servicesValue = [];
        }
        this.handleValidation();
        this.userInfo.userDetails.contactId = this.contactId !== undefined ? this.contactId : '';
        this.userInfo.userDetails.firstName = this.userDetails.firstName !== undefined ? this.userDetails.firstName : this.userDetailsParent.userDetails.firstName !== undefined ? this.userDetailsParent.userDetails.firstName : '';
        this.userInfo.userDetails.lastName = this.userDetails.lastName !== undefined ? this.userDetails.lastName : this.userDetailsParent.userDetails.lastName !== undefined ? this.userDetailsParent.userDetails.lastName : '';
    }

    handleServicesChange(event) {
        this.servicesValue = event ? event.detail.value : this.servicesValue;

        const serviceRole = this.serviceRolesAndRelatedServices.find(role => role.value === event.currentTarget.dataset.id);

        const serviceRolDataSet = this.dataSet.find(role => role.value === event.currentTarget.dataset.id);

        const allServices = serviceRole.relatedServices.map(values => values.value);

        this.servicesValue.forEach(service => {
            let relatedService = serviceRolDataSet.relatedServices.find(relatedService => relatedService.value === service);
            relatedService.isSelected = true;
            let relatedSer = serviceRole.relatedServices.find(relatedService => relatedService.value === service);
            relatedSer.isSelected = true;
        })

        serviceRolDataSet.selectedServices = this.servicesValue;
        serviceRole.selectedServices = this.servicesValue;

        allServices.forEach(element => {
            if(!serviceRolDataSet.selectedServices.includes(element)) {
                let relatedService = serviceRolDataSet.relatedServices.find(relatedService => relatedService.value === element);
                relatedService.isSelected = false;
            }
        })

        const selectAllCheckbox = this.template.querySelector('[data-id="' + serviceRole.value+ '"]');
        if (selectAllCheckbox !== null) {
            selectAllCheckbox.checked = (serviceRole.selectedServices.length === allServices.length) && !selectAllCheckbox.checked ? true : false;
        }

        this.userInfo.serviceRoles = this.serviceRolesAndRelatedServices.map(role => role.value);
        this.formattedServiceRolesAndRelatedServices()
        this.userInfo.relatedServices = this.relatedServicesObject;
        this.handleValidation();
    }

    handleSelectAllOnLoad() {
        if (this.serviceRolesAndRelatedServices.length > 0) {
            this.serviceRolesAndRelatedServices.forEach(role => {
                const selectedRelatedServices = role.relatedServices.filter(role => role.isSelected).map(role => role.value);
                this.servicesValue = selectedRelatedServices;
                const allServices = role.relatedServices.map(role => role.value);
                const selectAllCheckbox = this.template.querySelector('[data-id="' + role.value+ '"]');
                if (selectAllCheckbox !== null) {
                    if (this.servicesValue.length === allServices.length) {
                        selectAllCheckbox.checked = true;
                    } else if (selectAllCheckbox.checked && this.servicesValue.length === allServices.length){
                        selectAllCheckbox.checked = true;
                    } else if (this.servicesValue.length !== allServices.length){
                        selectAllCheckbox.checked = false;
                    }
                }
            })
        }
    }

    handleSelectAll(event) {
        const serviceRole = this.serviceRolesAndRelatedServices.find(role => role.value === event.currentTarget.dataset.id);
        const serviceRoleDataset = this.dataSet.find(role => role.value === event.currentTarget.dataset.id);
        const allServices = serviceRole.relatedServices.map(values => values.value);

        if (allServices.length !== serviceRole.selectedServices.length) {
            serviceRoleDataset.relatedServices.forEach(element => {
                element.isSelected = true;
            });
            serviceRole.selectedServices = allServices;
        } else {
            serviceRoleDataset.relatedServices.forEach(element => {
                element.isSelected = false;
            });
            serviceRole.selectedServices = [];
        }
        this.formattedServiceRolesAndRelatedServices();
        this.userInfo.relatedServices = this.relatedServicesObject;
        setTimeout(() => {
            this.handleValidation();}, this.delay);
    }

    handleChange(event) {
        this.userInfo.userDetails = {};
        const field = event.target.name;

        switch (field) {
            case 'dateOfBirth':
                this.dateOfBirth = event.target.value;
                this.userDetails.birthDate = this.dateOfBirth;
                break;
            case 'email':
                this.email = event.target.value;
                this.userDetails.email = this.email;
                break;
            case 'firstName':
                this.firstName = event.target.value;
                this.userDetails.firstName = this.firstName;
                break;
            case 'lastName':
                this.lastName = event.target.value;
                this.userDetails.lastName = this.lastName;
                break;
            case 'salutation':
                this.salutation = event.detail.value;
                this.userDetails.salutation = this.salutation;
                break;
            default:
                break;
        }
        this.userDetails.contactId = this.contactId !== undefined ? this.contactId : '';
        this.userInfo.userDetails = this.userDetails;
        this.handleValidation();
    }

    handleValidation() {
        const allValid = [...this.template.querySelectorAll('.validate'), ]
            .reduce((validSoFar, formField) => {
                formField.reportValidity();
                return validSoFar && formField.checkValidity();
            }, true);
        if (allValid) {
            this.showServiceValidationError = false;
            return true;
        } else {
            this.showServiceValidationError = true;
            return false;
        }
    }

    handleRemove() {
        this.dispatchEvent(new CustomEvent('removeclick', {
            detail: {
                buttonToFocus: this.template.querySelector('.remove-button')
            }
        }));
    }

    handleCancel() {
        this.dispatchEvent(new CustomEvent('cancelclick'));
    }

    handleCTA(_event) {
        if (this.handleValidation()) {
            this.dispatchEvent(new CustomEvent('ctaclick', {
                detail: this.userInfo
            }));

            this.handleLoading(true);
        }
    }

    handleUpdate(_event) {
        const rolesParent = {
            providerRoles: this.userDetailsParent.hasOwnProperty('providerRoles') ? this.userDetailsParent.providerRoles.filter(role => role.isSelected).map(role => role.value) : [],
            relatedServices: this.userDetailsParent.hasOwnProperty('relatedServices') ? this.userDetailsParent.relatedServices.filter(role => role.isSelected).map(role => role.value) : [],
            roles: this.userDetailsParent.hasOwnProperty('roles') && this.userDetailsParent.roles.length > 0 ? this.userDetailsParent.roles.filter(role => role.isSelected).map(role => role.value) : [],
            serviceRoles: this.userDetailsParent.hasOwnProperty('serviceRoles') ? this.userDetailsParent.serviceRoles.filter(role => role.isSelected).map(role => role.value) : []
        };

        if (this.handleValidation()) {
            this.dispatchEvent(new CustomEvent('saveclick', {
                detail: this.userInfo !== undefined ? this.userInfo : rolesParent
            }));

            this.handleLoading(true);
        }
    }

    handleLoading(isLoading) {
        this.dispatchEvent(new CustomEvent('loading', {
            detail: isLoading
        }));
    }

    resetForm() {
        this.dateOfBirth = '';
        this.email = '';
        this.firstName = '';
        this.lastName = '';
        this.salutation = '';
        this.userInfo = {};
    }
}
