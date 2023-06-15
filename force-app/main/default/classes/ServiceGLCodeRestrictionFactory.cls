public with sharing class ServiceGLCodeRestrictionFactory {
    /** 
     * Replaces the custom metadata type query with a list of restrictions defined in a test class.
     */
    @TestVisible
    private static List<Service_GL_Code_Restriction__mdt> testRestrictions = new List<Service_GL_Code_Restriction__mdt>();

    public static List<Service_GL_Code_Restriction__mdt> getRestrictions(Set<String> serviceCategories) {
        // return testRestrictions if specified, otherwise run as normal 
        if (Test.isRunningTest() && testRestrictions.size() != 0) {
            return testRestrictions;
        }
        
        return [SELECT Id, Service_Category__c, Restriction_Type__c, GL_Code__c,Summary_only__c FROM Service_GL_Code_Restriction__mdt WHERE Service_Category__c IN :serviceCategories];
    }
}