/*****************************************
    Programmer: Matthew Keefe
    Company:    Awana
    Contact:    mattk@awana.org
    Project:    Fulfillment In Salesforce
    Original:   09/13/2010
 
     -- Execute Batch -- 
    BatchGeneratePickTicketsByQuery job = new BatchGeneratePickTicketsByQuery(); ID batchprocessid = Database.executeBatch(job, 1); 
 *****************************************/

global class BatchGeneratePickTicketsByQuery implements Database.Batchable<sObject>
{
    global String Query;

    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String DefaultQuery = 
            ' Select Id, AccountId, Account.Name, Name, ' + 
            ' Status, TotalAmount, CreatedDate, CreatedById, CreatedBy.Name, HasOrderLineItem__c, LastModifiedDate, ' +
            ' LastModifiedById, LastModifiedBy.Name, TotalOrderQuantity__c, Total_Pick_Quantity__c, ' +
            ' Inventory_Items__c, Non_inventory_Items__c, Error_Log__c, ' +
            ' (Select Id, Name From Pick_Tickets__r) ' + 
            ' FROM Order Where CreatedDate > 2010-07-01T00:00:00.000Z ' +
            ' And TotalAmount > 0 ' + 
            ' And (Status = \'Order Confirmed\' OR Status like \'%Partially%\') ' + 
            ' And (NOT Status like \'%Cancelled%\') ';
    // Total_PicStatusk_Tickets__c  -- not using
        if(Query == null) {
            Query = DefaultQuery; }
        else {
            if(!Query.toLowerCase().contains('from order')) { Query = null; } }
        
        system.debug(Query);
        
        return Database.getQueryLocator(Query);
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