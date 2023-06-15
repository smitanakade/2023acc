/**
* author: AG
* date: 04/05/2023
* description: Test class for QIGetPreviewLink
 */
 
@isTest
public with sharing class QIGetPreviewLinkTest {
    
    @TestSetup
    private static void setup() {
        User testUser = TestDataFactory.createSystemAdminUser();
        Test.startTest();
        System.runAs(testUser){
            Reporting_Period__c reportingPeriod= TestDataFactory.createReportingPeriod('Quarter');
            insert reportingPeriod; 
            
            List<Account> accounts = TestDataFactory.createProviderRecords(1);
            insert accounts;
            
      

            Contact conRecord = new Contact(FirstName = 'John', LastName = 'Citizen');
            conRecord.AccountId = accounts[0].id;
            conrecord.lastname = 'TestCon1114';
            conrecord.Salutation = 'Mr';
            conrecord.Email = 'TestCon1114@accenture.com';
            insert conRecord;

            File_Staging__c stagingRecord= new File_Staging__c(Name = 'File Staging Record', File_Name__c= 'Bulk File Insert',Reporting_Period__c=reportingPeriod.id);
            
            insert stagingRecord;

            String uniqueUserName =
                'Admin1user' +
                DateTime.now().getTime() + '@accenture.com';
            Profile adminUsrProfile = [
                SELECT Id
                FROM Profile
                WHERE Name = 'System Administrator'
            ];
            TestDataFactory.createProviderPortalUser(1, new List<Contact> {conRecord});
        }
        Test.stopTest();
    }
    
    
    @IsTest
    
    private static void getLinkTest(){
        User user = [SELECT Id, Alias, Contact.Id, Contact.AccountId FROM User WHERE Alias = 'pusr'];
        File_Staging__c  stagingRecord= [SELECT Id FROM File_Staging__c  WHERE Name= 'File Staging Record'];
        Test.startTest();
        System.runAs(user){
            
            String s = QIGetPreviewLink.getLink(stagingRecord.Id, ' ');
            System.assertNotEquals(s,'Error');
        
        }
    
    
    }
    
    
}