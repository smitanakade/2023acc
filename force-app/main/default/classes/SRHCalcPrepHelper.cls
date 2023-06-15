/**
 * author: Daniel Clift
 * date: 30/09/2022
 * description: helper for SRHCalcPrepBatch, logic to link and map and missing sub rating records
 * @testClass SRHCaclPrepBatchTest
 **/
public with sharing class SRHCalcPrepHelper {

	private final static String MASTER_RT = 'Master';
    private final static String STATUS_NS = 'Not Started';
	private final static String STATUS_OFF = 'Offline';
    private final static String APPROVED_PROVIDER_RT = 'Approved_Provider';
	
	// get previous year RP
	public static String rpYear = String.valueOf([SELECT Id FROM Reporting_Period__c WHERE Reporting_Period_Type__c = 'Year' and Current_Reporting_Period__c = true]?.Id);

	public static Map<String, Map<String, Object>> mapSubRatings(List<STAR_Rating_History__c> srhList) {
		Map<String, Map<String, Object>> serviceMap = SRHCalcPrepHelper.mapServices(srhList);
	
		// SRQI_CER__c
		serviceMap = SRHCalcPrepHelper.addCER(serviceMap);
		
		// Quality_Indicator_Summary__c
		List<Quality_Indicator_Summary__c> qiList = [
			SELECT Id, Service__c, Status__c, Rating_Exemption_Granted__c, Quality_Indicator_Rating__c
			FROM Quality_Indicator_Summary__c
			WHERE Service__c IN :serviceMap.keySet() AND Reporting_Period__r.Previous_Reporting_Period__c = TRUE
			AND SERVICE_ACCOUNT_ID__r.Active__c = TRUE
		];
		if (!qiList.isEmpty()) {
			serviceMap = SRHCalcPrepHelper.addQI(qiList, serviceMap);
		}

		// Service_Compliance_History__c
		List<Service_Compliance_History__c> scrList = [
			SELECT Id, Service__c
			FROM Service_Compliance_History__c
			WHERE Service__c IN :serviceMap.keySet() AND Rating_Type__c = 'Current Rating'
		];
		if (!scrList.isEmpty()) {
			serviceMap = SRHCalcPrepHelper.addSCR(scrList, serviceMap);
		}

		// Care_Minutes_Summary__c
		List<Care_Minutes_Summary__c> cmList = [
			SELECT Id, Service__c
			FROM Care_Minutes_Summary__c
			WHERE Service__c IN :serviceMap.keySet() AND Reporting_Period__r.Previous_Reporting_Period__c = TRUE
			AND Service_Account__r.Active__c = TRUE
		];
		if (!cmList.isEmpty()) {
			serviceMap = SRHCalcPrepHelper.addCM(cmList, serviceMap);
		}

		return serviceMap;
	}

	public static List<STAR_Rating_History__c> linkToSRH(
		Map<String, Map<String, Object>> serviceMap,
		Map<Id, BusinessLicense> sericeExemptions
	) {
		// Record lists to update and insert
		List<STAR_Rating_History__c> srhUpdate = new List<STAR_Rating_History__c>();
		List<SRQI_CER__c> cerList = new List<SRQI_CER__c>();
		List<Care_Minutes_Summary__c> cmList = new List<Care_Minutes_Summary__c>();
		List<Quality_Indicator_Summary__c> qiList = new List<Quality_Indicator_Summary__c>();
		List<Quality_Indicator_Summary__c> qiListToInsert = new List<Quality_Indicator_Summary__c>();
		List<BusinessLicense> servicesToCheckOp = new List<BusinessLicense>(); 
		List<Quality_Indicator_Summary__c> qiListToUpdate = new List<Quality_Indicator_Summary__c>();
		List<Quality_Indicator_Details__c> qidList = new List<Quality_Indicator_Details__c>();
		List<Quality_Indicator_Targets__c> qitList = new List<Quality_Indicator_Targets__c>();


		for (String serviceId : serviceMap.keySet()) {
			STAR_Rating_History__c srh = (STAR_Rating_History__c) serviceMap.get(serviceId).get('StarRating');
			for (String recordType : serviceMap.get(serviceId).keySet()) {
				// check for cer
				if (recordType == 'CER') {
					if (serviceMap.get(serviceId).get('CER') != null) {
						SRQI_CER__c cer = (SRQI_CER__c) serviceMap.get(serviceId).get('CER');
						srh.Consumer_Experience_Id__c = cer.Id;
					} else {
						SRQI_CER__c cer = CheckExemptions.checkCER(sericeExemptions.get(serviceId), srh, rpYear);
						if (cer.Rating_Exemption_Granted__c) {
							srh.Rating_Exemption_Granted__c = true;
							srh.Rating_Exemption_Reason__c = cer.Rating_Exemption_Reason__c;
							srh.Transferred__c = (cer.Rating_Exemption_Reason__c == 'Transferred Service');
							srh.New_Service__c = (cer.Rating_Exemption_Reason__c == 'New Service');
						}

						cerList.add(cer);
					}
				}
				// check for cm
				if (recordType == 'CM') {
					if (serviceMap.get(serviceId).get('CM') != null) {
						Care_Minutes_Summary__c cm = (Care_Minutes_Summary__c) serviceMap.get(serviceId).get('CM');
						srh.Care_Minutes_Id__c = cm.Id;
					} else {
						Care_Minutes_Summary__c cm = CheckExemptions.checkCM(sericeExemptions.get(serviceId), srh);
						if (cm.Rating_Exemption_Granted__c) {
							srh.Rating_Exemption_Granted__c = true;
							srh.Rating_Exemption_Reason__c = cm.Rating_Exemption_Reason__c;
							srh.Transferred__c = (cm.Rating_Exemption_Reason__c == 'Transferred Service');
							srh.New_Service__c = (cm.Rating_Exemption_Reason__c == 'New Service');
						}
						cmList.add(cm);
					}
				}
				// check for qi
				if (recordType == 'QI') {
					if (serviceMap.get(serviceId).get('QI') != null) {
						Quality_Indicator_Summary__c qi = (Quality_Indicator_Summary__c) serviceMap.get(serviceId)
							.get('QI');
						qi = QualityIndicatorService.checkQiStatusAndRating(qi);
						if(qi.Status__c == QualityIndicatorService.STATUS_NSUB) {
							qiListToUpdate.add(qi);
						}
						srh.Quality_Indicator_Id__c = qi.Id;
					} else {
						Quality_Indicator_Summary__c qi = CheckExemptions.checkQI(sericeExemptions.get(serviceId), srh);
						servicesToCheckOp.add(sericeExemptions.get(serviceId));

						if (qi.Rating_Exemption_Granted__c) {
							srh.Rating_Exemption_Granted__c = true;
							srh.Rating_Exemption_Reason__c = qi.Rating_Exemption_Reason__c;
							srh.Transferred__c = (qi.Rating_Exemption_Reason__c == 'Transferred Service');
							srh.New_Service__c = (qi.Rating_Exemption_Reason__c == 'New Service');
						}
						qiList.add(qi);
					}
				}
				// check for scr
				if (recordType == 'SCR') {
					if (serviceMap.get(serviceId).get('SCR') != null) {
						Service_Compliance_History__c scr = (Service_Compliance_History__c) serviceMap.get(serviceId)
							.get('SCR');
						srh.Service_Compliance_Id__c = scr.Id;
					} else {
						continue;
					}
				}
			}
			srhUpdate.add(srh);
		}

		if (!qiList.isEmpty()) {
			Map<Id, Boolean> operationalByServiceIdMap = 
			ServiceOperationalChecker.isOperationalForLastFullQuarter(servicesToCheckOp);//find if services are operational

			//calculations if service is operational or not
			for(Quality_Indicator_Summary__c qi : qiList) {
				if(operationalByServiceIdMap.get(qi.Service__c)) { //operational service
					qi.Status__c = STATUS_NS;
				}
				else {//not operational
					qi.Status__c = STATUS_OFF;
					qi.Rating_Exemption_Granted__c = true;
				}
				qiListToInsert.add(qi);
			}
		}
		
		// insert all new records
		if (!cerList.isEmpty()) {
			try {
				Database.SaveResult[] srList = Database.insert(cerList, false);
			} catch (Exception ex) {
				dohagedcare.Logger.error(ex.getMessage(), ex, 'SRHCalcPrepBatch').log();
			}
		}
		if (!cmList.isEmpty()) {
			try {
				Database.SaveResult[] srList = Database.insert(cmList, false);
			} catch (Exception ex) {
				dohagedcare.Logger.error(ex.getMessage(), ex, 'SRHCalcPrepBatch').log();
			}
		}
		if(!qiListToInsert.isEmpty()) {
			try {
				Database.SaveResult[] srList = Database.insert(qiListToInsert, false);
				Set<Id> qiListIdsInserted = new Set<Id>();
				for (Database.SaveResult sr : srList) {
					if (sr.isSuccess()) {
						// Operation was successful, so get the ID of the record that was processed
						qiListIdsInserted.add(sr.getId());
					}
				}
				
				List<Quality_Indicator_Summary__c> queryQIS = queryQIS(qiListIdsInserted);
				qidList = insertQID(queryQIS);
				qitList = insertQIT(queryQIS);

				Database.insert(qidList, false);
				Database.insert(qitList, false);
			} catch (Exception ex) {
				dohagedcare.Logger.error(ex.getMessage(), ex, 'SRHCalcPrepBatch').log();
			}
		}
		if(!qiListToUpdate.isEmpty()) {
			try {
				Database.update(qiListToUpdate, false);
			} catch (Exception ex) {
				dohagedcare.Logger.error(ex.getMessage(), ex, 'SRHCalcPrepBatch').log();
			}
		}
		// return records to update
		return srhUpdate;
	}

	public static List<Quality_Indicator_Summary__c> queryQIS(Set<Id> qisId) {
		return [SELECT Id, Service__c, Reporting_Period__c FROM Quality_Indicator_Summary__c WHERE ID IN :qisId];
	}

	/**
	 * @description - add Quality Indicator Details and Quality Indicator Targets for Quality Indicators 
	 */
	public static List<Quality_Indicator_Details__c> insertQID(List<Quality_Indicator_Summary__c> qiList) {
        List<Quality_Indicator_Details__c> qidList = new List<Quality_Indicator_Details__c>();

		for(Quality_Indicator_Summary__c qis : qiList) {
			for(Schema.RecordTypeInfo rt : Quality_Indicator_Details__c.SObjectType.getDescribe().getRecordTypeInfos()) {
				if(rt.isActive() && rt.getDeveloperName() != MASTER_RT) {
					qidList.add(new Quality_Indicator_Details__c(
						QI_Summary_Id__c = qis.Id,
						Status__c = STATUS_NS,
						RecordTypeId = rt.getRecordTypeId()));
				}
			}
		}
		return qidList;
    }

	/**
	 * @description - add Quality Indicator Details and Quality Indicator Targets for Quality Indicators 
	 */
	public static List<Quality_Indicator_Targets__c> insertQIT(List<Quality_Indicator_Summary__c> qiList) {
        List<Quality_Indicator_Targets__c> qitList = new List<Quality_Indicator_Targets__c>();

		for(Quality_Indicator_Summary__c qis : qiList) {
			qitList.add(new Quality_Indicator_Targets__c(
				Quality_Indicator_Summary__c = qis.Id,
				Service__c =  qis.Service__c,
				Reporting_Period__c = qis.Reporting_Period__c));
		}

		return qitList;
    }

	public static Map<String, Map<String, Object>> mapServices(List<STAR_Rating_History__c> srhRecords) {
		Map<String, Map<String, Object>> serviceMap = new Map<String, Map<String, Object>>();
		for (STAR_Rating_History__c srh : srhRecords) {
			serviceMap.put(
				srh.SF_Service_Id__c,
				new Map<String, Object>{ 'StarRating' => srh, 'CER' => null, 'CM' => null, 'QI' => null, 'SCR' => null }
			);
		}
		return serviceMap;
	}
	// adds CER
	public static Map<String, Map<String, Object>> addCER(
		Map<String, Map<String, Object>> serviceMap
	) {
		for (SRQI_CER__c cer : [
						SELECT Id, Service__c
						FROM SRQI_CER__c
						WHERE Service__c IN :serviceMap.keySet() AND Service_Account__r.Active__c = TRUE
						AND Extant__c = TRUE
						ORDER BY CreatedDate DESC
		]) {
			if(serviceMap.get(cer.Service__c).get('CER') == null){
				serviceMap.get(cer.Service__c).put('CER', cer);
			}
		}
		return serviceMap;
	}
	// adds QI
	public static Map<String, Map<String, Object>> addQI(
		List<Quality_Indicator_Summary__c> qiRecords,
		Map<String, Map<String, Object>> serviceMap
	) {
		for (Quality_Indicator_Summary__c qi : qiRecords) {
			serviceMap.get(qi.Service__c).put('QI', qi);
		}
		return serviceMap;
	}
	// adds SCR
	public static Map<String, Map<String, Object>> addSCR(
		List<Service_Compliance_History__c> scrRecords,
		Map<String, Map<String, Object>> serviceMap
	) {
		for (Service_Compliance_History__c scr : scrRecords) {
			serviceMap.get(scr.Service__c).put('SCR', scr);
		}
		return serviceMap;
	}
	// adds CM
	public static Map<String, Map<String, Object>> addCM(
		List<Care_Minutes_Summary__c> cmRecords,
		Map<String, Map<String, Object>> serviceMap
	) {
		for (Care_Minutes_Summary__c cm : cmRecords) {
			serviceMap.get(cm.Service__c).put('CM', cm);
		}
		return serviceMap;
	}
}