@isTest
public class GPMSPermissionSetsManagerTest {
	@isTest
	public static void testGetObjectFields() {
		GPMSPermissionSetsManager pm = new GPMSPermissionSetsManager(
			'GPMS_MuleSoft_Integration'
		);

		System.assert(
			pm.setAllFieldsRead('Account')[0].SobjectType == 'Account'
		);
		System.assert(
			pm.setAllFieldsRead('Account')[0].PermissionsRead == true
		);
	}

	@isTest
	public static void setAllFieldsReadForAccount() {
		GPMSPermissionSetsManager pm = new GPMSPermissionSetsManager(
			'GPMS_MuleSoft_Integration'
		);

		List<FieldPermissions> fieldPermissions = pm.setAllFieldsRead(
			'Account'
		);
		for (FieldPermissions fieldPermission : fieldPermissions) {
			System.assertEquals(
				'Account',
				fieldPermission.SObjectType,
				'Change to permissions for object different to the one specified'
			);
			System.assertEquals(
				true,
				fieldPermission.PermissionsRead,
				'Read permission not set for ' + fieldPermission.Field
			);
		}
	}
}
