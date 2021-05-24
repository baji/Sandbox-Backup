global class DiscoveryContactToObjSave implements Database.Batchable<sObject>,Database.Stateful{
    // no related list
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String accounthouseholdId = '012f4000000nLu0';
        String businessUnit = '012f4000000dA7N';
        String internaltionalChurch = '012f4000000dA7T';
        String query = 'SELECT Id,Name FROM contact where Account.recordTypeId!=:accounthouseholdId AND Account.recordTypeId!=:businessUnit AND Account.recordTypeId!=:internaltionalChurch';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> contactListChunk) {
        try {
            List<Contact> contactList = new List<Contact>();
            contactList = [Select id , name ,Email,Gigya_UID__c,Constituent_Id__c,AccountID , Account.CreatedDate,Account.lastModifiedDate,
            Account.RecordType.name,CreatedDate,lastModifiedDate,
                           (Select id,lastModifiedDate from ActivityHistories order by lastmodifieddate desc limit 1),
                           (Select id,lastModifiedDate from OpenActivities order by lastmodifieddate desc limit 1),
                           (Select id,lastModifiedDate from TT_Credits__r order by lastmodifieddate desc limit 1),
                           (Select id,lastModifiedDate from dsfs__DocuSign_Status__r order by lastmodifieddate desc limit 1),
                           (Select id,lastModifiedDate from npe4__Relationships__r order by lastmodifieddate desc limit 1),
                           (Select id,lastModifiedDate from attachments order by lastmodifieddate desc limit 1),
                           (Select id,lastModifiedDate from notes order by lastmodifieddate desc limit 1),
                           (Select Id,lastModifiedDate from Order_Contact_Roles__r order by lastmodifieddate desc limit 1),
                           (Select Id,lastModifiedDate from npe5__Affiliations__r order by lastmodifieddate desc limit 1),
                           (Select Id,lastModifiedDate from Opportunities__r order by lastmodifieddate desc limit 1),
                           (Select Id,lastModifiedDate from CampaignMembers order by lastmodifieddate desc limit 1),
                           (Select Id,lastModifiedDate from R00N50000001IDTvEAO__r order by lastmodifieddate desc limit 1),
                           (Select Id,lastModifiedDate from Membership_Acceptances__r order by lastmodifieddate desc limit 1),
                           (Select Id,lastModifiedDate from dsfs__R00NS0000000WUMyMAO__r order by lastmodifieddate desc limit 1),
                           (Select Id,lastModifiedDate from WE_FW8_NP__SearchResult__r order by lastmodifieddate desc limit 1) ,
                           (Select Id,lastModifiedDate from Group_Contact_Contacts__r order by lastmodifieddate desc limit 1) 
                           from contact where Id IN :contactListChunk];
            System.debug('contactList-->'+contactList);
            List<TEST_OBJ__c> testObjList = new List<TEST_OBJ__c>();
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
                if(!isRelatedListPresent && con.dsfs__R00NS0000000WUMyMAO__r !=  null && !con.dsfs__R00NS0000000WUMyMAO__r.isEmpty()){
                    System.debug('con-------.dsfs__R00NS0000000WUMyMAO__r='+con.dsfs__R00NS0000000WUMyMAO__r );
                    isRelatedListPresent = true;
                }
                if(!isRelatedListPresent && con.WE_FW8_NP__SearchResult__r !=  null && !con.WE_FW8_NP__SearchResult__r.isEmpty()){
                    System.debug('con-------.WE_FW8_NP__SearchResult__r='+con.WE_FW8_NP__SearchResult__r );
                    isRelatedListPresent = true;
                }
                if(!isRelatedListPresent && con.ContentDocumentLinks !=  null && !con.ContentDocumentLinks.isEmpty()){
                    System.debug('con-------.ContentDocumentLinks='+con.ContentDocumentLinks );
                    isRelatedListPresent = true;
                }
                 if(!isRelatedListPresent && con.Group_Contact_Contacts__r !=  null && !con.Group_Contact_Contacts__r.isEmpty()){
                    System.debug('con-------.Group_Contact_Contacts__r='+con.Group_Contact_Contacts__r );
                    isRelatedListPresent = true;
                }
                if(!isRelatedListPresent){
                    TEST_OBJ__c testObj = new TEST_OBJ__c();
                    testObj.bucket__c = 'No Related Records	';
                    if(con.Account!=null){
                        testObj.Account_Created_Date__c = con.Account.createdDate;
                        testObj.Account_Lastmodified_Date__c = con.Account.LastModifiedDate;
                        testObj.Account_RecordTypeName__c = con.Account.RecordType.Name; 
                    }
                    testObj.Contact_created_date__c = con.CreatedDate;
                    testObj.Contact_Id__c = con.Id;
                    testObj.Contact_Lastmodifed_date__c = con.LastModifiedDate;
                    testObj.Contact_Name__c = con.Name;
                    testObj.Email__c = con.Email;
                    testObj.Gigya_Id__c = con.Gigya_UID__c;
                    testObj.Constituent__c = con.Constituent_Id__c;
                    testObjList.add(testObj);
                    
                }
                
            }
            if(testObjList!=null && !testObjList.isEmpty()){
                insert testObjList;
            }
            
            
        }catch(Exception e){
            System.debug('get exception on line number-->'+e.getLineNumber()+' error is=>'+e.getMessage());
        }
        
    }   
    
    global void finish(Database.BatchableContext BC) {
        
    }
}