/**************************************************************************************************************
 * NOTE: This clasess is no longer requried. Once the job is done. Remove it from all the instances(UAT/ Prod)
 * 
 * All Records: 
 * ProcessOrderAmountBatchService orderBtach = new ProcessOrderAmountBatchService();
 * Database.executeBatch(orderBtach, 2000);
 **************************************************************************************************************/

global class ProcessOrderAmountBatchService implements Database.Batchable < sObject >,Schedulable,Database.Stateful {
    global Decimal total;
    global String qry;
    
 
    /*global ProcessOrderAmountBatchService(String qry) {
        this.qry = qry;
    }*/

    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('****ProcessOrderAmountBatchService****START****');
        total = 0;
        if (String.isBlank(qry)) qry = 'SELECT id, Order_Amount_Summary__c, Previous_FY_Order_Summary__c, Current_FY_Order_Summary__c ,Order_Summary_Updated_Date__c FROM Account WHERE ID IN (SELECT AccountID FROM Order WHERE Status !=\'Order Open\' AND Status != \'Order Cancelled\' AND Id != null)';
        if(Test.isRunningTest()) qry += ' LIMIT 10';
        System.debug('Query : '+qry);
        return Database.getQueryLocator(qry);
    }

    global void execute(Database.BatchableContext BC, List < sObject > scope) {
        System.debug('****ProcessOrderAmountBatchService****Execute****scope***' + scope.size());
        Set < id > accids = new Set < id > ();
        for (Account acc: (List < Account > ) scope) {
            accids.add(acc.id);
        }
        System.debug('>>>accids : '+accids);
        try{
            //AggregateResult[] orderTotalList = [SELECT AccountId, SUM(TotalAmount) TOTAL FROM Order WHERE AccountId IN: accids AND Status <> 'Order Open' AND Status <> 'Order Cancelled' GROUP BY AccountId];
            Map < Id,
            Account > accountUpdateMap = new Map < Id,
            Account > ();
            //if (!orderTotalList.isEmpty()) {
                for (AggregateResult ar: [SELECT AccountId, SUM(TotalAmount) TOTAL FROM Order WHERE AccountId IN: accids AND Status <> 'Order Open' AND Status <> 'Order Cancelled' GROUP BY AccountId]) {
                    Account acc = new Account();
                    acc.Id = Id.valueOf(String.valueOf(ar.get('AccountId')));
                    acc.Order_Amount_Summary__c = Decimal.valueOf(String.valueOf(ar.get('TOTAL')));
                     acc.Order_Summary_Updated_Date__c = Date.today();
                    //setting othere amounts to 0 as it will be override if new value there
                    acc.Current_FY_Order_Summary__c=0;
                    acc.Previous_FY_Order_Summary__c=0;
                    accountUpdateMap.put(acc.Id, acc);
                }
            //}
            //TO DO: need to confirm what should be the Order Status for Opportunity filter WON=TRUE. Currently used 'Order Submitted'
            //AggregateResult[] prevFYOrderTotalList = [SELECT AccountId, SUM(TotalAmount) TOTAL FROM Order WHERE AccountId IN: accids AND Order_Created_Date__c = LAST_FISCAL_YEAR AND Status <>'Order Open' AND Status <> 'Order Cancelled' GROUP BY AccountId];
            //if (!prevFYOrderTotalList.isEmpty()) {
                for (AggregateResult ar: [SELECT AccountId, SUM(TotalAmount) TOTAL FROM Order WHERE AccountId IN: accids AND Order_Created_Date__c = LAST_FISCAL_YEAR AND Status <>'Order Open' AND Status <> 'Order Cancelled' GROUP BY AccountId]) {
                    Id accId = Id.valueOf(String.valueOf(ar.get('AccountId')));
                    if (!accountUpdateMap.containsKey(accId)) {
                        accountUpdateMap.put(accId,new Account(id=accId));
                    }
                    Account acc = accountUpdateMap.get(accId);
                    acc.Previous_FY_Order_Summary__c = Decimal.valueOf(String.valueOf(ar.get('TOTAL')));
                    /*if (accountUpdateMap.containsKey(accId)) {
                        Account acc = accountUpdateMap.get(accId);
                        acc.Previous_FY_Order_Summary__c = Decimal.valueOf(String.valueOf(ar.get('TOTAL')));
                    } else {
                        Account acc = new Account();
                        acc.Id = accId;
                        acc.Previous_FY_Order_Summary__c = Decimal.valueOf(String.valueOf(ar.get('TOTAL')));
                        accountUpdateMap.put(acc.Id, acc);
                    }*/
                }
            //}
            //TO DO: need to confirm what should be the Order Status for Opportunity filter WON=TRUE. Currently used 'Order Submitted' //CreatedDate
            //AggregateResult[] currFYOrderTotalList = [SELECT AccountId, SUM(TotalAmount) TOTAL FROM Order WHERE AccountId IN: accids AND Order_Created_Date__c = THIS_FISCAL_YEAR AND Status <>'Order Open' AND Status <> 'Order Cancelled' GROUP BY AccountId];
            //if (!currFYOrderTotalList.isEmpty()) {
                for (AggregateResult ar: [SELECT AccountId, SUM(TotalAmount) TOTAL FROM Order WHERE AccountId IN: accids AND Order_Created_Date__c = THIS_FISCAL_YEAR AND Status <>'Order Open' AND Status <> 'Order Cancelled' GROUP BY AccountId]) {
                    Id accId = Id.valueOf(String.valueOf(ar.get('AccountId')));
                    if (!accountUpdateMap.containsKey(accId)) {
                        accountUpdateMap.put(accId,new Account(id=accId));
                    }
                    Account acc = accountUpdateMap.get(accId);
                    acc.Current_FY_Order_Summary__c = Decimal.valueOf(String.valueOf(ar.get('TOTAL')));
                    acc.Order_Summary_Updated_Date__c = Date.today();
                    /*if (accountUpdateMap.containsKey(accId)) {
                        Account acc = accountUpdateMap.get(accId);
                        acc.Current_FY_Order_Summary__c = Decimal.valueOf(String.valueOf(ar.get('TOTAL')));
                    } else {
                        Account acc = new Account();
                        acc.Id = accId;
                        acc.Current_FY_Order_Summary__c = Decimal.valueOf(String.valueOf(ar.get('TOTAL')));
                        accountUpdateMap.put(acc.Id, acc);
                    }*/
                }
            //}
            System.debug('******Execute****accList***' + accountUpdateMap);
            if (!accountUpdateMap.isEmpty()) {
                Database.SaveResult[] accountList = Database.update(accountUpdateMap.values(), false); 
                
                list<Error_Log__c> errorLogsTobeInserted = new list<Error_Log__c>();
                for(integer itr=0; itr<accountList.size(); itr++){
                    if(!accountList[itr].isSuccess()){
   
                        Error_Log__c errLog = new Error_Log__c();
                        for(Database.Error err : accountList[itr].getErrors())
                        errLog.Trace__c = errLog.Trace__C + 'Error -' + string.valueOf(err.getMessage()) + ' Fields - '+ string.valueOf(err.getFields()) + '\n';
                        errLog.Object_Name__c = 'Exception IN ProcessOrderAmountBatchService';
                        errLog.Record_Id__c = accountUpdateMap.values().get(itr).id;
                        errorLogsTobeInserted.add(errLog);                    
                    }                
                } 
                if(!errorLogsTobeInserted.isEmpty())
                    insert errorLogsTobeInserted;        
                
            }   
        }Catch(Exception e){
            system.debug('error--'+e);
            system.debug('**Exception**'+e+'    MSG-'+e.getStackTraceString());
            /*Error_Log__c err = new Error_Log__c();
            err.Trace__c = e.getStackTraceString() + String.valueOf(e);
            err.Object_Name__c = 'Exception IN ProcessOrderAmountBatchService';
            err.Record_Id__c = String.join(new List<Id>(accids),',');   //if batch size is more than 1 it will store comma separated account ids
            insert err;*/
        }
    }

    global void finish(Database.BatchableContext BC) {
        System.debug('****ProcessOrderAmountBatchService****Finish****All Accounts Order Amount Summary***' + total);
    }
    
    public void execute(SchedulableContext SC) {
       
       ProcessOrderAmountBatchService job = new ProcessOrderAmountBatchService();
       Database.executeBatch(job,200); 
   
   }   
}