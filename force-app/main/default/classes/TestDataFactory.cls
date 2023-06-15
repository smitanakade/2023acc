/**
 * author: Daniel Clift
 * date: 18/08/2022
 * description: to generate data for test classes
 **/
/* MODIFICATION LOG
 * Version       Developer                   Date                Description
 *-------------------------------------------------------------------------------------------------------------------------------------------------------
 *  1.0     		Daniel Clift                18-08-2022          Initial Creation
 *  1.1             Gabriel PCL de Almeida      19-09-2022          Added Exemption creation methods
 *  1.2             Gabriel PCL de Almeida      27-09-2022          Added STAR Rating History creation method
 *  1.3			    Gabriel PCL de Almeida      09/10/2022			Added method to create Accreditation/Certification records
 *  1.4             Rami Zuhairi                26-10-2022          Added methods for SCR Cal test class that accepts certain criteria
 *  1.5             Smita Kagde                 01-10-2022          Added methods for SCR Cal test class that accepts certain criteria
 *  1.6             Sanjeev Bajpai              08-Nov-2022         Added methods for Star rating Admin user,compliance user and sysadmin
 *  1.7             Kai-Fan Hsieh               21-Nov-2022         Added provider portal user and contact creations methods
 *  1.8            Ali Mohammadi                02-Dec-2022         Added manage users test data methods
 *  1.9            Ashwani Kaushik              28-Feb-2023         Added Task,FeedComment,HealthUser test data methods
 *  1.91           Yifei Pei                    28-Feb-2023         Added Oracle Id generation for service record generation
 *  1.92           Yifei Pei                    01-Mar-2023         Added No_of_staff_FM_start_quarter__c for Quality Indicator Detail
 *  1.93           Yifei Pei                    01-Mar-2023         Added No_care_recipients_offered_QCE_ACC__c for Quality Indicator Detail
 *  1.94           Yifei Pei                    01-Mar-2023         Added No_of_staff_employed_as_Enrolled_Nurse__c for Quality Indicator Detail
 *  1.95           Yifei Pei                    01-Mar-2023         Added No_of_staff_PCW_start_quarter__c for Quality Indicator Detail
 *  1.96           Yifei Pei                    01-Mar-2023         Added No_care_recipients_offered_QOL_ACC__c for Quality Indicator Detail
 *  1.97           Yifei Pei                    01-Mar-2023         Added No_of_staff_NP_start_quarter__c for Quality Indicator Detail
 *  1.98           Jamil Khaki                  15-Mar-2023         Added QI Targets creation method
 *  1.99           Ali Mohammadi                20-Mar-2023         Assigning permissions Method for Manage User
 *  2.00           Rami Zuhairi                 20-Apr-2023         Updated createQIRegulatoryCodeViolation to have extra field Status='Current'
 *  2.01           Rami Zuhairi                 10-May-2023         Added createStarRatingHistoryRecordsWithSAR() method
 *****************************************************************************************************************************************************/
@isTest
public class TestDataFactory {
    public static final string sydenyTimeZone = 'Australia/Sydney';
    public static final string userName = '@testorg.com';
    public static Reporting_Period__c createReportingPeriod(String Type) {
        Reporting_Period__c rPeriod = new Reporting_Period__c();

        if (Type == 'Quarter') {
            rPeriod.Reporting_Period_Type__c = 'Quarter';
            rPeriod.Start_Date__c = System.today() - 5;
            rPeriod.End_Date__c = System.today() + 5;
            rPeriod.CM_Calc_Date__c = System.today();
            rPeriod.QI_Calc_Date__c = System.today();
            rPeriod.CER_Calc_Date__c = System.today();
            rPeriod.StarRating_Calc_Date__c = System.today();
        }

        if (Type == 'Year') {
            rPeriod.Reporting_Period_Type__c = 'Year';
            rPeriod.Start_Date__c = System.today() - 5;
            rPeriod.End_Date__c = System.today() + 5;
            rPeriod.CER_Calc_Date__c = System.today();
        }

        return rPeriod;
    }

    public static List<BusinessLicense> createServiceRecords(
        Integer RecordCount
    ) {
        List<BusinessLicense> serviceList = new List<BusinessLicense>();
        for (Integer i = 0; i < recordCount; i++) {
            BusinessLicense serv = new BusinessLicense();
            serv.Name = 'Service Test ' + i;
            serv.Care_Type__c = 'Residential';
            serv.Service_Care_Sub_Type__c = null;
            serv.Status__c = 'Operational';
            serv.Status_Date__c = Date.today();
            serv.Oracle_Service_ID__c = '9999' + String.valueOf(i);
            serviceList.add(serv);
        }
        return serviceList;
    }
    //create Test user with Health user profile
    public static User createTestUser() {
        String uniqueUserName =
            'starRatinguser' +
            DateTime.now().getTime() +
            userName;
        // This code runs as the system user
        Profile healthUsrProfile = [
            SELECT Id
            FROM Profile
            WHERE Name = 'Health User'
        ];
        Id userRoleId = [SELECT Id FROM UserRole WHERE Name = 'Health Staff']
            .Id;

        User usr = new User(
            Alias = 'starRatinguser',
            Email = 'starRatinguser@testorg.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = healthUsrProfile.Id,
            TimeZoneSidKey = sydenyTimeZone,
            UserName = uniqueUserName,
            UserRoleId = userRoleId
        );
        return usr;
    }
    //create Star rating admin user
    public static User createStarRatingAdminUser() {
        String uniqueUserName =
            'starRatingAdminuser' +
            DateTime.now().getTime() +
            userName;
        // This code runs as the system user
        Profile starRatingAdminUsrProfile = [
            SELECT Id
            FROM Profile
            WHERE Name = 'Health User'
        ];
        Id userRoleId = [SELECT Id FROM UserRole WHERE Name = 'Health Staff']
            .Id;

        User usr = new User(
            Alias = 'srad',
            Email = 'starRatingadminuser@testorg.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = starRatingAdminUsrProfile.Id,
            TimeZoneSidKey = sydenyTimeZone,
            UserName = uniqueUserName,
            UserRoleId = userRoleId
        );
        System.runAs([
            SELECT Id, Name, Email, Profile.Name, UserRole.Name
            FROM User
            WHERE Id = :UserInfo.getUserId()
        ][0]) {
            insert usr;
            PermissionSetGroup psg = [
                SELECT Id, DeveloperName, Status
                FROM PermissionSetGroup
                WHERE developername = 'Star_Rating_Super_User_PSG'
            ];
            if (psg.Status != 'Updated') {
                Test.calculatePermissionSetGroup(psg.Id);
            }
            PermissionSetAssignment assignment = new PermissionSetAssignment(
                PermissionSetGroupId = psg.Id,
                AssigneeId = usr.Id
            );
            insert assignment;
        }
        GroupMember publicGroup = new GroupMember();
        Group gp = [
            SELECT ID, name
            FROM Group
            WHERE name = 'STAR Rating Users'
        ];
        publicGroup.GroupId = gp.Id;
        publicGroup.UserOrGroupId = usr.Id;
        insert publicGroup;
        return usr;
    }
    //create complaince user
    public static User createComplianceUser() {
        String uniqueUserName =
            'ComplianceUser' +
            DateTime.now().getTime() +
            userName;
        // This code runs as the system user
        Profile complianceUsrProfile = [
            SELECT Id
            FROM Profile
            WHERE Name = 'Compliance User'
        ];
        Id userRoleId = [SELECT Id FROM UserRole WHERE Name = 'Health Staff']
            .Id;

        User usr = new User(
            Alias = 'ComplUsr',
            Email = 'ComplianceUser@testorg.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = complianceUsrProfile.Id,
            TimeZoneSidKey = sydenyTimeZone,
            UserName = uniqueUserName,
            UserRoleId = userRoleId
        );
        System.runAs([
            SELECT Id, Name, Email, Profile.Name, UserRole.Name
            FROM User
            WHERE Id = :UserInfo.getUserId()
        ][0]) {
            insert usr;
            PermissionSetGroup psg = [
                SELECT Id, DeveloperName, Status
                FROM PermissionSetGroup
                WHERE developername = 'Compliance_Users'
            ];
            if (psg.Status != 'Updated') {
                Test.calculatePermissionSetGroup(psg.Id);
            }
            PermissionSetAssignment assignment = new PermissionSetAssignment(
                PermissionSetGroupId = psg.Id,
                AssigneeId = usr.Id
            );
            insert assignment;
        }
        GroupMember publicGroup = new GroupMember();
        Group gp = [SELECT ID, name FROM Group WHERE name = 'GPMS ACQSC Users'];
        publicGroup.GroupId = gp.Id;
        publicGroup.UserOrGroupId = usr.Id;
        insert publicGroup;

        return usr;
    }
    //create admin user
    public static User createHealthUser() {
        String uniqueUserName =
            'HealthUser' +
            DateTime.now().getTime() +
            userName;
        Profile healthUsrProfile = [
            SELECT Id
            FROM Profile
            WHERE Name = 'Health User'
        ];

        User usr = new User(
            Alias = 'Huser',
            Email = 'healthuser@testorg.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Test User',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = healthUsrProfile.Id,
            TimeZoneSidKey = sydenyTimeZone,
            isActive = true,
            UserName = uniqueUserName
        );

        insert usr;
        return usr;
    }

