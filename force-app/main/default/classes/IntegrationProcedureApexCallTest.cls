/**
* author: Daniel Clift
* date: 28/09/2022
* description: handles testing of class IntegrationProcedureApexCall 
**/
@isTest
public with sharing class IntegrationProcedureApexCallTest {
    @isTest
    public static void testRunCER() {
        String callableClass = 'IntegrationProcedureApexCall';

        Callable extension = (Callable) Type.forName(callableClass).newInstance();
        String Results = String.valueOf(extension.call('RunCER', new Map<String, Object>()));
    }

    @isTest
    public static void testNotRecognised() {
        String callableClass = 'IntegrationProcedureApexCall';
        
        Callable extension = (Callable) Type.forName(callableClass).newInstance();
        String Results = String.valueOf(extension.call('NotRecognised', new Map<String, Object>()));
    }
}
