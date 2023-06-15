@isTest()
public class Test_SFDW_SB_Batch_Extract {
@isTest (SeeAllData=True)
    public static void SF2DW_SB_Batch_ExtractTest(){
  
    Test.startTest();  
        SF2DW_SB_BatchExtract SB = new SF2DW_SB_BatchExtract();
Database.executeBatch(SB);
   
       Test.stopTest();
}
}