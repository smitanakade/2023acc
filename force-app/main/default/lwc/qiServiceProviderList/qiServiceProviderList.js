/**
 * @author Sharevreet Singh
 * @date  01/03/2023
 * @description LWC custom type Datatable to show filtered services based on the search
 */
import { api, LightningElement, wire, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { refreshApex } from "@salesforce/apex";
import getRecordsDataTableListFilterSearch from "@salesforce/apex/QIServiceProviderController.getRecordsDataTableListFilterSearch";
import createQISRelatedRecords from "@salesforce/apex/QIServiceProviderController.createQISRelatedRecords";

import getCurrentRP from "@salesforce/apex/QIServiceProviderController.getCurrentRP";
import getPreviousRP from "@salesforce/apex/QIServiceProviderController.getPreviousRP";
import areServicesOffline from "@salesforce/apex/QIServiceProviderController.areServicesOffline";
import areServicesOfflinePRP from "@salesforce/apex/QIServiceProviderController.areServicesOfflinePRP";
import areServicesOperational from "@salesforce/apex/QIServiceProviderController.areServicesOperational";
import areServicesOperationalPRP from "@salesforce/apex/QIServiceProviderController.areServicesOperationalPRP";
import { CurrentPageReference, NavigationMixin } from "lightning/navigation";
import Id from "@salesforce/user/Id";

const columns = [
  {
    label: "Service ID",
    fieldName: "Oracle_Service_ID__c",
    sortable: "true",
    initialWidth: 110
  },
  {
    label: "Service name",
    fieldName: "Name",
    sortable: "true"
  },
  {
    label: "Address",
    fieldName: "Address",
    sortable: "true",
    initialWidth: 300
  },
  {
    label: "Period ending",
    fieldName: "End_Date__c",
    sortable: "true",
    initialWidth: 130
  },
  {
    label: "Due date",
    fieldName: "dueDate",
    sortable: "true",
    initialWidth: 130
  },
  {
    label: "Status",
    fieldName: "Status__c",
    initialWidth: 130,
    type: "qiPillCustomButton",
    typeAttributes: {
      buttonStatus: { fieldName: "Status__c" },
      submittedDate: { fieldName: "submissionDate" },
      buttonStyle: { fieldName: "statusColor" }
    }
  },
  {
    label: "",
    fieldName: "Id",
    initialWidth: 130,
    type: "buttonColumn",
    typeAttributes: {
      buttonName: { fieldName: "btnTitle" },
      recordData: { fieldName: "serviceIDAndRPEndDate" },
      reportingPeriodId: { fieldName: "reportingPId" }
    }
  }
];

export default class qiServiceProviderList extends NavigationMixin(
  LightningElement
) {
  @api itemsNumber;
  dataTableColumns = columns;
  dataTable;
  visibleDataTable;
  queryValueSearchContent;
  sortedBy;
  sortedDirection;
  btnClickFlag = false;
  todayDate;
  queryPerEnding = [];
  querySearchStatus = [];
  searchServNameOrId = "";
  providerIdByBusLicId = {};
  sarIdByBusLicId = {};
  // Assumption: Concatenation of Service ID and QIS Reporting Period End Date will be unique for each row
  qisIdByServiceIdAndRPEndDate = new Map();
  rpEndDate;
  rpDueDate;
  rpEndDateP;
  rpDueDateP;
  currentRP;
  previousRP;
  currentRPId;
  previousRPId;
  serviceIds = [];
  serviceMapOff = new Map();
  serviceMapOffPRP = new Map();
  serviceMapOpr = new Map();
  serviceMapOprPRP= new Map();
  userId = Id;
  sortedData = [];
  wiredResponse;
  @track showSpinner = false;

  //Get CurrentPageReference
  @wire(CurrentPageReference)
  pageRef;

  async connectedCallback() {
    this.currentRP = await getCurrentRP();
    this.previousRP = await getPreviousRP();
    this.rpEndDate = this.currentRP.End_Date__c;
    this.rpDueDate = this.currentRP.QI_Submission_Due_Dt__c;
    this.currentRPId=this.currentRP.Id;
    this.rpEndDateP = this.previousRP.End_Date__c;
    this.rpDueDateP = this.previousRP.QI_Submission_Due_Dt__c;
    this.previousRPId=this.previousRP.Id;
    refreshApex(this.wiredResponse);
  }

  /**
   * Show datatable result based on search queries
   * @param {*} querySearchStatus
   * @param {*} queryPerEnding
   * @param {*} searchServNameOrId
   */
  @api
  handleFilterSearch(querySearchStatus, queryPerEnding, searchServNameOrId) {
    this.queryPerEnding = queryPerEnding !== undefined ? queryPerEnding : [];
    this.querySearchStatus =
      querySearchStatus !== undefined ? querySearchStatus : [];
    this.searchServNameOrId =
      searchServNameOrId !== undefined ? searchServNameOrId : "";
    this.itemsNumber = 0;
    this.showSpinner = !this.showSpinner;
    getRecordsDataTableListFilterSearch({
      searchPeriodEnding: this.queryPerEnding,
      searchStatus: this.querySearchStatus,
      searchServNameOrId: this.searchServNameOrId,
      userId: Id
    })
      .then((result) => {
        this.showSpinner = !this.showSpinner;
        this.dataTable='';
      this.formatDataTable(result); 
        if (this.dataTable === null) {
          this.dispatchEvent(
            new ShowToastEvent({
              title: "No Data!!",
              message: "No data available for selected filter! try again",
              variant: "warning",
              mode: "pester"
            })
          );
        }
      })
      .catch((error) => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error!!",
            message: error?.body?.message,
            variant: "error",
            mode: "pester"
          })
        );
      });
  }
  handleButtonMethod(event) {
    this.viewRecordDetails(event.detail.recordData, event.detail.reportingPeriodId);
  }

  /**
   * call apex method to get data for datatable
   * @param {*} param0
   */
  @wire(getRecordsDataTableListFilterSearch, {
    searchPeriodEnding: [],
    searchStatus: [],
    searchServNameOrId: "",
    userId: Id
  })
  async wiredRecordsDataTable(result) {
    this.wiredResponse = result;
    const { error, data } = result;
    if (data) {
      data.forEach((record) => {
        this.serviceIds.push(record.Id);
      });

      const response = await areServicesOffline({
        serviceIds: this.serviceIds
      });
      this.serviceMapOff = new Map(Object.entries(response));

      const responseOffPRP = await areServicesOfflinePRP({
        serviceIds: this.serviceIds
      });
      this.serviceMapOffPRP = new Map(Object.entries(responseOffPRP));

      const reponseOperational = await areServicesOperational({
        serviceIds: this.serviceIds
      });
      this.serviceMapOpr = new Map(Object.entries(reponseOperational));

      const reponseOperationalPRP = await areServicesOperationalPRP({
        serviceIds: this.serviceIds
      });
      this.serviceMapOprPRP = new Map(Object.entries(reponseOperationalPRP));

      this.itemsNumber = 0;
      this.formatDataTable(data);
    } else if (error) {
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Error!!",
          message: error?.body?.message,
          variant: "error",
          mode: "pester"
        })
      );
    }
  }

  containsStatusValue(value) {
    return [...this.querySearchStatus.values()].includes(value);
  }
  containsPrEndingValue(value) {
    return [...this.queryPerEnding.values()].includes(value);
  }

  containsStatusANDRepValue(value1, value2) {
    if ([...this.querySearchStatus.values()].includes(value1)) {
      if ([...this.queryPerEnding.values()].includes(value2)) {
        return true;
      }
    }
  }

  /**
   * formatting the data coming from wire to be able to use parent records in the datatable
   * @param {*} result
   */
  formatDataTable(result) {
    this.itemsNumber = 0;
    const dataRefer = [];
    this.dataTable='';
    result.forEach((record) => {
      let isQISCurrent=false;
      let isQISPrevious=false;
      if (record.Quality_Indicator_Summary__r) {
        record.Quality_Indicator_Summary__r.forEach((qiRec) => {
          if(qiRec.REPORTING_PERIOD__r.Current_Reporting_Period__c===true){
            isQISCurrent=true;
          }
          else if(qiRec.REPORTING_PERIOD__r.Previous_Reporting_Period__c===true){
            isQISPrevious=true;
          }
          const preparedData = {};
          this.itemsNumber = this.itemsNumber + 1;
          preparedData.Id = record.Id;
          this.providerIdByBusLicId[record.Oracle_Service_ID__c] =
            record.AccountId;

          preparedData.Oracle_Service_ID__c = record.Oracle_Service_ID__c;
          preparedData.Name = record.Name;

          if (
            record.Physical_Address_Location__r &&
            record.Physical_Address_Location__r.Address__r
          ) {
            preparedData.Address =
              record.Physical_Address_Location__r.Address__r.Full_Street__c !==
              undefined
                ? record.Physical_Address_Location__r.Address__r.Full_Street__c
                : "";

            preparedData.Address +=
              record.Physical_Address_Location__r.Address__r.City__c !==
              undefined
                ? ", " + record.Physical_Address_Location__r.Address__r.City__c
                : "";

            preparedData.Address +=
              record.Physical_Address_Location__r.Address__r
                .State_Province__c !== undefined
                ? ", " +
                  record.Physical_Address_Location__r.Address__r
                    .State_Province__c
                : "";

            preparedData.Address +=
              record.Physical_Address_Location__r.Address__r.Country__c !==
              undefined
                ? ", " +
                  record.Physical_Address_Location__r.Address__r.Country__c
                : "";

            preparedData.Address +=
              record.Physical_Address_Location__r.Address__r
                .Zip_Postal_Code__c !== undefined
                ? ", " +
                  record.Physical_Address_Location__r.Address__r
                    .Zip_Postal_Code__c
                : "";
          }
          let reportingPeriod = null;
          if (record.Service_Account_Relationships__r) {
            this.sarIdByBusLicId[record.Oracle_Service_ID__c] =
              record.Service_Account_Relationships__r[0].Id;
          }
          preparedData.serviceIDAndRPEndDate = record.Id + this.formatDateddmmyyyy(qiRec.REPORTING_PERIOD__r.End_Date__c);
          this.qisIdByServiceIdAndRPEndDate.set(preparedData.serviceIDAndRPEndDate, qiRec.Id);
          preparedData.submissionDate = this.formatDatedddMonthYear(
            qiRec.Submission_Date_Time__c
          );
          reportingPeriod = qiRec.REPORTING_PERIOD__r;
          if (reportingPeriod) {
            preparedData.End_Date__c = this.formatDateddmmyyyy(
              reportingPeriod.End_Date__c
            );
            preparedData.dueDate = this.formatDateddmmyyyy(
              reportingPeriod.QI_Submission_Due_Dt__c
            );
          }
          this.prepData(
            dataRefer,
            qiRec,
            reportingPeriod,
            preparedData,
            record,
            null
          );
        });
      }
      if(isQISCurrent===false){
        this.prepDataNoQIS(record, dataRefer, this.currentRP);
      }
      if(isQISPrevious===false){
        this.prepDataNoQIS(record, dataRefer, this.previousRP);
      }
     });
    this.dataTable = this.sortData(dataRefer);
  }

 /**
   * prep data
   * dataRefer, qiRec, reportingPeriod, preparedData, record, endDate
   * @param {*} dataRefer
   */

 prepDataNoQIS(record, dataRefer, reportingPeriod){
  const preparedData = {};
        this.itemsNumber = this.itemsNumber + 1;
        preparedData.Id = record.Id;
        this.providerIdByBusLicId[record.Oracle_Service_ID__c] =
          record.AccountId;
        preparedData.Oracle_Service_ID__c = record.Oracle_Service_ID__c;
        preparedData.Name = record.Name;

        if (
          record.Physical_Address_Location__r &&
          record.Physical_Address_Location__r.Address__r
        ) {
          preparedData.Address =
            record.Physical_Address_Location__r.Address__r.Full_Street__c !==
            undefined
              ? record.Physical_Address_Location__r.Address__r.Full_Street__c
              : "";

          preparedData.Address +=
            record.Physical_Address_Location__r.Address__r.City__c !== undefined
              ? ", " + record.Physical_Address_Location__r.Address__r.City__c
              : "";

          preparedData.Address +=
            record.Physical_Address_Location__r.Address__r.State_Province__c !==
            undefined
              ? ", " +
                record.Physical_Address_Location__r.Address__r.State_Province__c
              : "";

          preparedData.Address +=
            record.Physical_Address_Location__r.Address__r.Country__c !==
            undefined
              ? ", " + record.Physical_Address_Location__r.Address__r.Country__c
              : "";

          preparedData.Address +=
            record.Physical_Address_Location__r.Address__r
              .Zip_Postal_Code__c !== undefined
              ? ", " +
                record.Physical_Address_Location__r.Address__r
                  .Zip_Postal_Code__c
              : "";
        }
        let qiSummary;
        if (record.Service_Account_Relationships__r) {
          this.sarIdByBusLicId[record.Oracle_Service_ID__c] =
            record.Service_Account_Relationships__r[0].Id;
        }
        this.prepData(
          dataRefer,
          qiSummary,
          reportingPeriod,
          preparedData,
          record,
          null
        );
 }
  /**
   * prep data
   * dataRefer, qiRec, reportingPeriod, preparedData, record, endDate
   * @param {*} dataRefer
   */
  prepData(dataRefer, qiRec, reportingPeriod, preparedData, record, endDate) {
    this.setStatusAndBtnTitle(qiRec, reportingPeriod, preparedData, record);
    if (
      this.queryPerEnding.length === 0 &&
      this.querySearchStatus.length === 0 &&
      preparedData.Status__c !== undefined
    ) {
      dataRefer.push(preparedData);
    } else {
      let reportDate;
      reportDate = endDate !== null ? endDate : reportingPeriod.End_Date__c;
      if (preparedData.Status__c !== undefined) {
        if (
          this.querySearchStatus.length > 0 &&
          this.queryPerEnding.length > 0 &&
          this.containsStatusANDRepValue(preparedData.Status__c, reportDate)
        ) {
          dataRefer.push(preparedData);
        } else if (
          this.querySearchStatus.length > 0 &&
          this.queryPerEnding.length === 0 &&
          this.containsStatusValue(preparedData.Status__c)
        ) {
          dataRefer.push(preparedData);
        } else if (
          this.queryPerEnding.length > 0 &&
          this.querySearchStatus.length === 0 &&
          this.containsPrEndingValue(reportDate)
        ) {
          dataRefer.push(preparedData);
        }
      }
    }
    preparedData.statuscolor =
      "border-radius: 10rem; position: absolute; margin-left: 20px; vertical-align: middle; margin-top: 0.8em; padding-left: 25px; width:120px;line-height: 14px;";
    preparedData.statusColor = "";
    switch (preparedData.Status__c) {
      case "Not Started":
        preparedData.statuscolor += "background:#00546E;color:#FFFFFF; ";
        preparedData.statusColor += "background:#00546E;color:#FFFFFF; ";

        break;
      case "In Progress":
        preparedData.statuscolor += "background:#FFA400;color:#000000;";
        preparedData.statusColor += "background:#FFA400;color:#000000;";
        break;
      case "Submitted":
        preparedData.statuscolor += "background:#216515;color:#FFFFFF;";
        preparedData.statusColor += "background:#216515;color:#FFFFFF;";
        break;
      case "Not Submitted":
        preparedData.statuscolor += "background:#E91E63;color:#000000;";
        preparedData.statusColor += "background:#E91E63;color:#000000;";
        break;
      case "Submitted - Updated After Due Date":
        preparedData.statuscolor += "background:#FFF6E6;color:#4D8144;";
        preparedData.statusColor += "background:#FFF6E6;color:#4D8144;";
        preparedData.statusColor += "height:44px;";
        break;
      case "Late Submission":
        preparedData.statuscolor += "background:#EEEEEE;color:#000000;";
        preparedData.statusColor += "background:#EEEEEE;color:#000000;";
        preparedData.statusColor += "height:44px;";
        break;
      case "Offline":
        //preparedData.statuscolor += "background:#EEEEEE; color:#FFFFFF;";
        preparedData.statusColor += "background:#333333;color:#FFFFFF;";
        preparedData.isDisabled = true;
        break;
      default:
        break;
    }
  }

  /**
   * sort the data based on status
   * Not started should be at top
   * @param {*} dataRefer
   */
  sortData(dataRefer) {
    const orderOfStatuses = {
      "Not Started": 1,
      "Not Submitted": 2,
      "In Progress": 3,
      "Late Submission": 4,
      "Submitted - Updated After Due Date": 5,
      Submitted: 6,
      Offline: 7
    };
    this.sortedData = [...dataRefer];
    this.sortedData.sort((a, b) =>
      orderOfStatuses[a.Status__c] > orderOfStatuses[b.Status__c] ? 1 : -1
    );
    return [...this.sortedData];
  }

  onlyNumbers(str) {
    return /^[0-9]+$/.test(str);
  }

  /**
   * Set sortedBy and sortedDirection
   * @param {*} event
   */
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
      return isReverseOrder * ((as > des) - (des > as));
    });
    this.dataTable = '';
    this.dataTable = parseData;
  }

  updateDataTableHandler(event) {
    this.visibleDataTable = [...event.detail.records];
  }

  /**
   * Dynamically set Status and Button Title on datatable
   * @param {*} qiSummary
   * @param {*} reportingPeriod
   * @param {*} preparedData
   */
  setStatusAndBtnTitle(
    qiSummary,
    reportingPeriod,
    preparedData,
    serviceRecord
  ) {
    preparedData.reportingPId=reportingPeriod.Id;
    if (qiSummary) {
      preparedData.Status__c = qiSummary.Status__c;
      if (qiSummary.Status__c === "Offline") {
        preparedData.btnTitle = "Offline";
      } else if (qiSummary.Status__c === "Not Started") {
        if (
          reportingPeriod &&
          (reportingPeriod.Current_Reporting_Period__c ||
            reportingPeriod.Previous_Reporting_Period__c)
        ) {
          preparedData.btnTitle = "Start";
        }
      } else if (qiSummary.Status__c === "In Progress") {
        if (
          reportingPeriod &&
          (reportingPeriod.Current_Reporting_Period__c ||
            reportingPeriod.Previous_Reporting_Period__c)
        ) {
          preparedData.btnTitle = "Continue";
        }
      } else if (qiSummary.Status__c === "Not Submitted") {
        if (
          reportingPeriod &&
          (reportingPeriod.Current_Reporting_Period__c ||
            reportingPeriod.Previous_Reporting_Period__c)
        ) {
          preparedData.btnTitle = "Amend";
        } else {
          preparedData.btnTitle = "View";
        }
      } else if (qiSummary.Status__c === "Submitted") {
        if (
          reportingPeriod &&
          (reportingPeriod.Current_Reporting_Period__c ||
            reportingPeriod.Previous_Reporting_Period__c)
        ) {
          preparedData.btnTitle = "Amend";
        } else {
          preparedData.btnTitle = "View";
        }
      } else if (qiSummary.Status__c === "Updated After Due Date") {
        preparedData.Status__c = "Submitted - Updated After Due Date";
        if (
          reportingPeriod &&
          (reportingPeriod.Current_Reporting_Period__c ||
            reportingPeriod.Previous_Reporting_Period__c)
        ) {
          preparedData.btnTitle = "Amend";
        } else {
          preparedData.btnTitle = "View";
        }
      } else if (qiSummary.Status__c === "Late Submission") {
        if (
          reportingPeriod &&
          (reportingPeriod.Current_Reporting_Period__c ||
            reportingPeriod.Previous_Reporting_Period__c)
        ) {
          preparedData.btnTitle = "Amend";
        } else {
          preparedData.btnTitle = "View";
        }
      }
    } else {
      if(reportingPeriod.Current_Reporting_Period__c){
        if (serviceRecord.Status__c === "Offline") {
            const isServiceOff = this.serviceMapOff.get(serviceRecord.Id);
            if (isServiceOff) {
              preparedData.Status__c = "Offline";
              preparedData.btnTitle = "Offline";
              preparedData.End_Date__c = this.formatDateddmmyyyy(reportingPeriod.End_Date__c);
              preparedData.dueDate = this.formatDateddmmyyyy(reportingPeriod.QI_Submission_Due_Dt__c);
            }
            else{
                preparedData.Status__c = "Not Started";
                preparedData.btnTitle = "Start";
                preparedData.End_Date__c = this.formatDateddmmyyyy(reportingPeriod.End_Date__c);
                preparedData.dueDate = this.formatDateddmmyyyy(reportingPeriod.QI_Submission_Due_Dt__c);
            }
        }
        else{
                preparedData.Status__c = "Not Started";
                preparedData.btnTitle = "Start";
                preparedData.End_Date__c = this.formatDateddmmyyyy(reportingPeriod.End_Date__c);
                preparedData.dueDate = this.formatDateddmmyyyy(reportingPeriod.QI_Submission_Due_Dt__c);
        }
      }
      else if(reportingPeriod.Previous_Reporting_Period__c){
              const isServiceOffPRP = this.serviceMapOffPRP.get(serviceRecord.Id);
              if (isServiceOffPRP) {
                preparedData.Status__c = "Offline";
                preparedData.btnTitle = "Offline";
                preparedData.End_Date__c = this.formatDateddmmyyyy(reportingPeriod.End_Date__c);
                preparedData.dueDate = this.formatDateddmmyyyy(reportingPeriod.QI_Submission_Due_Dt__c);
              }
              else{
                preparedData.Status__c = "Not Started";
                preparedData.btnTitle = "Start";
                preparedData.End_Date__c = this.formatDateddmmyyyy(reportingPeriod.End_Date__c);
                preparedData.dueDate = this.formatDateddmmyyyy(reportingPeriod.QI_Submission_Due_Dt__c);
              }
      }
    }
  }

  /**
   * Action of button click on datatable
   * @param {*} event
   */

  viewRecordDetails(serviceIDAndRPEndDate, reportingPeriodId) {
    const row = this.visibleDataTable.find((item) => item.serviceIDAndRPEndDate === serviceIDAndRPEndDate);
    if (row.btnTitle === "Start" && !this.btnClickFlag) {
      this.btnClickFlag = true;
      createQISRelatedRecords({
        busLicId: row.Id,
        providerId: this.providerIdByBusLicId[row.Oracle_Service_ID__c],
        sarId: this.sarIdByBusLicId[row.Oracle_Service_ID__c],
        reportingPId:reportingPeriodId
      })
        .then((result) => {
          this.navigateToQISPage(result, row);
        })
        .catch((error) => {
          this.dispatchEvent(
            new ShowToastEvent({
              title: "Error!!",
              message: error?.body?.message,
              variant: "error",
              mode: "pester"
            })
          );
        });
    }

    if (
      row.btnTitle === "View" ||
      row.btnTitle === "Amend" ||
      row.btnTitle === "Continue"
    ) {
      this.navigateToQISPage(this.qisIdByServiceIdAndRPEndDate.get(row.serviceIDAndRPEndDate), row);
    }
  }

  /**
   * Navigate to a specific community page and send QISummary Id.
   * @param {*} qisId - QISummary Id
   */
  navigateToQISPage(qisId, row) {
    if (qisId) {
      this[NavigationMixin.Navigate](
        {
          type: "comm__namedPage",
          attributes: {
            name: "Quality_Indicator_Summary__c"
          },
          state: {
            qisid: qisId,
            sproviderId: row.Oracle_Service_ID__c,
            status: row.Status__c
          }
        },
        true
      );
    } else {
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Quality Indicator View!!",
          message:
            "Opps!, Can not view at the moment,  Please navigate from the navigation bar",
          variant: "info",
          mode: "pester"
        })
      );
    }
  }

  formatDateddmmyyyy(date) {
    if (!date) {
      return null;
    }

    const day = date.substring(date.lastIndexOf("-") + 1, date.length);
    const month = date.substring(date.indexOf("-") + 1, date.lastIndexOf("-"));
    const year = date.substring(0, date.indexOf("-"));
    return day + "/" + month + "/" + year;
  }

  formatDatedddMonthYear(date) {
    if (!date) {
      return null;
    }
    const dtf = new Intl.DateTimeFormat("en-AU", {
      year: "numeric",
      month: "short",
      day: "2-digit"
    });
    return dtf.format(new Date(Date.parse(date)));
  }
}