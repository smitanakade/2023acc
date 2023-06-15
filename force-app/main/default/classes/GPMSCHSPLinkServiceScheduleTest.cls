@IsTest
public class GPMSCHSPLinkServiceScheduleTest {
    
    private static User currentUser = [SELECT Id From User WHERE Id = :UserInfo.getUserId()];
    
    @IsTest
    static void testPositive(){
        
        System.runAs(currentUser){
            Test.startTest();
            
            GPMSCHSPLinkServiceSchedule s = new GPMSCHSPLinkServiceSchedule();
            String sch = '00 40 09 ? * *';
            String jobId = System.schedule('Test GPMSCHSPLinkServiceSchedule', sch, s);
            
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
                              NextFireTime
                              FROM CronTrigger WHERE id = :jobId];
            
            System.assertEquals(sch, ct.CronExpression);
            
            Test.stopTest();
        }
    }
    
    @IsTest
    static void testException(){
        
        System.runAs(currentUser){
            Test.startTest();
            
            GPMSCHSPLinkServiceBatch linkServicebatch;
            
            GPMSCHSPLinkServiceSchedule s = new GPMSCHSPLinkServiceSchedule(linkServicebatch);
            String sch = '00 40 09 ? * *';
            
            String jobId = System.schedule('Test GPMSCHSPLinkServiceSchedule', sch, s);
            
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
                              NextFireTime
                              FROM CronTrigger WHERE id = :jobId];
            
            System.assertEquals(sch, ct.CronExpression);
            
            Test.stopTest();
        }
    }
    //@IsTest
    static void setup(){
        //account
        
        Account aco = new Account(Name = 'ACO Service',Incorporation_ID_Type__c='Not Incorporated',Prospective_Provider__c='');
        aco.Party_Id__c = '1112';
        aco.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Commonwealth_Home_Support_Programme').getRecordTypeId();
        insert aco;
        
        //service detail
        CHSP_Service_Schedule__c scheduleDetail = new CHSP_Service_Schedule__c();
        scheduleDetail.Party_Id__c = '1112';
        scheduleDetail.Service_Type_Level__c = 'Allied Health and Therapy Services';
        insert scheduleDetail;
        
        //service activity work plan
        CHSP_Service_Activity_Work_Plan_Record__c awp = new CHSP_Service_Activity_Work_Plan_Record__c();
        awp.Service_Type_Level__c = 'Allied Health and Therapy Services';
        awp.Service_Care_Sub_Type__c = 'Community and Home Support';
        awp.CHSP_Service_Schedule__c = scheduleDetail.Id;
        awp.Activity_Status__c = 'Approved';
        awp.Service_Care_Sub_Type__c = 'Community and Home Support';
        insert awp;
    }
}