/****************************************************************************************************
* @CreatedBy   : Accenture Developer Team
* @CreatedDate : 18-Jul-2022
* @Description : Handles the logic to link service with service schedule detail
* @Test Class  : GPMSCHSPCPAWPLinkServiceScheduleTest
*****************************************************************************************************/
global with sharing class GPMSCHSPCPAWPLinkServiceSchedule implements Schedulable {
    
    public GPMSCHSPCPAWPLinkServiceBatch awpLinkServiceBatch;
    
    public GPMSCHSPCPAWPLinkServiceSchedule(){
        awpLinkServiceBatch = new GPMSCHSPCPAWPLinkServiceBatch();
    }
    
    public GPMSCHSPCPAWPLinkServiceSchedule(GPMSCHSPCPAWPLinkServiceBatch awpLinkServiceBatch){
        this.awpLinkServiceBatch = awpLinkServiceBatch;
    }
    
    public void execute(SchedulableContext scheduleContext) {
        
        try{
            
            Database.executeBatch(awpLinkServiceBatch,100);
            
        }catch(Exception exp){
            
            dohagedcare.Logger.error(exp.getMessage(),exp,'GPMS').Log(); 
            
        }
    }
}