global class BatchUpdateProductListPrice implements Database.Batchable<sObject>{
    
    global Database.QueryLocator start(Database.BatchableContext BC){

        String query = 'SELECT Id,Product2Id,Pricebook2Id,UnitPrice FROM PricebookEntry WHERE Pricebook2.Name = \'Catalog Price Book\' AND SystemModStamp  >= LAST_N_DAYS:1 AND Product2.IsActive = True';
        return Database.getQueryLocator(query); 
    }
    
    global void execute(Database.BatchableContext BC, List<PricebookEntry> priceBookEntryList){
        if(!priceBookEntryList.isEmpty()){
            Map<Id,PricebookEntry> productVsPriceBookEntryMap = new Map<Id,PricebookEntry>();             
            for(PricebookEntry pbe :priceBookEntryList){
                productVsPriceBookEntryMap.put(pbe.Product2Id,pbe);
            }
            
            List<Product2> prodList = [SELECT Id,List_Price__c,IsActive
                                       FROM Product2 
                                       Where Id IN:productVsPriceBookEntryMap.keySet()];
                                                  
            if(!prodList.isEmpty()){
                For(Product2 prod : prodList){ 
                    //Decimal catalogPrice = productVsPriceBookEntryMap.get(prod.Id).UnitPrice;
                    if(prod.IsActive)
                        prod.List_Price__c = productVsPriceBookEntryMap.get(prod.Id).UnitPrice;
                    else
                        prod.List_Price__c = null;
                }
                update prodList;      
            }
        }        
    }
     
    global void finish(Database.BatchableContext BC){
        
    }     
}