    public static Task createTask(String subject) {
        Task t = new Task();
        t.Subject = subject;
        return t;
    }
    public static FeedItem createFeedItem(String parentId, String body) {
        FeedItem fitem = new FeedItem(ParentId = parentId, Body = body);
        return fitem;
    }
    public static FeedComment createFeedComment(
        String fItemId,
        String commentBody
    ) {
        FeedComment fc = new FeedComment();
        fc.commentBody = commentBody;
        fc.FeedItemId = fItemId;
        return fc;
    }

    /**
     * @description retrieves system admin user for test usage
     */
    public static User createSystemAdminUser() {
        String uniqueUserName =
            'Adminuser' +
            DateTime.now().getTime() +
            userName;
        // This code runs as the system user
        Profile adminUsrProfile = [
            SELECT Id
            FROM Profile
            WHERE Name = 'System Administrator'
        ];
        Id userRoleId = [SELECT Id FROM UserRole WHERE Name = 'Health Staff']
            .Id;

        User usr = new User(
            Alias = 'Adminusr',
            Email = 'adminuser@testorg.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = AdminUsrProfile.Id,
            TimeZoneSidKey = sydenyTimeZone,
            UserName = uniqueUserName,
            UserRoleId = userRoleId
        );
        System.runAs([
            SELECT Id, Name, Email, Profile.Name, UserRole.Name
            FROM User
            WHERE Id = :UserInfo.getUserId()
        ][0]) {
            insert usr;
            List<PermissionSet> ps = [
                SELECT Id
                FROM PermissionSet
                WHERE
                    Name IN (
                        'System_Admin',
                        'CM_management',
                        'Compliance_User',
                        'Consumer_Experience_Management',
                        'GPMS_Package_Permission_Set',
                        'QI_Management',
                        'Reporting_Domain_Management',
                        'STAR_Rating_Provider_Management',
                        'Star_Rating_Case_Management',
                        'Star_Rating_Management',
                        'Star_Rating_Omni_Admin'
                    )
            ];
            List<PermissionSetAssignment> allPS = new List<PermissionSetAssignment>();
            for (PermissionSet rec : ps) {
                PermissionSetAssignment assignment = new PermissionSetAssignment(
                    PermissionSetId = rec.Id,
                    AssigneeId = usr.Id
                );
                allPS.add(assignment);
            }
            insert allPS;
            GroupMember publicGroup = new GroupMember();
            Group gp = [
                SELECT ID, developername, name
                FROM Group
                WHERE developername = 'GPMS_System_Administrator'
            ];
            publicGroup.GroupId = gp.Id;
            publicGroup.UserOrGroupId = usr.Id;
            insert publicGroup;
        }
        return usr;
    }

    public static User insertNewSysAdmin() {
        String adminUsername =
            'azure.devops@health.gov.au.prod.' +
            System.DomainParser.parse(URL.getOrgDomainUrl()).getSandboxName();
        List<User> users = [
            SELECT
                Id,
                Username,
                UserRoleId,
                Alias,
                Email,
                EmailEncodingKey,
                LastName,
                ProfileId,
                TimeZoneSidKey,
                LanguageLocaleKey,
                IsActive
            FROM User
            WHERE Username = :adminUsername
        ];
        Assert.isTrue(
            users.size() == 1,
            'Apex System Admin Test User has not been set up, cannot retrieve for test execution.'
        );
        User u = users[0];
        if (!u.isActive) {
            u.isActive = true;
            System.runAs(new User(Id = UserInfo.getUserId())) {
                update u;
            }
        }
        return u;
    }

