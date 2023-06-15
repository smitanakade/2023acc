/**
 * author: Matthew Wall
 * date: 1/5/2023
 * description: Trigger on Regulatory Decision to dispatch Platform Event
 * @testClass RegulatoryDecisionTriggerTest
 **/
trigger RegulatoryDecisionTrigger on RegulatoryCodeViolation(
	after insert,
	after update
) {
	if (!(new TriggerBypassStrategy().isDisabled())) {
		if (Trigger.isUpdate && Trigger.isAfter) {
			TriggerDispatcher.dispatch(
				new RegulatoryDecisionTriggerHandler(),
				TriggerOperation.AFTER_UPDATE
			);
		}
		if (Trigger.isInsert && Trigger.isAfter) {
			TriggerDispatcher.dispatch(
				new RegulatoryDecisionTriggerHandler(),
				TriggerOperation.AFTER_INSERT
			);
		}
	}
}
