public class OrderTriggerHandler{
    
    public static Boolean runTest = false; //This is only for Test class use.
    
    public static void handleAfterUpdateEvent(){
        
        //MR-1 Changes. By : Urvashi Dagara        
        List<order> orderList = new List<order>();
        List<Product2> productList = new List<Product2>(); //MR-2         
        for(Order o :(List<Order>)trigger.new){
            Order oldOrder = (Order)trigger.oldMap.get(o.id);             
            if(oldOrder.Status != 'Order Submitted' && o.Status == 'Order Submitted' && o.Status != 'Order Confirmed' && o.Status != 'Order Being Fulfilled'){
                orderList.add(o);
            }//IF

            //MR-2 : Order Cancel process
            if((oldOrder.Status == 'Order Submitted' || oldOrder.Status == 'Order Confirmed' || oldOrder.Status == 'Order Being Fulfilled') && o.status == 'Order Cancelled' && (o.Payment_Terms__c!=null && o.Payment_Terms__c!='PrePay' && o.Payment_Terms__c!='Payment to be Collected' && o.Payment_Terms__c!='Sales Credit' && o.Payment_Terms__c!='Sales Credit - Refunded')){
                system.debug('Inside Order Cancelled');
                List<OrderItem> stockOLIs = [SELECT Id, Quantity,OrderId,Product2.ProductCode,Product2Id,Line_Type__c,PreOrder_Backorder_Handling__c,Quantity_Given_Away__c,PricebookEntry.Product2.ProductCode,UnitPrice,PricebookEntry.Product2.Name FROM OrderItem WHERE (Line_Type__c like 'S - Stock%') and OrderId =: o.Id];  
                system.debug('Stock list size:'+stockOLIs.size());                
                Map<Id,Decimal> orderItemVsProductMap = new Map<Id,Decimal>();
                for(OrderItem ordItem : stockOLIs){
                    orderItemVsProductMap.put(ordItem.Product2Id,ordItem.Quantity);
                }
                if(!orderItemVsProductMap.isEmpty()){
                    List<Product2> pList = [SELECT Id,Quantity_Reserved__c FROM Product2 WHERE Id IN: orderItemVsProductMap.keySet()];
                    if(!pList.isEmpty()){
                        for(Product2 prod: pList){
                            if(orderItemVsProductMap.containsKey(prod.id) ){
                                prod.Quantity_Reserved__c = prod.Quantity_Reserved__c - orderItemVsProductMap.get(prod.id);
                                productList.add(prod);
                            }
                        }
                        system.debug('Product List Size:'+productList.size());                                         
                    }                            
                }
            }//If end - Order Cancel
        }//For
        
        if(!orderList.isEmpty())
            postOrderSubmitted(orderList);
        
        //MR-2 DML
        if(!productList.isEmpty()){
            update productList;
        }
    }
    
    public static void postOrderSubmitted(List<Order> orderList){
        set<Id> orderIds = new set<Id>();
        String Status;
        Set<Id> AccountIds = new Set<Id>();
        Map<Id,Account> AccountMap = new Map<Id,Account>();
        for(Order o : OrderList)
            AccountIds.add(o.AccountId);
        if(AccountIds.size()>0)
            AccountMap=new Map<Id, Account>([Select id,Account_On_Hold__c,Sales_Tax_Exemption_Hold__c from Account where id IN: AccountIds]);
        for(Order o : orderList){
            if(o.Payment_Terms__c!='Payment to be Collected' && o.Payment_Terms__c!='Sales Credit' && o.Payment_Terms__c!='Sales Credit - Refunded'){
                if((String.isNotBlank(o.AccountId) && (AccountMap.get(o.AccountId).Account_On_Hold__c || AccountMap.get(o.AccountId).Sales_Tax_Exemption_Hold__c)) || runTest){
                    orderIds.add(o.id);
                    Status = 'Order On Hold';
                }else{
                    orderIds.add(o.id);
                }
            }
        }
        if(!orderIds.isEmpty() && String.isNotBlank(Status)){
            updateOrderStatus(Status,orderIds);
        }else if (!orderIds.isEmpty()){
            updateOrderStatus(orderIds);
        }
        
    }
    
    
    
    Public static void updateOrderStatus(String status,Set<Id> orderIds){
        
        List<Order> orderUpdateList = new List<Order>();
        if(!orderIds.isEmpty()){
            For(Order o : [SELECT Id,Status,Order_Submitted__c 
                           FROM Order 
                           WHERE Id IN:orderIds]){
                               o.Status = String.isNotBlank(Status) ?Status : 'Order On Hold';            
                               orderUpdateList.add(o);
                               o.Order_Submitted__c=Datetime.now();
                           }
            if(!orderUpdateList.isEmpty()){
                update orderUpdateList;
            }
        }
    }
    
