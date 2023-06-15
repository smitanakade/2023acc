/**
* Author : Sharevreet Singh
* Date :  01/03/2023
* Description : Test class for QIServiceProviderController
**/
@isTest
class QIServiceProviderControllerTest {
    @TestSetup
    static void dataSetup() {
        User testUser = TestDataFactory.createSystemAdminUser();
        Integer currentYear =  System.Today().year();
        Integer lastYear =  currentYear - 1;
        System.runAs(testUser) { 
            //Account 
            Account acc = new Account(
                Name = 'Test Account Company',
                Purpose__c = 'Government',
                Incorporated_Under__c = 'Associations Act 2008 (NT)',
                Incorporation_Status__c = 'Registered',        
                Incorporation_ID_Type__c = 'Other',
                Prospective_Provider__c = 'No',
                Incorporation_ID__c = '1222211111',
                RecordTypeId = [
                    SELECT Id
                    FROM RecordType
                    WHERE SobjectType = 'Account' AND IsActive = TRUE AND Name = 'Approved Provider' 
                    LIMIT 1
                    ]
                .Id
            );
            insert acc;

            List<Contact> providerContacts = TestDataFactory.createContact(1, new List<Account>{acc});
            insert providerContacts;
            List<User> providerPortalUsers = TestDataFactory.createProviderPortalUser(1, providerContacts);
            //Service
            List<BusinessLicense> services = new List<BusinessLicense>();
            {
                services.add(
                new BusinessLicense(
                    Name = 'Test Service '  ,
                    Effective_Date__c = Date.today(),
                    Status_Date__c =  Date.today(),
                    Care_Type__c = 'Residential',
                    Status__c = 'Operational',
                    AccountId = acc.id
                )
                );
            }
            services.add(
                new BusinessLicense(
                Name = 'Total',
                Effective_Date__c = Date.today(),
                Status_Date__c =  Date.today(),
                Care_Type__c = 'Home Care',
                Status__c = 'Operational'
                )
            );

            services.add(
                new BusinessLicense(
                Name = 'Offline Serv',
                Effective_Date__c = Date.today(),
                Status_Date__c =  Date.today(),
                Care_Type__c = 'Residential',
                Status__c = 'Offline'
                )
            );
            services.add(
                new BusinessLicense(
                Name = 'Operational Serv',
                Effective_Date__c = Date.today(),
                Status_Date__c =  Date.today(),
                Care_Type__c = 'Home Care',
                Status__c = 'Operational'
                )
            );
            insert services;


            //Service Account Relationship
            List<Service_Account_Relationship__c> serviceRelations = new List<Service_Account_Relationship__c>();
            Service_Account_Relationship__c servResiCare = new Service_Account_Relationship__c(
                Association_Start_Date__c = System.today(),
                Service_Name__c = services[0]?.id,
                Provider_Name__c = acc.id
            );

            serviceRelations.add(servResiCare);
            Service_Account_Relationship__c servHomeCare = new Service_Account_Relationship__c(
                Association_Start_Date__c = System.today(),
                Service_Name__c = services[1]?.id,
                Provider_Name__c = acc.id
            );
            serviceRelations.add(servHomeCare);
            insert serviceRelations;


            List<Reporting_Period__c> quarters = new List<Reporting_Period__c>();
            // create Q1
            Reporting_Period__c q1 = new Reporting_Period__c();
            q1.Reporting_Period_Type__c = 'Quarter';
            q1.Start_Date__c = Date.newInstance(lastYear, 07, 01);
            q1.End_Date__c = Date.newInstance(lastYear, 09, 31);
            q1.QFR_Lock_Date__c = date.today();
            q1.QI_Submission_Due_Dt__c   = Date.newInstance(lastYear, 10, 21);
            quarters.add(q1);

            // create Q2
            Reporting_Period__c q2 = new Reporting_Period__c();
            q2.Reporting_Period_Type__c = 'Quarter';
            q2.Start_Date__c = Date.newInstance(lastYear, 10, 01);
            q2.End_Date__c = Date.newInstance(lastYear, 12, 31);
            q2.QFR_Lock_Date__c = date.today();
            q2.QI_Submission_Due_Dt__c   = Date.newInstance(currentYear, 01, 21);
            quarters.add(q2);

            // create Q3
            Reporting_Period__c q3 = new Reporting_Period__c();
            q3.Reporting_Period_Type__c = 'Quarter';
            q3.Start_Date__c = Date.newInstance(currentYear, 01, 01);
            q3.End_Date__c = Date.newInstance(currentYear, 03, 31);
            q3.QFR_Lock_Date__c = date.today();
            q3.QI_Submission_Due_Dt__c   = Date.newInstance(currentYear, 04, 21);
            quarters.add(q3);

            // create Q4
            Reporting_Period__c q4 = new Reporting_Period__c();
            q4.Reporting_Period_Type__c = 'Quarter';
            q4.Start_Date__c = Date.newInstance(currentYear, 04, 01);
            q4.End_Date__c = Date.newInstance(currentYear, 06, 31);
            q4.QFR_Lock_Date__c = date.today();
            q4.QI_Submission_Due_Dt__c   = Date.newInstance(currentYear, 07, 21);
            quarters.add(q4);
            insert quarters;

            String scrRecordTypeId = Schema.SObjectType.Contact_Relationship__c.getRecordTypeInfosByDeveloperName().get('SCR')
			.getRecordTypeId();
            Contact_Relationship__c conR= new Contact_Relationship__c();
            conR.Service__c=services[0].id;
            conR.Contact__c=providerContacts[0].id;
            conR.RecordTypeId = scrRecordTypeId;
            conR.Role__c = 'Star Rating Service - Reviewer';
            insert conR;
        }
    }

