@isTest
global with sharing class IntegrationProcedureHandlerTest {
	@isTest
	public static void testrunIPs() {
		Test.startTest();
        Map<String, Object> ipInput = new Map<String, Object> (); // used to pass data to IP
    	Map<String, Object> ipOptions = new Map<String, Object>();
        
        new IntegrationProcedureHandler(IntegrationProcedureHandler.RUNCM, ipInput, ipOptions).executeIp();
        
        new IntegrationProcedureHandler(IntegrationProcedureHandler.RUNQI, ipInput).executeIp();
        
        new IntegrationProcedureHandler(IntegrationProcedureHandler.RUNCER).executeIp();
        
        new IntegrationProcedureHandler(IntegrationProcedureHandler.RUNALLSUBDOMAIN).executeIp();
        
		Test.stopTest();
	}
}