    public static List<Quality_Indicator_Details__c> createQIDetailRecords(
        Integer recordCount,
        List<Quality_Indicator_Summary__c> qiSummaryList
    ) {
        Integer qiSummarySize = qiSummaryList.size();
        List<Quality_Indicator_Details__c> qiDetailList = new List<Quality_Indicator_Details__c>();
        Integer k = 0;
        for (Integer i = 0; i < recordCount; i++) {
            if (k == qiSummarySize) {
                k = 0;
            }
            Quality_Indicator_Details__c qiDetail = new Quality_Indicator_Details__c();
            qiDetail.No_CR_One_More_PI_Stage2__c = 5;
            qiDetail.No_CR_One_More_PI_Stage3__c = 5;
            qiDetail.No_CR_One_More_PI_Stage4__c = 5;
            qiDetail.No_CR_PI_Unstagable__c = 5;
            qiDetail.No_CR_PI_DeepTissue__c = 5;
            qiDetail.No_CR_Physical_Restrained_SecureArea_3D__c = 5;
            qiDetail.Unplanned_Consecutive_Weight_Loss__c = 5;
            qiDetail.No_CR_Exp_Fall__c = 5;
            qiDetail.No_CR_Exp_FallWith_Injury__c = 5;
            qiDetail.No_CR_Presc_Med__c = 5;
            qiDetail.No_CR_rec_antipsychotic__c = 5;
            qiDetail.Unplanned_Sig_Weight_Loss__c = 5;
            qiDetail.No_CR_Assessed__c = 10;
            qiDetail.No_CR_Assessed2__c = 10;

            qiDetail.No_CR_One_More_PI__c = 5;
            qiDetail.No_CR_One_More_PI_Stage1__c = 5;
            qiDetail.No_CR_PI_AcqOutside__c = 5;
            qiDetail.No_CR_Self_QOL_completion_Moderate__c = 1;
            qiDetail.No_CR_Self_QOL_completion_Poor__c = 1;
            qiDetail.No_CR_Self_QOL_completion_VeryPoor__c = 1;
            qiDetail.No_CR_Self_CE_completion_Moderate__c = 1;
            qiDetail.No_CR_Self_CE_completion_Poor__c = 1;
            qiDetail.No_CR_Self_CE_completion_VeryPoor__c = 1;
            qiDetail.No_staff_stopped_facility_manager__c = 5;
            qiDetail.No_of_staff_FM_start_quarter__c = 6;
            qiDetail.No_staff_stopped_registered_nurse__c = 5;
            qiDetail.No_of_staff_NP_start_quarter__c = 6;
            qiDetail.No_staff_stopped_enrolled_nurse__c = 5;
            qiDetail.No_of_staff_employed_as_Enrolled_Nurse__c = 6;
            qiDetail.No_staff_stopped_personal_care_workers__c = 5;
            qiDetail.No_of_staff_PCW_start_quarter__c = 6;
            qiDetail.No_CR_IAD__c = 5;
            qiDetail.No_Care_Recipients_experienced_IAD__c = 5;
            qiDetail.No_CR_IAD_redness_without_infection__c = 5;
            qiDetail.No_CR_IAD_redness_with_infection__c = 5;
            qiDetail.No_CR_IAD_Skin_loss_without_infection__c = 5;
            qiDetail.No_CR_IAD_Skin_loss_with_infection__c = 5;
            qiDetail.No_CR_hospitalisation_Pres_assessment__c = 5;
            qiDetail.No_CR_hospitalisation_emerg_assessment__c = 5;
            qiDetail.No_Care_Recipients_diag_d_psychosis__c = 5;
            qiDetail.No_CR_Physical_Restrained_3Day__c = 5;
            qiDetail.No_CR_MBI_declined__c = 5;

            qiDetail.No_CR_proxy_completion_QOL_Moderate__c = 1;
            qiDetail.No_CR_proxy_completion_QOL_Poor__c = 1;
            qiDetail.No_CR_proxy_completion_QOL_VeryPoor__c = 1;
            qiDetail.No_CR_interviewer_admin_QOL_Moderate__c = 1;
            qiDetail.No_CR_interviewer_admin_QOL_Poor__c = 1;
            qiDetail.No_CR_interviewer_admin_QOL_VeryPoor__c = 1;
            qiDetail.No_care_recipients_offered_QOL_ACC__c = 9;
            qiDetail.No_CR_proxy_completion_CE_Moderate__c = 1;
            qiDetail.No_CR_proxy_completion_CE_Poor__c = 1;
            qiDetail.No_CR_proxy_completion_CE_VeryPoor__c = 1;
            qiDetail.No_CR_interviewer_admin_CE_Moderate__c = 1;
            qiDetail.No_CR_interviewer_admin_CE_Poor__c = 1;
            qiDetail.No_CR_interviewer_admin_CE_VeryPoor__c = 1;
            qiDetail.No_care_recipients_offered_QCE_ACC__c = 9;

            qiDetail.QI_Summary_Id__c = qiSummaryList[k].Id;
            qiDetailList.add(qiDetail);
            k = k++;
        }
        return qiDetailList;
    }

    public static List<ViolationType> createQIViolationType(
        Integer recordCount
    ) {
        List<ViolationType> qiListVType = new List<ViolationType>();
        for (Integer i = 0; i < recordCount; i++) {
            ViolationType qiVType = new ViolationType();
            qiVType.Name = 'Test Payment of Infringement notice' + i;
            qiVType.Type = 'Infringement';
            qiVType.Severity = 'Issue';
            qiVType.Service_Compliance_Rating_Effect__c = '3 Star';
            qiVType.Decision_Type_Effective_Date__c = System.today()
                .addDays(-5);
            qiVType.Decision_Type_Expiry_Date__c = qiVType.Decision_Type_Effective_Date__c.addDays(
                4
            );
            qiListVType.add(qiVType);
        }
        return qiListVType;
    }
    public static List<BusinessLicense> createQIServiceRecords(
        Integer RecordCount,
        List<Account> provider
    ) {
        List<BusinessLicense> serviceList = new List<BusinessLicense>();
        for (Integer i = 0; i < recordCount; i++) {
            BusinessLicense serv = new BusinessLicense();
            serv.Name = 'Service Test ' + i;
            serv.Care_Type__c = 'Residential';
            serv.AccountId = provider[i].id;
            serv.Status_Date__c = Date.today();

            serviceList.add(serv);
        }
        return serviceList;
    }
    // Created by Rami Zuhairi - SRQI team
    public static List<Care_Type__c> createSCRcareType(
        Integer recordCount,
        List<Account> provider
    ) {
        List<Care_Type__c> careTypeList = new List<Care_Type__c>();
        for (Integer i = 0; i < recordCount; i++) {
            Care_Type__c serv = new Care_Type__c();

            serv.RecordTypeId = Schema.SObjectType.Care_Type__c.getRecordTypeInfosByDeveloperName()
                .get('Approved_Provider_CT')
                .getRecordTypeId();
            serv.Care_Type__c = 'Residential';
            serv.Active__c = true;
            serv.Current_Approval_Status__c = 'Approved';
            serv.Account__c = provider[i].id;
            careTypeList.add(serv);
        }
        return careTypeList;
    }
    // Created by Rami Zuhairi - SRQI team
    public static List<BusinessLicense> createSCRServiceRecords(
        Integer recordCount,
        String serviceName,
        List<Account> provider,
        Integer noOfNonCurrRatingRegDecision,
        Integer countCurrentRegDec,
        Integer countArchRegDecision
    ) {
        List<BusinessLicense> serviceList = new List<BusinessLicense>();
        for (Integer i = 0; i < recordCount; i++) {
            BusinessLicense serv = new BusinessLicense();
            serv.Name = serviceName + ' ' + i;
            serv.RecordTypeId = Schema.SObjectType.BusinessLicense.getRecordTypeInfosByDeveloperName()
                .get('Approved_Provider_Service')
                .getRecordTypeId();
            serv.Care_Type__c = 'Residential';
            serv.Service_Care_Sub_Type__c = 'Residential';
            serv.Status__c = 'Operational';
            serv.Status_Date__c = Date.today();
            serv.Care_Type_Not_Approved__c = false;
            serv.NoOf_NonCurr_Rating_RegDecision__c = noOfNonCurrRatingRegDecision;
            serv.CountCurrentRegDec__c = countCurrentRegDec;
            serv.CountArchRegDecision__c = countArchRegDecision;
            serv.AccountId = provider[i].id;
            serviceList.add(serv);
        }
        return serviceList;
    }

    public static List<Account> createProviderRecords(Integer recordCount) {
        List<Account> providerList = new List<Account>();
        for (Integer i = 0; i < recordCount; i++) {
            Account acc = new Account();
            acc.Name = 'Test Provider ' + i;
            acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
                .get('Approved_Provider')
                .getRecordTypeId();
            acc.Type = 'ACN';
            acc.Incorporation_ID__c = '137083964';
            acc.Incorporation_Status__c = 'Registered';
            acc.Incorporation_Status_Date__c = System.today();
            acc.Incorporated_Under__c = 'Royal Charter';
            acc.Incorporation_Type__c = 'State Government';
            acc.Oracle_ID__c = 9999 + i;
            acc.Incorporation_ID_Type__c = 'ACN';
            acc.Prospective_Provider__c = '';

            providerList.add(acc);
        }
        return providerList;
    }

