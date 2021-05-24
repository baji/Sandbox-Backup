/*
@Company:Infoglen
@Author:Imran
@Creation date:24/11/2017
Reference:
*/
/**
 * Class S2SDynamicAccountObjectUpdate
 
 * This batch class is used to update all lookup fields of a Account Object
 */
global class S2SDynamicAccountObjectUpdate implements Database.Batchable<sObject>{
      
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator('SELECT Id,Source_Associated_Church__c,Source_MyAwana_Last_updated_By__c,Source_Commander__c,Source_Mozo_Free_Trial_ContactID__c,Source_Default_Shipping_Address__c,Associated_Church__c,Commander__c,Mozo_Free_Trial_ContactID__c,Default_Shipping_Address__c,MyAwana_Last_updated_By__c FROM Account WHERE Source_Account_Rec_Id__c!= null');
    }
    global void execute(Database.BatchableContext BC, List<Account>scope){
        List<String> listoldId = new List<String>();
        for(Account obj : scope){           
            listoldId.add(obj.Source_Associated_Church__c);  
            listoldId.add(obj.Source_MyAwana_Last_updated_By__c);
            listoldId.add(obj.Source_Commander__c); 
            listoldId.add(obj.Source_Mozo_Free_Trial_ContactID__c); 
            listoldId.add(obj.Source_Default_Shipping_Address__c); 
        }
        
        Map<Id,Id> mapWithNewOldId = S2SPartnerNetworkRecordUtility.getData(listoldId);
        for(Account obj : scope){          
            obj.Associated_Church__c = mapWithNewOldId.containsKey(obj.Source_Associated_Church__c)?mapWithNewOldId.get(obj.Source_Associated_Church__c):null;     
            obj.MyAwana_Last_updated_By__c = mapWithNewOldId.containsKey(obj.Source_MyAwana_Last_updated_By__c)?mapWithNewOldId.get(obj.Source_MyAwana_Last_updated_By__c):null;
            obj.Commander__c = mapWithNewOldId.containsKey(obj.Source_Commander__c)?mapWithNewOldId.get(obj.Source_Commander__c):null;
            obj.Mozo_Free_Trial_ContactID__c = mapWithNewOldId.containsKey(obj.Source_Mozo_Free_Trial_ContactID__c)?mapWithNewOldId.get(obj.Source_Mozo_Free_Trial_ContactID__c):null;
            obj.Default_Shipping_Address__c = mapWithNewOldId.containsKey(obj.Source_Default_Shipping_Address__c)?mapWithNewOldId.get(obj.Source_Default_Shipping_Address__c):null;
        }       
        update scope;                
    }
    global void finish(Database.BatchableContext BC){
    
    }
}