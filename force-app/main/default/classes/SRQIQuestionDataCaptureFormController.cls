/**
 * @author Rami Zuhairi, Smita Kagde
 * @date 08/2022
 * @objects Question_Section__c, Question_Library__c, Section_Library__c, Question_Category__c
 * @description Apex class to make dynamic read and get the required data for Nav bar and QI pages so
 * when the user delete or add new section or question , it will reflect directly on the LWC component
 * @testClass SRQIQuesDataCaptureFormControllerTest
 */
public with sharing class SRQIQuestionDataCaptureFormController {
    @TestVisible private static final String QIT_LABEL = 'Quality Indicator Targets';
    @TestVisible private static final String QI_LABEL = 'Quality Indicator';
    @TestVisible private static final String QI_Status_InProgress = 'In Progress';
    // Status values on the Quality Indicator Summary that indicate it has been submitted
    private static final List<String> QIS_STATUS_SUBMITTED = new List<String>{
        'Submitted',
        'Updated After Due Date',
        'Late Submission'
    };

    /**
     * @description returning who
     */
    public class LastModifiedDetails {
        String lastModifiedByName;
        Datetime lastModifiedDate;
        Boolean isInternal;
    }

    /**
     * Get record type ID for given record type name
     * @note Quality Indicator Targets do not have record types, therefore we return null
     */
    @AuraEnabled(cacheable=true)
    public static Id getRecordType(String recordTypeName, Boolean isVersionObject) {
        if (recordTypeName != null && recordTypeName != QIT_LABEL) {
            Id recordTypeId;
            if (isVersionObject) {
                recordTypeId = Schema.SObjectType.Quality_Indicator_Detail_Version__c.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
            } else {
                recordTypeId = Schema.SObjectType.Quality_Indicator_Details__c.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
            }
            return recordTypeId;
        } else {
            return null;
        }
    }
    
    /**
     * Get the form sections required for the given summary which will be displayed in the navigation stepper
     * @note This handles migrated data which has only five domains, whereas new data will have eleven plus targets
     */
    @AuraEnabled
    public static List<Question_Section__c> getFormSections(String category, Id qiSummaryId) {
        List<Question_Section__c> questionSections = new List<Question_Section__c>();

        if (isFiveDomainsRequired(qiSummaryId)) {
            String selectStepper = (String)Quality_Indicator_Settings__mdt.getInstance('QI_Stepper_for_Go_Live').QI_Limited_Steppers__c;
            List<String> qiSteppersList = new List<String>();
            for (String sList : selectStepper.split(',')) {
                qiSteppersList.add(sList.trim());
            }
            questionSections = [
                SELECT Type__c
                FROM Question_Section__c
                WHERE Question_Category__r.Name = :category
                AND Type__c IN :qiSteppersList
                ORDER BY Sequence_No__c ASC 
                LIMIT 10000
            ];  
        } else {
            // Order QIT sections first
            questionSections = [
                SELECT Type__c
                FROM Question_Section__c
                WHERE Question_Category__r.Name = :QIT_LABEL
                ORDER BY Sequence_No__c ASC 
                LIMIT 10000
            ];

            // Then QID sections
            questionSections.addAll([
                SELECT Type__c
                FROM Question_Section__c
                WHERE Question_Category__r.Name = :category
                ORDER BY Sequence_No__c ASC 
                LIMIT 10000
            ]);  
        }

        return getOneQuestionSectionPerType(questionSections);
    }

    /**
     * @description: retrieve a list of section headings and questions
     * @params  type , category
     */
    @AuraEnabled(cacheable=true)
    public static List<Question_Section__c> getQuestions(String type, String category) {
        List<String> categoryToQuery = category == QI_LABEL ? new List<String>{ QI_LABEL, QIT_LABEL } : new List<String>{ category };
        List<Question_Section__c> questions = new List<Question_Section__c>();
        questions = [
            SELECT Name, Key__c, Question_Library__r.Help_Text__c,Question_Library__r.Question__c, Question_Library__r.Mandatory__c,
                Question_Category__r.Name, Question_Library__r.Response_Data_Type__c, Type__c, Section_Library__r.Section_Name__c,
                Question_Group__c, Validation_Warning_Setting__c, Section_Library__r.Sub_Section__c
            FROM Question_Section__c
            WHERE Question_Category__r.Name IN :categoryToQuery
            AND Type__c = :type 
            ORDER BY Sequence_No__c ASC
            LIMIT 10000
        ];
        return questions;
    }

    /**
     * Get existing data for given section
     */
    @AuraEnabled
    public static SObject getFormSectionResponse(Id recordTypeId, Id summaryId, Id summaryVersionId, String questionSectionType) {
        String objectToQuery;
        List<String> fieldsToQuery = new List<String>{ 'Id' };
        String conditionsToQuery;

        List<Question_Section__c> questions = getQuestions(questionSectionType, QI_LABEL);
        for (Question_Section__c question : questions) {
            if (question.Key__c != null) {
                fieldsToQuery.add(question.Key__c);
            }
        }

        if (questionSectionType == QIT_LABEL) {
            if (summaryVersionId == null) {
                objectToQuery = 'Quality_Indicator_Targets__c';
                conditionsToQuery = 'WHERE Quality_Indicator_Summary__c = \'' + summaryId + '\' LIMIT 1';
            } else {
                objectToQuery = 'Quality_Indicator_Target_Version__c';
                conditionsToQuery = 'WHERE Quality_Indicator_Summary_Version__c = \'' + summaryVersionId + '\' LIMIT 1';
            }
        } else {
            fieldsToQuery.addAll(new List<String>{ 'Error_Flag__c', 'Status__c' });
            if (summaryVersionId == null) {
                objectToQuery = 'Quality_Indicator_Details__c';
                conditionsToQuery = 'WHERE RecordTypeId = \'' + recordTypeId + '\' AND QI_Summary_Id__c = \'' + summaryId + '\' LIMIT 1';
            } else {
                objectToQuery = 'Quality_Indicator_Detail_Version__c';
                conditionsToQuery = 'WHERE RecordTypeId = \'' + recordTypeId + '\' AND Quality_Indicator_Summary_Version__c = \'' + summaryVersionId + '\' LIMIT 1';
            }
        }

        String query = 'SELECT ' + String.join(fieldsToQuery, ',') + ' FROM ' + objectToQuery + ' ' + conditionsToQuery;
        try {
            List<SObject> responses = Database.query(query);
            if (responses.isEmpty()) {
                return null;
            } else {
                return responses.get(0);
            }
        } catch (Exception ex) {
            dohagedcare.Logger.error(ex.getMessage(), ex, 'QISR').log();
            String errorMessage = 'Error in getting ' + objectToQuery + ' record. Please refresh page or contact system administrator';
            throw new AuraHandledException(JSON.serialize(new List<String>{ errorMessage }));
        }
    }

    /**
     * Saves data for the form section that is currently in progress
     * @note Targets section does not have a status field so behaviour is the same in both in progress and complete functions
     */
    @AuraEnabled
    public static void saveFormSectionInProgress(String formData, Id recordTypeId, Id summaryId, Boolean warningFlag) {
        try {
            Quality_Indicator_Summary__c summary = getSummary(summaryId);
            validateQualityIndicatorSummaryEditable(summary);

            if (recordTypeId != null) {
                // Set fields on the quality indicator detail record
                Quality_Indicator_Details__c qidRecord = (Quality_Indicator_Details__c)constructRecordFromJSON(Quality_Indicator_Details__c.SObjectType, formData);
                qidRecord.RecordTypeId = recordTypeId;
                qidRecord.QI_Summary_Id__c = summaryId;
                qidRecord.Status__c = QI_Status_InProgress;
                qidRecord.Error_Flag__c = warningFlag ? 'Warnings Returned' : null;

                // Get existing quality indicator detail record if exists
                List<Quality_Indicator_Details__c> existingRecords = [
                    SELECT Id, Error_Flag__c 
                    FROM Quality_Indicator_Details__c 
                    WHERE QI_Summary_Id__c = :summaryId 
                    AND RecordTypeId = :qidRecord.RecordTypeId
                ];

                // Upsert the record
                if (existingRecords.size() > 0) {
                    qidRecord.Id = existingRecords[0].Id;

                    /**
                     * Errors are only cleared when completing a quality indicator details record successfully. 
                     * So when updating an in progress record, we simply take the error status on the existing record.
                     */
                    if (existingRecords[0].Error_Flag__c == 'Errors Returned') {
                        qidRecord.Error_Flag__c = 'Errors Returned';
                    }
                }
                upsert qidRecord;
            } else {
                saveTargets(formData, summaryId);
            }
        } catch (Exception ex) {
            dohagedcare.Logger.error(ex.getMessage(), ex, 'QISR').log();
            throw new AuraHandledException(JSON.serialize(new List<String>{ ex.getMessage() }));
        }
    }

    /**
     * Validates then saves data for the form section that is already completed or attempting to be completed.
     * If the section is attempting to be completed and there are errors, the data is still saved but status remains in progress.
     * If there are errors, these are returned.
     * @note Targets section does not have a status field so behaviour is the same in both in progress and complete functions
     */
    @AuraEnabled
    public static String saveFormSectionComplete(String formData, Id recordTypeId, Id summaryId, Boolean warningFlag, Boolean validateOnly) {
        Savepoint savePoint;
        Set<String> errorMessages = new Set<String>();

        try {
            Quality_Indicator_Summary__c summary = getSummary(summaryId);
            validateQualityIndicatorSummaryEditable(summary);

            if (recordTypeId != null) {
                // Set fields on the quality indicator detail record
                Quality_Indicator_Details__c qidRecord = (Quality_Indicator_Details__c)constructRecordFromJSON(Quality_Indicator_Details__c.SObjectType, formData);
                List<String> formFields = new List<String>(qidRecord.getPopulatedFieldsAsMap().keySet()); 
                qidRecord.RecordTypeId = recordTypeId;
                qidRecord.QI_Summary_Id__c = summaryId;
                qidRecord.Status__c = 'Completed'; 
                qidRecord.Error_Flag__c = warningFlag ? 'Warnings Returned' : null;

                // Get existing quality indicator detail record if exists
                String formFieldsToQuery = String.join(formFields, ',');
                String query = 'SELECT Id, Status__c, ' + formFieldsToQuery + ' FROM Quality_Indicator_Details__c WHERE QI_Summary_Id__c = \'' +
                                summaryId + '\' AND RecordTypeId = \'' + qidRecord.RecordTypeId + '\'';
                List<Quality_Indicator_Details__c> existingRecords = Database.query(query);

                // Logic to set the "Amended after Completion" field 
                Boolean isSummarySubmitted = QIS_STATUS_SUBMITTED.contains(summary.Status__c);
                Quality_Indicator_Details__c existingRecord = existingRecords.size() > 0 ? existingRecords[0] : null;
                if (isSummarySubmitted && isRecordChanged(qidRecord, existingRecord, formFields)) {
                    qidRecord.Amended_after_Completion__c = true;
                }

                if (validateOnly) {
                    savePoint = Database.setSavepoint();
                }

                // Upsert the record 
                Database.UpsertResult result = null;
                if (existingRecords.size() > 0) {
                    qidRecord.Id =  existingRecords[0].Id;
                }
                result = Database.upsert(qidRecord, false);

                // Handle validation errors
                if (result != null && !result.isSuccess()) {
                    List<Database.Error> errors = result.getErrors();

                    // Save record as in progress with error flag unless it is already marked completed (in which case we don't save anything)
                    if (!validateOnly && (existingRecords.size() <= 0 || existingRecords[0].Status__c != 'Completed')) {
                        qidRecord.Status__c = QI_Status_InProgress;
                        qidRecord.Error_Flag__c = 'Errors Returned';
                        upsert qidRecord;
                    }

                    // Return validation errors as a map to LWC
                    return JSON.serialize(formatErrors(errors));
                }

                // We simply want to fetch the errors without modifying data so roll back any changes
                if (validateOnly) {
                    Database.rollback(savePoint);
                }
            } else {
                saveTargets(formData, summaryId);
            }
        } catch (Exception ex) {
            // Some other error occurred
            dohagedcare.Logger.error(ex.getMessage(), ex, 'QISR').log();
            errorMessages.add(ex.getMessage());
            throw new AuraHandledException(JSON.serialize(errorMessages));
        }

        return null;
    }

    /**
     * Validates then saves data for the given version of the form section.
     * The validation rules on the QID object are not present on the QIDV object, so we need to do a mock update (i.e. set savepoint then rollback)
     * on the QID record in order to trigger them and get any errors. 
     * If there are errors, these are returned.
     */
    @AuraEnabled
    public static String saveFormSectionVersionComplete(String formData, Id versionRecordTypeId, String recordTypeName, Id summaryId, Id summaryVersionId, Boolean warningFlag) {
        Set<String> errorMessages = new Set<String>();

        try {
            validateQualityIndicatorSummaryVersionEditable(summaryVersionId);

            if (versionRecordTypeId != null) {
                // Set fields on the quality indicator detail version record
                Quality_Indicator_Detail_Version__c qidvRecord = (Quality_Indicator_Detail_Version__c)constructRecordFromJSON(Quality_Indicator_Detail_Version__c.SObjectType, formData);
                List<String> formFields = new List<String>(qidvRecord.getPopulatedFieldsAsMap().keySet()); 
                qidvRecord.RecordTypeId = versionRecordTypeId;
                qidvRecord.Quality_Indicator_Summary_Version__c = summaryVersionId;
                qidvRecord.Error_Flag__c = warningFlag ? 'Warnings Returned' : null;

                // Get existing quality indicator detail record if exists
                String formFieldsToQuery = String.join(formFields, ',');
                String query = 'SELECT Id FROM Quality_Indicator_Detail_Version__c WHERE Quality_Indicator_Summary_Version__c = \'' +
                                summaryVersionId + '\' AND RecordTypeId = \'' + qidvRecord.RecordTypeId + '\'';
                List<Quality_Indicator_Detail_Version__c> existingRecords = Database.query(query);

                // Trigger validations on Quality Indicator Detail object and then rollback any changes
                Id recordTypeId = getRecordType(recordTypeName, false);
                Boolean validateOnly = true;
                String errors = saveFormSectionComplete(formData, recordTypeId, summaryId, warningFlag, validateOnly);
                if (errors == null) {
                    // Update the QIDV record as there are no validation errors
                    if (existingRecords.size() > 0) {
                        qidvRecord.Id = existingRecords[0].Id;
                        Database.update(qidvRecord, false);
                    }
                } else {
                    return errors;
                }
            } else {
                saveTargetsVersion(formData, summaryVersionId);
            }
        } catch (Exception ex) {
            // Some other error occurred
            dohagedcare.Logger.error(ex.getMessage(), ex, 'QISR').log();
            errorMessages.add(ex.getMessage());
            throw new AuraHandledException(JSON.serialize(errorMessages));
        }

        return null;
    }

    /**
     * @description updates Quality Indicator Targets based on user input
     */
    public static void saveTargets(String formData, Id summaryId) {
        try { 
            Quality_Indicator_Targets__c qitRecord = (Quality_Indicator_Targets__c)constructRecordFromJSON(Quality_Indicator_Targets__c.SObjectType, formData);
            qitRecord.Quality_Indicator_Summary__c = summaryId;

            List<Quality_Indicator_Targets__c> existingRecords = [
                SELECT Id, Quality_Indicator_Summary__c 
                FROM Quality_Indicator_Targets__c 
                WHERE Quality_Indicator_Summary__c = :summaryId
            ];

            if (existingRecords.size() > 0) {
                qitRecord.Id = existingRecords[0].Id;
                update qitRecord;
            }
        } catch (Exception ex) {
            dohagedcare.Logger.error(ex.getMessage(), ex, 'QISR').log();
            throw new AuraHandledException(JSON.serialize(new List<String>{ ex.getMessage() }));
        }
    }

    /**
     * @description updates Quality Indicator Target Version based on user input
     */
    public static void saveTargetsVersion(String formData, Id summaryVersionId) {
        try { 
            Quality_Indicator_Target_Version__c qitRecord = (Quality_Indicator_Target_Version__c)constructRecordFromJSON(Quality_Indicator_Target_Version__c.SObjectType, formData);
            qitRecord.Quality_Indicator_Summary_Version__c = summaryVersionId;

            List<Quality_Indicator_Target_Version__c> existingRecords = [
                SELECT Id
                FROM Quality_Indicator_Target_Version__c 
                WHERE Quality_Indicator_Summary_Version__c = :summaryVersionId
            ];

            if (existingRecords.size() > 0) {
                qitRecord.Id = existingRecords[0].Id;
                update qitRecord;
            }
        } catch (Exception ex) {
            dohagedcare.Logger.error(ex.getMessage(), ex, 'QISR').log();
            throw new AuraHandledException(JSON.serialize(new List<String>{ ex.getMessage() }));
        }
    }

    // See QualityIndicatorValidationUtil
    @AuraEnabled(cacheable=true)
    public static QualityIndicatorValidationUtil.ValidationSettingWrapper getValidationErrorSetting() {
        return QualityIndicatorValidationUtil.getValidationErrorSetting();
    }

    // See QualityIndicatorValidationUtil
    @AuraEnabled(cacheable=true)
    public static Map<String,QualityIndicatorValidationUtil.ValidationSettingWrapper> getValidationWarningSettings(List<String> qualityIndicatorSettingNames) {
        return QualityIndicatorValidationUtil.getValidationSettingsMap(qualityIndicatorSettingNames);
    }

    /**
     * Formats the errors as a map with the field API name as the key and the error message as the value
     */
    public static Map<String,String> formatErrors(List<Database.Error> errors) {
        Map<String,String> fieldsToErrorMessages = new Map<String,String>();

        for (Database.Error error : errors) {
            for (String field : error.getFields()) {
                fieldsToErrorMessages.put(field, error.getMessage());
            }
        }

        return fieldsToErrorMessages;
    }

    /**
     * Parses JSON as record of given object
     */
    public static SObject constructRecordFromJSON(Schema.SObjectType objectType, String recordJSON) {
        SObject record = objectType.newSObject();

        Map<String,Object> rawObj = (Map<String,Object>) JSON.deserializeUntyped(recordJSON);
        Set<String> fields = rawObj.keySet();

        for (String field : fields) {
            Object value = rawObj.get(field);

            if (field.contains('Date')) {
                Date dateValue = value == null ? null : Date.valueOf((String)value);
                record.put(field, dateValue);
            } else {
                record.put(field, value);
            }
        }

        return record;
    }

    /**
     * Compares the updated record with the existing record. Returns true if there is a change, false otherwise.
     * Note we do not query for the fields in this method, so the assumption is that the fields to compare will be available 
     * on both records prior to calling this method.
     */
    public static Boolean isRecordChanged(Quality_Indicator_Details__c updatedRecord, Quality_Indicator_Details__c existingRecord, List<String> fieldsToCompare) {
        if (existingRecord == null) {
            return true;
        }

        for (String field : fieldsToCompare) {
            if (updatedRecord.get(field) != existingRecord.get(field)) {
                return true;
            }
        }

        return false;
    }

    /**
     * @description: retrieve a quality indicator summary Id
     * @params summaryId
     */
    @AuraEnabled(cacheable=true)
    public static Quality_Indicator_Summary__c getSummary(String summaryId) {
        if(summaryId == null) {
            return null;
        }

        return [ 
            SELECT Id,Service__r.Name, Name, Reporting_Period__r.Reporting_Period_Type__c, Reporting_Period__r.Name,
                (SELECT Id, Name, LastModifiedById, LastModifiedBy.Name, LastModifiedDate FROM Quality_Indicators__r WHERE QI_Summary_Id__c = :summaryId ORDER BY LastModifiedDate DESC Limit 1),
                Reporting_Period__r.Reporting_Period__c, Service__c, Reporting_Period__r.QI_Submission_Due_Dt__c, LastModifiedDate, LastModifiedBy.Name,
                Reporting_Period__r.End_Date__c, Status__c, Current_Quarter__c, Previous_Quarter__c
            FROM Quality_Indicator_Summary__c 
            WHERE Id =: summaryId
            LIMIT 1
        ];
    }

    public static List<Quality_Indicator_Summary__c> getSummaryWithAllFields(Id summaryId) {
        Map<String,Schema.SObjectField> fieldMap = Schema.SObjectType.Quality_Indicator_Summary__c.fields.getMap();
        List<String> allFields = new List<String>(fieldMap.keySet());
        String query = 'SELECT ' + String.join(allFields, ',') + ' FROM Quality_Indicator_Summary__c WHERE Id = \'' + summaryId + '\'';
        return Database.query(query);
    }

    /**
     * Checks whether the Quality Indicator Summary record meets the criteria to be editable in the portal.
     * If not editable, it will throw an exception.
     */
    public static void validateQualityIndicatorSummaryEditable(Quality_Indicator_Summary__c summary) {
        if (isQualityIndicatorSummaryReadOnly(summary)) {
            String errorMessage = 'Quality Indicator Summary is read-only';
            AuraHandledException e = new AuraHandledException(errorMessage);

            // Workaround for issue where the error message is "Script-thrown exception" unless you explicitly do setMessage()
            e.setMessage(errorMessage);
            throw e;
        }
    }

    /**
     * Checks whether the Quality Indicator Summary record can be edited 
     */
    public static Boolean isQualityIndicatorSummaryReadOnly(Quality_Indicator_Summary__c summary) {
        Boolean isCurrentOrPreviousReportingPeriod = summary.Current_Quarter__c || summary.Previous_Quarter__c;
        return !isCurrentOrPreviousReportingPeriod;
    }

    /**
     * Checks whether the Quality Indicator Summary record can be edited
     */
    @AuraEnabled
    public static Boolean isQualityIndicatorSummaryByIdReadOnly(Id summaryId) {
        Quality_Indicator_Summary__c summary = getSummary(summaryId);
        return isQualityIndicatorSummaryReadOnly(summary);
    }

    /**
     * Checks whether the Quality Indicator Summary Version record can be edited
     */
    public static void validateQualityIndicatorSummaryVersionEditable(Id summaryVersionId) {
        Quality_Indicator_Summary_Version__c summaryVersion = [ 
            SELECT Status__c
            FROM Quality_Indicator_Summary_Version__c 
            WHERE Id =: summaryVersionId 
            LIMIT 1
        ];

        if (QIS_STATUS_SUBMITTED.contains(summaryVersion.Status__c)) {
            String errorMessage = 'Quality Indicator Summary Version is read-only';
            AuraHandledException e = new AuraHandledException(errorMessage);
            e.setMessage(errorMessage);
            throw e;
        }
    }

    /**
     * Checks whether the fields in the form should be displayed as read-only
     */
    @AuraEnabled
    public static Boolean isShowFieldsReadOnly(Id summaryId, Id summaryVersionId) {
        // QIS must not be read-only 
        Boolean isQualityIndicatorSummaryReadOnly = isQualityIndicatorSummaryByIdReadOnly(summaryId);
        if (isQualityIndicatorSummaryReadOnly) {
            return true;
        }

        // If no QISV then still editable 
        if (summaryVersionId == null) {
            return false;
        }

        // If QISV then last one only is editable
        Quality_Indicator_Summary_Version__c latestSummaryVersion = getLatestSummaryVersion(summaryId);
        return latestSummaryVersion.Id != summaryVersionId;
    }

    /**
     * Get the most recent Quality Indicator Summary Version record for the given summary
     */
    public static Quality_Indicator_Summary_Version__c getLatestSummaryVersion(Id summaryId) {
        List<Quality_Indicator_Summary_Version__c> summaryVersions = [
            SELECT Status__c
            FROM Quality_Indicator_Summary_Version__c
            WHERE Quality_Indicator_Summary__c = :summaryId
            ORDER BY Version__c DESC
        ];
        return summaryVersions.size() > 0 ? summaryVersions[0] : null;
    }

    /**
     * Checks whether the form should display a draft version warning message when user makes any changes
     */
    @AuraEnabled
    public static Boolean isDraftVersionRequiredForAmendment(Id summaryId) {
        Quality_Indicator_Summary_Version__c latestSummaryVersion = getLatestSummaryVersion(summaryId);
        if (latestSummaryVersion == null) {
            return false;
        }
        Boolean isLatestSummaryVersionSubmitted = QIS_STATUS_SUBMITTED.contains(latestSummaryVersion.Status__c);
        return isLatestSummaryVersionSubmitted;
    }

    /**
     * Creates a new version of the QIS record that is in progress along with its child QID/QIT records, then updates
     * the data for the given form section (i.e. user has changed data for form section and needs to create a new draft version with 
     * those changes)
     */
    @AuraEnabled
    public static void createDraftVersion(String formData, Id recordTypeId, String recordTypeName, Id summaryId, Boolean warningFlag) {
        // Validate that draft version is required
        if (!isDraftVersionRequiredForAmendment(summaryId)) {
            String errorMessage = 'Does not meet requirements to create a draft version';
            AuraHandledException e = new AuraHandledException(errorMessage);
            e.setMessage(errorMessage);
            throw e;
        }

        // Validate that QIS can be edited
        Quality_Indicator_Summary__c summary = getSummary(summaryId);
        validateQualityIndicatorSummaryEditable(summary);

        // Create version data - existing method will create a "Submitted" QISV
        createQIVersionData(summaryId);
        Quality_Indicator_Summary_Version__c summaryVersion = getLatestSummaryVersion(summaryId);

        // Update domain draft version with data from form
        saveFormSectionVersionComplete(formData, recordTypeId, recordTypeName, summaryId, summaryVersion.Id, warningFlag);
    }

    /**
     * Creates a new version of the QIS record along with its child QID/QIT records
     */
    public static void createQIVersionData(Id summaryId) {
        List<Quality_Indicator_Summary__c> summary = getSummaryWithAllFields(summaryId);
        QIVersionsController.createDraftQIVersions(summary, QI_Status_InProgress);   
    }

    /**
     * Given a summary Id retrieve the last modified date and by details
     */
    @AuraEnabled(cacheable=true)
    public static String getLastModifiedDetails(String summaryId) {
        LastModifiedDetails result = new LastModifiedDetails();
        if( getSummary(summaryId) != null){
            String lastModifiedById;
            String lastModifiedDate;
            Quality_Indicator_Summary__c summary = getSummary(summaryId);
            User currentUser;
            // was a qid most recently updated?
            if(summary.Quality_Indicators__r != null && summary.Quality_Indicators__r.size() > 0){
                result.lastModifiedByName = summary.Quality_Indicators__r[0].LastModifiedBy.Name;
                result.lastModifiedDate = summary.Quality_Indicators__r[0].LastModifiedDate;
                lastModifiedById = summary.Quality_Indicators__r[0].LastModifiedById;
                for(User usr : [SELECT Id , Name , Profile.Name , Profile.UserType  FROM User WHERE Id = :lastModifiedById]){
                    currentUser = usr;
                }
            }
            
            if(currentUser != null){
                if(currentUser.Profile.UserType == 'PowerCustomerSuccess'){
                    result.isInternal = false;
                }else{
                    result.isInternal = true;
                }
            }else{
                result.isInternal = true;
            }

            return JSON.serialize(result);
        }
        return null;
    }

    /**
     * Fetches validation and status data for all QID records for the given QIS record.
     * Used to show status for each domain in the navigation stepper.
     */
    @AuraEnabled
    public static List<Quality_Indicator_Details__c> getQIStatus(Id summaryId) {
        List<Quality_Indicator_Details__c> qiDetailStatus = new List<Quality_Indicator_Details__c>();
       
		String query = 'SELECT Id, Error_Flag__c, Status__c, RecordType.Name FROM Quality_Indicator_Details__c WHERE QI_Summary_Id__c = \'' + summaryId + '\' Order by RecordType.Name'; 
        try {
             qiDetailStatus = Database.query(query);
        }catch(Exception ex){
            dohagedcare.Logger.error(ex.getMessage(), ex, 'QISR').log();
            String errorMessage = 'Error in getting Quality_Indicator_Details__c record. Please refresh page or contact system administrator';
            throw new AuraHandledException(JSON.serialize(new List<String>{ errorMessage }));
        }
        return qiDetailStatus;
    }

    /**
     * Checks whether the QIS record is migrated data and therefore requires only five domains instead of the eleven domains for new data
     */
    public static Boolean isFiveDomainsRequired(Id qiSummaryId) {
        Date fiveDomainsRPEndDate = (Date)Quality_Indicator_Settings__mdt.getInstance('QI_Stepper_for_Go_Live').Five_Domains_RP_End_Date__c;
        Quality_Indicator_Summary__c summary = getSummary(qiSummaryId);
        Date rpEndDate = summary.Reporting_Period__r.End_Date__c;
        return rpEndDate <= fiveDomainsRPEndDate;
    }

    /**
     * Helper function to return one question section per type field.
     * Used to get a unique list of domains/types for display in the navigation.
     */
    public static List<Question_Section__c> getOneQuestionSectionPerType(List<Question_Section__c> questionSections) {
        Set<String> uniqueTypes = new Set<String>();
        List<Question_Section__c> uniqueQuestionSectionsByType = new List<Question_Section__c>();

        for (Question_Section__c questionSection : questionSections) {
            if (!uniqueTypes.contains(questionSection.Type__c)) {
                uniqueTypes.add(questionSection.Type__c);
                uniqueQuestionSectionsByType.add(questionSection);
            }
        }

        return uniqueQuestionSectionsByType;
    }
}