    public static List<Service_Account_Relationship__c> createServiceAccountRecords(
        Integer recordCount,
        List<BusinessLicense> services,
        list<Account> providers
    ) {
        List<Service_Account_Relationship__c> serviceAccountList = new List<Service_Account_Relationship__c>();
        for (Integer i = 0; i < recordCount; i++) {
            Service_Account_Relationship__c serviceAccount = new Service_Account_Relationship__c();
            serviceAccount.RecordTypeId = Schema.SObjectType.Service_Account_Relationship__c.getRecordTypeInfosByDeveloperName()
                .get('Provider_to_Service')
                .getRecordTypeId();
            serviceAccount.Provider_Name__c = providers[i].Id;
            serviceAccount.Service_Name__c = services[i].Id;
            serviceAccount.Association_Start_Date__c = Date.valueof(
                '2022-09-20'
            );
            serviceAccountList.add(serviceAccount);
        }
        return serviceAccountList;
    }

    // Created by Rami Zuhairi - SRQI team
    public static List<Service_Account_Relationship__c> createSCRserviceAccountRecords(
        Integer recordCount,
        List<BusinessLicense> services,
        list<Account> providers,
        Date associationStartDate,
        Date associationEndDate,
        Integer noOfNonCurrRatingRegDecision,
        Integer countCurrentRegDec,
        Integer countArchRegDecision
    ) {
        List<Service_Account_Relationship__c> serviceAccountList = new List<Service_Account_Relationship__c>();
        for (Integer i = 0; i < recordCount; i++) {
            Service_Account_Relationship__c serviceAccount = new Service_Account_Relationship__c();
            serviceAccount.RecordTypeId = Schema.SObjectType.Service_Account_Relationship__c.getRecordTypeInfosByDeveloperName()
                .get('Provider_to_Service')
                .getRecordTypeId();
            serviceAccount.Provider_Name__c = providers[i].Id;
            serviceAccount.Service_Name__c = services[i].Id;
            serviceAccount.Association_Start_Date__c = associationStartDate;
            serviceAccount.Association_End_Date__c = associationEndDate;
            serviceAccount.CurrentNonCurrentRegDec__c = noOfNonCurrRatingRegDecision;
            serviceAccount.CountCurrentRegDec__c = countCurrentRegDec;
            serviceAccount.CountArchRegDecision__c = countArchRegDecision;
            //serviceAccount.active__c=true;

            serviceAccountList.add(serviceAccount);
        }
        return serviceAccountList;
    }

    public static List<SRQI_CER__c> createCERRecords(
        Integer recordCount,
        List<Service_Account_Relationship__c> serviceAccounts,
        List<Account> providers,
        List<BusinessLicense> services,
        Reporting_Period__c reportingPeriod
    ) {
        List<SRQI_CER__c> cerList = new List<SRQI_CER__c>();
        for (Integer i = 0; i < recordCount; i++) {
            SRQI_CER__c cer = new SRQI_CER__c();
            //cer.Name = 'Test CER ' + i;
            cer.Service_Account__c = serviceAccounts[i].Id;
            cer.Provider__c = providers[i].Id;
            cer.Reporting_Period__c = reportingPeriod.Id;
            cer.Service__c = services[i].Id;
            cerList.add(cer);
        }
        return cerList;
    }

    public static List<SRQI_CEI__c> createCEIRecords(
        Integer recordCount,
        List<SRQI_CER__c> cers
    ) {
        List<SRQI_CEI__c> ceiList = new List<SRQI_CEI__c>();
        List<String> possibleResponse = new List<String>{
            'Never',
            'Some of the time',
            'Most of the time',
            'Always'
        };
        for (Integer i = 0; i < recordCount; i++) {
            Integer lastNum = Math.mod(i, 10);
            SRQI_CEI__c cei = new SRQI_CEI__c();
            //cei.Name = 'Test CEI ' + i;
            cei.CEI_Version_No__c = 1;
            cei.Consumer_Experience_Report__c = cers[lastNum].Id;
            cei.Food__c = possibleResponse[Integer.valueOf(4 * Math.random())];
            cei.Safety__c = possibleResponse[
                Integer.valueOf(4 * Math.random())
                ];
            cei.Operation__c = possibleResponse[
                Integer.valueOf(4 * Math.random())
                ];
            cei.Care_Need__c = possibleResponse[
                Integer.valueOf(4 * Math.random())
                ];
            cei.Competent__c = possibleResponse[
                Integer.valueOf(4 * Math.random())
                ];
            cei.Independent__c = possibleResponse[
                Integer.valueOf(4 * Math.random())
                ];
            cei.Explain__c = possibleResponse[
                Integer.valueOf(4 * Math.random())
                ];
            cei.Respect__c = possibleResponse[
                Integer.valueOf(4 * Math.random())
                ];
            cei.Follow_Up__c = possibleResponse[
                Integer.valueOf(4 * Math.random())
                ];
            cei.Caring__c = possibleResponse[
                Integer.valueOf(4 * Math.random())
                ];
            cei.Voice__c = possibleResponse[Integer.valueOf(4 * Math.random())];
            cei.Home__c = possibleResponse[Integer.valueOf(4 * Math.random())];
            cei.Best_Thing_About_This_Service__c = 'Food is great';
            cei.Consent_Status__c = 'Yes';
            cei.LOI__c = 100;
            cei.Improvement_At_This_Service__c = 'More hiphop';
            cei.CERINTERVIEWID__c = '1234457889';

            ceiList.add(cei);
        }
        return ceiList;
    }

    public static List<SRQI_Exemption__c> createCERExemptionRecords(
        Integer recordCount,
        List<BusinessLicense> services
    ) {
        List<SRQI_Exemption__c> cerExemptionList = new List<SRQI_Exemption__c>();
        for (Integer i = 0; i < recordCount; i++) {
            SRQI_Exemption__c cerExemptionRec = new SRQI_Exemption__c();
            cerExemptionRec.RecordTypeId = Schema.SObjectType.SRQI_Exemption__c.getRecordTypeInfosByDeveloperName()
                .get('CER_Exemption')
                .getRecordTypeId();
            cerExemptionRec.Service__c = services[i].Id;
            cerExemptionRec.Exemption_Start__c = System.today().addDays(-5);
            cerExemptionRec.Exemption_Finish__c = cerExemptionRec.Exemption_Start__c.addDays(
                4
            );
            cerExemptionList.add(cerExemptionRec);
        }
        return cerExemptionList;
    }

    public static List<SRQI_Exemption__c> createCMExemptionRecords(
        Integer recordCount,
        List<BusinessLicense> services
    ) {
        List<SRQI_Exemption__c> cmExemptionList = new List<SRQI_Exemption__c>();
        for (Integer i = 0; i < recordCount; i++) {
            SRQI_Exemption__c cmExemptionRec = new SRQI_Exemption__c();
            cmExemptionRec.RecordTypeId = Schema.SObjectType.SRQI_Exemption__c.getRecordTypeInfosByDeveloperName()
                .get('CM_Exemption')
                .getRecordTypeId();
            cmExemptionRec.Service__c = services[i].Id;
            cmExemptionRec.Exemption_Start__c = System.today().addDays(-5);
            cmExemptionRec.Exemption_Finish__c = cmExemptionRec.Exemption_Start__c.addDays(
                4
            );
            cmExemptionList.add(cmExemptionRec);
        }
        return cmExemptionList;
    }

