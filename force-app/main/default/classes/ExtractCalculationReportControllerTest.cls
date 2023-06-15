@isTest
private with sharing class ExtractCalculationReportControllerTest {
    @isTest
	public static void testgetStarRatingHistory() {
		User adminUser = TestDataFactory.createSystemAdminUser();
        Test.startTest();
            System.runAs(adminUser) {
                List<STAR_Rating_History__c> result = ExtractCalculationReportController.getStarRatingHistory();
                System.assert(result != null,'Result should be found');
            }
		Test.stopTest();
	}
}