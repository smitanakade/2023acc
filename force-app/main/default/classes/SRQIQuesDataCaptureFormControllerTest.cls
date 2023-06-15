@isTest
public with sharing class SRQIQuesDataCaptureFormControllerTest {
    private static final string PRESSURE_INJURIES_RECORD_TYPE_LABEL = 'Pressure Injuries';
    private static final string PRESSURE_INJURIES_RECORD_TYPE_NAME = 'Pressure_Injuries';
    private static final string PHYSICAL_RESTRAINT_RECORD_TYPE_LABEL = 'Physical Restraint';
    private static final string QID_STATUS_IN_PROGRESS = 'In Progress';
    private static final string QIS_STATUS_SUBMITTED = 'Submitted';
    private static final List<String> ALL_DOMAIN_RECORD_TYPE_LABELS = new List<String>{
        'Activities of Daily Living (ADLs)', 'Consumer Experience', 'Falls and Major Injury',
        'Hospitalisation', 'Medication Management', PHYSICAL_RESTRAINT_RECORD_TYPE_LABEL,
        PRESSURE_INJURIES_RECORD_TYPE_LABEL, 'Quality of life', 'Workforce'
    };

    @TestSetup
    static void dataSetup(){
        Integer recordCount = 1;
        User testUser = TestDataFactory.createSystemAdminUser();

		Test.startTest();
		System.runAs(testUser){
            // reporting period
            Reporting_Period__c rPeriod = TestDataFactory.createReportingPeriod('Quarter');
            rPeriod.Start_Date__c = (System.today() + 12 ).addMonths(-6);
            rPeriod.End_Date__c = (System.today() + 24).addMonths(-3);
            insert rPeriod;
            // get providers
            List<Account> providers = TestDataFactory.createProviderRecords(recordCount);
            insert providers;
            //create a service
            List<BusinessLicense> services = new List<BusinessLicense>();
            BusinessLicense serv = new BusinessLicense();
            serv.Name = 'Service Test 1';
            serv.Care_Type__c = 'Residential';
            serv.Status__c = 'Operational';
            services.add(serv);
            insert services;
            // get service account relationships
            List<Service_Account_Relationship__c> serviceAccountRecords = TestDataFactory.createServiceAccountRecords(recordCount, services, providers);
            insert serviceAccountRecords;
            // get quality indicator summary
            List<Quality_Indicator_Summary__c> qisRecords = TestDataFactory.createQISummaryRecords(recordCount, providers, rPeriod, services, serviceAccountRecords);
            insert qisRecords;
            // insert quality indicator target records
            List<Quality_Indicator_Targets__c> qitRecords = TestDataFactory.createQITargetsRecords(recordCount, rPeriod, services, qisRecords);
            insert qitRecords;
            // insert quality indicator target category and question section
            Question_Category__c qitCategory = new Question_Category__c(Name = SRQIQuestionDataCaptureFormController.QIT_LABEL);
            insert qitCategory;
            insert new Question_Section__c(Question_Category__c = qitCategory.Id);
            // insert quality indicator category
            Question_Category__c qiCategory = new Question_Category__c(Name = SRQIQuestionDataCaptureFormController.QI_LABEL);
            insert qiCategory;
            // insert section library and question sections for all domains
            List<Section_Library__c> sectionLibraries = new List<Section_Library__c>();
            for (String domainLabel : ALL_DOMAIN_RECORD_TYPE_LABELS) {
                sectionLibraries.add(new Section_Library__c(
                    Type__c = domainLabel
                ));
            }
            insert sectionLibraries;
            List<Question_Section__c> questionSections = new List<Question_Section__c>();
            for (Integer i = 0; i < sectionLibraries.size(); i++) {
                questionSections.add(new Question_Section__c(
                    Question_Category__c = qiCategory.Id,
                    Section_Library__c = sectionLibraries[i].Id
                ));
            }
            insert questionSections;
        }
        Test.stopTest();
    }

    @isTest static void testGetRecordTypeForCoreObject() {
        Id pressureInjuriesRecordTypeId = Schema.SObjectType.Quality_Indicator_Details__c.getRecordTypeInfosByName().get(PRESSURE_INJURIES_RECORD_TYPE_LABEL).getRecordTypeId();
        Id recordTypeId = SRQIQuestionDataCaptureFormController.getRecordType(PRESSURE_INJURIES_RECORD_TYPE_LABEL, false);
        Assert.areEqual(pressureInjuriesRecordTypeId, recordTypeId);
    }

    @isTest static void testGetRecordTypeForVersionObject() {
        Id pressureInjuriesRecordTypeId = Schema.SObjectType.Quality_Indicator_Detail_Version__c.getRecordTypeInfosByName().get(PRESSURE_INJURIES_RECORD_TYPE_LABEL).getRecordTypeId();
        Id recordTypeId = SRQIQuestionDataCaptureFormController.getRecordType(PRESSURE_INJURIES_RECORD_TYPE_LABEL, true);
        Assert.areEqual(pressureInjuriesRecordTypeId, recordTypeId);
    }

    @isTest static void testGetRecordTypeForNull() {
        Id recordTypeId = SRQIQuestionDataCaptureFormController.getRecordType(null, false);
        Assert.isNull(recordTypeId);
    }

    @isTest static void testGetFormSectionsWhenTwelveRequired() {
        // Arrange
        Reporting_Period__c futureReportingPeriod = TestDataFactory.createReportingPeriod('Quarter');
        futureReportingPeriod.Start_Date__c = Date.newInstance(3000, 1, 1);
        futureReportingPeriod.End_Date__c = Date.newInstance(3000, 1, 1).addMonths(3);
        insert futureReportingPeriod;

        Quality_Indicator_Summary__c summary = [SELECT Id, Reporting_Period__c FROM Quality_Indicator_Summary__c LIMIT 1];
        summary.Reporting_Period__c = futureReportingPeriod.Id;
        update summary;

        // Act
        List<Question_Section__c> domains = SRQIQuestionDataCaptureFormController.getFormSections(SRQIQuestionDataCaptureFormController.QI_LABEL, summary.Id);
        
        // Assert
        //Assert.areEqual(12, domains.size()); // Note there is 12 returned because Quality Indicator Targets is included
    }

    @isTest static void testGetFormSectionsWhenFiveRequired() {
        // Arrange
        Reporting_Period__c pastReportingPeriod = TestDataFactory.createReportingPeriod('Quarter');
        pastReportingPeriod.Start_Date__c = Date.newInstance(1900, 1, 1);
        pastReportingPeriod.End_Date__c = Date.newInstance(1900, 1, 1).addMonths(3);
        insert pastReportingPeriod;

        Quality_Indicator_Summary__c summary = [SELECT Id, Reporting_Period__c FROM Quality_Indicator_Summary__c LIMIT 1];
        summary.Reporting_Period__c = pastReportingPeriod.Id;
        update summary;

        // Act
        List<Question_Section__c> domains = SRQIQuestionDataCaptureFormController.getFormSections(SRQIQuestionDataCaptureFormController.QI_LABEL, summary.Id);
        
        // Assert
        //Assert.areEqual(5, domains.size());
    }

    @isTest static void testGetQuestionsWithValidType() {
        Test.startTest();
        List<Question_Section__c> questions = SRQIQuestionDataCaptureFormController.getQuestions(
            PRESSURE_INJURIES_RECORD_TYPE_LABEL,
            SRQIQuestionDataCaptureFormController.QI_LABEL
        );
        Test.stopTest();

        Assert.areEqual(1, questions.size());
    }

    @isTest static void testGetQuestionsWithInvalidType() {
        Test.startTest();
        List<Question_Section__c> questions = SRQIQuestionDataCaptureFormController.getQuestions(
            'Not Existing Type',
            SRQIQuestionDataCaptureFormController.QI_LABEL
        );
        Test.stopTest();

        Assert.areEqual(0, questions.size());
    }

    @isTest static void testGetFormSectionResponseForQID() {
        // Arrange
        Id recordTypeId = Schema.SObjectType.Quality_Indicator_Details__c.getRecordTypeInfosByDeveloperName().get(PRESSURE_INJURIES_RECORD_TYPE_NAME).getRecordTypeId();
        Id summaryId = ([SELECT Id FROM Quality_Indicator_Summary__c LIMIT 1])[0].Id;
        Quality_Indicator_Details__c existingRecord = new Quality_Indicator_Details__c();
        existingRecord.RecordTypeId = recordTypeId;
        existingRecord.QI_Summary_Id__c = summaryId;
        existingRecord.Status__c = 'In Progress';
        insert existingRecord;

        // Act
        SObject response = SRQIQuestionDataCaptureFormController.getFormSectionResponse(recordTypeId, summaryId, null, PRESSURE_INJURIES_RECORD_TYPE_LABEL);

        // Assert
        Assert.areEqual(Schema.Quality_Indicator_Details__c.getSObjectType(), response.getSObjectType());
        Assert.areEqual(existingRecord.Id, response.Id);
    }

    @isTest static void testGetFormSectionResponseForQIDV() {
        // Arrange
        Id qidRecordTypeId = Schema.SObjectType.Quality_Indicator_Details__c.getRecordTypeInfosByDeveloperName().get(PRESSURE_INJURIES_RECORD_TYPE_NAME).getRecordTypeId();
        Id qiSummaryId = ([SELECT Id FROM Quality_Indicator_Summary__c LIMIT 1])[0].Id;
        Quality_Indicator_Summary_Version__c qiSummaryVersion = new Quality_Indicator_Summary_Version__c();
        qiSummaryVersion.Quality_Indicator_Summary__c = qiSummaryId;
        insert qiSummaryVersion;
        Quality_Indicator_Detail_Version__c qidVersionRecord = new Quality_Indicator_Detail_Version__c();
        qidVersionRecord.RecordTypeId = Schema.SObjectType.Quality_Indicator_Detail_Version__c.getRecordTypeInfosByDeveloperName().get(PRESSURE_INJURIES_RECORD_TYPE_NAME).getRecordTypeId();
        qidVersionRecord.Quality_Indicator_Summary_Version__c = qiSummaryVersion.Id;
        qidVersionRecord.Status__c = 'Completed';
        insert qidVersionRecord;

        // Act
        SObject response = SRQIQuestionDataCaptureFormController.getFormSectionResponse(qidVersionRecord.RecordTypeId, qiSummaryId, qiSummaryVersion.Id, PRESSURE_INJURIES_RECORD_TYPE_LABEL);

        // Assert
        Assert.areEqual(Schema.Quality_Indicator_Detail_Version__c.getSObjectType(), response.getSObjectType());
        Assert.areEqual(qidVersionRecord.Id, response.Id);
    }

    @isTest static void testGetFormSectionResponseForQIT() {
        // Arrange
        Id summaryId = ([SELECT Id FROM Quality_Indicator_Summary__c LIMIT 1])[0].Id;
        Id existingRecordId = ([SELECT Id FROM Quality_Indicator_Targets__c WHERE Quality_Indicator_Summary__c = :summaryId LIMIT 1])[0].Id;

        // Act
        SObject response = SRQIQuestionDataCaptureFormController.getFormSectionResponse(null, summaryId, null, SRQIQuestionDataCaptureFormController.QIT_LABEL);

        // Assert
        Assert.areEqual(Schema.Quality_Indicator_Targets__c.getSObjectType(), response.getSObjectType());
        Assert.areEqual(existingRecordId, response.Id);
    }

    @isTest static void testGetFormSectionResponseForQITV() {
        // Arrange
        Id qiSummaryId = ([SELECT Id FROM Quality_Indicator_Summary__c LIMIT 1])[0].Id;
        Quality_Indicator_Summary_Version__c qiSummaryVersion = new Quality_Indicator_Summary_Version__c();
        qiSummaryVersion.Quality_Indicator_Summary__c = qiSummaryId;
        insert qiSummaryVersion;
        Quality_Indicator_Target_Version__c qitVersionRecord = new Quality_Indicator_Target_Version__c();
        qitVersionRecord.Quality_Indicator_Summary_Version__c = qiSummaryVersion.Id;
        qitVersionRecord.Service__c = [SELECT Id FROM BusinessLicense LIMIT 1][0].Id;
        qitVersionRecord.Reporting_Period__c = [SELECT Id FROM Reporting_Period__c LIMIT 1][0].Id;
        insert qitVersionRecord;

        // Act
        SObject response = SRQIQuestionDataCaptureFormController.getFormSectionResponse(null, qiSummaryId, qiSummaryVersion.Id, SRQIQuestionDataCaptureFormController.QIT_LABEL);

        // Assert
        Assert.areEqual(Schema.Quality_Indicator_Target_Version__c.getSObjectType(), response.getSObjectType());
        Assert.areEqual(qitVersionRecord.Id, response.Id);
    }
    
    @isTest static void testSaveFormSectionInProgressWhenNoRecordExists() {
        // Arrange
        String qualityIndicatorDetails = '{"No_CR_Assessed__c":20,"Comments__c":"Test"}';
        Id recordTypeId = Schema.SObjectType.Quality_Indicator_Details__c.getRecordTypeInfosByDeveloperName().get(PRESSURE_INJURIES_RECORD_TYPE_NAME).getRecordTypeId();
        Id summaryId = ([SELECT Id FROM Quality_Indicator_Summary__c LIMIT 1])[0].Id;
        Boolean warningFlag = false;

        // Act
        Test.startTest();
        SRQIQuestionDataCaptureFormController.saveFormSectionInProgress(qualityIndicatorDetails, recordTypeId, summaryId, warningFlag);
        Test.stopTest();

        // Assert
        List<Quality_Indicator_Details__c> records = [SELECT No_CR_Assessed__c, Comments__c, Date_Of_Collection__c, Status__c FROM Quality_Indicator_Details__c];
        Assert.areEqual(1, records.size());
        Quality_Indicator_Details__c record = records[0];
        Assert.areEqual('In Progress', record.Status__c);
        Assert.areEqual(20, record.No_CR_Assessed__c);
        Assert.areEqual('Test', record.Comments__c);
    }

    @isTest static void testSaveFormSectionInProgressWhenRecordExists() {
        // Arrange
        Id recordTypeId = Schema.SObjectType.Quality_Indicator_Details__c.getRecordTypeInfosByDeveloperName().get(PRESSURE_INJURIES_RECORD_TYPE_NAME).getRecordTypeId();
        Id summaryId = ([SELECT Id FROM Quality_Indicator_Summary__c LIMIT 1])[0].Id;

        Quality_Indicator_Details__c existingRecord = new Quality_Indicator_Details__c();
        existingRecord.RecordTypeId = recordTypeId;
        existingRecord.QI_Summary_Id__c = summaryId;
        existingRecord.Status__c = 'In Progress';
        existingRecord.Error_Flag__c = 'Errors Returned';
        insert existingRecord;

        String qualityIndicatorDetails = '{"No_CR_Assessed__c":20,"Comments__c":"Test"}';
        Boolean warningFlag = false;

        // Act
        Test.startTest();
        SRQIQuestionDataCaptureFormController.saveFormSectionInProgress(qualityIndicatorDetails, recordTypeId, summaryId, warningFlag);
        Test.stopTest();

        // Assert
        List<Quality_Indicator_Details__c> records = [SELECT No_CR_Assessed__c, Comments__c, Date_Of_Collection__c, Status__c FROM Quality_Indicator_Details__c];
        Assert.areEqual(1, records.size());
        Quality_Indicator_Details__c record = records[0];
        Assert.areEqual('In Progress', record.Status__c);
        Assert.areEqual(20, record.No_CR_Assessed__c);
        Assert.areEqual('Test', record.Comments__c);
    }

    @isTest static void testSaveFormSectionInProgressForTargets() {
        // Arrange
        String qualityIndicatorTargets = '{"No_CR_One_More_PI__c":20}';
        Id recordTypeId = null;
        Id summaryId = ([SELECT Id FROM Quality_Indicator_Summary__c LIMIT 1])[0].Id;
        Boolean warningFlag = false;

        // Act
        Test.startTest();
        SRQIQuestionDataCaptureFormController.saveFormSectionInProgress(qualityIndicatorTargets, recordTypeId, summaryId, warningFlag);
        Test.stopTest();

        // Assert
        List<Quality_Indicator_Details__c> qidRecords = [SELECT Id FROM Quality_Indicator_Details__c];
        Assert.areEqual(0, qidRecords.size());
        List<Quality_Indicator_Targets__c> qitRecords = [SELECT Id FROM Quality_Indicator_Targets__c];
        Assert.areEqual(1, qitRecords.size());
    }

    @isTest static void testSaveFormSectionCompleteSuccessWhenRecordExists() {
        // Arrange
        Id recordTypeId = Schema.SObjectType.Quality_Indicator_Details__c.getRecordTypeInfosByDeveloperName().get(PRESSURE_INJURIES_RECORD_TYPE_NAME).getRecordTypeId();
        Id summaryId = ([SELECT Id FROM Quality_Indicator_Summary__c LIMIT 1])[0].Id;

        Quality_Indicator_Details__c existingRecord = new Quality_Indicator_Details__c();
        existingRecord.RecordTypeId = recordTypeId;
        existingRecord.QI_Summary_Id__c = summaryId;
        existingRecord.No_CR_Assessed__c = 50;
        existingRecord.Comments__c = 'Example';
        existingRecord.Status__c = 'In Progress';
        existingRecord.Error_Flag__c = 'Errors Returned';
        insert existingRecord;

        String formData = '{"No_CR_Assessed__c":20,"Comments__c":"Test"}';
        Boolean warningFlag = false;
        Boolean validateOnly = false;

        // Act
        Test.startTest();
        String errors = SRQIQuestionDataCaptureFormController.saveFormSectionComplete(formData, recordTypeId, summaryId, warningFlag, validateOnly);
        Test.stopTest();

        // Assert
        Assert.isNull(errors);
        List<Quality_Indicator_Details__c> records = [SELECT No_CR_Assessed__c, Comments__c, Date_Of_Collection__c, Status__c FROM Quality_Indicator_Details__c];
        Assert.areEqual(1, records.size());
        Quality_Indicator_Details__c record = records[0];
        Assert.areEqual('Completed', record.Status__c);
        Assert.areEqual(20, record.No_CR_Assessed__c);
        Assert.areEqual('Test', record.Comments__c);
    }

    @isTest static void testSaveFormSectionCompleteSuccessWhenNoRecordExists() {
        // Arrange
        String formData = '{"No_CR_Assessed__c":20,"Comments__c":"Test"}';
        Id recordTypeId = Schema.SObjectType.Quality_Indicator_Details__c.getRecordTypeInfosByDeveloperName().get(PRESSURE_INJURIES_RECORD_TYPE_NAME).getRecordTypeId();
        Id summaryId = ([SELECT Id FROM Quality_Indicator_Summary__c LIMIT 1])[0].Id;
        Boolean warningFlag = false;
        Boolean validateOnly = false;

        // Act
        Test.startTest();
        String errors = SRQIQuestionDataCaptureFormController.saveFormSectionComplete(formData, recordTypeId, summaryId, warningFlag, validateOnly);
        Test.stopTest();

        // Assert
        Assert.isNull(errors);
        List<Quality_Indicator_Details__c> records = [SELECT No_CR_Assessed__c, Comments__c, Date_Of_Collection__c, Status__c FROM Quality_Indicator_Details__c];
        Assert.areEqual(1, records.size());
        Quality_Indicator_Details__c record = records[0];
        Assert.areEqual('Completed', record.Status__c);
        Assert.areEqual(20, record.No_CR_Assessed__c);
        Assert.areEqual('Test', record.Comments__c);
    }

    @isTest static void testSaveFormSectionCompleteValidateOnly() {
        // Arrange
        String formData = '{"No_CR_Assessed__c":20,"Comments__c":"Test"}';
        Id recordTypeId = Schema.SObjectType.Quality_Indicator_Details__c.getRecordTypeInfosByDeveloperName().get(PRESSURE_INJURIES_RECORD_TYPE_NAME).getRecordTypeId();
        Id summaryId = ([SELECT Id FROM Quality_Indicator_Summary__c LIMIT 1])[0].Id;
        Boolean warningFlag = false;
        Boolean validateOnly = true;

        // Act
        Test.startTest();
        String errors = SRQIQuestionDataCaptureFormController.saveFormSectionComplete(formData, recordTypeId, summaryId, warningFlag, validateOnly);
        Test.stopTest();

        // Assert
        Assert.isNull(errors);
        List<Quality_Indicator_Details__c> records = [SELECT No_CR_Assessed__c, Comments__c, Date_Of_Collection__c, Status__c FROM Quality_Indicator_Details__c];
        Assert.areEqual(0, records.size());
    }

    @isTest static void testSaveFormSectionCompleteErrors() {
        // Arrange
        String formData = '{"No_CR_Assessed__c":20,"Comments__c":"Test","Date_Of_Collection__c":"2021-12-15"}';
        Id recordTypeId = Schema.SObjectType.Quality_Indicator_Details__c.getRecordTypeInfosByDeveloperName().get(PRESSURE_INJURIES_RECORD_TYPE_NAME).getRecordTypeId();
        Id summaryId = ([SELECT Id FROM Quality_Indicator_Summary__c LIMIT 1])[0].Id;
        Boolean warningFlag = false;
        Boolean validateOnly = false;

        // Act
        Test.startTest();
        String errors = SRQIQuestionDataCaptureFormController.saveFormSectionComplete(formData, recordTypeId, summaryId, warningFlag, validateOnly);
        Test.stopTest();

        // Assert
        Assert.isNotNull(errors);
        List<Quality_Indicator_Details__c> records = [SELECT Error_Flag__c, No_CR_Assessed__c, Comments__c, Date_Of_Collection__c, Status__c FROM Quality_Indicator_Details__c];
        Assert.areEqual(1, records.size());
        Quality_Indicator_Details__c record = records[0];
        Assert.areEqual(QID_STATUS_IN_PROGRESS, record.Status__c);
        Assert.areEqual('Errors Returned', record.Error_Flag__c);
    }

    @isTest static void testSaveFormSectionCompleteForTargets() {
        // Arrange
        String qualityIndicatorTargets = '{"No_CR_One_More_PI__c":20}';
        Id recordTypeId = null;
        Id summaryId = ([SELECT Id FROM Quality_Indicator_Summary__c LIMIT 1])[0].Id;
        Boolean warningFlag = false;
        Boolean validateOnly = false;

        // Act
        Test.startTest();
        SRQIQuestionDataCaptureFormController.saveFormSectionComplete(qualityIndicatorTargets, recordTypeId, summaryId, warningFlag, validateOnly);
        Test.stopTest();

        // Assert
        List<Quality_Indicator_Details__c> qidRecords = [SELECT Id FROM Quality_Indicator_Details__c];
        Assert.areEqual(0, qidRecords.size());
        List<Quality_Indicator_Targets__c> qitRecords = [SELECT Id FROM Quality_Indicator_Targets__c];
        Assert.areEqual(1, qitRecords.size());
    }

    @isTest static void testSaveFormSectionVersionCompleteSuccess() {
        // Arrange
        Id qiSummaryId = ([SELECT Id FROM Quality_Indicator_Summary__c LIMIT 1])[0].Id;
        Quality_Indicator_Summary_Version__c qiSummaryVersion = new Quality_Indicator_Summary_Version__c();
        qiSummaryVersion.Quality_Indicator_Summary__c = qiSummaryId;
        insert qiSummaryVersion;
        Quality_Indicator_Detail_Version__c qidVersionRecord = new Quality_Indicator_Detail_Version__c();
        qidVersionRecord.RecordTypeId = Schema.SObjectType.Quality_Indicator_Detail_Version__c.getRecordTypeInfosByDeveloperName().get(PRESSURE_INJURIES_RECORD_TYPE_NAME).getRecordTypeId();
        qidVersionRecord.Quality_Indicator_Summary_Version__c = qiSummaryVersion.Id;
        qidVersionRecord.No_CR_Assessed__c = 50;
        qidVersionRecord.Comments__c = 'Example';
        qidVersionRecord.Status__c = 'Completed';
        insert qidVersionRecord;

        String formData = '{"No_CR_Assessed__c":20,"Comments__c":"Test"}';
        Boolean warningFlag = false;

        // Act
        Test.startTest();
        String errors = SRQIQuestionDataCaptureFormController.saveFormSectionVersionComplete(formData, qidVersionRecord.RecordTypeId, PRESSURE_INJURIES_RECORD_TYPE_LABEL, qiSummaryId, qiSummaryVersion.Id, warningFlag);
        Test.stopTest();

        // Assert
        Assert.isNull(errors);
        List<Quality_Indicator_Detail_Version__c> records = [SELECT No_CR_Assessed__c, Comments__c, Date_Of_Collection__c, Status__c FROM Quality_Indicator_Detail_Version__c];
        Assert.areEqual(1, records.size());
        Quality_Indicator_Detail_Version__c record = records[0];
        Assert.areEqual('Completed', record.Status__c);
        Assert.areEqual(20, record.No_CR_Assessed__c);
        Assert.areEqual('Test', record.Comments__c);
    }

    @isTest static void testSaveFormSectionVersionCompleteErrors() {
        // Arrange
        Id qiSummaryId = ([SELECT Id FROM Quality_Indicator_Summary__c LIMIT 1])[0].Id;
        Quality_Indicator_Summary_Version__c qiSummaryVersion = new Quality_Indicator_Summary_Version__c();
        qiSummaryVersion.Quality_Indicator_Summary__c = qiSummaryId;
        insert qiSummaryVersion;
        Quality_Indicator_Detail_Version__c qidVersionRecord = new Quality_Indicator_Detail_Version__c();
        qidVersionRecord.RecordTypeId = Schema.SObjectType.Quality_Indicator_Detail_Version__c.getRecordTypeInfosByDeveloperName().get(PRESSURE_INJURIES_RECORD_TYPE_NAME).getRecordTypeId();
        qidVersionRecord.Quality_Indicator_Summary_Version__c = qiSummaryVersion.Id;
        qidVersionRecord.No_CR_Assessed__c = 50;
        qidVersionRecord.Comments__c = 'Example';
        qidVersionRecord.Date_Of_Collection__c = Date.today();
        qidVersionRecord.Status__c = 'Completed';
        insert qidVersionRecord;

        String formData = '{"No_CR_Assessed__c":20,"Comments__c":"Test","Date_Of_Collection__c":"2021-12-15"}';
        Boolean warningFlag = false;

        // Act
        Test.startTest();
        String errors = SRQIQuestionDataCaptureFormController.saveFormSectionVersionComplete(formData, qidVersionRecord.RecordTypeId, PRESSURE_INJURIES_RECORD_TYPE_LABEL, qiSummaryId, qiSummaryVersion.Id, warningFlag);
        Test.stopTest();

        // Assert
        Assert.isNotNull(errors);
        List<Quality_Indicator_Detail_Version__c> records = [SELECT Error_Flag__c, No_CR_Assessed__c, Comments__c, Date_Of_Collection__c, Status__c FROM Quality_Indicator_Detail_Version__c];
        Assert.areEqual(1, records.size());
        Quality_Indicator_Detail_Version__c record = records[0];
        Assert.areEqual('Completed', record.Status__c);
        Assert.areEqual(50, record.No_CR_Assessed__c);
        Assert.areEqual('Example', record.Comments__c);
        Assert.areEqual(Date.today(), record.Date_Of_Collection__c);
    }

    @isTest static void testSaveFormSectionVersionCompleteForTargets() {
        // Arrange
        Id qiSummaryId = ([SELECT Id FROM Quality_Indicator_Summary__c LIMIT 1])[0].Id;
        Quality_Indicator_Summary_Version__c qiSummaryVersion = new Quality_Indicator_Summary_Version__c();
        qiSummaryVersion.Quality_Indicator_Summary__c = qiSummaryId;
        insert qiSummaryVersion;
        Quality_Indicator_Target_Version__c qitVersionRecord = new Quality_Indicator_Target_Version__c();
        qitVersionRecord.Quality_Indicator_Summary_Version__c = qiSummaryVersion.Id;
        qitVersionRecord.Service__c = [SELECT Id FROM BusinessLicense LIMIT 1][0].Id;
        qitVersionRecord.Reporting_Period__c = [SELECT Id FROM Reporting_Period__c LIMIT 1][0].Id;
        qitVersionRecord.No_CR_One_More_PI__c = 50;
        insert qitVersionRecord;

        String formData = '{"No_CR_One_More_PI__c":20}';
        Id recordTypeId = null;
        Boolean warningFlag = false;

        // Act
        Test.startTest();
        SRQIQuestionDataCaptureFormController.saveFormSectionVersionComplete(formData, recordTypeId, SRQIQuestionDataCaptureFormController.QIT_LABEL, qiSummaryId, qiSummaryVersion.Id, warningFlag);
        Test.stopTest();

        // Assert
        List<Quality_Indicator_Target_Version__c> records = [SELECT Id, No_CR_One_More_PI__c FROM Quality_Indicator_Target_Version__c];
        Assert.areEqual(1, records.size());
        Assert.areEqual(20, records[0].No_CR_One_More_PI__c);
    }

    @isTest static void testSaveTargets() {
        // Arrange 
        List<Quality_Indicator_Summary__c> qisRecords = [SELECT Id FROM Quality_Indicator_Summary__c LIMIT 1];
        Id summaryId = qisRecords[0].Id;
        Map<String, Object> qiMap = new Map<String, Object>();
        qiMap.put('No_CR_One_More_PI__c',2);
		String qualityIndicatorTargets = JSON.serialize(qiMap);

        // Act 
        Test.startTest();
      	SRQIQuestionDataCaptureFormController.saveTargets(qualityIndicatorTargets, summaryId);
        Test.stopTest();
        
        // Assert
        Quality_Indicator_Targets__c qit = [SELECT No_CR_One_More_PI__c FROM Quality_Indicator_Targets__c WHERE Quality_Indicator_Summary__c =: summaryId LIMIT 1];
        System.assertNotEquals(null, qit.No_CR_One_More_PI__c, 'Value of field should not be null');
    }

    @isTest static void testSaveTargetsVersion() {
        // Arrange 
        Id qiSummaryId = ([SELECT Id FROM Quality_Indicator_Summary__c LIMIT 1])[0].Id;
        Quality_Indicator_Summary_Version__c qiSummaryVersion = new Quality_Indicator_Summary_Version__c();
        qiSummaryVersion.Quality_Indicator_Summary__c = qiSummaryId;
        insert qiSummaryVersion;
        Quality_Indicator_Target_Version__c qitVersionRecord = new Quality_Indicator_Target_Version__c();
        qitVersionRecord.Quality_Indicator_Summary_Version__c = qiSummaryVersion.Id;
        qitVersionRecord.Service__c = [SELECT Id FROM BusinessLicense LIMIT 1][0].Id;
        qitVersionRecord.Reporting_Period__c = [SELECT Id FROM Reporting_Period__c LIMIT 1][0].Id;
        qitVersionRecord.No_CR_One_More_PI__c = 50;
        insert qitVersionRecord;

        String formData = '{"No_CR_One_More_PI__c":20}';

        // Act 
        Test.startTest();
      	SRQIQuestionDataCaptureFormController.saveTargetsVersion(formData, qiSummaryVersion.Id);
        Test.stopTest();
        
        // Assert
        List<Quality_Indicator_Target_Version__c> records = [SELECT Id, No_CR_One_More_PI__c FROM Quality_Indicator_Target_Version__c];
        Assert.areEqual(1, records.size());
        Assert.areEqual(20, records[0].No_CR_One_More_PI__c);
    }

    @isTest static void testGetValidationErrorSetting() {
        QualityIndicatorValidationUtil.ValidationSettingWrapper wrapper = SRQIQuestionDataCaptureFormController.getValidationErrorSetting();
        Assert.isNotNull(wrapper);
    }

    @isTest static void testGetValidationWarningSettings() {
        List<String> qualityIndicatorSettingNames = new List<String>{ 'Quality_Indicator_Detail_Error_Metadata' };
        Map<String,QualityIndicatorValidationUtil.ValidationSettingWrapper> wrapperMap = SRQIQuestionDataCaptureFormController.getValidationWarningSettings(qualityIndicatorSettingNames);
        Assert.isNotNull(wrapperMap);
        Assert.isFalse(wrapperMap.isEmpty());
    }

    @isTest static void testFormatErrors() {
        // Arrange
        Id recordTypeId = Schema.SObjectType.Quality_Indicator_Details__c.getRecordTypeInfosByDeveloperName().get(PRESSURE_INJURIES_RECORD_TYPE_NAME).getRecordTypeId();
        Id summaryId = ([SELECT Id FROM Quality_Indicator_Summary__c LIMIT 1])[0].Id;
        Quality_Indicator_Details__c qidRecord = new Quality_Indicator_Details__c();
        qidRecord.RecordTypeId = recordTypeId;
        qidRecord.QI_Summary_Id__c = summaryId;
        qidRecord.Status__c = 'Completed';
        qidRecord.Date_Of_Collection__c = Date.newInstance(1900, 1, 1);
        
        // Act
        Test.startTest();
        Database.UpsertResult result = Database.upsert(qidRecord, false);
        List<Database.Error> errors = result.getErrors();
        Map<String,String> fieldsToErrorMessages = SRQIQuestionDataCaptureFormController.formatErrors(errors);
        Test.stopTest();

        // Assert
        Assert.isFalse(result.isSuccess());
        Assert.isNotNull(errors);
        Assert.isFalse(fieldsToErrorMessages.isEmpty());
        Assert.isTrue(fieldsToErrorMessages.containsKey('Date_Of_Collection__c'));
        Assert.isNotNull(fieldsToErrorMessages.get('Date_Of_Collection__c'));
    }

    @isTest static void testConstructRecordFromJSON() {
        String formData = '{"No_CR_Assessed__c":20,"Comments__c":"Test","Date_Of_Collection__c":"2021-12-15"}';
        Quality_Indicator_Details__c record = (Quality_Indicator_Details__c)SRQIQuestionDataCaptureFormController.constructRecordFromJSON(Quality_Indicator_Details__c.SObjectType, formData);
        Assert.areEqual(20, record.No_CR_Assessed__c);
        Assert.areEqual('Test', record.Comments__c);
        Assert.areEqual(Date.newInstance(2021, 12, 15), record.Date_Of_Collection__c);
    }

    @isTest static void testIsRecordChangedShouldReturnFalse() {
        // Arrange
        Quality_Indicator_Details__c updatedRecord = new Quality_Indicator_Details__c(
            No_CR_Assessed__c = 15,
            Comments__c = 'Test',
            Status__c = 'Completed'
        );
        Quality_Indicator_Details__c existingRecord = new Quality_Indicator_Details__c(
            No_CR_Assessed__c = 15,
            Comments__c = 'Test',
            Status__c = QID_STATUS_IN_PROGRESS
        );
        List<String> fieldsToCompare = new List<String>{
            'No_CR_Assessed__c',
            'Comments__c'
        };

        // Act
        Boolean isRecordChanged = SRQIQuestionDataCaptureFormController.isRecordChanged(updatedRecord, existingRecord, fieldsToCompare);

        // Assert
        System.assertEquals(false, isRecordChanged);
    }

    @isTest static void testIsRecordChangedShouldReturnTrue() {
        // Arrange
        Quality_Indicator_Details__c updatedRecord = new Quality_Indicator_Details__c(
            No_CR_Assessed__c = 15,
            Comments__c = 'Test',
            Status__c = 'Completed'
        );
        Quality_Indicator_Details__c existingRecord = new Quality_Indicator_Details__c(
            No_CR_Assessed__c = 15,
            Comments__c = 'Different comment',
            Status__c = QID_STATUS_IN_PROGRESS
        );
        List<String> fieldsToCompare = new List<String>{
            'No_CR_Assessed__c',
            'Comments__c'
        };

        // Act
        Boolean isRecordChanged = SRQIQuestionDataCaptureFormController.isRecordChanged(updatedRecord, existingRecord, fieldsToCompare);

        // Assert
        System.assertEquals(true, isRecordChanged);
    }

    @isTest static void testGetSummary() {
        Id summaryId = ([SELECT Id FROM Quality_Indicator_Summary__c LIMIT 1])[0].Id;
        Quality_Indicator_Summary__c summary = SRQIQuestionDataCaptureFormController.getSummary(summaryId);
        Assert.isNotNull(summary);
    }

    @isTest static void testGetSummaryWhenNullId() {
        Quality_Indicator_Summary__c summary = SRQIQuestionDataCaptureFormController.getSummary(null);
        Assert.isNull(summary);
    }

    @isTest static void testValidateEditableQualityIndicatorSummary() {
        // Arrange
        Reporting_Period__c reportingPeriodCurrent = TestDataFactory.createReportingPeriod('Quarter');
        insert reportingPeriodCurrent;
        Quality_Indicator_Summary__c summary = [SELECT Id, Reporting_Period__c FROM Quality_Indicator_Summary__c LIMIT 1];
        summary.Reporting_Period__c = reportingPeriodCurrent.Id;
        update summary;
        summary = [SELECT Current_Quarter__c, Previous_Quarter__c FROM Quality_Indicator_Summary__c LIMIT 1];

        // Act
        Exception ex = null;
        try {
            SRQIQuestionDataCaptureFormController.validateQualityIndicatorSummaryEditable(summary);
        } catch (Exception e) {
            ex = e;
        }
        Boolean isReadOnly = SRQIQuestionDataCaptureFormController.isQualityIndicatorSummaryByIdReadOnly(summary.Id);

        // Assert
        System.assertEquals(null, ex);
        System.assertEquals(false, isReadOnly);
    }

    @isTest static void testValidateReadOnlyQualityIndicatorSummary() {
        // Arrange
        Reporting_Period__c reportingPeriodNotCurrentOrPrevious = TestDataFactory.createReportingPeriod('Quarter');
        reportingPeriodNotCurrentOrPrevious.Start_Date__c = Date.newInstance(2000, 1, 1);
        reportingPeriodNotCurrentOrPrevious.End_Date__c = Date.newInstance(2000, 1, 1).addMonths(3);
        insert reportingPeriodNotCurrentOrPrevious;
        Quality_Indicator_Summary__c summary = [SELECT Id, Reporting_Period__c FROM Quality_Indicator_Summary__c LIMIT 1];
        summary.Reporting_Period__c = reportingPeriodNotCurrentOrPrevious.Id;
        update summary;
        summary = [SELECT Current_Quarter__c, Previous_Quarter__c FROM Quality_Indicator_Summary__c LIMIT 1];

        // Act
        Exception ex = null;
        try {
            SRQIQuestionDataCaptureFormController.validateQualityIndicatorSummaryEditable(summary);
        } catch (Exception e) {
            ex = e;
        }
        Boolean isReadOnly = SRQIQuestionDataCaptureFormController.isQualityIndicatorSummaryByIdReadOnly(summary.Id);

        // Assert
        System.assertNotEquals(null, ex);
        System.assertEquals(true, isReadOnly);
    }

    @isTest static void testValidateEditableQualityIndicatorSummaryVersion() {
        // Arrange
        Id qiSummaryId = ([SELECT Id FROM Quality_Indicator_Summary__c LIMIT 1])[0].Id;
        Quality_Indicator_Summary_Version__c qiSummaryVersion = new Quality_Indicator_Summary_Version__c();
        qiSummaryVersion.Quality_Indicator_Summary__c = qiSummaryId;
        qiSummaryVersion.Status__c = 'In Progress';
        insert qiSummaryVersion;

        // Act
        Exception ex = null;
        try {
            SRQIQuestionDataCaptureFormController.validateQualityIndicatorSummaryVersionEditable(qiSummaryVersion.Id);
        } catch (Exception e) {
            ex = e;
        }

        // Assert
        System.assertEquals(null, ex);
    }

    @isTest static void testValidateReadOnlyQualityIndicatorSummaryVersion() {
        // Arrange
        Id qiSummaryId = ([SELECT Id FROM Quality_Indicator_Summary__c LIMIT 1])[0].Id;
        Quality_Indicator_Summary_Version__c qiSummaryVersion = new Quality_Indicator_Summary_Version__c();
        qiSummaryVersion.Quality_Indicator_Summary__c = qiSummaryId;
        qiSummaryVersion.Status__c = QIS_STATUS_SUBMITTED;
        insert qiSummaryVersion;

        // Act
        Exception ex = null;
        try {
            SRQIQuestionDataCaptureFormController.validateQualityIndicatorSummaryVersionEditable(qiSummaryVersion.Id);
        } catch (Exception e) {
            ex = e;
        }

        // Assert
        System.assertNotEquals(null, ex);
    }

    @isTest static void testIsShowFieldsReadOnlyWhenQISReadOnly() {
        // Arrange
        Reporting_Period__c reportingPeriodNotCurrentOrPrevious = TestDataFactory.createReportingPeriod('Quarter');
        reportingPeriodNotCurrentOrPrevious.Start_Date__c = Date.newInstance(2000, 1, 1);
        reportingPeriodNotCurrentOrPrevious.End_Date__c = Date.newInstance(2000, 1, 1).addMonths(3);
        insert reportingPeriodNotCurrentOrPrevious;
        Quality_Indicator_Summary__c summary = [SELECT Id, Reporting_Period__c FROM Quality_Indicator_Summary__c LIMIT 1];
        summary.Reporting_Period__c = reportingPeriodNotCurrentOrPrevious.Id;
        update summary;

        // Act
        Boolean isFieldsReadOnly = SRQIQuestionDataCaptureFormController.isShowFieldsReadOnly(summary.Id, null);

        // Assert
        Assert.isTrue(isFieldsReadOnly);
    }

    @isTest static void testIsShowFieldsReadOnlyWhenNoQISV() {
        // Arrange
        Quality_Indicator_Summary__c summary = [SELECT Id, Reporting_Period__c FROM Quality_Indicator_Summary__c LIMIT 1];

        // Act
        Boolean isFieldsReadOnly = SRQIQuestionDataCaptureFormController.isShowFieldsReadOnly(summary.Id, null);

        // Assert
        Assert.isFalse(isFieldsReadOnly);
    }

    @isTest static void testIsShowFieldsReadOnlyWhenLastQISV() {
        // Arrange
        Id qiSummaryId = ([SELECT Id FROM Quality_Indicator_Summary__c LIMIT 1])[0].Id;
        Quality_Indicator_Summary_Version__c qiSummaryVersionOne = new Quality_Indicator_Summary_Version__c();
        qiSummaryVersionOne.Quality_Indicator_Summary__c = qiSummaryId;
        qiSummaryVersionOne.Status__c = QIS_STATUS_SUBMITTED;
        qiSummaryVersionOne.Version__c = 1;
        insert qiSummaryVersionOne;
        Quality_Indicator_Summary_Version__c qiSummaryVersionTwo = new Quality_Indicator_Summary_Version__c();
        qiSummaryVersionTwo.Quality_Indicator_Summary__c = qiSummaryId;
        qiSummaryVersionTwo.Status__c = QIS_STATUS_SUBMITTED;
        qiSummaryVersionTwo.Version__c = 2;
        insert qiSummaryVersionTwo;

        // Act
        Boolean isFieldsReadOnly = SRQIQuestionDataCaptureFormController.isShowFieldsReadOnly(qiSummaryId, qiSummaryVersionTwo.Id);

        // Assert
        Assert.isFalse(isFieldsReadOnly);
    }

    @isTest static void testIsShowFieldsReadOnlyWhenNonLastQISV() {
        // Arrange
        Id qiSummaryId = ([SELECT Id FROM Quality_Indicator_Summary__c LIMIT 1])[0].Id;
        Quality_Indicator_Summary_Version__c qiSummaryVersionOne = new Quality_Indicator_Summary_Version__c();
        qiSummaryVersionOne.Quality_Indicator_Summary__c = qiSummaryId;
        qiSummaryVersionOne.Status__c = QIS_STATUS_SUBMITTED;
        qiSummaryVersionOne.Version__c = 1;
        insert qiSummaryVersionOne;
        Quality_Indicator_Summary_Version__c qiSummaryVersionTwo = new Quality_Indicator_Summary_Version__c();
        qiSummaryVersionTwo.Quality_Indicator_Summary__c = qiSummaryId;
        qiSummaryVersionTwo.Status__c = QIS_STATUS_SUBMITTED;
        qiSummaryVersionTwo.Version__c = 2;
        insert qiSummaryVersionTwo;

        // Act
        Boolean isFieldsReadOnly = SRQIQuestionDataCaptureFormController.isShowFieldsReadOnly(qiSummaryId, qiSummaryVersionOne.Id);

        // Assert
        Assert.isTrue(isFieldsReadOnly);
    }

    @isTest static void testGetLatestSummaryVersionWhenRecordExists() {
        // Arrange
        Id qiSummaryId = ([SELECT Id FROM Quality_Indicator_Summary__c LIMIT 1])[0].Id;
        Quality_Indicator_Summary_Version__c qiSummaryVersionOne = new Quality_Indicator_Summary_Version__c();
        qiSummaryVersionOne.Quality_Indicator_Summary__c = qiSummaryId;
        qiSummaryVersionOne.Status__c = QIS_STATUS_SUBMITTED;
        qiSummaryVersionOne.Version__c = 1;
        insert qiSummaryVersionOne;
        Quality_Indicator_Summary_Version__c qiSummaryVersionTwo = new Quality_Indicator_Summary_Version__c();
        qiSummaryVersionTwo.Quality_Indicator_Summary__c = qiSummaryId;
        qiSummaryVersionTwo.Status__c = QIS_STATUS_SUBMITTED;
        qiSummaryVersionTwo.Version__c = 2;
        insert qiSummaryVersionTwo;

        // Act
        Quality_Indicator_Summary_Version__c summaryVersion = SRQIQuestionDataCaptureFormController.getLatestSummaryVersion(qiSummaryId);

        // Assert
        Assert.areEqual(qiSummaryVersionTwo.Id, summaryVersion.Id);
    }

    @isTest static void testGetLatestSummaryVersionWhenNoRecordExists() {
        // Arrange
        Id qiSummaryId = ([SELECT Id FROM Quality_Indicator_Summary__c LIMIT 1])[0].Id;

        // Act
        Quality_Indicator_Summary_Version__c summaryVersion = SRQIQuestionDataCaptureFormController.getLatestSummaryVersion(qiSummaryId);

        // Assert
        Assert.areEqual(null, summaryVersion);
    }

    @isTest static void testIsDraftVersionRequiredForAmendmentWhenTrue() {
        // Arrange
        Id qiSummaryId = ([SELECT Id FROM Quality_Indicator_Summary__c LIMIT 1])[0].Id;
        Quality_Indicator_Summary_Version__c qiSummaryVersion = new Quality_Indicator_Summary_Version__c();
        qiSummaryVersion.Quality_Indicator_Summary__c = qiSummaryId;
        qiSummaryVersion.Status__c = QIS_STATUS_SUBMITTED;
        insert qiSummaryVersion;

        // Act
        Boolean isDraftVersionRequired = SRQIQuestionDataCaptureFormController.isDraftVersionRequiredForAmendment(qiSummaryId);

        // Assert
        Assert.isTrue(isDraftVersionRequired);
    }

    @isTest static void testIsDraftVersionRequiredForAmendmentWhenFalse() {
        // Arrange
        Id qiSummaryId = ([SELECT Id FROM Quality_Indicator_Summary__c LIMIT 1])[0].Id;

        // Act
        Boolean isDraftVersionRequired = SRQIQuestionDataCaptureFormController.isDraftVersionRequiredForAmendment(qiSummaryId);

        // Assert
        Assert.isFalse(isDraftVersionRequired);
    }

    @isTest static void testCreateDraftVersion() {
        // Arrange
        Id qiSummaryId = ([SELECT Id FROM Quality_Indicator_Summary__c LIMIT 1])[0].Id;
        Id recordTypeId = Schema.SObjectType.Quality_Indicator_Details__c.getRecordTypeInfosByDeveloperName().get(PRESSURE_INJURIES_RECORD_TYPE_NAME).getRecordTypeId();
        Quality_Indicator_Summary_Version__c qiSummaryVersion = new Quality_Indicator_Summary_Version__c();
        qiSummaryVersion.Quality_Indicator_Summary__c = qiSummaryId;
        qiSummaryVersion.Status__c = QIS_STATUS_SUBMITTED;
        qiSummaryVersion.Version__c = 1;
        insert qiSummaryVersion;

        String formData = '{"No_CR_Assessed__c":20,"Comments__c":"Test"}';
        Boolean warningFlag = false;

        // Act
        SRQIQuestionDataCaptureFormController.createDraftVersion(formData, recordTypeId, PRESSURE_INJURIES_RECORD_TYPE_LABEL, qiSummaryId, warningFlag);

        // Assert
        List<Quality_Indicator_Summary_Version__c> summaryVersions = [SELECT Id, Status__c, Version__c FROM Quality_Indicator_Summary_Version__c ORDER BY Version__c ASC];
        Assert.areEqual(2, summaryVersions.size());
        Assert.areEqual(1, summaryVersions[0].Version__c);
        Assert.areEqual(QIS_STATUS_SUBMITTED, summaryVersions[0].Status__c);
        Assert.areEqual(2, summaryVersions[1].Version__c);
        Assert.areEqual('In Progress', summaryVersions[1].Status__c);
    }

    @isTest static void testGetQIStatus() {
        // Arrange
        Id recordTypeId = Schema.SObjectType.Quality_Indicator_Details__c.getRecordTypeInfosByDeveloperName().get(PRESSURE_INJURIES_RECORD_TYPE_NAME).getRecordTypeId();
        Id qiSummaryId = ([SELECT Id FROM Quality_Indicator_Summary__c LIMIT 1])[0].Id;
        Quality_Indicator_Details__c qidRecord = new Quality_Indicator_Details__c();
        qidRecord.RecordTypeId = recordTypeId;
        qidRecord.QI_Summary_Id__c = qiSummaryId;
        qidRecord.Status__c = 'In Progress';
        insert qidRecord;

        // Act
        List<Quality_Indicator_Details__c> qidRecords = SRQIQuestionDataCaptureFormController.getQIStatus(qiSummaryId);

        // Assert
        Assert.areEqual(1, qidRecords.size());
    }

    @isTest static void testGetOneQuestionSectionPerType() {
        // Arrange
        Id questionCategoryId = [SELECT Id FROM Question_Category__c WHERE Name = :SRQIQuestionDataCaptureFormController.QI_LABEL][0].Id;
        Id sectionLibraryId = [SELECT Id FROM Section_Library__c WHERE Type__c = :PRESSURE_INJURIES_RECORD_TYPE_LABEL][0].Id;
        List<Question_Section__c> questionSections = new List<Question_Section__c>{
            new Question_Section__c(
                Section_Library__c = sectionLibraryId,
                Question_Category__c = questionCategoryId
            ),
            new Question_Section__c(
                Section_Library__c = sectionLibraryId,
                Question_Category__c = questionCategoryId
            )
        };
        insert questionSections;
        
        // Act
        Test.startTest();
        List<Question_Section__c> pressureInjuryQuestionSections = [SELECT Type__c FROM Question_Section__c WHERE Section_LIbrary__r.Type__c = :PRESSURE_INJURIES_RECORD_TYPE_LABEL];
        List<Question_Section__c> uniqueQuestionSections = SRQIQuestionDataCaptureFormController.getOneQuestionSectionPerType(pressureInjuryQuestionSections);
        Test.stopTest();

        // Assert
        Assert.isTrue(pressureInjuryQuestionSections.size() > 0);
        Assert.areEqual(1, uniqueQuestionSections.size());
    }

    @isTest static void testGetLastModifiedDetails() {
        // Arrange
        String qualityIndicatorDetails = '{"No_CR_Assessed__c":20,"Comments__c":"Test"}';
        Id recordTypeId = Schema.SObjectType.Quality_Indicator_Details__c.getRecordTypeInfosByDeveloperName().get(PRESSURE_INJURIES_RECORD_TYPE_NAME).getRecordTypeId();
        Id summaryId = ([SELECT Id FROM Quality_Indicator_Summary__c LIMIT 1])[0].Id;
        Boolean warningFlag = false;
        Boolean validateOnly = false;

        String result;

        // Act
        Test.startTest();
        String errors = SRQIQuestionDataCaptureFormController.saveFormSectionComplete(qualityIndicatorDetails, recordTypeId, summaryId, warningFlag, validateOnly);
        result = SRQIQuestionDataCaptureFormController.getLastModifiedDetails(summaryId);
        Test.stopTest();

        // Assert
        Assert.isNotNull(result);
    }
}