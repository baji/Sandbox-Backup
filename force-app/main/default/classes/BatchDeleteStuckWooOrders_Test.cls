/*********************************************************************************************************
    Programmer:         Tony W.
    Company:            Awana/ EC Group
    Contact:            tonyw@awana.org
    Project:            Testing Batch Delete Stuck Woo Ticlets
    Original:          8/24/2018- Used to Test delete  bWoo orders in Order Open STatus.   
 ***********************************************************************************************************/ 
 

@isTest(SeeAllData=true)
public class BatchDeleteStuckWooOrders_Test {
    static testMethod void CreateStuckOrder_TestMethod (){
        User woo = [Select Id,Name from User Where Name = 'WooCommerce'];
        
       
        //Create Order from COrder
    
       	List<Order> stuckOrders = [Select Id,LastModifiedDate,Status,Name From Order  WHERE Opportunity_Source__c = 'Awana Store' And CreatedBy.Name='WooCommerce'  limit 2];
        system.debug('<< STUCK ORDER  >> '+stuckOrders);
        for(Order o : stuckOrders){
            if(o.Status != 'Order Open'){
                o.Status = 'Order Open';
            }
        }
        update stuckOrders;
        system.debug('<< STUCK ORDERS >> '+stuckOrders);
        
        //Now set up or Batch script job.
        Datetime dtRemove10Minutes = system.now().addSeconds(-600); // We want the lastDate MOdified to be < 10 minutes from now.
        BatchDeleteStuckWooOrders batchObj = new BatchDeleteStuckWooOrders();
        String  query 
            = 'Select Id,LastModifiedDate,Status,Name,Opportunity_Source__c  '
            + 'From Order  WHERE Opportunity_Source__c  = \'Awana Store\' '
            + 'And CreatedBy.Name=\'WooCommerce\' '
            + ' And Status = \'Order Open\' ';
        batchObj.query = null;
        Test.startTest();
          Database.executeBatch(batchObj,200);
        Test.stopTest();

    }
}