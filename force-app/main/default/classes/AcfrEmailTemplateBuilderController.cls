public with sharing class AcfrEmailTemplateBuilderController {
  static final String declartionFrmName = 'Declaration and Submission';
  static final String residentialViabilityFrmName = 'Residential Viability and Prudential Reporting';
  static final String homeCareViabilityFrmName = 'Home Care Viability and Prudential Reporting';
  static final String approvedProviderFrmName = 'Approved Provider Quarterly Financial Statements';
  static final String homeCareLabourCostFrmName = 'Home Care Labour Costs and Hours';
  static final String resiLabourCostFrmName = 'Residential Labour Costs and Hours';
  static final String mpsFoodFrmName = 'MPS Food and Nutrition Reporting';
  static final String resiFoodFrmName = 'Residential Food and Nutrition Reporting';
  static final String natsifacpFrmName = 'NATSIFACP Food and Nutrition Reporting';

  @AuraEnabled
  public static String getEmailSubject(String recordId) {
    String emailSubject = AcfrEmailService.getEmailSubject(
      recordId,
      'Case',
      'QFR_Reissue_Email'
    );
    return emailSubject;
  }

  @AuraEnabled
  public static String getEmailContent(String recordId) {
    String emailBody = AcfrEmailService.getEmailContent(
      recordId,
      'Case',
      'QFR_Reissue_Email'
    );
    List<Case> caseRec = [
      SELECT Id, AccountId, Account.Purpose__c
      FROM Case
      WHERE Id = :recordId AND AccountId != NULL
    ];
    List<Contact_Relationship__c> conRel = [
      SELECT id, Contact__c
      FROM Contact_Relationship__c
      WHERE
        Account__c = :caseRec[0].AccountId
        AND Role__c = 'QFR Primary Contact'
      LIMIT 1
    ];

    Set<String> notExistingTypes = new Set<String>();
    notExistingTypes.add(declartionFrmName);
    notExistingTypes.add(residentialViabilityFrmName);
    notExistingTypes.add(homeCareViabilityFrmName);
    notExistingTypes.add(approvedProviderFrmName);
    notExistingTypes.add(homeCareLabourCostFrmName);
    notExistingTypes.add(resiLabourCostFrmName);
    notExistingTypes.add(mpsFoodFrmName);
    notExistingTypes.add(resiFoodFrmName);
    notExistingTypes.add(natsifacpFrmName);
    for (Form__c rec : [
      SELECT
        id,
        Name,
        Type__c,
        QA_Outcome__c,
        Declaration_Complete__c,
        Declaration_Incomplete_Reason__c,
        Name_of_Signer__c,
        Case__c,
        Case__r.Account.Purpose__c
      FROM Form__c
      WHERE QA_Outcome__c != 'Accepted' AND Case__c = :recordId
      ORDER BY QA_Outcome__c DESC
    ]) {
        if(conRel != null){
      emailBody = getEmailBody(emailBody, rec, conRel[0]);
      notExistingTypes.remove(rec.Type__c);
        }
    }

    if (!notExistingTypes.isEmpty()) {
      emailBody = getEmailBodyNotExistingtype(emailBody, notExistingTypes);
    }
      emailBody = emailBody.substringAfter('<p').substringBeforeLast('</td>');
      emailBody = '<p'+emailBody;
      return emailBody;
  }

  public static String getEmailBody(
    String emailBody,
    Form__c rec,
    Contact_Relationship__c conRel
  ) {
    if (rec.Type__c == declartionFrmName) {
      emailBody = emailBody.replace('DECLARATION_FORM_NAME', rec.Type__c);
      emailBody = AcfrEmailService.hideConditions(
        emailBody,
        'DECLARATION',
        rec.Declaration_Complete__c != 'Yes'
      );

      DeclarationReasonWrapper resultwrap = checkDeclarationReason(
        rec,
        conRel,
        rec.Declaration_Incomplete_Reason__c
      );
      Boolean signatoryNonPrimary = resultwrap.signatoryNonPrimary;
      Boolean signatoryPrimary = resultwrap.signatoryPrimary;
      Boolean signatory = resultwrap.signatory;
      Boolean other = resultwrap.other;

      emailBody = AcfrEmailService.hideConditions(
        emailBody,
        'SIGNATORY2A_NONPRIMARY',
        signatoryNonPrimary
      );
      emailBody = AcfrEmailService.hideConditions(
        emailBody,
        'SIGNATORY2A_PRIMARY',
        signatoryPrimary
      );
      emailBody = AcfrEmailService.hideConditions(
        emailBody,
        'SIGNATORY2B',
        signatory
      );
      emailBody = AcfrEmailService.hideConditions(emailBody, 'OTHER2C', other);

      emailBody = emailBody.replace(
        'DECLARATION_LIST',
        resultwrap.declationList
      );
      emailBody = AcfrEmailService.mergeFields(emailBody, rec.Id, 'Form__c');
    } else if (rec.Type__c == residentialViabilityFrmName) {
      emailBody = emailBody.replace('RESI_VIABILITY_FORM_NAME', rec.Type__c);
      emailBody = AcfrEmailService.hideConditions(
        emailBody,
        'RESIVIABILITY',
        rec.QA_Outcome__c != 'Accepted'
      );
    } else if (rec.Type__c == homeCareViabilityFrmName) {
      emailBody = emailBody.replace('HOME_VIABILITY_FORM_NAME', rec.Type__c);
      emailBody = AcfrEmailService.hideConditions(
        emailBody,
        'HOMEVIABILITY',
        rec.QA_Outcome__c != 'Accepted'
      );
    } else if (rec.Type__c == approvedProviderFrmName) {
      emailBody = emailBody.replace('QUARTERLY_FORM_NAME', rec.Type__c);
      emailBody = AcfrEmailService.hideConditions(
        emailBody,
        'QUARTERLY',
        rec.QA_Outcome__c != 'Accepted'
      );
    } else if (rec.Type__c == homeCareLabourCostFrmName) {
      emailBody = emailBody.replace('HOME_LABOUR_FORM_NAME', rec.Type__c);
      emailBody = AcfrEmailService.hideConditions(
        emailBody,
        'HOMELABOUR',
        rec.QA_Outcome__c != 'Accepted'
      );
    } else if (rec.Type__c == resiLabourCostFrmName) {
      emailBody = emailBody.replace('RESI_LABOUR_FORM_NAME', rec.Type__c);
      emailBody = AcfrEmailService.hideConditions(
        emailBody,
        'RESILABOUR',
        rec.QA_Outcome__c != 'Accepted'
      );
    } else if (rec.Type__c == resiFoodFrmName) {
      emailBody = emailBody.replace('RESIFOOD_FORM_NAME', rec.Type__c);
      emailBody = AcfrEmailService.hideConditions(
        emailBody,
        'RESIFOOD',
        rec.QA_Outcome__c != 'Accepted'
      );
    } else if (rec.Type__c == mpsFoodFrmName) {
      emailBody = emailBody.replace('MPS_FORM_NAME', rec.Type__c);
      emailBody = AcfrEmailService.hideConditions(
        emailBody,
        'MPS',
        rec.QA_Outcome__c != 'Accepted'
      );
    } else if (rec.Type__c == natsifacpFrmName) {
      emailBody = emailBody.replace('NATSI_FORM_NAME', rec.Type__c);
      emailBody = AcfrEmailService.hideConditions(
        emailBody,
        'NATSI',
        rec.QA_Outcome__c != 'Accepted'
      );
    } else {
      //Do nothing
    }

    return emailBody;
  }

  public static String getEmailBodyNotExistingtype(
    String emailBody,
    Set<String> notExistingTypes
  ) {
    for (String rec : notExistingTypes) {
      if (rec == declartionFrmName) {
        emailBody = AcfrEmailService.hideConditions(
          emailBody,
          'DECLARATION',
          false
        );
      } else if (rec == residentialViabilityFrmName) {
        emailBody = AcfrEmailService.hideConditions(
          emailBody,
          'RESIVIABILITY',
          false
        );
      } else if (rec == homeCareViabilityFrmName) {
        emailBody = AcfrEmailService.hideConditions(
          emailBody,
          'HOMEVIABILITY',
          false
        );
      } else if (rec == approvedProviderFrmName) {
        emailBody = AcfrEmailService.hideConditions(
          emailBody,
          'QUARTERLY',
          false
        );
      } else if (rec == homeCareLabourCostFrmName) {
        emailBody = AcfrEmailService.hideConditions(
          emailBody,
          'HOMELABOUR',
          false
        );
      } else if (rec == resiLabourCostFrmName) {
        emailBody = AcfrEmailService.hideConditions(
          emailBody,
          'RESILABOUR',
          false
        );
      } else if (rec == resiFoodFrmName) {
        emailBody = AcfrEmailService.hideConditions(
          emailBody,
          'RESIFOOD',
          false
        );
      } else if (rec == mpsFoodFrmName) {
        emailBody = AcfrEmailService.hideConditions(emailBody, 'MPS', false);
      } else if (rec == natsifacpFrmName) {
        emailBody = AcfrEmailService.hideConditions(emailBody, 'NATSI', false);
      } else {
        //Do nothing
      }
    }

    return emailBody;
  }

  private static DeclarationReasonWrapper checkDeclarationReason(
    Form__c rec,
    Contact_Relationship__c conRel,
    String declarationIncReason
  ) {
    DeclarationReasonWrapper res = new DeclarationReasonWrapper();
    res.signatoryNonPrimary = false;
    res.signatoryPrimary = false;
    res.signatory = false;
    res.other = false;
    String declationList = '<ul>';
      if(declarationIncReason != null ){
          for (String val : declarationIncReason.split(';')) {
              declationList = declationList + '<li>' + val + '</li>';
              
              switch on val {
                  when 'Signatory is not an authorised person' {
                      res = clauseSignatoryIsNotAuthorizedPerson(conRel, res, rec);
                  }
                  when 'Other' {
                      res.other = true;
                  }
                  when else {
                      //Do nothing
                  }
              }
          }
      }
    declationList = declationList + '</ul>';
    res.declationList = declationList;

    return res;
  }

  public static DeclarationReasonWrapper clauseSignatoryIsNotAuthorizedPerson(Contact_Relationship__c conRel, DeclarationReasonWrapper res, Form__c rec){
    if (conRel != null) {
      res.signatoryPrimary = (conRel.Contact__c == rec.Name_of_Signer__c);
      res.signatoryNonPrimary = (conRel.Contact__c !=
      rec.Name_of_Signer__c);
    } else {
      res.signatoryNonPrimary = true;
    }

    if (rec.Case__r?.Account?.Purpose__c == 'Government') {
      res.signatory = true;
    }
    return res;
  }


  @AuraEnabled
  public static String getEmailAddress(String recordId) {
    String emailAdd = AcfrEmailService.getPrimaryEmailAddress(recordId);
    return emailAdd;
  }

  @AuraEnabled
  public static String getEmailAddressCC(String recordId) {
    String emailAdd = AcfrEmailService.getNonPrimaryEmailAddress(recordId);
    return emailAdd;
  }

  @AuraEnabled
  public static void sendSingleEmailMethod(
    String recordId,
    String emailBody,
    String emailAddress,
    String emailAddressCC,
    String emailSubject
  ) {
    AcfrEmailService.sendCustomSingleEmailMethod(
      recordId,
      emailBody,
      emailAddress,
      emailAddressCC,
      emailSubject
    );
  }

  public class DeclarationReasonWrapper {
    public Boolean signatoryNonPrimary;
    public Boolean signatoryPrimary;
    public Boolean signatory;
    public Boolean other;
    public String declationList;
  }
}