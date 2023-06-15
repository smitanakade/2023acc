import {api, LightningElement} from 'lwc';
import {loadStyle} from "lightning/platformResourceLoader";
import srqiStyles from '@salesforce/resourceUrl/srqi_styles';

let cssLoaded = false;

const columns = [
    {
        label: 'Care areas',
        type: 'richText',
        fieldName: 'name',
        hideDefaultActions: true,
        wrapText: true,
        cellAttributes: {
            style: "font-size: 20px; font-weight: 500;"
        }
    },
    {
        label: 'Your performance',
        type: 'servicePerformance',
        hideDefaultActions: true,
        wrapText: true,
        typeAttributes: {
            description: {fieldName: 'description'},
            serviceValue: {fieldName: 'serviceAverage'},
            isQI: true
        }
    },
    {
        label: 'You vs national average',
        type: 'serviceVsTarget',
        hideDefaultActions: true,
        wrapText: true,
        typeAttributes: {
            isAbove: {fieldName: 'isAbove'},
            isBelow: {fieldName: 'isBelow'},
            isEqual: {fieldName: 'isEqual'},
            compareToTarget: {fieldName: 'compareToNationalAverage'},
            targetValue: {fieldName: 'nationalAverage'},
            serviceValue: {fieldName: 'serviceAverage'},
            description: 'national average',
            isQI: true
        }
    }
];
export default class srqiPortalQualityMeasuresDetails extends LightningElement {
    // Expected JSON field mapping example as below
    /*
    [
    {
        "name": "Pressure injuries",
        "description": "of residents experienced pressure injuries",
        "compareToNationalAverageFieldName": "Quality_Indicator_Id__r.PI_Compare_with_National_Average__c",
        "serviceAverageFieldName": "Quality_Indicator_Id__r.Risk_Adjusted_PI__c",
        "nationalAverageFieldName": "Quality_Indicator_Id__r.National_Statistic__r.Risk_Adjusted_National_PI__c",
        "indicatorFieldName": "Quality_Indicator_Id__r.PI_Comparison_Outcome_Indicator__c"
    },
    {
        "name": "Physical restraint",
        "description": "of residents were physically restrained",
        "compareToNationalAverageFieldName": "Quality_Indicator_Id__r.PR_Compare_with_National_Average__c",
        "serviceAverageFieldName": "Quality_Indicator_Id__r.QI_Observed_Physical_Restraint__c",
        "nationalAverageFieldName": "Quality_Indicator_Id__r.National_Statistic__r.National_percentage_Physical_Restraint__c",
        "indicatorFieldName": "Quality_Indicator_Id__r.PR_Comparison_Outcome_Indicator__c"
    }
    ]
    */
    @api fieldMappingJSON;
    @api srhRecord;

    get fieldMappingList() {
        return this.fieldMappingJSON ? JSON.parse(this.fieldMappingJSON) : {};
    }

    dataTableColumns = columns;
    ratingDetails;

    getFieldValue(record, fieldMapping) {
        const fieldLayers = fieldMapping.split('.');
        let value;
        if (record) {
            value = JSON.parse(JSON.stringify(record));
            for (const fieldLayer of fieldLayers) {
                value = value?.[fieldLayer];
            }
        }
        return value;
    }

    transformRatingDetails() {
        this.ratingDetails = [];
        for (const mapping of this.fieldMappingList) {
            this.ratingDetails.push({
                name: mapping.name,
                description: mapping.description,
                compareToNationalAverage: Math.abs(this.getFieldValue(this.srhRecord, mapping.compareToNationalAverageFieldName)),
                nationalAverage: this.getFieldValue(this.srhRecord, mapping.nationalAverageFieldName),
                serviceAverage: this.getFieldValue(this.srhRecord, mapping.serviceAverageFieldName),
                isEqual: this.getFieldValue(this.srhRecord, mapping.indicatorFieldName) === 'Same',
                isBelow: this.getFieldValue(this.srhRecord, mapping.indicatorFieldName) === 'Below',
                isAbove: this.getFieldValue(this.srhRecord, mapping.indicatorFieldName) === 'Above'
            });
        }
    }

    renderedCallback() {
        if (!cssLoaded) {
            loadStyle(this, srqiStyles + '/portal.css');
            cssLoaded = true;
        }
    }

    connectedCallback() {
        this.transformRatingDetails();
    }
}