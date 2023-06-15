trigger BusinessLicenseEventTrigger on BusinessLicensePE__e (after insert) {
	
    BusinessLicenseTriggerService.createPublicGroupAndShare(Trigger.new);
}