/*****************************************
    Programmer:     Tony Williams
    Company:        Awana
    Contact:        tonyw@awana.org
    Project:        Batch Delete Stuck Woo Orders
    Description:    batch Apex Scheduler to do cleanup of struck WOO Orders open more than 10 minutes.
    Original:       08/31/2018
        -- Execute Batch -- 
    BatchDeleteStuckWooOrdersScheduler job = new BatchDeleteStuckWooOrdersScheduler(); ID batchprocessid = Database.executeBatch(job, 1); 
 *****************************************/

global class BatchDeleteStuckWooOrdersScheduler implements Schedulable{
   global void execute(SchedulableContext SC) {
       BatchDeleteStuckWooOrders job = new BatchDeleteStuckWooOrders();
       ID batchprocessid = Test.isRunningTest() ? Database.executeBatch(job, 100) : Database.executeBatch(job, 10);
   }

}