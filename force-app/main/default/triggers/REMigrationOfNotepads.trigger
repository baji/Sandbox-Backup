trigger REMigrationOfNotepads on Note (before insert) {
    Awana_Settings__c awanaSettings = Awana_Settings__c.getValues('ExecuteNotesTrigger');
    system.debug('awanaSettings'+awanaSettings);
    map<String,String> titleMap = new map<String,String>(); 
    string SEPARATOR = '#~#';
    if(Boolean.valueOf(awanaSettings.value__c))
    {
        system.debug('Executing Trigger');
        set<string> parentExternalIds =  new set<string>();
        for(Note n : Trigger.New)
        {
            if(n.Title!=null){
                system.debug(n.title);
                
                list<string> lst = (list<String>)n.Title.Split(SEPARATOR);
                system.debug(lst.get(0));
                //titleMap.put(lst.get(1),lst.get(0));
                titleMap.put(n.Title,lst.get(0));
                parentExternalIds.add(lst.get(0));
                //n.Title = lst.get(1);
            }
                
        }
        system.debug('parentExternalIds' + parentExternalIds);
        Awana_Settings__c awanaSettings1 = Awana_Settings__c.getValues('RENotesMigrationParentObjectName');
        system.debug('awanaSettings1--'+awanaSettings1);
        if(awanaSettings1.Value__c == 'Opportunity')
        {
            Map<String,opportunity> sourceIdVsOppMap = new Map<String,Opportunity>();
            list<Opportunity> OppLst = [SELECT Id,Source_Gift_Id__c FROM Opportunity WHERE Source_Gift_Id__c IN :parentExternalIds];
            for(Opportunity Opp : OppLst){
                sourceIdVsOppMap.put(opp.Source_Gift_Id__c,opp);
            }
            for(Note N : Trigger.New){
                if(titleMap.containsKey(N.Title) && sourceIdVsOppMap.containsKey(titleMap.get(N.Title)))
                    N.parentId = sourceIdVsOppMap.get(titleMap.get(N.Title)).Id;    
                    N.title = n.Title.Split(SEPARATOR)[1];
            }
            /*for(Opportunity Opp : OppLst){
                for(Note N : Trigger.New){
                    if(titleMap.containsKey(N.Title) && titleMap.get(N.Title) == Opp.Source_Gift_Id__c)
                        N.parentId = Opp.Id;    
                        N.title = n.Title.Split(SEPARATOR)[1];
                }
            }*/
        }
        else if(awanaSettings1.Value__c == 'Constituent'){
            list<Contact> ConLst = [SELECT Id,RE_Constit_Rec_Id__c FROM Contact WHERE RE_Constit_Rec_Id__c IN :parentExternalIds];
            list<Account> AccountLst = [SELECT Id,RE_Constit_Rec_Id__c FROM Account WHERE RE_Constit_Rec_Id__c IN :parentExternalIds];

            map<String,String>AccountMap = new map<string,string>();
            map<String,String>ContactMap = new map<string,string>();

            for(Account Acc : AccountLst){
                AccountMap.put(Acc.RE_Constit_Rec_Id__c, Acc.Id);
            }
            for(Contact Con : ConLst){
                ContactMap.put(Con.RE_Constit_Rec_Id__c, Con.Id);
            }
            for(Note N : Trigger.New){
                if(titleMap.containsKey(N.Title) && ContactMap.ContainsKey(titleMap.get(N.title)))
                    N.parentId = ContactMap.get(titleMap.get(N.title));
                else if(titleMap.containsKey(N.Title) && AccountMap.containsKey(titleMap.get(N.title)))
                    N.parentId = AccountMap.get(titleMap.get(N.title));            
                system.debug('Notes ParentId'+n.parentId);
                N.title = n.Title.Split(SEPARATOR)[1];
            } 
                     
        } 
        else if(awanaSettings1.Value__c == 'Task'){
            list<Task> TaskLst = [SELECT Id,Source_Rec_Id__c FROM Task WHERE Source_Rec_Id__c IN :parentExternalIds];
            System.debug('TaskList : '+TaskLst);
            for(Task T : TaskLst){
                for(Note N : Trigger.New){
                    if(titleMap.containsKey(N.Title) && titleMap.get(N.Title) == T.Source_Rec_Id__c)
                        N.parentId = T.Id;  
                    N.title = n.Title.Split(SEPARATOR)[1]; 
                    System.debug('N.ParentId : '+N.parentId);     
                }
            }
        }  
    }   
}