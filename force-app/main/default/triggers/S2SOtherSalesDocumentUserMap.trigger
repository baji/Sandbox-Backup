trigger S2SOtherSalesDocumentUserMap on Other_Sales_Document__c (before insert) {
    
    List<String> ownerIdLst= new List<String>(); 
    for(Other_Sales_Document__c obj : trigger.new){
        ownerIdLst.add(obj.Source_Owner_Email__c);
    }   
    Map<String,Id> mapUserIds = S2SPartnerNetworkRecordUtility.getUsers(ownerIdLst);
    for(Other_Sales_Document__c obj : trigger.new){    
        if(!Test.isRunningTest())
            obj.ownerId = mapUserIds.containsKey(obj.Source_Owner_Email__c)?mapUserIds.get(obj.Source_Owner_Email__c):'005f4000000ZJhT';
    }
    
    
}