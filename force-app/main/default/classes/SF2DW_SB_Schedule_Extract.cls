public with sharing class SF2DW_SB_Schedule_Extract implements Schedulable {
    public void execute(SchedulableContext ctx) {
// Note : The input dates DO NOT over-ride the Reporting Period Parameter 
//        These dates are only used to contrain extract batch sizes WITHIN a Reporting Period



ID batchprocessid = Database.executeBatch(new SF2DW_SB_BatchExtract(), 100);


    }
}