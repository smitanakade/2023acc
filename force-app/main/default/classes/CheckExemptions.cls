/**
 * author: Daniel Clift
 * date: 30/09/2022
 * description: used to check if exemptions exist for a given subrating, and applies appropriate rating
 * @testClass CheckExemptionsTest
 **/
public with sharing class CheckExemptions {
	// SRHQueryId__c keeps track of the Star Rating History Record associated with the record
	// RequiresSRH__c set to true for query and then after linked to SRH, set to false ++ boolean condition for query to help selective query
	public static SRQI_CER__c checkCER(BusinessLicense service, STAR_Rating_History__c srh, String rpYear) {
		SRQI_CER__c cer = new SRQI_CER__c();
		cer.Reporting_Period__c = rpYear;
		cer.SRHQueryId__c = srh.Id;
		cer.RequiresSRH__c = true;
		cer.Service__c = srh.SF_Service_Id__c;
		cer.Provider__c = srh.SF_Provider_Id__c;
		cer.Service_Account__c = srh.Service_Account_Relationship__c;
		cer.Rating_Calc_Date__c = System.now();
		cer.Rating_Type__c = srh.Rating_Type__c;
		cer.Availability_Status__c = srh.Status__c;
		cer.External_Id__c = 'NAPS' + String.valueOf(srh.SF_Provider_Id__r.Oracle_ID__c) + '-' + 'NAP' + String.valueOf(srh.SF_Service_Id__r.Oracle_Service_ID__c) + '-' + rpYear;
		if (!service.CER_Exempt__c && service.CER_Consent_Revoked__c) {
			cer.Consumer_Experience_Rating__c = 1;
			cer.Consent_Revoked__c = true;
		} else if (service.CER_Exempt__c) {
			cer.Rating_Exemption_Granted__c = true;
			cer.Rating_Exemption_Reason__c = getExemptReason(service, 'CER');
		} else if (service.Operational_Two_Last_Quarters__c == false) {
			cer.Consumer_Experience_Rating__c = null;
		} else {
			cer.Consumer_Experience_Rating__c = 1;
			cer.Rating_Exemption_Granted__c = false;
		}
		return cer;
	}

	public static Care_Minutes_Summary__c checkCM(BusinessLicense service, STAR_Rating_History__c srh) {
		Care_Minutes_Summary__c cm = new Care_Minutes_Summary__c();
		cm.Reporting_Period__c = srh.Reporting_Period__c;
		cm.SRHQueryId__c = srh.Id;
		cm.RequiresSRH__c = true;
		cm.Service__c = srh.SF_Service_Id__c;
		cm.Provider_Name__c = srh.SF_Provider_Id__c;
		cm.Service_Account__c = srh.Service_Account_Relationship__c;
		cm.Rating_Calc_Date__c = System.now();
		cm.Rating_Type__c = srh.Rating_Type__c;
		cm.Availability_Status__c = srh.Status__c;
		cm.CMS_External_ID__c = String.valueOf(srh.SF_Provider_Id__r.Oracle_ID__c) + '-' + String.valueOf(srh.SF_Service_Id__r.Oracle_Service_ID__c) + '-' + String.valueOf(srh.Reporting_Period__c);
		if (service.CM_Exempt__c) {
			cm.Rating_Exemption_Granted__c = true;
			cm.Rating_Exemption_Reason__c = getExemptReason(service, 'CM');
		} else if (service.Operational_Two_Last_Quarters__c == false) {
			cm.Care_Minutes_Rating__c = null;
		} else {
			cm.Care_Minutes_Rating__c = 1;
		}
		return cm;
	}

	public static Quality_Indicator_Summary__c checkQI(BusinessLicense service, STAR_Rating_History__c srh) {
		Quality_Indicator_Summary__c qi = new Quality_Indicator_Summary__c();
		qi.Reporting_Period__c = srh.Reporting_Period__c;
		qi.SRHQueryId__c = srh.Id;
		qi.RequiresSRH__c = true;
		qi.Service__c = srh.SF_Service_Id__c;
		qi.PROVIDER_ID__c = srh.SF_Provider_Id__c;
		qi.SERVICE_ACCOUNT_ID__c = srh.Service_Account_Relationship__c;
		qi.Rating_Calc_Date__c = System.now();
		qi.Rating_Type__c = srh.Rating_Type__c;
		qi.Availability_Status__c = srh.Status__c;
		qi.External_ID__c = String.valueOf(srh.SF_Provider_Id__r.Oracle_ID__c) + '-' + String.valueOf(srh.SF_Service_Id__r.Oracle_Service_ID__c) + '-' + String.valueOf(srh.Reporting_Period__c);
		if (service.QI_Exempt__c) {
			qi.Rating_Exemption_Granted__c = true;
			qi.Rating_Exemption_Reason__c = getExemptReason(service, 'QI');
		} else if (service.Operational_Two_Last_Quarters__c == false) {
			qi.Quality_Indicator_Rating__c = null;
		} else {
			qi.Quality_Indicator_Rating__c = 1;
			qi.Status__c = 'Not Submitted';
		}
		return qi;
	}

	public static String getExemptReason(BusinessLicense service, String returnType) {
		String exemptReason;
		if (!service.Service__r.isEmpty()) {
			for (SRQI_Exemption__c exemption : service.Service__r) {
				if (exemption.RecordType.Name == 'CER Exemption' && returnType == 'CER') {
					exemptReason = exemption.Reason__c;
					break;
				}
				if (exemption.RecordType.Name == 'CM Exemption' && returnType == 'CM') {
					exemptReason = exemption.Reason__c;
					break;
				}
				if (exemption.RecordType.Name == 'QI Exemption' && returnType == 'QI') {
					exemptReason = exemption.Reason__c;
					break;
				}
			}
		}
		if (exemptReason == null) {
			exemptReason = 'Business Exemption';
		}
		return exemptReason;
	}
}