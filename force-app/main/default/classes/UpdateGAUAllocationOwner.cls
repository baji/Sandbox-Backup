/*
* Name  : UpdateGAUAllocationOwner
* Usage : This batch will update GAU allocation owner with the user selected in the related GAU's Missionary__c field.
*         This batch will be called by a schedule class which will pass only the data which to be updated.
*Developer : Mayur Soni (mayur@infoglen.com)
*/
global class UpdateGAUAllocationOwner implements Database.Batchable<sObject>{

   global final String Query;
   global final Set<id> GAUIds;

   global UpdateGAUAllocationOwner (String q,Set<id> ids){

      Query=q;
      GAUIds = ids;
   }

   global Database.QueryLocator start(Database.BatchableContext BC){
       String finalQ = GAUIds.isEmpty() ? query: query+' WHERE npsp__General_Accounting_Unit__c IN : GAUIds';
       System.debug('Final Q : '+ finalQ);
      return Database.getQueryLocator(finalQ);
   }

   global void execute(Database.BatchableContext BC, List<sObject> scope){
     //Make sure to not change owner if Opportunity or Contact is marked as Anonymous
     List<npsp__Allocation__c> allocationsToUpdate = new List<npsp__Allocation__c>();
     Set<Id> allocationGAUId = new Set<Id>();
     
    for(npsp__Allocation__c allo : (List<npsp__Allocation__c>)scope){
        if(allo.npsp__General_Accounting_Unit__c != null && !allo.npsp__Opportunity__r.Anonymous__c){
            //for individual
            if(allo.npsp__Opportunity__r.npsp__Primary_Contact__c!=null && !allo.npsp__Opportunity__r.npsp__Primary_Contact__r.Anonymous__c){
                 allo.OwnerId = allo.npsp__General_Accounting_Unit__r.Missionary__c;
                 allocationsToUpdate.add(allo);
                 //allocationVsGAUMap.put(allo.id,allo.npsp__General_Accounting_Unit__c);
            }else if(allo.npsp__Opportunity__r.AccountId!=null && allo.npsp__Opportunity__r.Account.Recordtype.Name!='Household Account'){//For Organization
                 allo.OwnerId = allo.npsp__General_Accounting_Unit__r.Missionary__c;
                 allocationsToUpdate.add(allo);
                 //allocationVsGAUMap.put(allo.id,allo.npsp__General_Accounting_Unit__c);
            }
        }
        allocationGAUId.add(allo.npsp__General_Accounting_Unit__c);
    }
    System.debug('allocationGAUId : '+allocationGAUId);
    System.debug('allocationsToUpdate : '+allocationsToUpdate);
    if(!allocationsToUpdate.isEmpty()){
        Database.SaveResult [] updateResult = Database.update(allocationsToUpdate,false);
        
    }
    if(!allocationGAUId.isEmpty()){
        //Once GAU Allocations are updated, set the IsUSMissionaryChanged__c field to FALSE for the completed GAUs.
        List<npsp__General_Accounting_Unit__c> GAUToUpdate = new List<npsp__General_Accounting_Unit__c>();
        for(Id gauId : allocationGAUId){
            npsp__General_Accounting_Unit__c gau = new npsp__General_Accounting_Unit__c();
            gau.id = gauId ;
            gau.IsUSMissionaryChanged__c = false;
            GAUToUpdate.add(gau);
        }
        System.debug('GAUToUpdate : '+GAUToUpdate);
        if(!GAUToUpdate.isEmpty())
            update GAUToUpdate;
    }
   
   }

   global void finish(Database.BatchableContext BC){
       
       System.debug('in Finish : '+bc.getJobId());
   }
}