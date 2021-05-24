global class BatchWBNightlyJob implements Schedulable, Database.AllowsCallouts{
    
    global void execute(SchedulableContext SC) 
    {

        List<Pick_Ticket__c> PtTobeClosed = new list<Pick_Ticket__c>();
        List<Pick_Ticket__c> PtTobeClosedFinal = new list<Pick_Ticket__c>();
        String PT = '';
        if(!Test.isRunningTest())
            PtTobeClosed=[Select id,Name,status__c,Total_Pick_Quantity_Ordered__c,Total_Pick_Quantity__c,Order__r.OrderNumber from Pick_Ticket__c where status__c='Open' and CreatedDate=LAST_N_DAYS:30];
        else
            PtTobeClosed=[Select id,Name,status__c,Total_Pick_Quantity_Ordered__c,Total_Pick_Quantity__c,Order__r.OrderNumber from Pick_Ticket__c where CreatedDate=TODAY];
            
        if(PtTobeClosed.size()>0){
            for(Pick_Ticket__c p : PtTobeClosed){
                if(p.Total_Pick_Quantity_Ordered__c==p.Total_Pick_Quantity__c)
                {
                   p.Status__c='Closed';
 	               PT += p.Name+' - '+p.Order__r.OrderNumber+'; ';
                   PtTobeClosedFinal.add(p);
                }
            }
            if(PtTobeClosedFinal.size()>0)
	            update PtTobeClosedFinal;
        }
        
        String emailBody = PtTobeClosed.size()>0?'Closed PTs - '+ PT:'No Open PTs found';
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new List<String>{'anveshk@awana.org'});
        mail.setSenderDisplayName('ORG: Processes WhiteBox Nightly Open PTs');
        mail.setSubject('ORG: Batch to Processes WhiteBox Nightly PTs');
        mail.setPlainTextBody('ORG: Batch Process for Nightly Open PTs has completed\n\n' + emailBody);
        if(PtTobeClosedFinal.size()>0)
	        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
    }
}