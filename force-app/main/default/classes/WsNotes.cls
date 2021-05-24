@RestResource(urlMapping = '/SSNotes/*')
global class WsNotes{
    @HttpPost
    global static void doPost(){
        
        RestRequest req = RestContext.request;
        String objName = req.params.get('objName');
        String myJson = req.requestBody.toString();
        JSONParser parser = JSON.createParser(myJson);
        
        List<Note> listMyResponseObjects = new List<Note>();
        
        while (parser.nextToken() != null) {
            if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                while (parser.nextToken() != null) {
                    if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                        Sobject sobj = (Sobject)parser.readValueAs(Sobject.class);
                        listMyResponseObjects.add((Note)sobj);
                    }
                }
            }
        }
        
        List<Id> listoldParentId = new List<Id>();
        List<Note> listNewRecords = new List<Note>();
        
        for(Note obj : listMyResponseObjects){
            listoldParentId.add(obj.ParentId);
        }
        if(objName == 'Opportunity'){           
            Map<Id,Id> mapOrder = new Map<Id,Id>();
            for(Order obj : [SELECT Id,Source_Opportunity_Id__c FROM Order WHERE Source_Opportunity_Id__c IN :listoldParentId]){
                mapOrder.put(obj.Source_Opportunity_Id__c,obj.Id);
            }
            for(Note obj : listMyResponseObjects){          
                if(mapOrder.containsKey(obj.ParentId)){
                    obj.Id = null;
                    obj.ParentId = mapOrder.get(obj.ParentId);
                    listNewRecords.add(obj);
                }
            }
        }else{
            Map<Id,Id> mapWithNewOldId = S2SPartnerNetworkRecordUtility.getData(listoldParentId);        
            for(Note obj : listMyResponseObjects){          
                if(mapWithNewOldId.containsKey(obj.ParentId)){
                    obj.Id = null;
                    obj.ParentId = mapWithNewOldId.get(obj.ParentId);
                    listNewRecords.add(obj);
                }
            }
        }
        
        If(!listNewRecords.isEmpty())
            List<Database.saveResult> data = Database.Insert(listNewRecords);
    }
}