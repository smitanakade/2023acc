import {api, LightningElement, track, wire} from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import getSRHListBySFServiceId from '@salesforce/apex/srqiStarRatingHistoryRetrieval.getSRHListBySFServiceId';
import {CurrentPageReference, NavigationMixin} from 'lightning/navigation';
import {loadStyle} from "lightning/platformResourceLoader";
import srqiStyles from '@salesforce/resourceUrl/srqi_styles';

let cssLoaded = false;

const EXEMPTION_TSM = 'Transferred Service';
const EXEMPTION_NSM = 'New Service';
const EXEMPTION_BEM = 'Business Exemption';
const RATING_TYPE_NEW = 'New Rating';
const RATING_TYPE_CURRENT = 'Current Rating';
const RATING_TYPE_PREVIOUS = 'Previous Rating';
const EXEMPTION_SYSTEM = [EXEMPTION_TSM, EXEMPTION_NSM];
const BADGE_UNDER_REVIEW = 'Under review';
const BADGE_PUB_AVA = 'Publicly available';
const BADGE_PREVIEW = 'Preview'
const LABEL_NO_RATING_AVAILABLE = 'No rating available.';
const LABEL_EXEMPTED = 'This sub-category is exempt from the calculation of a Star Rating.';
const LABEL_UNDER_REVIEW = 'This rating is under review.';
const LENGTH_TIMESTAMP = 14;
export default class srqiStarRateHistorySubCategoryGraphsP extends NavigationMixin(LightningElement) {
    @api showQIRatingDetails;
    @api showCMRatingDetails;
    @api showSCRRatingDetails;
    @api showCERRatingDetails;
    @api qiDatatableFieldMappingJSON;
    @api cmDatatableFieldMappingJSON;
    @api cerDatatableFieldMappingJSON;
    @api officeURL = 'https://www.agedcarequality.gov.au/';
    @api qiInfoURL = 'https://www.health.gov.au/resources/publications/star-ratings-provider-manual?language=en';
    receivedServiceId;
    receivedSRHId;
    receivedActualSRHId;
    @api returnedServiceIdToBeSendToViewRatings;
    chart;
    @api serviceId;

