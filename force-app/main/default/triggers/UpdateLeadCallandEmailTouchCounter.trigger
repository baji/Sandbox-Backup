/*****************************************************************************************************************************************************************************************
*   Programmer: Vikas Y
*   Company:    Infoglen
*   Contact:    vikas@Infoglen.com
*   Project:    CRM Rewrite
*   Original:   10/18/2017 - Initial purpose for trigger is to check update closed Activities on Lead Object.
*   Test:       UpdateLeadCallandEmailTouchCounter_test.cls
*   
**************************************************************************************************************************************************************************************************************/

trigger UpdateLeadCallandEmailTouchCounter on Task (After insert, After Update, After Delete) {
   System.debug('******Trigger: UpdateLeadCallandEmailTouchCounter***Started***');
   Awana_Settings__c myCS1 = Awana_Settings__c.getValues('ExecuteTaskTrigger');
   if(Boolean.valueOf(myCS1.value__c)){
        Set<id> email_LeadIds = new Set<id>();
        Set<id> call_LeadIds = new Set<id>();
        Map<id, Integer> callCountMap = new Map<id, Integer>();
        Map<id, Integer> emailCountMap = new Map<id, Integer>();
        
        List<Task> tasksLst;
        
        if(!Trigger.IsDelete){
            tasksLst = Trigger.New;      
        }
        if(Trigger.IsDelete){
            tasksLst = Trigger.Old;
        }   
    
        for(Task ts: tasksLst){
          if(ts.Status.equals('Completed') && ts.whoid!=null && String.valueof(ts.whoid).startsWith('00Q')){// need to get only Lead related tasks count
               if(ts.Subject.containsIgnoreCase('Call'))
                   call_LeadIds.add(ts.WhoId); 
               if(ts.Subject.containsIgnoreCase('Email'))
                   email_LeadIds.add(ts.WhoId);
          }        
        }
        
        if(call_LeadIds.size() > 0){        
            
            /*for(AggregateResult ar: [SELECT Whoid LdId, count(id) total
                                     FROM Task 
                                     WHERE WhoId IN:call_LeadIds AND Subject LIKE 'Call%' AND Status = 'Completed' 
                                       GROUP BY Whoid]){                   
                callCountMap.put((id)ar.get('LdId'), (Integer)ar.get('total'));
            }*/
            //Added by Mayur to resolve query error : Non-selective query against large object type
            for(Lead ld : [SELECT Id,(SELECT Id,whoid FROM Tasks where Subject LIKE 'Call%' AND Status = 'Completed') FROM Lead WHERE ID IN:call_LeadIds]){
                if(ld.tasks.size() > 0){
                    callCountMap.put(ld.id, ld.tasks.size());    
                }
            }
        }
        
        if(email_LeadIds.size() > 0){   
            
            /*for(AggregateResult ar: [SELECT Whoid LdId, count(id) total
                                     FROM Task 
                                     WHERE WhoId IN:email_LeadIds AND Subject LIKE 'Email%' AND Status = 'Completed' 
                                       GROUP BY Whoid]){                          
                emailCountMap.put((id)ar.get('LdId'), (Integer)ar.get('total'));  
            }*/
            //Added by Mayur to resolve query error : Non-selective query against large object type
            for(Lead ld : [SELECT Id,(SELECT Id,whoid FROM Tasks where Subject LIKE 'Email%' AND Status = 'Completed') FROM Lead WHERE ID IN:email_LeadIds]){
                if(ld.tasks.size() > 0){
                    emailCountMap.put(ld.id, ld.tasks.size());    
                }
            }
        }
            
        List<Lead> updateLeads = [SELECT id, Call_Counter__c, Email_Counter__c 
                                  FROM Lead 
                                  WHERE Id IN: call_LeadIds OR Id IN:email_LeadIds]; 
        
        for(Lead ld: updateLeads){   
            if(call_LeadIds.size() > 0)
                ld.Call_Counter__c = (callCountMap.containsKey(ld.id)) ? callCountMap.get(ld.id) : 0;
            if(email_LeadIds.size() > 0)
                ld.Email_Counter__c = (emailCountMap.containsKey(ld.id)) ? emailCountMap.get(ld.id) : 0;
        }
        Update updateLeads;
    }
}