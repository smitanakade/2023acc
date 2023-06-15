@isTest
public with sharing class StarRatingExemptionCustomMetadataTest {
	@isTest
	public static void getExemptionConfigTest() {
		// Set values
		StarRatingExemptionCustomMetadata.ratingExemptDaysSetting = 100;
		StarRatingExemptionCustomMetadata.cerExemptDaysSetting = 90;
		StarRatingExemptionCustomMetadata.cmExemptDaysSetting = 80;
		StarRatingExemptionCustomMetadata.qiExemptDaysSetting = 70;
		StarRatingExemptionCustomMetadata.scrExemptDaysSetting = 60;
		StarRatingExemptionCustomMetadata.goLiveSetting = true;

		// Assert getters and setters
		System.assertEquals(100, StarRatingExemptionCustomMetadata.ratingExemptDaysSetting, 'Should be 100 days');
		System.assertEquals(90, StarRatingExemptionCustomMetadata.cerExemptDaysSetting, 'Should be 90 days');
		System.assertEquals(80, StarRatingExemptionCustomMetadata.cmExemptDaysSetting, 'Should be 80 days');
		System.assertEquals(70, StarRatingExemptionCustomMetadata.qiExemptDaysSetting, 'Should be 70 days');
		System.assertEquals(60, StarRatingExemptionCustomMetadata.scrExemptDaysSetting, 'Should be 60 days');
		System.assertEquals(true, StarRatingExemptionCustomMetadata.goLiveSetting, 'Should be true');
	}
}