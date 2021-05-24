@isTest
public class SchedulerUpdateProductListPriceTest {
	
    @isTest static void testBatchScheduler(){
        
        Test.StartTest();
        SchedulerBatchUpdateProductListPrice scheduleBatch = new SchedulerBatchUpdateProductListPrice();
        String sch = '0 0 23 * * ?'; 
        system.schedule('Test',sch,scheduleBatch);
        Test.stopTest(); 
    }
    
}