/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-04-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 **/
// Created by Ethan Sargent (ethan.sargent@health.gov.au) on 2022-08-01

@SuppressWarnings('apex:AvoidGlobalModifier')
global with sharing class AcfrCustomDatatableController implements omnistudio.VlocityOpenInterface2 {

  global Boolean invokeMethod(
    String methodName,
    Map<String, Object> input,
    Map<String, Object> output,
    Map<String, Object> options
  ) {
    switch on methodName {
      when 'getDatatableDefinitionForForm' {
        QFRDatatableDefinition datatableDefinition = 
          AcfrLWCDatatableController.getDatatableDefinitionForForm((String) input.get('formId'));

        output.put('datatableDefinition', datatableDefinition);
        return true;
      }
      when 'getCrossFormRowDefinitions' {
        Map<Id, QFRDatatableDefinition> datatableDefinitions = 
          AcfrLWCDatatableController.getCrossFormRowDefinitions(
            (String) input.get('formId'), 
            (List<String>) JSON.deserialize(JSON.serialize(input.get('glCodeBusinessIds')), List<String>.class)
          );

        output.put('datatableDefinitions', datatableDefinitions.values());
        return true;
      }
      when 'updateCells' {
        AcfrLWCDatatableController.updateCells((String) input.get('glCodeLineItemJson'));
        return true;
      }
      when 'updateServices' {
        AcfrLWCDatatableController.updateServices((String) input.get('servicesJson'));
        return true;
      }
      when 'getCaseId' {
        Id dataCaseId = 
          AcfrLWCDatatableController.getQFRCaseId(
            (String) input.get('formId')
          );

        output.put('dataCaseId', dataCaseId);
        return true;
      }
      when 'getGLCodeLineItemData' {
        List<GL_Code_Line_Item__c> dataGLCodeLineItems = 
          AcfrLWCDatatableController.getQFRGLCodeItemData(
            (List<String>) JSON.deserialize(JSON.serialize(input.get('glCodeBusinessIds')), List<String>.class),
            (List<String>) JSON.deserialize(JSON.serialize(input.get('serviceNames')), List<String>.class),
            (String) input.get('caseId')
          );
          
        output.put('dataGLCodeLineItems', dataGLCodeLineItems);
        return true;
      }
      when else {
        throw new AcfrCustomDatatableException('Specified action not supported');
      }
    }
  }

  public class AcfrCustomDatatableException extends Exception {
  }
}
