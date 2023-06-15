@IsTest
public class GPMSCHSPLinkServiceHelperTest {
    
    @TestSetup
    static void setup() {
        User adminUser = TestDataFactory.createSystemAdminUser();
        System.runAs(adminUser) {
            GPMS_Geospatial_Information_LayerVersion__c layerVersionRecord = new GPMS_Geospatial_Information_LayerVersion__c();
            layerVersionRecord.GPMS_Layer__c = 'Aged Care Planning Regions';
            layerVersionRecord.GPMS_Version__c = '2023';
            layerVersionRecord.Start_Date__c = Date.today().addDays(-1);
            layerVersionRecord.End_Date__c = null;
            insert layerVersionRecord;
            
            GPMS_Geospatial_Information_LayerVersion__c layerVersionRecordExpired = new GPMS_Geospatial_Information_LayerVersion__c();
            layerVersionRecordExpired.GPMS_Layer__c = 'Aged Care Planning Regions';
            layerVersionRecordExpired.GPMS_Version__c = '2022';
            layerVersionRecordExpired.Start_Date__c = Date.today().addDays(-200);
            layerVersionRecordExpired.End_Date__c = Date.today().addDays(-100);
            insert layerVersionRecordExpired;
            
            Aged_Care_Planning_Region__c acprRecord1 = new Aged_Care_Planning_Region__c();
            acprRecord1.Name = GPMSCHSPConstants.ACPR_REGION_2;
            acprRecord1.ACPR_State__c = 'QLD';
            acprRecord1.Geospatial_Information_Layer_Version__c = layerVersionRecord.Id;
            insert acprRecord1;
            
            Aged_Care_Planning_Region__c acprRecord2 = new Aged_Care_Planning_Region__c();
            acprRecord2.Name = 'ACT';
            acprRecord2.ACPR_State__c = 'ACT';
            acprRecord2.Geospatial_Information_Layer_Version__c = layerVersionRecord.Id;
            insert acprRecord2;
            
            Aged_Care_Planning_Region__c acprRecord3 = new Aged_Care_Planning_Region__c();
            acprRecord3.Name = GPMSCHSPConstants.ACPR_REGION_1;
            acprRecord3.ACPR_State__c = 'VIC';
            acprRecord3.Geospatial_Information_Layer_Version__c = layerVersionRecordExpired.Id;
            insert acprRecord3;
            
            Aged_Care_Planning_Region__c acprRecord4 = new Aged_Care_Planning_Region__c();
            acprRecord4.Name = GPMSCHSPConstants.ACPR_REGION_3;
            acprRecord4.ACPR_State__c = 'VIC';
            acprRecord4.Geospatial_Information_Layer_Version__c = layerVersionRecordExpired.Id;
            insert acprRecord4;
            
            Aged_Care_Planning_Region__c acprRecord5 = new Aged_Care_Planning_Region__c();
            acprRecord5.Name = GPMSCHSPConstants.ACPR_REGION_4;
            acprRecord5.ACPR_State__c = null;
            acprRecord5.Geospatial_Information_Layer_Version__c = layerVersionRecord.Id;
            insert acprRecord5;
        }
    }
    
