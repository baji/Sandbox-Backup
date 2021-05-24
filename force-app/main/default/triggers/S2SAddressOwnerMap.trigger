trigger S2SAddressOwnerMap on Address__c (before insert) {
   
    List<String> ownerIdLst= new List<String>(); 
    for(Address__c obj : trigger.new){
        ownerIdLst.add(obj.Source_Owner_Email__c);
    }
    Map<String,Id> mapUserIds = new Map<String,Id>();
    for(User obj : [SELECT Id,Source_User_Rec_Id_c__c FROM User WHERE Source_User_Rec_Id_c__c IN : ownerIdLst AND IsActive=true]){
        mapUserIds.put(obj.Source_User_Rec_Id_c__c,Obj.Id);
    }
    for(Address__c obj : trigger.new){    
            if(!Test.isRunningTest())
                obj.ownerId = mapUserIds.containsKey(obj.Source_Owner_Email__c)?mapUserIds.get(obj.Source_Owner_Email__c):'005f4000000ZJhT';
    }
}