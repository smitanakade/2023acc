@isTest
private class GPMSGetPermisssionSetRecordforIPTest { 
    @isTest 
	public static void testrunIPs() {
        User testUser = TestDataFactory.createACQSCUser();
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
            String callableClass = 'GPMSGetPermissionSetRecordforIP';
    
            Callable extension = (Callable) Type.forName(callableClass).newInstance();
            Boolean results = (Boolean)extension.call('getPermissionSet', args);
            Boolean negativeResults = (Boolean)extension.call('NegativeCase', args);
            System.assertEquals(results,true, 'Result should be true');
        }
		Test.stopTest();
	}
}