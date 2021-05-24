/*****************************************
    Programmer: Matthew Keefe
    Company:    Awana
    Contact:    mattk@awana.org
    Project:    Fulfillment In Salesforce
    Original:   09/13/2010
 
     -- Execute Batch -- 
    BatchGeneratePickTickets job = new BatchGeneratePickTickets(); ID batchprocessid = Database.executeBatch(job, 1); 
 *****************************************/

global class BatchGeneratePickTickets implements Database.Batchable<sObject>
{
    global String Query;
    global List<Order> OrdersToPick;
    
    global Iterable<sObject> start(Database.BatchableContext BC)
    {
        // if the list provided is null, it must be generated
        if(OrdersToPick == null)
        {
            String DefaultQuery = 
                ' Select Id, AccountId, Account.Name, Name, ' + 
                ' Status, TotalAmount, CreatedDate, CreatedById, CreatedBy.Name, HasOrderLineItem__c, LastModifiedDate, ' +
                ' LastModifiedById, LastModifiedBy.Name, TotalOrderQuantity__c, Total_Pick_Quantity__c, ' +
                ' Total_Pick_Tickets__c, Inventory_Items__c, Non_inventory_Items__c, Error_Log__c, ' +
                ' (Select Id, Name From Pick_Tickets__r) ' + 
                ' FROM Order Where CreatedDate > 2010-07-01T00:00:00.000Z ' +
                ' And TotalAmount > 0 ' + 
                ' And (Status = \'Order Confirmed\' OR Status like \'%Partially%\') ' + 
                ' And (NOT Status like \'%Cancelled%\') ';
        
            if(Query == null) {
                Query = DefaultQuery; }
            else {
                System.debug('Query : '+Query);
                if(!Query.toLowerCase().contains('from order')) { Query = null; } }
            
            system.debug(Query);
            
            OrdersToPick = Database.query(Query);
        }
        
        CustomIterable OrdersToPickIterable = new CustomIterable(OrdersToPick);
        
        system.debug('Custom Iterable: '+OrdersToPickIterable);
        
        return OrdersToPickIterable;
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        for(sObject s : scope)
        {
            Order o = (Order)s;
            OrderEntryStatus.QueueGeneratePickTicket(o.Id);
        }
    }
    
    global void finish(Database.BatchableContext BC)
    {
        system.debug(BC);
    }

}