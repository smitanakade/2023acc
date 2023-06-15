public class GPMSValidation {
    @invocableMethod
    public static List<String> validateABN(List<String> abnNumber) {
        List<String> result = new List<String>();
        Integer sum = 0;
        String abn;
        final List<Integer> abnWeighting = new List<Integer> {10,1,3,5,7,9,11,13,15,17,19};
        if (abnNumber[0].contains(',')) {
            abn = abnNumber[0].remove(',');  
        }
        else {
            abn = abnNumber[0];
        }        
        String check;        
        If (abn.length() == 11) {
            list<String> abnToList = abn.split('');
            integer remainder;
            for(integer count = 0;count <= 10; count++) {
                if(count == 0) {
                    sum = sum + (Integer.valueOf(abnToList[count])-1)*abnWeighting[count];
                }
                else {
                    sum = sum + Integer.valueOf(abnToList[count])*abnWeighting[count];
                }                
            }
            remainder = Math.mod(sum, 89);
            if(remainder==0) {
                check = 'Ok';
            } 
            else {
                check ='Invalid';
            }
        }
        else {
            check ='Invalid';
        }
        result.add(check);
        return result;
    }
}