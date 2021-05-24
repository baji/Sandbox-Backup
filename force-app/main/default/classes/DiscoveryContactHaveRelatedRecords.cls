global class DiscoveryContactHaveRelatedRecords implements Database.Batchable<sObject>,Database.Stateful{
    global  List<String> csvRowValues = new List<String>();
    global Double totalContact = 0;
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String accounthouseholdId = '012f4000000nLu0';
        String query = 'SELECT Id,Name FROM contact where Account.recordTypeId!=:accounthouseholdId but not internaltion church and business unit';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> contactListChunk) {
        system.debug(': Heap size is ' + limits.getHeapSize() + ' enforced is ' + limits.getLimitHeapSize());

        List<Contact> contactList = new List<Contact>();
        contactList = [Select id , name ,Email,Gigya_UID__c,Constituent_Id__c,Account.CreatedDate,Account.lastModifiedDate,Account.RecordType.name,CreatedDate,lastModifiedDate,(Select id,lastModifiedDate from ActivityHistories order by lastmodifieddate desc limit 1),(Select id,lastModifiedDate from OpenActivities order by lastmodifieddate desc limit 1),(Select id,lastModifiedDate from TT_Credits__r order by lastmodifieddate desc limit 1),(Select id,lastModifiedDate from dsfs__DocuSign_Status__r order by lastmodifieddate desc limit 1),(Select id,lastModifiedDate from npe4__Relationships__r order by lastmodifieddate desc limit 1),(Select id,lastModifiedDate from attachments order by lastmodifieddate desc limit 1),(Select id,lastModifiedDate from notes order by lastmodifieddate desc limit 1),(Select Id,lastModifiedDate from Order_Contact_Roles__r order by lastmodifieddate desc limit 1),(Select Id,lastModifiedDate from npe5__Affiliations__r order by lastmodifieddate desc limit 1),(Select Id,lastModifiedDate from Opportunities__r order by lastmodifieddate desc limit 1),(Select Id,lastModifiedDate from CampaignMembers order by lastmodifieddate desc limit 1),(Select Id,lastModifiedDate from R00N50000001IDTvEAO__r order by lastmodifieddate desc limit 1),(Select Id,lastModifiedDate from Membership_Acceptances__r order by lastmodifieddate desc limit 1) from contact where Id IN :contactListChunk];
        System.debug('contactList-->'+contactList);
        Boolean isRelatedListPresent = false;
        String affilaitionDate = '**BLANK**';
        String OrderContactDate = '**BLANK**';
        String OppDate = '**BLANK**';
        String CampaignmemDate = '**BLANK**';
        String xyzDate = '**BLANK**';
        String memberShipDate = '**BLANK**';
        String activityHisDate = '**BLANK**';
        String OpenActivityDate = '**BLANK**';
        String TTCreditDate = '**BLANK**';
        String docusignStatusDate = '**BLANK**';
        String relationShipDate = '**BLANK**';
        String AttachmentDate = '**BLANK**';
        String notesDate = '**BLANK**';
        for(contact con : contactList){
            isRelatedListPresent = false;
            if(con.npe5__Affiliations__r !=  null && !con.npe5__Affiliations__r.isEmpty()){
                System.debug('con-------.npe5__Affiliations__r='+con.npe5__Affiliations__r);
                isRelatedListPresent = true;
                affilaitionDate = String.valueOf(con.npe5__Affiliations__r[0].LastmodifiedDate);
            }
            if( con.Order_Contact_Roles__r !=  null && !con.Order_Contact_Roles__r.isEmpty()){
                System.debug('con-------.Order_Contact_Roles__r='+con.Order_Contact_Roles__r );
                isRelatedListPresent = true;
                OrderContactDate = String.valueOf(con.Order_Contact_Roles__r[0].LastmodifiedDate);
            }
            if( con.Opportunities__r !=  null && !con.Opportunities__r.isEmpty()){
                System.debug('con-------.Opportunities__r='+con.Opportunities__r );
                isRelatedListPresent = true;
                OppDate = String.valueOf(con.Opportunities__r[0].LastmodifiedDate);
            }
            if( con.CampaignMembers !=  null && !con.CampaignMembers.isEmpty()){
                System.debug('con-------.CampaignMembers='+con.CampaignMembers );
                isRelatedListPresent = true;
                CampaignmemDate = String.valueOf(con.CampaignMembers[0].LastmodifiedDate);
            }
            if( con.R00N50000001IDTvEAO__r !=  null  && !con.R00N50000001IDTvEAO__r.isEmpty()){
                System.debug('con-------.R00N50000001IDTvEAO__r='+con.R00N50000001IDTvEAO__r);
                isRelatedListPresent = true;
                xyzDate = String.valueOf(con.R00N50000001IDTvEAO__r[0].LastmodifiedDate);
            }
            if(con.Membership_Acceptances__r !=  null && !con.Membership_Acceptances__r.isEmpty()){
                System.debug('con-------.Membership_Acceptances__r='+con.Membership_Acceptances__r );
                isRelatedListPresent = true;
                memberShipDate = String.valueOf(con.Membership_Acceptances__r[0].LastmodifiedDate);
            }
            /**/
            if( con.ActivityHistories !=  null && !con.ActivityHistories.isEmpty()){
                System.debug('con-------.ActivityHistories='+con.ActivityHistories );
                isRelatedListPresent = true;
                activityHisDate = String.valueOf(con.ActivityHistories[0].LastmodifiedDate);
            }
            if(con.OpenActivities !=  null && !con.OpenActivities.isEmpty()){
                System.debug('con-------.OpenActivities='+con.OpenActivities );
                isRelatedListPresent = true;
                OpenActivityDate = String.valueOf(con.OpenActivities[0].LastmodifiedDate);
            }
            if( con.TT_Credits__r !=  null && !con.TT_Credits__r.isEmpty()){
                System.debug('con-------.TT_Credits__r='+con.TT_Credits__r );
                isRelatedListPresent = true;
                TTCreditDate = String.valueOf(con.TT_Credits__r[0].LastmodifiedDate);
                
            }
            if( con.dsfs__DocuSign_Status__r !=  null && !con.dsfs__DocuSign_Status__r.isEmpty()){
                System.debug('con.dsfs__DocuSign_Status__r='+con.dsfs__DocuSign_Status__r );
                isRelatedListPresent = true;
                docusignStatusDate = String.valueOf(con.dsfs__DocuSign_Status__r[0].LastmodifiedDate);
                
            }
            if( con.npe4__Relationships__r !=  null && !con.npe4__Relationships__r.isEmpty()){
                System.debug('con.npe4__Relationships__r='+con.npe4__Relationships__r );
                isRelatedListPresent = true;
                relationShipDate = String.valueOf(con.npe4__Relationships__r[0].LastmodifiedDate);
                
            }
            if( con.attachments !=  null && !con.attachments.isEmpty()){
                System.debug('con-------.attachments='+con.attachments );
                isRelatedListPresent = true;
                AttachmentDate = String.valueOf(con.attachments[0].LastmodifiedDate);
                
            }
            if( con.notes !=  null && !con.notes.isEmpty()){
                System.debug('con-------.notes='+con.notes );
                isRelatedListPresent = true;
                notesDate = String.valueOf(con.notes[0].LastmodifiedDate);
                
            }
            if(isRelatedListPresent){
                totalContact = totalContact +1;
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
                
                String rowVal = cId+','+Name+','+acCreadtedDate+','+acLastModDate+','+acRecordTypeName+','+conCreadtedDate+','+conLastModDate+','+email+','+guid+','+Constituent+','+affilaitionDate+','+OrderContactDate+','+OppDate+','+CampaignmemDate+','+xyzDate+','+memberShipDate+','+activityHisDate+','+OpenActivityDate+','+TTCreditDate+','+docusignStatusDate+','+relationShipDate+','+AttachmentDate+','+notesDate;
                csvRowValues.add(rowVal);  
            }
            
        }
        try {
            
        }catch(Exception e){
            System.debug('get exception on line number-->'+e.getLineNumber()+' error is=>'+e.getMessage());
        }
        
    }   
    
    global void finish(Database.BatchableContext BC) {
        System.debug('totalContact==>'+totalContact);
        System.debug('******FINISH *****');
        // execute any post-processing operations
        String csvColumnHeader = 'Id,Name,Account Created Date,Account Lastmodified Date , Account RecordTypeName,Contact created date , Contact Lastmodifed date, Email , GUID,Constituent,Affiliations,Order_Contact_Roles,Opportunities,CampaignMembers,R00N50000001IDTvEAO,Membership_Acceptances,ActivityHistories,OpenActivities,TT_Credits,DocuSign_Status,Relationships,attachments,notes \n';
        System.debug('csvRowValues->'+csvRowValues);
        String csvFile = csvColumnHeader + String.join(csvRowValues,'\n');
        Attachment at = new Attachment();
        at.parentId = '0030S00000O7BYzQAN';
        at.Name = 'NO_HOUSEHOULD_ACCOUNT_HAVE_relatedRecords-'+datetime.now()+'.csv';
        at.Body = Blob.valueOf(csvFile);
        insert at;
        System.debug('at->'+at);
    }
}