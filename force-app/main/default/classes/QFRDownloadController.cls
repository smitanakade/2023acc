// Created by Ethan Sargent (ethan.sargent@accenture.com) 2022-10-04

global with sharing class QFRDownloadController implements omnistudio.VlocityOpenInterface2 {


  global Boolean invokeMethod(
    String methodName,
    Map<String, Object> input,
    Map<String, Object> output,
    Map<String, Object> options
  ) {
    switch on methodName {
      when 'getFormIdsForCase' {
        Id caseId = (Id) input.get('caseId');
        List<FormDownloadDetail> formIds = getFormIdsForCase(caseId);
        output.put('formDetails', formIds);
        return true;
      }
      when 'getViabilityForm' {
        Id formId = (Id) input.get('formId');
        List<ViabilityResponse> responses = getViabilityResponses(formId);
        output.put('responses', responses);
        return true;
      }
      when 'saveExcelFile' {
        Id recordId = (Id) input.get('recordId');
        String b64Content = (String) input.get('contentBody');
        saveExcelFile(recordId, b64Content);
        return true;
      }
      when else {
        throw new IllegalArgumentException('Specified action not supported');
      }
    }
  }

  public static List<FormDownloadDetail> getFormIdsForCase(Id caseId) {
    List<Form__c> forms = [SELECT Id, Type__c, Name FROM Form__c WHERE Case__c = :caseId AND Type__c != 'Declaration and Submission' ORDER BY Type__c ASC];
    List<FormDownloadDetail> results = new List<FormDownloadDetail>();
    for (Form__c form: forms) {
      FormDownloadDetail detail = new FormDownloadDetail();
      detail.formId = form.Id;
      detail.formName = form.Name;
      if (form.Type__c == 'Residential Viability and Prudential Reporting' || form.Type__c == 'Home Care Viability and Prudential Reporting') {
        detail.downloaderType =  FormVariation.VIABILITY;
      } else {
        detail.downloaderType = FormVariation.DATATABLE;
      }
      detail.formType = form.Type__c;
      results.add(detail);
    }
    return results;
  }

  public static List<ViabilityResponse> getViabilityResponses(Id viabilityFormId) {
    List<Response__c> responses =   [SELECT Id, 
    Response_Options__c, 
    Question_Category__c, 
    Additional_Information__c, 
    Other_Business_Structure__c, 
    Care_or_Services__c,
    Other_Care_Services__c, 
    Question_Library__r.Question__c, //Modified this line of code to get the question from Question_Library__c
    Question_Library__r.Name
    FROM Response__c WHERE Form__c = :viabilityFormId];
    List<ViabilityResponse> results = new List<ViabilityResponse>();
    for (Response__c response: responses) {
      ViabilityResponse viabilityResponse = new ViabilityResponse();
      viabilityResponse.question = response.Question_Library__r.Question__c;
      viabilityResponse.response = response.Response_Options__c;
      viabilityResponse.additionalInformation = response.Additional_Information__c;
      viabilityResponse.careServices = response.Care_or_Services__c;
      viabilityResponse.additionalCareServices = response.Other_Care_Services__c;
      viabilityResponse.additionalBusinessStructure = response.Other_Business_Structure__c;
      results.add(viabilityResponse);
    }
    return results;
  }

  public static void saveExcelFile(Id recordId, String b64FileContent) {
    Blob contentBody = EncodingUtil.base64Decode(b64FileContent);
    ContentVersion cv = new ContentVersion(
      ContentLocation = 'S',
      FirstPublishLocationId = recordId,
      PathOnClient = 'SUBMITTED_QFR' + String.valueOf(Datetime.now()) + '.xlsx',
      VersionData = contentBody
    );
    insert cv;
  }

  @JsonAccess(serializable='always')
  public class FormDownloadDetail{
    public String formId;
    public String formName;
    public String formType;
    public transient FormVariation downloaderType;

    public String downloader {
      get {
        return downloaderType.name().toLowerCase();
      } 
      private set;
    }
  } 

  public enum FormVariation {
    VIABILITY,
    DATATABLE
  }

  @JsonAccess(serializable='always')
  public class ViabilityResponse {
    public String question;
    public String response;
    public String additionalInformation;
    public String careServices;
    public String additionalCareServices;
    public String additionalBusinessStructure;
  } 

}
