/**
 * @testClass QIFileUploadHistoryControllerTest
 */
public with sharing class QIFileUploadHistoryController {
    /**
     * Account record types that can be linked in the `Provider` field of a File Staging record.
     */
    private static final List<String> ACCOUNT_RECORD_TYPES = new List<String>{
        'Approved_Provider', 
        'Benchmarking_Organisation'
    };

    /**
     * All possible display (user-friendly) status values. 
     * Value is calculated in the field `Display Status` on the File Staging object.
     */
    private static final List<String> DISPLAY_STATUSES = new List<String>{
        'Submitted',
        'Failed',
        'Pending',
        'Partial'
    };

    /**
     * Returns list of current or past reporting period short names
     */
    private static List<String> getReportingPeriodPicklistValues() {
        List<String> reportingPeriodOptions = new List<String>();
        List<Reporting_Period__c> reportingPeriods = [
            SELECT Reporting_Period_Short__c
            FROM Reporting_Period__c
            WHERE Start_Date__c <= TODAY
            AND Reporting_Period_Type__c = 'Quarter'
            ORDER BY Start_Date__c DESC
        ];
        for (Reporting_Period__c reportingPeriod : reportingPeriods) {
            reportingPeriodOptions.add(reportingPeriod.Reporting_Period_Short__c);
        }
        return reportingPeriodOptions;
    }

    /**
     * Returns picklist values for various fields
     */
    @AuraEnabled(cacheable=true)
    public static PicklistValues getPicklistValues() {
        PicklistValues picklistValues = new PicklistValues();
        picklistValues.reportingQuarters = getReportingPeriodPicklistValues();
        picklistValues.statuses = DISPLAY_STATUSES;
        return picklistValues;
    }

    /**
     * Returns all File Staging records visible to the user and meeting given filter criteria
     */
    @AuraEnabled(cacheable=true)
    public static List<FileUploadDetail> getFileUploadHistory(String filterJSON) {
        // Get account that we need to query records for
        Id userId = UserInfo.getUserId();
        Id activeAccountId = getActiveAccountId(userId);

        // Declare bind variables (used depending on whether filters are passed in)
        List<String> reportingQuarters;
        List<String> statuses;

        // Set initial query field and clause strings
        List<String> queryFields = new List<String>{
            'Id', 'CreatedDate', 'Name', 'File_Name__c', 'Reporting_Period__r.Reporting_Period_Short__c',
            'File_CreatedDate__c', 'Total_Records__c', 'Failure_Records__c', 'Success_Records__c', 'Display_Status__c'
        };
        List<String> queryConditions = new List<String>{
            'Provider__c = :activeAccountId'
        };
        String queryOrder = 'CreatedDate DESC';

        // Add query condition strings based on passed in filters
        if (filterJSON != null) {
            QueryFilter filter = (QueryFilter) JSON.deserializeStrict(filterJSON, QueryFilter.class);
            
            if (!String.isEmpty(filter.search)) {
                queryConditions.add('(Name LIKE \'%' + filter.search + '%\' OR File_Name__c LIKE \'%' + filter.search + '%\')');
            }

            if (filter.reportingQuarters != null && !filter.reportingQuarters.isEmpty()) {
                reportingQuarters = filter.reportingQuarters;
                queryConditions.add('Reporting_Period__r.Reporting_Period_Short__c IN :reportingQuarters');
            }

            if (filter.statuses != null && !filter.statuses.isEmpty()) {
                statuses = filter.statuses;
                queryConditions.add('Display_Status__c IN :statuses');
            }
        }

        // Construct query string
        String query = 'SELECT ' + String.join(queryFields, ',') + ' FROM File_Staging__c WHERE ' + String.join(queryConditions, ' AND ') + ' ORDER BY ' + queryOrder;

        // Do query
        List<File_Staging__c> fileStagingRecords = Database.query(query);

        // Return results
        List<FileUploadDetail> fileUploadDetails = new List<FileUploadDetail>();
        for (File_Staging__c fileStagingRecord : fileStagingRecords) {
            fileUploadDetails.add(new FileUploadDetail(fileStagingRecord));
        }
        return fileUploadDetails;
    }

    /**
     * Returns the ID of the account that is currently active for the user.
     */
    public static Id getActiveAccountId(Id userId) {
        Id userContactId = [SELECT ContactId FROM User WHERE Id = :userId LIMIT 1].ContactId;
        return [
            SELECT AccountId
            FROM AccountContactRelation
            WHERE ContactId = :userContactId 
            AND IsActive = TRUE 
            AND Account.RecordType.DeveloperName IN :ACCOUNT_RECORD_TYPES
            LIMIT 1
        ].AccountId;
    }

    /**
     * Used to deserialize search filters passed by LWC as JSON string
     */
    public class QueryFilter {
        public String search;
        public List<String> reportingQuarters;
        public List<String> statuses;
    }

    /**
     * Wrapper class for getting picklist values for use in LWC
     */
    public class PicklistValues {
        @AuraEnabled public List<String> reportingQuarters;
        @AuraEnabled public List<String> statuses;
    }

    /**
     * Wrapper class for the File Staging record. Used to format data for use in LWC
     */
    public class FileUploadDetail {
        @AuraEnabled public Id id;
        @AuraEnabled public DateTime createdDate;
        @AuraEnabled public String uploadId;
        @AuraEnabled public String fileName;
        @AuraEnabled public String reportingQuarter;
        @AuraEnabled public DateTime submittedDate;
        @AuraEnabled public Decimal totalRecords;
        @AuraEnabled public Decimal failureRecords;
        @AuraEnabled public Decimal successRecords;
        @AuraEnabled public String status;

        public FileUploadDetail(File_Staging__c record) {
            this.Id = record.Id;
            this.createdDate = record.CreatedDate;
            this.uploadId = record.Name;
            this.fileName = record.File_Name__c;
            this.reportingQuarter = record.Reporting_Period__r.Reporting_Period_Short__c;
            this.submittedDate = record.File_CreatedDate__c;
            this.totalRecords = record.Total_Records__c;
            this.failureRecords = record.Failure_Records__c;
            this.successRecords = record.Success_Records__c;
            this.status = record.Display_Status__c;
        }
    }
}