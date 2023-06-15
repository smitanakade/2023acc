/**
 * @description       : Schedules the PermissionSetManager
 **/
public without sharing class GPMSPermissionSetsScheduler implements Schedulable {
	private String permissionSetApiName { get; set; }
	private DML dml = new DMLImpl();
	/**
	 * @description
	 * @param permissionSetApiName
	 **/
	public GPMSPermissionSetsScheduler(
		String permissionSetApiName,
		DML dmlImpl
	) {
		this.permissionSetApiName = permissionSetApiName;
		this.dml = dmlImpl;
	}
	/**
	 * @description
	 * @param permissionSetApiName
	 **/
	public GPMSPermissionSetsScheduler(String permissionSetApiName) {
		this.permissionSetApiName = permissionSetApiName;
	}
	/**
	 * @description
	 * @param SC
	 **/
	public void execute(SchedulableContext SC) {
		List<GPMS_Backup_Config__mdt> backupConfigs = GPMS_Backup_Config__mdt.getAll()
			.values();
		List<FieldPermissions> fieldPermissionToUpdate = new List<FieldPermissions>();
		GPMSPermissionSetsManager pm = new GPMSPermissionSetsManager(
			permissionSetApiName
		);
		for (GPMS_Backup_Config__mdt backupConfig : backupConfigs) {
			if (
				String.isNotBlank(backupConfig.Object_Name__c) &&
				backupConfig.IsCDCRequired__c
			) {
				fieldPermissionToUpdate.addAll(
					pm.setAllFieldsRead(backupConfig.Object_Name__c)
				);
			}
		}
		try {
			dml.insertRecords(fieldPermissionToUpdate, false);
		} catch (DmlException exp) {
			dohagedcare.Logger.error(
					exp.getMessage(),
					exp,
					'GPMSPermissionSetsScheduler'
				)
				.Log();
		}
	}
}
