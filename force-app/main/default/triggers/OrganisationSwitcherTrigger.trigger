trigger OrganisationSwitcherTrigger on OrganisationSwitcherPlatformEvent__e (after insert) {
    OrgSwitcherPlatformEventTriggerHandler.updateUser(Trigger.new);
}