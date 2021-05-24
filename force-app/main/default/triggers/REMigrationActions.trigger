/*******************************************************************************************************************************************************************************************************************
    Programmer: Chellappa Karimanoor
    Company:    Awana
    Project:    Salesforce SSO
    Original:   4/22/2018  -Create new What and Who Id tasks for Campaigns and Contacts for Raiser's Edge.
    Updated:    4/28/2018 - (TW)  Bulkified the Awana_Settings__c instantiation to avoid null pointer exception errors so that Account with Dropped Registrations won't cause an abort when Account Registration is reinstated 
**********************************************************************************************************************************************************************************************************************/

trigger REMigrationActions on Task (before insert) {
    List<Awana_Settings__c> awanaSettings = new List<Awana_Settings__c>();
    awanaSettings.add(Awana_Settings__c.getValues('ExecuteREMigrationAction'));
   system.debug('<<AWANA SETTING SIZE>> '+awanaSettings.size());
    if(awanaSettings.size() > 0){ // Ths is a bandage fix - Tony W.
        if(Boolean.valueOf(awanaSettings[0].value__c))
        {
            map<string,String> whoIdMap = new map<string,string>();
            map<string,Task> newTask = new map<string,Task>();
            map<string,string> WhatIdMap = new map<string,string>();
    
            for(Task T : Trigger.New){
                if(T.Source_RE_ID__c!=null && T.Source_RE_ID__c!='')
                {
                    if(T.Source_WhoId__c !=null && T.Source_WhoId__c!='')
                        whoIdMap.put(T.Source_RE_ID__c,T.Source_WhoId__c);
                    if(T.Source_WhatId__c !=null && T.Source_WhatId__c!='')
                        WhatIdMap.put(T.Source_RE_ID__c,T.Source_WhatId__c);
                        newTask.put(T.Source_RE_ID__c,T);
                    }
                }
                if(whoIdMap!=null && whoIdMap.size()>0){
                    list<Contact> whoIdContact = [SELECT Id,RE_Constit_Rec_Id__c FROM Contact WHERE RE_Constit_Rec_Id__c IN :whoIdMap.Values()];
                    system.debug('whoIdContact--'+whoIdContact);
                    list<Campaign> whatIdCampaigns = [SELECT Id, RE_Appeal_ID__c  FROM Campaign WHERE RE_Appeal_ID__c IN :WhatIdMap.values()]; 
                    for(Contact Con : whoIdContact){
                        for(string str : whoIdMap.KeySet())
                        {    
                            system.debug('**str**'+str);
                            if(whoIdMap.get(str) == con.RE_Constit_Rec_Id__c)
                            { 
                                system.debug('SETTING WhoID');
                                newTask.get(str).WhoId = con.Id;
                            }
                        }
                    }
                    for(Campaign Camp : whatIdCampaigns){
                        for(string str : WhatIdMap.KeySet())
                            if(WhatIdMap.get(str) == Camp.RE_Appeal_ID__c)
                                newTask.get(str).WhatId = Camp.Id;
                        }
                    }
                }
        }
}