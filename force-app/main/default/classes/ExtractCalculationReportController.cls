public with sharing class ExtractCalculationReportController {

    @AuraEnabled(cacheable=true)
    public static List<STAR_Rating_History__c> getStarRatingHistory(){
        return [SELECT SF_Service_Id__r.Account.Integration_ID__c, SF_Service_Id__r.Account.Name, SF_Provider_Id__r.Name, 
        SF_Provider_Id__r.Integration_ID__c, SF_Service_Id__r.Name, SF_Service_Id__r.Integration_ID__c,STAR_Rating_Calculation__c,
        Quality_Indicator_Id__r.Quality_Indicator_Rating__c, Quality_Indicator_Id__r.Risk_Adjusted_PI_Level2__c, Quality_Indicator_Id__r.QI_Sector_Avg_PI_S2__c, 
        Quality_Indicator_Id__r.QI_Observed_Physical_Restraint__c, Quality_Indicator_Id__r.PI_Compare_with_National_Average__c, 
        Quality_Indicator_Id__r.Risk_Adjusted_SUWL__c, Quality_Indicator_Id__r.UWL_Compare_with_National_Average__c,
        Quality_Indicator_Id__r.Risk_Adjusted_Falls_with_injury__c,  Quality_Indicator_Id__r.QI_Predicted_FALLS__c, Quality_Indicator_Id__r.Risk_Adjusted_Falls_with_Major_injury__c, 
        Quality_Indicator_Id__r.FALLS_Compare_with_National_Average__c, 
        Quality_Indicator_Id__r.FMI_Compare_with_National_Average__c, Quality_Indicator_Id__r.QI_Observed_Polypharmacy__c, 
        Quality_Indicator_Id__r.Pres_Med_Compare_with_National_Average__c, Quality_Indicator_Id__r.QI_Observed_APSY__c, 
        Quality_Indicator_Id__r.Antipsy_Compare_with_National_Average__c, Quality_Indicator_Id__r.Risk_Adjusted_PI_Level3__c, Quality_Indicator_Id__r.QI_Sector_Avg_PI_S3__c,
        Quality_Indicator_Id__r.Risk_Adjusted_PI_Level4__c,Quality_Indicator_Id__r.QI_Sector_Avg_PI_S4__c, Quality_Indicator_Id__r.Risk_Adjusted_DT_PI__c,
        Quality_Indicator_Id__r.QI_Sector_Avg_PI_DT__c,Quality_Indicator_Id__r.Risk_Adjusted_Unstageable_PI__c,Quality_Indicator_Id__r.QI_Sector_Avg_PI_Unstageable__c,
        Consumer_Experience_Id__r.Consumer_Experience_Rating__c, Consumer_Experience_Id__r.Food_Always__c, Consumer_Experience_Id__r.Food_Most_of_the_time__c, 
        Consumer_Experience_Id__r.Food_Some_of_the_time__c, Consumer_Experience_Id__r.Food_Never__c, Consumer_Experience_Id__r.Safety_Always__c, 
        Consumer_Experience_Id__r.Safety_Most_of_the_time__c, Consumer_Experience_Id__r.Safety_Some_of_the_time__c, Consumer_Experience_Id__r.Safety_Never__c,
        Consumer_Experience_Id__r.Operation_Always__c, Consumer_Experience_Id__r.Operation_Most_of_the_time__c, Consumer_Experience_Id__r.Operation_Some_of_the_time__c, 
        Consumer_Experience_Id__r.Operation_Never__c, Consumer_Experience_Id__r.Care_Need_Always__c, Consumer_Experience_Id__r.Care_Need_Most_of_the_time__c,
        Consumer_Experience_Id__r.Care_Need_Some_of_the_time__c, Consumer_Experience_Id__r.Care_Need_Never__c, Consumer_Experience_Id__r.Competent_Always__c, 
        Consumer_Experience_Id__r.Competent_Most_of_the_time__c, Consumer_Experience_Id__r.Competent_Some_of_the_time__c, Consumer_Experience_Id__r.Competent_Never__c, 
        Consumer_Experience_Id__r.Independent_Always__c, Consumer_Experience_Id__r.Independent_Most_of_the_time__c, Consumer_Experience_Id__r.Independent_Some_of_the_time__c, 
        Consumer_Experience_Id__r.Independent_Never__c, Consumer_Experience_Id__r.Explain_Always__c, Consumer_Experience_Id__r.Explain_Most_of_the_time__c, 
        Consumer_Experience_Id__r.Explain_Some_of_the_time__c, Consumer_Experience_Id__r.Explain_Never__c, Consumer_Experience_Id__r.Respect_Always__c, 
        Consumer_Experience_Id__r.Respect_Most_of_the_time__c, Consumer_Experience_Id__r.Respect_Some_of_the_time__c, Consumer_Experience_Id__r.Respect_Never__c, 
        Consumer_Experience_Id__r.Follow_Up_Always__c, Consumer_Experience_Id__r.Follow_Up_Most_of_the_time__c, Consumer_Experience_Id__r.Follow_Up_Some_of_the_time__c, 
        Consumer_Experience_Id__r.Follow_Up_Never__c, Consumer_Experience_Id__r.Caring_Always__c, Consumer_Experience_Id__r.Caring_Most_of_the_time__c, 
        Consumer_Experience_Id__r.Caring_Some_of_the_time__c, Consumer_Experience_Id__r.Caring_Never__c, Consumer_Experience_Id__r.Voice_Always__c, 
        Consumer_Experience_Id__r.Voice_Most_of_the_time__c, Consumer_Experience_Id__r.Voice_Some_of_the_time__c, Consumer_Experience_Id__r.Voice_Never__c, 
        Consumer_Experience_Id__r.Home_Always__c, Consumer_Experience_Id__r.Home_Most_of_the_time__c, Consumer_Experience_Id__r.Home_Some_of_the_time__c, 
        Consumer_Experience_Id__r.Home_Never__c,  
        Care_Minutes_Id__r.Care_Minutes_Rating__c, Care_Minutes_Id__r.Registered_Nurse_Care_Minutes_Target__c, 
        Care_Minutes_Id__r.Actual_Registered_Nursing_Minutes__c, Care_Minutes_Id__r.Total_Care_Minutes_Target__c, Care_Minutes_Id__r.Actual_Care_Minutes__c,
        Service_Compliance_Id__r.Service_Compliance_Rating__c, Service_Compliance_Id__r.Regulatory_Decision__r.Name,
        Service_Compliance_Id__r.Regulatory_Decision__r.ViolationType.Name, Service_Compliance_Id__r.Regulatory_Decision__r.Date_Decision_Applied__c, 
        Service_Compliance_Id__r.Regulatory_Decision__r.Date_Decision_Ends__c, Service_Compliance_Id__r.Regulatory_Decision__r.Service_Compliance_Rating_Effect__c, 
        Service_Compliance_Id__r.Regulatory_Decision__r.Service_Name_lookup__r.Name
        FROM STAR_Rating_History__c 
        WHERE SF_Service_Id__r.Care_Type__c = 'Residential' AND SF_Service_Id__r.Status__c In  ('Operational', 'Offline') AND Status__c  = 'Published' AND Rating_Type__c= 'New Rating'
        ORDER BY SF_Service_Id__r.Integration_ID__c ];
    }

}