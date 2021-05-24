trigger ResultTrigger on WE_FW8_NP__WESearchResult__c (after insert/*,after update*/) {

    
    public static boolean isafter = false;
    public set<id> contactids = new set<id>();
    public map<id,id> contactmap = new map<id,id>();
    public map<id,Account> UpdAccMap = new map<id,Account>();
    
    if(!isafter){
        for(WE_FW8_NP__WESearchResult__c c : trigger.new){
            contactids.add(c.WE_FW8_NP__Contact__c);
            contactmap.put(c.WE_FW8_NP__Contact__c,c.id);
        }
        for(Contact c:[Select id,Accountid from Contact where id IN:contactids]){
            if(contactmap.get(c.id)!=null)
                UpdAccMap.put(c.Accountid,new Account(id=c.Accountid,Wealth_Engine_Result__c=contactmap.get(c.id)));
        }
        if(UpdAccMap.size()>0){
            isafter=true;
            update UpdAccMap.values();
        }
    }
}