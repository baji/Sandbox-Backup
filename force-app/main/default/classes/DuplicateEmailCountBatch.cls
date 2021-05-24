global class DuplicateEmailCountBatch implements Database.Batchable<sObject>{
    global string query;
    global DuplicateEmailCountBatch(String q){
        query = String.isNotBlank(q) ? q :
        'SELECT id, ContactId__c,AccountId__c,CountOfOpportunity__c,CountOfOrder__c,Email__c,'+
            'LastOpportunity__c,LastOpportunityCreatedDate__c,LastOrder__c,LastOrderCreateddate__c,TotalOpportunityAmount__c,TotalOrderAmount__c,'+
			'RE_Constit_Rec_Id__c,SpouseContactID__c'+
            ' FROM Duplicate_Contact_Analyze__c';
        if(Test.isRunningTest())
            query += ' LIMIT 10';
    }
    global DuplicateEmailCountBatch(){
        query = 'SELECT id, ContactId__c,AccountId__c,CountOfOpportunity__c,CountOfOrder__c,Email__c,'+
            'LastOpportunity__c,LastOpportunityCreatedDate__c,LastOrder__c,LastOrderCreateddate__c,TotalOpportunityAmount__c,TotalOrderAmount__c,'+
			'RE_Constit_Rec_Id__c,SpouseContactID__c'+
            ' FROM Duplicate_Contact_Analyze__c';
        if(Test.isRunningTest())
            query += ' LIMIT 10';
        
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Duplicate_Contact_Analyze__c> scope){
        List<Duplicate_Contact_Analyze__c> listToUpdate = new List<Duplicate_Contact_Analyze__c>();
		for(Duplicate_Contact_Analyze__c dcaObj : scope){
			//Opportunity Count
			Integer opptyCount; 
			Decimal opptyAmount;
			List<AggregateResult> oppList = [SELECT COUNT(id) ,sum(Amount) FROM Opportunity WHERE Recordtype.Name='Donation' AND npsp__Primary_Contact__c=:dcaObj.ContactId__c];
			if(!oppList.isEmpty()){
				for(AggregateResult ar : oppList){
					opptyCount = Integer.valueOf(ar.get('expr0'));
					if(opptyCount > 0)
						opptyAmount = Decimal.valueOf(String.valueOf(ar.get('expr1')));
				}
			}
			//Order Count
			Integer ordCount;
			Decimal ordAmount;
			List<AggregateResult> ordList = [SELECT COUNT(Id) ,SUM(TotalAmount) FROM Order WHERE ID IN (SELECT Order__c FROM Order_Contact_Role__c where Contact__c=:dcaObj.ContactId__c)];
			if(!ordList.isEmpty()){
				for(AggregateResult ar : ordList){
					ordCount = Integer.valueOf(ar.get('expr0'));
					if(ordCount > 0)
						ordAmount = Decimal.valueOf(String.valueOf(ar.get('expr1')));
				}
			}
			//Last Opportunity
			List<Opportunity> lastOppList = new List<Opportunity>();
			if(opptyCount > 0){
				lastOppList = [SELECT ID,Createddate FROM Opportunity WHERE Recordtype.Name='Donation' 
										AND npsp__Primary_Contact__c=:dcaObj.ContactId__c ORDER BY CreatedDate DESC LIMIT 1];
											
			}
			//Last Order
			List<Order> lastOrderList = new List<Order>();
			if(ordCount > 0 ){
				lastOrderList = [SELECT ID,Order_Created_Date__c FROM Order WHERE ID IN (SELECT Order__c FROM Order_Contact_Role__c where Contact__c=:dcaObj.ContactId__c)
								ORDER BY Order_Created_Date__c DESC LIMIT 1];
			}
			//if migrated from RE, check for spouse id
			List<npe4__Relationship__c> relationList = new List<npe4__Relationship__c>();
			if(String.isNotBlank(dcaObj.RE_Constit_Rec_Id__c)){
				relationList = [SELECT Id,npe4__RelatedContact__c FROM npe4__Relationship__c 
														WHERE npe4__Contact__c=:dcaObj.ContactId__c AND npe4__Type__c='Spouse' LIMIT 1];	
			}
			
			Duplicate_Contact_Analyze__c obj = new Duplicate_Contact_Analyze__c(id=dcaObj.Id);
			if(opptyCount!=null )	obj.CountOfOpportunity__c = opptyCount;
			if(opptyAmount!=null)	obj.TotalOpportunityAmount__c=opptyAmount;
			if(ordCount!=null)	obj.CountOfOrder__c	= ordCount;
			if(ordAmount!=null) obj.TotalOrderAmount__c = ordAmount;
			if(!lastOppList.isEmpty()){
				obj.LastOpportunityCreatedDate__c = lastOppList[0].Createddate;
				obj.LastOpportunity__c = lastOppList[0].Id;
			}
			if(!lastOrderList.isEmpty()){
				obj.LastOrderCreateddate__c = lastOrderList[0].Order_Created_Date__c;
				obj.LastOrder__c = lastOrderList[0].Id;
			}
			if(!relationList.isEmpty()){
				obj.SpouseContactID__c = relationList[0].npe4__RelatedContact__c;
			}
			listToUpdate.add(obj);
		}
		if(!listToUpdate.isEmpty())
			update listToUpdate;
            System.debug('list to update : '+JSON.serialize(listToUpdate));
    }
    
    global void finish(Database.BatchableContext BC){
    }
}