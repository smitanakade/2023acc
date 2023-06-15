/* Author: Nick Parsons
   Date Created: 3/10/22
   User Sotry: 233634
   Revision History: */

global with sharing class OmniDeclarationFileDownload implements Callable{
    
    public static String getFileUrl() {
        // Get the URl for the static resource
        String fileName = 'DeclarationTestFile';
        String staticUrl = Pagereference.forResource(fileName).getUrl();

        // Remove the extra stuff from the URL
        List<String> bothStrings = staticUrl.split('aura');
        String staticShortUrl = bothStrings[0];

        // Get the base URL for the page
        String siteUrl = Site.getBaseSecureUrl();

        // Combine the URLs
        String fullUrl = siteUrl + staticShortUrl;

        // Return the final URL
        return fullUrl;
    }


    global Object call(string action, Map<String, Object> args) {
        Map<String, Object> input = (Map<String, Object>)args.get('input');
        Map<String, Object> output = (Map<String, Object>)args.get('output');
        Map<String, Object> options = (Map<String, Object>)args.get('options');
        switch on action {
            when 'getFileUrl' {
                String declarationUrl = getFileUrl();
                output.put('fileUrl', declarationUrl);
                return true;
            }
            when else {
                throw new ExtensionMalformedException('Method not implemented');
            }
        }
    }
    public class ExtensionMalformedException extends Exception {}
}