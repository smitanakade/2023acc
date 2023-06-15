@isTest
private class BatchOnceOffUpdateFileStageObjTest {
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

    @isTest
    static void testBatchUpdateRecordType() {
      ContentVersion testContVer = new ContentVersion();  
   	 User testUser = createTestUser();
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
    }
	//List<File_Staging__c> fileStagingList= [select Id,Reporting_Category__c,RecordType.Name,RecordTypeId from File_Staging__c WHERE Reporting_Category__c ='CEI'];
        // Instantiate batch class
        BatchOnceOffUpdateFileStageObj batchObj = new BatchOnceOffUpdateFileStageObj();

        // Call Database.executeBatch()
        Test.startTest();
        Database.executeBatch(batchObj);
        Test.stopTest();
      
    }
}