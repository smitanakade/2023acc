/**
* author: Daniel Clift
* date: 15/10/2022
* description: Test class for CheckExemptions
**/
@isTest
public with sharing class CheckExemptionsTest {
    private static User currentUser = TestDataFactory.createSystemAdminUser();
    @TestSetup
    static void dataSetup(){
        System.runAs(currentUser)
        {
            Test.startTest();
            Integer recordCount = 3;
            // get reporting period
            Reporting_Period__c rPeriod = TestDataFactory.createReportingPeriod('Quarter');
            rPeriod.Start_Date__c = (System.today() + 12 ).addMonths(-6);
            rPeriod.End_Date__c = (System.today() + 24).addMonths(-3);
            insert rPeriod;
            // get reporting period year
            Reporting_Period__c rPeriodYear = TestDataFactory.createReportingPeriod('Year');
            Integer yearDate = System.today().Year() - 1;
			rPeriodYear.Start_Date__c = System.today().addMonths(-12);
            rPeriodYear.End_Date__c = System.today().addMonths(-9);
            insert rPeriodYear;
            // get providers
            List<Account> providers = TestDataFactory.createProviderRecords(recordCount);
            insert providers;
            // get services
            List<BusinessLicense> services = TestDataFactory.createServiceRecords(recordCount);
            services[0].Operational_Two_Last_Quarters__c = true;
            insert services;
            // get service account relationships
            List<Service_Account_Relationship__c> serviceAccountRecords = TestDataFactory.createServiceAccountRecords(recordCount, services, providers);
            insert serviceAccountRecords;
            // get exemptions and link to services
            List<SRQI_Exemption__c> exemptList= new List<SRQI_Exemption__c>();
            exemptList.add(TestDataFactory.createCERExemptionRecords(1, new List<BusinessLicense>{services[0]})[0]);
            exemptList.add(TestDataFactory.createQIExemptionRecords(1, new List<BusinessLicense>{services[1]})[0]);
            exemptList.add(TestDataFactory.createCMExemptionRecords(1, new List<BusinessLicense>{services[2]})[0]);
            for(SRQI_Exemption__c exempt : exemptList) {
                exempt.Reason__c = 'Business Exemption';
            }
            insert exemptList;
            // get Service Compliance History
            List<Service_Compliance_History__c> schRecords = TestDataFactory.createServiceComplianceHistory(recordCount);
            for(Integer y = 0; y < schRecords.size(); y++) {
                schRecords[y].Rating_Type__c = 'Current Rating';
                schRecords[y].Service__c = services[y].Id;
            }
            insert schRecords;
            // get quality indicator summary
            List<Quality_Indicator_Summary__c> qisRecords = TestDataFactory.createQISummaryRecords(recordCount, providers, rPeriod, services, serviceAccountRecords);
            insert qisRecords;
            // get consumer experience reports
            List<SRQI_CER__c> cerRecords = TestDataFactory.createCERRecords(recordCount, serviceAccountRecords, providers, services, rPeriod);
            insert cerRecords;
            // get care minutes summary
            List<Care_Minutes_Summary__c> cmsRecords = TestDataFactory.createCareMinuteSummary(recordCount, services);
            for(Care_Minutes_Summary__c cmsRecord : cmsRecords) {
                cmsRecord.Reporting_Period__c = rPeriod.Id;
                cmsRecord.Provider_Name__c = providers[0].Id;
                cmsRecord.Service_Account__c = serviceAccountRecords[0].Id;
            }
            insert cmsRecords;
            // get star rating history records
            List<STAR_Rating_History__c> srhRecords = TestDataFactory.createStarRatingHistoryRecords(recordCount, services, providers, rPeriod);
            for(Integer i = 0; i < srhRecords.size(); i++) {
                srhRecords[i].Rating_Type__c = 'Draft Rating';
                srhRecords[i].Status__c = 'Draft';
                srhRecords[i].Service_Account_Relationship__c = serviceAccountRecords[i].Id;
            }
            insert srhRecords;
            Test.stopTest();
        }
    }

    @isTest
    public static void testCheckCER() {
        String cerRecordType = Schema.SObjectType.SRQI_Exemption__c.getRecordTypeInfosByDeveloperName().get('CER_Exemption').getRecordTypeId();
        
        List<BusinessLicense> serviceList = [SELECT Id, CER_Exempt__c, CM_Exempt__c, QI_Exempt__c, CER_Consent_Revoked__c, Operational_Two_Last_Quarters__c, 
                            (SELECT RecordTypeId, RecordType.Name, Active__c, Reason__c FROM Service__r WHERE RecordTypeId = :cerRecordType) 
                            FROM BusinessLicense];

        BusinessLicense service;                    
        for(BusinessLicense serviceException : serviceList) {
            if(serviceException.Service__r.size() > 0) {
                service = serviceException;
                break;
            }
        }
        
        STAR_Rating_History__c srh = [SELECT Id, SF_Service_Id__c, Reporting_Period__c, SF_Provider_Id__c, Service_Account_Relationship__c, 
                                            Rating_Type__c, Status__c, SF_Provider_Id__r.Oracle_ID__c, SF_Service_Id__r.Oracle_Service_ID__c
                                    FROM STAR_Rating_History__c 
                                    WHERE SF_Service_Id__c = :service.Id];
        System.runAs(currentUser)
        {
            String rpYear = String.valueOf([SELECT Id FROM Reporting_Period__c WHERE Reporting_Period_Type__c = 'Year' and Previous_Reporting_Period__c = true].Id);

            Test.startTest();
            CheckExemptions.checkCER(service, srh, rpYear);
            service.CER_Exempt__c = true;
            update service;
            SRQI_CER__c cerExempt = CheckExemptions.checkCER(service, srh, rpYear);
            Test.stopTest();
            System.assertEquals(true, cerExempt.Rating_Exemption_Granted__c, 'Rating_Exemption_Granted__c should be true');
        }
        
        
        
    }

    @isTest
    public static void testCheckCM() {
        String cmRecordType = Schema.SObjectType.SRQI_Exemption__c.getRecordTypeInfosByDeveloperName().get('CM_Exemption').getRecordTypeId();
        
        List<BusinessLicense> serviceList = [SELECT Id, CER_Exempt__c, CM_Exempt__c, QI_Exempt__c, CER_Consent_Revoked__c, Operational_Two_Last_Quarters__c, 
                            (SELECT RecordTypeId, RecordType.Name, Active__c, Reason__c FROM Service__r WHERE RecordTypeId = :cmRecordType) 
                            FROM BusinessLicense];

        BusinessLicense service;                    
        for(BusinessLicense serviceException : serviceList) {
            if(serviceException.Service__r.size() > 0) {
                service = serviceException;
                break;
            }
        }
        
        STAR_Rating_History__c srh = [SELECT Id, SF_Service_Id__c, Reporting_Period__c, SF_Provider_Id__c, Service_Account_Relationship__c, 
                                        Rating_Type__c, Status__c, SF_Provider_Id__r.Oracle_ID__c, SF_Service_Id__r.Oracle_Service_ID__c 
                                    FROM STAR_Rating_History__c 
                                    WHERE SF_Service_Id__c = :service.Id]; 
        System.runAs(currentUser)
        {
            Test.startTest();
            Care_Minutes_Summary__c cmNotExempt = CheckExemptions.checkCM(service, srh); 
            service.CM_Exempt__c = true;
            update service;
            Care_Minutes_Summary__c cmExempt = CheckExemptions.checkCM(service, srh); 
            Test.stopTest();
            System.assertEquals(true, cmExempt.Rating_Exemption_Granted__c, 'Rating_Exemption_Granted__c should be true');
        }        
                  
    }

    @isTest
    public static void testCheckQI() {
        String qiRecordType = Schema.SObjectType.SRQI_Exemption__c.getRecordTypeInfosByDeveloperName().get('QI_Exemption').getRecordTypeId();

        List<BusinessLicense> serviceList = [SELECT Id, CER_Exempt__c, CM_Exempt__c, QI_Exempt__c, CER_Consent_Revoked__c, Operational_Two_Last_Quarters__c, 
                            (SELECT RecordTypeId, RecordType.Name, Active__c, Reason__c FROM Service__r WHERE RecordTypeId = :qiRecordType) 
                            FROM BusinessLicense];

        BusinessLicense service;                    
        for(BusinessLicense serviceException : serviceList) {
            if(serviceException.Service__r.size() > 0) {
                service = serviceException;
                break;
            }
        }

        STAR_Rating_History__c srh = [SELECT Id, SF_Service_Id__c, Reporting_Period__c, SF_Provider_Id__c, Service_Account_Relationship__c, 
                                        Rating_Type__c, Status__c, SF_Provider_Id__r.Oracle_ID__c, SF_Service_Id__r.Oracle_Service_ID__c
        FROM STAR_Rating_History__c 
        WHERE SF_Service_Id__c = :service.Id];
        System.runAs(currentUser)
        {
            Test.startTest();
            Quality_Indicator_Summary__c qiNotExempt = CheckExemptions.checkQI(service, srh);
            service.QI_Exempt__c = true;
            update service;
            Quality_Indicator_Summary__c qiExempt = CheckExemptions.checkQI(service, srh);
            Test.stopTest();
            System.assertEquals(true, qiExempt.Rating_Exemption_Granted__c, 'Rating_Exemption_Granted__c should be true');
        }       
        
    }
}