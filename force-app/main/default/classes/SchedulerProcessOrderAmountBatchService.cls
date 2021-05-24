public class SchedulerProcessOrderAmountBatchService implements Schedulable{
  
    Public String query;
  
    public void execute(SchedulableContext SC) {
       
        
       ProcessOrderAmountBatchService job = new ProcessOrderAmountBatchService(query);
       Database.executeBatch(job,200); 
   
   }   
}