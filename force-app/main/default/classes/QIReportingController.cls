/**
 * @author Cyrille
 * @createdDate 03/2023
 */
public with sharing class QIReportingController {
    /**
     *
     */
    @AuraEnabled(cacheable=true)
    public static List<Reporting_Period__c> getReportingQuarters() {
        List<Reporting_Period__c> result = new List<Reporting_Period__c>();
        Map<String, Reporting_Period__c> resultMap = new Map<String, Reporting_Period__c>();

        Integer currentMonth;
        Integer currentYear;

        try {
            //get the current quarter
            for (Reporting_Period__c quarter : [
                SELECT
                    Reporting_Period_Type__c,
                    QI_Submission_Due_Dt__c,
                    Start_Date__c,
                    End_Date__c,
                    Current_Reporting_Period__c,
                    Previous_Reporting_Period__c,
                    Reporting_Period_Short__c
                FROM Reporting_Period__c
                WHERE
                    Reporting_Period_Type__c = 'Quarter'
                    AND QI_Submission_Due_Dt__c != NULL
                    AND Reporting_Period_Short__c != NULL
                    AND (Current_Reporting_Period__c = TRUE
                    OR Previous_Reporting_Period__c = TRUE)
                ORDER BY QI_Submission_Due_Dt__c DESC
            ]) {
                if (quarter.Current_Reporting_Period__c == true) {
                    currentMonth = quarter.Start_Date__c.month();
                    currentYear = quarter.Start_Date__c.year();
                    if (!resultMap.containsKey('' + quarter.Start_Date__c)) {
                        resultMap.put('' + quarter.Start_Date__c, quarter);
                    }
                }
            }

            if (currentMonth == 7) {
                getReportingForQuarter1(currentYear, currentYear + 1, resultMap);
            } else if (currentMonth == 10) {
                getReportingForQuarter2(currentYear + 1, resultMap);
            } else if (currentMonth == 1) {
                getReportingForQuarter3(currentYear, resultMap);
            } else if (currentMonth == 4) {
                getReportingForQuarter4(currentYear, currentYear - 1, resultMap);
            }
        } catch (Exception ex) {
            dohagedcare.Logger.error(ex.getMessage(), ex, 'QI').log();
            throw new AuraHandledException(JSON.serialize(new List<String>{ ex.getMessage() }));
        }

        //sort all based on start date
        if (resultMap.size() > 0) {
            List<String> keys = new List<String>();
            keys.addAll(resultMap.keySet());
            keys.sort();
            for (String key : keys) {
                result.add(resultMap.get(key));
            }
        }

        return result;
    }

    /**
     * If the current quarter starts April 2022, then get the previous 3
     *
     */
    public static void getReportingForQuarter4(Integer currentYear, Integer pastYear, Map<String, Reporting_Period__c> resultMap) {
        for (Reporting_Period__c quarter : [
            SELECT
                Reporting_Period_Type__c,
                QI_Submission_Due_Dt__c,
                Start_Date__c,
                End_Date__c,
                Current_Reporting_Period__c,
                Previous_Reporting_Period__c,
                Reporting_Period_Short__c
            FROM Reporting_Period__c
            WHERE
                Reporting_Period_Type__c = 'Quarter'
                AND QI_Submission_Due_Dt__c != NULL
                AND Reporting_Period_Short__c != NULL
                AND ((CALENDAR_MONTH(Start_Date__c) = 1
                AND CALENDAR_YEAR(Start_Date__c) = :currentYear)
                OR (CALENDAR_MONTH(Start_Date__c) = 10
                AND CALENDAR_YEAR(Start_Date__c) = :pastYear)
                OR (CALENDAR_MONTH(Start_Date__c) = 7
                AND CALENDAR_YEAR(Start_Date__c) = :pastYear))
            ORDER BY QI_Submission_Due_Dt__c DESC
        ]) {
            System.debug('$$$quarter ' + quarter);
            if (!resultMap.containsKey('' + quarter.Start_Date__c)) {
                resultMap.put('' + quarter.Start_Date__c, quarter);
            }
        }
    }

    /**
     * If the current quarter starts July 2022, then the next 3 start Oct 2022, Jan 2023 and April 2023
     *
     */
    public static void getReportingForQuarter1(Integer currentYear, Integer nextYear, Map<String, Reporting_Period__c> resultMap) {
        for (Reporting_Period__c quarter : [
            SELECT
                Reporting_Period_Type__c,
                QI_Submission_Due_Dt__c,
                Start_Date__c,
                End_Date__c,
                Current_Reporting_Period__c,
                Previous_Reporting_Period__c,
                Reporting_Period_Short__c
            FROM Reporting_Period__c
            WHERE
                Reporting_Period_Type__c = 'Quarter'
                AND QI_Submission_Due_Dt__c != NULL
                AND Reporting_Period_Short__c != NULL
                AND ((CALENDAR_MONTH(Start_Date__c) = 10
                AND CALENDAR_YEAR(Start_Date__c) = :currentYear)
                OR (CALENDAR_MONTH(Start_Date__c) = 1
                AND CALENDAR_YEAR(Start_Date__c) = :nextYear)
                OR (CALENDAR_MONTH(Start_Date__c) = 4
                AND CALENDAR_YEAR(Start_Date__c) = :nextYear))
            ORDER BY QI_Submission_Due_Dt__c DESC
        ]) {
            System.debug('$$$quarter ' + quarter);
            if (!resultMap.containsKey('' + quarter.Start_Date__c)) {
                resultMap.put('' + quarter.Start_Date__c, quarter);
            }
        }
    }

    /**
     * If the current quarter starts April 2023, then the prev 3 start Jul 2022, Oct 2022 and Jan 2023
     *
     */
    public static void getReportingForQuarter3(Integer currentYear, Map<String, Reporting_Period__c> resultMap) {
        Integer prevYear = currentYear - 1;
        for (Reporting_Period__c quarter : [
            SELECT
                Reporting_Period_Type__c,
                QI_Submission_Due_Dt__c,
                Start_Date__c,
                End_Date__c,
                Current_Reporting_Period__c,
                Previous_Reporting_Period__c,
                Reporting_Period_Short__c
            FROM Reporting_Period__c
            WHERE
                Reporting_Period_Type__c = 'Quarter'
                AND QI_Submission_Due_Dt__c != NULL
                AND Reporting_Period_Short__c != NULL
                AND (Previous_Reporting_Period__c = TRUE
                OR (CALENDAR_MONTH(Start_Date__c) = 7
                AND CALENDAR_YEAR(Start_Date__c) = :prevYear)
                OR (CALENDAR_MONTH(Start_Date__c) = 4
                AND CALENDAR_YEAR(Start_Date__c) = :currentYear))
            ORDER BY QI_Submission_Due_Dt__c DESC
        ]) {
            System.debug('$$$quarter ' + quarter);
            if (!resultMap.containsKey('' + quarter.Start_Date__c)) {
                resultMap.put('' + quarter.Start_Date__c, quarter);
            }
        }
    }

    /**
     * If the current quarter starts October 2022, then the prev quarter starts Jul 2022 and the next 2 Jan and April 2023
     *
     */
    public static void getReportingForQuarter2(Integer nextYear, Map<String, Reporting_Period__c> resultMap) {
        for (Reporting_Period__c quarter : [
            SELECT
                Reporting_Period_Type__c,
                QI_Submission_Due_Dt__c,
                Start_Date__c,
                End_Date__c,
                Current_Reporting_Period__c,
                Previous_Reporting_Period__c,
                Reporting_Period_Short__c
            FROM Reporting_Period__c
            WHERE
                Reporting_Period_Type__c = 'Quarter'
                AND QI_Submission_Due_Dt__c != NULL
                AND Reporting_Period_Short__c != NULL
                AND (Previous_Reporting_Period__c = TRUE
                OR Current_Reporting_Period__c = TRUE
                OR (CALENDAR_MONTH(Start_Date__c) = 1
                AND CALENDAR_YEAR(Start_Date__c) = :nextYear)
                OR (CALENDAR_MONTH(Start_Date__c) = 4
                AND CALENDAR_YEAR(Start_Date__c) = :nextYear))
            ORDER BY QI_Submission_Due_Dt__c DESC
        ]) {
            System.debug('$$$quarter ' + quarter);
            if (!resultMap.containsKey('' + quarter.Start_Date__c)) {
                resultMap.put('' + quarter.Start_Date__c, quarter);
            }
        }
    }
}