/**
 * @author Rami Zuhairi
 * @date 17-09-2022
 * @objects Reporting_Period_Short__c , BusinessLicense, STAR_Rating_History__c
 * @description LWC custom type Datatable and smart search functionality that will help the user to display the data from STAR_Rating_History__c
 * It allows the user to search by number or by Service name.
 * It allows the user to sort the result data with sorting functionality.
 * It will receive the divided number of records from pagination and display it.c/srqiCustomDataTable
 * c/srqiCustomDataTable - that has the custom datatype for Datatable to restore the images that come from the formula field
 */
import {api, LightningElement, wire} from "lwc";
import {ShowToastEvent} from "lightning/platformShowToastEvent";
import {CurrentPageReference, NavigationMixin} from "lightning/navigation";
import srqi_images from "@salesforce/resourceUrl/srqi_images";
import {loadStyle} from "lightning/platformResourceLoader";
import srqiStyles from "@salesforce/resourceUrl/srqi_styles";

let cssLoaded = false;
const starRating1 = 1;
const starRating2 = 2;
const starRating3 = 3;
const starRating4 = 4;
const starRating5 = 5;

const cellStyle = "font-size: 18px; height: 100px;";
const columns = [
    //columns need for the custom datatable  slds-text-body_small slds-text-color_weak
    {
        label: "Service ID",
        fieldName: "ServiceID",
        sortable: "true",
        initialWidth: 126,
        sortedDirection: "asc",
        cellAttributes: {
            class: "slds-text-color_weak",
            style: "font-size: 18px; color: #888888; height: 100px; ",
        },
    },
    {
        label: "Service name",
        fieldName: "ServiceName",
        sortable: "true",
        initialWidth: 210,
        wrapText: true,
        cellAttributes: {
            style: "font-size: 18px; font-weight: 500; height: 100px; ",
        },
    },
    {
        label: "Quarter",
        fieldName: "Quarter",
        sortable: "true",
        initialWidth: 176,
        cellAttributes: {
            style: cellStyle,
        },
    },
    {
        label: "Rating type",
        fieldName: "ProviderPortal_RatingType__c",
        sortable: true,
        initialWidth: 140,
        cellAttributes: {
            alignment: "center",
            style: cellStyle,
        },
    },
    {
        label: "Status",
        sortable: true,
        fieldName: "Provider_Portal_Status__c",
        initialWidth: 140,
        type: "qiPillCustomButton",
        typeAttributes: {
            buttonStatus: {fieldName: "Provider_Portal_Status__c"},
            submittedDate: {fieldName: "submissionDate"},
            buttonStyle: {fieldName: "statusColor"},
        },
    },
    {
        label: "Overall Star Rating",
        fieldName: "STAR_Rating_Calculation__c",
        type: "richText",
        sortable: "true",
        initialWidth: 190,
        cellAttributes: {
            style: cellStyle,
        },
    },
    {
        label: "Publicly available",
        fieldName: "Go_Live_Date__c",
        sortable: "true",
        type: "date-local",
        initialWidth: 160,
        cellAttributes: {
            style: cellStyle,
        },
        typeAttributes: {
            month: "2-digit",
            day: "2-digit",
        },
    },
    {
        type: "button",
        fixedWidth: 90,
        typeAttributes: {
            label: "View",
            title: "View",
            name: "viewDetails",
            value: "viewDetails",
            variant: "Brand"
        },
        cellAttributes: {
            class: "srqi-brand-background-button"
        }
    },
];

