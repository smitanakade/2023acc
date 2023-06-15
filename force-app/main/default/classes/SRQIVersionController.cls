/****************************************************************************************************
 * @CreatedBy   : Yifei Pei
 * @CreatedDate : 11-04-2023
 * @Description : Controller Class for LWC srqiVersionControl
 *
 * @Test Class  :
 *****************************************************************************************************/
public with sharing class SRQIVersionController {
    private static final List<String> ALL_STATUS_SUBMITTED = new List<String>{ 'Submitted', 'Late Submission', 'Updated After Due Date' };
    private static final String VERSION_PREFIX = 'Version ';
    private static final String VERSION_SUFFIX_CURRENT = ' (Current)';
    private static final String VERSION_SUFFIX_DRAFT = ' (Draft)';

    /**
     *
     *
     * @parameter qisId is the recordId of the QIS record retrived from currentPageReference.state?.qisid
     */
    @AuraEnabled
    public static List<VersionInfo> getVersionInfo(String qisId) {
        List<VersionInfo> response = new List<VersionInfo>();
        try {
            List<Quality_Indicator_Summary_Version__c> qisvRecords = getQISVRecord(qisId);
            if (qisvRecords?.size() > 0) {
                for (Quality_Indicator_Summary_Version__c qisvRecord : qisvRecords) {
                    VersionInfo vi = qisvToVI(qisvRecord);
                    // Assumption: the first popped item is the current of draft
                    if (response.size() < 1) {
                        if (!ALL_STATUS_SUBMITTED.contains(vi.status)) {
                            vi.isDraft = true;
                            vi.value += VERSION_SUFFIX_DRAFT;
                            vi.label += VERSION_SUFFIX_DRAFT;
                        } else {
                            vi.isCurrent = true;
                            vi.value += VERSION_SUFFIX_CURRENT;
                            vi.label += VERSION_SUFFIX_CURRENT;
                        }
                    }
                    if (response.size() == 1) {
                        if (response[0].isDraft == true) {
                            vi.value += VERSION_SUFFIX_CURRENT;
                            vi.label += VERSION_SUFFIX_CURRENT;
                        }
                    }
                    response.add(vi);
                }
            }
        } catch (Exception e) {
            dohagedcare.Logger.error(e.getMessage(), e, 'SRQIVersionController.getVersionInfo failed').Log();
            throw new AuraHandledException(e.getMessage());
        }
        return response;
    }

    private static VersionInfo qisvToVI(Quality_Indicator_Summary_Version__c qisvRecord) {
        VersionInfo newVI = new VersionInfo();
        newVI.value = VERSION_PREFIX + String.valueOf(qisvRecord.Version__c);
        newVI.label = VERSION_PREFIX + String.valueOf(qisvRecord.Version__c);
        newVI.status = qisvRecord.Status__c;
        newVI.qisvId = qisvRecord.Id;
        if (qisvRecord.Submitted_By__c != null) {
            if (qisvRecord.Submitted_By__r.Profile.UserType != 'PowerCustomerSuccess') {
                newVI.lastUpdated =
                    'Submitted By: Department user | Submitted Date: ' + qisvRecord.Submission_Date_Time__c.format('dd MMMMM yyyy, HH:mm');
            } else {
                newVI.lastUpdated =
                    'Submitted By: ' +
                    qisvRecord.Submitted_By__r.Name +
                    ' | Submitted Date: ' +
                    qisvRecord.Submission_Date_Time__c.format('dd MMMMM yyyy, HH:mm');
            }
        }
        newVI.isCurrent = false;
        newVI.isDraft = false;
        if (Date.today() > qisvRecord.REPORTING_PERIOD__r.QI_Submission_Due_Dt__c) {
            newVI.isLate = true;
        } else {
            newVI.isLate = false;
        }
        if (!qisvRecord.REPORTING_PERIOD__r.Current_Reporting_Period__c && !qisvRecord.REPORTING_PERIOD__r.Previous_Reporting_Period__c) {
            newVI.isReadOnly = true;
        } else {
            newVI.isReadOnly = false;
        }
        return newVI;
    }
    private static List<Quality_Indicator_Summary_Version__c> getQISVRecord(String qisId) {
        // Assumption: latest version should be the current version (or draft version)
        return [
            SELECT
                Id,
                LastModifiedDate,
                LastModifiedBy.Name,
                Quality_Indicator_Summary__c,
                Status__c,
                Version__c,
                Submission_Date_Time__c,
                Submitted_By__r.Name,
                Submitted_By__r.Profile.UserType,
                REPORTING_PERIOD__r.QI_Submission_Due_Dt__c,
                REPORTING_PERIOD__r.Previous_Reporting_Period__c,
                REPORTING_PERIOD__r.Current_Reporting_Period__c
            FROM Quality_Indicator_Summary_Version__c
            WHERE Quality_Indicator_Summary__c = :qisId
            ORDER BY Version__c DESC
        ];
    }

    public class VersionInfo {
        @AuraEnabled
        public String label;

        @AuraEnabled
        public String value;

        @AuraEnabled
        public String status;

        @AuraEnabled
        public Boolean isCurrent;

        @AuraEnabled
        public Boolean isDraft;

        @AuraEnabled
        public String qisvId;

        @AuraEnabled
        public String lastUpdated;

        @AuraEnabled
        public Boolean isLate;

        @AuraEnabled
        public Boolean isReadOnly;
    }
}