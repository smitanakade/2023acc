/*******************************************************************************************
 * @Name             SRQIUserCustomPermissions
 * @Test class       SRQIUserCustomPermissionsTest
 * @Author           Gabriel Piragibe Cova Leda de Almeida
 * @Date             07-11-2022
 * @Story#           TBA
 * @LWC Component    None
 * @Description		 utility class for omniscripts. It checks if user has required permissions
 *******************************************************************************************/
/* MODIFICATION LOG
 * Version       Developer                                Date                Description
 *-------------------------------------------------------------------------------------------
 *  1.0     	 Gabriel Piragibe Cova Leda de Almeida    12-10-2022          Initial Creation
 *  1.1 		 Gabriel								  21-11-2022 		  Added scr method
 *******************************************************************************************/
global with sharing class SRQIUserCustomPermissions implements omnistudio.VlocityOpenInterface {
	@testvisible
	private static Boolean fakeException = false;

	global static Boolean invokeMethod(
		String methodName,
		Map<String, Object> input,
		Map<String, Object> output,
		Map<String, Object> options
	) {
		Boolean result = false;

		try {
			switch on methodName {
				when 'getUserCustomPermissions' {
					result = getUserCustomPermissions(input, output, options);
				}
				when 'getUserHoldReleaseCustomPermissions' {
					result = getUserHoldReleaseCustomPermissions(input, output, options);
				}
				when 'getComplianceUserCustomPermissions' {
					result = getComplianceUserCustomPermissions(input, output, options);
				}
				when else {
					output.put('result', '');
				}
			}

			if (test.isRunningTest() && fakeException) {
				input.values()[20000] = true;
			}
		} catch (Exception ex) {
			dohagedcare.Logger.error(ex.getMessage(), ex, 'STAR Omniscript').log();
		}

		return result;
	}

	private static Boolean checkIfUserHasPermission(String userId, Set<String> permissions) {
		Set<Id> permissionSetIds = new Set<Id>();

		for (SetupEntityAccess access : [
			SELECT ParentId
			FROM SetupEntityAccess
			WHERE SetupEntityId IN (SELECT Id FROM CustomPermission WHERE DeveloperName IN :permissions)
		]) {
			permissionSetIds.add(access.ParentId);
		}

		List<User> userList = [
			SELECT Username
			FROM User
			WHERE
				Id IN (
					SELECT AssigneeId
					FROM PermissionSetAssignment
					WHERE AssigneeId = :userId AND PermissionSetId IN :permissionSetIds
				)
		];

		return !userList.isEmpty();
	}

	public static Boolean getUserCustomPermissions(
		Map<String, Object> input,
		Map<String, Object> output,
		Map<String, Object> options
	) {
		String userId = (String) input.get('userId');
		Set<String> permissions = new Set<String>{ 'Star_Rating_Admin' };
		Boolean hasPermissions = checkIfUserHasPermission(userId, permissions);

		output.put('result', hasPermissions);

		return hasPermissions;
	}

	public static Boolean getUserHoldReleaseCustomPermissions(
		Map<String, Object> input,
		Map<String, Object> output,
		Map<String, Object> options
	) {
		String userId = (String) input.get('userId');
		Set<String> permissions = new Set<String>{ 'Star_Rating_Admin', 'Star_Rating_Hold_Release' };
		Boolean hasPermissions = checkIfUserHasPermission(userId, permissions);

		output.put('result', hasPermissions);

		return hasPermissions;
	}

	public static Boolean getComplianceUserCustomPermissions(
		Map<String, Object> input,
		Map<String, Object> output,
		Map<String, Object> options
	) {
		String userId = (String) input.get('userId');
		Set<String> permissions = new Set<String>{ 'Compliance_User' };
		Boolean hasPermissions = checkIfUserHasPermission(userId, permissions);

		output.put('result', hasPermissions);

		return hasPermissions;
	}
}