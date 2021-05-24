/*****************************************
    Programmer:   Baji Shaik
    Company:      Awana
    Contact:      shaikbaji.a@ecgroup-intl.com
    Project:       Mozo Free Trail
    Description:  batch Apex Scheduler to push Affiliation to Demandware.
    Original:     08/18/2016
        -- Execute Batch -- 
     
 *****************************************/

global class BatchAffiliationSchedule implements Schedulable{
   global void execute(SchedulableContext SC) 
   {
       BatchUpdateAffiliationToDemandware job = new BatchUpdateAffiliationToDemandware();
       ID batchprocessid = Database.executeBatch(job, 10);
   }
}