/********************************************************************
 * @CreatedBy   : Daniel Clift
 * @CreatedDate : 01/02/2023
 * @Description : Utility class to validate QI detail records on commit
 * @Test Class  : QualityIndicatorValidationUtilTest
 * @modified by: Yifei Pei on 01/03/2023 add funtion to update Completion_Date__c when the status equals to 'Completed'
 * @modified by: Jamil Khaki on 14/03/2023: add method for QIT qitFieldValidation; prefix QID method name with qid.
 *********************************************************************/

public with sharing class QualityIndicatorValidationUtil {

  // get QI Metadata, for errors and limits
  private static final Quality_Indicator_Settings__mdt qiMetaData = Quality_Indicator_Settings__mdt.getInstance(
    'Quality_Indicator_Detail_Error_Metadata'
  );
  // error messages
  private static final string TEXT_ERROR = qiMetaData.Text_Error_Message__c;
  private static final string NUMBER_ERROR = qiMetaData.Integer_Error_Message__c;
  // error limits
  private static final double TEXT_CHARACTER_LIMIT = (double) qiMetaData.Text_Character_Limit__c;
  private static final double INTEGER_LOWER_LIMIT = (double) qiMetaData.Integer_Lower_Limit__c;
  private static final double INTEGER_UPPER_LIMIT = (double) qiMetaData.Integer_Upper_Limit__c;
  // Status picklist value
  private static final string STATUS_COMPLETE = 'Completed';

  public static void qidFieldValidation(
    List<Quality_Indicator_Details__c> qiList
  ) {

    //get schema for Quality_Indicator_Details__c
    final Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Quality_Indicator_Details__c.fields.getMap();

    for (Quality_Indicator_Details__c qid : qiList) {
      // map fields and values of qi detail record
      Map<String, Object> fieldsToValue = qid.getPopulatedFieldsAsMap();

      for (String fieldName : fieldsToValue.keySet()) {
        // get and store field, from fieldMap
        Schema.SObjectField qiField = fieldMap.get(fieldName);
        // don't validate formula fields
        if (qiField.getDescribe().isCalculated()) {
          continue;
        }
        // check if field is string or textarea
        if (
          qiField.getDescribe().getType() == Schema.DisplayType.String ||
          qiField.getDescribe().getType() == Schema.DisplayType.TextArea
        ) {
          // get and ensure value is a string
          String fieldValue = (String) fieldsToValue.get(fieldName);
          // check field TEXT_CHARACTER_LIMIT
          if (
            fieldValue != null &&
            fieldValue.length() > TEXT_CHARACTER_LIMIT
          ) {
            qid.addError(qiField, TEXT_ERROR);
          }
        }
        // check if integer or double
        else if (
          qiField.getDescribe().getType() == Schema.DisplayType.Integer ||
          qiField.getDescribe().getType() == Schema.DisplayType.Double
        ) {
          // get and ensure value is a double
          Double fieldValue = (Double) fieldsToValue.get(fieldName);
          
          
          //Added to check if the number have the decimal values - START
          if(
              fieldValue != null && Math.abs(fieldValue - fieldValue.intValue())!=0
          ){
                
               qid.addError(qiField, NUMBER_ERROR);
          }
          //Added to check if the number have the decimal values - END
          
          // check between INTEGER_LOWER_LIMIT to INTEGER_UPPER_LIMIT  
          if (
            fieldValue != null &&
            (fieldValue < INTEGER_LOWER_LIMIT ||
            fieldValue > INTEGER_UPPER_LIMIT)
          ) {
            qid.addError(qiField, NUMBER_ERROR);
          }
        } else {
          continue;
        }
      }
    }
  }

  //QIT Field Validations
  public static void qitFieldValidation(List<Quality_Indicator_Targets__c> qitList) {

    //get schema for Quality_Indicator_Targets__c
    final Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Quality_Indicator_Targets__c.fields.getMap();

    for (Quality_Indicator_Targets__c qit : qitList) {
      // map fields and values of qi target record
      Map<String, Object> fieldsToValue = qit.getPopulatedFieldsAsMap();

      for (String fieldName : fieldsToValue.keySet()) {
        // get and store fields, from fieldMap. QIT uses QID fieldName APIs and schema, data types
        Schema.SObjectField qiField = fieldMap.get(fieldName);
        // don't validate formula fields
        if (qiField.getDescribe().isCalculated()) {
          continue;
        }
        // check if field is string or textarea
        if (
          qiField.getDescribe().getType() == Schema.DisplayType.String ||
          qiField.getDescribe().getType() == Schema.DisplayType.TextArea
        ) {
          // get and ensure value is a string
          String fieldValue = (String) fieldsToValue.get(fieldName);
          // check field TEXT_CHARACTER_LIMIT
          if (
            fieldValue != null &&
            fieldValue.length() > TEXT_CHARACTER_LIMIT
          ) {
            qit.addError(qiField, TEXT_ERROR);
          }
        }
        // check if integer or double
        else if (
          qiField.getDescribe().getType() == Schema.DisplayType.Integer ||
          qiField.getDescribe().getType() == Schema.DisplayType.Double
        ) {
          // get and ensure value is a double
          Double fieldValue = (Double) fieldsToValue.get(fieldName);
          
          //Added to check if the number have the decimal values - START
          if(
              fieldValue != null && Math.abs(fieldValue - fieldValue.intValue())!=0
          ){
                
               
               qit.addError(qiField, NUMBER_ERROR);
          }
          //Added to check if the number have the decimal values - END  
            
          // check between INTEGER_LOWER_LIMIT to INTEGER_UPPER_LIMIT
          if (
            fieldValue != null &&
            (fieldValue < INTEGER_LOWER_LIMIT ||
            fieldValue > INTEGER_UPPER_LIMIT)
          ) {
            qit.addError(qiField, NUMBER_ERROR);
          }
        } else {
          continue;
        }
      }
    }
  }


  public static void fieldUpdate(
    List<Quality_Indicator_Details__c> qiList,
    Map<Id, Quality_Indicator_Details__c> qiOldMap
  ) {
    for (Quality_Indicator_Details__c qiRec : qiList) {
      if (qiOldMap != null) {
        Quality_Indicator_Details__c oldQIRec = qiOldMap.get(qiRec.Id);
        if (
          qiRec.Status__c == STATUS_COMPLETE &&
          qiRec.Status__c != oldQIRec.Status__c
        ) {
          qiRec.Completion_Date__c = date.today();
        } else if (
          oldQIRec.Status__c == STATUS_COMPLETE &&
          qiRec.Status__c != oldQIRec.Status__c
        ) {
          qiRec.Completion_Date__c = null;
        }
      } else {
        if (qiRec.Status__c == STATUS_COMPLETE) {
          qiRec.Completion_Date__c = date.today();
        }
      }
    }
  }

  /**
   * Wrapper class for the validations for use in LWC
   */
  public class ValidationSettingWrapper {
    // Maximum number of characters - will display error
    @AuraEnabled
    public Double maxChar;

    // Error message when more characters entered than maximum
    @AuraEnabled
    public String charError;

    // Maximum integer - will display error
    @AuraEnabled
    public Double maxNumber;

    // Minimum integer - will display error
    @AuraEnabled
    public Double minNumber;

    // Error message when integer is out of allowed range
    @AuraEnabled
    public String numberError;

    public ValidationSettingWrapper(Quality_Indicator_Settings__mdt setting) {
      this.maxChar = setting.Text_Character_Limit__c;
      this.charError = setting.Text_Error_Message__c;
      this.maxNumber = setting.Integer_Upper_Limit__c;
      this.minNumber = setting.Integer_Lower_Limit__c;
      this.numberError = setting.Integer_Error_Message__c;
    }
  }

  /**
   * Returns the validation errors configured in the custom metadata record
   */
  public static ValidationSettingWrapper getValidationErrorSetting() {
      ValidationSettingWrapper setting = new ValidationSettingWrapper(qiMetaData);
      return setting;
  }

  /**
   * Returns the validation warnings configured in the custom metadata record API names that are passed in
   */
  public static Map<String,ValidationSettingWrapper> getValidationSettingsMap(List<String> qualityIndicatorSettingNames) {
    Map<String,ValidationSettingWrapper> settingsMap = new Map<String,ValidationSettingWrapper>();

    for (String name : qualityIndicatorSettingNames) {
      Quality_Indicator_Settings__mdt setting = Quality_Indicator_Settings__mdt.getInstance(name);
      if (setting != null) {
        ValidationSettingWrapper wrapper = new ValidationSettingWrapper(setting);
        settingsMap.put(name, wrapper);
      }
    }

    return settingsMap;
  }
}