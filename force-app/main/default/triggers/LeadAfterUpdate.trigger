/************************************************************************************************************************************************************
    Programmer: Tony Williams
    Company:    Awana
    Project:    Salesforce SSO
    Original:   5/16/2014  - Dispatcher that processes Leads based on different Record Types
                            a) If Record Type = "Aquisition" Then Create Affiliations and 1x1 accounts from converted Leads
    Updated:    6/30/2014 - Changed the initial Account Status to Pending for Aquisition Lead Conversion on Accounts.
    Updated:    01/09/2015 - Updated code to prevent recursive trigger calls which also could lead to  unwanted governor limits See: Knowledge Article Number: 000002357 and  000133752  in SFDC Success Community
    Updated:    05/08/2015 - Updated code to check the accountId and contactId to convert the lead when email found when the user submits membership singup form (line no 27).
    Updated:    03/04/2016 - <SFDC-3> Added code to idsplay the Inquiry Owner on the Lead's Account as well as the Lead's Open Activities and Activity History
 *************************************************************************************************************************************************************/
trigger LeadAfterUpdate on Lead (after update) {
    
    Awana_Settings__c custmSetting =  Awana_Settings__c.getValues('RunLeadTrigger');   
    
    if (custmSetting != null && Boolean.valueOf(custmSetting.value__c)){ 
        Awana_Settings__c myCS1 = Awana_Settings__c.getValues('ExecuteInquiryTrigger');
        String myCCVal = myCS1.Value__c;
        //String execute = 'true';
        // Gather up all leads that have their record type = 'Aquisition' and their LeadSource field = 'Aquisition Signed' and convert them
        if(Boolean.valueOf(myCCVal)){
            Integer sizeLimit = Trigger.new.size();
            List<Id> contactIds = new List<Id>();   
            List<Id> accountIds = new List<Id>();
            List<Task> leadTask = new List<Task>();
            String ProcessType = ''; // Flag to determine what type or process shoul dbe handled on Lead Update since this is a decision-treee/dispatch trigger
            List<RecordType> Rec = [Select Id, Name from RecordType where Name='Acquisition' Limit 1 ];// Change this type back to 'Aquisition after testing'
            //User awanaAppRec = [Select Id from User where Name = 'Awana Applications' limit 1];
            User awanaAppRec = [Select Id from User where Profile.Name = 'System Administrator' AND IsActive = True limit 1];
            Database.LeadConvert lc = new Database.LeadConvert();
            List<Task> migratedTasks = new List<Task>();
            List<Event> migratedEvents = new List<Event>();
        
            for(Lead alead : trigger.new){
                system.debug('*****************'+alead.Id);
                // RECORD TYPE =  AQUISITION process type and Leadsource != null
                system.debug('<<ALEAD>> '+Rec[0].Id+', '+alead.RecordTypeId+', '+alead.IsConverted+', '+alead.Status+', '+alead.AcountID__c+', '+alead.ContactID__c);
                
                if(Rec[0].Id == alead.RecordTypeId && alead.IsConverted == false && alead.AcountID__c != null && alead.ContactID__c != null){ 
                    system.debug('********Condition Satisfied*********');  
                    //**Migrate the tasks to Lead before conversion** t.Status != 'Open' And
                    List<Task> activityHistory = [SELECT Id,WhoId, Subject,Description,CreatedById,OwnerId,LastModifiedById,ActivityDate,ReminderDateTime,Status,CreatedDate FROM Task t WHERE t.WhoId =: alead.Id];
                
                    //By Mayur to copy Events to Account
                    List<String> fieldList = new List<String>();
                    fieldList.addAll(Event.sobjectType.getDescribe().fields.getMap().keySet());
                    String q = 'Select '+ String.join(fieldList,',') + ' FROM Event Where WhoId =\''+alead.Id+'\'';
                    List<Event> eventHistory = Database.query(q);
                    if(!eventHistory.isEmpty()){
                        for(Event ev : eventHistory){
                            Event evNew = ev.clone(false,true,false,false);
                            evNew.WhoId = null;
                            evNew.whatId = alead.AcountID__c;
                            migratedEvents.add(evNew);
                        }
                    }
                    for(Task currentAH : activityHistory){
                        system.debug(currentAH);
        
                        migratedTasks.add(new Task(whatId =alead.AcountID__c, 
                            OwnerId = currentAH.OwnerId,
                            Subject = currentAH.Subject,
                            ActivityDate = currentAH.ActivityDate,
                            ReminderDateTime=currentAH.ReminderDateTime,
                            Status=currentAH.Status,
                            Description = currentAH.Description));
                    }
                    //**End Task Migration to new account**
                    ProcessType = Rec[0].Name;
                    lc.setLeadId(alead.Id);
                    LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true and MasterLabel = 'Converted' LIMIT 1];
                    lc.setConvertedStatus(convertStatus.MasterLabel);
                    system.debug('LC converted? '+alead.isConverted);
                    system.debug('MASTER LABEL: '+convertStatus.MasterLabel);
                    lc.setOwnerId(awanaAppRec.Id);
                    //lc.setDoNotCreateOpportunity(true);
                    //setAccountId to merge with the existing account.
                    lc.setAccountId(alead.AcountID__c);
                    //update the contact inquiry status
                    Contact conUpdate = [select Id from Contact where Id=:alead.ContactID__c];
                    conUpdate.LeadSource = alead.LeadSource;
                    update conUpdate;
                    Account acctUpdate = [select Id from Account  where Id=:alead.AcountID__c];
                    // Since we don't know whether this is a Lead Queue or Lead User to migrate to this Account ...
                    String getObjectName=String.valueOf(alead.OwnerId);
                
                    List<Group> thisGroup = [Select  Name from Group where Id =: alead.OwnerId limit 1];
                    if(thisGroup.size() > 0){
                        getObjectName =  thisGroup[0].Name;
                    } 
                    else{
                        User thisUser = [Select  Name from User where Id =: alead.OwnerId limit 1];
                        getObjectName =  thisUser.Name;
                    }
                    acctUpdate.Inquiry_Owner__c = getObjectName;
                    update acctUpdate;
                    Database.LeadConvertResult lcr = Database.convertLead(lc);
                    
                    Contact con = [select Id from Contact where Id=:lcr.getContactId()];
                    delete con;

                    Id OpportunityId=[select ConvertedOpportunityId from Lead where id=:aLead.Id].ConvertedOpportunityId;
                    

                    /* -- // Migrate Activities to Opp - Begin
                    if(!eventHistory.isEmpty()){
                        for(Event ev : eventHistory){
                            Event evNew = ev.clone(false,true,false,false);
                            evNew.WhoId = null;
                            evNew.whatId = OpportunityId;
                            migratedEvents.add(evNew);
                        }
                    }
                    for(Task currentAH : activityHistory){
                        system.debug(currentAH);
        
                        migratedTasks.add(new Task(whatId =OpportunityId, 
                            OwnerId = currentAH.OwnerId,
                            Subject = currentAH.Subject,
                            ActivityDate = currentAH.ActivityDate,
                            ReminderDateTime=currentAH.ReminderDateTime,
                            Status=currentAH.Status,
                            Description = currentAH.Description));
                    }
                    // Migrate Activities to Opp - End -- */
              
                    System.assert(lcr.isSuccess());
             
                }//IF Tag Tools Inqury Creation
                // END  RECORD TYPE =  AQUISITION
            }//FOR 
            // Decision Tree for dispatching process to the correct handler method
       
            if(migratedTasks.size() > 0){
                system.debug('<<<<<<<<< BEFORE UPDATE TASKS >>>>>> '+migratedTasks);
                upsert migratedTasks;
                system.debug('<<<<<<<<< AFTER UPDATE TASKS >>>>>> '+migratedTasks);
            }
            if(!migratedEvents.isEmpty()){
                upsert migratedEvents;
            }
        
            //1. <<FUTURE CONDITIONS HERE...>>  If Process is an <<Whatever Process Type>> and continue...:
        
            //By Mayur -  to update the converted contact field Organization_Account_Id__c with the converted organization account id when conversion is done by standard lead conversion and not by TAG tool
            Map<Id,Id> contactVsAccountMap = new Map<Id,Id>();
            for(Lead alead : trigger.new){    
                if(alead.IsConverted && alead.ConvertedAccountId != null && alead.ConvertedContactId != null && !trigger.oldmap.get(alead.id).IsConverted &&  alead.AcountID__c == null && alead.ContactID__c == null){
                    contactVsAccountMap.put(alead.ConvertedContactId,alead.ConvertedAccountId);
                }
            }
            System.debug('********contactVsAccountMap************'+contactVsAccountMap);
        
            if(!contactVsAccountMap.isEmpty()){
                List<Contact> contactsToUpdate = [SELECT Id,Organization_Account_Id__c FROM Contact WHERE Id IN : contactVsAccountMap.keySet()];
                if(!contactsToUpdate.isEmpty()){
                    for(Contact con : contactsToUpdate){
                        con.Organization_Account_Id__c = contactVsAccountMap.get(con.Id);
                    }    
                    update contactsToUpdate; 
                }
            }
        }
    }
}