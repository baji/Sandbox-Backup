//this test class cover the ProcessOrderAmountBatchService batch used to update the old production Account data with Order Amount Summary
@isTest(seeAllData=true)
public class ProcessOrderAmountBatchServiceTest{

    @isTest
    public static void testBatch(){
        String accIds = '';
        List<Order> orderThisFY = [SELECT AccountId FROM ORDER WHERE Status !='Order Open' AND Order_Created_Date__c = THIS_FISCAL_YEAR LIMIT 1];
        
        if(!orderThisFY.isEmpty()){
            accIds += '\''+orderThisFY[0].AccountId +'\'';
        }
        
        List<Order> orderLastFY = [SELECT AccountId FROM ORDER WHERE Status !='Order Open' AND Order_Created_Date__c = LAST_FISCAL_YEAR LIMIT 1];
        if(!orderLastFY.isEmpty()){
            if(String.isNotBlank(accIds))
                accIds +=',';
            accIds += '\''+orderLastFY[0].AccountId +'\'';
        }   
        String q; 
        if(String.isNotBlank(accIds))
            q = 'SELECT id, Order_Amount_Summary__c, Previous_FY_Order_Summary__c, Current_FY_Order_Summary__c ,Order_Summary_Updated_Date__c FROM Account WHERE ID IN ('+accIds+')';
        else{
            q = 'SELECT id, Order_Amount_Summary__c, Previous_FY_Order_Summary__c, Current_FY_Order_Summary__c,Order_Summary_Updated_Date__c  FROM Account WHERE ID IN (SELECT AccountID FROM Order WHERE Status !=\'Order Open\')';
        }
        //SchedulerProcessOrderAmountBatchService scBath = new SchedulerProcessOrderAmountBatchService();
        //scBath.query = q;
        ProcessOrderAmountBatchService batch = new ProcessOrderAmountBatchService();
        batch.qry = q;
        Test.startTest();
        Database.executeBatch(batch,200);
        
        String sch ='0 48 * * * ?'; 
        System.schedule('ProcessOrderAmountBatchService',sch ,batch);
        Test.stopTest();
        
        
    }
}