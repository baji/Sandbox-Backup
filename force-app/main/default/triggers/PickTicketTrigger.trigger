trigger PickTicketTrigger on Pick_Ticket__c (before insert,after update) {
    
    if(Trigger.isAfter && Trigger.isUpdate){
        if(PickTicketTriggerHandler.runTrigger){
            PickTicketTriggerHandler.handleAfterUpdateEvent();
        }
    } 
    //This is for non-stock ,downloadable items as it is not required to decrement the quantity,
    //just changing this flag so it could send outbond message.
    if(Trigger.isBefore && Trigger.isInsert){
        for(Pick_Ticket__c pt :trigger.new){
            if(String.isNotBlank(pt.Status__c) && pt.Status__c == 'Closed'){
                pt.Status_Closed__c = true;
            }
        }
    }

}