    Public static void updateOrderStatus(Set<Id> orderIds){
        
        List<Order> orderUpdateList = [SELECT Id,Status,Order_Hold__c,Payment_Terms__c,Order_Submitted__c 
                                       FROM Order 
                                       WHERE Id IN: orderIds];
        
        List<OrderItem> orderItemList = [SELECT Id,Quantity,Product2Id 
                                         FROM OrderItem 
                                         WHERE OrderId IN: orderIds
                                         AND Line_Type__c = 'S - Stock Inventory Item'];  
        
        List<String> ordrerIdList = new  List<String>();  
        system.debug('orderItemList--'+orderItemList);
        List<Product2> productUpdatetList = new List<Product2>();
        if(!orderItemList.isEmpty()){
            Map<Id,Decimal> orderItemVsProductMap = new Map<Id,Decimal>();
            for(OrderItem ordItem : orderItemList){
                orderItemVsProductMap.put(ordItem.Product2Id,ordItem.Quantity);
            }
            if(!orderItemVsProductMap.isEmpty()){
                List<Product2> productList = [SELECT Id,Quantity_Reserved__c 
                                              FROM Product2 
                                              WHERE Id IN: orderItemVsProductMap.keySet()];
                system.debug('productList--'+productList);
                if(!productList.isEmpty()){
                    for(Product2 prod: productList){
                        if(orderItemVsProductMap.containsKey(prod.id) ){
                            system.debug('prod.Quantity_Reserved__c---'+prod.Quantity_Reserved__c);
                            prod.Quantity_Reserved__c = prod.Quantity_Reserved__c +  orderItemVsProductMap.get(prod.id);
                            system.debug('prod.Quantity_Reserved__c---'+prod.Quantity_Reserved__c);
                            productUpdatetList.add(prod);
                        }
                    }
                    
                    /* Anvesh - Moved this section after the OrderItemList loop as the code should be independent of OrderItems
for(order o :orderUpdateList){
o.status = 'Order Confirmed';
o.Order_Hold__c = false; 
IDHelper ih = new IDHelper(o.Id);
ordrerIdList.add(JSON.serialize(ih));

}
Savepoint sp = Database.setSavepoint();
try{      
system.debug('productUpdatetList--'+productUpdatetList);
if(!productUpdatetList.isEmpty())
update productUpdatetList;

if(!orderUpdateList.isEmpty()){
update orderUpdateList;
if(!System.isFuture() && !System.isBatch()){ 
system.debug('calling PostShipmentRequest');
PostShipmentRequest.postOrders(ordrerIdList);
}
}
}catch(exception e){
Database.rollback(sp);   
system.debug('exception--'+e);
}   */
                }                            
            }            
        } //OrderItemList
        for(order o :orderUpdateList){
            if(o.Payment_Terms__c!=null && o.Payment_Terms__c!='PrePay' && o.Payment_Terms__c!='Payment to be Collected' && o.Payment_Terms__c!='Sales Credit' && o.Payment_Terms__c!='Sales Credit - Refunded'){
                o.status = 'Order Confirmed';
                o.Order_Hold__c = false; 
                IDHelper ih = new IDHelper(o.Id);
                o.Order_Submitted__c=Datetime.now();
                ordrerIdList.add(JSON.serialize(ih));
            }
        }
        Savepoint sp = Database.setSavepoint();
        try{      
            system.debug('productUpdatetList--'+productUpdatetList);
            if(!productUpdatetList.isEmpty())
                update productUpdatetList;
            if(!orderUpdateList.isEmpty()){
                system.debug('ordrerIdList--'+ordrerIdList);
                update orderUpdateList;
                if(!System.isFuture() && !System.isBatch() && !ordrerIdList.isEmpty()){ 
                    system.debug('calling PostShipmentRequest');
                    PostShipmentRequest.postOrders(ordrerIdList);
                }
            }
        }catch(exception e){
            Database.rollback(sp);   
            system.debug('exception--'+e);
        }
    }
    
    /*public static void handleAfterInsertEvent(){
        List<order> orderList = new List<order>(); 
        for(Order o :(List<Order>)trigger.new){             
            if(o.status == 'Order Submitted' && o.Status != 'Order Confirmed' && o.Status != 'Order Being Fulfilled'){
                orderList.add(o);
            }//IF
        }//FOR
        
        if(!orderList.isEmpty())
            postOrderSubmitted(orderList);
        
    }*/
    
    
    /* For Future purpose.


public static void handleBeforeUpdateEvent(){

}

public static void handleBeforeInsertEvent(){

}
*/
}