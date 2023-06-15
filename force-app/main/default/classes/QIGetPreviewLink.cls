/**
* @author: AG
* @date: 29/04/2023
* @description: Utility class for generating preview link 
* @Test Class  : QIGetPreviewLinkTest.cls
 */


public with sharing class QIGetPreviewLink {
    
    @AuraEnabled
    public static string getLink(String parentRecID, String attachmentID){

        dohagedcare.FilePreviewUtility.PreviewResponseWrapper downloadResponse = dohagedcare.FilePreviewUtility.getFilePreviewDetailsExt(parentRecID, attachmentID);
        return downloadResponse.response;
        
    }

    
}