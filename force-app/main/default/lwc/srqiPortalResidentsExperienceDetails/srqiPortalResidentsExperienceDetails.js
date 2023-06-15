import {api, LightningElement} from 'lwc';
import {loadStyle} from "lightning/platformResourceLoader";
import srqiStyles from '@salesforce/resourceUrl/srqi_styles';
import srqi_images from '@salesforce/resourceUrl/srqi_images';

let cssLoaded = false;

const columns = [
    {
        label: 'Survey questions',
        type: 'richText',
        hideDefaultActions: true,
        wrapText: true,
        fieldName: 'question',
        cellAttributes: {
            style: "font-size: 24px"
        }
    },
    {
        label: 'Residents\' responses',
        type: 'richText',
        hideDefaultActions: true,
        wrapText: true,
        fieldName: 'results',
        cellAttributes: {
            style: "width: 328px"
        }
    }
];
export default class srqiPortalResidentsExperienceDetails extends LightningElement {
    // Expected JSON field mapping example as below
    /*
    [
    {
        "questionIndex": 11,
        "name": [
            {
                "startDate": "2022-01-01",
                "value": "Do you have a say in your daily activities?"
            }
        ],
        "alwaysFieldName": "Consumer_Experience_Id__r.Voice_Always__c",
        "mostOfTheTimeFieldName": "Consumer_Experience_Id__r.Voice_Most_of_the_time__c",
        "neverFieldName": "Consumer_Experience_Id__r.Voice_Never__c",
        "someOfTheTimeFieldName": "Consumer_Experience_Id__r.Voice_Some_of_the_time__c"
    },
    {
        "questionIndex": 12,
        "name": [
            {
                "startDate": "2022-01-01",
                "value": "Do you feel at home here?"
            },
            {
                "startDate": "2023-01-01",
                "value": "How likely are you to recommend this residential aged care home to someone?"
            }
        ],
        "alwaysFieldName": "Consumer_Experience_Id__r.Home_Always__c",
        "mostOfTheTimeFieldName": "Consumer_Experience_Id__r.Home_Most_of_the_time__c",
        "neverFieldName": "Consumer_Experience_Id__r.Home_Never__c",
        "someOfTheTimeFieldName": "Consumer_Experience_Id__r.Home_Some_of_the_time__c"
    }
    ]
    */
    @api fieldMappingJSON;
    @api srhRecord;

    iconFaceAlways = srqi_images + '/face_always.svg';
    iconFaceMostOfTheTime = srqi_images + '/face_most_of_the_time.svg';
    iconFaceSomeOfTheTime = srqi_images + '/face_some_of_the_time.svg';
    iconFaceNever = srqi_images + '/face_never.svg';

    get fieldMappingList() {
        return this.fieldMappingJSON ? JSON.parse(this.fieldMappingJSON) : [];
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

    get resultCellStyle() {
        return `style="height: 18px; font-size: 18px; color: var(--gpmsColsecondaryDark); font-weight: 500;"`;
    }

    transformRatingDetails() {
        this.ratingDetails = [];
        for (const mapping of this.fieldMappingList) {
            this.ratingDetails.push({
                question: this.getQuestionCellContent(mapping),
                results: this.getRatingCellContent(mapping)
            });
        }
    }

    getQuestionCellContent(fieldMapping) {
        // Set default question
        let selectedQuestion = fieldMapping.name[0].value;
        for (const question of fieldMapping.name) {
            // Select question based on Iv_Commenced_Date__c and question start date
            if (this.srhRecord.Consumer_Experience_Id__r.Iv_Commenced_Date__c) {
                const interviewCommencedDate = new Date(this.srhRecord.Consumer_Experience_Id__r.Iv_Commenced_Date__c);
                // Convert interviewCommencedDate from UTC to local date in yyyy-mm-dd format, so it can be compared
                if (interviewCommencedDate.toLocaleDateString('en-CA') >= question.startDate) {
                    selectedQuestion = question.value;
                }
            }
        }

        return `${fieldMapping.questionIndex}.&nbsp;&nbsp;&nbsp;${selectedQuestion}`;
    }

    roundValue(value) {
        return value ? Math.round(value) : 0;
    }

    getRatingCellContent(fieldMapping) {
        return `
                <div class="slds-grid">
                    <div class="slds-m-right_large">
                        <img class="slds-p-right_small" src=${this.iconFaceAlways} title="Always"/>
                        <span class="slds-align_absolute-center" ${this.resultCellStyle}>
                                    ${this.roundValue(this.getFieldValue(this.srhRecord, fieldMapping.alwaysFieldName))}%
                        </span>
                    </div>
                    <div class="slds-m-right_large">
                        <img class="slds-p-right_small" src=${this.iconFaceMostOfTheTime} title="Most of the time"/>
                        <span class="slds-align_absolute-center" ${this.resultCellStyle}>
                                    ${this.roundValue(this.getFieldValue(this.srhRecord, fieldMapping.mostOfTheTimeFieldName))}%
                        </span>
                    </div>
                    <div class="slds-m-right_large">
                        <img class="slds-p-right_small" src=${this.iconFaceSomeOfTheTime} title="Some of the time"/>
                        <span class="slds-align_absolute-center" ${this.resultCellStyle}>
                                    ${this.roundValue(this.getFieldValue(this.srhRecord, fieldMapping.someOfTheTimeFieldName))}%
                        </span>
                    </div>
                    <div class="slds-m-right_large">
                        <img class="slds-p-right_small" src=${this.iconFaceNever} title="Never"/>
                        <span class="slds-align_absolute-center" ${this.resultCellStyle}>
                                    ${this.roundValue(this.getFieldValue(this.srhRecord, fieldMapping.neverFieldName))}%
                        </span>
                    </div>
                </div>
               `;
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