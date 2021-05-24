@RestResource(urlMapping = '/Events/*')
global class WsEvent{
    @HttpPost
    global static void doPost(){
        
        RestRequest req = RestContext.request;
        String myJson = req.requestBody.toString();
        String objName = req.params.get('objName');
        JSONParser parser = JSON.createParser(myJson);
        List<Event> listMyResponseObjects = new List<Event>();
        
        while (parser.nextToken() != null) {
            if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                while (parser.nextToken() != null) {
                    if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                        Sobject sobj = (Sobject)parser.readValueAs(Sobject.class);
                        listMyResponseObjects.add((Event)sobj);
                    }
                }
            }
        }
        List<Id> listoldId = new List<Id>();
        List<String> listOldOwnerEmail = new List<String>();
        for(Event obj : listMyResponseObjects){
            If(Obj.WhoId != null)
                listoldId.add(obj.WhoId);
            If(Obj.WhatId != null)
                listoldId.add(obj.WhatId);
            listOldOwnerEmail.add(obj.Formula_OwnerId__c);
        } 
        Map<Id,Id> mapWithNewOldId = S2SPartnerNetworkRecordUtility.getData(listoldId);
        Map<String,Id> mapEmail = S2SPartnerNetworkRecordUtility.getUsers(listOldOwnerEmail);
        List<Event> listCon = new List<Event>();
        if(objName == 'Opportunity'){
            Map<Id,Id> mapOrder = new Map<Id,Id>();
            for(Order obj : [SELECT Id,Source_Opportunity_Id__c FROM Order WHERE Source_Opportunity_Id__c IN :listoldId]){
                mapOrder.put(obj.Source_Opportunity_Id__c,obj.Id);
            } 
            for(Event obj : listMyResponseObjects){       
                obj.Id = null;
                obj.Source_WhatId__c = obj.WhatId;
                obj.Source_WhoId__c = obj.WhoId;
                obj.Source_OwnerId__c = obj.Formula_OwnerId__c;
                obj.WhoId = mapWithNewOldId.containsKey(obj.WhoId)?mapWithNewOldId.get(obj.WhoId):null;
                obj.WhatId = mapOrder.containsKey(obj.WhatId)?mapOrder.get(obj.WhatId):null;
                if(mapEmail.containsKey(obj.Formula_OwnerId__c))
                obj.OwnerId = mapEmail.get(obj.Formula_OwnerId__c);
              listCon.add(obj); 
            }
        }else{          
            for(Event obj : listMyResponseObjects){       
                obj.Id = null;
                obj.Source_WhatId__c = obj.WhatId;
                obj.Source_WhoId__c = obj.WhoId;
                obj.Source_OwnerId__c = obj.Formula_OwnerId__c;
                obj.WhoId = mapWithNewOldId.containsKey(obj.WhoId)?mapWithNewOldId.get(obj.WhoId):null;
                obj.WhatId = mapWithNewOldId.containsKey(obj.WhatId)?mapWithNewOldId.get(obj.WhatId):null;
                if(mapEmail.containsKey(obj.Formula_OwnerId__c))
                obj.OwnerId = mapEmail.get(obj.Formula_OwnerId__c);
              listCon.add(obj); 
            }
        }
        If(!listCon.isEmpty())      
        List<Database.saveResult> data = Database.Insert(listCon);
         
    }
}