global class BatchProductQuantityReserved implements Database.Batchable<sObject>,Database.AllowsCallouts, Database.Stateful{
    
    global String query; 
    global set<string> OrderNos = new set<string>();
    
    //Constructor
    global BatchProductQuantityReserved(){
        system.debug('BatchProductQuantityReserved Constructor');
    }
 
    //Start - BEGIN
    global database.querylocator start(Database.BatchableContext BC){
       
        if(query == null){
            query  = 'SELECT Id, Name,Quantity_Reserved__c,PSI_Status_Indicator__c'
                +' FROM Product2 '
                +'where (PSI_Status_Indicator__c = \'1\' or PSI_Status_Indicator__c = \'2\' or PSI_Status_Indicator__c = \'3\')'
                +' And (IsActive = true)';
        }
        if(Test.isRunningTest() ){
            query = query + ' LIMIT 100';
        }
        return Database.getQueryLocator(query);
    }
    //Start - END
    
    //Execute - BEGIN
    global void execute(Database.BatchableContext BC, List<Product2> products) { 
        system.debug('execute method');
        
        Map<Id,Decimal> orderItemVsProductMap = new Map<Id,Decimal>();
        List<Product2> productList = new List<Product2>();
        Decimal reservedQuantity = 0.0;
                
        for(product2 p: products){
            List<OrderItem> stockOLIs = [SELECT Id,Quantity,Order.Status,OrderId,Product2.ProductCode,Product2Id,Line_Type__c,PreOrder_Backorder_Handling__c,Quantity_Fillable__c,Quantity_Backordered__c,Quantity_Given_Away__c,PricebookEntry.Product2.ProductCode,UnitPrice,PricebookEntry.Product2.Name FROM OrderItem WHERE Product2Id=:p.Id AND (Line_Type__c like 'S - Stock Inventory Item%') and (Order.Status ='Order Being Fulfilled' or Order.Status = 'Order Partially Invoiced' or Order.Status ='Order Confirmed' or Order.Status ='Order Submitted') AND Order.Payment_Terms__c != 'Sales Credit'];               
                        
                for(OrderItem ordItem : stockOLIs){
                        if(p.Id == ordItem.Product2Id){
                            if(ordItem.Order.Status == 'Order Partially Invoiced'){
                                if(ordItem.Quantity_Backordered__c > 0 || ordItem.Quantity_Fillable__c > 0){
                                    reservedQuantity = reservedQuantity + ordItem.Quantity_Backordered__c + ordItem.Quantity_Fillable__c;                                    
                                }
                            }
                            else{
                                reservedQuantity = reservedQuantity + ordItem.Quantity;
                            }
                        }//ProductId If   
                    }//OrderItems Loop
                    
                    system.debug('Final Res Qua = '+reservedQuantity);
                    p.Quantity_Reserved__c = reservedQuantity;
                    reservedQuantity = 0.0;
                    productList.add(p);
                    system.debug('Product List Size:'+productList.size());
                    if(!productList.isEmpty()){
                        update productList;
                        system.debug('********'+productList[0]);
                    }
            }//For products                      
    }//Excute - End
    
    //Finish
    global void finish(Database.BatchableContext BC){
       system.debug('Finish method');
        AsyncApexJob apexBatchResult = [
            SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob
            WHERE Id =: BC.getJobId()
        ];
    
        // Generate email body
        String emailBody = 'Batch to Update Product Quantity Reserved is processed '
            + apexBatchResult.TotalJobItems + ' batches with '+ apexBatchResult.NumberOfErrors + ' failures.\n\n';
         
        
         //3. Get User Ids for the SF Admins. They are the only ones that should be getting email.         
          Map<Id,User> users = new Map<Id, User>([SELECT Id, Email FROM User WHERE UserRole.name = 'System Administrator' 
                                                  AND IsActive = true]);
            
            
            List<String> userEmail = new List<String>();
            //We need to make sure that the Test coverage will work when testing emails otherwise a REQUIRED_FIELD_MISSING, Missing exception will occur.
            if(Test.isRunningTest()){
                User tUser=[Select Email from User where Name Like 'MyAwana%' Limit 1];
                userEmail.add(tUser.Email);
            }else{
                for(User someUser : users.values()){
                    userEmail.add(someUser.Email); 
                }
            }
            List<String> sendTo = new List<String>();
            sendTo.addAll(userEmail);

        // Send email
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(sendTo);
        mail.setSenderDisplayName('Product Quantity Reserved Update Batch Results');
        mail.setSubject('Batch to Remove Stuck WOO Orders: ' + apexBatchResult.Status);
        mail.setPlainTextBody('Updating Quantity Reserved for Products has completed\n\n' + emailBody);

        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
       system.debug('Batch process to update product quantity is completed');
    }
}