@isTest
public class SrqiCSVFileReadLWCControllerTest {
  @testSetup
  static void setupData() {
    ContentVersion testContVer = new ContentVersion();  
    User testUser = createTestUser();
    System.runAs(testUser) {
      // Create Reporting_Period__c record
      String year = 'Year';
      Reporting_Period__c reportingPeriodList = TestDataFactory.createReportingPeriod(
        year
      );
      insert reportingPeriodList;
 
      //Populate and create ContentVersion
      testContVer.Title = 'Test Docs';
      testContVer.PathOnClient = 'SF_ELO_Code.txt';
      testContVer.VersionData = Blob.valueOf('Test Content');
      testContVer.IsMajorVersion = true;
      insert testContVer;
    }
  }

  @istest
  static void unitTestGetRecordsRP() {
    List<Reporting_Period__c> nameRPList = new  List<Reporting_Period__c> ();
      List<Reporting_Period__c> nameRPListActual = new  List<Reporting_Period__c> ();
    User testUser = createTestUser();

    Test.startTest();
    System.runAs(testUser) {
      nameRPList = [
         SELECT Reporting_Period_Short__c FROM Reporting_Period__c Where Current_Reporting_Period__c  = true AND Reporting_Period_Type__c = 'Year' ORDER BY Reporting_Period__c DESC LIMIT 1
      ];
      nameRPListActual = SrqiCSVFileReadLWCController.getRecordsRP();
      System.assertEquals(nameRPList, nameRPListActual );
      Test.stopTest();
    }
  }
  
  @istest
  static void unitTestInsertFileEntryFields() {
    ContentVersion testContVer = new ContentVersion();  
    User testUser = createTestUser();
    Test.startTest();
    System.runAs(testUser) {
      String year = 'Year';
      Reporting_Period__c reportingPeriodList = TestDataFactory.createReportingPeriod(
        year
      );
      insert reportingPeriodList;

      //Populate and create ContentVersion
      testContVer.Title = 'TestDocs.csv';
      testContVer.PathOnClient = 'SF_ELO_Code.txt';
      testContVer.VersionData = Blob.valueOf('Test Content');
      testContVer.IsMajorVersion = true;
      insert testContVer;
      Id reportingPeriodId = [SELECT Id FROM Reporting_Period__c LIMIT 1].Id;
      Id contentDocumentId = [
        SELECT ContentDocumentId
        FROM ContentVersion
        WHERE Title = 'TestDocs.csv'
      ]
      .ContentDocumentId;
       SrqiCSVFileReadLWCController.insertFileEntryFields(
        contentDocumentId,
        reportingPeriodId,
        '12345T'
      );
      System.assertEquals(1, [SELECT COUNT() FROM File_Staging__c]);
    }
    Test.stopTest();
  }
  // Create Test user
  public static User createTestUser() {
    String uniqueUserName =
      'AdminFileUploaduser' +
      DateTime.now().getTime() +
      '@testorg.com';
    Profile prof = [
      SELECT Id, Name
      FROM Profile
      WHERE Name LIKE 'Project Administrator'
    ];
    User user = new User();
    user.firstName = 'test2';
    user.lastName = 'test3';
    user.ProfileId = prof.Id;
    user.Username = uniqueUserName;
    user.email = 'test@test.com';
    user.Alias = 'tst';
    user.TimeZoneSidKey = 'Australia/Sydney';
    user.LocaleSidKey = 'en_AU';
    user.EmailEncodingKey = 'UTF-8';
    user.LanguageLocaleKey = 'en_US';
    insert user;
    return user;
  }
}