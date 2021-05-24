/******************************************************************************************************************
    Programmer:         Tony Williams
    Company:            Awana
    Contact:            tonyw@awana.org
    Project:            SFDC-62 (JIRA) 
    Original:           5/4/2016 - Updates an account via state whose GO Territory state record has been updated.
    *****************************************************************************************************************/ 
trigger GO_TerritoriesChanged on GO_Club_Territories__c (after update) {
    
    
    Integer territoryLimit = Trigger.New.size();
    Map<String,GO_Club_Territories__c> mapTerritories = new Map<String,GO_Club_Territories__c>();
    for( Integer i = 0; i < territoryLimit; i++){
        if(Trigger.New[i].GO_Territory__c != Trigger.old[i].GO_Territory__c|| Trigger.New[i].GO_Club_Outreach_Specialist__c != Trigger.old[i].GO_Club_Outreach_Specialist__c){
            system.debug(' << TERRITORY >> '+Trigger.New[i]);
            mapTerritories.put(Trigger.New[i].Name,Trigger.New[i]);
        }
    }
    if(mapTerritories.size() > 0){
        GOTerritoryAfterUpdatetMgr.handler(mapTerritories);
    }
    
}