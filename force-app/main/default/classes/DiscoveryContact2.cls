global class DiscoveryContact2 implements Database.Batchable<sObject>,Database.Stateful{
    global  List<String> csvRowValues = new List<String>();
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String accounthouseholdId = '012f4000000nLu0';
        String query = 'SELECT Id,Name FROM contact where Account.recordTypeId!=:accounthouseholdId ';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> contactListChunk) {
        List<Contact> contactList = new List<Contact>();
        contactList = [Select id , name ,Email,Gigya_UID__c,Constituent_Id__c,Account.CreatedDate,Account.lastModifiedDate,Account.RecordType.name,CreatedDate,lastModifiedDate,(Select id,lastModifiedDate from ActivityHistories order by lastmodifieddate desc limit 1),(Select id,lastModifiedDate from OpenActivities order by lastmodifieddate desc limit 1),(Select id,lastModifiedDate from TT_Credits__r order by lastmodifieddate desc limit 1),(Select id,lastModifiedDate from dsfs__DocuSign_Status__r order by lastmodifieddate desc limit 1),(Select id,lastModifiedDate from npe4__Relationships__r order by lastmodifieddate desc limit 1),(Select id,lastModifiedDate from attachments order by lastmodifieddate desc limit 1),(Select id,lastModifiedDate from notes order by lastmodifieddate desc limit 1),(Select Id,lastModifiedDate from Order_Contact_Roles__r order by lastmodifieddate desc limit 1),(Select Id,lastModifiedDate from npe5__Affiliations__r order by lastmodifieddate desc limit 1),(Select Id,lastModifiedDate from Opportunities__r order by lastmodifieddate desc limit 1),(Select Id,lastModifiedDate from CampaignMembers order by lastmodifieddate desc limit 1),(Select Id,lastModifiedDate from R00N50000001IDTvEAO__r order by lastmodifieddate desc limit 1),(Select Id,lastModifiedDate from Membership_Acceptances__r order by lastmodifieddate desc limit 1) from contact where Id IN :contactListChunk];
        System.debug('contactList-->'+contactList);
        Boolean isRelatedListPresent = false;
        for(contact con : contactList){
            isRelatedListPresent = false;
            if(con.npe5__Affiliations__r !=  null && !con.npe5__Affiliations__r.isEmpty()){
                System.debug('con-------.npe5__Affiliations__r='+con.npe5__Affiliations__r);
                isRelatedListPresent = true;
            }
            if(!isRelatedListPresent && con.Order_Contact_Roles__r !=  null && !con.Order_Contact_Roles__r.isEmpty()){
                System.debug('con-------.Order_Contact_Roles__r='+con.Order_Contact_Roles__r );
                isRelatedListPresent = true;
            }
            if(!isRelatedListPresent && con.Opportunities__r !=  null && !con.Opportunities__r.isEmpty()){
                System.debug('con-------.Opportunities__r='+con.Opportunities__r );
                isRelatedListPresent = true;
            }
            if(!isRelatedListPresent && con.CampaignMembers !=  null && !con.CampaignMembers.isEmpty()){
                System.debug('con-------.CampaignMembers='+con.CampaignMembers );
                isRelatedListPresent = true;
            }
            if(!isRelatedListPresent && con.R00N50000001IDTvEAO__r !=  null  && !con.R00N50000001IDTvEAO__r.isEmpty()){
                System.debug('con-------.R00N50000001IDTvEAO__r='+con.R00N50000001IDTvEAO__r);
                isRelatedListPresent = true;
            }
            if(!isRelatedListPresent && con.Membership_Acceptances__r !=  null && !con.Membership_Acceptances__r.isEmpty()){
                System.debug('con-------.Membership_Acceptances__r='+con.Membership_Acceptances__r );
                isRelatedListPresent = true;
            }
            /**/
            if(!isRelatedListPresent && con.ActivityHistories !=  null && !con.ActivityHistories.isEmpty()){
                System.debug('con-------.ActivityHistories='+con.ActivityHistories );
                isRelatedListPresent = true;
            }
            if(!isRelatedListPresent && con.OpenActivities !=  null && !con.OpenActivities.isEmpty()){
                System.debug('con-------.OpenActivities='+con.OpenActivities );
                isRelatedListPresent = true;
            }
            if(!isRelatedListPresent && con.TT_Credits__r !=  null && !con.TT_Credits__r.isEmpty()){
                System.debug('con-------.TT_Credits__r='+con.TT_Credits__r );
                isRelatedListPresent = true;
            }
            if(!isRelatedListPresent && con.dsfs__DocuSign_Status__r !=  null && !con.dsfs__DocuSign_Status__r.isEmpty()){
                System.debug('con.dsfs__DocuSign_Status__r='+con.dsfs__DocuSign_Status__r );
                isRelatedListPresent = true;
            }
            if(!isRelatedListPresent && con.npe4__Relationships__r !=  null && !con.npe4__Relationships__r.isEmpty()){
                System.debug('con.npe4__Relationships__r='+con.npe4__Relationships__r );
                isRelatedListPresent = true;
            }
            if(!isRelatedListPresent && con.attachments !=  null && !con.attachments.isEmpty()){
                System.debug('con-------.attachments='+con.attachments );
                isRelatedListPresent = true;
            }
            if(!isRelatedListPresent && con.notes !=  null && !con.notes.isEmpty()){
                System.debug('con-------.notes='+con.notes );
                isRelatedListPresent = true;
            }
            if(!isRelatedListPresent){
                System.debug('************ROW ADDED*****************');
                String cId = con.Id;
                String Name = con.Name!=null ? con.Name : 'NAME BLANK';
                String acCreadtedDate = '**BLANK**';
                String acLastModDate = '**BLANK**';
                String acRecordTypeName = '**BLANK**';
                if(con.Account!=null){
                    acCreadtedDate = con.Account.createdDate!=null ? String.valueOf(con.Account.createdDate ): '**BLANK**';
                    acLastModDate = con.Account.LastModifiedDate!=null ? String.valueOf(con.Account.LastModifiedDate ): '**BLANK**';
                    acRecordTypeName = con.Account.RecordType.Name!=null ? con.Account.RecordType.Name : '**BLANK**'; 
                }
                
                
                String conCreadtedDate = con.createdDate!=null ? String.valueOf(con.createdDate ): '**BLANK**';
                String conLastModDate = con.LastModifiedDate!=null ? String.valueOf(con.LastModifiedDate ): '**BLANK**';
                
                String email = con.email!=null ? con.email : '**BLANK**';
                String guid = con.Gigya_UID__c!=null ? con.Gigya_UID__c : '**BLANK**';
                String Constituent = con.Constituent_Id__c!=null ? con.Constituent_Id__c : '**BLANK**';
                
                String rowVal = cId+','+Name+','+acCreadtedDate+','+acLastModDate+','+acRecordTypeName+','+conCreadtedDate+','+conLastModDate+','+email+','+guid+','+Constituent;
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
        String csvColumnHeader = 'Id,Name,Account Created Date,Account Lastmodified Date , Account RecordTypeName,Contact created date , Contact Lastmodifed date, Email , GUID,Constituent \n';
        System.debug('csvRowValues->'+csvRowValues);
        String csvFile = csvColumnHeader + String.join(csvRowValues,'\n');
        Attachment at = new Attachment();
        at.parentId = '0030S00000O7BYzQAN';
        at.Name = 'NO_HOUSEHOULD_ACCOUNT-'+datetime.now()+'.csv';
        at.Body = Blob.valueOf(csvFile);
        insert at;
        System.debug('at->'+at);
    }
}