    public static List<SRQI_Exemption__c> createQIExemptionRecords(
        Integer recordCount,
        List<BusinessLicense> services
    ) {
        List<SRQI_Exemption__c> qiExemptionList = new List<SRQI_Exemption__c>();
        for (Integer i = 0; i < recordCount; i++) {
            SRQI_Exemption__c qiExemptionRec = new SRQI_Exemption__c();
            qiExemptionRec.RecordTypeId = Schema.SObjectType.SRQI_Exemption__c.getRecordTypeInfosByDeveloperName()
                .get('QI_Exemption')
                .getRecordTypeId();
            qiExemptionRec.Service__c = services[i].Id;
            qiExemptionRec.Exemption_Start__c = System.today().addDays(-5);
            qiExemptionRec.Exemption_Finish__c = qiExemptionRec.Exemption_Start__c.addDays(
                4
            );
            qiExemptionList.add(qiExemptionRec);
        }
        return qiExemptionList;
    }

    public static List<SRQI_Exemption__c> createSCRExemptionRecords(
        Integer recordCount,
        List<BusinessLicense> services
    ) {
        List<SRQI_Exemption__c> scrExemptionList = new List<SRQI_Exemption__c>();
        for (Integer i = 0; i < recordCount; i++) {
            SRQI_Exemption__c scrExemptionRec = new SRQI_Exemption__c();
            scrExemptionRec.RecordTypeId = Schema.SObjectType.SRQI_Exemption__c.getRecordTypeInfosByDeveloperName()
                .get('SCR_Exemption')
                .getRecordTypeId();
            scrExemptionRec.Service__c = services[i].Id;
            scrExemptionRec.Exemption_Start__c = System.today().addDays(-5);
            scrExemptionRec.Exemption_Finish__c = scrExemptionRec.Exemption_Start__c.addDays(
                4
            );
            scrExemptionList.add(scrExemptionRec);
        }
        return scrExemptionList;
    }

    public static List<STAR_Rating_History__c> createStarRatingHistoryRecords(
        Integer recordCount,
        List<BusinessLicense> services,
        List<Account> providers,
        Reporting_Period__c rp
    ) {
        List<STAR_Rating_History__c> starHistoryRecords = new List<STAR_Rating_History__c>();
        for (Integer i = 0; i < recordCount; i++) {
            STAR_Rating_History__c starRec = new STAR_Rating_History__c();
            starRec.SF_Provider_Id__c = providers[i].Id;
            starRec.SF_Service_Id__c = services[i].Id;
            starRec.Reporting_Period__c = rp.Id;
            starRec.Rating_Type__c = 'Current Rating';
            starRec.Reason_for_release__c = 'This is for testing the data';
            starHistoryRecords.add(starRec);
        }
        return starHistoryRecords;
    }
    public static List<STAR_Rating_History__c> createStarRatingHistoryRecordsWithSAR(
        Integer recordCount,
        List<BusinessLicense> services,
        List<Account> providers,
        Reporting_Period__c rp,
        List<Service_Account_Relationship__c> sar

    ) {
        List<STAR_Rating_History__c> starHistoryRecords = new List<STAR_Rating_History__c>();
        for (Integer i = 0; i < recordCount; i++) {
            STAR_Rating_History__c starRec = new STAR_Rating_History__c();
            starRec.SF_Provider_Id__c = providers[i].Id;
            starRec.SF_Service_Id__c = services[i].Id;
            starRec.Reporting_Period__c = rp.Id;
            starRec.Service_Account_Relationship__c = sar[i].Id;
            starRec.Reason_for_release__c = 'This is for testing the data';
            starHistoryRecords.add(starRec);
        }
        return starHistoryRecords;
    }

    public static List<Care_Minutes_Summary__c> createCareMinuteSummary(
        Integer recordCount,
        List<BusinessLicense> serviceRecords
    ) {
        List<Care_Minutes_Summary__c> cmsList = new List<Care_Minutes_Summary__c>();
        for (Integer i = 0; i < recordCount; i++) {
            Care_Minutes_Summary__c cms = new Care_Minutes_Summary__c();
            cms.Service__c = serviceRecords[i].Id;
            cms.Availability_Status__c = 'Published';
            cms.Under_Review__c = (math.mod(i, 2) == 0);
            cmsList.add(cms);
        }
        return cmsList;
    }

    public static List<SRQI_Care_Minutes_Target__c> createCareMinuteTarget(
        Integer recordCount,
        List<BusinessLicense> serviceRecords,
        List<Care_Minutes_Summary__c> careMinutesSummaryRecords
    ) {
        List<SRQI_Care_Minutes_Target__c> cmtList = new List<SRQI_Care_Minutes_Target__c>();
        for (Integer i = 0; i < recordCount; i++) {
            SRQI_Care_Minutes_Target__c cmt = new SRQI_Care_Minutes_Target__c();
            cmt.Care_Minutes_Summary__c = careMinutesSummaryRecords[i].Id;
            cmt.Registered_Nurse_Care_Minutes_Target__c = 1000;
            cmt.Total_Care_Minutes_Target__c = 1000;
            cmt.Total_Nursing_Care_Minutes_Target__c = 1000;
            cmtList.add(cmt);
        }
        return cmtList;
    }

    public static List<Service_Compliance_History__c> createServiceComplianceHistory(
        Integer recordCount
    ) {
        List<Service_Compliance_History__c> schList = new List<Service_Compliance_History__c>();
        for (Integer i = 0; i < recordCount; i++) {
            Service_Compliance_History__c sch = new Service_Compliance_History__c();
            sch.Service_Compliance_Rating__c = math.mod(i, 2) == 0
                ? Integer.valueof((math.random() * 5))
                : 1;
            schList.add(sch);
        }
        return schList;
    }
    // Created by Rami Zuhairi - SRQI team
    public static List<Service_Compliance_History__c> createSCRServiceComplianceHistory(
        Integer recordCount,
        List<BusinessLicense> services,
        Integer ratingsNumber,
        String ratingType
    ) {
        List<Service_Compliance_History__c> schList = new List<Service_Compliance_History__c>();
        for (Integer i = 0; i < recordCount; i++) {
            Service_Compliance_History__c sch = new Service_Compliance_History__c();
            sch.Service_Compliance_Rating__c = ratingsNumber;
            sch.Service__c = services[i].Id;
            sch.Rating_Type__c = ratingType;
            schList.add(sch);
        }
        return schList;
    }

    public static List<Quality_Indicator_Summary__c> createQISummaryRecords(
        Integer recordCount,
        List<Account> providers,
        Reporting_Period__c rp,
        List<BusinessLicense> services,
        List<Service_Account_Relationship__c> serviceAccounts
    ) {
        List<Quality_Indicator_Summary__c> qisRecords = new List<Quality_Indicator_Summary__c>();
        for (Integer i = 0; i < recordCount; i++) {
            Quality_Indicator_Summary__c qis = new Quality_Indicator_Summary__c();
            qis.External_ID__c = 'ExternalId' + i;
            qis.PROVIDER_ID__c = providers[i].Id;
            qis.Reporting_Period__c = rp.Id;
            qis.Service__c = services[0].Id;
            qis.SERVICE_ACCOUNT_ID__c = serviceAccounts[0].Id;
            qisRecords.add(qis);
        }
        return qisRecords;
    }

