@isTest
private class IntegrationProcedureLoggerTest {
	@isTest
	public static void testrunIPs() {
        User testUser = TestDataFactory.createSystemAdminUser();
		Test.startTest();
        System.runAs(testUser){
            Map<String, Object> ipInput = new Map<String, Object> (); // used to pass data to 
            ipInput.put('status', 'Error');
            ipInput.put('node', 'Ip Path / Stake trace');
            ipInput.put('errorMessage', 'detailed Error Message.');
            
            
            Map<String, Object> args = new Map<String, Object>();
            args.put('input', ipInput);
            args.put('output', new Map<String, Object> ());
            args.put('options', new Map<String, Object> ());
            
            String callableClass = 'IntegrationProcedureLogger';
    
            Callable extension = (Callable) Type.forName(callableClass).newInstance();
            Boolean results = (Boolean)extension.call('Log', args);
            Boolean negativeResults = (Boolean)extension.call('NegativeCase', args);
            
            System.assert(results,'Result should be true');
            System.assert(negativeResults,'Result should be true');
        }
		Test.stopTest();
	}
}