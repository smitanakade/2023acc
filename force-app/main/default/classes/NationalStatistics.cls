/**
 * author: Daniel Clift
 * date: 02/10/2022
 * description: Create and calculate National_Statistic__c (National Average based on QI Summary data calculated)
 **/
public with sharing class NationalStatistics {
	// create national static record & list for access to methods
	public static National_Statistic__c ns = new National_Statistic__c();
	public static List<Quality_Indicator_Summary__c> qiSummaryList = new List<Quality_Indicator_Summary__c>();

	public static National_Statistic__c calcNationalAverage(List<Quality_Indicator_Summary__c> qiRecords) {
		// set to global variable
		qiSummaryList = qiRecords;
		// run respective national averages, has access to public variables

		// Added by Gab - 25/11/2022
		processAllData();

		initializeQuintiles();
		// insert created national statistics record
		ns.Reporting_Period__c = qiSummaryList[0].Reporting_Period__c;
		try {
			insert ns;
		} catch (Exception ex) {
            dohagedcare.Logger.error(ex.getMessage(), ex, 'National Statistics').log();
        }
		return ns;
	}

	/**
	 * @description these fields are used in QuintileScoreCalculator; initialzing to avoid a query
	 */
	public static void initializeQuintiles() {
		ns.APSY_First_Quintile__c = 0;
		ns.APSY_Fourth_Quintile__c = 0;
		ns.APSY_Second_Quintile__c = 0;
		ns.APSY_Third_Quintile__c = 0;

		ns.DTPI_First_Quintile__c = 0;
		ns.DTPI_Fourth_Quintile__c = 0;
		ns.DTPI_Second_Quintile__c = 0;
		ns.DTPI_Third_Quintile__c = 0;

		ns.Falls_First_Quintile__c = 0;
		ns.Falls_Fourth_Quintile__c = 0;
		ns.Falls_Second_Quintile__c = 0;
		ns.Falls_Third_Quintile__c = 0;

		ns.FallsMI_First_Quintile__c = 0;
		ns.FallsMI_Fourth_Quintile__c = 0;
		ns.FallsMI_Second_Quintile__c = 0;
		ns.FallsMI_Third_Quintile__c = 0;

		ns.PhyRes_First_Quintile__c = 0;
		ns.PhyRes_Fourth_Quintile__c = 0;
		ns.PhyRes_Second_Quintile__c = 0;
		ns.PhyRes_Third_Quintile__c = 0;

		ns.PolyPharm_First_Quintile__c = 0;
		ns.PolyPharm_Fourth_Quintile__c = 0;
		ns.PolyPharm_Second_Quintile__c = 0;
		ns.PolyPharm_Third_Quintile__c = 0;

		ns.SigWL_First_Quintile__c = 0;
		ns.SigWL_Fourth_Quintile__c = 0;
		ns.SigWL_Second_Quintile__c = 0;
		ns.SigWL_Third_Quintile__c = 0;

		ns.Stg2PI_First_Quintile__c = 0;
		ns.Stg2PI_Fourth_Quintile__c = 0;
		ns.Stg2PI_Second_Quintile__c = 0;
		ns.Stg2PI_Third_Quintile__c = 0;

		ns.Stg3PI_First_Quintile__c = 0;
		ns.Stg3PI_Fourth_Quintile__c = 0;
		ns.Stg3PI_Second_Quintile__c = 0;
		ns.Stg3PI_Third_Quintile__c = 0;

		ns.Stg4PI_First_Quintile__c = 0;
		ns.Stg4PI_Fourth_Quintile__c = 0;
		ns.Stg4PI_Second_Quintile__c = 0;
		ns.Stg4PI_Third_Quintile__c = 0;

		ns.UnstgPI_First_Quintile__c = 0;
		ns.UnstgPI_Fourth_Quintile__c = 0;
		ns.UnstgPI_Second_Quintile__c = 0;
		ns.UnstgPI_Third_Quintile__c = 0;
	}

	public static void processAllData() {
		// intialise variable(s) - pressure injuries
		Decimal combinedPIS2 = null;
		Decimal combinedPIS3 = null;
		Decimal combinedPIS4 = null;
		Decimal combinedPISDT = null;
		Decimal combinedPIUnstageable = null;

		Decimal combinedPIs = null;
		Decimal combinedPIS1 = null;
		Decimal combinedPIsOutside = null;

		// intialise variable(s) - Physical Restraint
		Decimal combinedPhyRes = null;

		Decimal combinedPR3Day = null;

		// intialise variable(s) - unplannedWeightLoss
		Decimal combinedWLSIG = null;

		Decimal combinedWLCONS = null;

		// intialise variable(s) - fallsMajorInjuryAndMore
		Decimal combinedFALLS = null;
		Decimal combinedFALLSMI = null;

		// intialise variable(s) - Medication Management
		Decimal combinedPolyPharm = null;
		Decimal combinedAPSY = null;

		Decimal combinedMMApsyDig = null;

		// intialise variable(s) - ADLs
		Decimal combinedAdlDec = null;

		// intialise variable(s) - Hospitalisation
		Decimal combinedHspEdPr = null;
		Decimal combinedHspEdAdm = null;

		// intialise variable(s) - Incontinence
		Decimal combinedInc = null;
		Decimal combinedIncIAD = null;
		Decimal combinedInc1A = null;
		Decimal combinedInc1B = null;
		Decimal combinedInc2A = null;
		Decimal combinedInc2B = null;

		// intialise variable(s) - Workforce
		Decimal combinedWfStoppedCM = null;
		Decimal combinedWfStoppedRN = null;
		Decimal combinedWfStoppedEN = null;
		Decimal combinedWfStoppedPC = null;

		// intialise variable(s) - Consumer Experience
		Decimal combinedCeGoodSC = null;
		Decimal combinedCeGoodInt = null;
		Decimal combinedCeGoodPC = null;

		// intialise variable(s) - QOL
		Decimal combinedQlGoodInt = null;
		Decimal combinedQlGoodPC = null;
		Decimal combinedQlGoodSC = null;


		for (Quality_Indicator_Summary__c qiSummary : qiSummaryList) {
			// process pressure injuries
			if(qiSummary.QI_Observed_PI_S2__c != null) {
				combinedPIS2 = combinedPIS2 == null ? qiSummary.QI_Observed_PI_S2__c : combinedPIS2 + qiSummary.QI_Observed_PI_S2__c;
			}

			if(qiSummary.QI_Observed_PI_S3__c != null) {
				combinedPIS3 = combinedPIS3 == null ? qiSummary.QI_Observed_PI_S3__c : combinedPIS3 + qiSummary.QI_Observed_PI_S3__c;
			}

			if(qiSummary.QI_Observed_PI_S4__c != null) {
				combinedPIS4 = combinedPIS4 == null ? qiSummary.QI_Observed_PI_S4__c : combinedPIS4 + qiSummary.QI_Observed_PI_S4__c;
			}

			if(qiSummary.QI_Observed_PI_SDT__c != null) {
				combinedPISDT = combinedPISDT == null ? qiSummary.QI_Observed_PI_SDT__c : combinedPISDT + qiSummary.QI_Observed_PI_SDT__c;
			}

			if(qiSummary.QI_Observed_PI_unstageable__c != null) {
				combinedPIUnstageable = combinedPIUnstageable == null ? qiSummary.QI_Observed_PI_unstageable__c : combinedPIUnstageable + qiSummary.QI_Observed_PI_unstageable__c;
			}


			if(qiSummary.QI_Observed_PIs__c != null) {
				combinedPIs = combinedPIs == null ? qiSummary.QI_Observed_PIs__c : combinedPIs + qiSummary.QI_Observed_PIs__c;
			}
			if(qiSummary.QI_Observed_PI_S1__c != null) {
				combinedPIS1 = combinedPIS1 == null ? qiSummary.QI_Observed_PI_S1__c : combinedPIS1 + qiSummary.QI_Observed_PI_S1__c;
			}
			if(qiSummary.QI_Observed_PIs_Outside__c != null) {
				combinedPIsOutside = combinedPIsOutside == null ? qiSummary.QI_Observed_PIs_Outside__c : combinedPIsOutside + qiSummary.QI_Observed_PIs_Outside__c;
			}

			//process Physical Restraint
			if(qiSummary.QI_Observed_Physical_Restraint__c != null) {
				combinedPhyRes = combinedPhyRes == null ? qiSummary.QI_Observed_Physical_Restraint__c : combinedPhyRes + qiSummary.QI_Observed_Physical_Restraint__c;
			}

			if(qiSummary.QI_Observed_PR_3Day__c != null) {
				combinedPR3Day = combinedPR3Day == null ? qiSummary.QI_Observed_PR_3Day__c : combinedPR3Day + qiSummary.QI_Observed_PR_3Day__c;
			}

			// process unplannedWeightLoss
			if(qiSummary.QI_Observed_WL_SIG__c != null) {
				combinedWLSIG = combinedWLSIG == null ? qiSummary.QI_Observed_WL_SIG__c : combinedWLSIG + qiSummary.QI_Observed_WL_SIG__c;
			}

			if(qiSummary.QI_Observed_WL_Cons__c != null) {
				combinedWLCONS = combinedWLCONS == null ? qiSummary.QI_Observed_WL_Cons__c : combinedWLCONS + qiSummary.QI_Observed_WL_Cons__c;
			}

			// process fallsMajorInjuryAndMore
			if(qiSummary.QI_Observed_FALLS__c != null) {
				combinedFALLS = combinedFALLS == null ? qiSummary.QI_Observed_FALLS__c : combinedFALLS + qiSummary.QI_Observed_FALLS__c;
			}

			if(qiSummary.QI_Observed_Falls_MI__c != null) {
				combinedFALLSMI = combinedFALLSMI == null ? qiSummary.QI_Observed_Falls_MI__c : combinedFALLSMI + qiSummary.QI_Observed_Falls_MI__c;
			}

			//process Medication Management
			if(qiSummary.QI_Observed_Polypharmacy__c != null) {
				combinedPolyPharm = combinedPolyPharm == null ? qiSummary.QI_Observed_Polypharmacy__c : combinedPolyPharm + qiSummary.QI_Observed_Polypharmacy__c;
			}

			if(qiSummary.QI_Observed_APSY__c != null) {
				combinedAPSY = combinedAPSY == null ? qiSummary.QI_Observed_APSY__c : combinedAPSY + qiSummary.QI_Observed_APSY__c;
			}

			if(qiSummary.QI_Observed_MM_APSY_DIG__c != null) {
				combinedMMApsyDig = combinedMMApsyDig == null ? qiSummary.QI_Observed_MM_APSY_DIG__c : combinedMMApsyDig + qiSummary.QI_Observed_MM_APSY_DIG__c;
			}

			//process ADLs
			if(qiSummary.QI_Observed_ADL_DEC__c != null) {
				combinedAdlDec = combinedAdlDec == null ? qiSummary.QI_Observed_ADL_DEC__c : combinedAdlDec + qiSummary.QI_Observed_ADL_DEC__c;
			}

			//process Hospitalisation
			if(qiSummary.QI_Observed_HSP_ED_PR__c != null) {
				combinedHspEdPr = combinedHspEdPr == null ? qiSummary.QI_Observed_HSP_ED_PR__c : combinedHspEdPr + qiSummary.QI_Observed_HSP_ED_PR__c;
			}

			if(qiSummary.QI_Observed_HSP_ED_ADM__c != null) {
				combinedHspEdAdm = combinedHspEdAdm == null ? qiSummary.QI_Observed_HSP_ED_ADM__c : combinedHspEdAdm + qiSummary.QI_Observed_HSP_ED_ADM__c;
			}

			//process Incontinence
			if(qiSummary.QI_Observed_INC__c != null) {
				combinedInc = combinedInc == null ? qiSummary.QI_Observed_INC__c : combinedInc + qiSummary.QI_Observed_INC__c;
			}

			if(qiSummary.QI_Observed_INC_IAD__c != null) {
				combinedIncIAD = combinedIncIAD == null ? qiSummary.QI_Observed_INC_IAD__c : combinedIncIAD + qiSummary.QI_Observed_INC_IAD__c;
			}

			if(qiSummary.QI_Observed_INC_1A__c != null) {
				combinedInc1A = combinedInc1A == null ? qiSummary.QI_Observed_INC_1A__c : combinedInc1A + qiSummary.QI_Observed_INC_1A__c;
			}

			if(qiSummary.QI_Observed_INC_1B__c != null) {
				combinedInc1B = combinedInc1B == null ? qiSummary.QI_Observed_INC_1B__c : combinedInc1B + qiSummary.QI_Observed_INC_1B__c;
			}

			if(qiSummary.QI_Observed_INC_2A__c != null) {
				combinedInc2A = combinedInc2A == null ? qiSummary.QI_Observed_INC_2A__c : combinedInc2A + qiSummary.QI_Observed_INC_2A__c;
			}

			if(qiSummary.QI_Observed_INC_2B__c != null) {
				combinedInc2B = combinedInc2B == null ? qiSummary.QI_Observed_INC_2B__c : combinedInc2B + qiSummary.QI_Observed_INC_2B__c;
			}

			//process Workforce

			if(qiSummary.QI_Observed_WF_Stopped_CM__c != null) {
				combinedWfStoppedCM = combinedWfStoppedCM == null ? qiSummary.QI_Observed_WF_Stopped_CM__c : combinedWfStoppedCM + qiSummary.QI_Observed_WF_Stopped_CM__c;
			}

			if(qiSummary.QI_Observed_WF_Stopped_RN__c != null) {
				combinedWfStoppedRN = combinedWfStoppedRN == null ? qiSummary.QI_Observed_WF_Stopped_RN__c : combinedWfStoppedRN + qiSummary.QI_Observed_WF_Stopped_RN__c;
			}

			if(qiSummary.QI_Observed_WF_Stopped_EN__c != null) {
				combinedWfStoppedEN = combinedWfStoppedEN == null ? qiSummary.QI_Observed_WF_Stopped_EN__c : combinedWfStoppedEN + qiSummary.QI_Observed_WF_Stopped_EN__c;
			}

			if(qiSummary.QI_Observed_WF_Stopped_PC__c != null) {
				combinedWfStoppedPC = combinedWfStoppedPC == null ? qiSummary.QI_Observed_WF_Stopped_PC__c : combinedWfStoppedPC + qiSummary.QI_Observed_WF_Stopped_PC__c;
			}

			//process Consumer Experience
			if(qiSummary.QI_Observed_CE_Good_SC__c != null) {
				combinedCeGoodSC = combinedCeGoodSC == null ? qiSummary.QI_Observed_CE_Good_SC__c : combinedCeGoodSC + qiSummary.QI_Observed_CE_Good_SC__c;
			}

			if(qiSummary.QI_Observed_CE_Good_Int__c != null) {
				combinedCeGoodInt = combinedCeGoodInt == null ? qiSummary.QI_Observed_CE_Good_Int__c : combinedCeGoodInt + qiSummary.QI_Observed_CE_Good_Int__c;
			}

			if(qiSummary.QI_Observed_CE_Good_PC__c != null) {
				combinedCeGoodPC = combinedCeGoodPC == null ? qiSummary.QI_Observed_CE_Good_PC__c : combinedCeGoodPC + qiSummary.QI_Observed_CE_Good_PC__c;
			}

			//process QOL
			if(qiSummary.QI_Observed_QL_Good_Int__c != null) {
				combinedQlGoodInt = combinedQlGoodInt == null ? qiSummary.QI_Observed_QL_Good_Int__c : combinedQlGoodInt + qiSummary.QI_Observed_QL_Good_Int__c;
			}

			if(qiSummary.QI_Observed_QL_Good_PC__c != null) {
				combinedQlGoodPC = combinedQlGoodPC == null ? qiSummary.QI_Observed_QL_Good_PC__c : combinedQlGoodPC + qiSummary.QI_Observed_QL_Good_PC__c;
			}

			if(qiSummary.QI_Observed_QL_Good_SC__c != null) {
				combinedQlGoodSC = combinedQlGoodSC == null ? qiSummary.QI_Observed_QL_Good_SC__c : combinedQlGoodSC + qiSummary.QI_Observed_QL_Good_SC__c;
			}

		}

		// update national percentage for pressure injuries
		ns.National_percentage_PI_Stage2__c = combinedPIS2 != null ? combinedPIS2 / qiSummaryList.size() : null;
		ns.National_percentage_PI_Stage3__c = combinedPIS3 != null ? combinedPIS3 / qiSummaryList.size() : null;
		ns.National_percentage_PI_Stage4__c = combinedPIS4 != null ? combinedPIS4 / qiSummaryList.size() : null;
		ns.National_percentage_PI_Deep_Tissue__c = combinedPISDT != null ? combinedPISDT / qiSummaryList.size() : null;
		ns.National_percentage_PI_Unstageable__c = combinedPIUnstageable != null ? combinedPIUnstageable / qiSummaryList.size() : null;

		ns.National_percentage_PIs__c = combinedPIs != null ? combinedPIs / qiSummaryList.size() : null;
		ns.National_percentage_PI_Stage1__c = combinedPIS1 != null ? combinedPIS1 / qiSummaryList.size() : null;
		ns.National_percentage_PIs_Outside__c = combinedPIsOutside != null ? combinedPIsOutside / qiSummaryList.size() : null;

		// update national percentage for Physical Restraint
		ns.National_percentage_Physical_Restraint__c = combinedPhyRes != null ? combinedPhyRes / qiSummaryList.size() : null;

		ns.National_percentage_PR_3Day__c = combinedPR3Day != null ? combinedPR3Day / qiSummaryList.size() : null;

		// update national percentage for weightloss
		ns.National_percentage_significant_UWL__c = combinedWLSIG != null ? combinedWLSIG / qiSummaryList.size() : null;

		ns.National_percentage_WL_Cons__c = combinedWLCONS != null ? combinedWLCONS / qiSummaryList.size() : null;

		// update national percentage for falls
		ns.National_percentage_falls__c = combinedFALLS != null ? combinedFALLS / qiSummaryList.size() : null;
		ns.National_Percentage_falls_Major_Injury__c = combinedFALLSMI != null ? combinedFALLSMI / qiSummaryList.size() : null;

		// update Medication Management
		ns.National_percentage_Polypharmacy__c = combinedPolyPharm != null ? combinedPolyPharm / qiSummaryList.size() : null;
		ns.National_percentage_APSY__c = combinedAPSY != null ? combinedAPSY / qiSummaryList.size() : null;

		ns.National_percentage_MM_APSY_DIG__c = combinedMMApsyDig != null ? combinedMMApsyDig / qiSummaryList.size() : null;

		//update ADLs
		ns.National_percentage_ADL_DEC__c = combinedAdlDec != null ? combinedAdlDec / qiSummaryList.size() : null;

		
		//update Hospitalisation
		ns.National_percentage_HSP_ED_PR__c = combinedHspEdPr != null ? combinedHspEdPr / qiSummaryList.size() : null;
		ns.National_percentage_HSP_ED_ADM__c = combinedHspEdAdm != null ? combinedHspEdAdm / qiSummaryList.size() : null;

		//update Incontinence
		ns.National_percentage_INC__c = combinedInc != null ? combinedInc / qiSummaryList.size() : null;
		ns.National_percentage_INC_IAD__c = combinedIncIAD != null ? combinedIncIAD / qiSummaryList.size() : null;
		ns.National_percentage_INC_1A__c = combinedInc1A != null ? combinedInc1A / qiSummaryList.size() : null;
		ns.National_percentage_INC_1B__c = combinedInc1B != null ? combinedInc1B / qiSummaryList.size() : null;
		ns.National_percentage_INC_2A__c = combinedInc2A != null ? combinedInc2A / qiSummaryList.size() : null;
		ns.National_percentage_INC_2B__c = combinedInc2B != null ? combinedInc2B / qiSummaryList.size() : null;

		//update Workforce
		ns.National_percentage_WF_Stopped_CM__c = combinedWfStoppedCM != null ? combinedWfStoppedCM / qiSummaryList.size() : null;
		ns.National_percentage_WF_Stopped_RN__c = combinedWfStoppedRN != null ? combinedWfStoppedRN / qiSummaryList.size() : null;
		ns.National_percentage_WF_Stopped_EN__c = combinedWfStoppedEN != null ? combinedWfStoppedEN / qiSummaryList.size() : null;
		ns.National_percentage_WF_Stopped_PC__c = combinedWfStoppedPC != null ? combinedWfStoppedPC / qiSummaryList.size() : null;

		//update Consumer Experience
		ns.National_percentage_CE_Good_SC__c = combinedCeGoodSC != null ? combinedCeGoodSC / qiSummaryList.size() : null;
		ns.National_percentage_CE_Good_Int__c = combinedCeGoodInt != null ? combinedCeGoodInt / qiSummaryList.size() : null;
		ns.National_percentage_CE_Good_PC__c = combinedCeGoodPC != null ? combinedCeGoodPC / qiSummaryList.size() : null;

		//update QOL
		ns.National_percentage_QL_Good_Int__c = combinedQlGoodInt != null ? combinedQlGoodInt / qiSummaryList.size() : null;
		ns.National_percentage_QL_Good_PC__c = combinedQlGoodPC != null ? combinedQlGoodPC / qiSummaryList.size() : null;
		ns.National_percentage_QL_Good_SC__c = combinedQlGoodSC != null ? combinedQlGoodSC / qiSummaryList.size() : null;
	}

	public static void updateRiskAdjusted(List<Quality_Indicator_Summary__c> qiRecords, National_Statistic__c ns) {
		Decimal combinedRAPIS2 = null;
		Decimal combinedRAPIS3 = null;
		Decimal combinedRAPIS4 = null;
		Decimal combinedRAPISDT = null;
		Decimal combinedRAPIUnstageable = null;

		for (Quality_Indicator_Summary__c qiSummary : qiRecords) {
			if(qiSummary.Risk_Adjusted_PI_Level2__c != null) {
				combinedRAPIS2 = combinedRAPIS2 == null ? qiSummary.Risk_Adjusted_PI_Level2__c : combinedRAPIS2 + qiSummary.Risk_Adjusted_PI_Level2__c;
			}

			if(qiSummary.Risk_Adjusted_PI_Level3__c != null) {
				combinedRAPIS3 = combinedRAPIS3 == null ? qiSummary.Risk_Adjusted_PI_Level3__c : combinedRAPIS3 + qiSummary.Risk_Adjusted_PI_Level3__c;
			}

			if(qiSummary.Risk_Adjusted_PI_Level4__c != null) {
				combinedRAPIS4 = combinedRAPIS4 == null ? qiSummary.Risk_Adjusted_PI_Level4__c : combinedRAPIS4 + qiSummary.Risk_Adjusted_PI_Level4__c;
			}

			if(qiSummary.Risk_Adjusted_DT_PI__c != null) {
				combinedRAPISDT = combinedRAPISDT == null ? qiSummary.Risk_Adjusted_DT_PI__c : combinedRAPISDT + qiSummary.Risk_Adjusted_DT_PI__c;
			}

			if(qiSummary.Risk_Adjusted_Unstageable_PI__c != null) {
				combinedRAPIUnstageable = combinedRAPIUnstageable == null ? qiSummary.Risk_Adjusted_Unstageable_PI__c : combinedRAPIUnstageable + qiSummary.Risk_Adjusted_Unstageable_PI__c;
			}
		}

		ns.Risk_Adjusted_National_PI_Stage2__c = combinedRAPIS2 != null ? combinedRAPIS2 / qiSummaryList.size() : null;
		ns.Risk_Adjusted_National_PI_Stage3__c = combinedRAPIS3 != null ? combinedRAPIS3 / qiSummaryList.size() : null;
		ns.Risk_Adjusted_National_PI_Stage4__c = combinedRAPIS4 != null ? combinedRAPIS4 / qiSummaryList.size() : null;
		ns.Risk_Adjusted_National_PI_DT__c = combinedRAPISDT != null ? combinedRAPISDT / qiSummaryList.size() : null;
		ns.Risk_Adjusted_National_PI_Unstageable__c = combinedRAPIUnstageable != null ? combinedRAPIUnstageable / qiSummaryList.size() : null;

		try {
			update ns;
		} catch (Exception ex) {
            dohagedcare.Logger.error(ex.getMessage(), ex, 'National Statistics - Risk Adjusted').log();
        }
	}
}