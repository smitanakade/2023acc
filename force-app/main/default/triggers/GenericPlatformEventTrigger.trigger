/**
 * author: Matthew Wall
 * date: 1/5/2023
 * description: Event Trigger on Generic_Event__e to collect and filter events
 * @testClass RegulatoryDecisionTriggerTest
 **/
trigger GenericPlatformEventTrigger on Generic_Event__e(after insert) {
	if (!(new TriggerBypassStrategy().isDisabled())) {
		if (Trigger.isInsert) {
			if (Trigger.isAfter) {
				TriggerDispatcher.dispatch(
					new GenericPlatformEventHandler(),
					TriggerOperation.AFTER_INSERT
				);
			}
		}
	}
}
