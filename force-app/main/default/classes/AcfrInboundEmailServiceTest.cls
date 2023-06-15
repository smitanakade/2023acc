/****************************************************************************************************
 * @Description : Test Class for AcfrInboundEmailService
 *****************************************************************************************************/
@IsTest
public with sharing class AcfrInboundEmailServiceTest {
    
	
    @testSetup static void setup() {
        User testUser = TestDataFactory.createSystemAdminUser(); 
		System.runAs(testUser) {
        
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
				RecordTypeId = [
					SELECT Id
					FROM RecordType
					WHERE
						SobjectType = 'Account'
						AND IsActive = TRUE
						AND Name = 'Approved Provider'
					LIMIT 1
				]
				.Id
			);
			insert acc;
        
        Contact c=new Contact();
        c.firstName='Test';
        c.lastName='Last';
        c.email='test@test.com.au';
        c.AccountId=acc.id;
        c.Salutation='Mr';
        insert c;
            
        Case defaultCase=new Case();
        defaultCase.RecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('QFR').getRecordTypeId();
    	defaultCase.Subject='QFR Unresolved Items';
        insert defaultCase;
        
        }

    }
   
    @IsTest
    static void TestEmailCreatedAndLinked() {
       
       Messaging.InboundEmail email = new Messaging.InboundEmail() ;
       Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
       List<string> emails = new List<string>{'testbandi@gmail.com','testbandi123@gmail.com'};
      
       email.subject = 'Create case';
       email.fromAddress = 'someaddress@email.com';
       email.toAddresses = emails;
       email.plainTextBody = 'email body Sender:(test@test.com.au<)';
       Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
       attachment.body = blob.valueOf('my attachment text');
       attachment.fileName = 'textfileone.txt';
       attachment.mimeTypeSubType = 'text/plain';
       email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };
     
       AcfrInboundEmailService  testInbound=new AcfrInboundEmailService ();
       Test.startTest();
       testInbound.handleInboundEmail(email, env); 
       Test.stopTest();
        
        Case c=[select id from case where subject='QFR Unresolved Items' LIMIT 1];
        Task t=[select id,whatId from task where whatId=:c.id];
        
        
        System.assertEquals(t.WhatId, c.Id);
        
   		}
    
 

}