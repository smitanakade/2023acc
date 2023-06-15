trigger BusinessLicenseDeleteEventTrigger on BusinessLicenseDeletePE__e (after insert) {

    BusinessLicenseTriggerService.deletePublicGroups(Trigger.new);

}