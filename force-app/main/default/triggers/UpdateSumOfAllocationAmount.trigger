/****************************************************************************************************************************************************************************************************************
Developer:  Imran
Company:    Infoglen
Contact:    imran@Infoglen.com
Project:    Donation Management
Created:    04/23/2018 - <CRM - 130> Allocation trigger to update sum of allocation amount and GAU with amount in opportunity
***************************************************************************************************************************************************************************************************************************************** **************/
trigger UpdateSumOfAllocationAmount on npsp__Allocation__c (After Insert,After Update,After Delete,After Undelete) {
    Decimal totalAmount = 0;
    String fundWithAmount;
    if(trigger.isInsert || trigger.isUndelete){
        Set<Id> opportunityId = new Set<Id>();
        for(npsp__Allocation__c obj:trigger.new){
            opportunityId.add(obj.npsp__Opportunity__c);
        }
        List<Opportunity> listOpp = new List<Opportunity>(); 
            for (Opportunity obj:[Select Id,Total_Allocation_Amount__c,Fund_With_Amount__c,(Select Id,npsp__Amount__c,npsp__General_Accounting_Unit__r.Name From npsp__Allocations__r) From Opportunity Where Id IN :opportunityId]){
                if(!(obj.npsp__Allocations__r).isEmpty()){
                    for(npsp__Allocation__c all : obj.npsp__Allocations__r){
                        totalAmount = totalAmount + all.npsp__Amount__c;
                        if(fundWithAmount == null)
                            fundWithAmount = all.npsp__General_Accounting_Unit__r.Name+' - '+all.npsp__Amount__c;
                        else
                            fundWithAmount = fundWithAmount+' ; '+all.npsp__General_Accounting_Unit__r.Name+' - '+all.npsp__Amount__c;
                    } 
                    obj.Total_Allocation_Amount__c= totalAmount;
                    obj.Fund_With_Amount__c = fundWithAmount;
                    listOpp.add(obj);
                    totalAmount = 0;
                    fundWithAmount = null;
                }                    
            }
        update listOpp;
    }
    if(trigger.isUpdate){
        Set<Id> opportunityId = new Set<Id>();
        for(npsp__Allocation__c obj:trigger.new){
            opportunityId.add(obj.npsp__Opportunity__c);
        }
        List<Opportunity> listOpp = new List<Opportunity>(); 
            for (Opportunity obj:[Select Id,Total_Allocation_Amount__c,Fund_With_Amount__c,(Select Id,npsp__Amount__c,npsp__General_Accounting_Unit__r.Name From npsp__Allocations__r) From Opportunity Where Id IN :opportunityId]){
                if(!(obj.npsp__Allocations__r).isEmpty()){
                    for(npsp__Allocation__c all : obj.npsp__Allocations__r){
                        totalAmount = totalAmount + all.npsp__Amount__c;
                        if(fundWithAmount == null)
                            fundWithAmount = all.npsp__General_Accounting_Unit__r.Name+' - '+all.npsp__Amount__c;
                        else
                            fundWithAmount = fundWithAmount+' ; '+all.npsp__General_Accounting_Unit__r.Name+' - '+all.npsp__Amount__c;
                    } 
                    obj.Total_Allocation_Amount__c= totalAmount;
                    obj.Fund_With_Amount__c = fundWithAmount;
                    listOpp.add(obj);
                    totalAmount = 0;
                    fundWithAmount = null;
                }                    
            }
        update listOpp;
    }
    if(trigger.isDelete){
        Set<Id> opportunityId = new Set<Id>();
        for(npsp__Allocation__c obj:trigger.old){
            opportunityId.add(obj.npsp__Opportunity__c);
        }
        List<Opportunity> listOpp = new List<Opportunity>(); 
            for (Opportunity obj:[Select Id,Total_Allocation_Amount__c,Fund_With_Amount__c,(Select Id,npsp__Amount__c,npsp__General_Accounting_Unit__r.Name From npsp__Allocations__r) From Opportunity Where Id IN :opportunityId]){
                if(!(obj.npsp__Allocations__r).isEmpty()){
                    for(npsp__Allocation__c all : obj.npsp__Allocations__r){
                        totalAmount = totalAmount + all.npsp__Amount__c;
                        if(fundWithAmount == null)
                            fundWithAmount = all.npsp__General_Accounting_Unit__r.Name+' - '+all.npsp__Amount__c;
                        else
                            fundWithAmount = fundWithAmount+' ; '+all.npsp__General_Accounting_Unit__r.Name+' - '+all.npsp__Amount__c;
                    } 
                    obj.Total_Allocation_Amount__c= totalAmount;
                    obj.Fund_With_Amount__c = fundWithAmount;
                    listOpp.add(obj);
                    totalAmount = 0;
                    fundWithAmount = null;
                }                    
            }
        update listOpp;
    }
}