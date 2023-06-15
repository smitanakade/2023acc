import { LightningElement } from 'lwc';
import styles from '@salesforce/resourceUrl/gpms_global_styles';
import gpms_images from '@salesforce/resourceUrl/gpms_images';
import { loadStyle } from 'lightning/platformResourceLoader';

export default class GpmsPortalFooter extends LightningElement {

    logoGOV = gpms_images + '/logo-AUSGOV-inverse.svg';

    connectedCallback() {
        loadStyle(this, styles + '/variables.css');
    }

    get footerLinks() {
        return [{
                heading: "Using this website",
                links: [{
                        label: "Terms of use",
                        url: "https://www.health.gov.au/resources/publications/government-provider-management-system-terms-of-use",
                        target: "_blank"
                    },
                    {
                        label: "Privacy and security",
                        url: "https://www.health.gov.au/using-our-websites/website-privacy-policy/privacy-notice-for-gpms",
                        target: "_blank"
                    },
                    {
                        label: "Copyright",
                        url: "https://www.health.gov.au/resources/publications/government-provider-management-system-terms-of-use",
                        target: "_blank"
                    },
                    {
                        label: "Accessibility",
                        url: "https://www.health.gov.au/using-our-websites/accessibility",
                        target: "_blank"
                    },
                    {
                        label: "Disclaimer",
                        url: "https://www.health.gov.au/resources/publications/government-provider-management-system-terms-of-use",
                        target: "_blank"
                    }
                ]
            },
            {
                heading: "Links and resources",
                links: [{
                        label: "Department of Health and Aged Care website ",
                        url: "http://www.health.gov.au",
                        target: "_blank"
                    },
                    {
                        label: "My Aged Care service and support portal",
                        url: "https://www.health.gov.au/resources/apps-and-tools/my-aged-care-service-provider-portal",
                        target: "_blank"
                    },
                    {
                        label: "Aged Care Quality and Safety Commission website",
                        url: "https://www.agedcarequality.gov.au/",
                        target: "_blank"
                    },
                    {
                        label: "Contact us",
                        url: "https://www.health.gov.au/resources/apps-and-tools/government-provider-management-system",
                        target: "_blank"
                    }
                ]
            }
        ]
    }
}