global class BatchSearchWBShipmentsScheduler implements Schedulable, Database.AllowsCallouts{
 global void execute(SchedulableContext SC) 
   {
       BatchSearchWBShipments job = new BatchSearchWBShipments();
       ID batchprocessid = Test.isRunningTest() ? Database.executeBatch(job, 100) : Database.executeBatch(job, 10);
   }
}