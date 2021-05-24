public class SchedulerBatchUpdateProductListPrice implements Schedulable{
    
    public void execute(SchedulableContext SC) {
        
       BatchUpdateProductListPrice job = new BatchUpdateProductListPrice();
       Database.executeBatch(job,200); 
   }
    
}