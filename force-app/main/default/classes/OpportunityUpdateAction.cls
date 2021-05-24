/****************************************************************************************************************************************************************************************************************
Developer:  Ayesha Zulkha
Company:    Infoglen
Contact:    ayesha@Infoglen.com
Project:    Donation Management
Created:    02/19/2018 - <CRM - 130> Track down the opportunity which influenced the level change in Account
***************************************************************************************************************************************************************************************************************************************** **************/

public class OpportunityUpdateAction {
    public static void UpdateOpportunities(List<Opportunity> opptyIdList) {
        List<Account> listAccounts = new List<Account>();
        set<id> AccIds = new set<id>();
        Map<Id,List<opportunity>> AccOppMap = new Map<Id,List<opportunity>>();
        if(opptyIdList!=null){
            for(opportunity op:opptyIdList){
                if(op.id==null){
                    List<Opportunity> lstOppt = new List<Opportunity>();
                    lstOppt.add(op);
                    if(op.accountId!=null){
                    AccOppMap.put(op.accountId,lstOppt);
                    AccIds.add(op.accountid);
                    }
                }
                else{
                    if(op.accountId!=null)AccIds.add(op.accountid);
                }
            }
            AccIds.remove(null); 
            system.debug('accid$$$'+AccIds);
            List<opportunity> childOpptys = new List<opportunity>([select id,amount,accountid from opportunity where accountid in:AccIds]);
            if(childOpptys!=null){
                for(Opportunity opt:childOpptys){
                    if(AccOppMap.containsKey(opt.accountId))
                    {
                        List<Opportunity> lstOppt = AccOppMap.get(opt.accountId);
                        lstOppt.add(opt);
                    }
                    else
                    {
                        List<Opportunity> lstOppt = new List<Opportunity>();
                        lstOppt.add(opt);
                        AccOppMap.put(opt.accountId,lstOppt);
                    }
                }
                if(AccOppMap!=null){
                    List<npsp__Level__c> levelsList = new List<npsp__Level__c>([select id,name,npsp__Active__c,npsp__Maximum_Amount__c,npsp__Minimum_Amount__c,npsp__Target__c from npsp__Level__c where npsp__Target__c = 'Account' and npsp__Active__c=true and (name = 'Major' or name = 'Mid' or name = 'Mass')]);
                    Decimal compareAmount = 0;
                    for(opportunity opt:opptyIdList){
                        List<Opportunity> opptyList = new List<Opportunity>(AccOppMap.get(opt.accountId));
                         for(Opportunity opp:opptyList){
                            if(opp.id!=opt.id && opp.amount>0){
                                compareAmount += opp.amount;
                            }
                            else if(opt.amount>0){
                                compareAmount+= opt.amount;
                            }   
                        }
                        if(compareAmount>0){
                            for(npsp__Level__c npLevel:levelsList){
                                 if(npLevel.npsp__Maximum_Amount__c==null){
                                    if(compareAmount >= npLevel.npsp__Minimum_Amount__c){
                                        opt.opportunity_level__c = npLevel.name;
                                    }
                                }
                                else if(compareAmount >= npLevel.npsp__Minimum_Amount__c && compareAmount < npLevel.npsp__Maximum_Amount__c){
                                    opt.opportunity_level__c = npLevel.name;
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}