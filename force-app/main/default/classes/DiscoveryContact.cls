global class DiscoveryContact implements Database.Batchable<sObject>,Database.Stateful{
    global  List<String> csvRowValues = new List<String>();
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String accounthouseholdId = '012f4000000nLu0';
        String query = 'SELECT Id,Name,(Select Id from npe5__Affiliations__r limit 1),(Select Id from Opportunities__r limit 1),(Select Id from CampaignMembers limit 1),(Select Id from R00N50000001IDTvEAO__r limit 1),(Select Id from Membership_Acceptances__r limit 1) FROM contact where Account.recordTypeId=:accounthouseholdId';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> contactList) {
        System.debug('contactList-->'+contactList);
        Boolean isRelatedListPresent = false;
        for(contact con : contactList){
            isRelatedListPresent = false;
            if(con.npe5__Affiliations__r !=  null && !con.npe5__Affiliations__r.isEmpty()){
                System.debug('con.npe5__Affiliations__r='+con.npe5__Affiliations__r);
                isRelatedListPresent = true;
            }
            if(!isRelatedListPresent && con.Opportunities__r !=  null && !con.Opportunities__r.isEmpty()){
                System.debug('con.Opportunities__r='+con.Opportunities__r );
                isRelatedListPresent = true;
            }
            if(!isRelatedListPresent && con.CampaignMembers !=  null && !con.CampaignMembers.isEmpty()){
                System.debug('con.CampaignMembers='+con.CampaignMembers );
                isRelatedListPresent = true;
            }
            if(!isRelatedListPresent && con.R00N50000001IDTvEAO__r !=  null  && !con.R00N50000001IDTvEAO__r.isEmpty()){
                System.debug('con.R00N50000001IDTvEAO__r='+con.R00N50000001IDTvEAO__r);
                isRelatedListPresent = true;
            }
            if(!isRelatedListPresent && con.Membership_Acceptances__r !=  null && !con.Membership_Acceptances__r.isEmpty()){
                System.debug('con.Membership_Acceptances__r='+con.Membership_Acceptances__r );
                isRelatedListPresent = true;
            }
            if(!isRelatedListPresent){
                System.debug('************ROW ADDED*****************');
                String cId = con.Id;
                String Name = con.Name!=null ? con.Name : 'NAME BLANK';
                String rowVal = cId+','+Name;
                csvRowValues.add(rowVal);  
            }
            
        }
        try {
            
        }catch(Exception e){
            System.debug('get exception on line number-->'+e.getLineNumber()+' error is=>'+e.getMessage());
        }
        
    }   
    
    global void finish(Database.BatchableContext BC) {
        System.debug('******FINISH *****');
        // execute any post-processing operations
        String csvColumnHeader = 'Id,Name\n';
        System.debug('csvRowValues->'+csvRowValues);
        String csvFile = csvColumnHeader + String.join(csvRowValues,'\n');
        Attachment at = new Attachment();
        at.parentId = '0030S00000O7BYzQAN';
        at.Name = 'newcontacts.csv';
        at.Body = Blob.valueOf(csvFile);
        insert at;
        System.debug('at->'+at);
    }
}