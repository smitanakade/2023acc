/**
 * Author: PDas
 * Date: 14/03/2023
 * Description: This is a test class for batch class UserAccessReminderEmailBatch
 **/
/* MODIFICATION LOG
 * Version       Developer                   Date                Description
 *-------------------------------------------------------------------------------------------
 *  
 *******************************************************************************************/
@isTest
public class UserAccessReminderEmailBatchTest {
    
    @IsTest
    static void createTest() {
        
        Profile prof = [SELECT Id, Name FROM Profile WHERE Name LIKE 'System Administrator'];
        
        integer numberOfDays = integer.Valueof(Label.days_Limit);
        
        User user = new User();
        user.firstName = 'test1';
        user.lastName = 'test2';
        user.ProfileId = prof.Id;
        user.Username = 'testusr1@unittest.com.test';
        user.email = 'test@test.com';
        user.Alias = 'tst';
        user.TimeZoneSidKey = 'Australia/Sydney';
        user.LocaleSidKey = 'en_AU'; 
        user.EmailEncodingKey = 'UTF-8'; 
        user.LanguageLocaleKey = 'en_US';
        user.InactivateUserDate__c = system.today() + numberOfDays;
        insert user;
        
        Test.startTest();
            System.runAs(user) {
                UserAccessReminderEmailBatch b = new UserAccessReminderEmailBatch();
				database.executebatch(b);
            }
        Test.stopTest();
        
    }

}