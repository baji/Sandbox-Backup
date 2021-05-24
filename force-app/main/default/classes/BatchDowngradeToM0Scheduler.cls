/*****************************************
    Programmer:     Tony Williams
    Company:        Awana
    Contact:        tonyw@awana.org
    Description:    batch Apex Scheduler to do cleanup of delinquent Mozo Levels which should be set to M0 when Mozo Expiration Date <= Today. 
    Original:       08/5/2016
        -- Execute Batch -- 
    BatchDowngradeToM0Scheduler job = new BatchDowngradeToM0Scheduler(); ID batchprocessid = Database.executeBatch(job, 1); 
 *****************************************/

global class BatchDowngradeToM0Scheduler implements Schedulable{
     global void execute(SchedulableContext SC) {
       BatchDowngradeToM0 job = new BatchDowngradeToM0();
       ID batchprocessid = Test.isRunningTest() ? Database.executeBatch(job, 10) : Database.executeBatch(job, 10);
   }
}