    @IsTest
    static void testServiceCreated() {
        User adminUser = TestDataFactory.createSystemAdminUser();
        Test.startTest();
        System.runAs(adminUser) {
            // Create Scope
            Account chspProvider = new Account(Name = 'ProviderA',Incorporation_ID_Type__c='Other');
            chspProvider.Party_ID__c = GPMSCHSPConstants.TEST_PARTYID_1; // Required for populating Organisation_Name__c in CHSP_Service_Schedule__c (trigger another Flow)
            chspProvider.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Commonwealth_Home_Support_Programme').getRecordTypeId();
            Insert chspProvider;
            
            CHSP_Service_Schedule__c chspServiceSchedule = new CHSP_Service_Schedule__c();
            chspServiceSchedule.Service_Type_Level__c = GPMSCHSPConstants.SERVICE_TYPE_LEVEL_1;
            chspServiceSchedule.Party_Id__c = GPMSCHSPConstants.TEST_PARTYID_1;
            chspServiceSchedule.Organisation_Name__c = chspProvider.Id;
            chspServiceSchedule.Service_Care_Sub_Type__c = GPMSCHSPConstants.SERVICE_SUB_CARE_TYPE_1;
            insert chspServiceSchedule;
            
            List<CHSP_Service_Activity_Work_Plan_Record__c> chspAWPRecords = new List<CHSP_Service_Activity_Work_Plan_Record__c>();
            for(Integer i=0; i<2; i++) {
                CHSP_Service_Activity_Work_Plan_Record__c chspAWPRecord = new CHSP_Service_Activity_Work_Plan_Record__c();
                chspAWPRecord.Service_Type_Level__c = GPMSCHSPConstants.SERVICE_TYPE_LEVEL_1; // Required for populating Service_Care_Sub_Type__c (trigger another Flow)
                chspAWPRecord.Service_Care_Sub_Type__c = GPMSCHSPConstants.SERVICE_SUB_CARE_TYPE_1;
                chspAWPRecord.Service_Area__c = 'Central West (Qld)';
                chspAWPRecord.Activity_Status__c = 'Approved';
                chspAWPRecord.CHSP_Service_Schedule__c = chspServiceSchedule.Id;
                chspAWPRecords.add(chspAWPRecord);
            }
            insert chspAWPRecords;
            
            // Get scope
            List<CHSP_Service_Schedule__c> scope = [SELECT Id,Party_Id__c,Service_Care_Sub_Type__c,
                                                   (SELECT Id, Name, Service_Care_Sub_Type__c, Activity_Status__c, Service_Area__c
                                                    FROM CHSP_Service_Activity_Work_Plan_Records__r 
                                                    WHERE Service_Care_Sub_Type__c != null)
                                                   FROM CHSP_Service_Schedule__c
                                                   WHERE Organisation_Name__c != null AND Party_Id__c != null];
            
            // Execute GPMSCHSPLinkService
            GPMSCHSPLinkServiceHelper chspLinkServiceHelper = new GPMSCHSPLinkServiceHelper(scope);
            chspLinkServiceHelper.executeGPMSCHSPLinkService();
            
            List<BusinessLicense> services = [SELECT Id,Party_Id__c,Service_Care_Sub_Type__c 
                                       FROM BusinessLicense];
            System.assert(services.size() > 0, 'There should be at least one service created.');
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testServiceCreatedOtherServiceArea() {
        User adminUser = TestDataFactory.createSystemAdminUser();
        Test.startTest();
        System.runAs(adminUser) {
            // Create Scope
            Account chspProvider = new Account(Name = 'ProviderA',Incorporation_ID_Type__c='Other');
            chspProvider.Party_ID__c = GPMSCHSPConstants.TEST_PARTYID_1; // Required for populating Organisation_Name__c in CHSP_Service_Schedule__c (trigger another Flow)
            chspProvider.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Commonwealth_Home_Support_Programme').getRecordTypeId();
            Insert chspProvider;
            
            CHSP_Service_Schedule__c chspServiceSchedule = new CHSP_Service_Schedule__c();
            chspServiceSchedule.Service_Type_Level__c = GPMSCHSPConstants.SERVICE_TYPE_LEVEL_1;
            chspServiceSchedule.Party_Id__c = GPMSCHSPConstants.TEST_PARTYID_1;
            chspServiceSchedule.Organisation_Name__c = chspProvider.Id;
            chspServiceSchedule.Service_Care_Sub_Type__c = GPMSCHSPConstants.SERVICE_SUB_CARE_TYPE_1;
            insert chspServiceSchedule;
            
            List<CHSP_Service_Activity_Work_Plan_Record__c> chspAWPRecords = new List<CHSP_Service_Activity_Work_Plan_Record__c>();
            for(Integer i=0; i<2; i++) {
                CHSP_Service_Activity_Work_Plan_Record__c chspAWPRecord = new CHSP_Service_Activity_Work_Plan_Record__c();
                chspAWPRecord.Service_Type_Level__c = GPMSCHSPConstants.SERVICE_TYPE_LEVEL_1; // Required for populating Service_Care_Sub_Type__c (trigger another Flow)
                chspAWPRecord.Service_Care_Sub_Type__c = GPMSCHSPConstants.SERVICE_SUB_CARE_TYPE_1;
                chspAWPRecord.Service_Area__c = GPMSCHSPConstants.ACPR_REGION_4;
                chspAWPRecord.Activity_Status__c = 'Approved';
                chspAWPRecord.CHSP_Service_Schedule__c = chspServiceSchedule.Id;
                chspAWPRecords.add(chspAWPRecord);
            }
            insert chspAWPRecords;
            
            // Get scope
            List<CHSP_Service_Schedule__c> scope = [SELECT Id,Party_Id__c,Service_Care_Sub_Type__c,
                                                   (SELECT Id, Name, Service_Care_Sub_Type__c, Activity_Status__c, Service_Area__c
                                                    FROM CHSP_Service_Activity_Work_Plan_Records__r 
                                                    WHERE Service_Care_Sub_Type__c != null)
                                                   FROM CHSP_Service_Schedule__c
                                                   WHERE Organisation_Name__c != null AND Party_Id__c != null];
            
            // Execute GPMSCHSPLinkService
            GPMSCHSPLinkServiceHelper chspLinkServiceHelper = new GPMSCHSPLinkServiceHelper(scope);
            chspLinkServiceHelper.executeGPMSCHSPLinkService();
            
            List<BusinessLicense> services = [SELECT Id,Party_Id__c,Service_Care_Sub_Type__c 
                                       FROM BusinessLicense];
            System.assert(services.size() > 0, 'There should be at least one service created.');
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testServiceUpdated() {
        User adminUser = TestDataFactory.createSystemAdminUser();
        Test.startTest();
        System.runAs(adminUser) {
            // Create Scope
            Account chspProvider = new Account(Name = 'ProviderA',Incorporation_ID_Type__c='Other');
            chspProvider.Party_ID__c = GPMSCHSPConstants.TEST_PARTYID_1; // Required for populating Organisation_Name__c in CHSP_Service_Schedule__c (trigger another Flow)
            chspProvider.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Commonwealth_Home_Support_Programme').getRecordTypeId();
            Insert chspProvider;
            
            CHSP_Service_Schedule__c chspServiceSchedule = new CHSP_Service_Schedule__c();
            chspServiceSchedule.Service_Type_Level__c = GPMSCHSPConstants.SERVICE_TYPE_LEVEL_1;
            chspServiceSchedule.Party_Id__c = GPMSCHSPConstants.TEST_PARTYID_1;
            chspServiceSchedule.Organisation_Name__c = chspProvider.Id;
            chspServiceSchedule.Service_Care_Sub_Type__c = GPMSCHSPConstants.SERVICE_SUB_CARE_TYPE_1;
            insert chspServiceSchedule;
            
            List<CHSP_Service_Activity_Work_Plan_Record__c> chspAWPRecords = new List<CHSP_Service_Activity_Work_Plan_Record__c>();
            for(Integer i=0; i<2; i++) {
                CHSP_Service_Activity_Work_Plan_Record__c chspAWPRecord = new CHSP_Service_Activity_Work_Plan_Record__c();
                chspAWPRecord.Service_Type_Level__c = GPMSCHSPConstants.SERVICE_TYPE_LEVEL_1; // Required for populating Service_Care_Sub_Type__c (trigger another Flow)
                chspAWPRecord.Service_Care_Sub_Type__c = GPMSCHSPConstants.SERVICE_SUB_CARE_TYPE_1;
                chspAWPRecord.Service_Area__c = 'ACT';
                chspAWPRecord.Activity_Status__c = 'Approved';
                chspAWPRecord.CHSP_Service_Schedule__c = chspServiceSchedule.Id;
                chspAWPRecords.add(chspAWPRecord);
            }
            insert chspAWPRecords;
            
            
            // Get scope
            List<CHSP_Service_Schedule__c> scope = [SELECT Id,Party_Id__c,Service_Care_Sub_Type__c,
                                                   (SELECT Id, Name, Service_Care_Sub_Type__c, Activity_Status__c, Service_Area__c
                                                    FROM CHSP_Service_Activity_Work_Plan_Records__r 
                                                    WHERE Service_Care_Sub_Type__c != null)
                                                   FROM CHSP_Service_Schedule__c
                                                   WHERE Organisation_Name__c != null AND Party_Id__c != null];
            
            // Declare GPMSCHSPLinkService
            GPMSCHSPLinkServiceHelper chspLinkServiceHelper = new GPMSCHSPLinkServiceHelper(scope);
            
            // Create existing service
            BusinessLicense existingService = new BusinessLicense();
            existingService.RecordTypeId = Schema.SObjectType.BusinessLicense
        		.getRecordTypeInfosByDeveloperName()
                .get('CHSP_Service').getRecordTypeId();
            existingService.Care_Type__c = 'Commonwealth Home Support Programme';
            existingService.Party_Id__c = GPMSCHSPConstants.TEST_PARTYID_1;
            existingService.Service_Name_Effective_Date__c = Date.today();
            existingService.Status_Date__c = Date.today();
            existingService.Service_Care_Sub_Type__c = GPMSCHSPConstants.SERVICE_SUB_CARE_TYPE_1;
            existingService.Status__c = 'Inactive';
            existingService.Name = chspLinkServiceHelper.getServiceName(GPMSCHSPConstants.TEST_PARTYID_1, GPMSCHSPConstants.SERVICE_SUB_CARE_TYPE_1);
            insert existingService;
            
            // Create junction object
            Service_with_CHSP_Schedule_Detail__c juction = new Service_with_CHSP_Schedule_Detail__c();
            juction.CHSP_Schedule_Detail__c = chspServiceSchedule.id;
            juction.Service__c = existingService.id;
            insert juction;
            
            // Execute GPMSCHSPLinkService
            chspLinkServiceHelper.executeGPMSCHSPLinkService();
            
            List<BusinessLicense> services = [SELECT Id,Party_Id__c,Service_Care_Sub_Type__c, Status__c 
                                       FROM BusinessLicense];
            System.assertEquals('Operational', services[0].Status__c, 'Existing service status should be operational.');
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testServiceUpdatedToInactive() {
        User adminUser = TestDataFactory.createSystemAdminUser();
        Test.startTest();
        System.runAs(adminUser) {
            // Create Scope
            Account chspProvider = new Account(Name = 'ProviderA',Incorporation_ID_Type__c='Other');
            chspProvider.Party_ID__c = GPMSCHSPConstants.TEST_PARTYID_1; // Required for populating Organisation_Name__c in CHSP_Service_Schedule__c (trigger another Flow)
            chspProvider.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Commonwealth_Home_Support_Programme').getRecordTypeId();
            Insert chspProvider;
            
            CHSP_Service_Schedule__c chspServiceSchedule = new CHSP_Service_Schedule__c();
            chspServiceSchedule.Service_Type_Level__c = GPMSCHSPConstants.SERVICE_TYPE_LEVEL_1;
            chspServiceSchedule.Party_Id__c = GPMSCHSPConstants.TEST_PARTYID_1;
            chspServiceSchedule.Organisation_Name__c = chspProvider.Id;
            chspServiceSchedule.Service_Care_Sub_Type__c = GPMSCHSPConstants.SERVICE_SUB_CARE_TYPE_1;
            insert chspServiceSchedule;
            
            List<CHSP_Service_Activity_Work_Plan_Record__c> chspAWPRecords = new List<CHSP_Service_Activity_Work_Plan_Record__c>();
            for(Integer i=0; i<2; i++) {
                CHSP_Service_Activity_Work_Plan_Record__c chspAWPRecord = new CHSP_Service_Activity_Work_Plan_Record__c();
                chspAWPRecord.Service_Type_Level__c = GPMSCHSPConstants.SERVICE_TYPE_LEVEL_1; // Required for populating Service_Care_Sub_Type__c (trigger another Flow)
                chspAWPRecord.Service_Care_Sub_Type__c = GPMSCHSPConstants.SERVICE_SUB_CARE_TYPE_1;
                chspAWPRecord.Service_Area__c = 'ACT';
                chspAWPRecord.Activity_Status__c = 'Inactive';
                chspAWPRecord.CHSP_Service_Schedule__c = chspServiceSchedule.Id;
                chspAWPRecords.add(chspAWPRecord);
            }
            insert chspAWPRecords;
            
            
            // Get scope
            List<CHSP_Service_Schedule__c> scope = [SELECT Id,Party_Id__c,Service_Care_Sub_Type__c,
                                                   (SELECT Id, Name, Service_Care_Sub_Type__c, Activity_Status__c, Service_Area__c
                                                    FROM CHSP_Service_Activity_Work_Plan_Records__r 
                                                    WHERE Service_Care_Sub_Type__c != null)
                                                   FROM CHSP_Service_Schedule__c
                                                   WHERE Organisation_Name__c != null AND Party_Id__c != null];
            
            // Declare GPMSCHSPLinkService
            GPMSCHSPLinkServiceHelper chspLinkServiceHelper = new GPMSCHSPLinkServiceHelper(scope);
            
            // Create existing service
            BusinessLicense existingService = new BusinessLicense();
            existingService.RecordTypeId = Schema.SObjectType.BusinessLicense
        		.getRecordTypeInfosByDeveloperName()
                .get('CHSP_Service').getRecordTypeId();
            existingService.Care_Type__c = 'Commonwealth Home Support Programme';
            existingService.Party_Id__c = GPMSCHSPConstants.TEST_PARTYID_1;
            existingService.Service_Name_Effective_Date__c = Date.today();
            existingService.Status_Date__c = Date.today();
            existingService.Service_Care_Sub_Type__c = GPMSCHSPConstants.SERVICE_SUB_CARE_TYPE_1;
            existingService.Status__c = 'Operational';
            existingService.Name = chspLinkServiceHelper.getServiceName(GPMSCHSPConstants.TEST_PARTYID_1, GPMSCHSPConstants.SERVICE_SUB_CARE_TYPE_1);
            insert existingService;
            
            // Create junction object
            Service_with_CHSP_Schedule_Detail__c juction = new Service_with_CHSP_Schedule_Detail__c();
            juction.CHSP_Schedule_Detail__c = chspServiceSchedule.id;
            juction.Service__c = existingService.id;
            insert juction;
            
            // Execute GPMSCHSPLinkService
            chspLinkServiceHelper.executeGPMSCHSPLinkService();
            
            List<BusinessLicense> services = [SELECT Id,Party_Id__c,Service_Care_Sub_Type__c, Status__c 
                                       FROM BusinessLicense];
            System.assertEquals('Inactive', services[0].Status__c, 'Existing service status should be inactive.');
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testNoSchedule() {
        User adminUser = TestDataFactory.createSystemAdminUser();
        Test.startTest();
        System.runAs(adminUser) {            
            
            // Get scope
            List<CHSP_Service_Schedule__c> scope = [SELECT Id,Party_Id__c,Service_Care_Sub_Type__c,
                                                   (SELECT Id, Name, Service_Care_Sub_Type__c, Activity_Status__c, Service_Area__c 
                                                    FROM CHSP_Service_Activity_Work_Plan_Records__r 
                                                    WHERE Service_Care_Sub_Type__c != null)
                                                   FROM CHSP_Service_Schedule__c
                                                   WHERE Organisation_Name__c != null AND Party_Id__c != null];
            
            // Declare GPMSCHSPLinkService
            GPMSCHSPLinkServiceHelper chspLinkServiceHelper = new GPMSCHSPLinkServiceHelper(scope);
            
            // Execute GPMSCHSPLinkService
            chspLinkServiceHelper.executeGPMSCHSPLinkService();
            
            List<BusinessLicense> services = [SELECT Id,Party_Id__c,Service_Care_Sub_Type__c, Status__c 
                                       FROM BusinessLicense];
            System.assert(services.size() == 0, 'No service should be found.');
        }
        Test.stopTest();
    }
}