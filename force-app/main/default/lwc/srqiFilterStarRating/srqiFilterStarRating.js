/**
 * @author Rami Zuhairi
 * @date: 17-09-2022
 * @objects: Reporting_Period__c , BusinessLicense, STAR_Rating_History__c
 * @description: LWC custom type Datatable and smart search functionality that will help the user to display the data from STAR_Rating_History__c
 * It allows the user to Filter based on quarter or Status
 * Clear filter
 */
import {LightningElement} from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import searchStarRatingHistories from '@salesforce/apex/srqiSearchStarRating.searchStarRatingHistories';
import getFilterValuesAndDefaultSearchResults
    from '@salesforce/apex/srqiSearchStarRating.getFilterValuesAndDefaultSearchResults';
import srqiStyles from '@salesforce/resourceUrl/srqi_styles';
import {loadStyle} from "lightning/platformResourceLoader";

let cssLoaded = false;

export default class srqiFilterStarRating extends LightningElement {
    reportingPeriodOptions = [];
    statusOptions = [];
    ratingTypeOptions = [];
    ratingOptions = [];
    selectedReportingPeriods = [];
    selectedStatuses = [];
    selectedRatingTypes = [];
    selectedRatings = [];
    serviceNamesOrIds;
    isLoading = false;

    updateSelectedFilterValues(contextVariableName, newSelectedValues) {
        this[contextVariableName] = [];
        for (const option of newSelectedValues) {
            this[contextVariableName].push(option.value);
        }
    }

    handleFilterValueChange(event) {
        switch (event.target.name) {
            case "reportingPeriod":
                this.updateSelectedFilterValues('selectedReportingPeriods', event.detail);
                break;
            case "status":
                this.updateSelectedFilterValues('selectedStatuses', event.detail);
                break;
            case "ratingType":
                this.updateSelectedFilterValues('selectedRatingTypes', event.detail);
                break;
            case "rating":
                this.updateSelectedFilterValues('selectedRatings', event.detail);
                break;
            case "serviceNamesOrIds":
                this.serviceNamesOrIds = event.detail.value;
                break;
        }
    }

    populateFilterOptions(filter, values) {
        if (values) {
            for (const value of values) {
                filter.push({
                    label: value,
                    value: value
                });
            }
        }
    }

    async connectedCallback() {
        this.isLoading = true;
        try {
            const result = await getFilterValuesAndDefaultSearchResults({});
            this.populateFilterOptions(this.reportingPeriodOptions, result.reportingPeriods);
            this.populateFilterOptions(this.statusOptions, result.statuses);
            this.populateFilterOptions(this.ratingTypeOptions, result.ratingTypes);
            this.populateFilterOptions(this.ratingOptions, result.ratings);
            this.template.querySelector('c-srqi-search-data-table-star-rating').formatDataTable(result.defaultSearchResults);
            // For init load, set default quarter filter
            if (this.reportingPeriodOptions.length > 0) {
                this.template.querySelector('c-multi-select-combobox[data-id="reportingPeriodCombobox"]').setSelectedItem(this.reportingPeriodOptions[0]);
            }
        } catch (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: error?.body?.message,
                    variant: 'error',
                    mode: 'sticky',
                })
            );
        } finally {
            this.isLoading = false;
        }
    }

    async handleFilterClick() {
        this.isLoading = true;
        try {
            const result = await searchStarRatingHistories({
                searchConfig: {
                    reportingPeriods: this.selectedReportingPeriods,
                    statuses: this.selectedStatuses,
                    ratingTypes: this.selectedRatingTypes,
                    ratings: this.selectedRatings,
                    serviceNamesOrIds: this.serviceNamesOrIds
                }
            });
            this.template.querySelector('c-srqi-search-data-table-star-rating').formatDataTable(result);
        } catch (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: error?.body?.message,
                    variant: 'error',
                    mode: 'sticky',
                }),
            );
        } finally {
            this.isLoading = false;
        }
    }

    handleClearClick() {
        this.template.querySelectorAll('c-multi-select-combobox').forEach(element => element.reset());
        this.template.querySelector('lightning-input[data-name="searchBox"]').value = null;
        this.selectedReportingPeriods = [];
        this.selectedStatuses = [];
        this.selectedRatingTypes = [];
        this.selectedRatings = [];
        this.serviceNamesOrIds = '';
        this.handleFilterClick();
    }

    renderedCallback() {
        if (!cssLoaded) {
            loadStyle(this, srqiStyles + '/portal.css');
            cssLoaded = true;
        }
    }
}