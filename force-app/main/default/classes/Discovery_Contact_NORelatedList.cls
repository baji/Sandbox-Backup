global class Discovery_Contact_NORelatedList implements Database.Batchable<sObject>,Database.Stateful{
    // no related list
    global Database.QueryLocator start(Database.BatchableContext BC) {
        /*String accounthouseholdId = '012f4000000nLu0';
String businessUnit = '012f4000000dA7N';
String internaltionalChurch = '012f4000000dA7T';
String query = 'SELECT Id,Name FROM contact where Account.recordTypeId!=:accounthouseholdId AND Account.recordTypeId!=:businessUnit AND Account.recordTypeId!=:internaltionalChurch';
*/ 
        String accounthouseholdId_TypeId = [Select Id,name,developername from Recordtype where SobjectType='Account'  and developername='HH_Account'].Id;
        String businessUnit_TypeId = [Select Id,name,developername from Recordtype where SobjectType='Account'  and developername='Business_Unit'].Id;
        String internaltionalChurch_TypeId = [Select Id,name,developername from Recordtype where SobjectType='Account'  and developername='International_Church'].Id;
        String canadaChurch_TypeId = [Select Id,name,developername from Recordtype where SobjectType='Account'  and developername='Canada_Church'].Id;
        
        Set<String> exclude_recordTypeIds =  new set<String>{accounthouseholdId_TypeId,businessUnit_TypeId,internaltionalChurch_TypeId,canadaChurch_TypeId};
            //String query = 'SELECT Id,Name FROM contact where Account.recordTypeId!=:accounthouseholdId AND Account.recordTypeId!=:businessUnit AND Account.recordTypeId!=:internaltionalChurch limit 10';
            String query = 'SELECT Id,Name,Account.RecordType.Name FROM contact where Account.recordTypeId NOT IN :exclude_recordTypeIds and AccountID!=null AND pi__campaign__c = NUll';
        
        return Database.getQueryLocator(query);
       
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> contactListChunk) {
        try {
            System.debug('contactListChunk=====>'+contactListChunk.size());
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
                           (Select Id,lastModifiedDate from Group_Contact_Contacts__r order by lastmodifieddate desc limit 1)
                           
                           ,
                           (Select Id,lastModifiedDate from Churches__r order by lastmodifieddate desc limit 1),
                           (Select Id,lastModifiedDate from dsfs__DocuSign_Envelope01__r order by lastmodifieddate desc limit 1),
                           (Select Id,lastModifiedDate from Contacts__r order by lastmodifieddate desc limit 1),
                           (Select Id,lastModifiedDate from ChargentOrders__Payment_Requests__r order by lastmodifieddate desc limit 1)
                           from contact where Id IN :contactListChunk];
            System.debug('contactList-->'+contactList);
            List<TEST_OBJ__c> testObjList = new List<TEST_OBJ__c>();
            List<DataWrp> dataWrpList = new List<DataWrp>();
            Boolean isRelatedListPresent = false;
            Integer counterOld = 0;
            for(contact con : contactList){
                System.debug('counterOld '+counterOld+' ==>'+con.Id);
                counterOld = counterOld +1;
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
                
                
                /**/
                if(!isRelatedListPresent && con.Churches__r !=  null && !con.Churches__r.isEmpty()){
                    System.debug('con-------.Churches__r='+con.Churches__r );
                    isRelatedListPresent = true;
                }
                if(!isRelatedListPresent && con.dsfs__DocuSign_Envelope01__r !=  null && !con.dsfs__DocuSign_Envelope01__r.isEmpty()){
                    System.debug('con-------.dsfs__DocuSign_Envelope01__r='+con.dsfs__DocuSign_Envelope01__r );
                    isRelatedListPresent = true;
                }
                if(!isRelatedListPresent && con.Contacts__r !=  null && !con.Contacts__r.isEmpty()){
                    System.debug('con-------.Contacts__r='+con.Contacts__r );
                    isRelatedListPresent = true;
                }
                if(!isRelatedListPresent && con.ChargentOrders__Payment_Requests__r !=  null && !con.ChargentOrders__Payment_Requests__r.isEmpty()){
                    System.debug('con-------.ChargentOrders__Payment_Requests__r='+con.ChargentOrders__Payment_Requests__r );
                    isRelatedListPresent = true;
                }
                
                if(true){
                    TEST_OBJ__c testObj = new TEST_OBJ__c();
                    testObj.bucket__c = 'No Related Records';
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
                    DataWrp dataWrpObj = new DataWrp();
                    //dataWrpObj.testObj = testObj;
                    dataWrpObj.isListPresent = isRelatedListPresent;
                    dataWrpList.add(dataWrpObj);
                    
                }
                
            }
            if(testObjList!=null && !testObjList.isEmpty()){
             //   insert testObjList;
            }
            // again query
            
            contactList = new List<Contact>();
            contactList = [Select id , name ,Email,Gigya_UID__c,Constituent_Id__c,AccountID , Account.CreatedDate,Account.lastModifiedDate,
                           Account.RecordType.name,CreatedDate,lastModifiedDate,
                           (Select Id,lastModifiedDate from Accounts1__r order by lastmodifieddate desc limit 1)  ,
                           (Select Id,lastModifiedDate from Accounts__r order by lastmodifieddate desc limit 1)  ,
                           (Select Id,lastModifiedDate from npe01__Organizations__r order by lastmodifieddate desc limit 1)  ,
                           (Select Id,lastModifiedDate from dsfs__DocuSign_Envelope_Recipient__r order by lastmodifieddate desc limit 1)  ,
                           (Select Id,lastModifiedDate from npe4__Relationships1__r order by lastmodifieddate desc limit 1)  ,
                           (Select Id,lastModifiedDate from Leads__r order by lastmodifieddate desc limit 1)  ,
                           (Select Id,lastModifiedDate from Membership_Acceptances1__r order by lastmodifieddate desc limit 1)  ,
                           (Select Id,lastModifiedDate from npsp__Honoree_Opportunities__r order by lastmodifieddate desc limit 1)  ,
                           (Select Id,lastModifiedDate from npsp__Notification_Opportunities__r order by lastmodifieddate desc limit 1)  ,
                           (Select Id,lastModifiedDate from npsp__Opportunities__r order by lastmodifieddate desc limit 1)  ,
                           (Select Id,lastModifiedDate from Opportunities1__r order by lastmodifieddate desc limit 1)
                           
                             ,
                           (Select Id,lastModifiedDate from WE_FW8_NP__SearchResult__r order by lastmodifieddate desc limit 1)  ,
                           (Select Id,lastModifiedDate from WE_FW8_NP__Score_Results__r order by lastmodifieddate desc limit 1)
                           from contact where Id IN :contactListChunk];
            isRelatedListPresent = false;
            List<TEST_OBJ__c> testObjList_New = new List<TEST_OBJ__c>();
            Integer counter = 0;
            List<contact> contactTobeUpdated = new List<contact>();
            for(contact con : contactList){
                System.debug('counterNew '+counter+' ==>'+con.Id);
                isRelatedListPresent = dataWrpList[counter].isListPresent;
                counter = counter+1;
                if(isRelatedListPresent){
                    continue;   
                }
                
                //TEST_OBJ__c testObj =  dataWrpList[counter].testObj;
                if( !isRelatedListPresent && con.Accounts1__r !=  null && !con.Accounts1__r.isEmpty()){
                    System.debug('con-------.Accounts1__r='+con.Accounts1__r );
                    isRelatedListPresent = true;
                    
                }if(  !isRelatedListPresent && con.Accounts__r !=  null && !con.Accounts__r.isEmpty()){
                    System.debug('con-------.Accounts__r='+con.Accounts__r );
                    isRelatedListPresent = true;
                    
                }if(  !isRelatedListPresent && con.npe01__Organizations__r !=  null && !con.npe01__Organizations__r.isEmpty()){
                    System.debug('con-------.npe01__Organizations__r='+con.npe01__Organizations__r );
                    isRelatedListPresent = true;
                    
                }if(  !isRelatedListPresent && con.dsfs__DocuSign_Envelope_Recipient__r !=  null && !con.dsfs__DocuSign_Envelope_Recipient__r.isEmpty()){
                    System.debug('con-------.dsfs__DocuSign_Envelope_Recipient__r='+con.dsfs__DocuSign_Envelope_Recipient__r );
                    isRelatedListPresent = true;
                    
                }if(  !isRelatedListPresent && con.npe4__Relationships1__r !=  null && !con.npe4__Relationships1__r.isEmpty()){
                    System.debug('con-------.npe4__Relationships1__r='+con.npe4__Relationships1__r );
                    isRelatedListPresent = true;
                    
                }if(  !isRelatedListPresent && con.Leads__r !=  null && !con.Leads__r.isEmpty()){
                    System.debug('con-------.Leads__r='+con.Leads__r );
                    isRelatedListPresent = true;
                    
                }if(  !isRelatedListPresent && con.Membership_Acceptances1__r !=  null && !con.Membership_Acceptances1__r.isEmpty()){
                    System.debug('con-------.Membership_Acceptances1__r='+con.Membership_Acceptances1__r );
                    isRelatedListPresent = true;
                    
                }if(  !isRelatedListPresent && con.npsp__Honoree_Opportunities__r !=  null && !con.npsp__Honoree_Opportunities__r.isEmpty()){
                    System.debug('con-------.npsp__Honoree_Opportunities__r='+con.npsp__Honoree_Opportunities__r );
                    isRelatedListPresent = true;
                    
                }if(  !isRelatedListPresent && con.npsp__Notification_Opportunities__r !=  null && !con.npsp__Notification_Opportunities__r.isEmpty()){
                    System.debug('con-------.npsp__Notification_Opportunities__r='+con.npsp__Notification_Opportunities__r );
                    isRelatedListPresent = true;
                    
                }if(  !isRelatedListPresent && con.npsp__Opportunities__r !=  null && !con.npsp__Opportunities__r.isEmpty()){
                    System.debug('con-------.npsp__Opportunities__r='+con.npsp__Opportunities__r );
                    isRelatedListPresent = true;
                    
                }if(  !isRelatedListPresent && con.Opportunities1__r !=  null && !con.Opportunities1__r.isEmpty()){
                    System.debug('con-------.Opportunities1__r='+con.Opportunities1__r );
                    isRelatedListPresent = true;
                    
                }
                if(  !isRelatedListPresent && con.pi__Category_Contact_Scores__r !=  null && !con.pi__Category_Contact_Scores__r.isEmpty()){
                    System.debug('con-------.pi__Category_Contact_Scores__r='+con.pi__Category_Contact_Scores__r );
                    isRelatedListPresent = true;
                    
                }
                if(  !isRelatedListPresent && con.npsp__Partial_Soft_Credits__r !=  null && !con.npsp__Partial_Soft_Credits__r.isEmpty()){
                    System.debug('con-------.npsp__Partial_Soft_Credits__r='+con.npsp__Partial_Soft_Credits__r );
                    isRelatedListPresent = true;
                    
                }
                if(  !isRelatedListPresent && con.Club__r !=  null && !con.Club__r.isEmpty()){
                    System.debug('con-------.Club__r='+con.Club__r );
                    isRelatedListPresent = true;
                    
                }
                /**/
                if(  !isRelatedListPresent && con.WE_FW8_NP__SearchResult__r !=  null && !con.WE_FW8_NP__SearchResult__r.isEmpty()){
                    System.debug('con-------.WE_FW8_NP__SearchResult__r='+con.WE_FW8_NP__SearchResult__r );
                    isRelatedListPresent = true;
                    
                }
                if(  !isRelatedListPresent && con.WE_FW8_NP__Score_Results__r !=  null && !con.WE_FW8_NP__Score_Results__r.isEmpty()){
                    System.debug('con-------.WE_FW8_NP__Score_Results__r='+con.WE_FW8_NP__Score_Results__r );
                    isRelatedListPresent = true;
                    
                }
                
                if(!isRelatedListPresent){
                    contact conObj = new Contact();
                    conObj.Id = con.Id;
                    conObj.To_be_Deleted__c = true;
                    TEST_OBJ__c testObj = new TEST_OBJ__c();
                    testObj.bucket__c = 'No Related Records';
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
                    contactTobeUpdated.add(conObj);
                    
                }
                
            }
            
            if(testObjList!=null && !testObjList.isEmpty()){
                insert testObjList;
            }
            if(contactTobeUpdated!=null && !contactTobeUpdated.isEmpty()){
                update contactTobeUpdated;
            }
            
            
        }catch(Exception e){
            System.debug('get exception on line number-->'+e.getLineNumber()+' error is=>'+e.getMessage());
        }
        
    }   
    
    global void finish(Database.BatchableContext BC) {
        
    }
    
    public class DataWrp{
        //public TEST_OBJ__c testObj;
        public boolean isListPresent;
    }
}