/*
Purpose - A batch which wil create OrderItem from migrated opportunityLineItem and update this old opprtunity for deletion. 
Author - Darshan Chhajed.
*/

global class MigrateOpportunityProducts implements Database.Batchable<sObject>{
     string query = 'SELECT Id,';
     public MigrateOpportunityProducts(){
            query+= 'Source_Opportunity_Id__c, Source_Pricebook_Entry_Id__c, ';
            query+= 'Source_Product_Id__c,';
            query+= 'Quantity,';
            query+= 'PricebookEntryId,';
            query+= 'ProductCode,';
            query+= 'Description,';
            query+= 'ListPrice,';
            query+= 'TotalPrice,';
            query+= 'UnitPrice,';
            query+= 'Auto_Renew__c,';
            query+= 'Coupon_Code__c,';
            query+= 'Date_Time_Added__c,'; 
            query+= 'Estimated_Quantity_Backordered__c,';
            query+= 'Estimated_Weight__c,';
            query+= 'G_L_Date__c,';
            query+= 'GL_Override__c,';
            query+= 'Invoice_Number__c,';
            query+= 'LineNumber__c,';
            query+= 'Line_Status__c,';
            query+= 'Line_Type__c,';
            query+= 'IsOrderItemCreated__c,';
            query+= 'PreOrder_Backorder_Handling__c,';
            query+= 'Price_After_Discount__c,';
            query+= 'Price_Before_Discount__c,';
            query+= 'Price_of_Discount__c,';
            query+= 'Product_Line_Type_Check__c,';
            query+= 'Product_Weight__c,';
            query+= 'Promo_Code__c,';
            query+= 'Quantity_Canceled__c,';
            query+= 'Quantity_Given_Away__c,';
            query+= 'Quantity_Returned__c,';
            query+= 'Quantity_Shipped__c,';
            query+= 'Ship_Date__c,';
            query+= 'Upgrade_Level__c ';
            query+= ' FROM OpportunityLineItem WHERE IsOrderItemCreated__c=false AND Source_Opportunity_Id__c!=null AND Source_Pricebook_Entry_Id__c!=null';
            system.debug('**start Query**'+query);
     }
     global Database.querylocator start(Database.BatchableContext BC){
            
          return Database.getQueryLocator(query);  //get all opportunity item
    }
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        
        list<String> productsIds = new list<string>();
        set<String> orderIds = new set<String>();
        list<string> pricebookentryIds = new list<string>();
        map<Id,Id> oldToNewIdOrders =  new map<Id,Id>();
        list<OrderItem> orderItemToBeInserted = new list<OrderItem>();
        map<Id,OpportunityLineItem> optyLineItemMap = new map<Id,OpportunityLineItem>();
        map<string,Id> prodPBToPriceBookEntryMap = new map<string,Id>();
        // this map is used to to fond out what orderItem had an error while inserting 
        map<integer,string> OrderItemToOpptyItem = new map<integer,String>();
        map<Integer,OpportunityLineItem> opportunityLineItemMap = new map<Integer,OpportunityLineItem>();
        integer key=0;
        list<Error_Log__c> errorLogsTobeInserted = new list<Error_Log__c>();
        for(sObject sObj : scope){
            OpportunityLineItem OLI = (OpportunityLineItem)sObj;
            orderIds.add(OLI.Source_Opportunity_Id__c);
            pricebookentryIds.add(OLI.Source_Pricebook_Entry_Id__c);
            optyLineItemMap.put(OLI.Id,OLI);
        }
        system.debug('**orderIds**'+orderIds.size()+'   '+JSON.serialize(orderIds));
        list<Order> orderLst = [SELECT Id,Source_Opportunity_Id__c FROM Order WHERE Source_Opportunity_Id__c IN :orderIds AND Source_Opportunity_Id__c!=null];
        for(Order Ord : orderLst)
        {
            oldToNewIdOrders.put(Ord.Source_Opportunity_Id__c,Ord.Id);
        }
        system.debug('**oldToNewIdOrders**'+oldToNewIdOrders);       
        map<string,string> oldToNewPriceBookEntryIds = new map<string,string> ();
        list<PriceBookEntry> pirceBookEntries =  [Select Id, Source_Pricebook_Entry_Rec_Id__c,PriceBook2.Id, Product2.Id From PriceBookEntry Where Source_Pricebook_Entry_Rec_Id__c IN :pricebookentryIds AND IsActive = true];
        system.debug('pirceBookEntries==='+pirceBookEntries);
        system.debug('pricebookentryIds==='+pricebookentryIds);
        for(PriceBookEntry PBE : pirceBookEntries){
            prodPBToPriceBookEntryMap.put(PBE.Source_Pricebook_Entry_Rec_Id__c,PBE.Id);
        }
        system.debug('**oldToNewPriceBookIds**'+JSON.serialize(prodPBToPriceBookEntryMap));
        system.debug('**oldToNewIdOrders**'+oldToNewIdOrders);
        system.debug('**optyLineItemMap SCOPE**'+optyLineItemMap.size());
        for(OpportunityLineItem oli : optyLineItemMap.Values()){
            if(oldToNewIdOrders.get(oli.Source_Opportunity_Id__c)!=null){ //only for those opportunity products for which oppty is created
                OrderItem oItem = new OrderItem();
                /*Mapping Lookups*/
                oItem.OrderId  =  oldToNewIdOrders.get(oli.Source_Opportunity_Id__c);
                system.debug('**Pricebook Id**'+Oli.Id+'    Order ID**' +oldToNewIdOrders.get(oli.Source_Opportunity_Id__c));
                oItem.PricebookEntryId = prodPBToPriceBookEntryMap.get(oli.Source_Pricebook_Entry_Id__c); //will return new Pircebook id
                /*MAP OTHER FIELDS*/
                oItem.Quantity = oli.Quantity;
                //oItem.ProductCode = oli.ProductCode;
                oItem.Description = oli.Description;
                oItem.UnitPrice    = oli.UnitPrice;
                oItem.Auto_Renew__c = oli.Auto_Renew__c;
                oItem.Coupon_Code__c = oli.Coupon_Code__c;
                oItem.Estimated_Weight__c = oli.Estimated_Weight__c; 
                oItem.G_L_Date__c = oli.G_L_Date__c;
                oItem.GL_Override__c = oli.GL_Override__c;
                oItem.Invoice_Number__c = oli.Invoice_Number__c;
                oItem.LineNumber__c = oli.LineNumber__c;
                oItem.Line_Status__c = oli.Line_Status__c;
                oItem.Line_Type__c = oli.Line_Type__c;
                oItem.PreOrder_Backorder_Handling__c = oli.PreOrder_Backorder_Handling__c;
                oItem.Price_After_Discount__c = oli.Price_After_Discount__c;
                oItem.Price_Before_Discount__c = oli.Price_Before_Discount__c;
                //oItem.Price_of_Discount__c = oli.Price_of_Discount__c;
                oItem.Product_Weight__c = oli.Product_Weight__c;
                oItem.Promo_Code__c = oli.Promo_Code__c;
                oItem.Quantity_Canceled__c = oli.Quantity_Canceled__c;
                oItem.Quantity_Given_Away__c = oli.Quantity_Given_Away__c;
                oItem.Quantity_Returned__c = oli.Quantity_Returned__c;
                oItem.Quantity_Shipped__c = oli.Quantity_Shipped__c;
                oItem.Ship_Date__c = oli.Ship_Date__c;
                oItem.Upgrade_Level__c = oli.Upgrade_Level__c;
                oItem.OpportunityLineItemId__c = oli.id;
                oli.IsOrderItemCreated__c = true;
                OrderItemToOpptyItem.put(key,oli.id); //for oppty Product having errors;
                opportunityLineItemMap.put(key,oli);
                orderItemToBeInserted.add(oItem);
                key++;
            }
            else{
                    Error_Log__c errLog = new Error_Log__c();
                    errLog.Trace__C = 'Order for corresponding Source_Opportunity_Id__c is not present';
                    errLog.Object_Name__c = 'MigrateOLItoOrderItem';
                    errLog.Record_Id__c = oli.Id;
                    errorLogsTobeInserted.add(errLog);
            }
                
        }
        try{
            Database.SaveResult[] srList = Database.insert(orderItemToBeInserted, false);
            for(integer itr=0; itr<srList.size(); itr++){
                if(!srList[itr].isSuccess()){
                    Error_Log__c errLog = new Error_Log__c();
                    errLog.Trace__C = '';
                    for(Database.Error err : srList[itr].getErrors())
                        errLog.Trace__C = errLog.Trace__C + 'Error -' + string.valueOf(err.getMessage()) + ' Fields - '+ string.valueOf(err.getFields()) + '\n';
                    errLog.Object_Name__c = 'MigrateOpportunityProduct';
                    errLog.Record_Id__c = OrderItemToOpptyItem.get(itr);
                    opportunityLineItemMap.remove(itr);
                    errorLogsTobeInserted.add(errLog);
                }
                
            }
            insert errorLogsTobeInserted;
            update opportunityLineItemMap.values();
        }catch(Exception e){
           system.debug('**Exception**'+e+'    MSG-'+e.getStackTraceString());
            Error_Log__c err = new Error_Log__c();
            err.Trace__C = e.getStackTraceString() + String.valueOf(e);
            err.Object_Name__c = 'Exception IN MigrateOppTyProdToOrderProd';
            insert err;
        }
    }
    global void finish(Database.BatchableContext BC){
        
    }    
}