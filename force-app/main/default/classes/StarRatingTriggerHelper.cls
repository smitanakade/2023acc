public with sharing class StarRatingTriggerHelper {

    public static void setDateAfterCalculation(STAR_Rating_History__c srh) {
        
        Integer goLiveDays = (Integer) STARRating_Settings__mdt.getInstance('Status_Change_Dates').Days_to_Go_Live__c;
        Integer publishDateDays = (Integer) STARRating_Settings__mdt.getInstance('Status_Change_Dates').Days_to_Publish_Date__c;
        if (publishDateDays == null || publishDateDays == 0) {
            srh.Publish_Date__c = System.today();
            srh.Status__c = 'Published';
        } else {
            srh.Publish_Date__c = Date.today().addDays(publishDateDays);
        }
        srh.Go_Live_Date__c = srh.Publish_Date__c.addDays(goLiveDays);
        srh.Rating_Calc_Date__c = System.now();
    }

    public static Boolean ratingCalculated(STAR_Rating_History__c srh, Map<Id, SObject> oldMap) {
        STAR_Rating_History__c oldRecord = (STAR_Rating_History__c) oldMap.get(srh.Id);

        if (srh.STAR_Rating_Calculation__c != null && oldRecord.STAR_Rating_Calculation__c == null) {
            return true;
        }
        return false;
    }
}