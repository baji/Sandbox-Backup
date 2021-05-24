/*****************************************
    Programmer:     Tony Williams
    Company:        Awana
    Contact:        tonyw@awana.org
    Project:        Batch End Mozo Free Trial
    Description:    batch Apex Scheduler to do cleanup of delinquent Mozo Free Trial Accounts which should be cancelled due to end date expiration.
    Original:       08/5/2016
        -- Execute Batch -- 
    BatchEndMozoFreeTrialSchedule job = new BatchEndMozoFreeTrialSchedule(); ID batchprocessid = Database.executeBatch(job, 1); 
 *****************************************/

global class BatchEndMozoFreeTrialSchedule implements Schedulable{
   global void execute(SchedulableContext SC) 
   {
       BatchEndMozoFreeTrialAccounts job = new BatchEndMozoFreeTrialAccounts();

       ID batchprocessid = Test.isRunningTest() ? Database.executeBatch(job, 100) : Database.executeBatch(job, 10);
   }
}