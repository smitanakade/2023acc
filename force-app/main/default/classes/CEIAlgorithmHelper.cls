/**
* author: Daniel Clift
* date: 26/08/2022
* description: Collects all CEI data related to one CER record
* @testClass CEIAlgorithmTest
**/

public with sharing class CEIAlgorithmHelper {
    // all ceiList records are related by cerId
    public static SRQI_CER__c calculateCategories(SRQI_CER__c cerRecord, List<SRQI_CEI__c> ceiList) {
        try {
            // Map for all categories, with zero count in interger value
            Map<String, Map<String, Integer>> categoryMap = setUpMap();
            // counts resonses and adds to map
            for(SRQI_CEI__c cei : ceiList) {
                categoryMap.get('Food__c').put(cei.Food__c, categoryMap.get('Food__c').get(cei.Food__c) + 1);
                categoryMap.get('Safety__c').put(cei.Safety__c, categoryMap.get('Safety__c').get(cei.Safety__c) + 1);
                categoryMap.get('Operation__c').put(cei.Operation__c, categoryMap.get('Operation__c').get(cei.Operation__c) + 1);
                categoryMap.get('Care_Need__c').put(cei.Care_Need__c, categoryMap.get('Care_Need__c').get(cei.Care_Need__c) + 1);
                categoryMap.get('Competent__c').put(cei.Competent__c, categoryMap.get('Competent__c').get(cei.Competent__c) + 1);
                categoryMap.get('Independent__c').put(cei.Independent__c, categoryMap.get('Independent__c').get(cei.Independent__c) + 1);
                categoryMap.get('Explain__c').put(cei.Explain__c, categoryMap.get('Explain__c').get(cei.Explain__c) + 1);
                categoryMap.get('Respect__c').put(cei.Respect__c, categoryMap.get('Respect__c').get(cei.Respect__c) + 1);
                categoryMap.get('Follow_Up__c').put(cei.Follow_Up__c, categoryMap.get('Follow_Up__c').get(cei.Follow_Up__c) + 1);
                categoryMap.get('Caring__c').put(cei.Caring__c, categoryMap.get('Caring__c').get(cei.Caring__c) + 1);
                categoryMap.get('Voice__c').put(cei.Voice__c, categoryMap.get('Voice__c').get(cei.Voice__c) + 1);
                categoryMap.get('Home__c').put(cei.Home__c, categoryMap.get('Home__c').get(cei.Home__c) + 1);
            }
            // passes the values to CER record
            cerRecord = cerUpdateValues(cerRecord, categoryMap, Decimal.valueOf(ceiList.size()));

        } catch(Exception exp) {

            dohagedcare.Logger.error(exp.getMessage(),exp,'Rating Calc').Log(); 
        }
        // return CER to batch class
        return cerRecord;
    }

    public static Map<String, Map<String, Integer>> setUpMap() {
        // initialise map
        Map<String, Map<String, Integer>> categoryMap = new Map<String, Map<String, Integer>>();
        categoryMap.put('Food__c', new Map<String, Integer>{'Never' => 0, 'Some of the time' => 0, 'Most of the time' => 0, 'Always' => 0});
        categoryMap.put('Safety__c',new Map<String, Integer>{'Never' => 0, 'Some of the time' => 0, 'Most of the time' => 0, 'Always' => 0});
        categoryMap.put('Operation__c', new Map<String, Integer>{'Never' => 0, 'Some of the time' => 0, 'Most of the time' => 0, 'Always' => 0});
        categoryMap.put('Care_Need__c', new Map<String, Integer>{'Never' => 0, 'Some of the time' => 0, 'Most of the time' => 0, 'Always' => 0});
        categoryMap.put('Competent__c', new Map<String, Integer>{'Never' => 0, 'Some of the time' => 0, 'Most of the time' => 0, 'Always' => 0});
        categoryMap.put('Independent__c', new Map<String, Integer>{'Never' => 0, 'Some of the time' => 0, 'Most of the time' => 0, 'Always' => 0});
        categoryMap.put('Explain__c', new Map<String, Integer>{'Never' => 0, 'Some of the time' => 0, 'Most of the time' => 0, 'Always' => 0});
        categoryMap.put('Respect__c', new Map<String, Integer>{'Never' => 0, 'Some of the time' => 0, 'Most of the time' => 0, 'Always' => 0});
        categoryMap.put('Follow_Up__c', new Map<String, Integer>{'Never' => 0, 'Some of the time' => 0, 'Most of the time' => 0, 'Always' => 0});
        categoryMap.put('Caring__c', new Map<String, Integer>{'Never' => 0, 'Some of the time' => 0, 'Most of the time' => 0, 'Always' => 0});
        categoryMap.put('Voice__c', new Map<String, Integer>{'Never' => 0, 'Some of the time' => 0, 'Most of the time' => 0, 'Always' => 0});
        categoryMap.put('Home__c', new Map<String, Integer>{'Never' => 0, 'Some of the time' => 0, 'Most of the time' => 0, 'Always' => 0});

        return categoryMap;
    }

    public static SRQI_CER__c cerUpdateValues(SRQI_CER__c cerRecord, Map<String, Map<String, Integer>> categoryMap, Decimal ceiCount) {
        // calculates, and prints vales for CER categories
        // Respect
        cerRecord.Respect_Always__c = ((Decimal.valueOf(categoryMap.get('Respect__c').get('Always')) / ceiCount) * 100).setScale(2);
        cerRecord.Respect_Most_of_the_time__c = ((Decimal.valueOf(categoryMap.get('Respect__c').get('Most of the time')) / ceiCount) * 100).setScale(2);
        cerRecord.Respect_Some_of_the_time__c = ((Decimal.valueOf(categoryMap.get('Respect__c').get('Some of the time')) / ceiCount) * 100).setScale(2);
        cerRecord.Respect_Never__c = ((Decimal.valueOf(categoryMap.get('Respect__c').get('Never')) / ceiCount) * 100).setScale(2);
        cerRecord.Respect_Score__c = (((4 * cerRecord.Respect_Always__c) + (3 * cerRecord.Respect_Most_of_the_time__c) + (2 * cerRecord.Respect_Some_of_the_time__c) + (1 * cerRecord.Respect_Never__c)) / 100).setScale(2);
        cerRecord.Respect_Rating_Desc__c = scoreConversion(cerRecord.Respect_Score__c);

        // Food
        cerRecord.Food_Always__c = ((Decimal.valueOf(categoryMap.get('Food__c').get('Always')) / ceiCount) * 100).setScale(2);
        cerRecord.Food_Most_of_the_time__c = ((Decimal.valueOf(categoryMap.get('Food__c').get('Most of the time')) / ceiCount) * 100).setScale(2);
        cerRecord.Food_Some_of_the_time__c = ((Decimal.valueOf(categoryMap.get('Food__c').get('Some of the time')) / ceiCount) * 100).setScale(2);
        cerRecord.Food_Never__c = ((Decimal.valueOf(categoryMap.get('Food__c').get('Never')) / ceiCount) * 100).setScale(2);
        cerRecord.Food_Score__c = (((4 * cerRecord.Food_Always__c) + (3 * cerRecord.Food_Most_of_the_time__c) + (2 * cerRecord.Food_Some_of_the_time__c) + (1 * cerRecord.Food_Never__c)) / 100).setScale(2);
        cerRecord.Food_Rating_Desc__c = scoreConversion(cerRecord.Food_Score__c);
        // Safety
        cerRecord.Safety_Always__c = ((Decimal.valueOf(categoryMap.get('Safety__c').get('Always')) / ceiCount) * 100).setScale(2);
        cerRecord.Safety_Most_of_the_time__c = ((Decimal.valueOf(categoryMap.get('Safety__c').get('Most of the time')) / ceiCount) * 100).setScale(2);
        cerRecord.Safety_Some_of_the_time__c = ((Decimal.valueOf(categoryMap.get('Safety__c').get('Some of the time')) / ceiCount) * 100).setScale(2);
        cerRecord.Safety_Never__c = ((Decimal.valueOf(categoryMap.get('Safety__c').get('Never')) / ceiCount) * 100).setScale(2);
        cerRecord.Safety_Score__c = (((4 * cerRecord.Safety_Always__c) + (3 * cerRecord.Safety_Most_of_the_time__c) + (2 * cerRecord.Safety_Some_of_the_time__c) + (1 * cerRecord.Safety_Never__c)) / 100).setScale(2);
        cerRecord.Safety_Rating_Desc__c = scoreConversion(cerRecord.Safety_Score__c);
        // Operations
        cerRecord.Operation_Always__c = ((Decimal.valueOf(categoryMap.get('Operation__c').get('Always')) / ceiCount) * 100).setScale(2);
        cerRecord.Operation_Most_of_the_time__c = ((Decimal.valueOf(categoryMap.get('Operation__c').get('Most of the time')) / ceiCount) * 100).setScale(2);
        cerRecord.Operation_Some_of_the_time__c = ((Decimal.valueOf(categoryMap.get('Operation__c').get('Some of the time')) / ceiCount) * 100).setScale(2);
        cerRecord.Operation_Never__c = ((Decimal.valueOf(categoryMap.get('Operation__c').get('Never')) / ceiCount) * 100).setScale(2);
        cerRecord.Operation_Score__c = (((4 * cerRecord.Operation_Always__c) + (3 * cerRecord.Operation_Most_of_the_time__c) + (2 * cerRecord.Operation_Some_of_the_time__c) + (1 * cerRecord.Operation_Never__c)) / 100).setScale(2);
        cerRecord.Operation_Rating_Desc__c = scoreConversion(cerRecord.Operation_Score__c);
        // Care Needs
        cerRecord.Care_Need_Always__c = ((Decimal.valueOf(categoryMap.get('Care_Need__c').get('Always')) / ceiCount) * 100).setScale(2);
        cerRecord.Care_Need_Most_of_the_time__c = ((Decimal.valueOf(categoryMap.get('Care_Need__c').get('Most of the time')) / ceiCount) * 100).setScale(2);
        cerRecord.Care_Need_Some_of_the_time__c = ((Decimal.valueOf(categoryMap.get('Care_Need__c').get('Some of the time')) / ceiCount) * 100).setScale(2);
        cerRecord.Care_Need_Never__c = ((Decimal.valueOf(categoryMap.get('Care_Need__c').get('Never')) / ceiCount) * 100).setScale(2);
        cerRecord.Care_Need_Score__c = (((4 * cerRecord.Care_Need_Always__c) + (3 * cerRecord.Care_Need_Most_of_the_time__c) + (2 * cerRecord.Care_Need_Some_of_the_time__c) + (1 * cerRecord.Care_Need_Never__c)) / 100).setScale(2);
        cerRecord.Care_Need_Rating_Desc__c = scoreConversion(cerRecord.Care_Need_Score__c);
        
        // Compedent
        cerRecord.Competent_Always__c = ((Decimal.valueOf(categoryMap.get('Competent__c').get('Always')) / ceiCount) * 100).setScale(2);
        cerRecord.Competent_Most_of_the_time__c = ((Decimal.valueOf(categoryMap.get('Competent__c').get('Most of the time')) / ceiCount) * 100).setScale(2);
        cerRecord.Competent_Some_of_the_time__c = ((Decimal.valueOf(categoryMap.get('Competent__c').get('Some of the time')) / ceiCount) * 100).setScale(2);
        cerRecord.Competent_Never__c = ((Decimal.valueOf(categoryMap.get('Competent__c').get('Never')) / ceiCount) * 100).setScale(2);
        cerRecord.Competent_Score__c = (((4 * cerRecord.Competent_Always__c) + (3 * cerRecord.Competent_Most_of_the_time__c) + (2 * cerRecord.Competent_Some_of_the_time__c) + (1 * cerRecord.Competent_Never__c)) / 100).setScale(2);
        cerRecord.Competent_Rating_Desc__c = scoreConversion(cerRecord.Competent_Score__c);
        
        // Independent
        cerRecord.Independent_Always__c = ((Decimal.valueOf(categoryMap.get('Independent__c').get('Always')) / ceiCount) * 100).setScale(2);
        cerRecord.Independent_Most_of_the_time__c = ((Decimal.valueOf(categoryMap.get('Independent__c').get('Most of the time')) / ceiCount) * 100).setScale(2);
        cerRecord.Independent_Some_of_the_time__c = ((Decimal.valueOf(categoryMap.get('Independent__c').get('Some of the time')) / ceiCount) * 100).setScale(2);
        cerRecord.Independent_Never__c = ((Decimal.valueOf(categoryMap.get('Independent__c').get('Never')) / ceiCount) * 100).setScale(2);
        cerRecord.Independent_Score__c = (((4 * cerRecord.Independent_Always__c) + (3 * cerRecord.Independent_Most_of_the_time__c) + (2 * cerRecord.Independent_Some_of_the_time__c) + (1 * cerRecord.Independent_Never__c)) / 100).setScale(2);
        cerRecord.Independent_Rating_Desc__c = scoreConversion(cerRecord.Independent_Score__c);
        // Explain
        cerRecord.Explain_Always__c = ((Decimal.valueOf(categoryMap.get('Explain__c').get('Always')) / ceiCount) * 100).setScale(2);
        cerRecord.Explain_Most_of_the_time__c = ((Decimal.valueOf(categoryMap.get('Explain__c').get('Most of the time')) / ceiCount) * 100).setScale(2);
        cerRecord.Explain_Some_of_the_time__c = ((Decimal.valueOf(categoryMap.get('Explain__c').get('Some of the time')) / ceiCount) * 100).setScale(2);
        cerRecord.Explain_Never__c = ((Decimal.valueOf(categoryMap.get('Explain__c').get('Never')) / ceiCount) * 100).setScale(2);
        cerRecord.Explain_Score__c = (((4 * cerRecord.Explain_Always__c) + (3 * cerRecord.Explain_Most_of_the_time__c) + (2 * cerRecord.Explain_Some_of_the_time__c) + (1 * cerRecord.Explain_Never__c)) / 100).setScale(2);
        cerRecord.Explain_Rating_Desc__c = scoreConversion(cerRecord.Explain_Score__c);
        // Follow Up
        cerRecord.Follow_Up_Always__c = ((Decimal.valueOf(categoryMap.get('Follow_Up__c').get('Always')) / ceiCount) * 100).setScale(2);
        cerRecord.Follow_Up_Most_of_the_time__c = ((Decimal.valueOf(categoryMap.get('Follow_Up__c').get('Most of the time')) / ceiCount) * 100).setScale(2);
        cerRecord.Follow_Up_Some_of_the_time__c = ((Decimal.valueOf(categoryMap.get('Follow_Up__c').get('Some of the time')) / ceiCount) * 100).setScale(2);
        cerRecord.Follow_Up_Never__c = ((Decimal.valueOf(categoryMap.get('Follow_Up__c').get('Never')) / ceiCount) * 100).setScale(2);
        cerRecord.Follow_Up_Score__c = (((4 * cerRecord.Follow_Up_Always__c) + (3 * cerRecord.Follow_Up_Most_of_the_time__c) + (2 * cerRecord.Follow_Up_Some_of_the_time__c) + (1 * cerRecord.Follow_Up_Never__c)) / 100).setScale(2);
        cerRecord.Follow_Up_Rating_Desc__c = scoreConversion(cerRecord.Follow_Up_Score__c);
        // Caring
        cerRecord.Caring_Always__c = ((Decimal.valueOf(categoryMap.get('Caring__c').get('Always')) / ceiCount) * 100).setScale(2);
        cerRecord.Caring_Most_of_the_time__c = ((Decimal.valueOf(categoryMap.get('Caring__c').get('Most of the time')) / ceiCount) * 100).setScale(2);
        cerRecord.Caring_Some_of_the_time__c = ((Decimal.valueOf(categoryMap.get('Caring__c').get('Some of the time')) / ceiCount) * 100).setScale(2);
        cerRecord.Caring_Never__c = ((Decimal.valueOf(categoryMap.get('Caring__c').get('Never')) / ceiCount) * 100).setScale(2);
        cerRecord.Caring_Score__c = (((4 * cerRecord.Caring_Always__c) + (3 * cerRecord.Caring_Most_of_the_time__c) + (2 * cerRecord.Caring_Some_of_the_time__c) + (1 * cerRecord.Caring_Never__c)) / 100).setScale(2);
        cerRecord.Caring_Rating_Desc__c = scoreConversion(cerRecord.Caring_Score__c);
        // Voice
        cerRecord.Voice_Always__c = ((Decimal.valueOf(categoryMap.get('Voice__c').get('Always')) / ceiCount) * 100).setScale(2);
        cerRecord.Voice_Most_of_the_time__c = ((Decimal.valueOf(categoryMap.get('Voice__c').get('Most of the time')) / ceiCount) * 100).setScale(2);
        cerRecord.Voice_Some_of_the_time__c = ((Decimal.valueOf(categoryMap.get('Voice__c').get('Some of the time')) / ceiCount) * 100).setScale(2);
        cerRecord.Voice_Never__c = ((Decimal.valueOf(categoryMap.get('Voice__c').get('Never')) / ceiCount) * 100).setScale(2);
        cerRecord.Voice_Score__c = (((4 * cerRecord.Voice_Always__c) + (3 * cerRecord.Voice_Most_of_the_time__c) + (2 * cerRecord.Voice_Some_of_the_time__c) + (1 * cerRecord.Voice_Never__c)) / 100).setScale(2);
        cerRecord.Voice_Rating_Desc__c = scoreConversion(cerRecord.Voice_Score__c);
        // Home
        cerRecord.Home_Always__c = ((Decimal.valueOf(categoryMap.get('Home__c').get('Always')) / ceiCount) * 100).setScale(2);
        cerRecord.Home_Most_of_the_time__c = ((Decimal.valueOf(categoryMap.get('Home__c').get('Most of the time')) / ceiCount) * 100).setScale(2);
        cerRecord.Home_Some_of_the_time__c = ((Decimal.valueOf(categoryMap.get('Home__c').get('Some of the time')) / ceiCount) * 100).setScale(2);        
        cerRecord.Home_Never__c = ((Decimal.valueOf(categoryMap.get('Home__c').get('Never')) / ceiCount) * 100).setScale(2);
        cerRecord.Home_Score__c = (((4 * cerRecord.Home_Always__c) + (3 * cerRecord.Home_Most_of_the_time__c) + (2 * cerRecord.Home_Some_of_the_time__c) + (1 * cerRecord.Home_Never__c)) / 100).setScale(2);
        cerRecord.Home_Rating_Desc__c = scoreConversion(cerRecord.Home_Score__c);
        // Print count of CEI record used in calc
        cerRecord.Consumers_Surveyed__c = Integer.valueOf(ceiCount);

        return cerRecord;
    }

    public static Map<Id, List<SRQI_CEI__c>> getCEIRecords(Set<Id> cerIds)
    {
        // initialise map to be returned
        Map<Id, List<SRQI_CEI__c>> ceiMap = new Map<Id, List<SRQI_CEI__c>>();
        // get CEI Records related to cerIds
        List<SRQI_CEI__c> ceiList = [SELECT Id, Consumer_Experience_Report__c, Food__c, Safety__c, Operation__c, Care_Need__c, Competent__c, Independent__c, Explain__c, Respect__c, Follow_Up__c, Caring__c, Voice__c, Home__c FROM SRQI_CEI__c WHERE Consumer_Experience_Report__c IN :cerIds AND Consent_Status__c = 'Yes'];
        // turn into map, collecting a list against cerId key
        for (SRQI_CEI__c cei : ceiList) {
            Id cerId = cei.Consumer_Experience_Report__c;
            if(ceiMap.containsKey(cerId)) {
                List<SRQI_CEI__c> ceiRecords = ceiMap.get(cerId);
                ceiRecords.add(cei);
                ceiMap.put(cerId, ceiRecords);
            } else {
                ceiMap.put(cerId, new List<SRQI_CEI__c> {cei});
            }
        }
        return ceiMap;
    }

    public static Integer scoreConversion(Decimal score) {
        Integer rating;
        List<Decimal> cerNumbers = new List<Decimal>();
        List<CER_Formula__mdt> cerValues = CER_Formula__mdt.getAll().values();
        for(CER_Formula__mdt cerValue : cerValues) {
            if(cerValue.Domain_Star_Range__c != null && cerValue.Domain_Star_Range__c != 1.00) {
                cerNumbers.add(cerValue.Domain_Star_Range__c);
            }
        }
        cerNumbers.sort();
        for(Integer i = 0; i < cerNumbers.size(); i++) {
            if(score < cerNumbers[i]) {
                rating = i + 1;
                break;
            }
            else {
                rating = 5;
            }
        }
        return rating;
    }

    public static void calcCEI(List<SRQI_CER__c> scope)
    {
        // Key is CER Id, will a list of all associated CEI records
        Map<Id, SRQI_CER__c> cerMap = new Map<Id, SRQI_CER__c>();
        // Store updated CER records
        List<SRQI_CER__c> cerUpdateList = new List<SRQI_CER__c>();
        
        
        for (SRQI_CER__c cer : scope) {
            cerMap.put(cer.Id, cer);
        }
        Map<Id, List<SRQI_CEI__c>> ceiMap = new Map<Id, List<SRQI_CEI__c>>(CEIAlgorithmHelper.getCEIRecords(cerMap.keySet()));
        
        for(Id cerId : ceiMap.keySet()){
            SRQI_CER__c cerUpdate = CEIAlgorithmHelper.calculateCategories(cerMap.get(cerId), ceiMap.get(cerId));
            cerUpdateList.add(cerUpdate);
        }
        
        update cerUpdateList;
    }

    /** 
     * Description: Converts field Total_CER_Score__c into star rating
    */
	public static Double convertTotalCERScoreIntoStarRating(SRQI_CER__c cerRecord) {
        Double finalResult = 0;
		Http http = new Http();
		HttpRequest request = new HttpRequest();
		request.setEndpoint(
			Url.getOrgDomainUrl().toExternalForm() +
			'/services/data/v55.0/connect/business-rules/expressionSet/New_EX_CERTot'
		);
		request.setMethod('POST');
		request.setHeader('Content-Type', 'application/json;charset=UTF-8');
		request.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
		// Set the body as a JSON object
        String payload = JSON.serialize(
            new Map<String, Object>{
                'inputs' => new List<Object>{ new Map<String, Object>{ 'Id' => cerRecord.Id, 'Score' => cerRecord.Total_CER_Score__c } },
                'options' => new Map<String, Object>{
                    'actionContextCode' => cerRecord.Id,
                    'explainabilitySpecName' => 'CERAction'
                }
            }
        );
		request.setBody(payload);
		HttpResponse response = http.send(request);
		// Parse the JSON response
		if (response.getStatusCode() != 201) {
            dohagedcare.Logger.warn('CEIAlgorithmHelper method convertTotalCERScoreIntoStarRating. ' + response.getStatusCode() + ' ' + response.getStatus()).Log();
		} else {
			Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
			List<Object> outputs= (List<Object>) result.get('outputs');
			Map<String, Object> output = (Map<String, Object>) outputs[0];
			Map<String, Object> results = (Map<String, Object>) output .get('results');
            finalResult = (Double)results.get('CER_Total_Stars_II__Rating');
		}

        return finalResult;
	}

    /**
     * Description: method used by IP RecalcTriggeredFromFlow. It calculates the domains for a specific CER
     * and the CER rating
    */
    public static void recalculateCER(Set<Id> cerId) {
        // Step 1 - get CER record
        String idFilter = ' WHERE Id IN :cerId';
        String query = CEIAlgorithmBatch.getQuery().split('WHERE').get(0) + idFilter;
        List<SRQI_CER__c> cerRecords = Database.query(query);

        if(!cerRecords.isEmpty()){
            // Step 2 - calculate CEI
            calcCEI(cerRecords);

            // Step 3 - get services' ids
            Set<Id> servicesId = new Set<Id>();
            for(SRQI_CER__c rec : cerRecords){
                servicesId.add(rec.Service__c);
            }

            // Step 4 - calculate cer rating
            Database.executeBatch(new CerHybridBatch(cerId, servicesId), 90);
        }    
    }
}