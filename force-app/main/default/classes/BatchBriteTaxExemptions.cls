global class BatchBriteTaxExemptions implements Schedulable, Database.AllowsCallouts{
    
    global void execute(SchedulableContext SC) 
    {
        
        
    List<Order> Olist = [Select id,OrderNumber, Status,Has_Brite__c,AccountId, Account.Sales_Tax_Exemption_Hold__c, Account.Sales_Tax_Exemption_Hold_Expiration_Date__c from Order where Status='Order on Hold' and Has_Brite__c=true];
    system.debug(Olist.size());
    List<Account> updAccount= new List<Account>();
    List<Order> updOrder = new List<Order>();
    for(Order O : Olist){
        if(O.Account.Sales_Tax_Exemption_Hold_Expiration_Date__c < date.today()){
        system.debug(O.Account.Sales_Tax_Exemption_Hold_Expiration_Date__c);
            updAccount.add(new Account(id=O.AccountId,Sales_Tax_Exemption_Hold__c=false));
            updOrder.add(new Order(id=O.id, status='Order Submitted'));
        }
        system.debug(O);
    }
    if(updAccount.size()>0)
    {
        update updAccount;
        update updOrder;
    }
        
        
    }
}