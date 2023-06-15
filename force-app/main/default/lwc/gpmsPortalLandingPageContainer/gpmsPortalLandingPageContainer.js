import { LightningElement, api } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import styles from '@salesforce/resourceUrl/gpms_global_styles';
import getUserPermission from '@salesforce/apex/GPMSUserInfoController.getUserPermission';

export default class GpmsPortalLandingPageContainer extends LightningElement {

    @api tileAboutOrg = false;
    @api tileAboutOrgShort = false;
    @api tileFinancialReporting = false;
    @api tileLookingForSomething = false;
    @api tileQI = false;
    @api tileQIShort = false;
    @api tileStarRatings = false;
    @api tileWhatYouProvide = false;
    @api tileWhatYouProvideShort = false;
    @api tileBenchmarker = false;
    @api toggleTileAboutOrg;
    @api toggleTileFinancialReporting;
    @api toggleTileQI;
    @api toggleTileStarRatings;
    @api toggleTileWhatYouProvide;
    systemErrorTitle = 'System Error';

    connectedCallback() {
        loadStyle(this, styles + '/variables.css');
        this.fetchData();
    }

    // About your organisation tile content
    get aboutYourOrganisation() {

        if (!this.tileAboutOrgShort) {
            return {
                heading: "About your organisation",
                listItems: [
                    "View and manage org details such as contact info and third party orgs",
                    "Initiate notifications of material changes for key personnel, financial status and other information"
                ]
            };
        } else {
            return {
                heading: "About your organisation",
                listItems: [
                    "View and manage org details such as contact info and third party orgs"
                ]
            };
        }
    }

    // What you provide tile content
    get careTypes() {
        if (!this.tileWhatYouProvideShort) {
            return {
                heading: "What you provide",
                listItems: [
                    "Care types you're approved to provide",
                    "Apply to provide additional care types",
                    "Manage your applications"
                ]
            };
        } else {
            return {
                heading: "What you provide",
                listItems: [
                    "Care types you're approved to provide"
                ]
            };
        }
    }

    // Financial reporting tile content
    get financialReporting() {
        return {
            heading: "Financial reporting",
            listItems: [
                "Manage, view and complete quarterly financial reports",
                "View due dates and supporting materials to help you with your reporting"
            ]
        };
    }

    // Star ratings tile content
    get organisationRating() {
        return {
            heading: "Star Ratings",
            listItems: [
                "View new and current ratings",
                "View historic ratings",
                "Understand how Star Ratings are calculated"
            ]
        };
    }

    // Looking for something else tile content
    get somethingElse() {
        return {
            heading: "Looking for something else?",
            introText: "Sign in to My Aged Care service provider portal",
            listItems: [
                "Referrals",
                "Clients",
                "Outlets",
                "Staff",
                "Incidents",
                "Forms & Reports"
            ]
        };
    }

    // QI tile content
    get qualityIndicator() {

        if (!this.tileQIShort) {
            return {
                heading: "Quality Indicators",
                listItems: [
                    "Set up your QI targets",
                    "Enter and submit your QI data",
                    "Access your QI reports"
                ]
            };
        } else {
            return {
                heading: "Quality Indicators",
                listItems: [
                    "Upload and submit your QI data"
                ]
            };
        }
    }

    fetchData() {
        getUserPermission().then(response => {
            if (response.success) {

                if ((response.isSROrg || response.isSRService) && this.toggleTileStarRatings) {
                    this.tileStarRatings = true;
                }
                if ((response.isQFREntry || response.isQFRSubmission) && this.toggleTileFinancialReporting) {
                    this.tileFinancialReporting = true;
                }
                if (((response.isQIOrg || response.isQIService) && !response.isQIBenchmark) && this.toggleTileQI) {
                    this.tileQI = true;
                }
                if (response.isQIBenchmarker && !response.isQIOrg && !response.isQIService) {
                    this.tileBenchmarker = true;
                    this.tileQIShort = true;
                }
                this.tileLookingForSomething = true;

            } else {
                this.handleToast(this.systemErrorTitle, response.error ? response.error : 'Failure fetching the data. Please reload the page to try again.');
            }
        }).catch(_error => {
            this.handleToast(this.systemErrorTitle, 'Unable to fetch data.');
        });
    }

    handleToast(title, variant, message, mode) {
        const toastEvent = new ShowToastEvent({
            title: title,
            variant: variant ? variant : 'error',
            message: message,
            mode: mode ? mode : 'dismissible'
        });

        this.dispatchEvent(toastEvent);
    }
}
