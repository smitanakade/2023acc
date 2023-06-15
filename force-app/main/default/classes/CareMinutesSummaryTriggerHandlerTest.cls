/**
 * author: Daniel Clift
 * date: 27/09/2022
 * description: test class for CareMinutesSummaryTriggerHandler
 **/

@isTest
public with sharing class CareMinutesSummaryTriggerHandlerTest {
  private static User currentUser = TestDataFactory.createSystemAdminUser();
  @TestSetup
  public static void dataSetup() {
    System.runAs(currentUser)
    {
        Test.startTest();
        Integer recordCount = 20;
        // get reporting period
        Reporting_Period__c rPeriod = TestDataFactory.createReportingPeriod(
          'Quarter'
        );
        insert rPeriod;
        // get providers
        List<Account> providers = TestDataFactory.createProviderRecords(
          recordCount
        );
        insert providers;
        // get services
        List<BusinessLicense> services = TestDataFactory.createServiceRecords(
          recordCount
        );
        insert services;
        // get service account relationships
        List<Service_Account_Relationship__c> serviceAccountRecords = TestDataFactory.createServiceAccountRecords(recordCount, services, providers);
        insert serviceAccountRecords;
        // get care minutes summary
        List<Care_Minutes_Summary__c> cmsRecords = TestDataFactory.createCareMinuteSummary(
          recordCount,
          services
        );
        for (Integer i = 0; i < recordCount; i++) {
          cmsRecords[i].Under_Review__c = false;
          cmsRecords[i].Provider_Name__c = providers[i].Id;
                cmsRecords[i].Service_Account__c = serviceAccountRecords[i].Id;
        }
        insert cmsRecords;
        // get service compliance history reocrds
        List<Service_Compliance_History__c> schRecords = TestDataFactory.createServiceComplianceHistory(
          recordCount
        );
        insert schRecords;
        // get star rating history records
        List<STAR_Rating_History__c> srhRecords = TestDataFactory.createStarRatingHistoryRecords(
          recordCount,
          services,
          providers,
          rPeriod
        );
        for (Integer i = 0; i < srhRecords.size(); i++) {
          srhRecords[i].Care_Minutes_Id__c = cmsRecords[i].Id;
          srhRecords[i].Service_Compliance_Id__c = schRecords[i].Id;
          srhRecords[i].Rating_Type__c = math.mod(i, 2) == 0
            ? 'New Rating'
            : 'Current Rating';
        }
        insert srhRecords;
        // get care minutes target records
        List<SRQI_Care_Minutes_Target__c> cmtRecords = TestDataFactory.createCareMinuteTarget(
          recordCount,
          services,
          cmsRecords
        );
        for (Integer i = 0; i < recordCount; i++) {
          cmtRecords[i].Provider_Name__c = providers[i].Id;
          cmtRecords[i].Service_Account__c = serviceAccountRecords[i].Id;
        }
        insert cmtRecords;
        Test.stopTest();
     }
  }

  @isTest
  public static void testPublishedStatus() {
    List<Care_Minutes_Summary__c> cmsList = [
      SELECT Id, Name, Availability_Status__c, Rating_Type__c, Service__c
      FROM Care_Minutes_Summary__c
      LIMIT 20
    ];
    System.debug(cmsList);

    System.runAs(currentUser)
    {
      for (Care_Minutes_Summary__c cms : cmsList) {
      cms.Availability_Status__c = 'Draft';
      cms.Rating_Type__c = 'New Rating';
    }
    update cmsList;
   
        test.startTest();
        for (Care_Minutes_Summary__c cms : cmsList) {
          cms.Availability_Status__c = 'Published';
        }
        update cmsList;
        test.stopTest();
    }

    AggregateResult count = [
      SELECT COUNT(Id)
      FROM Care_Minutes_Summary__c
      WHERE Availability_Status__c = 'Published'
      GROUP BY Availability_Status__c
      LIMIT 20
    ];

    System.assertEquals(
      20,
      count.get('expr0'),
      'The number of published records is incorrect'
    );
  }

  @isTest
  public static void testLiveStatus() {
    List<Care_Minutes_Summary__c> cmsList = [
      SELECT Id, Name, Availability_Status__c, Rating_Type__c, Service__c
      FROM Care_Minutes_Summary__c
      LIMIT 20
    ];
    System.debug(cmsList);

    System.runAs(currentUser)
    {
        for (Care_Minutes_Summary__c cms : cmsList) {
          cms.Availability_Status__c = 'Published';
          cms.Rating_Type__c = 'Current Rating';
        }
    update cmsList;
        test.startTest();
        for (Care_Minutes_Summary__c cms : cmsList) {
          cms.Availability_Status__c = 'Live';
        }
        update cmsList;
        test.stopTest();
    }

    AggregateResult count = [
      SELECT COUNT(Id)
      FROM Care_Minutes_Summary__c
      WHERE Availability_Status__c = 'LIVE'
      GROUP BY Availability_Status__c
      LIMIT 20
    ];

    System.assertEquals(
      20,
      count.get('expr0'),
      'The number of live records is incorrect'
    );
  }

  @isTest
  public static void testCurrentRating() {
    Care_Minutes_Summary__c cmCurrent = [
      SELECT Id, Name, Availability_Status__c, Rating_Type__c, Service__c
      FROM Care_Minutes_Summary__c
      LIMIT 1
    ];
   

    List<Account> providers = [SELECT Id FROM Account];
    List<Service_Account_Relationship__c> serviceAccountRecords = [SELECT Id FROM Service_Account_Relationship__c];

   
    System.runAs(currentUser)
    {
    cmCurrent.Availability_Status__c = 'LIVE';
    cmCurrent.Rating_Type__c = 'Current Rating';
    update cmCurrent;
        
    Care_Minutes_Summary__c cmNewCurrent = new Care_Minutes_Summary__c();
    cmNewCurrent.Availability_Status__c = 'Published';
    cmNewCurrent.Rating_Type__c = 'New Rating';
    cmNewCurrent.Service__c = cmCurrent.Service__c;
    cmNewCurrent.Provider_Name__c = providers[0].Id;
    cmNewCurrent.Service_Account__c = serviceAccountRecords[0].Id;
    insert cmNewCurrent;   
    test.startTest();
    cmNewCurrent.Availability_Status__c = 'LIVE';
    update cmNewCurrent;
    test.stopTest();
    
    }
      AggregateResult count = [
      SELECT COUNT(Id)
      FROM Care_Minutes_Summary__c
      WHERE Availability_Status__c = 'Live'
      GROUP BY Availability_Status__c
      LIMIT 20
    ];

    System.assertEquals(
      2,
      count.get('expr0'),
      'The number of published records is incorrect'
    );
        
  }
}