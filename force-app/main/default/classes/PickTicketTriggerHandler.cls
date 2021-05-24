public class PickTicketTriggerHandler {
    public static boolean runTrigger = true;
    
    public static void handleAfterUpdateEvent(){
        Savepoint sp = Database.setSavepoint();
        //PickTicketTriggerHandler.runTrigger = false;
        Set<Id> closedPickTicketIds = new Set<Id>();
        try{
            system.debug('trigger callled');
            for(Pick_Ticket__c pt :(List<Pick_Ticket__c>)trigger.new){
                //Pick_Ticket__c oldPt = (Pick_Ticket__c)trigger.oldMap.get(pt.id);
                
                //system.debug('pt.Status__c==>'+pt.Status__c);
                //system.debug('oldPt==>'+oldPt);
                if(pt.Status__c == 'Closed' && !pt.Status_Closed__c){
                    closedPickTicketIds.add(pt.Id);
                    PickTicketTriggerHandler.runTrigger = false;
                }
            }
            //system.debug('closedPickTicketIds==>'+closedPickTicketIds);
            if(!closedPickTicketIds.isEmpty() && closedPickTicketIds.size() > 0){
                List<Pick_Ticket_Line_Item__c> ptLineItems = [SELECT Id,Product__c,Quantity__c,Line_Type__c
                                                              FROM Pick_Ticket_Line_Item__c 
                                                              WHERE Pick_Ticket__r.Id IN : closedPickTicketIds];
                
                system.debug('ptLineItems==>'+ptLineItems);
                MAP<Id,Decimal> productVsPtLineItemQauntity;
                if(!ptLineItems.isEmpty() && ptLineItems.size() > 0){
                    productVsPtLineItemQauntity = new MAP<Id,Decimal>();  
                    
                    for(Pick_Ticket_Line_Item__c ptLineItem : ptLineItems){
                        if(ptLineItem.Line_Type__c == 'S - Stock Inventory Item'){
                            if(productVsPtLineItemQauntity.get(ptLineItem.Product__c)!=null)
                                productVsPtLineItemQauntity.put(ptLineItem.Product__c,productVsPtLineItemQauntity.get(ptLineItem.Product__c) +ptLineItem.Quantity__c);
                            else 
                                productVsPtLineItemQauntity.put(ptLineItem.Product__c,ptLineItem.Quantity__c);
                        }
                    }
                    //system.debug('productVsPtLineItemQauntity==>'+productVsPtLineItemQauntity);
                    if(!productVsPtLineItemQauntity.isEmpty()){
                        List<Product2> products = [SELECT Id,Quantity_Reserved__c,Quantity__c
                                                   FROM Product2
                                                   WHERE Id IN: productVsPtLineItemQauntity.keyset()];
                        List<Product2> updateProducts = new List<Product2>();
                        //system.debug('products==>'+products);
                        if(!products.isEmpty() && products.size() > 0){
                            for(Product2 prod : products){
                                if(productVsPtLineItemQauntity.containsKey(prod.Id)){
                                    Decimal quantity = productVsPtLineItemQauntity.get(prod.Id);
                                    if(prod.Quantity_Reserved__c > 0){
                                        prod.Quantity_Reserved__c = (prod.Quantity_Reserved__c - quantity) >= 0 ? prod.Quantity_Reserved__c - quantity : 0;              
                                    }
                                    if(prod.Quantity__c > 0){
                                        prod.Quantity__c = (prod.Quantity__c - quantity) >= 0 ? prod.Quantity__c - quantity : 0;              
                                    }
                                    
                                    updateProducts.add(prod);
                                }
                            }
                            
                            if(!updateProducts.isEmpty())
                                Database.update(updateProducts);
                            
                        }
                        
                    }
                    
                }
                List<Pick_Ticket__c> updatePickTickets = [SELECT Id,Status_Closed__c 
                                                          FROM Pick_Ticket__c                                                                 
                                                          WHERE Id IN: closedPickTicketIds];
                
                for(Pick_Ticket__c pt :updatePickTickets){
                    if(!pt.Status_Closed__c){
                        pt.Status_Closed__c = true;
                    }
                }
                Database.update(updatePickTickets);
            }
        }catch(exception ex){
            
            system.debug('error==>'+ex);      
            Database.rollback(sp);            
            List<String> errList = new List<String>();
            errList.add(ex.getMessage());
            errList.add(ex.getStackTraceString());                 
            sendErrorNotificationToAdmin(errList);  
            
        }
    }
    
    public static void sendErrorNotificationToAdmin(List<String> errList){
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        List<User> userEmail = [SELECT Email FROM User WHERE Profile.Name = 'System Administrator'];
        List<String> sendTo = new List<String>();
        for(User u : [SELECT Email FROM User WHERE Profile.Name = 'System Administrator']){
            sendTo.add(u.Email);
        }
        
        String sub = 'Error in PickTicket closed trigger : '+system.today();
        String plainBody = 'Hi there,\n\n';
        plainBody += 'PickTicket closed trigger encountered below errors.\n';
        
        if(!errList.isEmpty()) {
            plainBody += '\n\nError List: \n';
            for(Integer i=0; i<errList.size(); i++) {
                plainBody += ' '+(i+1)+'.  '+errList[i]+'. \n';
            }           
        }        
        
        mail.setToAddresses(sendTo);
        mail.setSubject(sub); 
        mail.setPlainTextBody(plainBody);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}