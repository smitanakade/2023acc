/* Author: Nick Parsons
   Date Created: 15/8/22
   User Story: 233634
   Revision History: 
   15/9/22 - Added field history query and cutoff date to limit results to after re-issue */

global with sharing class OmniFileUploadHelper implements Callable {
  public static List<file> getRelatedFiles(Id caseId) {
    // Set the Form record ID
    Form__c declarationForm;
    Id formId;
    try {
      declarationForm = [
        SELECT Id, CreatedDate
        FROM Form__c
        WHERE Case__c = :caseId AND Type__c = 'Declaration and Submission'
        LIMIT 1
      ];
    } catch (QueryException e) {
      System.debug('Error querying Form: ' + e.getMessage());
      /* return new List<File>(); */
    }
    formId = declarationForm?.Id;

    // Query the field history for QA_Outcome__c
    List<CaseHistory> fieldHistory = [
      SELECT Case.CreatedDate, Field, NewValue, OldValue, CreatedDate
      FROM CaseHistory
      WHERE CaseId = :caseId AND Field = 'Status'
      ORDER BY CreatedDate DESC
    ];

    // Filter the list for only results for Re-Issue instances
    List<CaseHistory> reIssuedHistory = new List<CaseHistory>();
    for (CaseHistory fh : fieldHistory) {
      if (fh.NewValue == 'Reissued') {
        reIssuedHistory.add(fh);
      }
    }

    // Create the cut off date variable
    DateTime CutOffDate = DateTime.now();

    // Check if there has been any Re-Issue
    if (reIssuedHistory.isEmpty()) {
      CutOffDate = declarationForm?.createdDate;
    } else {
      CutOffDate = reIssuedHistory[0].CreatedDate;
    }

    //Query the ContentDocument for the related files
    List<File> files = new List<File>();

    for (ContentDocumentLink conLink : [
      SELECT
        ContentDocument.Id,
        ContentDocument.Title,
        ContentDocument.CreatedDate,
        ContentDocument.FileType
      FROM ContentDocumentLink
      WHERE
        LinkedEntityId = :caseId
        AND ContentDocument.FileType IN ('pdf', 'png', 'jpg', 'jpeg')
        AND ContentDocument.CreatedDate >= :CutOffDate
    ]) {
      File file = new File();
      file.Title = conLink.ContentDocument.Title;
      file.Id = conLink.ContentDocument.Id;
      file.CreatedDate = conLink.ContentDocument.CreatedDate;
      file.Type = conLink.ContentDocument.FileType;
      files.add(file);
    }
    return files;
  }

  global class File {
    global String Title;
    global String Type;
    global Id Id;
    global Datetime CreatedDate;
  }

  global Object call(string action, Map<String, Object> args) {
    Map<String, Object> input = (Map<String, Object>) args.get('input');
    Map<String, Object> output = (Map<String, Object>) args.get('output');
    Map<String, Object> options = (Map<String, Object>) args.get('options');
    switch on action {
      when 'getRelatedFiles' {
        List<File> relatedFiles = getRelatedFiles((String) input.get('caseId'));
        output.put('relatedFile', JSON.serialize(relatedFiles));
        return true;
      }
      when 'isReadOnlyForms' {
        Boolean isReadOnly = isReadOnlyForms((String) input.get('caseId'));
        output.put('isReadOnly', JSON.serialize(isReadOnly));
        return true;
      }
      when 'checkHasPermission' {
        Boolean canSubmit = checkUserCanSubmit();
        output.put('hasPermission', canSubmit);
        return true;
      }
      when else {
        throw new ExtensionMalformedException('Method not implemented');
      }
    }
  }
  public class ExtensionMalformedException extends Exception {
  }

  public static Boolean isReadOnlyForms(Id caseId) {
    List<File> files = OmniFileUploadHelper.getRelatedFiles(caseId);
    return files.size() > 0 ? true : false;
  }

  public static Boolean checkUserCanSubmit() {
    Boolean hasPerm = FeatureManagement.checkPermission(
      'QFR_Finance_Data_Submission'
    );
    return hasPerm;
  }
}
