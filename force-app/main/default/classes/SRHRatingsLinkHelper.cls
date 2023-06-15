/**
 * author: Daniel Clift
 * date: 30/09/2022
 * description: Links inserted subrating records to satar rating history records
 **/
public with sharing class SRHRatingsLinkHelper {
	private static Map<String, Map<String, String>> srhUpdate = new Map<String, Map<String, String>>();

	private static void updateCM(List<Care_Minutes_Summary__c> cmList) {
		for (Care_Minutes_Summary__c cm : cmList) {
			srhUpdate.put(cm.SRHQueryId__c, new Map<String, String>{ 'CM' => cm.Id });
			cm.RequiresSRH__c = false;
		}
	}

	private static void updateCER(List<SRQI_CER__c> cerList) {
		for (SRQI_CER__c cer : cerList) {
			if (srhUpdate.get(cer.SRHQueryId__c) != null) {
				srhUpdate.get(cer.SRHQueryId__c).put('CER', cer.Id);
			} else {
				srhUpdate.put(cer.SRHQueryId__c, new Map<String, String>{ 'CER' => cer.Id });
				cer.RequiresSRH__c = false;
			}
		}
	}

	private static void updateQI(List<Quality_Indicator_Summary__c> qiList) {
		for (Quality_Indicator_Summary__c qi : qiList) {
			if (srhUpdate.get(qi.SRHQueryId__c) != null) {
				srhUpdate.get(qi.SRHQueryId__c).put('QI', qi.Id);
			} else {
				srhUpdate.put(qi.SRHQueryId__c, new Map<String, String>{ 'QI' => qi.Id });
				qi.RequiresSRH__c = false;
			}
		}
	}

	public static void updateSubDomains() {
		// For CM
		Map<Id, Care_Minutes_Summary__c> cmMap = new Map<Id, Care_Minutes_Summary__c>(
			[SELECT Id, SRHQueryId__c FROM Care_Minutes_Summary__c WHERE RequiresSRH__c = TRUE]
		);

		if (!cmMap.isEmpty()) {
			updateCM(cmMap.values());
			update cmMap.values();
		}

		// For CER
		Map<Id, SRQI_CER__c> cerMap = new Map<Id, SRQI_CER__c>(
			[SELECT Id, SRHQueryId__c FROM SRQI_CER__c WHERE RequiresSRH__c = TRUE]
		);
		if (!cerMap.isEmpty()) {
			updateCER(cerMap.values());
			update cerMap.values();
		}

		// for QI
		Map<Id, Quality_Indicator_Summary__c> qiMap = new Map<Id, Quality_Indicator_Summary__c>(
			[SELECT Id, SRHQueryId__c FROM Quality_Indicator_Summary__c WHERE RequiresSRH__c = TRUE]
		);
		if (!qiMap.isEmpty()) {
			updateQI(qiMap.values());
			update qiMap.values();
		}

		if (!srhUpdate.isEmpty()) {
			linkRecords(srhUpdate);
		}
	}

	public static void linkRecords(Map<String, Map<String, String>> srhRecords) {
		Map<Id, STAR_Rating_History__c> srhList = new Map<Id, STAR_Rating_History__c>(
			[SELECT Id FROM STAR_Rating_History__c WHERE Id IN :srhRecords.keySet()]
		);

		for (String srhId : srhRecords.keySet()) {
			Map<String, String> recordTypes = srhRecords.get(srhId);
			for (String recordType : recordTypes.keySet()) {
				if (recordType == 'CER' && srhList.get(srhId) != null) {
					srhList.get(srhId).Consumer_Experience_Id__c = recordTypes.get('CER');
				} else if (recordType == 'QI' && srhList.get(srhId) != null) {
					srhList.get(srhId).Quality_Indicator_Id__c = recordTypes.get('QI');
				} else if (recordType == 'CM' && srhList.get(srhId) != null) {
					srhList.get(srhId).Care_Minutes_Id__c = recordTypes.get('CM');
				} else {
					continue;
				}
			}
		}
		update srhList.values();
	}
}