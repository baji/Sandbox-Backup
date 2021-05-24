global class BatchProductQuantityReservedScheduler implements Schedulable{
     global void execute(SchedulableContext SC) {
       //BatchProductQuantityReserved2 job = new BatchProductQuantityReserved2();
       //BatchProductQuantityReserved1 job = new BatchProductQuantityReserved1();
       BatchProductQuantityReserved job = new BatchProductQuantityReserved();
       ID batchprocessid = Test.isRunningTest() ? Database.executeBatch(job, 100) : Database.executeBatch(job, 100);
   }
}