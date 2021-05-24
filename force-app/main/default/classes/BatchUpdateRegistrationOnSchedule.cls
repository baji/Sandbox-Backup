global class BatchUpdateRegistrationOnSchedule implements Schedulable{
   global void execute(SchedulableContext SC) 
   {
       BatchUpdateRegistrationObject job = new BatchUpdateRegistrationObject();
       ID batchprocessid = Database.executeBatch(job, 100);
   }
}