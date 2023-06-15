/*******************************************************************************************
 * @Name             StarRatingExemptionCustomMetadata
 * @Test class       StarRatingExemptionBatchTest
 * @Author           Gabriel Piragibe Cova Leda de Almeida
 * @Date             09-11-2022
 * @Story#           280716
 * @LWC Component    None
 * @Description		 Provides a centralised access to Exemptions custom metadata
 *******************************************************************************************/
/* MODIFICATION LOG
 * Version       Developer                                Date                Description
 *-------------------------------------------------------------------------------------------
 *  1.0     		Gabriel Piragibe Cova Leda de Almeida    09-11-2022          Initial Creation
 *******************************************************************************************/
public with sharing class StarRatingExemptionCustomMetadata {
	@testvisible
	private static STARRating_Exemption_Setting__mdt exemptionTestConfig = null;

	public static STARRating_Exemption_Setting__mdt getExemptionConfig() {
		if (exemptionTestConfig != null && Test.isRunningTest()) {
			return exemptionTestConfig;
		}

		STARRating_Exemption_Setting__mdt exemptionSetting = STARRating_Exemption_Setting__mdt.getInstance(
			'Exemption_Defaults'
		);

		if (exemptionSetting == null || Test.isRunningTest()) {
			exemptionSetting = new STARRating_Exemption_Setting__mdt(
				DeveloperName = 'Exemption_Defaults',
				Label = 'Exemption Defaults'
			);

			exemptionSetting.Rating_Exempt_Days__c = 365;
			exemptionSetting.CER_Exempt_Days__c = 365;
			exemptionSetting.CM_Exempt_Days__c = 270;
			exemptionSetting.QI_Exempt_Days__c = 270;
			exemptionSetting.SCR_Exempt_Days__c = 365;
			exemptionSetting.Star_Rating_Live__c = false;

			if (Test.isRunningTest()) {
				exemptionTestConfig = exemptionSetting;
				return exemptionSetting;
			}
		}

		return exemptionSetting;
	}

	@testvisible
	public static Decimal ratingExemptDaysSetting {
		get {
			return getExemptionConfig().Rating_Exempt_Days__c;
		}
		private set {
			getExemptionConfig().Rating_Exempt_Days__c = value;
		}
	}

	@testvisible
	public static Decimal cerExemptDaysSetting {
		get {
			return getExemptionConfig().CER_Exempt_Days__c;
		}
		private set {
			getExemptionConfig().CER_Exempt_Days__c = value;
		}
	}

	@testvisible
	public static Decimal cmExemptDaysSetting {
		get {
			return getExemptionConfig().CM_Exempt_Days__c;
		}
		private set {
			getExemptionConfig().CM_Exempt_Days__c = value;
		}
	}

	@testvisible
	public static Decimal qiExemptDaysSetting {
		get {
			return getExemptionConfig().QI_Exempt_Days__c;
		}
		private set {
			getExemptionConfig().QI_Exempt_Days__c = value;
		}
	}

	@testvisible
	public static Decimal scrExemptDaysSetting {
		get {
			return getExemptionConfig().SCR_Exempt_Days__c;
		}
		private set {
			getExemptionConfig().SCR_Exempt_Days__c = value;
		}
	}

	@testvisible
	public static Boolean goLiveSetting {
		get {
			return getExemptionConfig().Star_Rating_Live__c;
		}
		private set {
			getExemptionConfig().Star_Rating_Live__c = value;
		}
	}
}