/**
 * @author Rami Zuhairi
 * @date 17-09-2022
 * @objects Reporting_Period_Short__c, BusinessLicense, STAR_Rating_History__c
 * @description Apex class that will query through STAR_Rating_History__c and get the required data
 * @testClass SrqiSearchStarRatingTest
 */
public with sharing class srqiSearchStarRating {
    private static final String LABEL_NO_RATING_AVAILABLE = 'No rating available';

    /**
     * Returns a map of filter values and default search results.
     * The method queries the Salesforce database to retrieve service rating data and
     * aggregates them to create filter values and default search results. It populates
     * sets of reporting periods, statuses, rating types, and ratings, as well as a
     * list of sorted ratings, and a map of latest rating history records by service ID.
     * @return a map of filter values and default search results.
     */
    @AuraEnabled
    public static Map<String, Object> getFilterValuesAndDefaultSearchResults() {

        Set<String> reportingPeriods = new Set<String>();
        Set<String> statuses = new Set<String>();
        Set<String> ratingTypes = new Set<String>();
        Set<String> ratings = new Set<String>();
        List<String> sortedRatings = new List<String>();
        Id mostRecentReportingPeriodId;

        List<STAR_Rating_History__c> srhListOfMostRecentReportingPeriod = new List<STAR_Rating_History__c>();

        try {
            Set<Id> sarIds = new Map<Id, Service_Account_Relationship__c>(
                SRProviderPortalUtil.getServiceAccountRelationships()
            ).keySet();

            if (!sarIds.isEmpty()) {
                for (STAR_Rating_History__c srh : [
                    SELECT
                        Id,
                        SF_Service_Id__c,
                        Rating_Type__c,
                        Status__c,
                        Rating_Calc_Date__c,
                        STAR_Rating_Calculation__c,
                        Provider_Portal_Status__c,
                        STAR_Rating__c,
                        Go_Live_Date__c,
                        Under_Review__c,
                        ProviderPortal_RatingType__c,
                        SF_Service_Id__r.Name,
                        SF_Service_Id__r.Integration_ID__c,
                        Reporting_Period__r.Reporting_Period_Short__c,
                        Reporting_Period__r.Start_Date__c,
                        Reporting_Period__c
                    FROM STAR_Rating_History__c
                    WHERE Reporting_Period__r.Reporting_Period_Short__c != NULL
                    AND Service_Account_Relationship__c IN :sarIds
                    AND Status__c NOT IN ('Removed', 'Draft', NULL )
                    AND (CreatedDate > LAST_N_YEARS:3 OR Go_Live_Date__c > LAST_N_YEARS:3)
                    ORDER BY Reporting_Period__r.Start_Date__c DESC //We need to get mostRecentReportingPeriodId
                ]) {
                    if (mostRecentReportingPeriodId == null) {
                        mostRecentReportingPeriodId = srh.Reporting_Period__c;
                    }
                    reportingPeriods.add(srh.Reporting_Period__r.Reporting_Period_Short__c);
                    statuses.add(srh.Provider_Portal_Status__c);
                    ratingTypes.add(srh.ProviderPortal_RatingType__c);
                    ratings.add(isNoDataAvailable(srh.STAR_Rating_Calculation__c));
                    if (srh.Reporting_Period__c == mostRecentReportingPeriodId) {
                        srhListOfMostRecentReportingPeriod.add(srh);
                    }
                }
                sortRating(ratings, sortedRatings);
                srhListOfMostRecentReportingPeriod = getSortedRecords(srhListOfMostRecentReportingPeriod);
            }
        } catch (Exception exp) {
            dohagedcare.Logger.error(exp.getMessage(), exp, 'QISR').log();
            throw new AuraHandledException(
                'Error in getting filter values and default search results. Please try again or contact system administrator.'
            );
        }

        return new Map<String, Object>{
            'reportingPeriods' => reportingPeriods,
            'statuses' => statuses,
            'ratingTypes' => ratingTypes,
            'ratings' => sortedRatings,
            'defaultSearchResults' => srhListOfMostRecentReportingPeriod
        };
    }

    /**
     * This method searches for Star Rating History records based on the provided SearchConfig object.
     * The method constructs a dynamic SOQL query based on the search criteria in the SearchConfig object,
     * executes the query and returns a list of STAR_Rating_History__c objects that match the search criteria.
     * @param searchConfig the SearchConfig object containing the search criteria
     * @return a list of STAR_Rating_History__c objects that match the search criteria
     */
    @AuraEnabled
    public static List<STAR_Rating_History__c> searchStarRatingHistories(SearchConfig searchConfig) {
        try {
            String soqlQuery = '';
            soqlQuery += 'SELECT Id, SF_Service_Id__c, Rating_Type__c, Status__c, Rating_Calc_Date__c, Under_Review__c, Provider_Portal_Status__c, ProviderPortal_RatingType__c, ';
            soqlQuery += 'STAR_Rating__c, STAR_Rating_Calculation__c, Go_Live_Date__c, SF_Service_Id__r.Name, SF_Service_Id__r.Integration_ID__c, ';
            soqlQuery += 'Reporting_Period__r.Reporting_Period_Short__c, Reporting_Period__r.Start_Date__c ';
            soqlQuery += 'FROM STAR_Rating_History__c ';
            soqlQuery += 'WHERE ';
            soqlQuery += 'SF_Service_Id__r.Name != NULL AND Status__c NOT IN (\'Removed\', \'Draft\', NULL) AND ';
            soqlQuery += 'Reporting_Period__r.Reporting_Period_Short__c != NULL AND ';
            soqlQuery += '(CreatedDate > LAST_N_YEARS:3 OR Go_Live_Date__c > LAST_N_YEARS:3) AND ';
            soqlQuery += 'Service_Account_Relationship__c IN ' + SRProviderPortalUtil.getSARIdsString();

            if (!searchConfig.statuses.isEmpty()) {
                soqlQuery += ' AND Provider_Portal_Status__c IN ' + getValuesInJointString(searchConfig.statuses, true);
            }

            if (!searchConfig.reportingPeriods.isEmpty()) {
                soqlQuery += ' AND Reporting_Period__r.Reporting_Period_Short__c IN ' + getValuesInJointString(searchConfig.reportingPeriods, true);
            }

            if (!searchConfig.ratingTypes.isEmpty()) {
                soqlQuery += ' AND ProviderPortal_RatingType__c IN ' + getValuesInJointString(searchConfig.ratingTypes, true);
            }

            if (!searchConfig.ratings.isEmpty()) {
                soqlQuery += ' AND STAR_Rating_Calculation__c IN ' + replaceNoDataAvailableSearchOptionToRatings(
                    getValuesInJointString(searchConfig.ratings, false)
                );
            }

            if (String.isNotBlank(searchConfig.serviceNamesOrIds)) {
                List<String> validSearchTerms = getValidSearchTerms(searchConfig.serviceNamesOrIds);
                soqlQuery += ' AND (';
                for (Integer i = 0; i < validSearchTerms.size(); i++) {
                    String searchTerm = validSearchTerms[i];
                    soqlQuery += ' (';
                    soqlQuery +=
                        'SF_Service_Id__r.Integration_ID__c LIKE \'%' +
                        String.escapeSingleQuotes(searchTerm) +
                        '%\' ';
                    soqlQuery +=
                        'OR SF_Service_Id__r.Name LIKE \'%' +
                        String.escapeSingleQuotes(searchTerm) +
                        '%\' ';
                    soqlQuery += ') ';
                    if (validSearchTerms.size() > 1 && i < validSearchTerms.size() - 1) {
                        soqlQuery += ' OR ';
                    }
                }
                soqlQuery += ') ';
            }

            return getSortedRecords(Database.query(soqlQuery));
        } catch (Exception ex) {
            dohagedcare.Logger.error(ex.getMessage(), ex, 'QISR').log();
            throw new AuraHandledException(
                'Error in Search! Please try again or contact system administrator.'
            );
        }
    }

    // Get all Service Names from BusinessLicense
    @AuraEnabled(Cacheable=true)
    public static List<BusinessLicense> getServiceNameRecords() {
        List<BusinessLicense> nameServiceNameList;
        try {
            nameServiceNameList = [
                SELECT Id, Integration_ID__c, Name
                FROM BusinessLicense
            ];
        } catch (Exception exp) {
            dohagedcare.Logger.error(exp.getMessage(), exp, 'QISR').log();
            throw new AuraHandledException(
                'Error in getting service names! Please try again or contact system administrator.'
            );
        }
        return nameServiceNameList;
    }

    // Get Service Name ID from BusinessLicense
    @AuraEnabled(Cacheable=true)
    public static Id getServiceNameIDRecord(String serviceName) {
        Id serviceID;
        try {
            serviceID = [
                SELECT Id, Integration_ID__c
                FROM BusinessLicense
                WHERE Name = :serviceName
            ]
                .Id;
        } catch (Exception exp) {
            dohagedcare.Logger.error(exp.getMessage(), exp, 'QISR').log();
            throw new AuraHandledException(
                'Error in getting service ID! Please try again or contact system administrator.'
            );
        }
        return serviceID;
    }

    public class SearchConfig {
        public SearchConfig() {
            this.reportingPeriods = new List<String>();
            this.statuses = new List<String>();
            this.ratingTypes = new List<String>();
            this.ratings = new List<String>();
        }
        @AuraEnabled
        public List<String> reportingPeriods { get; set; }
        @AuraEnabled
        public List<String> statuses { get; set; }
        @AuraEnabled
        public List<String> ratingTypes { get; set; }
        @AuraEnabled
        public List<String> ratings { get; set; }
        @AuraEnabled
        public String serviceNamesOrIds { get; set; }
    }

    private static String isNoDataAvailable(Decimal value) {
        if (value == 0 || value == null) {
            return LABEL_NO_RATING_AVAILABLE;
        } else {
            return String.valueOf(value);
        }
    }

    private static void sortRating(Set<String> ratings, List<String> sortedRatings) {
        if (!ratings.isEmpty()) {
            sortedRatings.addAll(ratings);
            sortedRatings.sort();
        }
    }

    private static String replaceNoDataAvailableSearchOptionToRatings(String ratings) {
        // When rating options from LWC includes 'No rating available', at backend, it can be 0 or NULL
        return ratings.replace(LABEL_NO_RATING_AVAILABLE, '0,NULL');
    }

    /**
     * Returns a formatted String of the values in the given List, with optional wrapping quotes for each value.
     * @param values the List of String values to format
     * @param wrapValueWithQuotes a Boolean flag indicating whether to wrap each value with single quotes
     * @return a formatted String of the values, with parentheses around them
     */
    private static String getValuesInJointString(List<String> values, Boolean wrapValueWithQuotes) {
        for (Integer i = 0; i < values.size(); i++) {
            values[i] = String.escapeSingleQuotes(values[i]);
        }
        String valuesInJointString;
        if (wrapValueWithQuotes) {
            valuesInJointString = '\'' + String.join(values, '\',\'') + '\'';
        } else {
            valuesInJointString = String.join(values, ',') ;
        }
        return '( ' + valuesInJointString + ' )';
    }

    /**
     * Returns a List of valid search terms from the given comma-separated String of search terms.
     * @param searchTerms a comma-separated String of search terms
     * @return a List of valid search terms, with leading/trailing whitespace removed
     */
    private static List<String> getValidSearchTerms(String searchTerms) {
        List<String> terms = searchTerms.split(',');
        List<String> validSearchTerms = new List<String>();
        for (String term : terms) {
            if (!String.isEmpty(term.trim())) {
                validSearchTerms.add(term.trim());
            }
        }
        return validSearchTerms;
    }

    private static List<STAR_Rating_History__c> getSortedRecords(List<STAR_Rating_History__c> records) {
        List<SortableStarRatingHistory> wrappers = new List<SortableStarRatingHistory>();
        for (STAR_Rating_History__c srh : records) {
            wrappers.add(new SortableStarRatingHistory(srh));
        }
        wrappers.sort();

        List<STAR_Rating_History__c> sortedRecords = new List<STAR_Rating_History__c>();
        for (SortableStarRatingHistory wrapper : wrappers) {
            sortedRecords.add(wrapper.record);
        }

        return sortedRecords;
    }

    public with sharing class SortableStarRatingHistory implements Comparable {
        public STAR_Rating_History__c record;
        public Integer ratingTypeOrder;
        public Integer statusOrder;

        public SortableStarRatingHistory(STAR_Rating_History__c record) {
            this.record = record;
            switch on record.Provider_Portal_Status__c {
                when 'Under review' {
                    statusOrder = 1;
                }
                when 'Preview' {
                    statusOrder = 2;
                }
                when 'Publicly available' {
                    statusOrder = 3;
                }
                when else {
                    statusOrder = 4;  // add default case to handle unexpected values
                }
            }
            switch on record.ProviderPortal_RatingType__c {
                when 'New' {
                    ratingTypeOrder = 1;
                }
                when 'Current' {
                    ratingTypeOrder = 2;
                }
                when 'Previous' {
                    ratingTypeOrder = 3;
                }
                when else {
                    ratingTypeOrder = 4;  // add default case to handle unexpected values
                }
            }
        }

        /**
         * This method is used to compare the current SortableStarRatingHistory instance with another instance.
         * The comparison is based on several fields, in the following priority order:
         * 1. Reporting_Period__r.Start_Date__c (Descending)
         * 2. SF_Service_Id__r.Integration_ID__c (Ascending)
         * 3. statusOrder (which is based on Provider_Portal_Status__c: 'Under review' -> 1, 'Preview' -> 2, 'Publicly available' -> 3)
         * 4. ratingTypeOrder (which is based on ProviderPortal_RatingType__c: 'New' -> 1, 'Current' -> 2, 'Previous' -> 3)
         * 5. Go_Live_Date__c (Descending)
         *
         * @param compareTo The Object that this instance should be compared to.
         *        It should be an instance of SortableStarRatingHistory; otherwise a ClassCastException will occur.
         *
         * @return Integer A negative integer if this instance should sort before compareTo,
         *        a positive integer if this instance should sort after compareTo.
         *        The absolute value of the returned integer does not have any specific meaning,
         *        as only the sign of the value (negative, zero, or positive) matters for sorting.
         */
        public Integer compareTo(Object compareTo) {
            SortableStarRatingHistory compareToWrapper = (SortableStarRatingHistory) compareTo;
            // Descending order for Reporting_Period__r.Start_Date__c
            if (record.Reporting_Period__r.Start_Date__c != compareToWrapper.record.Reporting_Period__r.Start_Date__c) {
                return record.Reporting_Period__r.Start_Date__c.daysBetween(compareToWrapper.record.Reporting_Period__r.Start_Date__c) > 0 ? 1 : -1;
            }
            // Ascending order for SF_Service_Id__r.Integration_ID__c
            if (record.SF_Service_Id__r.Integration_ID__c != compareToWrapper.record.SF_Service_Id__r.Integration_ID__c) {
                return record.SF_Service_Id__r.Integration_ID__c > compareToWrapper.record.SF_Service_Id__r.Integration_ID__c ? 1 : -1;
            }

            if (statusOrder != compareToWrapper.statusOrder) {
                return statusOrder > compareToWrapper.statusOrder ? 1 : -1;
            }

            if (ratingTypeOrder != compareToWrapper.ratingTypeOrder) {
                return ratingTypeOrder > compareToWrapper.ratingTypeOrder ? 1 : -1;
            }
            // Descending order for Go_Live_Date__c
            return record.Go_Live_Date__c.daysBetween(compareToWrapper.record.Go_Live_Date__c) > 0 ? 1 : -1;
        }
    }
}