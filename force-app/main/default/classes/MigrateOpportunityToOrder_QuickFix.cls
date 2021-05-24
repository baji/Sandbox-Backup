/*
    Author - Darshan Chhajed.
    Description - This class is Quickfix for updating few fields on newly created Order Data.
*/
Global Class MigrateOpportunityToOrder_QuickFix implements Database.Batchable<sObject>{
    
    global Database.querylocator start(Database.BatchableContext BC){
          string query='SELECT Source_Record_Id__c,Billing_County__c,Cancel_Log__c,Shipping_Code__c,Shipping_GeoCode__c,Ship_to_Name__c FROM Opportunity WHERE safe_to_delete__c = true AND Source_Record_Id__c!=null AND Source_Record_Type_Name__c = \'Orders\'';
          return Database.getQueryLocator(query);  //get Opportunity Data which is migrated from Old instance.
    }
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        list<string> sourceOpptyIdLst = new list<string>();
        integer key = 0;
        map<string,Opportunity> idToOpportunityMap = new map<string,Opportunity>();
        for(sObject sObj : scope){
            Opportunity Oppty = (Opportunity)sObj;
            idToOpportunityMap.put(oppty.Source_Record_Id__c,Oppty);
        }
        list<Error_Log__c> errorLogsTobeInserted = new list<Error_Log__c>();
        try{
            list<Order> OrderTobeUpdated = [SELECT Source_Opportunity_Id__c,Billing_County__c,Cancel_Log__c,Shipping_Code__c,Shipping_GeoCode__c,Ship_to_Name__c FROM Order WHERE Source_Opportunity_Id__c IN :idToOpportunityMap.KeySet()];
            if(OrderTobeUpdated !=null && OrderTobeUpdated.size()>0){
                for(Order Ord : OrderTobeUpdated ){
                    Opportunity opp  = idToOpportunityMap.get(Ord.Source_Opportunity_Id__c);
                    Ord.Billing_County__c = Opp.Billing_County__c; 
                    Ord.Cancel_Log__c = Opp.Cancel_Log__c;
                    Ord.Shipping_Code__c = Opp.Shipping_Code__c;
                    Ord.Shipping_GeoCode__c = Opp.Shipping_GeoCode__c;
                    Ord.Ship_to_Name__c = Opp.Ship_to_Name__c; 
                }
            }
            Database.SaveResult[] srList = Database.Update(OrderTobeUpdated, false);
            for(integer itr=0; itr<srList.size(); itr++){
                if(!srList[itr].isSuccess()){
                    Error_Log__c errLog = new Error_Log__c(Object_Name__c = 'MigrateOpportunityToOrder_QuickFix',Record_Id__c = OrderTobeUpdated[key].Id);
                    for(Database.Error err : srList[itr].getErrors()){
                        errLog.Trace__C = errLog.Trace__C + 'Error -' + string.valueOf(err.getMessage()) + ' Fields - '+ string.valueOf(err.getFields()) + '\n';
                    }
                    errorLogsTobeInserted.add(errLog);
                }
                key++;
            }
            insert errorLogsTobeInserted;    
        }    
        catch(Exception e){
            Error_Log__c err = new Error_Log__c(Trace__C = e.getStackTraceString() + String.valueOf(e),Object_Name__c = 'Exception IN MigrateOpportunityToOrder_QuickFix');
            insert err;
        }
    }
    global void finish(Database.BatchableContext BC){
    }
}