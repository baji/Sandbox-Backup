/*
* Name  : ScheduleGAUAllocationBatch
* Usage : This class will retrieve GAUs whose IsUSMissionaryChanged__c field is true and prepare query of GAU Allocation and pass it to batch. This will be scheduled to run at after 1 minute from now.
* Developer : Mayur Soni (mayur@infoglen.com)
*/
global class ScheduleGAUAllocationBatch{

   private static Boolean runAllocationOwner=true;
   
   public static boolean runOnceAllocationOwner(){
        if(runAllocationOwner)
        {
         runAllocationOwner= false;
         return true;
        }
        else
        {
            return runAllocationOwner;
        }
   }
   
   /*global void execute(SchedulableContext sc) {
      System.debug('in schedule execute : '+sc.getTriggerId());  
      invokeBatch();
      
   }*/
   
   public static void invokeBatch(){
       //this code should not execute if called from batch
       System.debug('is batch : '+System.isBatch());
       System.debug('is batch : '+System.isFuture());
       if(!System.isBatch() && !System.isFuture()){
           //Retrieve those data whose IsUSMissionaryChanged__c field is true in GAU object
          Map<Id,npsp__General_Accounting_Unit__c> gauList = new Map<id,npsp__General_Accounting_Unit__c>([SELECT Id,IsUSMissionaryChanged__c,Missionary__c FROM npsp__General_Accounting_Unit__c WHERE IsUSMissionaryChanged__c=TRUE]);
          if(!gauList.isEmpty()){
              Set<Id> gauIds = gauList.keySet();
              System.debug('gauIds : '+gauIds);
              String query = 'SELECT Id,OwnerId,npsp__General_Accounting_Unit__c,npsp__Opportunity__r.Anonymous__c,';
              query+='npsp__Opportunity__r.npsp__Primary_Contact__c,npsp__Opportunity__r.npsp__Primary_Contact__r.Anonymous__c,';
              query+='npsp__General_Accounting_Unit__r.Missionary__c,npsp__Opportunity__r.AccountId,';
              query+='npsp__Opportunity__r.Account.Recordtype.Name ';
              query+=' FROM npsp__Allocation__c';
              UpdateGAUAllocationOwner  batch = new UpdateGAUAllocationOwner(query,gauIds); 
              //use system.schedulebatch to execute one time batch after 1 min
              String cronID = System.scheduleBatch(batch, 'Allocation owner batch', 1);
              System.debug('after scheduling batch : '+cronID);
              //database.executebatch(batch);
          }
      }
   }
}