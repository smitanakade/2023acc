/**
 * @Author           Kai-Fan Hsieh
 * @Date             21-12-2022
 * @Description      Utility class to be used within STAR Rating application
*/
public with sharing class ReportingPeriodUtil {
    public static final String REPORTING_PERIOD_TYPE_QUARTER = 'Quarter';

    public static Reporting_Period__c previousQuarterReportingPeriod {
        get {
            if (previousQuarterReportingPeriod == null) {
                List<Reporting_Period__c> rpList = [
                    SELECT Id
                    FROM Reporting_Period__c
                    WHERE Previous_Reporting_Period__c = TRUE
                    AND Reporting_Period_Type__c = :REPORTING_PERIOD_TYPE_QUARTER
                    LIMIT 1
                ];
                if (rpList.size() > 0) {
                    previousQuarterReportingPeriod = rpList.get(0);
                }
            }
            return previousQuarterReportingPeriod;
        }
        private set;
    }
}