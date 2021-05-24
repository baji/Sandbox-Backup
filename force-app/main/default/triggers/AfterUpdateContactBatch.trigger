trigger AfterUpdateContactBatch on npe5__Affiliation__c (before update) {
    
    system.debug('checkRecursive.batchUpdate==>'+checkRecursive.batchUpdate);
    if(checkRecursive.batchUpdate){
        system.debug('checkRecursive.batchUpdate==>'+checkRecursive.batchUpdate);
        List<npe5__Affiliation__c> updateList = new List<npe5__Affiliation__c>();
        for(npe5__Affiliation__c aff: Trigger.New){
            npe5__Affiliation__c oldAff = Trigger.oldMap.get(aff.id); 
            if(aff.npe5__Status__c == 'Former' && oldAff.npe5__Status__c == 'Current'){
                aff.npe5__Status__c = 'Current';     
                aff.npe5__EndDate__c  = null;          
            }
            if((!aff.Authorized_Purchaser__c) && (oldAff.Authorized_Purchaser__c)){
                aff.Authorized_Purchaser__c = true;
            }
            if((!aff.Organization_Owner__c) && (oldAff.Organization_Owner__c)){
                aff.Organization_Owner__c = true;
            }                                  
        }      
      
    }
}