    /*Rating information for graphs */
    @track chartSRData = [];
    @track chartDateSRData = [];
    @track chartCMRData = [];
    @track chartDateCMRData = [];
    @track chartCERData = [];
    @track chartDateCERData = [];
    chartDateSliceCER;
    @track chartQIData = [];
    @track chartDateQIData = [];
    @track chartSCData = [];
    @track chartDateSCData = [];
    chartDateSliceSC;
    currentPageReference = null;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            if (Object.keys(currentPageReference.state).length > 0) {
                this.receivedServiceId = currentPageReference.state.ServiceId; // getting the value "ServiceID" from ServiceId key on URL
                this.receivedSRHId = currentPageReference.state.RecordIdSRH;
                this.receivedActualSRHId = currentPageReference.state.SRHActualId; // getting value "ID" from SRH sent from Rami's comp
            }
        }
    }

    srhList = [];
    selectedSRH = {};
    currentSRH = {};
    newSRH = {};

    capitalizeFirstLatter(label) {
        return label.charAt(0).toUpperCase() + label.slice(1).toLowerCase();
    }

    get firstRatingTileTitle() {
        if (this.selectedSRH?.Rating_Type__c === RATING_TYPE_PREVIOUS) {
            return this.capitalizeFirstLatter(RATING_TYPE_PREVIOUS);
        } else {
            return this.capitalizeFirstLatter(RATING_TYPE_CURRENT);
        }
    }

    get secondRatingTileTitle() {
        return this.capitalizeFirstLatter(RATING_TYPE_NEW);
    }

    get isSelectedSRHPreviousRating() {
        return this.selectedSRH?.Rating_Type__c === RATING_TYPE_PREVIOUS;
    }

    get labelNoRatingAvailable() {
        return LABEL_NO_RATING_AVAILABLE;
    }

    get labelExempted() {
        return LABEL_EXEMPTED;
    }

    get labelUnderReview() {
        return LABEL_UNDER_REVIEW;
    }

    async connectedCallback() {
        try {
            this.srhList = await getSRHListBySFServiceId({sfServiceId: this.receivedSRHId});
        } catch (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error occurred when retrieving star rating history data',
                    message: error?.message,
                    variant: 'error',
                    mode: 'sticky',
                }),
            );
        }
        this.resetData();
        this.setupViewBySelectedSRHRatingType();
        this.populateChartData();
    }

    resetData() {
        this.chartCERData = [];
        this.chartDateCERData = [];
        this.chartSRData = [];
        this.chartDateSRData = [];
        this.chartCMRData = [];
        this.chartDateCMRData = [];
        this.chartSCData = [];
        this.chartDateSCData = [];
        this.chartQIData = [];
        this.chartDateQIData = [];
        this.currentSRH = {};
        this.newSRH = {};
        this.selectedSRH = {};
    }

    populateChartData() {
        let cerSet = new Set();
        let scrSet = new Set();

        for (const srh of this.srhList) {
            this.chartSRData.push(srh.STAR_Rating_Calculation__c === 0 ? undefined : srh.STAR_Rating_Calculation__c);
            this.chartDateSRData.push(srh.Go_Live_Date__c);

            this.chartCMRData.push(srh.Care_Minutes_Id__r?.Care_Minutes_Rating__c === 0 ? undefined : srh.Care_Minutes_Id__r?.Care_Minutes_Rating__c);
            this.chartDateCMRData.push(srh.Go_Live_Date__c);

            if (!cerSet.has(srh.Consumer_Experience_Id__r?.Id)) {
                cerSet.add(srh.Consumer_Experience_Id__r?.Id);
                this.chartCERData.push(srh.Consumer_Experience_Id__r?.Consumer_Experience_Rating__c === 0 ? undefined : srh.Consumer_Experience_Id__r?.Consumer_Experience_Rating__c);
                this.chartDateSliceCER = srh.Consumer_Experience_Id__r?.Publication_Date__c;
                this.chartDateSliceCER = this.chartDateSliceCER?.slice(0, -LENGTH_TIMESTAMP);
                this.chartDateCERData.push(this.chartDateSliceCER);
            }

            this.chartQIData.push(srh.Quality_Indicator_Id__r?.Quality_Indicator_Rating__c === 0 ? undefined : srh.Quality_Indicator_Id__r?.Quality_Indicator_Rating__c);
            this.chartDateQIData.push(srh.Go_Live_Date__c);

            if (!scrSet.has(srh.Service_Compliance_Id__r?.Id)) {
                scrSet.add(srh.Service_Compliance_Id__r?.Id);
                this.chartSCData.push(srh.Service_Compliance_Id__r?.Service_Compliance_Rating__c === 0 ? undefined : srh.Service_Compliance_Id__r?.Service_Compliance_Rating__c);
                this.chartDateSliceSC = srh.Service_Compliance_Id__r?.Publication_Date__c;
                this.chartDateSliceSC = this.chartDateSliceSC?.slice(0, -LENGTH_TIMESTAMP);
                this.chartDateSCData.push(this.chartDateSliceSC);
            }
        }
        this.template.querySelectorAll('c-srqi-star-rating-history-graph').forEach(cmp => {
            const delayTime = 500;
            setTimeout(() => {
                cmp.refresh();
            }, delayTime);
        });
    }

    setupViewBySelectedSRHRatingType() {
        let actualCurrentSRH;
        let actualNewSRH;

        for (const srh of this.srhList) {
            if (srh.Id === this.receivedActualSRHId) {
                this.selectedSRH = JSON.parse(JSON.stringify(srh));
            }

            if (srh?.Rating_Type__c === RATING_TYPE_CURRENT) {
                actualCurrentSRH = srh;
            }

            if (srh?.Rating_Type__c === RATING_TYPE_NEW) {
                actualNewSRH = srh;
            }
        }

        if (this.selectedSRH?.Rating_Type__c === RATING_TYPE_PREVIOUS) {
            if (this.selectedSRH?.Id) {
                this.currentSRH = JSON.parse(JSON.stringify(this.selectedSRH));
            }
            this.newSRH = {};
        }

        if (this.selectedSRH?.Rating_Type__c === RATING_TYPE_NEW ||
            this.selectedSRH?.Rating_Type__c === RATING_TYPE_CURRENT) {
            if (actualCurrentSRH?.Id) {
                this.currentSRH = JSON.parse(JSON.stringify(actualCurrentSRH));
            }
            if (actualNewSRH?.Id) {
                this.newSRH = JSON.parse(JSON.stringify(actualNewSRH));
            }
        }
    }

    goToAllServices() {
        this[NavigationMixin.Navigate]({
                type: 'standard__namedPage',
                attributes: {
                    name: 'Your_Organisations_Rating__c'
                }
            },
            true
        );
    }

    get statusBadgeCssClasses() {
        let cssClass = 'slds-badge_inverse slds-m-top_small srqi-badge ';
        switch (this.selectedSRH.Provider_Portal_Status__c) {
            case BADGE_UNDER_REVIEW:
                cssClass += 'srqi-badge-under-review';
                break;
            case BADGE_PREVIEW:
                cssClass += 'srqi-badge-preview';
                break;
            case BADGE_PUB_AVA:
                cssClass += 'srqi-badge-publicly-available';
                break;
        }
        return cssClass;
    }

    //Begin selectedRate/Date Data
    get chartSelectedDateSRData() {
        return this.selectedSRH?.Go_Live_Date__c
    }

    get chartSelectedDateCMRData() {
        return this.selectedSRH?.Go_Live_Date__c
    }

    get chartSelectedDateCERData() {
        return this.selectedSRH?.Consumer_Experience_Id__r?.Publication_Date__c?.slice(0, -LENGTH_TIMESTAMP);
    }

    get chartSelectedDateQIData() {
        return this.selectedSRH?.Go_Live_Date__c
    }

    get chartSelectedDateSCData() {
        return this.selectedSRH?.Service_Compliance_Id__r?.Publication_Date__c?.slice(0, -LENGTH_TIMESTAMP);
    }

    //End selectedRate/Date Data*/

    get selectedServiceName() {
        return this.selectedSRH?.SF_Service_Id__r?.Name;
    }

    get selectedServiceIntegrationId() {
        return this.selectedSRH?.SF_Service_Id__r?.Integration_ID__c;
    }

    get selectedReportingPeriod() {
        return this.selectedSRH?.Reporting_Period__r?.Reporting_Period_Short__c;
    }

    //Begin overall 
    get isCurrentOverallRatingSystemExempted() {
        return EXEMPTION_SYSTEM.includes(this.currentSRH?.Rating_Exemption_Reason__c);
    }

    get isNewOverallRatingSystemExempted() {
        return EXEMPTION_SYSTEM.includes(this.newSRH?.Rating_Exemption_Reason__c);
    }

    get isCurrentOverallRatingUnderReview() {
        return this.currentSRH?.Under_Review__c;
    }

    get isNewOverallRatingUnderReview() {
        return this.newSRH?.Under_Review__c;
    }

    get showOverallRatingLeftTileBody() {
        return !this.isCurrentOverallRatingBusinessExempted && !this.isCurrentOverallRatingSystemExempted && !this.isCurrentOverallRatingMissing && !this.currentSRH.Under_Review__c;
    }

    get showOverallRatingRightTileBody() {
        return !this.isNewOverallRatingBusinessExempted && !this.isNewOverallRatingSystemExempted && !this.isNewOverallRatingMissing && !this.newSRH.Under_Review__c;
    }

    get isCurrentOverallRatingBusinessExempted() {
        return this.isReasonBusinessExemption(this.currentSRH?.Rating_Exemption_Reason__c);
    }

    get isNewOverallRatingBusinessExempted() {
        return this.isReasonBusinessExemption(this.newSRH?.Rating_Exemption_Reason__c);
    }

    get isCurrentOverallRatingMissing() {
        return this.currentSRH?.STAR_Rating_Calculation__c === undefined;
    }

    get isNewOverallRatingMissing() {
        return this.newSRH?.STAR_Rating_Calculation__c === undefined;
    }

    // Begin QI
    get currentQI() {
        return this.currentSRH?.Quality_Indicator_Id__r ? this.currentSRH?.Quality_Indicator_Id__r : {};
    }

    get newQI() {
        return this.newSRH?.Quality_Indicator_Id__r ? this.newSRH?.Quality_Indicator_Id__r : {};
    }

    get isNewQIUnderReview() {
        return this.newSRH?.Quality_Indicator_Id__r?.Under_Review__c;
    }

    get isCurrentQIUnderReview() {
        return this.currentSRH?.Quality_Indicator_Id__r?.Under_Review__c;
    }

    get isCurrentQISystemExempted() {
        return EXEMPTION_SYSTEM.includes(this.currentSRH?.Quality_Indicator_Id__r?.Rating_Exemption_Reason__c);
    }

    get isNewQISystemExempted() {
        return EXEMPTION_SYSTEM.includes(this.newSRH?.Quality_Indicator_Id__r?.Rating_Exemption_Reason__c);
    }

    get showQILeftTileBody() {
        return !this.isCurrentQIBusinessExempted && !this.isCurrentQISystemExempted && !this.isCurrentQIRatingMissing && !this.currentQI.Under_Review__c;
    }

    get showQIRightTileBody() {
        return !this.isNewQIBusinessExempted && !this.isNewQISystemExempted && !this.isNewQIRatingMissing && !this.newQI.Under_Review__c;
    }

    get isCurrentQIBusinessExempted() {
        return this.isReasonBusinessExemption(this.currentQI?.Rating_Exemption_Reason__c);
    }

    get isNewQIBusinessExempted() {
        return this.isReasonBusinessExemption(this.newQI?.Rating_Exemption_Reason__c);
    }

    get isCurrentQIRatingMissing() {
        return this.currentQI?.Quality_Indicator_Rating__c === undefined;
    }

    get isNewQIRatingMissing() {
        return this.newQI?.Quality_Indicator_Rating__c === undefined;
    }

    //End QI

    //Begin SCR
    get currentSCR() {
        return this.currentSRH?.Service_Compliance_Id__r ? this.currentSRH?.Service_Compliance_Id__r : {};
    }

    get newSCR() {
        return this.newSRH?.Service_Compliance_Id__r ? this.newSRH?.Service_Compliance_Id__r : {};
    }

    get isCurrentSCRSystemExempted() {
        return EXEMPTION_SYSTEM.includes(this.currentSCR?.Rating_Exemption_Reason__c);
    }

    get isNewSCRSystemExempted() {
        return EXEMPTION_SYSTEM.includes(this.newSCR?.Rating_Exemption_Reason__c);
    }

    get showSCRLeftTileBody() {
        return !this.isCurrentSCRBusinessExempted && !this.isCurrentSCRSystemExempted && !this.isCurrentSCRRatingMissing;
    }

    get showSCRRightTileBody() {
        return !this.isNewSCRBusinessExempted && !this.isNewSCRSystemExempted && !this.isNewSCRRatingMissing;
    }

    get isCurrentSCRBusinessExempted() {
        return this.isReasonBusinessExemption(this.currentSCR?.Rating_Exemption_Reason__c);
    }

    get isNewSCRBusinessExempted() {
        return this.isReasonBusinessExemption(this.newSCR?.Rating_Exemption_Reason__c);
    }

    get isCurrentSCRRatingMissing() {
        return this.currentSCR?.Service_Compliance_Rating__c === undefined;
    }

    get isNewSCRRatingMissing() {
        return this.newSCR?.Service_Compliance_Rating__c === undefined;
    }

    // End SCR

    //Begin CM
    get currentCM() {
        return this.currentSRH?.Care_Minutes_Id__r ? this.currentSRH?.Care_Minutes_Id__r : {};
    }

    get newCM() {
        return this.newSRH?.Care_Minutes_Id__r ? this.newSRH?.Care_Minutes_Id__r : {};
    }

    get isNewCMUnderReview() {
        return this.newSRH?.Care_Minutes_Id__r?.Under_Review__c;
    }

    get isCurrentCMUnderReview() {
        return this.currentSRH?.Care_Minutes_Id__r?.Under_Review__c;
    }

    get isCurrentCMSystemExempted() {
        return EXEMPTION_SYSTEM.includes(this.currentCM?.Rating_Exemption_Reason__c);
    }

    get isNewCMSystemExempted() {
        return EXEMPTION_SYSTEM.includes(this.newCM?.Rating_Exemption_Reason__c);
    }

    get showCMLeftTileBody() {
        return !this.isCurrentCMBusinessExempted && !this.isCurrentCMSystemExempted && !this.isCurrentCMRatingMissing && !this.currentCM.Under_Review__c;
    }

    get showCMRightTileBody() {
        return !this.isNewCMBusinessExempted && !this.isNewCMSystemExempted && !this.isNewCMRatingMissing && !this.newCM.Under_Review__c;
    }

    get isCurrentCMBusinessExempted() {
        return this.isReasonBusinessExemption(this.currentCM?.Rating_Exemption_Reason__c);
    }

    get isNewCMBusinessExempted() {
        return this.isReasonBusinessExemption(this.newCM?.Rating_Exemption_Reason__c);
    }

    get isCurrentCMRatingMissing() {
        return this.currentCM?.Care_Minutes_Rating__c === undefined;
    }

    get isNewCMRatingMissing() {
        return this.newCM?.Care_Minutes_Rating__c === undefined;
    }

    //End CM

    //Begin CER
    get currentCER() {
        return this.currentSRH?.Consumer_Experience_Id__r ? this.currentSRH?.Consumer_Experience_Id__r : {};
    }

    get newCER() {
        return this.newSRH?.Consumer_Experience_Id__r ? this.newSRH?.Consumer_Experience_Id__r : {};
    }

    get isCurrentCERUnderReview() {
        return this.currentSRH?.Consumer_Experience_Id__r?.Under_Review__c;
    }

    get isNewCERUnderReview() {
        return this.newSRH?.Consumer_Experience_Id__r?.Under_Review__c;
    }

    get isCurrentCERSystemExempted() {
        return EXEMPTION_SYSTEM.includes(this.currentCER?.Rating_Exemption_Reason__c);
    }

    get isNewCERSystemExempted() {
        return EXEMPTION_SYSTEM.includes(this.newCER?.Rating_Exemption_Reason__c);
    }

    get showCERLeftTileBody() {
        return !this.isCurrentCERBusinessExempted && !this.isCurrentSCRSystemExempted && !this.isCurrentCERRatingMissing && !this.currentCER.Under_Review__c;
    }

    get showCERRightTileBody() {
        return !this.isNewCERBusinessExempted && !this.isNewSCRSystemExempted && !this.isNewCERRatingMissing && !this.newCER.Under_Review__c;
    }

    get isCurrentCERBusinessExempted() {
        return this.isReasonBusinessExemption(this.currentCER?.Rating_Exemption_Reason__c);
    }

    get isNewCERBusinessExempted() {
        return this.isReasonBusinessExemption(this.newCER?.Rating_Exemption_Reason__c);
    }

    get isCurrentCERRatingMissing() {
        return this.currentCER?.Consumer_Experience_Rating__c === undefined;
    }

    get isNewCERRatingMissing() {
        return this.newCER?.Consumer_Experience_Rating__c === undefined;
    }

    //End CER
    isReasonBusinessExemption(reason) {
        return reason === EXEMPTION_BEM;
    }

    getAllExemptionReasons(srh) {
        return [srh.Rating_Exemption_Reason__c,
            srh.Care_Minutes_Id__r?.Rating_Exemption_Reason__c,
            srh.Consumer_Experience_Id__r?.Rating_Exemption_Reason__c,
            srh.Service_Compliance_Id__r?.Rating_Exemption_Reason__c,
            srh.Quality_Indicator_Id__r?.Rating_Exemption_Reason__c
        ];
    }

    isBusinessExempted(srh) {
        for (const reason of this.getAllExemptionReasons(srh)) {
            if (this.isReasonBusinessExemption(reason)) {
                return true;
            }
        }
        return false;
    }

    get hasBusinessExemption() {
        return this.isBusinessExempted(this.currentSRH) || this.isBusinessExempted(this.newSRH);
    }

    isTransferExempted(srh) {
        for (const reason of this.getAllExemptionReasons(srh)) {
            if (reason === EXEMPTION_TSM) {
                return true;
            }
        }
        return false;
    }

    get hasTransferExemption() {
        return this.isTransferExempted(this.currentSRH) || this.isTransferExempted(this.newSRH);
    }

    isNewProviderExempted(srh) {
        for (const reason of this.getAllExemptionReasons(srh)) {
            if (reason === EXEMPTION_NSM) {
                return true;
            }
        }
        return false;
    }

    get hasNewProviderExemption() {
        return this.isNewProviderExempted(this.currentSRH) || this.isNewProviderExempted(this.newSRH);
    }

    isAnyMissingSRHRating(srhRatings) {
        for (const rating of srhRatings) {
            if (rating === undefined) {
                return true;
            }
        }
        return false;
    }

    get isAnyMissingRating() {
        const allCurrentRatings = [
            this.currentSRH?.STAR_Rating_Calculation__c,
            this.currentSCR?.Service_Compliance_Rating__c,
            this.currentCM?.Care_Minutes_Rating__c,
            this.currentQI?.Quality_Indicator_Rating__c,
            this.currentCER?.Consumer_Experience_Rating__c
        ];
        const allNewRatings = [this.newSRH?.STAR_Rating_Calculation__c,
            this.newSCR?.Service_Compliance_Rating__c,
            this.newCM?.Care_Minutes_Rating__c,
            this.newQI?.Quality_Indicator_Rating__c,
            this.newCER?.Consumer_Experience_Rating__c
        ];
        return (this.currentSRH.Id && this.isAnyMissingSRHRating(allCurrentRatings)) ||
            (this.newSRH.Id && this.isAnyMissingSRHRating(allNewRatings));
    }

    get isAnyUnderReview() {
        return this.currentSRH?.Under_Review__c || this.newSRH?.Under_Review__c;
    }

    get isQIRatingDetailsAvailable() {
        return this.showQIRatingDetails && !this.isSelectedQISystemExempted && !this.isSelectedQIBusinessExempted;
    }

    get isCMRatingDetailsAvailable() {
        return this.showCMRatingDetails && !this.isSelectedCMSystemExempted && !this.isSelectedCMBusinessExempted;
    }

    get isCERRatingDetailsAvailable() {
        return this.showCERRatingDetails && !this.isSelectedCERSystemExempted && !this.isSelectedCERBusinessExempted;
    }

    get isSCRRatingDetailsAvailable() {
        return this.showSCRRatingDetails && !this.isSelectedSCRSystemExempted && !this.isSelectedSCRBusinessExempted;
    }

    get isSelectedSCRSystemExempted() {
        return this.selectedSRH.Id === this.currentSRH.Id ? this.isCurrentSCRSystemExempted : this.isNewSCRSystemExempted;
    }

    get isSelectedSCRBusinessExempted() {
        return this.selectedSRH.Id === this.currentSRH.Id ? this.isCurrentSCRBusinessExempted : this.isNewSCRBusinessExempted;
    }

    get isSelectedCERSystemExempted() {
        return this.selectedSRH.Id === this.currentSRH.Id ? this.isCurrentCERSystemExempted : this.isNewCERSystemExempted;
    }

    get isSelectedCERBusinessExempted() {
        return this.selectedSRH.Id === this.currentSRH.Id ? this.isCurrentCERBusinessExempted : this.isNewCERBusinessExempted;
    }

    get isSelectedQISystemExempted() {
        return this.selectedSRH.Id === this.currentSRH.Id ? this.isCurrentQISystemExempted : this.isNewQISystemExempted;
    }

    get isSelectedQIBusinessExempted() {
        return this.selectedSRH.Id === this.currentSRH.Id ? this.isCurrentQIBusinessExempted : this.isNewQIBusinessExempted;
    }

    get isSelectedCMSystemExempted() {
        return this.selectedSRH.Id === this.currentSRH.Id ? this.isCurrentCMSystemExempted : this.isNewCMSystemExempted;
    }

    get isSelectedCMBusinessExempted() {
        return this.selectedSRH.Id === this.currentSRH.Id ? this.isCurrentCMBusinessExempted : this.isNewCMBusinessExempted;
    }

    renderedCallback() {
        if (!cssLoaded) {
            loadStyle(this, srqiStyles + '/portal.css');
            cssLoaded = true;
        }
    }
}