    @isTest
    static void createQISRelatedRecordsTest() {
        Service_Account_Relationship__c sar = [SELECT Id, Service_Name__c, Provider_Name__c
                                                FROM Service_Account_Relationship__c 
                                                WHERE Service_Name__c != NULL 
                                                AND Provider_Name__c != NULL
                                                AND Association_Start_Date__c =: System.today()
                                                LIMIT 1];
        List<Quality_Indicator_Summary__c> qis = [SELECT Id FROM Quality_Indicator_Summary__c WHERE Service__c =: sar.Service_Name__c LIMIT 1];
        Reporting_Period__c rp1 = [
            SELECT Id , QFR_Lock_Date__c, Start_Date__c
            FROM   Reporting_Period__c 
            WHERE  Reporting_Period_Type__c = 'Quarter' 
            AND    Current_Reporting_Period__c = true
            LIMIT 1];
        System.assertEquals(0, qis.size(), 'There should be no QIS with related service');
        Test.startTest();
        QIServiceProviderController.createQISRelatedRecords(sar.Service_Name__c, sar.Provider_Name__c, sar.Id, rp1.id);
        qis = [SELECT Id FROM Quality_Indicator_Summary__c WHERE Service__c =: sar.Service_Name__c LIMIT 1];
        Test.stopTest();
        System.assertEquals(1, qis.size(), 'There should be a QIS with related service');
    }

    @isTest
    static void createQISRelatedRecords_ExceptionTest() {
        Service_Account_Relationship__c sar = [SELECT Id, Service_Name__c, Provider_Name__c
                                                FROM Service_Account_Relationship__c 
                                                WHERE Service_Name__c != NULL 
                                                AND Provider_Name__c != NULL
                                                AND Association_Start_Date__c =: System.today()
                                                LIMIT 1];
        List<Quality_Indicator_Summary__c> qis = [SELECT Id FROM Quality_Indicator_Summary__c WHERE Service__c =: sar.Service_Name__c LIMIT 1];
        Reporting_Period__c rp1;

        try{
            QIServiceProviderController.createQISRelatedRecords(sar.Service_Name__c, sar.Provider_Name__c, sar.Id, rp1.id);
        }
        catch(Exception e){
            System.assertNotEquals(e, null);
        }
    }

    @isTest
    static void filterSearchTest() {
        Test.startTest();
        Id userId = [SELECT Id FROM User WHERE Alias = 'pusr' LIMIT 1].Id;
        
        List<AccountContactRelation> accountContactRelations=[Select id, AccountId,  Roles FROM AccountContactRelation ];
        for(AccountContactRelation acR:accountContactRelations){
            acR.Roles='QI Role - Service';
            acR.IsActive=true;
        }
        update accountContactRelations;
        List<BusinessLicense> sar = QIServiceProviderController.getRecordsDataTableListFilterSearch(new List<Date>{}, new List<String>{}, '', userId);
        for(AccountContactRelation acR2:accountContactRelations){
            acR2.Roles='QI Role - Org';
            acR2.IsActive=true;
        }
        update accountContactRelations;
        List<BusinessLicense> sar2 = QIServiceProviderController.getRecordsDataTableListFilterSearch(new List<Date>{}, new List<String>{}, '', userId);
        Test.stopTest();
        System.assert(sar2.size() > 0, 'User should retrieve a sar');
    }

