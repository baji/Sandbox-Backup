global class DiscoverCon_RelatedRecordsToSave implements Database.Batchable<sObject>,Database.Stateful{
    
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String accounthouseholdId = '012f4000000nLu0';
        String businessUnit = '012f4000000dA7N';
        String internaltionalChurch = '012f4000000dA7T';
        String query = 'SELECT Id,Name FROM contact where Account.recordTypeId!=:accounthouseholdId AND Account.recordTypeId!=:businessUnit AND Account.recordTypeId!=:internaltionalChurch';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> contactListChunk) {
        system.debug(': Heap size is ' + limits.getHeapSize() + ' enforced is ' + limits.getLimitHeapSize());
        
        List<Contact> contactList = new List<Contact>();
        contactList = [Select id , name ,Email,Gigya_UID__c,Constituent_Id__c,Account.CreatedDate,Account.lastModifiedDate,Account.RecordType.name,CreatedDate,lastModifiedDate,
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
        Boolean isRelatedListPresent = false;
        
        List<TEST_OBJ__c> testObjList = new List<TEST_OBJ__c>();
        for(contact con : contactList){
           /* Datetime affilaitionDate ;
            Datetime OrderContactDate ;
            Datetime OppDate ;
            Datetime CampaignmemDate ;
            Datetime xyzDate;
            Datetime memberShipDate ;
            Datetime activityHisDate ;
            Datetime OpenActivityDate;
            Datetime TTCreditDate ;
            Datetime docusignStatusDate ;
            Datetime relationShipDate ;
            Datetime AttachmentDate ;
            Datetime notesDate ;
            Datetime searchResult ;
            Datetime docusignRecepient ;
            Datetime groupContact ;*/
            TEST_OBJ__c testObj = new TEST_OBJ__c();
            isRelatedListPresent = false;
            if(con.npe5__Affiliations__r !=  null && !con.npe5__Affiliations__r.isEmpty()){
                System.debug('con-------.npe5__Affiliations__r='+con.npe5__Affiliations__r);
                isRelatedListPresent = true;
                testObj.Affiliations__c = con.npe5__Affiliations__r[0].LastmodifiedDate;
                
            }
            if( con.Order_Contact_Roles__r !=  null && !con.Order_Contact_Roles__r.isEmpty()){
                System.debug('con-------.Order_Contact_Roles__r='+con.Order_Contact_Roles__r );
                isRelatedListPresent = true;
                testObj.Order_Contact_Roles__c = con.Order_Contact_Roles__r[0].LastmodifiedDate;
                
            }
            if( con.Opportunities__r !=  null && !con.Opportunities__r.isEmpty()){
                System.debug('con-------.Opportunities__r='+con.Opportunities__r );
                isRelatedListPresent = true;
                testObj.Opportunities__c = con.Opportunities__r[0].LastmodifiedDate;
                
            }
            if( con.CampaignMembers !=  null && !con.CampaignMembers.isEmpty()){
                System.debug('con-------.CampaignMembers='+con.CampaignMembers );
                isRelatedListPresent = true;
                testObj.CampaignMembers__c = con.CampaignMembers[0].LastmodifiedDate;
                
            }
            if( con.R00N50000001IDTvEAO__r !=  null  && !con.R00N50000001IDTvEAO__r.isEmpty()){
                System.debug('con-------.R00N50000001IDTvEAO__r='+con.R00N50000001IDTvEAO__r);
                isRelatedListPresent = true;
                testObj.Awards__c  =con.R00N50000001IDTvEAO__r[0].LastmodifiedDate;
                
            }
            if(con.Membership_Acceptances__r !=  null && !con.Membership_Acceptances__r.isEmpty()){
                System.debug('con-------.Membership_Acceptances__r='+con.Membership_Acceptances__r );
                isRelatedListPresent = true;
                testObj.Membership_Acceptances__c = con.Membership_Acceptances__r[0].LastmodifiedDate;
                
            }
            /**/
            if( con.ActivityHistories !=  null && !con.ActivityHistories.isEmpty()){
                System.debug('con-------.ActivityHistories='+con.ActivityHistories );
                isRelatedListPresent = true;
                testObj.ActivityHistories__c =con.ActivityHistories[0].LastmodifiedDate;
                
                
            }
            if(con.OpenActivities !=  null && !con.OpenActivities.isEmpty()){
                System.debug('con-------.OpenActivities='+con.OpenActivities );
                isRelatedListPresent = true;
                testObj.OpenActivities__c = con.OpenActivities[0].LastmodifiedDate;
                
            }
            if( con.TT_Credits__r !=  null && !con.TT_Credits__r.isEmpty()){
                System.debug('con-------.TT_Credits__r='+con.TT_Credits__r );
                isRelatedListPresent = true;
                testObj.TT_Credits__c = con.TT_Credits__r[0].LastmodifiedDate;
                
            }
            if( con.dsfs__DocuSign_Status__r !=  null && !con.dsfs__DocuSign_Status__r.isEmpty()){
                System.debug('con.dsfs__DocuSign_Status__r='+con.dsfs__DocuSign_Status__r );
                isRelatedListPresent = true;
                testObj.DocuSign_Status__c = con.dsfs__DocuSign_Status__r[0].LastmodifiedDate;
                
            }
            if( con.npe4__Relationships__r !=  null && !con.npe4__Relationships__r.isEmpty()){
                System.debug('con.npe4__Relationships__r='+con.npe4__Relationships__r );
                isRelatedListPresent = true;
                testObj.Relationships__c = con.npe4__Relationships__r[0].LastmodifiedDate;
                
            }
            if( con.attachments !=  null && !con.attachments.isEmpty()){
                System.debug('con-------.attachments='+con.attachments );
                isRelatedListPresent = true;
                testObj.attachments__c  = con.attachments[0].LastmodifiedDate;
                
            }
            if( con.notes !=  null && !con.notes.isEmpty()){
                System.debug('con-------.notes='+con.notes );
                isRelatedListPresent = true;
                testObj.notes__c  =con.notes[0].LastmodifiedDate;
                
            }
            //
            if( con.WE_FW8_NP__SearchResult__r !=  null && !con.WE_FW8_NP__SearchResult__r.isEmpty()){
                System.debug('con.WE_FW8_NP__SearchResult__r='+con.WE_FW8_NP__SearchResult__r );
                isRelatedListPresent = true;
                testObj.SearchResult__c = con.WE_FW8_NP__SearchResult__r[0].LastmodifiedDate;
                
            }
            if( con.dsfs__R00NS0000000WUMyMAO__r !=  null && !con.dsfs__R00NS0000000WUMyMAO__r.isEmpty()){
                System.debug('con-------.dsfs__R00NS0000000WUMyMAO__r='+con.dsfs__R00NS0000000WUMyMAO__r );
                isRelatedListPresent = true;
                testObj.Docusign_Recepient_Status__c  = con.dsfs__R00NS0000000WUMyMAO__r[0].LastmodifiedDate;
                
            }
            if( con.Group_Contact_Contacts__r !=  null && !con.Group_Contact_Contacts__r.isEmpty()){
                System.debug('con-------.Group_Contact_Contacts__r='+con.Group_Contact_Contacts__r );
                isRelatedListPresent = true;
                testObj.Group_Contact_Contacts__c =con.Group_Contact_Contacts__r[0].LastmodifiedDate;
                
            }
            if(isRelatedListPresent){
                // TEST_OBJ__c testObj = new TEST_OBJ__c();
                testObj.bucket__c = 'Have Related Records';
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
                //
                
                testObjList.add(testObj);
            }
            
        }
        if(testObjList!=null && !testObjList.isEmpty()){
            insert testObjList;
        }
        try {
            
        }catch(Exception e){
            System.debug('get exception on line number-->'+e.getLineNumber()+' error is=>'+e.getMessage());
        }
        
    }   
    
    global void finish(Database.BatchableContext BC) {
        
    }
}