public with sharing class GPMSUserInfoController {
    @AuraEnabled
    public static map < String, Object > getUserInfo() {
        String salutation;
        String firstName;
        String fullName;
        User myUser = [SELECT id, contactId, contact.salutation, firstName, Current_Account__c, lastName FROM User WHERE Id =: UserInfo.getUserId()];
        If(myUser.id !=null) {
            if(myUser.contact.salutation!=null) {
                salutation = myUser.contact.salutation;
            }
            else {
				salutation = '';
            }
            if(myUser.firstName!=null) {
                firstName = myUser.firstName;
            }
            else {
				firstName = '';
            }
            fullName = salutation + ' ' + firstName +' '+myUser.lastName;
            fullName.removeStart(' ');
            return new Map < String, Object > {
                'success' => true,
                    'fullName' => fullName,
                    'accountName' => myUser.Current_Account__c,
                    'UserId' => myUser.id
            };
        }
        else {
            dohagedcare.Logger.Info('Failed to retreive user details');
            return new Map < String, Object > {'success' => false,'error' => 'Failed to retreive user details'};
        }
    }

    @AuraEnabled
    public static map < String, Object > getUserPermission() {
        Boolean isCHSP = false;
        Boolean isAP = false;
        Boolean isNATSIFAC = false;
        Boolean isOrgAdmin = false;
        Boolean isApplicant = false;
        Boolean isStaff = false;
        Boolean isSROrg = false;
        Boolean isSRService = false;
        Boolean isQIOrg = false;
        Boolean isQIService = false;
        Boolean isQFREntry = false;
        Boolean isQFRSubmission = false;
        Boolean isQIBenchmarker = false;

        User myUser = [SELECT id, contactId FROM User WHERE Id =: UserInfo.getUserId()];
        List<Org_Switcher_Mapping__mdt> switcherMapping = [SELECT id, DeveloperName, AccountRecordType__c, PermissionSet__c, Permission_Set_Group_Developer_Name__c, Role__c
                                                            FROM Org_Switcher_Mapping__mdt];

        if(myUser.id != null){
            Set<String> portalUserPermissionSets = new Set<String>();
            Set<String> portalUserPermissionSetGroups = new Set<String>();
            for(Org_Switcher_Mapping__mdt sm : switcherMapping) {
                if(sm.PermissionSet__c != null && sm.AccountRecordType__c!=null){
                    portalUserPermissionSets.add(sm.PermissionSet__c);
                }else if(sm.Permission_Set_Group_Developer_Name__c != null && sm.Role__c!=null){
                    portalUserPermissionSetGroups.add(sm.Permission_Set_Group_Developer_Name__c);
                }
            }

            List<PermissionSetAssignment> userPermissionSetAssignment = [SELECT id, PermissionSetId, PermissionSet.Name, PermissionSetGroupId, PermissionSetGroup.DeveloperName
                                                                        FROM PermissionSetAssignment
                                                                        WHERE AssigneeId =:myUser.id AND (PermissionSet.Name IN:portalUserPermissionSets
                                                                        OR PermissionSetGroup.DeveloperName IN: portalUserPermissionSetGroups)];

            for(PermissionSetAssignment psa : userPermissionSetAssignment){
                if(psa.PermissionSetId != null){
                    switch on psa.PermissionSet.Name {
                        when 'Commonwealth_Home_Support_Programme'{
                            isCHSP =true;
                        }
                        when 'National_Aboriginal_and_Torres_Strait_Islander_Flexible_Aged_Care'{
                            isNATSIFAC = true;
                        }
                        when 'Approved_Provider'{
                            isAP = true;
                        }
                    }

                    if(psa.PermissionSetGroupId != null){
                        switch on psa.PermissionSetGroup.DeveloperName {
                            when 'Applicants'{
                                isApplicant = true;
                            }
                            when 'Organisation_Administrator'{
                                isOrgAdmin = true;
                            }
                            when 'QFR_Finance_Data_Entry'{
                                isQFREntry = true;
                            }
                            when 'QFR_Finance_Data_Submission'{
                                isQFRSubmission = true;
                            }
                            when 'QI_Benchmarker'{
                                isQIBenchmarker = true;
                            }
                            when 'QI_Role'{
                                isQIService = true;
                            }
                            when 'QI_Role_Org'{
                                isQIOrg = true;
                            }
                            when 'Staff_Member'{
                                isStaff = true;
                            }
                            when 'Provider_Portal_Star_Rating_User'{
                                isSROrg = true;
                            }
                            when 'Star_Rating_Reviewer_Service'{
                                isSRService = true;
                            }
                        }
                    }
                }
            }
            return new Map < String, Object > {
                'success' => true,
                    'isCHSP' => isCHSP,
                    'isAP' => isAP,
                    'isNATSIFAC' => isNATSIFAC,
                    'isOrgAdmin' => isOrgAdmin,
                    'isApplicant' => isApplicant,
                    'isStaff' => isStaff,
                    'isSROrg' => isSROrg,
                    'isSRService' => isSRService,
                    'isQIOrg' => isQIOrg,
                    'isQIService' => isQIService,
                    'isQFREntry' => isQFREntry,
                    'isQFRSubmission' => isQFRSubmission,
                    'isQIBenchmarker' => isQIBenchmarker
                    };
                        }
        else {
            dohagedcare.Logger.Info('Failed to retreive user details');
            return new Map < String, Object > {'success' => false,'error' => 'Failed to retreive user details'};
                }
    }
}
