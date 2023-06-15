/****************************************************************************************************
* @CreatedBy   : Accenture Developer Team
* @CreatedDate : 19-Jul-2022
* @Description : Handles the logic to Link with CHSP schedule details and service
* @Test Class  : GPMSCHSPLinkServiceScheduleTest
*****************************************************************************************************/
public with sharing class GPMSCHSPLinkServiceSchedule implements Schedulable {
    
    public GPMSCHSPLinkServiceBatch linkServicebatch;
    
    public GPMSCHSPLinkServiceSchedule(){
        linkServicebatch = new GPMSCHSPLinkServiceBatch();
    }
    
    public GPMSCHSPLinkServiceSchedule(GPMSCHSPLinkServiceBatch linkServicebatch){
        this.linkServicebatch = linkServicebatch;
    }
    
    public void execute(SchedulableContext scheduleContext) {
        
        try{
            
            Database.executeBatch(linkServicebatch,100);
            
        }catch(Exception exp){
            
            dohagedcare.Logger.error(exp.getMessage(),exp,'GPMS').Log(); 
            
        }
        
    }
}