    @isTest
    static void filterSearch_serachFieldTest() {
        Test.startTest();
        Id userId = [SELECT Id FROM User WHERE Alias = 'pusr' LIMIT 1].Id;
        
        List<AccountContactRelation> accountContactRelations=[Select id, AccountId,  Roles FROM AccountContactRelation ];
        for(AccountContactRelation acR:accountContactRelations){
            acR.Roles='QI Role - Service';
            acR.IsActive=true;
        }
        update accountContactRelations;
        List<BusinessLicense> sar = QIServiceProviderController.getRecordsDataTableListFilterSearch(new List<Date>{}, new List<String>{'Submitted - Updated After Due Date'}, 'srt', userId);
        for(AccountContactRelation acR2:accountContactRelations){
            acR2.Roles='QI Role - Org';
            acR2.IsActive=true;
        }
        update accountContactRelations;
        List<BusinessLicense> sar2 = QIServiceProviderController.getRecordsDataTableListFilterSearch(new List<Date>{}, new List<String>{}, '', userId);
        Test.stopTest();
        System.assert(sar2.size() > 0, 'User should  retrieve a sar');
    }

    @isTest
    static void filterSearch_ExceptionTest() {
       try{
        Id userId = '11223344';
        
        List<AccountContactRelation> accountContactRelations=[Select id, AccountId,  Roles FROM AccountContactRelation ];
        for(AccountContactRelation acR:accountContactRelations){
            acR.Roles='QI Role - Service';
            acR.IsActive=true;
        }
        update accountContactRelations;
        List<BusinessLicense> sar = QIServiceProviderController.getRecordsDataTableListFilterSearch(new List<Date>{}, new List<String>{'Submitted - Updated After Due Date'}, '', userId);
        }
        catch(Exception e){
            System.assertNotEquals(e, null);
        }
        
    }

    @isTest
    static void getCurrentRP_test() {
        Test.startTest();
        Reporting_Period__c rp=QIServiceProviderController.getCurrentRP();
        Test.stopTest();
        Reporting_Period__c rp1 = [
            SELECT Id , QFR_Lock_Date__c, Start_Date__c
            FROM   Reporting_Period__c 
            WHERE  Reporting_Period_Type__c = 'Quarter' 
            AND    Current_Reporting_Period__c = true
            LIMIT 1];
        System.assertEquals(rp.Start_Date__c, rp1.Start_Date__c);
    }

    @isTest
    static void getPreviousRP_test() {
        Test.startTest();
        Reporting_Period__c rp=QIServiceProviderController.getPreviousRP();
        Test.stopTest();
        Reporting_Period__c rp1 = [
            SELECT Id , QFR_Lock_Date__c, Start_Date__c
            FROM   Reporting_Period__c 
            WHERE  Reporting_Period_Type__c = 'Quarter' 
            AND    Previous_Reporting_Period__c = true
            LIMIT 1];
        System.assertEquals(rp.Start_Date__c, rp1.Start_Date__c);
    }

    @isTest
    static void isServiceOffline_test() {
        Test.startTest();
        BusinessLicense service=[select id, Status__c from BusinessLicense where Name=:'Offline Serv' LIMIT 1];
        service.Status__c='Offline';
        update service;
        List<String> serviceIds=new List<String>();
        serviceIds.add(service.id);
        Map<String, boolean> res=QIServiceProviderController.areServicesOffline(serviceIds);
        Test.stopTest();
        System.assertEquals(res.get(service.id), true);
    }

    @isTest
    static void isServiceOfflinePRP_test() {
        Test.startTest();
        BusinessLicense service=[select id, Status__c from BusinessLicense where Name=:'Offline Serv' LIMIT 1];
        service.Status__c='Offline';
        update service;
        List<String> serviceIds=new List<String>();
        serviceIds.add(service.id);
        Map<String, boolean> res=QIServiceProviderController.areServicesOfflinePRP(serviceIds);
        Test.stopTest();
        System.assertEquals(res.get(service.id), true);
    }

    @isTest
    static void isServiceOperational_test() {
        Test.startTest();
        BusinessLicense service=[select id, Status__c from BusinessLicense where Name=:'Operational Serv' LIMIT 1];
        service.Care_Type__c = 'Residential';
        service.Status__c='Offline';
        update service;
        List<String> serviceIds=new List<String>();
        serviceIds.add(service.id);
        Map<String, boolean> res=QIServiceProviderController.areServicesOperational(serviceIds);
        Test.stopTest();
        System.assertEquals(res.get(service.id), true);
    }

    @isTest
    static void isServiceOperationalPRP_test() {
        Test.startTest();
        BusinessLicense service=[select id, Status__c from BusinessLicense where Name=:'Operational Serv' LIMIT 1];
        service.Care_Type__c = 'Residential';
        service.Status__c='Offline';
        update service;
        List<String> serviceIds=new List<String>();
        serviceIds.add(service.id);
        Map<String, boolean> res=QIServiceProviderController.areServicesOperationalPRP(serviceIds);
        Test.stopTest();
        System.assertEquals(res.get(service.id), true);
    }

    
    @isTest
    static void currentReportingPeriodId_test() {
        Test.startTest();
        String rdId=QIServiceProviderController.currentReportingPeriodId();
        Test.stopTest();
        System.assertNotEquals(rdId, '');
    }
}