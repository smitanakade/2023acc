@IsTest
public class QFRTestDataFactory {

    // Function to make health user for testing
    public static TestUserBuilder getHealthProviderBuilder(){
        List<PermissionSet> permissionSets = [SELECT Id FROM PermissionSet WHERE Name IN ('QFR_Report_Create_Update_and_Submit')];
        PermissionSetLicense PermissionSetLicenses = [SELECT Id FROM PermissionSetLicense WHERE PermissionSetLicenseKey = 'PublicSectorAccessPSL'];
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'VS Administrator'].Id;
        TestUserBuilder healthProviderBuilder = new TestUserBuilder();
        healthProviderBuilder.setUserProfile(profileId);
        healthProviderBuilder.setDoInsert(true);
        healthProviderBuilder.setPermissionSets(permissionSets);
        healthProviderBuilder.setPermissionSetLicenses(new List<PermissionSetLicense> {permissionSetLicenses});
        return healthProviderBuilder;
    } 

}