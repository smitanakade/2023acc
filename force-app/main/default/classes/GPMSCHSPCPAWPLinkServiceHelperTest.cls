@IsTest
public class GPMSCHSPCPAWPLinkServiceHelperTest {

    @TestSetup
    static void setup() {
        TestDataFactory.createSystemAdminUser();
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
            acprRecord2.Name = GPMSCHSPConstants.ACPR_REGION_1;
            acprRecord2.ACPR_State__c = 'VIC';
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
            chspProvider.Party_ID__c = GPMSCHSPConstants.TEST_PARTYID_2; // Required for populating Organisation_Name__c in CHSP_Service_Schedule__c (trigger another Flow)
            chspProvider.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Commonwealth_Home_Support_Programme').getRecordTypeId();
            Insert chspProvider;
            
            List<CHSP_Procurement_Based_AWP_Record__c> chspAWPRecords = new List<CHSP_Procurement_Based_AWP_Record__c>();
            for(Integer i=0; i<2; i++) {
                CHSP_Procurement_Based_AWP_Record__c chspAWPRecord = new CHSP_Procurement_Based_AWP_Record__c();
                chspAWPRecord.Service_Type_Level__c = GPMSCHSPConstants.SERVICE_TYPE_LEVEL_2; // Required for populating Service_Care_Sub_Type__c (trigger another Flow)
                chspAWPRecord.Party_ID__c = chspProvider.Party_ID__c;
                chspAWPRecord.Service_Care_Sub_Type__c = GPMSCHSPConstants.SERVICE_SUB_CARE_TYPE_2;
                chspAWPRecord.Activity_Status__c = 'Approved';
                chspAWPRecord.Service_Area__c = 'Central West (QLD)';
                chspAWPRecord.Activity_Work_Plan_ID__c = '4-XY'+i+'RJKL';
                chspAWPRecords.add(chspAWPRecord);
            }
            insert chspAWPRecords;
            
            // Get scope
            List<CHSP_Procurement_Based_AWP_Record__c> scope = [SELECT Id,Party_Id__c,Service_Care_Sub_Type__c, Activity_Status__c, Service_Area__c
                                                    		FROM CHSP_Procurement_Based_AWP_Record__c
                                                    		WHERE Service__c = null AND Party_Id__c != null AND Service_Care_Sub_Type__c != null];
            
            // Execute GPMSCHSPLinkService
            GPMSCHSPCPAWPLinkServiceHelper chspLinkServiceHelper = new GPMSCHSPCPAWPLinkServiceHelper(scope);
            chspLinkServiceHelper.executeGPMSCHSPCPAWPLinkService();
            
            List<BusinessLicense> services = [SELECT Id,Party_Id__c,Service_Care_Sub_Type__c 
                                              FROM BusinessLicense];
            System.assert(services.size() > 0, 'There should be at least one service created.');
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testServiceCreatedOtherRegion() {
        User adminUser = TestDataFactory.createSystemAdminUser();
        Test.startTest();
        System.runAs(adminUser) {
            // Create Scope
            Account chspProvider = new Account(Name = 'ProviderA',Incorporation_ID_Type__c='Other');
            chspProvider.Party_ID__c = GPMSCHSPConstants.TEST_PARTYID_2; // Required for populating Organisation_Name__c in CHSP_Service_Schedule__c (trigger another Flow)
            chspProvider.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Commonwealth_Home_Support_Programme').getRecordTypeId();
            Insert chspProvider;
            
            List<CHSP_Procurement_Based_AWP_Record__c> chspAWPRecords = new List<CHSP_Procurement_Based_AWP_Record__c>();
            for(Integer i=0; i<2; i++) {
                CHSP_Procurement_Based_AWP_Record__c chspAWPRecord = new CHSP_Procurement_Based_AWP_Record__c();
                chspAWPRecord.Service_Type_Level__c = GPMSCHSPConstants.SERVICE_TYPE_LEVEL_2; // Required for populating Service_Care_Sub_Type__c (trigger another Flow)
                chspAWPRecord.Party_ID__c = chspProvider.Party_ID__c;
                chspAWPRecord.Service_Care_Sub_Type__c = GPMSCHSPConstants.SERVICE_SUB_CARE_TYPE_2;
                chspAWPRecord.Activity_Status__c = 'Approved';
                chspAWPRecord.Service_Area__c = 'ACT';
                chspAWPRecord.Activity_Work_Plan_ID__c = '4-XY'+i+'RJKL';
                chspAWPRecords.add(chspAWPRecord);
            }
            insert chspAWPRecords;
            
            // Get scope
            List<CHSP_Procurement_Based_AWP_Record__c> scope = [SELECT Id,Party_Id__c,Service_Care_Sub_Type__c, Activity_Status__c, Service_Area__c
                                                    		FROM CHSP_Procurement_Based_AWP_Record__c
                                                    		WHERE Service__c = null AND Party_Id__c != null AND Service_Care_Sub_Type__c != null];
            
            // Execute GPMSCHSPLinkService
            GPMSCHSPCPAWPLinkServiceHelper chspLinkServiceHelper = new GPMSCHSPCPAWPLinkServiceHelper(scope);
            chspLinkServiceHelper.executeGPMSCHSPCPAWPLinkService();
            
            List<BusinessLicense> services = [SELECT Id,Party_Id__c,Service_Care_Sub_Type__c 
                                              FROM BusinessLicense];
            System.assert(services.size() > 0, 'There should be at least one service created.');
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testServiceUpdate() {
        User adminUser = TestDataFactory.createSystemAdminUser();
        Test.startTest();
        System.runAs(adminUser) {
            // Create Scope
            Account chspProvider = new Account(Name = 'ProviderA',Incorporation_ID_Type__c='Other');
            chspProvider.Party_ID__c = GPMSCHSPConstants.TEST_PARTYID_2; // Required for populating Organisation_Name__c in CHSP_Service_Schedule__c (trigger another Flow)
            chspProvider.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Commonwealth_Home_Support_Programme').getRecordTypeId();
            Insert chspProvider;
            
            List<CHSP_Procurement_Based_AWP_Record__c> chspAWPRecords = new List<CHSP_Procurement_Based_AWP_Record__c>();
            for(Integer i=0; i<2; i++) {
                CHSP_Procurement_Based_AWP_Record__c chspAWPRecord = new CHSP_Procurement_Based_AWP_Record__c();
                chspAWPRecord.Service_Type_Level__c = GPMSCHSPConstants.SERVICE_TYPE_LEVEL_2; // Required for populating Service_Care_Sub_Type__c (trigger another Flow)
                chspAWPRecord.Party_ID__c = chspProvider.Party_ID__c;
                chspAWPRecord.Service_Care_Sub_Type__c = GPMSCHSPConstants.SERVICE_SUB_CARE_TYPE_2;
                chspAWPRecord.Activity_Status__c = 'Approved';
                chspAWPRecord.Service_Area__c = GPMSCHSPConstants.ACPR_REGION_1;
                chspAWPRecord.Activity_Work_Plan_ID__c = '4-XY'+i+'RJKL';
                chspAWPRecords.add(chspAWPRecord);
            }
            insert chspAWPRecords;
            
            // Create existing service
            BusinessLicense existingService = new BusinessLicense();
            existingService.RecordTypeId = Schema.SObjectType.BusinessLicense
        		.getRecordTypeInfosByDeveloperName()
                .get('CHSP_Service').getRecordTypeId();
            existingService.Care_Type__c = 'Commonwealth Home Support Programme';
            existingService.Party_Id__c = GPMSCHSPConstants.TEST_PARTYID_2;
            existingService.Service_Name_Effective_Date__c = Date.today();
            existingService.Status_Date__c = Date.today();
            existingService.Service_Care_Sub_Type__c = GPMSCHSPConstants.SERVICE_SUB_CARE_TYPE_2;
            existingService.Status__c = 'Inactive';
            existingService.Name = 'Test Service Name';
            insert existingService;
            
            // Get scope
            List<CHSP_Procurement_Based_AWP_Record__c> scope = [SELECT Id,Party_Id__c,Service_Care_Sub_Type__c, Activity_Status__c, Service_Area__c
                                                    		FROM CHSP_Procurement_Based_AWP_Record__c
                                                    		WHERE Service__c = null AND Party_Id__c != null AND Service_Care_Sub_Type__c != null];
            
            // Execute GPMSCHSPLinkService
            GPMSCHSPCPAWPLinkServiceHelper chspLinkServiceHelper = new GPMSCHSPCPAWPLinkServiceHelper(scope);
            chspLinkServiceHelper.executeGPMSCHSPCPAWPLinkService();
            
            List<BusinessLicense> services = [SELECT Id, Party_Id__c, Service_Care_Sub_Type__c, Status__c 
                                              FROM BusinessLicense];
            System.assertEquals('Operational', services[0].Status__c, 'Existing service status should be operational.');
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testServiceUpdateToInactive() {
        User adminUser = TestDataFactory.createSystemAdminUser();
        Test.startTest();
        System.runAs(adminUser) {
            // Create Scope
            Account chspProvider = new Account(Name = 'ProviderA',Incorporation_ID_Type__c='Other');
            chspProvider.Party_ID__c = GPMSCHSPConstants.TEST_PARTYID_2; // Required for populating Organisation_Name__c in CHSP_Service_Schedule__c (trigger another Flow)
            chspProvider.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Commonwealth_Home_Support_Programme').getRecordTypeId();
            Insert chspProvider;
            
            List<CHSP_Procurement_Based_AWP_Record__c> chspAWPRecords = new List<CHSP_Procurement_Based_AWP_Record__c>();
            for(Integer i=0; i<2; i++) {
                CHSP_Procurement_Based_AWP_Record__c chspAWPRecord = new CHSP_Procurement_Based_AWP_Record__c();
                chspAWPRecord.Service_Type_Level__c = GPMSCHSPConstants.SERVICE_TYPE_LEVEL_2; // Required for populating Service_Care_Sub_Type__c (trigger another Flow)
                chspAWPRecord.Party_ID__c = chspProvider.Party_ID__c;
                chspAWPRecord.Service_Care_Sub_Type__c = GPMSCHSPConstants.SERVICE_SUB_CARE_TYPE_2;
                chspAWPRecord.Activity_Status__c = 'Inactive';
                chspAWPRecord.Service_Area__c = GPMSCHSPConstants.ACPR_REGION_1;
                chspAWPRecord.Activity_Work_Plan_ID__c = '4-XY'+i+'RJKL';
                chspAWPRecords.add(chspAWPRecord);
            }
            insert chspAWPRecords;
            
            // Create existing service
            BusinessLicense existingService = new BusinessLicense();
            existingService.RecordTypeId = Schema.SObjectType.BusinessLicense
        		.getRecordTypeInfosByDeveloperName()
                .get('CHSP_Service').getRecordTypeId();
            existingService.Care_Type__c = 'Commonwealth Home Support Programme';
            existingService.Party_Id__c = GPMSCHSPConstants.TEST_PARTYID_2;
            existingService.Service_Name_Effective_Date__c = Date.today();
            existingService.Status_Date__c = Date.today();
            existingService.Service_Care_Sub_Type__c = GPMSCHSPConstants.SERVICE_SUB_CARE_TYPE_2;
            existingService.Status__c = 'Operational';
            existingService.Name = 'Test Service Name';
            insert existingService;
            
            // Get scope
            List<CHSP_Procurement_Based_AWP_Record__c> scope = [SELECT Id,Party_Id__c,Service_Care_Sub_Type__c, Activity_Status__c, Service_Area__c
                                                    		FROM CHSP_Procurement_Based_AWP_Record__c
                                                    		WHERE Service__c = null AND Party_Id__c != null AND Service_Care_Sub_Type__c != null];
            
            // Execute GPMSCHSPLinkService
            GPMSCHSPCPAWPLinkServiceHelper chspLinkServiceHelper = new GPMSCHSPCPAWPLinkServiceHelper(scope);
            chspLinkServiceHelper.executeGPMSCHSPCPAWPLinkService();
            
            List<BusinessLicense> services = [SELECT Id, Party_Id__c, Service_Care_Sub_Type__c, Status__c 
                                              FROM BusinessLicense];
            System.assertEquals('Inactive', services[0].Status__c, 'Existing service status should be inactive.');
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testNoProvider() {
        User adminUser = TestDataFactory.createSystemAdminUser();
        Test.startTest();
        System.runAs(adminUser) {
            
            List<CHSP_Procurement_Based_AWP_Record__c> chspAWPRecords = new List<CHSP_Procurement_Based_AWP_Record__c>();
            for(Integer i=0; i<2; i++) {
                CHSP_Procurement_Based_AWP_Record__c chspAWPRecord = new CHSP_Procurement_Based_AWP_Record__c();
                chspAWPRecord.Service_Type_Level__c = GPMSCHSPConstants.SERVICE_TYPE_LEVEL_2; // Required for populating Service_Care_Sub_Type__c (trigger another Flow)
                chspAWPRecord.Party_ID__c = GPMSCHSPConstants.TEST_PARTYID_2;
                chspAWPRecord.Service_Care_Sub_Type__c = GPMSCHSPConstants.SERVICE_SUB_CARE_TYPE_2;
                chspAWPRecord.Activity_Status__c = 'Approved';
                chspAWPRecord.Service_Area__c = GPMSCHSPConstants.ACPR_REGION_1;
                chspAWPRecord.Activity_Work_Plan_ID__c = '4-XY'+i+'RJKL';
                chspAWPRecords.add(chspAWPRecord);
            }
            insert chspAWPRecords;
            
            
			// Get scope
            List<CHSP_Procurement_Based_AWP_Record__c> scope = [SELECT Id,Party_Id__c,Service_Care_Sub_Type__c, Activity_Status__c, Service_Area__c
                                                    		FROM CHSP_Procurement_Based_AWP_Record__c
                                                    		WHERE Service__c = null AND Party_Id__c != null AND Service_Care_Sub_Type__c != null];
            
            // Execute GPMSCHSPLinkService
            GPMSCHSPCPAWPLinkServiceHelper chspLinkServiceHelper = new GPMSCHSPCPAWPLinkServiceHelper(scope);
            chspLinkServiceHelper.executeGPMSCHSPCPAWPLinkService();
            
            List<BusinessLicense> services = [SELECT Id, Party_Id__c, Service_Care_Sub_Type__c, Status__c 
                                              FROM BusinessLicense];
            
            System.assert(services.size() == 1, 'A service should be created.');
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testNoWorkPlan() {
        User adminUser = TestDataFactory.createSystemAdminUser();
        Test.startTest();
        System.runAs(adminUser) {
            
			// Get scope
            List<CHSP_Procurement_Based_AWP_Record__c> scope = [SELECT Id,Party_Id__c,Service_Care_Sub_Type__c, Activity_Status__c, Service_Area__c
                                                    		FROM CHSP_Procurement_Based_AWP_Record__c
                                                    		WHERE Service__c = null AND Party_Id__c != null AND Service_Care_Sub_Type__c != null];
            
            // Execute GPMSCHSPLinkService
            GPMSCHSPCPAWPLinkServiceHelper chspLinkServiceHelper = new GPMSCHSPCPAWPLinkServiceHelper(scope);
            chspLinkServiceHelper.executeGPMSCHSPCPAWPLinkService();
            
            List<BusinessLicense> services = [SELECT Id, Party_Id__c, Service_Care_Sub_Type__c, Status__c 
                                              FROM BusinessLicense];
            
            System.assert(services.size() == 0, 'No service should be created.');
        }
        Test.stopTest();
    }
}