/**
 * @description       : Sets the Permissions for a given Permission Set
 **/
public with sharing class GPMSPermissionSetsManager {
	private Id permissionSetId { get; set; }
	private String targetPermissionSet { get; set; }
	private Set<String> existingReadPermissions = new Set<String>();

	public GPMSPermissionSetsManager(String targetPermissionSet) {
		this.permissionSetId = [
			SELECT Id
			FROM PermissionSet
			WHERE Name = :targetPermissionSet
			LIMIT 1
		]
		.Id;
		this.targetPermissionSet = targetPermissionSet;
		List<FieldPermissions> readPermissions = [
			SELECT Field
			FROM FieldPermissions
			WHERE ParentId = :this.permissionSetId AND PermissionsRead = TRUE
			ORDER BY Parent.Name ASC
		];
		for (FieldPermissions fieldPermission : readPermissions) {
			existingReadPermissions.add(fieldPermission.Field.toLowerCase());
		}
	}

	/**
	 * @description Returns the set of fields from the object
	 * @param sObjectApiName
	 * @return Set<String>
	 **/
	private Set<String> getObjectFields(String sObjectApiName) {
		Set<String> returnFields = new Set<String>();
		SObjectType sObjType;
		try {
			sObjType = ((SObject) Type.forName(sObjectApiName).newInstance())
				.getSObjectType();
		} catch (Exception exc) {
			dohagedcare.Logger.debug(
				'SObject describe information requested for ' +
					sObjectApiName +
					', which does not exist.'
			);
			// not rethrowing as original method did not throw
		}
		if (sObjType != null) {
			Map<String, Schema.SObjectField> objectFields = sObjType.getDescribe(SObjectDescribeOptions.DEFERRED)
				.fields.getMap();
			returnFields = objectFields.keySet();
		}
		return returnFields;
	}
	/**
	 * @description Returns the FieldPermissions that are required to be set with Read Permission
	 * @param sObjectApiName
	 * @return List<FieldPermissions>
	 **/
	public List<FieldPermissions> setAllFieldsRead(String sObjectApiName) {
		List<FieldPermissions> fieldPermissionToUpdate = new List<FieldPermissions>();
		dohagedcare.Logger.debug('sObjectApiName: ' + sObjectApiName);
		List<String> objectFields = new List<String>(
			getObjectFields(sObjectApiName)
		);
		if (objectFields != null && !objectFields.isEmpty()) {
			for (String field : objectFields) {
				final String fieldPermName = sObjectApiName + '.' + field;
				if (
					this.existingReadPermissions.contains(
						fieldPermName.toLowerCase()
					)
				) {
					continue;
				}
				FieldPermissions newFieldPermission = new FieldPermissions();
				newFieldPermission.ParentId = this.permissionSetId;
				newFieldPermission.SobjectType = sObjectApiName;
				newFieldPermission.Field = fieldPermName;
				newFieldPermission.PermissionsRead = true;
				fieldPermissionToUpdate.add(newFieldPermission);
			}
		}
		return fieldPermissionToUpdate;
	}
}
