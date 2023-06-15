public With Sharing class StarRatingPublishBatch implements Database.Batchable<SObject> {
    public static final String PUBLISHED_STATUS = 'Published';
    public static final String LIVE_STATUS = 'Live';
    private static final String SEND_EML_MDT = 'Send_Email';

    public static String getQuery(){
        String retQuery = 'SELECT Id, Name, Status__c, Reporting_Period__c, Rating_Type__c, Publish_Date__c, Go_Live_Date__c , SF_Service_Id__c, SF_Provider_Id__c, SF_Provider_Id__r.Oracle_ID__c, SF_Service_Id__r.Oracle_Service_ID__c, Consumer_Experience_Id__c, '+
                            'Care_Minutes_Id__c, Quality_Indicator_Id__c '+
                            'FROM STAR_Rating_History__c '+
                            'WHERE (Publish_Date__c = Today OR Go_Live_Date__c  = Today) '+
                            'AND SF_Service_Id__c!=null AND  SF_Provider_Id__c!=null '+
                            'AND Reporting_Period__c!=null AND Service_Account_Relationship__c!=null '+
                            'AND Quality_Indicator_Id__c!=null '+
                            'AND Care_Minutes_Id__c!=null AND Consumer_Experience_Id__c!=null '+
                            'AND  Service_Compliance_Id__c!=null ';
                        return (retQuery);
    }
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(getQuery());
    }
    public void execute(Database.BatchableContext bc, List<STAR_Rating_History__c> scope) {
        try {
            publishStarRating(scope);
        } catch(Exception exp) {
            dohagedcare.Logger.error(exp.getMessage(),exp,'StarRatingPublishBatch').Log();
        }
    }

    public static void publishStarRating(List<STAR_Rating_History__c> starRatingList) {
        // Map<Rating Type, Map<Record Id, Publish || Live>>();
        Map<String, Map<Id, String>> ratingsMap = InitiateRatingsMap();
        // store service Ids
        Map<Id, Id> liveSHRRecords = new Map<Id, Id>();

        List<STAR_Rating_History__c> updateList = new List<STAR_Rating_History__c>();
        Date todayDate = Date.today();

        if (starRatingList.size() > 0) {
            for (STAR_Rating_History__c rating : starRatingList) {
                if (rating.Publish_Date__c == todayDate) {
                    rating.Status__c = PUBLISHED_STATUS;
                    rating.Rating_Type__c = 'New Rating';
                    updateList.add(rating);
                }
                else {
                    rating.Status__c = LIVE_STATUS;
                    rating.Rating_Type__c = 'Current Rating';
                    updateList.add(rating);
                    LiveSHRRecords.put(rating.Id, rating.SF_Service_Id__c);
                }
                setRatingsMap(rating, ratingsMap);
            }

            if (Schema.SObjectType.STAR_Rating_History__c.fields.Status__c.isUpdateable()) {
                update updateList;
            }

            if(!ratingsMap.isEmpty()){
                RatingsStatusHelper.UpdateSubRatingRecords(ratingsMap);
                RatingsStatusHelper.UpdateSRHRatingType(liveSHRRecords);
            }
        }
    }
    private static Map<String, Map<Id, String>> initiateRatingsMap() {
        Map<String, Map<Id, String>> initiateMap = new Map<String, Map<Id, String>>();
        initiateMap.put('CER', new Map<Id, String>());
        initiateMap.put('CM', new Map<Id, String>());
        initiateMap.put('QI', new Map<Id, String>());
        return initiateMap;
    }
    private static void setRatingsMap(STAR_Rating_History__c rating, Map<String, Map<Id, String>> ratingsMap) {
        if(rating.Status__c == PUBLISHED_STATUS  || rating.Status__c == LIVE_STATUS) {
            if(rating.Consumer_Experience_Id__c != null) {
                ratingsMap.get('CER').put(rating.Consumer_Experience_Id__c, rating.Status__c);
            }
            if(rating.Care_Minutes_Id__c != null) {
                ratingsMap.get('CM').put(rating.Care_Minutes_Id__c, rating.Status__c);
            }
            if(rating.Quality_Indicator_Id__c != null) {
                ratingsMap.get('QI').put(rating.Quality_Indicator_Id__c, rating.Status__c);
            }
        }
    }
    public void finish(Database.BatchableContext bc){
        try{
            Map<String, EmailNotificationSetting__mdt> mapEmailNotf = EmailNotificationSetting__mdt.getAll();
            if(mapEmailNotf.get(SEND_EML_MDT).EnablePublishNotification__c || mapEmailNotf.get(SEND_EML_MDT).EnableGoLiveNotification__c){
                StarRatingEmailBatch sRatingBatch = new StarRatingEmailBatch();
                Database.executeBatch(sRatingBatch,200);
            }
        } catch(Exception exp){
            dohagedcare.Logger.error(exp.getMessage(),exp,'StarRatingPublishBatch').Log();
        }
    }
}
