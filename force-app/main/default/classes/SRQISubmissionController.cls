/****************************************************************************************************
 * @CreatedBy   : Yifei Pei
 * @CreatedDate : 08-03-2023
 * @Description : Controller Class for LWC srqiSubmission
 *
 * @Test Class  : SRQISubmissionControllerTest
 *****************************************************************************************************/

public with sharing class SRQISubmissionController {
    private static final String STATUS_COMPLETE = 'Completed';
    private static final List<String> ALL_STATUS_SUBMITTED = new List<String>{ 'Submitted', 'Late Submission', 'Updated After Due Date' };
    private static final String STATUS_SUBMITTED = 'Submitted';
    private static final String STATUS_LATE_SUBMISSION = 'Late Submission';
    private static final String STATUS_AFTER_DUE_DATE = 'Updated After Due Date';
    // Assumption: there will be exactly 11 QID records before the user reaches the submission step
    private static final Integer DOMAIN_NUMBER = 11;
    private static final Integer PREVIOUS_DOMAIN_NUMBER = 5;

    /**
     * Method getDomainInfo to query on all Quality Indicator Details realted to the QIS record
     * according to the different cases, the LWC will have different behaviours
     * @parameter qisId is the recordId of the QIS record retrived from currentPageReference.state?.qisid
     */
    @AuraEnabled
    public static String getDomainInfo(String qisId) {
        DomainInfo domainData = new DomainInfo();
        domainData.completedDomains = new List<QIDomain>();
        domainData.uncompletedDomains = new List<QIDomain>();
        domainData.isSubmittable = false;
        domainData.isAmended = false;
        domainData.isCompleted = false;
        domainData.isLateSubmission = false;
        try {
            // Dicide whether it is a 11-domain summary or 5-domain summary
            Boolean isFiveDomainsRequired = SRQIQuestionDataCaptureFormController.isFiveDomainsRequired(qisId);
            // get all the five domain names
            String selectStepper = (String) Quality_Indicator_Settings__mdt.getInstance('QI_Stepper_for_Go_Live').QI_Limited_Steppers__c;
            List<String> qiSteppersList = new List<String>();
            for (String sList : selectStepper.split(',')) {
                qiSteppersList.add(sList.trim());
            }
            // Assumption: as there is QIS ID, there will defnitely be a QIS Record
            Quality_Indicator_Summary__c qisRecord = getQISRecord(qisId);
            List<Quality_Indicator_Details__c> qidRecords = getQIDRecords(qisId);
            if (qidRecords?.size() > 0) {
                for (Quality_Indicator_Details__c qidRecord : qidRecords) {
                    if (isFiveDomainsRequired) {
                        if (qiSteppersList.contains(qidRecord.RecordType.Name)) {
                            if (qidRecord.Status__c == STATUS_COMPLETE) {
                                domainData.completedDomains.add(new QIDomain(qidRecord));
                            } else {
                                domainData.uncompletedDomains.add(new QIDomain(qidRecord));
                            }
                            if (qidRecord.Amended_after_Completion__c) {
                                domainData.isAmended = true;
                            }
                        }
                    } else {
                        if (qidRecord.Status__c == STATUS_COMPLETE) {
                            domainData.completedDomains.add(new QIDomain(qidRecord));
                        } else {
                            domainData.uncompletedDomains.add(new QIDomain(qidRecord));
                        }
                        if (
                            (qidRecord.Amended_after_Completion__c) &&
                            (Date.today() > qisRecord.REPORTING_PERIOD__r.QI_Submission_Due_Dt__c)
                        ) {
                            domainData.isAmended = true;
                        }
                    }
                }
                if (Date.today() > qisRecord.REPORTING_PERIOD__r.QI_Submission_Due_Dt__c) {
                    domainData.isLateSubmission = true;
                }
                // validation
                // Assumption: if there are only 5 domains, the front end will only have five steps as well.
                //             Therefore, we should expect only five domains
                if (isFiveDomainsRequired) {
                    if ((domainData.completedDomains.size() + domainData.uncompletedDomains.size()) < PREVIOUS_DOMAIN_NUMBER) {
                        throw QIDynamicManagementController.qiMessageException(
                            'Please make sure there are five Quality Indicator Detail records for migrated data.'
                        );
                    }
                } else {
                    if ((domainData.completedDomains.size() + domainData.uncompletedDomains.size()) != DOMAIN_NUMBER) {
                        throw QIDynamicManagementController.qiMessageException(
                            'Please create Quality Indicator Detail records for all the domains.'
                        );
                    }
                }
                // Assumption: if the uncompletedDomains list is not empty, the QIS is not submitted
                // Assumption: even the QID is amended, the status will still be completed
                if (domainData.uncompletedDomains.size() < 1) {
                    // Case 1: all domains are completed
                    // Case 2 all domains are completed but at least one domain has been amended
                    domainData.isSubmittable = true;
                    if ((ALL_STATUS_SUBMITTED.contains(qisRecord.Status__c)) && (!domainData.isAmended)) {
                        // Case 3: all domains are completed and none of the domains are amended
                        domainData.isSubmittable = false;
                        domainData.isCompleted = true;
                    }
                }
                // Case 4: if there are uncomlatedDomains, keep it as what it is and show the uncompleted ones on LWC
            } else {
                // Assumption: if there are QID records, there will be 11 records, one for each record type.
                throw QIDynamicManagementController.qiMessageException('No Quality Indicator Detail records have been created.');
            }
        } catch (Exception e) {
            dohagedcare.Logger.error(e.getMessage(), e, 'SRQISubmissionController.getDomainInfo failed').Log();
            throw new AuraHandledException(e.getMessage());
        }
        return JSON.serialize(domainData);
    }
    /**
     * Method submitRecord to mark the QIS submitted
     * does the same as "submit record" button on QIS record
     * @parameter qisId retrieved from currentPageReference.state?.qisid
     *            isAmended passed back from frontend for action direction
     */
    @AuraEnabled
    public static string submitRecord(String qisId, Boolean isAmended) {
        String response = '';
        try {
            // Assumption: if the user can click the submit button, that means all conditions are met
            Quality_Indicator_Summary__c qisRecord = getQISRecord(qisId);
            List<Quality_Indicator_Details__c> amendedQIDRecords = new List<Quality_Indicator_Details__c>();
            if (Date.today() > qisRecord.REPORTING_PERIOD__r.QI_Submission_Due_Dt__c) {
                if (isAmended) {
                    amendedQIDRecords = getAmendedQIDRecords(qisId);
                    for (Quality_Indicator_Details__c amendedQIDRecord : amendedQIDRecords) {
                        amendedQIDRecord.Amended_after_Completion__c = false;
                    }
                    qisRecord.Status__c = STATUS_AFTER_DUE_DATE;
                } else {
                    qisRecord.Status__c = STATUS_LATE_SUBMISSION;
                }
            } else {
                qisRecord.Status__c = STATUS_SUBMITTED;
            }
            qisRecord.Submission_Date_Time__c = Datetime.now();
            if (qisRecord.First_submission_date__c == null) {
                qisRecord.First_submission_date__c = Date.today();
            }
            qisRecord.QIUpdatedbySiebel__c = true;
            // it is a controller with exception catch so haven't put CRUD permission check
            update qisRecord;
            if (amendedQIDRecords.size() > 0) {
                update amendedQIDRecords;
            }
            response = 'Success';
        } catch (Exception e) {
            dohagedcare.Logger.error(e.getMessage(), e, 'SRQISubmissionController.submitRecord failed').Log();
            throw new AuraHandledException(e.getMessage());
        }
        return JSON.serialize(response);
    }

    /**
     * Method isSubmitted to check if Quality Indicator Summary record is submitted
     * This is used in srqiQuestionDataCaptureForm LWC
     * @parameter qisId is the recordId of the QIS record retrived from currentPageReference.state?.qisid
     */
    @AuraEnabled
    public static Boolean isSubmitted(String qisId) {
        Boolean isSubmitted = false;
        try {
            List<Quality_Indicator_Details__c> relatedQIDList = getQIDRecords(qisId);
            List<Quality_Indicator_Details__c> amendedQIDList = new List<Quality_Indicator_Details__c>();
            for (Quality_Indicator_Details__c qidRec : relatedQIDList) {
                if (qidRec.Amended_after_Completion__c) {
                    amendedQIDList.add(qidRec);
                }
            }
            // all the QID records in the list are associated with only one QIS record
            if ((amendedQIDList.size() < 1) && ALL_STATUS_SUBMITTED.contains(relatedQIDList[0].QI_Summary_Id__r.Status__c)) {
                isSubmitted = true;
            }
        } catch (Exception e) {
            dohagedcare.Logger.error(e.getMessage(), e, 'SRQISubmissionController.isSubmitted failed').Log();
            throw new AuraHandledException(e.getMessage());
        }
        return isSubmitted;
    }

    /**
     * Method submitVersionRecord to mark the draft QIS Version record submitted
     * @parameter qisvId retrieved from front end passed on by the form
     */
    @AuraEnabled
    public static string submitVersionRecord(String qisvId, Boolean isLate) {
        String response = '';
        try {
            Quality_Indicator_Summary_Version__c qisvRecord = getQISVRecord(qisvId);
            if (!ALL_STATUS_SUBMITTED.contains(qisvRecord.Status__c)) {
                if (isLate) {
                    if (qisvRecord.Quality_Indicator_Summary__r.Status__c == STATUS_LATE_SUBMISSION) {
                        qisvRecord.Status__c = STATUS_LATE_SUBMISSION;
                    } else {
                        qisvRecord.Status__c = STATUS_AFTER_DUE_DATE;
                    }
                } else {
                    qisvRecord.Status__c = STATUS_SUBMITTED;
                }
                qisvRecord.Submission_Date_Time__c = Datetime.now();
                update qisvRecord;
            }
            // Assumption: if we go this far, that means we don't need to do anything when the status is submitted
            response = 'Success';
        } catch (Exception e) {
            dohagedcare.Logger.error(e.getMessage(), e, 'SRQISubmissionController.submitVersionRecord failed').Log();
            throw new AuraHandledException(e.getMessage());
        }
        return JSON.serialize(response);
    }

    private static List<Quality_Indicator_Details__c> getQIDRecords(String qisId) {
        return [
            SELECT
                Id,
                Amended_after_Completion__c,
                Status__c,
                RecordType.Name,
                QI_Summary_Id__r.Status__c,
                QI_Summary_Id__r.REPORTING_PERIOD__r.QI_Submission_Due_Dt__c
            FROM Quality_Indicator_Details__c
            WHERE QI_Summary_Id__c = :qisId
            WITH SECURITY_ENFORCED
            ORDER BY CreatedDate DESC
        ];
    }
    private static Quality_Indicator_Summary__c getQISRecord(String qisId) {
        // Assumption: QI_Submission_Due_Dt__c is always not null
        return [
            SELECT
                Id,
                First_submission_date__c,
                QIUpdatedbySiebel__c,
                REPORTING_PERIOD__r.QI_Submission_Due_Dt__c,
                Service__r.AccountId,
                Status__c,
                Submission_Date_Time__c
            FROM Quality_Indicator_Summary__c
            WHERE Id = :qisId
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
    }
    private static List<Quality_Indicator_Details__c> getAmendedQIDRecords(String qisId) {
        return [
            SELECT Id, Amended_after_Completion__c
            FROM Quality_Indicator_Details__c
            WHERE QI_Summary_Id__c = :qisId AND Amended_after_Completion__c = TRUE
            WITH SECURITY_ENFORCED
            ORDER BY CreatedDate DESC
        ];
    }
    private static Quality_Indicator_Summary_Version__c getQISVRecord(String qisvId) {
        return [
            SELECT Id, Status__c, Submission_Date_Time__c, Quality_Indicator_Summary__r.Status__c
            FROM Quality_Indicator_Summary_Version__c
            WHERE Id = :qisvId
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
    }
    public class DomainInfo {
        @AuraEnabled
        public List<QIDomain> completedDomains;

        @AuraEnabled
        public List<QIDomain> uncompletedDomains;

        @AuraEnabled
        public Boolean isSubmittable;

        @AuraEnabled
        public Boolean isAmended;

        @AuraEnabled
        public Boolean isCompleted;

        @AuraEnabled
        public Boolean isLateSubmission;
    }
    public class QIDomain {
        QIDomain(Quality_Indicator_Details__c qidRec) {
            domainName = qidRec.RecordType.Name;
            status = qidRec.Status__c;
        }

        @AuraEnabled
        public String domainName;

        @AuraEnabled
        public String status;
    }
}