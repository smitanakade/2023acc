/**
* author: Sharevreet Singh
* date: 14/10/2022
* @description Class is to take a QI map and set the quintile scores on the respective records.
**/ 
public with sharing class QuintileScoreCalculator implements Queueable {
    National_Statistic__c natStatRecord;
    Reporting_Period__c reportPeriod;
    Boolean lateUpdate;
    Set<Id> qiIdsSet = new Set<Id>();
    Map<Id, Quality_Indicator_Summary__c> qisMap = new Map<Id, Quality_Indicator_Summary__c>();
    Map<Decimal, Set<Id>> antipsychoticMap = new Map<Decimal, Set<Id>>();
    Map<Decimal, Set<Id>> dtpiMap = new Map<Decimal, Set<Id>>();
    Map<Decimal, Set<Id>> phyRestraintMap = new Map<Decimal, Set<Id>>();
    Map<Decimal, Set<Id>> polypharmacyMap = new Map<Decimal, Set<Id>>();
    Map<Decimal, Set<Id>> unstgPiMap = new Map<Decimal, Set<Id>>();
    
    Map<Decimal, Set<Id>> stg2PiMap = new Map<Decimal, Set<Id>>();
    Map<Decimal, Set<Id>> stg3PiMap = new Map<Decimal, Set<Id>>();
    Map<Decimal, Set<Id>> stg4PiMap = new Map<Decimal, Set<Id>>();
    Map<Decimal, Set<Id>> sigWeightLossMap = new Map<Decimal, Set<Id>>();
    Map<Decimal, Set<Id>> fallMap = new Map<Decimal, Set<Id>>();
    Map<Decimal, Set<Id>> fmiMap = new Map<Decimal, Set<Id>>();

    /**
     * @description class constructor - initializing maps of field values (based on which Quintile score is generated) by QIS Id 
     * Later on the Ids will be matched with Ids from qisMap to fill values for Quintile score fields
     */
    public QuintileScoreCalculator(Set<Id> qiIdsSet, National_Statistic__c natStatRecord, Reporting_Period__c reportPeriod, Boolean lateUpdate) {
        this.natStatRecord = natStatRecord;
        this.reportPeriod = reportPeriod;
        this.qiIdsSet = qiIdsSet;
        this.lateUpdate = lateUpdate;
    }
    public void setMapData(){

        List< Quality_Indicator_Summary__c> qiList  = [SELECT Id, QI_Observed_PI_SDT__c, QI_Observed_PI_unstageable__c, Reporting_Period__c,
                                                        QI_Observed_Polypharmacy__c, QI_Observed_APSY__c, QI_Observed_Physical_Restraint__c,
                                                        Risk_Adjusted_PI_Level2__c,Risk_Adjusted_PI_Level3__c, Risk_Adjusted_PI_Level4__c,
                                                        Risk_Adjusted_SUWL__c, Risk_Adjusted_Falls_with_injury__c, Risk_Adjusted_Falls_with_Major_injury__c
                                                        FROM Quality_Indicator_Summary__c 
                                                        WHERE Id IN : qiIdsSet];

        qisMap = new Map<Id, Quality_Indicator_Summary__c>(qiList);

        for(Quality_Indicator_Summary__c qi : qiList) {
            if(antipsychoticMap.get(qi.QI_Observed_APSY__c) != null) {
                antipsychoticMap.get(qi.QI_Observed_APSY__c).add(qi.Id);
            } else {
                antipsychoticMap.put(qi.QI_Observed_APSY__c, new Set<Id> {qi.Id});
            }
            
            if(dtpiMap.get(qi.QI_Observed_PI_SDT__c) != null) {
                dtpiMap.get(qi.QI_Observed_PI_SDT__c).add(qi.Id);
            } else {
                dtpiMap.put(qi.QI_Observed_PI_SDT__c, new Set<Id> {qi.Id});
            }
            
            if(phyRestraintMap.get(qi.QI_Observed_Physical_Restraint__c) != null) {
                phyRestraintMap.get(qi.QI_Observed_Physical_Restraint__c).add(qi.Id);
            } else {
                phyRestraintMap.put(qi.QI_Observed_Physical_Restraint__c, new Set<Id> {qi.Id});
            }
            
            if(polypharmacyMap.get(qi.QI_Observed_Polypharmacy__c) != null) {
                polypharmacyMap.get(qi.QI_Observed_Polypharmacy__c).add(qi.Id);
            } else {
                polypharmacyMap.put(qi.QI_Observed_Polypharmacy__c, new Set<Id> {qi.Id});
            }
            
            if(unstgPiMap.get(qi.QI_Observed_PI_unstageable__c) != null) {
                unstgPiMap.get(qi.QI_Observed_PI_unstageable__c).add(qi.Id);
            } else {
                unstgPiMap.put(qi.QI_Observed_PI_unstageable__c, new Set<Id> {qi.Id});
            }
            
            if(stg2PiMap.get(qi.Risk_Adjusted_PI_Level2__c) != null) {
                stg2PiMap.get(qi.Risk_Adjusted_PI_Level2__c).add(qi.Id);
            } else {
                stg2PiMap.put(qi.Risk_Adjusted_PI_Level2__c, new Set<Id> {qi.Id});
            }
            
            if(stg3PiMap.get(qi.Risk_Adjusted_PI_Level3__c) != null) {
                stg3PiMap.get(qi.Risk_Adjusted_PI_Level3__c).add(qi.Id);
            } else {
                stg3PiMap.put(qi.Risk_Adjusted_PI_Level3__c, new Set<Id> {qi.Id});
            }
            
            if(stg4PiMap.get(qi.Risk_Adjusted_PI_Level4__c) != null) {
                stg4PiMap.get(qi.Risk_Adjusted_PI_Level4__c).add(qi.Id);
            } else {
                stg4PiMap.put(qi.Risk_Adjusted_PI_Level4__c, new Set<Id> {qi.Id});
            }
            
            if(sigWeightLossMap.get(qi.Risk_Adjusted_SUWL__c) != null) {
                sigWeightLossMap.get(qi.Risk_Adjusted_SUWL__c).add(qi.Id);
            } else {
                sigWeightLossMap.put(qi.Risk_Adjusted_SUWL__c, new Set<Id> {qi.Id});
            }
            
            if(fallMap.get(qi.Risk_Adjusted_Falls_with_injury__c) != null) {
                fallMap.get(qi.Risk_Adjusted_Falls_with_injury__c).add(qi.Id);
            } else {
                fallMap.put(qi.Risk_Adjusted_Falls_with_injury__c, new Set<Id> {qi.Id});
            }
            
            if(fmiMap.get(qi.Risk_Adjusted_Falls_with_Major_injury__c) != null) {
                fmiMap.get(qi.Risk_Adjusted_Falls_with_Major_injury__c).add(qi.Id);
            } else {
                fmiMap.put(qi.Risk_Adjusted_Falls_with_Major_injury__c, new Set<Id> {qi.Id});
            }
        }
    }

    /**
     * @description acutal method to calculate Quintile Score for all the Quintile fields in passed on QIS map
     */
    public void execute(QueueableContext context) {
        try {
            calculate();
        } catch(Exception ex) {
            dohagedcare.Logger.error(ex.getMessage(), ex, 'QuintileScoreCalculator.cls').log();
        }
    }
    
    public void calculate(){

        setMapData();

        List<Quality_Indicator_Summary__c> qisList = new List<Quality_Indicator_Summary__c>();

        Map<Id, Integer> antiPsyQuintileMap = getQuintileMap(antipsychoticMap, 'APSY');
        Map<Id, Integer> dtpiQuintileMap = getQuintileMap(dtpiMap, 'DTPI');
        Map<Id, Integer> phyRestraintQuintileMap = getQuintileMap(phyRestraintMap, 'PhyRes');
        Map<Id, Integer> polypharmacyQuintileMap = getQuintileMap(polypharmacyMap, 'PolyPharm');
        Map<Id, Integer> unstgPiQuintileMap = getQuintileMap(unstgPiMap, 'UnstgPI');
        Map<Id, Integer> stg2PiQuintileMap = getQuintileMap(stg2PiMap, 'Stg2PI');
        Map<Id, Integer> stg3PiQuintileMap = getQuintileMap(stg3PiMap, 'Stg3PI');
        Map<Id, Integer> stg4PiQuintileMap = getQuintileMap(stg4PiMap, 'Stg4PI');
        Map<Id, Integer> sigWeightLossQuintileMap = getQuintileMap(sigWeightLossMap, 'SigWL');
        Map<Id, Integer> fallQuintileMap = getQuintileMap(fallMap, 'Falls');
        Map<Id, Integer> fmiQuintileMap = getQuintileMap(fmiMap, 'FallsMI');

        update natStatRecord;
        reportPeriod.QuintileRangesCalculated__c = true;
        update reportPeriod;

        for(Id quintileId : qisMap.keySet()) {
            qisList.add(new Quality_Indicator_Summary__c(Id = quintileId, 
                                                        Antipsychotic_Quintile__c = antiPsyQuintileMap.get(quintileId),
                                                        Deep_Tissue_Pressure_Injury_Quintile__c = dtpiQuintileMap.get(quintileId),
                                                        Physical_Restraint_Quintile__c = phyRestraintQuintileMap.get(quintileId),
                                                        Polypharmacy_Quintile__c = polypharmacyQuintileMap.get(quintileId),
                                                        Unstageable_Pressure_Injury_Quintile__c = unstgPiQuintileMap.get(quintileId),
                                                        Stage_2_Pressure_Injury_Quintile__c = stg2PiQuintileMap.get(quintileId),
                                                        Stage_3_Pressure_Injury_Quintile__c = stg3PiQuintileMap.get(quintileId),
                                                        Stage_4_Pressure_Injury_Quintile__c = stg4PiQuintileMap.get(quintileId),
                                                        Significant_Weight_Loss_Quintile__c = sigWeightLossQuintileMap.get(quintileId),
                                                        Falls_Quintile__c = fallQuintileMap.get(quintileId),
                                                        Falls_Major_Injury_Quintile__c = fmiQuintileMap.get(quintileId)));
        }

        if(qisList.size() > 0) {
            try {
                Database.update(qisList, false);
                Map<String, Object> ipInput = new Map<String, Object>();
                if (lateUpdate) {
                    ipInput.put('lateUpdate', lateUpdate);
                }
                else {
                    ipInput.put('runAll', 'true');
                }
                IntegrationProcedureHandler ipHandler = new IntegrationProcedureHandler(IntegrationProcedureHandler.RUNQI, ipInput);
                ipHandler.executeIp();
            }
            catch(Exception ex) {
                dohagedcare.Logger.error(ex.getMessage(), ex, 'QuintileScoreCalculator.cls').log();
            }
        }
    }

    /**
     * @description used to divide a given List to 5 approx equal parts
     */
    private void quintileCuts(List<Decimal> decimalList, String forList) {
        Integer per20 = decimalList.size() > 1 ? (Integer) (Math.floor(decimalList.size()*.2) - 1) : 0;
        Integer per40 = decimalList.size() > 1 ? (Integer) (Math.floor(decimalList.size()*.4) - 1) : 0;
        Integer per60 = decimalList.size() > 1 ? (Integer) (Math.floor(decimalList.size()*.6) - 1) : 0;
        Integer per80 = decimalList.size() > 1 ? (Integer) (Math.floor(decimalList.size()*.8) - 1) : 0;
        Integer per100 = decimalList.size() > 1 ? (Integer) (decimalList.size() - 1) : 0;

        switch on forList {
            when 'APSY' {
                natStatRecord.APSY_First_Quintile__c = decimalList[per20];
                natStatRecord.APSY_Second_Quintile__c = decimalList[per40];
                natStatRecord.APSY_Third_Quintile__c = decimalList[per60];
                natStatRecord.APSY_Fourth_Quintile__c = decimalList[per80];
                natStatRecord.APSY_Fifth_Quintile__c = decimalList[per100];
            }
            when 'DTPI' {
                natStatRecord.DTPI_First_Quintile__c = decimalList[per20];
                natStatRecord.DTPI_Second_Quintile__c = decimalList[per40];
                natStatRecord.DTPI_Third_Quintile__c = decimalList[per60];
                natStatRecord.DTPI_Fourth_Quintile__c = decimalList[per80];
                natStatRecord.DTPI_Fifth_Quintile__c = decimalList[per100];
            }
            when 'Falls' {
                natStatRecord.Falls_First_Quintile__c = decimalList[per20];
                natStatRecord.Falls_Second_Quintile__c = decimalList[per40];
                natStatRecord.Falls_Third_Quintile__c = decimalList[per60];
                natStatRecord.Falls_Fourth_Quintile__c = decimalList[per80];
                natStatRecord.Falls_Fifth_Quintile__c = decimalList[per100];
            }
            when 'FallsMI' {
                natStatRecord.FallsMI_First_Quintile__c = decimalList[per20];
                natStatRecord.FallsMI_Second_Quintile__c = decimalList[per40];
                natStatRecord.FallsMI_Third_Quintile__c = decimalList[per60];
                natStatRecord.FallsMI_Fourth_Quintile__c = decimalList[per80];
                natStatRecord.FallsMI_Fifth_Quintile__c = decimalList[per100];
            }
            when 'PhyRes' {
                natStatRecord.PhyRes_First_Quintile__c = decimalList[per20];
                natStatRecord.PhyRes_Second_Quintile__c = decimalList[per40];
                natStatRecord.PhyRes_Third_Quintile__c = decimalList[per60];
                natStatRecord.PhyRes_Fourth_Quintile__c = decimalList[per80];
                natStatRecord.PhyRes_Fifth_Quintile__c = decimalList[per100];
            }
            when 'PolyPharm' {
                natStatRecord.PolyPharm_First_Quintile__c = decimalList[per20];
                natStatRecord.PolyPharm_Second_Quintile__c = decimalList[per40];
                natStatRecord.PolyPharm_Third_Quintile__c = decimalList[per60];
                natStatRecord.PolyPharm_Fourth_Quintile__c = decimalList[per80];
                natStatRecord.PolyPharm_Fifth_Quintile__c = decimalList[per100];
            }
            when 'SigWL' {
                natStatRecord.SigWL_First_Quintile__c = decimalList[per20];
                natStatRecord.SigWL_Second_Quintile__c = decimalList[per40];
                natStatRecord.SigWL_Third_Quintile__c = decimalList[per60];
                natStatRecord.SigWL_Fourth_Quintile__c = decimalList[per80];
                natStatRecord.SigWL_Fifth_Quintile__c = decimalList[per100];
            }
            when 'Stg2PI' {
                natStatRecord.Stg2PI_First_Quintile__c = decimalList[per20];
                natStatRecord.Stg2PI_Second_Quintile__c = decimalList[per40];
                natStatRecord.Stg2PI_Third_Quintile__c = decimalList[per60];
                natStatRecord.Stg2PI_Fourth_Quintile__c = decimalList[per80];
                natStatRecord.Stg2PI_Fifth_Quintile__c = decimalList[per100];
            }
            when 'Stg3PI' {
                natStatRecord.Stg3PI_First_Quintile__c = decimalList[per20];
                natStatRecord.Stg3PI_Second_Quintile__c = decimalList[per40];
                natStatRecord.Stg3PI_Third_Quintile__c = decimalList[per60];
                natStatRecord.Stg3PI_Fourth_Quintile__c = decimalList[per80];
                natStatRecord.Stg3PI_Fifth_Quintile__c = decimalList[per100];
            }
            when 'Stg4PI' {
                natStatRecord.Stg4PI_First_Quintile__c = decimalList[per20];
                natStatRecord.Stg4PI_Second_Quintile__c = decimalList[per40];
                natStatRecord.Stg4PI_Third_Quintile__c = decimalList[per60];
                natStatRecord.Stg4PI_Fourth_Quintile__c = decimalList[per80];
                natStatRecord.Stg4PI_Fifth_Quintile__c = decimalList[per100];
            }
            when 'UnstgPI' {
                natStatRecord.UnstgPI_First_Quintile__c = decimalList[per20];
                natStatRecord.UnstgPI_Second_Quintile__c = decimalList[per40];
                natStatRecord.UnstgPI_Third_Quintile__c = decimalList[per60];
                natStatRecord.UnstgPI_Fourth_Quintile__c = decimalList[per80];
                natStatRecord.UnstgPI_Fifth_Quintile__c = decimalList[per100];
            }
        }
    }

    /**
     * @description perform quintile calculation on given Map<Id, Decimal> 
     * @return a Map<Id, Integer> 
     * where Id => id from parameter, Integer => quintile value
     */
    private Map<Id, Integer> getQuintileMap(Map<Decimal, Set<Id>> fieldValueByObjId, String forList) {
        Map<Id, Integer> quintileMap = new Map<Id, Integer>();
        Integer listSize = fieldValueByObjId.keySet().size();
        // sort values in a list
        List<Decimal> sortList = new List<Decimal>(fieldValueByObjId.keySet());
        sortList.sort();
        if(!reportPeriod.QuintileRangesCalculated__c) {
            quintileCuts(sortList, forList);
        }
        
        Decimal firstQuintile;
        Decimal secondQuintile;
        Decimal thirdQuintile;
        Decimal fourthQuintile;

        switch on forList {
            when 'APSY' {
                firstQuintile = natStatRecord.APSY_First_Quintile__c;
                fourthQuintile = natStatRecord.APSY_Fourth_Quintile__c;
                secondQuintile = natStatRecord.APSY_Second_Quintile__c;
                thirdQuintile = natStatRecord.APSY_Third_Quintile__c;
            }
            when 'DTPI' {
                firstQuintile = natStatRecord.DTPI_First_Quintile__c;
                fourthQuintile = natStatRecord.DTPI_Fourth_Quintile__c;
                secondQuintile = natStatRecord.DTPI_Second_Quintile__c;
                thirdQuintile = natStatRecord.DTPI_Third_Quintile__c;
            }
            when 'Falls' {
                firstQuintile = natStatRecord.Falls_First_Quintile__c;
                fourthQuintile = natStatRecord.Falls_Fourth_Quintile__c;
                secondQuintile = natStatRecord.Falls_Second_Quintile__c;
                thirdQuintile = natStatRecord.Falls_Third_Quintile__c;
            }
            when 'FallsMI' {
                firstQuintile = natStatRecord.FallsMI_First_Quintile__c;
                fourthQuintile = natStatRecord.FallsMI_Fourth_Quintile__c;
                secondQuintile = natStatRecord.FallsMI_Second_Quintile__c;
                thirdQuintile = natStatRecord.FallsMI_Third_Quintile__c;
            }
            when 'PhyRes' {
                firstQuintile = natStatRecord.PhyRes_First_Quintile__c;
                fourthQuintile = natStatRecord.PhyRes_Fourth_Quintile__c;
                secondQuintile = natStatRecord.PhyRes_Second_Quintile__c;
                thirdQuintile = natStatRecord.PhyRes_Third_Quintile__c;
            }
            when 'PolyPharm' {
                firstQuintile = natStatRecord.PolyPharm_First_Quintile__c;
                fourthQuintile = natStatRecord.PolyPharm_Fourth_Quintile__c;
                secondQuintile = natStatRecord.PolyPharm_Second_Quintile__c;
                thirdQuintile = natStatRecord.PolyPharm_Third_Quintile__c;
            }
            when 'SigWL' {
                firstQuintile = natStatRecord.SigWL_First_Quintile__c;
                fourthQuintile = natStatRecord.SigWL_Fourth_Quintile__c;
                secondQuintile = natStatRecord.SigWL_Second_Quintile__c;
                thirdQuintile = natStatRecord.SigWL_Third_Quintile__c;
            }
            when 'Stg2PI' {
                firstQuintile = natStatRecord.Stg2PI_First_Quintile__c;
                fourthQuintile = natStatRecord.Stg2PI_Fourth_Quintile__c;
                secondQuintile = natStatRecord.Stg2PI_Second_Quintile__c;
                thirdQuintile = natStatRecord.Stg2PI_Third_Quintile__c;
            }
            when 'Stg3PI' {
                firstQuintile = natStatRecord.Stg3PI_First_Quintile__c;
                fourthQuintile = natStatRecord.Stg3PI_Fourth_Quintile__c;
                secondQuintile = natStatRecord.Stg3PI_Second_Quintile__c;
                thirdQuintile = natStatRecord.Stg3PI_Third_Quintile__c;
            }
            when 'Stg4PI' {
                firstQuintile = natStatRecord.Stg4PI_First_Quintile__c;
                fourthQuintile = natStatRecord.Stg4PI_Fourth_Quintile__c;
                secondQuintile = natStatRecord.Stg4PI_Second_Quintile__c;
                thirdQuintile = natStatRecord.Stg4PI_Third_Quintile__c;
            }
            when 'UnstgPI' {
                firstQuintile = natStatRecord.UnstgPI_First_Quintile__c;
                fourthQuintile = natStatRecord.UnstgPI_Fourth_Quintile__c;
                secondQuintile = natStatRecord.UnstgPI_Second_Quintile__c;
                thirdQuintile = natStatRecord.UnstgPI_Third_Quintile__c;
            }
        }

        for(Decimal qisVal : fieldValueByObjId.keySet()) {
            Integer quintileVal = null;
            if(qisVal <= firstQuintile) {
                quintileVal = 1;
            }
            else if(qisVal <= secondQuintile) {
                quintileVal = 2;
            }
            else if(qisVal <= thirdQuintile) {
                quintileVal = 3;
            }
            else if(qisVal <= fourthQuintile) {
                quintileVal = 4;
            }
            else if(qisVal > fourthQuintile){
                quintileVal = 5;
            }
            for(Id recordId : fieldValueByObjId.get(qisVal)) {
                quintileMap.put(recordId, quintileVal);
            }
        }

        return quintileMap;
    }
}