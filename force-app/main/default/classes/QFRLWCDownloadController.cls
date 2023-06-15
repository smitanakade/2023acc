public with sharing class QFRLWCDownloadController {
  @AuraEnabled(cacheable=true)
  public static List<FormDownloadDetail> getFormIdsForCase(Id caseId) {
    List<Form__c> forms = [
      SELECT
        Id,
        Type__c,
        Name,
        Case__r.RecordType.name,
        Case__r.NAPSID__c,
        Reporting_period__r.RP_Quarter__c,
        Case__r.Status,
        Case__r.Submission_count__c
      FROM Form__c
      WHERE Case__c = :caseId AND Type__c != 'Declaration and Submission'
      ORDER BY Type__c ASC
    ];
    List<FormDownloadDetail> results = new List<FormDownloadDetail>();
    for (Form__c form : forms) {
      FormDownloadDetail detail = new FormDownloadDetail();
      detail.formId = form.Id;
      detail.formName = form.Name;
      detail.recordTypeName = form.Case__r.RecordType.name;
      detail.providerID = form.Case__r.NAPSID__c;
      detail.currentQuarter = form.Reporting_period__r.RP_Quarter__c;
      detail.caseStatus = form.Case__r.Status;
      detail.submissionCount = form.Case__r.Submission_count__c;
      if (
        form.Type__c == 'Residential Viability and Prudential Reporting' ||
        form.Type__c == 'Home Care Viability and Prudential Reporting'
      ) {
        detail.downloaderType = FormVariation.VIABILITY;
      } else {
        detail.downloaderType = FormVariation.DATATABLE;
      }
      detail.formType = form.Type__c;
      results.add(detail);
    }
    system.debug(results);
    return results;
  }

  @AuraEnabled(cacheable=true)
  public static List<ViabilityResponse> getViabilityResponses(
    Id viabilityFormId
  ) {
    List<Response__c> responses = [
      SELECT
        Id,
        Response_Options__c,
        Question_Category__c,
        Additional_Information__c,
        Other_Business_Structure__c,
        Care_or_Services__c,
        Other_Care_Services__c,
        Question_Library__r.Question__c, //Modified this line of code to get the question from Question_Library__c
        Question_Library__r.Name
      FROM Response__c
      WHERE Form__c = :viabilityFormId
    ];
    List<ViabilityResponse> results = new List<ViabilityResponse>();
    for (Response__c response : responses) {
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

  @AuraEnabled
  public static void saveExcelFile(
    Id recordId,
    String b64FileContent,
    String fileName
  ) {
    Blob contentBody = EncodingUtil.base64Decode(b64FileContent);
    ContentVersion cv = new ContentVersion(
      ContentLocation = 'S',
      FirstPublishLocationId = recordId,
      PathOnClient = fileName,
      VersionData = contentBody
    );

    DMLImpl dmlinsert = new DMLImpl();
    dmlinsert.InsertRecord(cv);

    Id contentDocId = [
      SELECT ContentDocumentId
      FROM ContentVersion
      WHERE id = :cv.id
    ]
    .ContentDocumentId;

    List<Id> fileList = new List<Id>();
    fileList.add(contentDocId);

    calloutTRIMs(recordId, contentDocId);
  }

  @future(callout=true)
  public static void calloutTRIMs(Id parentId, Id contentDocId) {
    List<Id> contentDocList = new List<Id>();
    contentDocList.add(contentDocId);

    dohagedcare.FileStorageListController.uploadFilesToTRIMExt(
      parentId,
      contentDocList
    );
  }

  @AuraEnabled
  public static dohagedcare.FilePreviewUtility.PreviewResponseWrapper loadExcelFile(
    Id recordId
  ) {
    Id contentDocId = [
      SELECT ContentDocumentId
      FROM ContentDocumentLink
      WHERE
        LinkedEntityId = :recordId
        AND ContentDocument.FileExtension = 'xlsx'
      ORDER BY ContentDocument.LastModifiedDate DESC
      LIMIT 1
    ]
    .ContentDocumentId;

    dohagedcare.FilePreviewUtility.PreviewResponseWrapper result = dohagedcare.FilePreviewUtility.getFilePreviewDetailsExt(
      recordId,
      contentDocId
    );

    return result;
  }

  @JsonAccess(serializable='always')
  public class FormDownloadDetail {
    @AuraEnabled
    public String formId { get; set; }
    @AuraEnabled
    public String formName { get; set; }
    @AuraEnabled
    public String formType { get; set; }
    @AuraEnabled
    public String recordTypeName { get; set; }
    @AuraEnabled
    public String providerID { get; set; }
    @AuraEnabled
    public String currentQuarter { get; set; }
    @AuraEnabled
    public String caseStatus { get; set; }
    @AuraEnabled
    public Decimal submissionCount { get; set; }
    @AuraEnabled
    public transient FormVariation downloaderType { get; set; }

    @AuraEnabled
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
    @AuraEnabled
    public String question { get; set; }
    @AuraEnabled
    public String response { get; set; }
    @AuraEnabled
    public String additionalInformation { get; set; }
    @AuraEnabled
    public String careServices { get; set; }
    @AuraEnabled
    public String additionalCareServices { get; set; }
    @AuraEnabled
    public String additionalBusinessStructure { get; set; }
  }
}
