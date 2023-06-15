/**
 * @description       :
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             :
 * @last modified on  : 11-28-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 **/
public with sharing class GLCodeLineItemHelper {
	Set<String> serviceCategories = new Set<String>();
	Set<String> formTypes = new Set<String>();
	List<Service_line_item__c> serviceLineItems = new List<Service_line_item__c>();
	Map<Database.SaveResult, Id> allFailedResultsGLC = new Map<Database.SaveResult, Id>();
	List<Database.SaveResult> allSuccessResultsGLC = new List<Database.SaveResult>();
    private QueryService queryService = new QueryService();
	WithoutSharingDML withoutSharingDML = new WithoutSharingDML();

	public GLCodeLineItemHelper(
		List<Service_line_item__c> serviceLineItems,
		Set<String> formTypes
	) {
		this.formTypes = formTypes;
		this.serviceLineItems = serviceLineItems;
		System.debug('this.formTypes = formTypes;====' + formTypes);
		for (Service_Line_Item__c sli : this.serviceLineItems) {
			serviceCategories.add(sli.Service_Category__c);
			System.debug(
				'serviceCategories.add(sli.Service_Category__c);====' +
				sli.Service_Category__c
			);
		}
	}

	public void generateGLCodeLineItems() {
		List<Service_GL_Code_Restriction__mdt> restrictions = ServiceGLCodeRestrictionFactory.getRestrictions(
			serviceCategories
		);
		Map<String, Set<String>> glCodesByServiceCategoryInclusions = new Map<String, Set<String>>();
		Map<String, Set<String>> glCodesByServiceCategoryInclusionsSummaryOnly = new Map<String, Set<String>>();
		Map<String, Set<String>> glCodesByServiceCategoryExclusions = new Map<String, Set<String>>();
		for (Service_GL_Code_Restriction__mdt restriction : restrictions) {
			// add to inclusion or exclusion map appropriately
			Set<String> glCodeIds;
			if (
				restriction.Restriction_Type__c == 'Include' &&
				!restriction.Summary_only__c
			) {
				glCodeIds = glCodesByServiceCategoryInclusions.get(
					restriction.Service_Category__c
				);

				if (glCodeIds == null) {
					glCodeIds = new Set<String>();
					glCodesByServiceCategoryInclusions.put(
						restriction.Service_Category__c,
						glCodeIds
					);
				}
			} else if (
				restriction.Restriction_Type__c == 'Include' &&
				restriction.Summary_only__c
			) {
				glCodeIds = glCodesByServiceCategoryInclusionsSummaryOnly.get(
					restriction.Service_Category__c
				);

				if (glCodeIds == null) {
					glCodeIds = new Set<String>();
					glCodesByServiceCategoryInclusionsSummaryOnly.put(
						restriction.Service_Category__c,
						glCodeIds
					);
				}
			} else if (restriction.Restriction_Type__c == 'Exclude') {
				glCodeIds = glCodesByServiceCategoryExclusions.get(
					restriction.Service_Category__c
				);

				if (glCodeIds == null) {
					glCodeIds = new Set<String>();
					glCodesByServiceCategoryExclusions.put(
						restriction.Service_Category__c,
						glCodeIds
					);
				}
			}else{
				//Do nothing
			}

			glCodeIds.add(restriction.GL_Code__c);
		}

		List<GL_Code__c> glCodes =  getGLcodeRecords(this.formTypes);
		List<GL_Code_Line_Item__c> lineitems = new List<GL_Code_Line_Item__c>();

		for (Service_Line_Item__c sli : serviceLineItems) {
			for (GL_Code__c glCode : glCodes) {
				if (sli.Form__r.Type__c != glCode.Type__c) {
					continue;
				}

				// if this sli has a service category, filter GL Codes accordingly
				if (
					sli.Service_Category__c != null &&
					(sli.Form__r.Type__c ==
					'Approved Provider Quarterly Financial Statements' ||
					sli.Form__r.Type__c == 'MPS Food and Nutrition Reporting' ||
					sli.Form__r.Type__c ==
					'Residential Food and Nutrition Reporting' ||
					sli.Form__r.Type__c ==
					'NATSIFACP Food and Nutrition Reporting')
				) {
					Set<String> inclusions = glCodesByServiceCategoryInclusions.get(
						sli.Service_Category__c
					);
					if (
						inclusions != null &&
						!inclusions.contains(glCode.Business_ID__c)
					) {
						continue;
					}

					Set<String> exclusions = glCodesByServiceCategoryExclusions.get(
						sli.Service_Category__c
					);
					if (
						exclusions != null &&
						exclusions.contains(glCode.Business_ID__c)
					) {
						continue;
					}
				}
				// include the GL codes to summary only

				else if (
					sli.Service_Category__c == null ||
					sli.Service_Category__c != 'Total'
				) {
					Set<String> inclusionsSummaryOnly = glCodesByServiceCategoryInclusionsSummaryOnly.get(
						'Total'
					);

					if (
						inclusionsSummaryOnly != null &&
						inclusionsSummaryOnly.contains(glCode.Business_ID__c)
					) {
						continue;
					}
				}else{
					//Do nothing
				}
				GL_Code_Line_Item__c lineitem = new GL_Code_Line_Item__c(
					GL_Code__c = glCode.Id,
					Service_Line_Item__c = sli.Id
				);
				lineitems.add(lineItem);
			}
		}

		try {
            withoutSharingDML.insertRecords(lineitems, false);

		} catch (DmlException e) {
			dohagedcare.logger.error(e.getMessage(), e, 'QFR').log();
		}
	}

    public List<GL_Code__c> getGLcodeRecords(Set<String> formTypes) {
        return this.queryService.getGLCodes(formTypes);  
    }
    private without sharing class QueryService {
        private List<GL_Code__c> getGLCodes(Set<String> formTypes) {
			return [ SELECT Id, Type__c, Business_ID__c
                FROM GL_Code__c
                WHERE Type__c IN :formTypes AND Line_Item_Value_Type__c != NULL
			];
		}
    }
}
