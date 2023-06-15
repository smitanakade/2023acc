@isTest
public with sharing class SRQIUserCustomPermissionsTest {
	static final String USER_EMAIL = 'star@star.com';
	static final String USER_HAS_PERMISSION = 'User should have permission';
	static final String USER_NO_PERMISSION = 'User does not have permission';
	@TestSetup
	static void makeData() {
		Test.startTest();
		User u = new User(
			ProfileId = [SELECT Id FROM Profile WHERE Name = 'Health User' LIMIT 1]
			.Id,
			LastName = 'last',
			Email = USER_EMAIL,
			UserName = 'Star.Awesome.' + DateTime.now().getTime() + '@star.com',
			Alias = 'alias',
			TimeZoneSidKey = 'Australia/Sydney',
			EmailEncodingKey = 'UTF-8',
			LanguageLocaleKey = 'en_US',
			LocaleSidKey = 'en_US',
			IsActive = true
		);

		insert u;
		Test.stopTest();
	}

	@isTest
	public static void getUserCustomPermissionsTest() {
		User u = [SELECT Id FROM User WHERE Email = :USER_EMAIL LIMIT 1][0];

		PermissionSet ps = [SELECT id FROM PermissionSet WHERE Name = 'Star_Rating_Omni_Admin'];
		PermissionSetAssignment pa = new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = ps.Id);
		insert pa;

		Boolean response;

		Test.startTest();
		System.runAs(u) {
			String methodName = 'getUserCustomPermissions';
			Map<String, Object> input = new Map<String, Object>();
			Map<String, Object> output = new Map<String, Object>();
			Map<String, Object> options = new Map<String, Object>();
			input.put('userId', u.Id);
			response = SRQIUserCustomPermissions.invokeMethod(methodName, input, output, options);
		}
		Test.stopTest();

		System.assertEquals(true, response, USER_HAS_PERMISSION);
	}

	@isTest
	public static void getUserCustomPermissionsWithoutPSTest() {
		User u = [SELECT Id FROM User WHERE Email = :USER_EMAIL LIMIT 1][0];

		Boolean response;

		Test.startTest();
		System.runAs(u) {
			String methodName = 'getUserCustomPermissions';
			Map<String, Object> input = new Map<String, Object>();
			Map<String, Object> output = new Map<String, Object>();
			Map<String, Object> options = new Map<String, Object>();
			input.put('userId', u.Id);
			response = SRQIUserCustomPermissions.invokeMethod(methodName, input, output, options);
		}
		Test.stopTest();

		System.assertEquals(false, response, USER_NO_PERMISSION);
	}

	@isTest
	public static void getUserHoldReleaseCustomPermissionsTest() {
		User u = [SELECT Id FROM User WHERE Email = :USER_EMAIL LIMIT 1][0];

		PermissionSet ps = [SELECT id FROM PermissionSet WHERE Name = 'Contact_Centre_Hold_Release'];
		PermissionSetAssignment pa = new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = ps.Id);
		insert pa;

		Boolean response;

		Test.startTest();
		System.runAs(u) {
			String methodName = 'getUserHoldReleaseCustomPermissions';
			Map<String, Object> input = new Map<String, Object>();
			Map<String, Object> output = new Map<String, Object>();
			Map<String, Object> options = new Map<String, Object>();
			input.put('userId', u.Id);
			response = SRQIUserCustomPermissions.invokeMethod(methodName, input, output, options);
		}
		Test.stopTest();

		System.assertEquals(true, response, USER_HAS_PERMISSION);
	}

	@isTest
	public static void getUserHoldReleaseWithoutCustomPermissionsTest() {
		User u = [SELECT Id FROM User WHERE Email = :USER_EMAIL LIMIT 1][0];

		Boolean response;

		Test.startTest();
		System.runAs(u) {
			String methodName = 'getUserHoldReleaseCustomPermissions';
			Map<String, Object> input = new Map<String, Object>();
			Map<String, Object> output = new Map<String, Object>();
			Map<String, Object> options = new Map<String, Object>();
			input.put('userId', u.Id);
			response = SRQIUserCustomPermissions.invokeMethod(methodName, input, output, options);
		}
		Test.stopTest();

		System.assertEquals(false, response, USER_NO_PERMISSION);
	}

	@isTest
	public static void getComplianceUserCustomPermissionsTest() {
		User u = [SELECT Id FROM User WHERE Email = :USER_EMAIL LIMIT 1][0];

		Boolean response;

		Test.startTest();
		System.runAs(u) {
			String methodName = 'getComplianceUserCustomPermissions';
			Map<String, Object> input = new Map<String, Object>();
			Map<String, Object> output = new Map<String, Object>();
			Map<String, Object> options = new Map<String, Object>();
			input.put('userId', u.Id);
			response = SRQIUserCustomPermissions.invokeMethod(methodName, input, output, options);
		}
		Test.stopTest();

		System.assertEquals(false, response, USER_NO_PERMISSION);
	}

	@isTest
	public static void invalidMethodNameTest() {
		User u = [SELECT Id FROM User WHERE Email = :USER_EMAIL LIMIT 1][0];

		Boolean response;

		Test.startTest();
		System.runAs(u) {
			SRQIUserCustomPermissions.fakeException = true;
			String methodName = 'invalid';
			Map<String, Object> input = new Map<String, Object>();
			Map<String, Object> output = new Map<String, Object>();
			Map<String, Object> options = new Map<String, Object>();
			input.put('userId', u.Id);
			response = SRQIUserCustomPermissions.invokeMethod(methodName, input, output, options);
		}
		Test.stopTest();

		System.assertEquals(false, response, 'Response should be false as no method was executed');
	}
}