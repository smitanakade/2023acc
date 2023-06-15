@IsTest
public with sharing class TestStarRatingTriggerHelper {
	@TestSetup
	static void makeData() {
		STAR_Rating_History__c srh = new STAR_Rating_History__c(Status__c = 'Published');
		insert srh;
	}

	@IsTest
	static void testSetCalculation() {
		STAR_Rating_History__c srh = [
			SELECT Status__c, STAR_Rating_Calculation__c, Publish_Date__c, Go_Live_Date__c
			FROM STAR_Rating_History__c
			WHERE Status__c = 'Published'
			LIMIT 1
		];
        System.debug('Query1: ' + srh);
		Test.startTest();
		srh.STAR_Rating_Calculation__c = 4;
		update srh;
		
		STAR_Rating_History__c srh2 = [
			SELECT Status__c, STAR_Rating_Calculation__c, Publish_Date__c, Go_Live_Date__c
			FROM STAR_Rating_History__c 
			LIMIT 1
		];
        System.debug('Query2: ' + srh2);
		Integer goLiveDays = (Integer) STARRating_Settings__mdt.getInstance('Status_Change_Dates').Days_to_Go_Live__c;
		Integer publishDateDays = (Integer) STARRating_Settings__mdt.getInstance('Status_Change_Dates')
			.Days_to_Publish_Date__c;
        Test.stopTest();
		/* QISR - To fix 
		System.assertEquals(
			srh2.Publish_Date__c.addDays(goLiveDays),
			srh2.Go_Live_Date__c,
			'Go Live date should be ' +
			goLiveDays +
			' days from publish date'
		);
		System.assertEquals(
			Date.today().addDays(publishDateDays),
			srh2.Publish_Date__c,
			'Publish date should be ' +
			publishDateDays +
			' days from today'
		);*/
	}

	@IsTest
	static void testUpdateWithoutCalculation() {
		STAR_Rating_History__c srh = [
			SELECT Status__c, STAR_Rating_Calculation__c, Publish_Date__c, Go_Live_Date__c
			FROM STAR_Rating_History__c
			WHERE Status__c = 'Published'
			LIMIT 1
		];
		Test.startTest();
		update srh;
		Test.stopTest();
		srh = [
			SELECT Status__c, STAR_Rating_Calculation__c, Publish_Date__c, Go_Live_Date__c
			FROM STAR_Rating_History__c
			WHERE Status__c = 'Published'
			LIMIT 1
		];
		System.assertEquals(null, srh.Go_Live_Date__c, 'Go Live date should not be set');
		System.assertEquals(null, srh.Publish_Date__c, 'Publish date should not be set');
	}
}