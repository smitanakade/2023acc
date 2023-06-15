@isTest
public class GPMSStreetStringFormatTest {
    
    @isTest static void testGPMSStreetStringFormatreplace() {
        
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap = new Map<String,Object>();
        Map<String,Object> options = new Map<String,Object>();
        
        inputMap.put('type','ACO');
        
        String testStreet1 = '3 Barangaroo Ave, Barangaroo, Sydney, New South Wales, AUS, 2000';
        String testStreet2 = '161 Collins St, Melbourne, victoria, 3000, AUS';
        String testStreet3 = '10 Eagle St, Brisbane, queensland, 4000, AUS';
        String testStreet4 = '8 Angas St, Kent Town, south australia,5067, AUS';
        String testStreet5 = '2 The Esplanade, Perth, western australia, 6000, OT';
        String testStreet6 = '198 Charles St, Launceston, tasmania, 7250, AUS';
        String testStreet7 = '1 Knuckey St, Darwin City, northern territory, 0800';
        String testStreet8 = '55 Wentworth Ave, Kingston, australian capital territory, 2604, AUS';
        String testStreet9 = '2604, Wentworth Ave,Kingston, australian capital territory, AUS';
        
        String[] inputList = new String[]{testStreet1,testStreet2,testStreet3,testStreet4,testStreet5,testStreet6,testStreet7,testStreet8,testStreet9};
        inputMap.put('arguments',inputList);
            
        Map<String, Object> args = new Map<String, Object>();
        args.put('input', inputMap);
        args.put('output', outMap);
        args.put('options', options);
        
        GPMSStreetStringFormat getGroupList = new GPMSStreetStringFormat();
        Object result = getGroupList.call('replace',args);
        
    }
}