/*******************************************************************************************
 * @Name             StarRatingsSettingsCustomMetadata
 * @testclass       StarRatingsSettingsCustomMetadataTest
 * @Author           Gabriel Piragibe Cova Leda de Almeida
 * @Date             22-05-2023
 * @Story#           366468
 * @LWC Component    None
 * @Description		 Provides a centralised access to STAR Ratings Settings custom metadata
 *******************************************************************************************/
/* MODIFICATION LOG
 * Version       Developer                                Date                Description
 *-------------------------------------------------------------------------------------------
 *  1.0     	 Gabriel Piragibe Cova Leda de Almeida    22-05-2023          Initial Creation
 *******************************************************************************************/
public with sharing class StarRatingsSettingsCustomMetadata {
	@testvisible
	private static STARRating_Settings__mdt starRatingSettingTestConfig = null;

	public static STARRating_Settings__mdt getStarRatingSettingsConfig() {
		if (starRatingSettingTestConfig != null && Test.isRunningTest()) {
			return starRatingSettingTestConfig;
		}

		STARRating_Settings__mdt starRatingSettings = STARRating_Settings__mdt.getInstance('Status_Change_Dates');

		if (starRatingSettings == null || Test.isRunningTest()) {
			starRatingSettings = new STARRating_Settings__mdt(
				DeveloperName = 'Status_Change_Dates',
				Label = 'Status Change Dates'
			);

			starRatingSettings.Days_after_Date_Decision_Ends_1__c = 365;
			starRatingSettings.Days_after_Date_Decision_Ends_2__c = 1095;
			starRatingSettings.Days_to_Go_Live__c = 14;
			starRatingSettings.Days_to_Publish_Date__c = 0;

			if (Test.isRunningTest()) {
				starRatingSettingTestConfig = starRatingSettings;
				return starRatingSettings;
			}
		}

		return starRatingSettings;
	}

	@testvisible
	public static Decimal daysAfterDateDecisionEndsOne {
		get {
			return getStarRatingSettingsConfig().Days_after_Date_Decision_Ends_1__c;
		}
		private set {
			getStarRatingSettingsConfig().Days_after_Date_Decision_Ends_1__c = value;
		}
	}

	@testvisible
	public static Decimal daysAfterDateDecisionEndsTwo {
		get {
			return getStarRatingSettingsConfig().Days_after_Date_Decision_Ends_2__c;
		}
		private set {
			getStarRatingSettingsConfig().Days_after_Date_Decision_Ends_2__c = value;
		}
	}

	@testvisible
	public static Decimal goLiveDate {
		get {
			return getStarRatingSettingsConfig().Days_to_Go_Live__c;
		}
		private set {
			getStarRatingSettingsConfig().Days_to_Go_Live__c = value;
		}
	}

	@testvisible
	public static Decimal publishDate {
		get {
			return getStarRatingSettingsConfig().Days_to_Publish_Date__c;
		}
		private set {
			getStarRatingSettingsConfig().Days_to_Publish_Date__c = value;
		}
	}
}
