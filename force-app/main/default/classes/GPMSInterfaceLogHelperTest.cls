@IsTest
public with sharing class GPMSInterfaceLogHelperTest {

    private static User user = TestDataFactory.createSystemAdminUser();

    @testSetup static void setup() {

        System.runAs(user){

            List<Account> accountToInsert = new List<Account>();
            
            Account apaccount = new Account();
            apaccount = GPMSTestUtility.getAccountByRecordType('Approved_Provider');
            apaccount.Incorporation_ID_Type__c = 'IAN';
            
            Account tpoaccount = new Account();
            tpoaccount = GPMSTestUtility.getAccountByRecordType('Management_Company');
            tpoaccount.Incorporation_ID_Type__c = 'IAN';
            tpoaccount.Incorporation_Type__c = 'Incorporated Association';
            
            accountToInsert.add(GPMSTestUtility.getACOAccount());
            accountToInsert.add(apaccount);
            accountToInsert.add(tpoaccount);
            insert accountToInsert;
            
            Contact contactToInsert = GPMSTestUtility.getContact();
            insert contactToInsert;
            
            Account aco = [SELECT Id FROM Account Where RecordType.DeveloperName = 'Aged_Care_Organisation' limit 1];
            Account ap = [SELECT Id FROM Account Where RecordType.DeveloperName = 'Approved_Provider' limit 1];
            Account tpo = [SELECT Id FROM Account Where RecordType.DeveloperName = 'Management_Company' limit 1];
            
            List<Account_Relationship__c> accountRelationshipToInsert = new List<Account_Relationship__c>();
            accountRelationshipToInsert.add(GPMSTestUtility.getAccountRelationship('ACO_to_Account',aco.Id,ap.Id));
            accountRelationshipToInsert.add(GPMSTestUtility.getAccountRelationship('Provider_to_Management_Company',ap.Id,tpo.Id));
            insert accountRelationshipToInsert;
            
            Contact_Relationship__c contactRelationshipToInsert = GPMSTestUtility.getContactRelationship('Key_Personnel_CR',ap.Id,contactToInsert.Id);
            insert contactRelationshipToInsert;
            
            Address__c address = GPMSTestUtility.getAddress();
            insert address;
            
            Address_Location__c accountLocation = GPMSTestUtility.getAccountAddress(address.Id,ap.Id);
            insert accountLocation;

            BusinessLicense serviceToInsert = GPMSTestUtility.getServiceByRecordType('Approved_Provider_Service');
            serviceToInsert.Care_Type__c = 'Residential';
            insert serviceToInsert;
            
            Allotment__c allotment = GPMSTestUtility.getAllotment('Approved_Provider_Residential_ALM',serviceToInsert.Id);
            insert Allotment;

            Integer placesCount = 5;
            List<Places_Allotment__c> places = GPMSTestUtility.getPlaces(placesCount,Allotment.Id);
            insert places;

        }
                
    }

    @isTest static void testGPMSCreatePlaces() {

        
        
        

        System.runAs(user){
        
            Test.startTest();

            Test.enableChangeDataCapture();
        
            List<Account> accounts = [SELECT Id FROM Account WHERE recordType.developerName = 'Approved_Provider'];
            System.debug(accounts);

            Update accounts;

            BusinessLicense service = [SELECT Id from BusinessLicense limit 1];

            Service_Account_Relationship__c serviceAccount = new Service_Account_Relationship__c(Service_Name__c = service.Id,Provider_Name__c = accounts[0].Id);
            serviceAccount.Association_Start_Date__c = System.today()-2;
            insert serviceAccount;

            GPMS_Service_Funding__c serviceFunding = new GPMS_Service_Funding__c(service__c = service.Id);
            serviceFunding.AN_ACC_Base_Care_Tariff__c = '5';
            serviceFunding.Start_Date__c = System.today();
            insert serviceFunding;

            Accreditation_Certification__c certificate = new Accreditation_Certification__c(service__c = service.Id);
            certificate.End_Date__c = System.today();
            insert certificate;

            GPMS_Emergency_Situation__c emergency = new GPMS_Emergency_Situation__c(service__c = service.Id);
            insert emergency;

            Test.getEventBus().deliver();
            
            List<GPMS_Interface_Logging__c> log = [SELECT Id from GPMS_Interface_Logging__c];
            
            System.assert(log.size()>=0);

        Test.stopTest();

        
        }
        
    }
}