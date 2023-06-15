/**
* author: Sharevreet Singh
* date: 14/10/2022
* description: Class is to take a single QI record and National_Statistic__c record and set the risk adjusted scores on the respective record.
**/ 
public with sharing class RiskAdjustedCalculator {
    private final String REPORTING_PERIOD_TYPE = 'Quarter';
    private National_Statistic__c natStatRecord;
    private Quality_Indicator_Summary__c qiRecord;

    /**
     * @description: constructor used to initialize values
     */
    public RiskAdjustedCalculator(Quality_Indicator_Summary__c qiRecord, National_Statistic__c natStatRecord) {
        this.qiRecord = qiRecord;
        this.natStatRecord = natStatRecord;
    }

    /**
     * @description calculate and update QI risk adjusted for given qiRecord
     */
    public Quality_Indicator_Summary__c calculateRiskAdjusted() {
        if(qiRecord != null && natStatRecord != null) {
            qiRecord.Risk_Adjusted_PI_Level2__c = calRiskAdjustedFrm(qiRecord.QI_Observed_PI_S2__c, qiRecord.QI_Predicted_PI_S2__c, natStatRecord.National_percentage_PI_Stage2__c);
            qiRecord.Risk_Adjusted_PI_Level3__c = calRiskAdjustedFrm(qiRecord.QI_Observed_PI_S3__c, qiRecord.QI_Predicted_PI_S3__c,	natStatRecord.National_percentage_PI_Stage3__c);
            qiRecord.Risk_Adjusted_PI_Level4__c = calRiskAdjustedFrm(qiRecord.QI_Observed_PI_S4__c, qiRecord.QI_Predicted_PI_S4__c, natStatRecord.National_percentage_PI_Stage4__c);
            qiRecord.Risk_Adjusted_Unstageable_PI__c = calRiskAdjustedFrm(qiRecord.QI_Observed_PI_unstageable__c, qiRecord.QI_Predicted_PI_S4__c, natStatRecord.National_percentage_PI_Unstageable__c);
            qiRecord.Risk_Adjusted_DT_PI__c = calRiskAdjustedFrm(qiRecord.QI_Observed_PI_SDT__c, qiRecord.QI_Predicted_PI_S4__c, natStatRecord.National_percentage_PI_Deep_Tissue__c);
            qiRecord.Risk_Adjusted_SUWL__c = calRiskAdjustedFrm(qiRecord.QI_Observed_WL_SIG__c, qiRecord.QI_Predicted_WL_SIG__c, natStatRecord.National_percentage_significant_UWL__c);
            qiRecord.Risk_Adjusted_Falls_with_injury__c = calRiskAdjustedFrm(qiRecord.QI_Observed_FALLS__c, qiRecord.QI_Predicted_FALLS__c, natStatRecord.National_percentage_falls__c);
            qiRecord.Risk_Adjusted_Falls_with_Major_injury__c = calRiskAdjustedFrm(qiRecord.QI_Observed_Falls_MI__c, qiRecord.QI_Predicted_FALLS_MI__c, natStatRecord.National_Percentage_falls_Major_Injury__c);
        }
        return qiRecord;
    }

    /**
     * @description: formula for calculating risk adjusted for given values
     */
    private Decimal calRiskAdjustedFrm(Decimal qiObserved, Decimal qiPerdicted, Decimal qiSecAvg) {
        Decimal qiRiskAdjusted = null;
        if(qiObserved != null && qiPerdicted != null && qiSecAvg != null) {
            qiRiskAdjusted = qiPerdicted == 0 ? 0 : ((qiObserved / qiPerdicted) * qiSecAvg);
        }
        return qiRiskAdjusted;
    }
}