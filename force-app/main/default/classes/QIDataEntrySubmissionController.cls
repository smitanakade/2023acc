/**
 * @author Vivek J
 * @date 23-02-2023
 * @objects Reporting_Period__c, Quality_Indicator_Summary__c
 * @description : Controller for qiDataEntryAndSubmissison page
 */
public with sharing class QIDataEntrySubmissionController {
    /**
    * @description : get filter values
    * @author VJAIS | 02-27-2023 
    * @return QIResponseDTO 
    **/
    @AuraEnabled
    public static QIResponseDTO getfilterComponents(){
        QIResponseDTO reponse= new QIResponseDTO();
        try{
            FilteredComponents filterComp=new FilteredComponents();
            List<REPORTING_PERIOD__c> reportingPeriods=[SELECT id, Name, Start_Date__c, End_Date__c, Reporting_Period__c FROM Reporting_Period__c WHERE  Reporting_Period_Type__c = 'Quarter' AND Start_Date__c<=Today];
            if(!reportingPeriods.isEmpty()){
                for(REPORTING_PERIOD__c period:reportingPeriods){
                    filterComp.reportingPeriods.add(period.End_Date__c);
                }
            }
            filterComp.status=getQISStatus();
            reponse.returnValue=JSON.serialize(filterComp);
        }
        catch(Exception ex){
            reponse.status='Exception';
            dohagedcare.Logger.error(ex.getMessage(), ex, 'QIDataEntrySubmissionController').log();
        }
        return reponse;
   }
  
   /**
   * @description Get the status values
   * @author ChangeMeIn@UserSettingsUnder.SFDoc | 02-27-2023 
   * @return List<String> 
   **/
   private Static List<String> getQISStatus(){
        List<String> statusList= new List<String>();
        Schema.DescribeFieldResult fieldResult = Quality_Indicator_Summary__c.Status__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            statusList.add(pickListVal.getLabel());
        }     
        return statusList;
    }

   public class FilteredComponents{
    public  List<Date> reportingPeriods=new List<Date>();
    public  List<String> status;
   }
}