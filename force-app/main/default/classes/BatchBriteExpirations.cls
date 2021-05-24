global class BatchBriteExpirations implements Schedulable, Database.AllowsCallouts{
    
    global void execute(SchedulableContext SC) 
    {
        Awana_Settings__c custSetting =  Awana_Settings__c.getValues('briteGracePeriod');
        Integer GracePeriod = Integer.valueOf(custSetting.Value__c);
        List<Digital_Curriculum_Expiration__c> ExpiredDCD = new list<Digital_Curriculum_Expiration__c>();
        Date dt = Date.today().addDays(-1*GracePeriod);
        if(!Test.isRunningTest())
            ExpiredDCD=[Select id,Curriculum_Expiration_Date__c,Curriculum_Expiration_Status__c from Digital_Curriculum_Expiration__c where Curriculum_Expiration_Status__c='Active' AND Curriculum_Expiration_Date__c<:dt];
        else
            ExpiredDCD=[Select id,Curriculum_Expiration_Date__c,Curriculum_Expiration_Status__c from Digital_Curriculum_Expiration__c where CreatedDate=TODAY];
            
        if(ExpiredDCD.size()>0){
            for(Digital_Curriculum_Expiration__c DCD : ExpiredDCD){
                DCD.Curriculum_Expiration_Status__c='Expired';
                system.debug(DCD);
            }
            update ExpiredDCD;
        }
        
        /*
        String emailBody = PtTobeClosed.size()>0?'Closed PTs - '+ PT:'No Open PTs found';
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new List<String>{'anveshk@awana.org'});
        mail.setSenderDisplayName('ORG: Processes WhiteBox Nightly Open PTs');
        mail.setSubject('ORG: Batch to Processes WhiteBox Nightly PTs');
        mail.setPlainTextBody('ORG: Batch Process for Nightly Open PTs has completed\n\n' + emailBody);
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
        */
        
    }
}