/*
 * Trigger name : UpdateOwnerToMissionary
 * Developed by : Mayur Soni(mayur@infoglen.com)
 * Usage        : Fetch the Missionary from the GAU and assigned as owner in to the allocation
 * Date created : 15-Feb-2018
 * Company      : Infoglen
*/
trigger UpdateOwnerToMissionary on npsp__Allocation__c (before insert,before update) {
     
    Set<Id> gauIds = new Set<Id>(); 
    Set<Id> oppIds = new Set<Id>();
    if(Trigger.isInsert){
        for(npsp__Allocation__c allo : Trigger.new){
            if(allo.npsp__General_Accounting_Unit__c != null){
                gauIds.add(allo.npsp__General_Accounting_Unit__c);
                oppIds.add(allo.npsp__Opportunity__c);
            }
        }
    }
    if(Trigger.isUpdate){
        for(npsp__Allocation__c allo : Trigger.new){
            if(allo.npsp__General_Accounting_Unit__c != null && allo.npsp__General_Accounting_Unit__c != Trigger.oldMap.get(allo.Id).npsp__General_Accounting_Unit__c){
                gauIds.add(allo.npsp__General_Accounting_Unit__c);
                oppIds.add(allo.npsp__Opportunity__c);
            }
            
        }
    }
    //get the Anonymous information from Opportunity
    Map<Id,Opportunity> opportunityMap;
    if(!oppIds.isEmpty()){
        opportunityMap = new Map<Id,Opportunity>([SELECT Id,Anonymous__c,npsp__Primary_Contact__r.Anonymous__c FROM Opportunity WHERE Id IN: oppIds]);
        System.debug('>>> Opportunity Map : '+opportunityMap);
    }
    if(!gauIds.isEmpty()){
        Map<Id,npsp__General_Accounting_Unit__c> gauList = new Map<Id,npsp__General_Accounting_Unit__c>([SELECT Id,Missionary__c FROM npsp__General_Accounting_Unit__c WHERE Id IN :gauIds AND Missionary__c!=null]);
        if(!gauList.isEmpty()){
            for(npsp__Allocation__c allo : Trigger.new){
                //change the owner only if opportunity and contact is not marked as anonymous
                if(!opportunityMap.isEmpty() && opportunityMap.containsKey(allo.npsp__Opportunity__c) && !opportunityMap.get(allo.npsp__Opportunity__c).Anonymous__c && !opportunityMap.get(allo.npsp__Opportunity__c).npsp__Primary_Contact__r.Anonymous__c){
                    if(allo.npsp__General_Accounting_Unit__c != null && gauList.containsKey(allo.npsp__General_Accounting_Unit__c)){
                        allo.OwnerId = gauList.get(allo.npsp__General_Accounting_Unit__c).Missionary__c;
                    }
                }   
            }
        }
    }
    
}