    public static List<Quality_Indicator_Targets__c> createQITargetsRecords(
        Integer recordCount,
        Reporting_Period__c rp,
        List<BusinessLicense> services,
        List<Quality_Indicator_Summary__c> qisRecords
    ) {
        List<Quality_Indicator_Targets__c> qitRecords = new List<Quality_Indicator_Targets__c>();
        for (Integer i = 0; i < recordCount; i++) {
            Quality_Indicator_Targets__c qit = new Quality_Indicator_Targets__c();
            qit.Reporting_Period__c = rp.Id;
            qit.Service__c = services[i].Id;
            qit.Quality_Indicator_Summary__c = qisRecords[i].Id;
            qitRecords.add(qit);
        }
        return qitRecords;
    }

    public static List<Service_Compliance_History__c> createSCRRecords(
        Integer recordCount
    ) {
        List<Service_Compliance_History__c> scrRecords = new List<Service_Compliance_History__c>();
        for (Integer i = 0; i < recordCount; i++) {
            Service_Compliance_History__c scr = new Service_Compliance_History__c();
            scrRecords.add(scr);
        }
        return scrRecords;
    }

    public static List<RegulatoryCodeViolation> createQIRegulatoryCodeViolation(
        Integer recordCount,
        List<BusinessLicense> services,
        list<Account> providers,
        List<ViolationType> VType,
        List<Service_Account_Relationship__c> serviceAccounts
    ) {
        List<RegulatoryCodeViolation> qiListRCV = new List<RegulatoryCodeViolation>();
        for (Integer i = 0; i < recordCount; i++) {
            RegulatoryCodeViolation qiRCV = new RegulatoryCodeViolation();
            qiRCV.ViolationTypeId = VType[i].Id;
            qiRCV.Service_Name_lookup__c = services[i].Id;
            qiRCV.Service_Provider_Name__c = providers[i].Id;
            qiRCV.Decision_Details__c = 'Testing here data';
            qiRCV.Progress__c = 'Testing data';
            qiRCV.Status = 'Current';
            qiRCV.Reason_for_issuing_Regulatory_Decision__c = 'Testing data';
            qiRCV.Service_Account_Relationship__c = serviceAccounts[i].Id;
            qiRCV.Service_Provider_Name_lookup__c = providers[i].Id;
            qiRCV.Date_Decision_Applied__c = System.today().addDays(-5);
            qiRCV.DateCreated = System.today().addDays(-5);
            qiListRCV.add(qiRCV);
        }
        return qiListRCV;
    }

    public static List<Accreditation_Certification__c> createAccreditationCertification(
        Integer recordCount,
        List<BusinessLicense> services
    ) {
        List<Accreditation_Certification__c> accrCertList = new List<Accreditation_Certification__c>();
        for (Integer i = 0; i < recordCount; i++) {
            Accreditation_Certification__c accrCert = new Accreditation_Certification__c();
            accrCert.Service__c = services[i].Id;
            accrCert.Start_Date__c = Date.valueOf('2022-01-01');
            accrCert.End_Date__c = Math.mod(i, 2) == 0
                ? Date.valueOf('2025-04-01')
                : Date.valueOf('2023-01-01');
            accrCert.Accreditation_Type__c = 'Accreditation';
            accrCert.Accreditation_Status__c = 'Accredited';
            accrCert.Decision_Type__c = 'Record a Decision to Accredit';
            accrCert.Decision_Date__c = Date.valueOf('2022-08-31');
            accrCert.RecordTypeId = Schema.SObjectType.Accreditation_Certification__c.getRecordTypeInfosByDeveloperName()
                .get('Accreditation')
                .getRecordTypeId();
            accrCertList.add(accrCert);
        }
        return accrCertList;
    }
    // Created by Rami Zuhairi - SRQI team
    public static List<Accreditation_Certification__c> createSCRAccreditationCertification(
        Integer recordCount,
        List<BusinessLicense> services,
        Date accreditationStartDate,
        Date decisionDate
    ) {
        List<Accreditation_Certification__c> accrCertList = new List<Accreditation_Certification__c>();
        for (Integer i = 0; i < recordCount; i++) {
            Accreditation_Certification__c accrCert = new Accreditation_Certification__c();
            accrCert.Service__c = services[i].Id;
            accrCert.Start_Date__c = accreditationStartDate;
            accrCert.End_Date__c = accrCert.Start_Date__c.addMonths(36);
            accrCert.Accreditation_Type__c = 'Accreditation';
            accrCert.Accreditation_Status__c = 'Accredited';
            accrCert.Decision_Type__c = 'Record a Decision to Accredit';
            accrCert.Decision_Date__c = Date.valueOf('2022-08-31');
            accrCert.Accreditation_Decision_Date__c = decisionDate;
            accrCert.RecordTypeId = Schema.SObjectType.Accreditation_Certification__c.getRecordTypeInfosByDeveloperName()
                .get('Accreditation')
                .getRecordTypeId();
            accrCertList.add(accrCert);
        }
        return accrCertList;
    }
    //create GPMS Admin user with Health user profile
    public static User createGPMSTestUser() {
        String uniqueUserName =
            'GPMSAdminUser' +
            DateTime.now().getTime() +
            userName;
        //This code runs as the health user with GPMS System Admin Permission set
        Profile healthUsrProfile = [
            SELECT Id
            FROM Profile
            WHERE Name = 'Health User'
        ];
        Id userRoleId = [SELECT Id FROM UserRole WHERE Name = 'Health Staff']
            .Id;

        User usr = new User(
            Alias = 'GPMSUser',
            Email = 'GPMSUser@testorg.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = healthUsrProfile.Id,
            TimeZoneSidKey = sydenyTimeZone,
            UserName = uniqueUserName,
            UserRoleId = userRoleId
        );
        insert usr;
        PermissionSetGroup psg = [
            SELECT Id, DeveloperName, Status
            FROM PermissionSetGroup
            WHERE Developername = 'GPMS_System_Administrators'
        ];
        if (psg.Status != 'Updated') {
            Test.calculatePermissionSetGroup(psg.Id);
        }
        PermissionSetAssignment assignment = new PermissionSetAssignment(
            PermissionSetGroupId = psg.Id,
            AssigneeId = usr.Id
        );

        insert assignment;

        return usr;
    }
    //Create ACQSC User
    public static User createACQSCUser() {
        String uniqueUserName =
            'HealthUser' +
            DateTime.now().getTime() +
            userName;
        Profile healthUsrProfile = [
            SELECT Id
            FROM Profile
            WHERE Name = 'Health User'
        ];
        Id userRoleId = [SELECT Id FROM UserRole WHERE Name = 'Health Staff']
            .Id;

        User currentUser = new User(
            Alias = 'Health',
            Email = 'HealthUser@testorg.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = healthUsrProfile.Id,
            TimeZoneSidKey = sydenyTimeZone,
            UserName = uniqueUserName,
            UserRoleId = userRoleId
        );
        insert currentUser;
        PermissionSetGroup psg = [
            SELECT Id, DeveloperName, Status
            FROM PermissionSetGroup
            WHERE Developername = 'ACQSC_Users'
        ];
        if (psg.Status != 'Updated') {
            Test.calculatePermissionSetGroup(psg.Id);
        }
        PermissionSetAssignment assignment = new PermissionSetAssignment(
            PermissionSetGroupId = psg.Id,
            AssigneeId = currentUser.Id
        );

        insert assignment;
        return currentUser;
    }

