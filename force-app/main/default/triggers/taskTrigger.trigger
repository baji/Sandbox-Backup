trigger taskTrigger on Task (after update) {
    
   /* if(Trigger.isupdate && Trigger.isAfter){
        Set<String> conIds;
        for(task t : Trigger.new){
            if(String.isNotBlank(t.Ministry_Agreement_Status__c) && t.Ministry_Agreement_Status__c == 'Verified' &&  
               string.isNotBlank(t.Status) && t.status == 'Completed' && string.isnotBlank(t.WhoId)){
                   string conId = t.WhoId;
                   if(conId.StartsWith('003')){
                       conIds.add(t.WhoId);
                   }
               }
        }
        
        if(!conIds.isEmpty()){
            //Contact con = [SELECT ]
        }
    }*/
    
}