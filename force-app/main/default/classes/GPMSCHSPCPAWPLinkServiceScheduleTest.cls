@IsTest
public class GPMSCHSPCPAWPLinkServiceScheduleTest {
    
    private static User currentUser = [SELECT Id From User WHERE Id = :UserInfo.getUserId()];
    
    @IsTest
    static void testPositive(){
        
        System.runAs(currentUser){
            Test.startTest();
            
            GPMSCHSPCPAWPLinkServiceSchedule s = new GPMSCHSPCPAWPLinkServiceSchedule();
            String sch = '00 40 09 ? * *';
            String jobId = System.schedule('Test GPMSCHSPCPAWPLinkServiceSchedule', sch, s);
            
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
                              NextFireTime
                              FROM CronTrigger WHERE id = :jobId];
            
            System.assertEquals(sch, ct.CronExpression);
            
            Test.stopTest();
        }
    }
    
    @IsTest
    static void testErrorCatch(){
        
        System.runAs(currentUser){
            Test.startTest();
            
            GPMSCHSPCPAWPLinkServiceBatch awpLinkServiceBatch;
            
            GPMSCHSPCPAWPLinkServiceSchedule s = new GPMSCHSPCPAWPLinkServiceSchedule(awpLinkServiceBatch);
            String sch = '00 40 09 ? * *';
            String jobId = System.schedule('Test GPMSCHSPCPAWPLinkServiceSchedule', sch, s);
            
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
        
        Account aco = new Account(Name = 'ACO',Incorporation_ID_Type__c='Not Incorporated',Prospective_Provider__c='');
        aco.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Commonwealth_Home_Support_Programme').getRecordTypeId();
        insert aco;
        
        //service detail
        List<CHSP_Procurement_Based_AWP_Record__c> chsp_List = new List<CHSP_Procurement_Based_AWP_Record__c>();
        for(integer i=0;i<10;i++){
            CHSP_Procurement_Based_AWP_Record__c chsp1 = new CHSP_Procurement_Based_AWP_Record__c();
            chsp1.Party_Id__c = '111';
            chsp1.Activity_Status__c = 'Approved';
            chsp1.Service_Type_Level__c = 'Allied Health and Therapy Services';
            chsp1.Service_Care_Sub_Type__c = 'xxx' + i;
            chsp_List.add(chsp1);
        }
        insert chsp_List;
    }
    
    static void test(){
        List<CHSP_Procurement_Based_AWP_Record__c> chsp_List = new List<CHSP_Procurement_Based_AWP_Record__c>();
        for(integer i=0;i<10;i++){
            CHSP_Procurement_Based_AWP_Record__c chsp1 = new CHSP_Procurement_Based_AWP_Record__c();
            chsp1.Party_Id__c = '6956';
            chsp1.Service_Type_Level__c = 'Allied Health and Therapy Services';
            chsp1.Activity_Status__c = 'Approved';
            chsp1.Service_Care_Sub_Type__c = 'xxx' + i;
            chsp_List.add(chsp1);
        }
        insert chsp_List;
    }
}