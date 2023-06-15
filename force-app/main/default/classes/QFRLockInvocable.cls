/**
 * @description       : This class received a date and schedules AcfrLockQuarterlyCaseScheduler.cls
 * @author            : Cyrille Jeufo
 * @group             :
 * @last modified on  : 17-May-2022
 * @last modified by  : Cyrille Jeufo
 * @TestClass AcfrCaseLockSchedulerTest
 **/
public with sharing class QFRLockInvocable {
	@InvocableMethod(
		label='scheduleCaseLockJob'
		description='Schedule quarterly Lock of Cases'
	)
	public static void scheduleCaseLockJob(List<Date> lockDate) {
		System.debug('@@@lockDate ' + lockDate);
		if (lockDate != null || !lockDate.isEmpty()) {
			if (lockDate[0] >= System.Today()) {
				String sch =
					'0 0 22 ' +
					String.valueOf(lockDate[0].Day()) +
					' ' +
					String.valueOf(lockDate[0].Month()) +
					' ? ' +
					' ' +
					String.valueOf(lockDate[0].Year());
				System.schedule(
					'Lock Cases ' + System.now(),
					sch,
					new AcfrCaseLockScheduler()
				);
			}
		}
	}
}
