/**
 * @author Rami Zuhairi
 * @date 17-09-2022
 * @objects: Reporting_Period__c , BusinessLicense, STAR_Rating_History__c
 * @description Pagination component from either a local development server or a Salesforce hosted Lightning page.
 * It allows the user to dynamically change the number of rows displayed on each page.
 */
import { api, LightningElement } from "lwc";

export default class srqiDataTablePaginationStarRating extends LightningElement {
    // Check current page
    currentPage = 1;
    totalRecords;
    @api recordSize = 10;
    totalPage = 0;
    @api showResults = false;
    totalResults;
    recordsShown;

    get records() {
        return this.visibleRecords;
    }

    @api
    set records(data) {
        if (data) {
            this.currentPage = 1;
            this.totalRecords = data;
            this.recordSize = Number(this.recordSize);
            // Will divide number of pages returned and for example 1.7 = 2
            this.totalPage = Math.ceil(data.length / this.recordSize);
            this.totalPage = Math.ceil(data.length / this.recordSize);

            this.totalResults = data.length;
            if (data.length > 0) {
                this.recordsShown =
                    data.length > this.recordSize
                        ? "1 to " + this.recordSize
                        : "1 to " + data.length;
            }

            if (data.length === 0) {
                this.totalPage = 0;
                this.currentPage = 0;
            }

            this.updateRecords();
        }
    }

    get disablePrevious() {
        return this.currentPage <= 1;
    }

    get disableNext() {
        return this.currentPage >= this.totalPage;
    }

    previousHandler() {
        if (this.currentPage > 1) {
            this.currentPage = this.currentPage - 1;
            this.setRecordsShown();
            this.updateRecords();
        }
    }

    nextHandler() {
        if (this.currentPage < this.totalPage) {
            this.currentPage = this.currentPage + 1;
            this.setRecordsShown();
            this.updateRecords();
        }
    }

    setRecordsShown() {
        this.recordsShown =
            this.totalRecords.length > this.recordSize * this.currentPage
                ? this.currentPage -
                  1 +
                  "1 to " +
                  this.recordSize * this.currentPage
                : this.currentPage - 1 + "1 to " + this.totalRecords.length;
    }

    updateRecords() {
        const start = (this.currentPage - 1) * this.recordSize;
        const end = this.recordSize * this.currentPage;
        this.visibleRecords = this.totalRecords.slice(start, end);
        this.dispatchEvent(
            new CustomEvent("update", {
                detail: {
                    records: this.visibleRecords,
                },
            })
        );
    }
}