    // create contact
    public static List<Contact> createContact(
        Integer recordCount,
        List<Account> providers
    ) {
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < recordCount; i++) {
            Contact testContact = new Contact();
            testContact.Salutation = 'Mr';
            testContact.FirstName = 'First Name' + i;
            testContact.LastName = 'Last Name';
            testContact.AccountId = providers[i].Id;
            testContact.Email = 'TestClassContact' + i + userName;
            contacts.add(testContact);
        }
        return contacts;
    }

    // create provider portal user
    public static List<User> createProviderPortalUser(
        Integer recordCount,
        List<Contact> providerContacts
    ) {
        Profile providerUsrProfile = [
            SELECT Id
            FROM Profile
            WHERE Name = 'Provider User'
        ];
        List<User> providerPortalUsers = new List<User>();
        for (Integer i = 0; i < recordCount; i++) {
            String uniqueUserName =
                'ProviderPortalTestClassUser' +
                i +
                Datetime.now().getTime() +
                userName;
            User usr = new User(
                ContactId = providerContacts[i].Id,
                Alias = 'pusr',
                Email = providerContacts[i].Email,
                EmailEncodingKey = 'UTF-8',
                LastName = providerContacts[i].LastName,
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                CommunityNickname = providerContacts[i].Id,
                ProfileId = providerUsrProfile.Id,
                TimeZoneSidKey = sydenyTimeZone,
                Username = uniqueUserName
            );
            providerPortalUsers.add(usr);
        }
        System.runAs([
            SELECT Id, Name, Email, Profile.Name, UserRole.Name
            FROM User
            WHERE Id = :UserInfo.getUserId()
        ][0]) {
            insert providerPortalUsers;
            PermissionSetGroup psg = [
                SELECT Id, DeveloperName, Status
                FROM PermissionSetGroup
                WHERE DeveloperName = 'Provider_Portal_Star_Rating_User'
            ];
            if (psg.Status != 'Updated') {
                Test.calculatePermissionSetGroup(psg.Id);
            }
            List<PermissionSetAssignment> assignments = new List<PermissionSetAssignment>();
            for (Integer i = 0; i < recordCount; i++) {
                PermissionSetAssignment assignment = new PermissionSetAssignment(
                    PermissionSetGroupId = psg.Id,
                    AssigneeId = providerPortalUsers[i].Id
                );
                assignments.add(assignment);
            }
            insert assignments;
        }
        return providerPortalUsers;
    }
    //Create Aco, Providers, Service, Contacts, Users and ACR for Manange Users
    public static Map<String, Object> manageUsersTestData() {
        string acoId = createACO();
        User orgAdmin = new User();
        List<String> providerIds = createProvider(acoId);
        List<Map<String, Object>> contactDetails = createContacts(
            acoId,
            providerIds
        );
        updateAcr(acoId);
        List<Map<String, String>> serviceAccountList = createServices(
            providerIds
        );
        createScr(acoId, serviceAccountList);
        orgAdmin = createUser(contactDetails);
        return new Map<String, Object>{
            'acoId' => acoId,
            'userId' => orgAdmin.id,
            'providerIds' => providerIds,
            'contactDetails' => contactDetails,
            'orgAdmin' => orgAdmin
        };
    }
    public static String createACO() {
        Account acoAccount = new Account();
        acoAccount.Name = 'Manage Users ACO account';
        acoAccount.GPMS_ProspectivePortalACO__c = true;
        acoAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Aged_Care_Organisation')
            .getRecordTypeId();
        insert (acoAccount);
        return acoAccount.Id;
    }
    public static List<String> createProvider(String acoId) {
        List<Account> providerAccounts = new List<Account>();
        Integer recordCount = 2;
        List<String> providerIds = new List<String>();
        for (Integer i = 0; i < recordCount; i++) {
            Account tempAccount = new Account();
            tempAccount.Name = 'Apex Test Provider ' + i;
            tempAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
                .get('Approved_Provider')
                .getRecordTypeId();
            tempAccount.ParentId = acoId;
            providerAccounts.add(tempAccount);
        }
        insert (providerAccounts);
        for (Account iterProviders : providerAccounts) {
            providerIds.add(iterProviders.id);
        }
        return providerIds;
    }
    public static List<Map<String, Object>> createContacts(
        String acoId,
        List<String> providerIds
    ) {
        List<Contact> contactsToCreate = new List<Contact>();
        List<Map<String, Object>> contactDetails = new List<Map<String, Object>>();
        integer count = 110;
        if (acoId != null) {
            Contact tempContact = new Contact();
            tempContact.Salutation = 'Mr';
            tempContact.FirstName = 'Test Class';
            tempContact.LastName = 'User' + count;
            tempContact.Email = 'TestClassUser_OrgAdmin@gmail.com';
            tempContact.GPMS_myGov_Vanguard_Id__c = 'TestClassUser_OrgAdmin@gmail.com';
            tempContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
                .get('GPMS_Contact')
                .getRecordTypeId();
            tempContact.AccountId = acoId;
            tempContact.IsPortalUser__c = true;
            tempContact.Birthdate = Date.valueOf('2000-11-02');
            contactsToCreate.add(tempContact);
        }
        for (String iterIds : providerIds) {
            Contact tempContact = new Contact();
            tempContact.Salutation = 'Mr';
            tempContact.FirstName = 'Test Class';
            tempContact.LastName = 'User' + count;
            tempContact.Email = 'TestClass_User' + count + '@gmail.com';
            tempContact.GPMS_myGov_Vanguard_Id__c =
                'TestClass_User' +
                count +
                '@gmail.com';
            tempContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
                .get('GPMS_Contact')
                .getRecordTypeId();
            tempContact.AccountId = iterIds;
            tempContact.IsPortalUser__c = true;
            tempContact.Birthdate = Date.valueOf('2000-11-02');
            contactsToCreate.add(tempContact);
            count++;
        }
        insert (contactsToCreate);
        for (contact iterContacts : contactsToCreate) {
            if (
                iterContacts.Account.recordType.DeveloperName ==
                    'Aged_Care_Organisation'
            ) {
                contactDetails.add(
                    new Map<String, Object>{
                        'firstName' => iterContacts.firstName,
                        'lastName' => iterContacts.lastName,
                        'email' => iterContacts.GPMS_myGov_Vanguard_Id__c,
                        'contactId' => iterContacts.Id,
                        'isOrgAdmin' => true
                    }
                );
            } else {
                contactDetails.add(
                    new Map<String, Object>{
                        'firstName' => iterContacts.firstName,
                        'lastName' => iterContacts.lastName,
                        'email' => iterContacts.GPMS_myGov_Vanguard_Id__c,
                        'contactId' => iterContacts.Id,
                        'isOrgAdmin' => false
                    }
                );
            }
        }
        return contactDetails;
    }

    public static void updateAcr(string acoId) {
        List<AccountContactRelation> acrToUpdate = [
            SELECT Id, Account.RecordType.DeveloperName, Roles
            FROM AccountContactRelation
            WHERE Account.ParentId = :acoId OR AccountId = :acoId
        ];
        for (AccountContactRelation iterAcr : acrToUpdate) {
            if (
                iterAcr.Account.RecordType.DeveloperName ==
                    'Aged_Care_Organisation'
            ) {
                iterAcr.roles = 'Organisation administrator';
            } else {
                iterAcr.roles = 'Star Rating Reviewer - Service';
            }
        }
        update (acrToUpdate);
    }
    public static User createUser(List<Map<String, Object>> contactDetails) {
        List<User> usersToCreate = new List<User>();
        User orgAdminUser = new User();
        Profile orgAdmin = [
            SELECT Id
            FROM profile
            WHERE name = :'Org Admin'
            LIMIT 1
        ];
        Profile providerUser = [
            SELECT Id
            FROM profile
            WHERE name = :'Provider User'
            LIMIT 1
        ];
        for (Map<String, Object> iterContactMap : contactDetails) {
            User tempUser = new User();
            tempUser.FirstName = (String) iterContactMap.get('firstName');
            tempUser.LastName = (String) iterContactMap.get('lastName');
            tempUser.Email = (String) iterContactMap.get('email');
            tempUser.Alias =
                tempUser.firstName.left(1) + tempUser.lastName.left(4);
            tempUser.Username =
                tempUser.Alias +
                '_' +
                (String) iterContactMap.get('email');
            tempUser.federationIdentifier = (String) iterContactMap.get(
                'email'
            );
            if ((Boolean) iterContactMap.get('isOrgAdmin')) {
                tempUser.ProfileId = orgAdmin.Id;
            } else {
                tempUser.ProfileId = providerUser.Id;
            }
            tempUser.TimeZoneSidKey = 'Australia/Sydney';
            tempUser.LocaleSidKey = 'en_AU';
            tempUser.LanguageLocaleKey = 'en_US';
            tempUser.EmailEncodingKey = 'UTF-8';
            tempUser.ContactId = (String) iterContactMap.get('contactId');
            tempUser.IsActive = true;
            tempUser.CommunityNickname =
                tempUser.Alias +
                '_' +
                tempUser.federationIdentifier;
            usersToCreate.add(tempUser);
        }

        try {
            insert usersToCreate;
        } catch (DmlException exp) {
            dohagedcare.Logger.error(exp.getMessage(), exp, 'GPMS').Log();
        }
        for (User iterUsers : usersToCreate) {
            if (iterUsers.ProfileId == orgAdmin.Id) {
                orgAdminUser = iterUsers;
            }
        }
        return orgAdminUser;
    }
    public static List<Map<String, String>> createServices(
        List<String> providerIds
    ) {
        List<BusinessLicense> servicesToCreate = new List<BusinessLicense>();
        List<Map<String, String>> returnMap = new List<Map<String, String>>();
        Integer count = 323;
        for (String iterId : ProviderIds) {
            for (Integer i = 0; i < 3; i++) {
                BusinessLicense tempService = new BusinessLicense();
                tempService.Name = 'Test Class Service' + count;
                tempService.status = 'Operational';
                tempService.Care_Type__c = 'Residential';
                tempService.Care_Type_Not_Approved__c = false;
                tempService.AccountId = iterId;
                tempService.Status_Date__c = Date.today();
                servicesToCreate.add(tempService);
                count++;
            }
        }
        try {
            insert servicesToCreate;
        } catch (DmlException exp) {
            dohagedcare.Logger.error(exp.getMessage(), exp, 'GPMS').Log();
        }
        for (BusinessLicense iterService : servicesToCreate) {
            returnMap.add(
                new Map<String, String>{
                    'serviceId' => iterService.id,
                    'accountId' => iterService.accountid
                }
            );
        }
        return returnMap;
    }
    public static void createScr(
        String acoId,
        List<Map<String, String>> serviceAccountMap
    ) {
        List<Contact> getContacts = [
            SELECT Id, accountId
            FROM contact
            WHERE account.parentId = :acoId
        ];
        List<Contact_Relationship__c> scrToCreate = new List<Contact_Relationship__c>();
        String scrRecordTypeId = Schema.SObjectType.Contact_Relationship__c.getRecordTypeInfosByDeveloperName()
            .get('SCR')
            .getRecordTypeId();
        for (Contact iterCont : getContacts) {
            for (Map<String, String> iterMap : serviceAccountMap) {
                if (iterCont.accountId == iterMap.get('accountId')) {
                    Contact_Relationship__c tempScr = new Contact_Relationship__c();
                    tempScr.Contact__c = iterCont.Id;
                    tempScr.Service__c = iterMap.get('serviceId');
                    tempScr.Role__c = 'Star Rating Service - Reviewer';
                    tempScr.RecordTypeId = scrRecordTypeId;
                    scrToCreate.add(tempScr);
                }
            }
        }
        try {
            insert scrToCreate;
        } catch (DmlException exp) {
            dohagedcare.Logger.error(exp.getMessage(), exp, 'GPMS').Log();
        }
    }
    public static void creatPSA(String assigneIds) {
        List<Org_Switcher_Mapping__mdt> switcherMapping = [
            SELECT
                id,
                DeveloperName,
                AccountRecordType__c,
                PermissionSet__c,
                Permission_Set_Group_Developer_Name__c,
                Role__c
            FROM Org_Switcher_Mapping__mdt
        ];
        Set<String> portalUserPermissionSets = new Set<String>();
        Set<String> portalUserPermissionSetGroups = new Set<String>();
        List<PermissionSetAssignment> permissionAssignment = new List<PermissionSetAssignment>();
        for (Org_Switcher_Mapping__mdt sm : switcherMapping) {
            if (
                sm.PermissionSet__c != null &&
                sm.AccountRecordType__c != null
            ) {
                portalUserPermissionSets.add(sm.PermissionSet__c);
            } else if (
                sm.Permission_Set_Group_Developer_Name__c != null &&
                sm.Role__c != null
            ) {
                portalUserPermissionSetGroups.add(
                    sm.Permission_Set_Group_Developer_Name__c
                );
            }
        }
        List<PermissionSet> userPermissionSet = [
            SELECT id
            FROM PermissionSet
            WHERE Name IN :portalUserPermissionSets
        ];
        List<PermissionSetGroup> userPermissionSetGroup = [
            SELECT id, Status
            FROM PermissionSetGroup
            WHERE DeveloperName IN :portalUserPermissionSetGroups
        ];

        for (PermissionSet ps : userPermissionSet) {
            PermissionSetAssignment tempPSA = new PermissionSetAssignment();
            tempPSA.AssigneeId = assigneIds;
            tempPSA.PermissionSetId = ps.Id;
            permissionAssignment.add(tempPSA);
        }
        for (PermissionSetGroup psg : userPermissionSetGroup) {
            if (psg.Status == 'Updated') {
                PermissionSetAssignment tempPSA = new PermissionSetAssignment();
                tempPSA.AssigneeId = assigneIds;
                tempPSA.PermissionSetGroupId = psg.Id;
                permissionAssignment.add(tempPSA);
            }
        }
        insert (permissionAssignment);
    }

    public static List<Allotment__c> createAllotments(Integer recordCount, List<BusinessLicense> services) {
        List<Allotment__c> allotments = new List<Allotment__c>();
        for (BusinessLicense service : services) {
            for (Integer i = 0; i < recordCount; i++) {
                Allotment__c allot = new Allotment__c();
                allot.Service_Name__c = service.Id;
                allotments.add(allot);
            }
        }
        return allotments;
    }

    public static List<Places_Allotment__c> createPlacesAllotments(Integer recordCount, List<Allotment__c> allotments) {
        List<Places_Allotment__c> placesAllotments = new List<Places_Allotment__c>();
        for (Allotment__c allotment : allotments) {
            for (Integer i = 0; i < recordCount; i++) {
                Places_Allotment__c placesAllotment = new Places_Allotment__c();
                placesAllotment.Number_of_Places__c = 4;
                placesAllotment.Status_of_Places__c = 'Operational';
                placesAllotment.Current__c = 'Yes';
                placesAllotment.Allotment__c = allotment.Id;
                placesAllotment.Oracle_ID__c = i;
                placesAllotments.add(placesAllotment);
            }
        }
        return placesAllotments;
    }
}
