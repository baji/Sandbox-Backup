/*
Purpose - Trigger to handle all operations which happens after update. 
code of OpportunityAfterUpdate trigger which was on Opportunity has been merged in this code as well. 
Author - Darshan Chhajed.
Updated: 04-06-2018 - <NMM-17> - (TW) Updated code so that registration_product__c  will contan both new Membership and Mozo levels.
Updated: 06-13-2018 - <ASP-874,990,1018,ASP-177> - (TW) Checked for Line Item Downloadables.
Updated: 07-05-2018 - <ASP-1206> - If we delete a Membership/MOZO line item in Sales Force (OE) then update it's Parent Order's Registration Product Field to remove the 'R1' and or M1-M4 indicator.Updated: 07-06-2018  - <ASP-1206> - Trigger to handle all operations which happens after delete as well.
Updated: 07-17-2018 - <ASP-1221> - Baji: Added code to update 'Product Weight' on OrderItem record using Product weight.
Updated: 07-25-2018 - <ASP-1233> - Tony: Updating the previous fix 1221 to quickly calulate product weight.
*/
trigger UpdateOrder on OrderItem (before insert, after insert, after Update, after delete) {
    if(Trigger.isUpdate || Trigger.isInsert){
        list<Order> ordersToBeUpdated  =  new list<Order>();
        map<Id,list<OrderItem>> orderToOrderItemMap = new map<Id,list<OrderItem>>();
        map<Id,String> orderItemToProductCode = new map<Id,String>();
        map<Id,Id> prodcutToOrderItemMap = new map<Id,Id>();
        Set<Id> OrderHasDownloads = new Set<Id>();
        boolean updateOrdersFlag = false;
        system.debug('Trigger.New**'+Trigger.New);
        for(OrderItem item : Trigger.New){
            //Code to update the Total Product Weight on OrderProduct item (no.of items * weight of the product)....
            // ... but first we have to get the Product Weight of the order product (line item: Total weight of the product / no.of items) since Product Weight is null.
            if (Trigger.isBefore) {
                item.Product_Weight__c = item.Temp_Product_Weight__c / item.Quantity;
                system.debug('<< ITEM PRODUCT WEIGHT >> '+item);
            }
            
            //Check for Downloadables
            if(item.PricebookEntryId !=null && item.Product2Id != null){
                prodcutToOrderItemMap.put(item.Product2Id,item.Id); 
                system.debug('<< UPDATE ORDER -  DOWNLOADABLE FOUND >> '+item.Order.Number_of_Downloadable_Items__c);
                system.debug('<< UPDATE ORDER -  DOWNLOADABLE FOUND >> '+item.Downloadable_Product_URL__c);
                system.debug('<< UPDATE ORDER -  TEST  FOUND >> '+item.Test__c);
                system.debug('<< UPDATE ORDER -  PRODUCT CODE  FOUND >> '+item.Product2.ProductCode);
                system.debug('<< UPDATE ORDER -  OPPORTNITY SOURCE >> '+item.Order.Opportunity_Source__c);
                // This following IF condtion isonly for Order Entry Customer Service since Woo already sets the Has Downloadable field to true.
                if(item.Downloadable_Product_URL__c != null && item.Downloadable_Product_URL__c !=''){
                    OrderHasDownloads.add(item.OrderId);
                }
                if(orderToOrderItemMap.containsKey(item.OrderId))
                    orderToOrderItemMap.get(item.OrderId).add(Item);
                else{
                    list <OrderItem> lst = new list<OrderItem>();
                    lst.add(Item);
                    orderToOrderItemMap.put(item.OrderId,lst);
                }
            }   
        }//Loop
        list<Order> downloadOrders = new list<Order>();
        if(OrderHasDownloads.size() > 0){
            downloadOrders = [SELECT Id, Has_Downloads__c  from Order where Id in: OrderHasDownloads];
            for(Order someOrder : downloadOrders){
                someOrder.Has_Downloads__c = true;
            }
            if(downloadOrders.size() > 0){
                update downloadOrders;
            }
        }
        system.debug('prodcutToOrderItemMap**'+prodcutToOrderItemMap);
        list<Product2> products  = [SELECT Id, ProductCode FROM Product2 WHERE Id IN :prodcutToOrderItemMap.KeySet()];
        for(Product2 Prod : products){
            system.debug('*Prod.ProductCode'+Prod.ProductCode);
            orderItemToProductCode.put(prodcutToOrderItemMap.get(Prod.Id),Prod.ProductCode);
        }
        system.debug('**orderItemToProductCode**'+orderItemToProductCode);
        system.debug('**orderToOrderItemMap**'+orderToOrderItemMap);
        if(orderToOrderItemMap.size()>0){
            ordersToBeUpdated  = [SELECT Id,Registration_Product__c FROM Order WHERE Id IN :orderToOrderItemMap.KeySet() Limit 10000];
            system.debug('**ordersToBeUpdated**'+ordersToBeUpdated);
   
            for(Order ord : ordersToBeUpdated){
                //ord.Registration_Product__c =null;
                for(OrderItem oItem : orderToOrderItemMap.get(ord.Id)){
                    system.debug('**ord.Registration_Product__c**'+ord.Registration_Product__c);
                    system.debug('**orderItemToProductCode.get(oItem.Id)**'+orderItemToProductCode.get(oItem.Id));
                    system.debug('**Upgrade_Level__c**'+oItem.Upgrade_Level__c);
                    if(orderItemToProductCode.get(oItem.Id) =='70001' && Ord.Registration_Product__c == null)
                    {   system.debug('<< WE ORDERED R1 [UPDATEORDER TRIGGER] >>');
                        ord.Registration_Product__c ='R1';
                    }else{
                        if(orderItemToProductCode.get(oItem.Id) =='70001' && Ord.Registration_Product__c != null && Ord.Registration_Product__c.length() <=3 && !Ord.Registration_Product__c.contains('R1')) {
                            ord.Registration_Product__c =ord.Registration_Product__c+'R1';
                        }
                    }
           
                    if(oItem.Upgrade_Level__c!=null ||  orderItemToProductCode.get(oItem.Id) =='70011' ||orderItemToProductCode.get(oItem.Id) =='70012' || orderItemToProductCode.get(oItem.Id) =='70013' || orderItemToProductCode.get(oItem.Id) =='70014'){ /* Workflow - TR -Registration Product Purchased*/
                        if(orderItemToProductCode.get(oItem.Id) =='70011' )  // If R1 already exists inside then append this to the end
                        {   
                   
                            if(ord.Registration_Product__c != null && ord.Registration_Product__c !=''){
                                system.debug('<< OK WE ARE IN IF FOR REG PROD  70011 +>> '+ord.Registration_Product__c);
                                if(ord.Registration_Product__c.contains('R1') && (ord.Registration_Product__c.length() < 4 )){
                                    ord.Registration_Product__c = ord.Registration_Product__c + 'M1';
                                }
                            }else{  
                                    ord.Registration_Product__c = 'M1';
                                    system.debug('<< OK WE ARE IN ELSE FOR REG PROD  70011 +>> '+ord.Registration_Product__c);
                            }//ELSE
                   
                        }
                        else if(orderItemToProductCode.get(oItem.Id) =='70012')
                        {
                            if(ord.Registration_Product__c != null && ord.Registration_Product__c !=''){
                                system.debug('<< OK WE ARE IN IF FOR REG PROD  70012 +>> '+ord.Registration_Product__c);
                                if(ord.Registration_Product__c.contains('R1') && (ord.Registration_Product__c.length() < 4 )){
                                    ord.Registration_Product__c = ord.Registration_Product__c + 'M2';
                                }
                            }else{  
                                    ord.Registration_Product__c = 'M2';
                                    system.debug('<< OK WE ARE IN ELSE FOR REG PROD  70012 +>> '+ord.Registration_Product__c);
                            }//ELSE
                        }
                        else if(orderItemToProductCode.get(oItem.Id) =='70013')
                        {
                            if(ord.Registration_Product__c != null && ord.Registration_Product__c !=''){
                                system.debug('<< OK WE ARE IN IF FOR REG PROD  70013 +>> '+ord.Registration_Product__c);
                                if(ord.Registration_Product__c.contains('R1') && (ord.Registration_Product__c.length() < 4 )){
                                    ord.Registration_Product__c = ord.Registration_Product__c + 'M3';
                                }
                            }else{  
                                ord.Registration_Product__c = 'M3';
                                system.debug('<< OK WE ARE IN ELSE FOR REG PROD  70013 +>> '+ord.Registration_Product__c);
                            }//ELSE
                        }
                        else if(orderItemToProductCode.get(oItem.Id) =='70014')
                        {
                            if(ord.Registration_Product__c != null && ord.Registration_Product__c !=''){
                                system.debug('<< OK WE ARE IN IF FOR REG PROD  70014 +>> '+ord.Registration_Product__c);
                                if(ord.Registration_Product__c.contains('R1') && (ord.Registration_Product__c.length() < 4 )){
                                    ord.Registration_Product__c = ord.Registration_Product__c + 'M4';
                                }
                            }else{  
                                    ord.Registration_Product__c = 'M4';
                                    system.debug('<< OK WE ARE IN ELSE FOR REG PROD  70014 +>> '+ord.Registration_Product__c);
                            }//ELSE
                        }
                        else 
                        {
                            system.debug('<< OK WE ARE IN ELSE FOR REG PROD >> '+ord.Registration_Product__c);
                            if(ord.Registration_Product__c != null && ord.Registration_Product__c !=''){
                                if(ord.Registration_Product__c.contains('R1') && (ord.Registration_Product__c.length() < 4 )){
                                    ord.Registration_Product__c = ord.Registration_Product__c + 'U' + oItem.Upgrade_Level__c;
                                }
                            }else{
                                ord.Registration_Product__c = 'U' + oItem.Upgrade_Level__c;  
                            }
                        }
                    } //IF   
                }// INner For
            }// end of for
            update ordersToBeUpdated; 
        }   
    }
//* If isDelete - <ASP-1136-1206> If we delete a Membership/MOZO line item in Sales Force (OE) then update it's Parent Order's Registration Product Field to remove the 'R1' and or M1-M4 indicator.
if(Trigger.isDelete){
        Map<Id,String> whatWasOrderedMap = new Map<Id,String>();
        //1) Go through List of deleted line items which are Membership or Mozo and save their Characer Codes into a list
        Map<Id,Product2> someProduct = new Map<Id,Product2>([Select Id,ProductCode from Product2 where ProductCode in ('70001','70011','70012','70013','70014','70005')]);
        
        system.debug('<<SOME PRODUCT >>'+someProduct);
        if(someProduct.size() > 0){
            for(OrderItem item : Trigger.old){
                Product2 aProduct = someProduct.get(item.Product2Id);
                if(aProduct != null){
                    if(aProduct.ProductCode == '70001'){
                        whatWasOrderedMap.put(item.OrderId,'R1');
                    }
                    if(aProduct.ProductCode == '70011'){
                        whatWasOrderedMap.put(item.OrderId,'M1');
                    }
                    if(aProduct.ProductCode == '70012'){
                        whatWasOrderedMap.put(item.OrderId,'M2');
                    }
                    if(aProduct.ProductCode == '70013'){
                        whatWasOrderedMap.put(item.OrderId,'M3');
                    }
                    if(aProduct.ProductCode == '70014'){
                        whatWasOrderedMap.put(item.OrderId,'M4');
                    }
                     if(aProduct.ProductCode == '70005'){
                        whatWasOrderedMap.put(item.OrderId,'U');
                    }
                    system.debug('<< ProductCode >> '+aProduct.ProductCode);
                    system.debug('<< OrderId >> '+item.OrderId);
                    system.debug('<< What Was ordred>> '+ whatWasOrderedMap);
                }
            }//2) Update the Registration Product field of the parent Order removing any trace of 'R1' from its registration Product field.
            if(whatWasOrderedMap.size() > 0){
                List<Order> OrdersToUpdate = new List<Order>();
                List<Order> OrdersRemovedMembership = [Select Id,Registration_Product__c From Order WHERE Id in:whatWasOrderedMap.keySet() ];
                for(Order someOrder : OrdersRemovedMembership){
                    String getCode = whatWasOrderedMap.get(someOrder.Id); 
                    system.debug('<< FOUND UPGRADE - U? >> '+getCode );
                    Integer spaces = 0;
                    if(getCode != 'U'){
                        spaces = 2;
                    }else{
                        spaces = 3;
                    }
                    Integer pos;
                    if(someOrder.Registration_Product__c != null){
                        pos = someOrder.Registration_Product__c.indexOf(whatWasOrderedMap.get(someOrder.Id));
                    }
                    if(pos==0){
                        system.debug('<< POS = 0 SUBSTRING  >> '+someOrder.Registration_Product__c.substring(spaces,someOrder.Registration_Product__c.length()));
                        someOrder.Registration_Product__c = someOrder.Registration_Product__c.substring(spaces,someOrder.Registration_Product__c.length());
                        OrdersToUpdate.add(someOrder); 
                        system.debug('<< ORDERS TO UPDATE >> '+OrdersToUpdate);
                    }
                    if(pos>0){
                        someOrder.Registration_Product__c =  someOrder.Registration_Product__c.substring(0,someOrder.Registration_Product__c.length() - spaces);
                        OrdersToUpdate.add(someOrder);
                    }
                
                }//FOR
                if(OrdersToUpdate.size() > 0){
                    update OrdersToUpdate;
                }
            } // whatrwasorderedmap > 0
        }// someProduct IF
    }// Trigger Delete                                                             
}