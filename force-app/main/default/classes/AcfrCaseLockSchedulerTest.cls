/**
 * @description       : Test class for AcfrcaseLockScheduler
 * @author            : Cyrille Jeufo
 * @group             :
 * @last modified on  : 05-May-2022
 * @last modified by  : Cyrille Jeufo
 **/
@IsTest
public with sharing class AcfrCaseLockSchedulerTest {
	@TestSetup
	static void setup() {
		Integer recordCount = 2; 
		User testUser = TestDataFactory.createSystemAdminUser();
        testUser.isActive = true;
        update testUser;
        Integer currentYear =  System.Today().year();
        Integer lastYear =  currentYear - 1;
		System.runAs(testUser) {
            Id accountRecordTypeId = Schema.Account.getSObjectType()
            .getDescribe()
            .getRecordTypeInfosByDeveloperName()
            .get('Approved_Provider')
            .getRecordTypeId();

			//Account
			Account acc = new Account(
				Name = 'Test Account Company',
				Purpose__c = 'Government',
				Incorporated_Under__c = 'Associations Act 2008 (NT)',
				Incorporation_Status__c = 'Registered',
				Incorporation_ID_Type__c = 'Other',
				Prospective_Provider__c = 'No',
				Incorporation_ID__c = String.valueOf(
					(Integer) (Math.random() * 1000000000)
				),
				RecordTypeId = accountRecordTypeId
			);
			insert acc;    

			List<BusinessLicense> services = new List<BusinessLicense>();
			services.add(
				new BusinessLicense(
					Name = 'Total',
					Effective_Date__c = Date.today(),
					Care_Type__c = 'Home Care',
					Status = 'Operational',
					Service_Care_Sub_Type__c = null,
					Status_Date__c = Date.today()
				)
			);
			services.add(
				new BusinessLicense(
					Name = 'Test Service ',
					Effective_Date__c = Date.today(),
					Care_Type__c = 'Residential',
					Status = 'Operational',
					AccountId = acc.id,
					Service_Care_Sub_Type__c = null,
					Status_Date__c = Date.today()
				)
			);
			insert services;

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
            
            //create quarters
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

            //get previous quarter
            Reporting_Period__c prevPeriod = [
                SELECT Id , QFR_Lock_Date__c
                FROM   Reporting_Period__c 
                WHERE  Reporting_Period_Type__c = 'Quarter' 
                AND    Previous_Reporting_Period__c = true
                LIMIT 1];

            //new case
            Id caseRecordTypeId = Schema.Case.getSObjectType()
                                            .getDescribe()
                                            .getRecordTypeInfosByDeveloperName()
                                            .get('QFR')
                                            .getRecordTypeId();

            System.debug('###prevPeriod ' + prevPeriod );
            Case testCase = new Case();
            testCase.Status = 'New';
            testCase.accountid = acc.id;
            testCase.Priority = 'Medium';
            testCase.QFR_RP_Locked__c = false;
            testCase.RecordTypeId = caseRecordTypeId;
            testCase.Reporting_Period__c = prevPeriod.Id;
            insert testCase;
		}
	} 

	@IsTest
	private static void lockQuarterlyCases() {
		User adminUser = [
			SELECT Id , isActive
			FROM User
			WHERE Email = 'adminuser@testorg.com'
			LIMIT 1
		];

        if(!adminUser.isActive){
            adminUser.isActive = true;
            update adminUser;
        }

        List<Case> newcases = new List<Case>();
        System.runAs(adminUser) {
            newcases = [SELECT Id , QFR_RP_Locked__c FROM Case WHERE QFR_RP_Locked__c = true ];
            System.assert(newcases.size() == 0 , 'No locked records expected. Found ' + newcases.size());

            Test.startTest();
            //get previous quarter
            Reporting_Period__c rp = [
                SELECT Id , QFR_Lock_Date__c
                FROM   Reporting_Period__c 
                WHERE  Reporting_Period_Type__c = 'Quarter' 
                AND    Previous_Reporting_Period__c = true
                LIMIT 1];
                
            rp.QFR_Lock_Date__c = Date.Today();
            update rp;
        
            Test.stopTest();
            
            newcases = [SELECT Id , QFR_RP_Locked__c FROM Case WHERE QFR_RP_Locked__c = true ];
        }
	}

}