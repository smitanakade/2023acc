import { api, LightningElement, wire } from "lwc";
import { loadStyle } from "lightning/platformResourceLoader";
import srqiStyles from "@salesforce/resourceUrl/srqi_styles";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getRDListBySFServiceAccountId from "@salesforce/apex/srqiStarRatingHistoryRetrieval.getRDListBySFServiceAccountId";

let cssLoaded = false;
const cellStyle = "font-size: 16px; font-weight: 500; height: 80px;";
const columns = [
    {
        label: "Action type",
        fieldName: "ViolationTypeName",
        hideDefaultActions: true,
        sortable: "true",
        type: "text",
        wrapText: true,
        cellAttributes: {
            style: cellStyle,
        },
    },
    {
        label: "Status",
        fieldName: "Status",
        initialWidth: 150,
        hideDefaultActions: true,
        sortable: "true",
        type: "text",
        wrapText: true,
        cellAttributes: {
            style: cellStyle,
        },
    },
    {
        label: "Date notice sent",
        fieldName: "Date_Decision_Applied",
        type: "date",
        hideDefaultActions: true,
        sortable: "true",
        typeAttributes: {
            year: "numeric",
            month: "long",
            day: "2-digit",
            wrapText: true,
        },
        cellAttributes: {
            style: cellStyle,
        },
    },
    {
        label: "Expiry date",
        fieldName: "Date_Decision_Ends",
        type: "date",
        hideDefaultActions: true,
        sortable: "true",
        typeAttributes: {
            year: "numeric",
            month: "long",
            day: "2-digit",
            wrapText: true,
        },
        cellAttributes: {
            style: cellStyle,
        },
    },
];
export default class SrqiPortalServiceComplianceDetails extends LightningElement {
    @api convertedSCH;
    @api serviceId;
    sortedBy;
    sortedDirection;
    rdList = [];
    convertedSCH = {};
    dataTable;

    //formatting the data coming from wire to be able to use parent records in the datatable
    formatDataTable(result) {
        const dataRefer = [];
        result.forEach((record) => {
            const preparedData = {};
            preparedData.Id = record.Id;
            preparedData.Service_Name_lookup = record.Service_Name_lookup__c;
            preparedData.ViolationTypeName = record.ViolationType.Name;
            preparedData.Date_Decision_Ends = record.Date_Decision_Ends__c;
            preparedData.Status = record.Status;
            preparedData.Date_Decision_Applied =
                record.Date_Decision_Applied__c;
            preparedData.Reason_for_issuing_Regulatory_Decision =
                record.Reason_for_issuing_Regulatory_Decision__c;
            dataRefer.push(preparedData);
        });
        this.dataTable = dataRefer;
    }

    dataTableColumns = columns;
    ratingDetails;

    renderedCallback() {
        if (!cssLoaded) {
            loadStyle(this, srqiStyles + "/portal.css");
            cssLoaded = true;
        }
    }

    @wire(getRDListBySFServiceAccountId, {
        sfServiceAccountId: "$serviceId",
    })
    wiredRecordsDataTable({ error, data }) {
        if (data) {
            this.rdList = data;

            this.formatDataTable(data);
        } else {
            if (error) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Error!!",
                        message: error?.body?.message,
                        variant: "error",
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
}
