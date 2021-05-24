/************************************************************************************************************************************************************
    Programmer: Ayesha Zulkha
    Company:    Awana
    Project:    Donation management
    Original:   2/16/2018  - Level Assignment on Opportunity
    *************************************************************************************************************************************************************/
    public class UpdateAccountSoftCredit{
        
        public static Map<id ,opportunity> oppIdMap = new Map<id ,opportunity>();
        
        public static void accountUpdate(List<Opportunity> opptyIdList){
        if(checkRecursive.runOnce())
        {
        list<contact> conList = new list<contact>();
        list<account> accList = new list<account>();
        list<opportunity> oppList = new list<opportunity>();
        set<Id> accId = new set<id>();
        for(opportunity op:opptyIdList){
            if(op.Soft_Credit_Organization__c!=null){
            if(op.Soft_Credit_Amount__c==null || op.Soft_Credit_Amount__c>op.amount){
                  op.addError(Label.SoftCreditValidation);
                }else{
                    oppList.add(op);
                    accId.add(op.Soft_Credit_Organization__c);
                }
            
            }
        }accId.remove(null);
        if(accId.size()>0){
        Map<id,account> accMap = new Map<id,account>([select npe01__One2OneContact__c,recordtype.name,BillingPostalCode,Physical_Zip__c,name from account where id in:accid]);
         if(accMap.size()>0){
         for(opportunity op:oppList){
                 
                 if(accMap.get(op.Soft_Credit_Organization__c).recordtype.name == 'US Organization' || accMap.get(op.Soft_Credit_Organization__c).recordtype.name == 'Organization'){
                    oppIdMap.put(op.Soft_Credit_Organization__c,op);
                    if(accMap.get(op.Soft_Credit_Organization__c).npe01__One2OneContact__c!=null){
                       system.debug('***opcon'+accMap.get(op.Soft_Credit_Organization__c).npe01__One2OneContact__c);
                       contactroleCreation(accMap.get(op.Soft_Credit_Organization__c).npe01__One2OneContact__c,op);
                    }
                    else{
                        contact con = new contact();
                        con.firstname = accMap.get(op.Soft_Credit_Organization__c).Physical_Zip__c+' - '+accMap.get(op.Soft_Credit_Organization__c).name+' -';
                        con.lastname = 'Soft Credit Contact';
                        con.accountid = op.Soft_Credit_Organization__c;
                        conList.add(con);
                        
                    }
                }
                
            }
            Database.SaveResult[] srList = Database.insert(conList, false);
            set<id> conIds = new set<id>();
            
            // Iterate through each returned result
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    
                    System.debug('Successfully inserted contact. contact ID: ' + sr.getId());
                    conIds.add(sr.getId());
                    
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('contact fields that affected this error: ' + err.getFields());
                    }
                }
            }
            for(contact con:[select id,accountid from contact where id in:conIds]){
                opportunity op = oppIdMap.get(con.accountid);
                contactroleCreation(con.id,op);
                account ac = accMap.get(con.accountid);
                ac.npe01__One2OneContact__c = con.id;
                accList.add(ac);
            }
            try{
                Database.update(accList,false);
            }
            catch(exception e){
            }
        }
        }
        }
        }
        public static void contactRoleCreation(id conId,opportunity op){
            
            list<npsp__Partial_Soft_Credit__c> contactRoleList = new list<npsp__Partial_Soft_Credit__c>();
                       npsp__Partial_Soft_Credit__c np = new npsp__Partial_Soft_Credit__c();
                       np.npsp__Contact__c =  conId;
                       np.npsp__Opportunity__c = op.id;
                       np.npsp__Role_Name__c = 'Soft Credit';
                       if(op.Soft_Credit_Amount__c!=null){
                           np.npsp__Amount__c = op.Soft_Credit_Amount__c;
                       }
                       else{
                           np.npsp__Amount__c = op.amount*0.1;
                       }
                       contactRoleList.add(np);
                       try{
                           Database.upsert(contactRoleList,false);
                       }
                       catch(exception e){
                       }
        }
        
    }