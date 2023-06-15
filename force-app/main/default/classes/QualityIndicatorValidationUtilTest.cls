/****************************************************************************************************
 * @CreatedBy   : Daniel Clift
 * @CreatedDate : 01/02/2023
 * @Description : Test class for QualityIndicatorValidationUtil
 *****************************************************************************************************/
@isTest
public with sharing class QualityIndicatorValidationUtilTest {
  private static final string NO_ERROR_STRING = 'Expected to receive an exception.';

  @TestSetup
  static void dataSetup() {
    Integer recordCount = 2;
    User testUser = TestDataFactory.createSystemAdminUser();

    System.runAs(testUser) {
      // reporting period
      Reporting_Period__c rPeriod = TestDataFactory.createReportingPeriod(
        'Quarter'
      );
      rPeriod.Start_Date__c = (System.today() + 12).addMonths(-6);
      rPeriod.End_Date__c = (System.today() + 24).addMonths(-3);
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
      List<Service_Account_Relationship__c> serviceAccountRecords = TestDataFactory.createServiceAccountRecords(
        recordCount,
        services,
        providers
      );
      insert serviceAccountRecords;
      // get quality indicator summary
      List<Quality_Indicator_Summary__c> qisRecords = TestDataFactory.createQISummaryRecords(
        recordCount,
        providers,
        rPeriod,
        services,
        serviceAccountRecords
      );
      insert qisRecords;
      // get quality indicator detail
      List<Quality_Indicator_Details__c> qidRecords = TestDataFactory.createQIDetailRecords(
        10,
        qisRecords
      );
      // Pressure_Injuries or Pressure_Injury
      List<String> recordTypes = new List<String>{
        'Pressure_Injuries',
        'Physical_Restraint',
        'Unplanned_Weight_Loss',
        'Falls_and_Major_Injury',
        'Medication_Management'
      };
      for (Integer i = 0; i < qidRecords.size(); i++) {
        if (i < 5) {
          String recordId = Schema.SObjectType.Quality_Indicator_Details__c.getRecordTypeInfosByDeveloperName()
            .get(recordTypes[i])
            .getRecordTypeId();
          qidRecords[i].RecordTypeId = recordId;
        } else {
          Integer k = i - 5;
          String recordId = Schema.SObjectType.Quality_Indicator_Details__c.getRecordTypeInfosByDeveloperName()
            .get(recordTypes[k])
            .getRecordTypeId();
          qidRecords[i].RecordTypeId = recordId;
        }
      }
      // test on trigger for completion date
      qidRecords[3].Status__c = 'Completed';
      insert qidRecords;
    }
  }
  @isTest
  public static void testCharacterLimit() {
    Quality_Indicator_Details__c qid = [
      SELECT Id
      FROM Quality_Indicator_Details__c
      LIMIT 1
    ];
    qid.Comments__c = generateRandomString(1001);

    Test.startTest();
    try {
      update qid;
      System.assert(false, NO_ERROR_STRING);
    } catch (Exception e) {
      System.assert(e.getMessage().contains('STRING_TOO_LONG'));
    }
    Test.stopTest();
  }

  @isTest
  public static void testLowerIntegerLimit() {
    Quality_Indicator_Settings__mdt qiMetaData = Quality_Indicator_Settings__mdt.getInstance(
      'Quality_Indicator_Detail_Error_Metadata'
    );

    Quality_Indicator_Details__c qid = [
      SELECT Id
      FROM Quality_Indicator_Details__c
      LIMIT 1
    ];

    qid.No_CR_Assessed__c = qiMetaData.Integer_Lower_Limit__c - 1;

    Test.startTest();
    try {
      update qid;
      System.assert(false, NO_ERROR_STRING);
    } catch (Exception e) {
      System.assert(
        e.getMessage().contains(qiMetaData.Integer_Error_Message__c)
      );
    }
    Test.stopTest();
  }

  @isTest
  public static void testUpperIntegerLimit() {
    Quality_Indicator_Settings__mdt qiMetaData = Quality_Indicator_Settings__mdt.getInstance(
      'Quality_Indicator_Detail_Error_Metadata'
    );

    Quality_Indicator_Details__c qid = [
      SELECT Id
      FROM Quality_Indicator_Details__c
      LIMIT 1
    ];

    qid.No_CR_Assessed__c = qiMetaData.Integer_Upper_Limit__c + 1;

    Test.startTest();
    try {
      update qid;
      System.assert(false, NO_ERROR_STRING);
    } catch (Exception e) {
      System.assert(
        e.getMessage().contains(qiMetaData.Integer_Error_Message__c)
      );
    }
    Test.stopTest();
  }

  @isTest
  public static void testUpdateField() {
    Quality_Indicator_Details__c qid = [
      SELECT Id, Status__c, Completion_Date__c
      FROM Quality_Indicator_Details__c
      LIMIT 1
    ];
    Test.startTest();
    qid.Status__c = 'Completed';
    update qid;
    qid = [
      SELECT Id, Status__c, Completion_Date__c
      FROM Quality_Indicator_Details__c
      WHERE Status__c = 'Completed'
      LIMIT 1
    ];
    System.assertEquals(date.today(), qid.Completion_Date__c);
    qid.Status__c = 'Not Started';
    update qid;
    Test.stopTest();
  }

  private static String generateRandomString(Integer len) {
    final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
    String randStr = '';
    while (randStr.length() < len) {
      Integer idx = Math.mod(
        Math.abs(Crypto.getRandomInteger()),
        chars.length()
      );
      randStr += chars.substring(idx, idx + 1);
    }
    return randStr;
  }

  @isTest static void testGetValidationErrorSetting() {
    Test.startTest();
    QualityIndicatorValidationUtil.ValidationSettingWrapper setting = QualityIndicatorValidationUtil.getValidationErrorSetting();
    Test.stopTest();

    Assert.isNotNull(setting.maxChar);
    Assert.isNotNull(setting.charError);
    Assert.isNotNull(setting.maxNumber);
    Assert.isNotNull(setting.minNumber);
    Assert.isNotNull(setting.numberError);
  }

  @isTest static void testGetValidationSettingsMap() {
    List<String> metadataNames = new List<String>{
      'QID_Warning_Recipients_Assessed_ADL',
      'QID_Warning_Recipients_Assessed_FMI'
    };

    Test.startTest();
    Map<String,QualityIndicatorValidationUtil.ValidationSettingWrapper> settingsMap = QualityIndicatorValidationUtil.getValidationSettingsMap(metadataNames);
    Test.stopTest();

    Assert.areEqual(2, settingsMap.size());
    Assert.isTrue(settingsMap.containsKey(metadataNames[0]));
    Assert.isNotNull(settingsMap.get(metadataNames[0]));
    Assert.isTrue(settingsMap.containsKey(metadataNames[1]));
    Assert.isNotNull(settingsMap.get(metadataNames[1]));
  }
}