/**
 * Author: PDas
 * Date: 14/03/2023
 * Description: Batch job to send user deactivation reminder email
 * Test Class:UserAccessReminderEmailBatchTest
 **/
/* MODIFICATION LOG
 * Version       Developer                   Date                Description
 *-------------------------------------------------------------------------------------------
 *  
 *******************************************************************************************/
public class UserAccessReminderEmailBatch implements Database.Batchable<sobject>, Schedulable{
	
    public integer numberOfDays;
    public UserAccessReminderEmailBatch() {
        numberOfDays = integer.Valueof(Label.days_Limit);
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        date dt = system.today() + numberOfDays;
        String query = 'SELECT Id, InactivateUserDate__c, IsActive, profileId, email  ' + 
                        'FROM User WHERE  InactivateUserDate__c = :dt ' +
                        'AND IsActive = true';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<User> scope) { 
     
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();        
        emailTemplate et = [Select id from emailTemplate where name = 'User Deactivation Email Template' limit 1];
        OrgWideEmailAddress owa = [Select id, displayname from OrgWideEmailAddress  where displayname like '%NoReply%' limit 1];

        if(scope.size() > 0) {
            for (user u: scope) {
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();                
                email.setTemplateId(et.Id);
                email.setTargetObjectId(u.Id);
                email.setSaveAsActivity(false); 
                email.setOrgWideEmailAddressId(owa.id);
                emailList.add(email); 
                
            } 
            
            if(emailList.size() > 0){        
                try{
                    Messaging.SendEmailResult[] result = Messaging.sendEmail(emailList);
                
                    if (result[0].success) {
                        System.debug('Emails sent successfully..');
                    } else {
                        System.debug('Email send failed:: ' + result[0].errors[0].message);
                    }
                }catch(Exception ex) {
                    system.debug('error occured:: ' +ex.getMessage());
                }
                
            }
            
        }
        
    }
    

    public void finish(Database.BatchableContext bc) {
        // nothing to do here
    }
    
    public void execute(SchedulableContext sc) {		
        UserAccessReminderEmailBatch b = new UserAccessReminderEmailBatch();
		database.executebatch(b,200);		
	}
}