export default class srqiSearchDataTableStarRating extends NavigationMixin(
    LightningElement
) {
    @api itemsNumber;
    @api filterBy;
    @api chosenValueRP;
    @api chosenValueStatus;
    dataTableColumns = columns;
    dataTable;
    visibleDataTable;
    sortedBy;
    sortedDirection;
    serviceIdToBeSendToStarRatingViewPage;
    recordIdToBeSendToStarRatingViewPage;
    //Get CurrentPageReference
    @wire(CurrentPageReference)
    pageRef;

    //formatting the data coming from wire to be able to use parent records in the datatable
    @api
    formatDataTable(result) {
        this.itemsNumber = 0;
        let dataRefer = [];
        result.forEach((record) => {
            let preparedData = {};
            // to get number of items in the table
            this.itemsNumber = this.itemsNumber + 1;
            preparedData.Id = record.Id;
            preparedData.SF_Service_Id__c = record.SF_Service_Id__c;
            preparedData.ServiceName = record.SF_Service_Id__r.Name;
            preparedData.ServiceID = record.SF_Service_Id__r.Integration_ID__c;
            preparedData.Quarter =
                record.Reporting_Period__r.Reporting_Period_Short__c;
            preparedData.ProviderPortal_RatingType__c =
                record.ProviderPortal_RatingType__c;
            preparedData.Rating_Calc_Date__c = record.Rating_Calc_Date__c;
            preparedData.STAR_Rating_Calculation__c =
                record.STAR_Rating_Calculation__c;
            preparedData.Go_Live_Date__c = record.Go_Live_Date__c;
            preparedData.Under_Review__c = record.Under_Review__c;
            preparedData.Provider_Portal_Status__c =
                record.Provider_Portal_Status__c;
            // Set cellAttributes based on the value of Status
            preparedData.statuscolor =
                "border-radius: 10rem; position: absolute; margin-left: 20px; vertical-align: middle; margin-top: 0.8em; padding-left: 25px; width:120px;line-height: 14px;";
            preparedData.statusColor = "";
            switch (preparedData.Provider_Portal_Status__c) {
                case "Publicly available":
                    preparedData.statusColor +=
                        "background-color: #EDF2EC;  color: #4D8144;  cursor: pointer;";
                    break;
                case "Preview":
                    preparedData.statusColor +=
                        "background-color: #04819C; cursor: pointer;";
                    break;
                case "Under review":
                    preparedData.statusColor +=
                        "background-color: #FFA400; color: #000000;  cursor: pointer;";
                    break;
                default:
                    break;
            }

            // Set the STAR rating to a string of stars based on the value of STAR_Rating_Calculation__c
            switch (preparedData.STAR_Rating_Calculation__c) {
                case starRating1:
                    preparedData.STAR_Rating_Calculation__c = `<img src="${srqi_images}/stars_1.svg" />`;
                    break;
                case starRating2:
                    preparedData.STAR_Rating_Calculation__c = `<img src="${srqi_images}/stars_2.svg" />`;
                    break;
                case starRating3:
                    preparedData.STAR_Rating_Calculation__c = `<img src="${srqi_images}/stars_3.svg" />`;
                    break;
                case starRating4:
                    preparedData.STAR_Rating_Calculation__c = `<img src="${srqi_images}/stars_4.svg" />`;
                    break;
                case starRating5:
                    preparedData.STAR_Rating_Calculation__c = `<img src="${srqi_images}/stars_5.svg" />`;
                    break;
                default:
                    preparedData.STAR_Rating_Calculation__c =
                        "No rating available";
                    break;
            }

            // Add cellAttributes to the Status__c column
            if (!preparedData.columns) {
                preparedData.columns = {};
            }
            preparedData.columns.Provider_Portal_Status__c = {
                cellAttributes: preparedData.cellAttributes,
                fieldName: "Provider_Portal_Status__c",
            };

            dataRefer.push(preparedData);
        });

        // Update the data table with the new data
        this.dataTable = dataRefer;
        if (this.sortedBy && this.sortedDirection) {
            this.sortDataLogic(this.sortedBy, this.sortedDirection);
        }
    }

    //View Rating Page
    viewRecord(event) {
        if (event.detail.action.name === "viewDetails") {
            //get Row details and the IntegrationId
            const row = event.detail.row;
            this.recordIdToBeSendToStarRatingViewPage = row.SF_Service_Id__c;
            this.serviceIdToBeSendToStarRatingViewPage = row.ServiceID;
            this.srhIdToBeSendToStarRatingViewPage = row.Id;
            //check of recordId has data
            if (this.recordIdToBeSendToStarRatingViewPage) {
                // Navigate to a specific community page Send the IntegrationId to ViewRatingPage.
                this[NavigationMixin.Navigate](
                    {
                        type: "comm__namedPage",
                        attributes: {
                            name: "Star_Rating_Details__c",
                        },
                        state: {
                            ServiceId:
                            this.serviceIdToBeSendToStarRatingViewPage,
                            RecordIdSRH:
                            this.recordIdToBeSendToStarRatingViewPage,
                            SRHActualId: this.srhIdToBeSendToStarRatingViewPage,
                            sourcePageType: "standard__namedPage",
                            sourcePageName: "Your_Organisations_Rating__c",
                        },
                    },
                    true
                );
            } else {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Star Rating View!!",
                        message:
                            "Opps!, Can not view at the moment,  Please navigate from the navigation bar",
                        variant: "info",
                        mode: "pester",
                    })
                );
            }
        }
    }

    // Set sortedBy and sortedDirection
    onSortData(event) {
        this.sortedBy = event.detail.fieldName;
        this.sortedDirection = event.detail.sortDirection;
        this.sortDataLogic(this.sortedBy, this.sortedDirection);
    }

    sortDataLogic(dtFieldName, directionToSort) {
        const parseData = JSON.parse(JSON.stringify(this.dataTable));
        const keyValue = (key) => {
            return key[dtFieldName];
        };
        const isReverseOrder = directionToSort === "asc" ? 1 : -1;
        parseData.sort((as, des) => {
            as = keyValue(as) ? keyValue(as) : "";
            des = keyValue(des) ? keyValue(des) : "";
            return isReverseOrder * this.compareValue(as, des);
        });
        this.dataTable = parseData;
    }

    compareValue(as, des) {
        if (as > des) {
            return 1;
        } else if (as < des) {
            return -1;
        } else {
            return 0;
        }
    }

    updateDataTableHandler(event) {
        this.visibleDataTable = [...event.detail.records];
    }

    renderedCallback() {
        if (!cssLoaded) {
            loadStyle(this, srqiStyles + "/portal.css");
            cssLoaded = true;
        }
    }
}