global class BatchProductQuantityReserved4 implements Database.Batchable<sObject>,Database.AllowsCallouts, Database.Stateful{
    
    global String query; 
    global set<string> OrderNos = new set<string>();
    global List<Product2> productList = new List<Product2>();
    
    //Constructor
    global BatchProductQuantityReserved4(){
        system.debug('BatchProductQuantityReserved Constructor');
    }
 
    //Start - BEGIN
    global database.querylocator start(Database.BatchableContext BC){
       
        if(query == null){
            query  = 'SELECT Id, Name,'
                +'Company__c,Estimated_Weight__c,Billing_Email__c,Payment_Terms__c,'
                +'AccountId, Account.Name, OrderNumber, Status, TotalAmount, CreatedDate, CreatedById, CreatedBy.Name,'
                +'HasOrderLineItem__c, LastModifiedDate, LastModifiedById, LastModifiedBy.Name, TotalOrderQuantity__c,'
                +'Total_Pick_Quantity__c, Inventory_Items__c, Non_inventory_Items__c, Error_Log__c,Order.NG_Shipment_ID__c'
                +' FROM Order '
                +'where (Status = \'Order Submitted\' or Status = \'Order Awaiting Payment\' or Status = \'Order on Hold\' or Status = \'Order Confirmed\' or Status = \'Order Partially Invoiced\' or Status = \'Order Being Fulfilled\')'
                +' And (Payment_Terms__c != \'Sales Credit\')';
                
        }
        if(Test.isRunningTest() ){
            query = query + ' LIMIT 200';
        }
        return Database.getQueryLocator(query);
    }
    //Start - END
    
    //Execute - BEGIN
    global void execute(Database.BatchableContext BC, List<Order> orders) { 
        system.debug('execute method');
        
        List<OrderItem> stockOLIs = [SELECT Id,Quantity,Order.Status,OrderId,Product2.ProductCode,Product2Id,Line_Type__c,PreOrder_Backorder_Handling__c,Quantity_Fillable__c,Quantity_Backordered__c,Quantity_Given_Away__c,PricebookEntry.Product2.ProductCode,UnitPrice,PricebookEntry.Product2.Name FROM OrderItem WHERE (Line_Type__c like 'S - Stock%') and Order.Id in: orders];  
                //system.debug('Stock list size:'+stockOLIs.size());                
                Map<Id,Decimal> orderItemVsProductMap = new Map<Id,Decimal>();
                Decimal reservedQuantity = 0.0;
                for(OrderItem ordItem : stockOLIs){
                    orderItemVsProductMap.put(ordItem.Product2Id,ordItem.Quantity);
                }
                if(!orderItemVsProductMap.isEmpty()){
                    List<Product2> pList = [SELECT Id,Quantity_Reserved__c FROM Product2 WHERE Id IN: orderItemVsProductMap.keySet()];
                    if(!pList.isEmpty()){
                        for(Product2 prod : pList){
                            for(OrderItem ordItem : stockOLIs){
                            //system.debug(ordItem.Order.Status);
                                if(prod.Id == ordItem.Product2Id){
                                    if(ordItem.Order.Status == 'Order Partially Invoiced'){
                                        if(ordItem.Quantity_Backordered__c > 0 || ordItem.Quantity_Fillable__c > 0){
                                            reservedQuantity = reservedQuantity + ordItem.Quantity_Backordered__c + ordItem.Quantity_Fillable__c;                                    
                                        }
                                    }
                                    else{
                                        reservedQuantity = reservedQuantity + ordItem.Quantity;
                                    }
                                }    
                            }
                                system.debug('Final Res Qua = '+reservedQuantity);
                                prod.Quantity_Reserved__c = reservedQuantity;
                                reservedQuantity = 0.0;
                                productList.add(prod);
                            }
                        }
                        system.debug('Product List Size:'+productList.size());                                        
                }                            
                
                if(!productList.isEmpty()){
                    update productList;
                    system.debug('********'+productList[0]);
                }
                        
    }
    
    //Finish
    global void finish(Database.BatchableContext BC){
       system.debug('Finish method');
       system.debug('Batch process to update product quantity is completed');
    }
}