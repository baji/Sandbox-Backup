/***************************************************************************************************************************************************************************************
    Programmer: Sk. Baji.  
    Company:    Awana
    Contact:    
    Project:    
    Description: ConvertInquiry: Converts Inquiries into Accounts. 
    Created:    07/20/2018 - S. Baji
    Updated:    07/30/2018 - <ASP-1246> (TW.) Set the Status of the newly created account to "Added'.
    Updated:    07/30/2018 - <ASP-1249> (Blake S)  Added new Existing Church field.
    Updated:    09/19/2018 - <ASP-1362> (Baji) Update lead informatioin to Existing Contact/Account
    Updated:    09/19/2018 - <ASP-1383> (Tony W) Copied Activity History and Events to Account from Lead.
***************************************************************************************************************************************************************************************/

global class ConvertInquiry {
    webservice static string inqryConversion(Id InqId) { 
        Account acc = new Account();
        Contact con = new Contact();
        Opportunity opp = new Opportunity();
        OpportunityContactRole opr = new OpportunityContactRole();
        Task t = new Task();
        npe5__Affiliation__c aff = new npe5__Affiliation__c();
         Database.LeadConvert lc = new Database.LeadConvert();
        List<Task> migratedTasks = new List<Task>();
        List<Event> migratedEvents = new List<Event>();
        
        system.debug('******Inquiry ID Need to Convert********'+InqId);   
        Lead l = [select Description,AlreadyRunningAwana__c,AnticipatedStartDate__c,ChildrensMinistryMidweek__c,ChildrensMinistrySunday__c,Church_Attendance__c,
                     Comments__c,Denomination__c,FamiliarityWithAwana__c,Lead_Source__c,PhysicalCity__c,Physical_Country__c,PhysicalCounty__c,
                     PhysicalState__c,PhysicalStreet1__c,PhysicalStreet2__c,PhysicalStreet3__c,PhysicalStreet4__c,PhysicalZipCode__c,PrimaryEthnicGroup__c,Existing_Contact__c,Existing_Account__c,
                     Undeliverable_Physical__c,Undeliverable_Billing_Address__c,npe01__Preferred_Email__c,npe01__Preferred_Phone__c,FirstName,LastName,Email,Company,Phone,Fax,Website,
                     HasOptedOutOfEmail,PositionRole__c,MobilePhone,Street,City,State,Postalcode,Country,County__c,Work_Phone__c,CustomerNotes__c,
                     pi__Needs_Score_Synced__c,pi__campaign__c,pi__comments__c,pi__conversion_date__c,pi__conversion_object_name__c,pi__conversion_object_type__c,pi__created_date__c,
                     pi__first_activity__c,pi__first_touch_url__c,pi__first_search_term__c,pi__first_search_type__c,pi__grade__c,pi__pardot_hard_bounced__c,pi__last_activity__c,
                     pi__Pardot_Last_Scored_At__c,pi__notes__c,pi__score__c,pi__url__c,Best_Time_to_Call__c,Temperature__c,AcountID__c,
                     pi__utm_campaign__c,pi__utm_content__c,pi__utm_medium__c,pi__utm_source__c,pi__utm_term__c,Club_Interest__c From Lead where Id =: InqId];               
         
        List<Task> activityHistory = [SELECT Id,WhoId, Subject,Description,CreatedById,OwnerId,LastModifiedById,ActivityDate,ReminderDateTime,Status,CreatedDate FROM Task t WHERE t.WhoId =: InqId];
        system.debug('<<  ACTIVITY HISTORY >> '+activityHistory);
       
        
        system.debug('******Inquiry Values Need to Convert********'+l);
        system.debug('******Inquiry Existing Contact ID********'+l.Existing_Contact__c);
        system.debug('******Inquiry Existing Account ID********'+l.Existing_Account__c);
        
        if(l.Existing_Contact__c == null){
            //Map Contact fields
            con.FirstName = l.FirstName;
            con.LastName = l.LastName;
            con.Email = l.Email;
            con.Phone = l.Phone;
            con.npe01__Preferred_Email__c = l.npe01__Preferred_Email__c;
            con.npe01__PreferredPhone__c = l.npe01__Preferred_Phone__c;
            con.HasOptedOutOfEmail = l.HasOptedOutOfEmail;
            con.PositionRole__c = l.PositionRole__c;
            con.MobilePhone = l.MobilePhone;
            con.OtherPhone = l.Work_Phone__c;
            con.LeadSource = l.Lead_Source__c;
            
            //Create Contact
            insert con;
        }
        else{
            con.Id = l.Existing_Contact__c;
            if(l.FirstName != null){con.FirstName = l.FirstName;}
            if(l.LastName != null){con.LastName = l.LastName;}
            if(l.Email != null){con.Email = l.Email;}
            if(l.Phone != null){con.Phone = l.Phone;}
            if(l.npe01__Preferred_Email__c != null){con.npe01__Preferred_Email__c = l.npe01__Preferred_Email__c;}
            if(l.npe01__Preferred_Phone__c != null){con.npe01__PreferredPhone__c = l.npe01__Preferred_Phone__c;}
            if(l.HasOptedOutOfEmail != null){con.HasOptedOutOfEmail = l.HasOptedOutOfEmail;}            
            if(l.PositionRole__c != null){con.PositionRole__c = l.PositionRole__c;}           
            if(l.MobilePhone != null){con.MobilePhone = l.MobilePhone;}
            if(l.Work_Phone__c != null){con.OtherPhone = l.Work_Phone__c;}
            if(l.Lead_Source__c != null){con.LeadSource = l.Lead_Source__c;}

            //Create Contact
            update con;
            
        }
        
        if(l.Existing_Account__c == null){
            //Map Account fields
            acc.Name = l.Company;
            acc.RecordTypeId = '012f4000000dA3K';
            acc.Already_Running_Awana__c = l.AlreadyRunningAwana__c;
            acc.Planned_Start_Date__c = l.AnticipatedStartDate__c;
            acc.Children_s_Ministry_Midweek__c = l.ChildrensMinistryMidweek__c;
            acc.Children_s_Ministry_Sunday__c = l.ChildrensMinistrySunday__c;
            acc.Church_Attendance__c = l.Church_Attendance__c;
            acc.Comments__c = l.Comments__c;
            acc.Customer_Notes__c = l.CustomerNotes__c;
            acc.Description = l.Description;
            acc.Denomination__c = l.Denomination__c;
            acc.Familiarity_With_Awana__c = l.FamiliarityWithAwana__c;
            acc.Lead_Source__c = l.Lead_Source__c;
            acc.Physical_City__c = l.PhysicalCity__c;
            acc.PhysicalCountry__c = l.Physical_Country__c;
            acc.Physical_County__c = l.PhysicalCounty__c;
            acc.Physical_State__c = l.PhysicalState__c;
            acc.Physical_Street_1__c = l.PhysicalStreet1__c;
            acc.Physical_Street_2__c = l.PhysicalStreet2__c;
            acc.PhysicalStreet3__c = l.PhysicalStreet3__c;
            acc.PhysicalStreet4__c = l.PhysicalStreet4__c;
            acc.Physical_Zip__c = l.PhysicalZipCode__c;
            acc.Primary_Ethnic_Group__c = l.PrimaryEthnicGroup__c;
            acc.Undeliverable_Physical__c = l.Undeliverable_Physical__c;
            acc.Undeliverable_Billing__c = l.Undeliverable_Billing_Address__c;
            acc.BillingStreet = l.Street;
            acc.BillingCity = l.City;
            acc.BillingState = l.State;
            acc.Billing_County__c = l.County__c;
            acc.BillingPostalCode = l.PostalCode;
            acc.BillingCountry = l.Country; //Added by AK
            acc.Phone = l.Phone;
            acc.Fax = l.Fax;
            acc.Website = l.Website;
            acc.Applicant__c = con.Id;
            acc.Status__c = 'Added'; 
            acc.UTM_Campaign__c = l.pi__utm_campaign__c;
            acc.UTM_Content__c = l.pi__utm_content__c;
            acc.UTM_Medium__c    = l.pi__utm_medium__c;
            acc.UTM_Source__c = l.pi__utm_source__c;
            acc.UTM_Term__c = l.pi__utm_term__c;
            acc.Interest__c = l.Club_Interest__c;
            acc.Pardot_Campaign__c = l.pi__campaign__c;
            acc.Pardot_Comments__c = l.pi__comments__c;
            acc.Pardot_Conversion_Date__c = l.pi__conversion_date__c;
            acc.Pardot_Conversion_Object_Name__c = l.pi__conversion_object_name__c;
            acc.Pardot_Conversion_Object_Type__c = l.pi__conversion_object_type__c;
            acc.Pardot_Created_Date__c = l.pi__created_date__c;
            acc.Pardot_First_Activity__c = l.pi__first_activity__c;
            acc.Pardot_First_Referrer__c = l.pi__first_touch_url__c;
            acc.Pardot_First_Referrer_Query__c = l.pi__first_search_term__c;
            acc.Pardot_First_Referrer_Type__c = l.pi__first_search_type__c;
            acc.Pardot_Grade__c = l.pi__grade__c;
            acc.Pardot_Hard_Bounced__c = l.pi__pardot_hard_bounced__c;
            acc.Pardot_Last_Activity__c = l.pi__last_activity__c;
            acc.Pardot_Last_Scored_At__c = l.pi__Pardot_Last_Scored_At__c;
            acc.Pardot_Notes__c = l.pi__notes__c;
            acc.Pardot_Score__c = l.pi__score__c;
            acc.Pardot_URL__c = l.pi__url__c;
            acc.Needs_Score_Synced__c = l.pi__Needs_Score_Synced__c;
            //Create Account
            insert acc;
            
             
        }
        else{
            
            acc.ID = l.Existing_Account__c;
            acc.Status__c = 'Added';
            if(l.Company != null){acc.Name = l.Company;}
            if(l.AlreadyRunningAwana__c != null){acc.Already_Running_Awana__c = l.AlreadyRunningAwana__c;}
            if(l.AnticipatedStartDate__c != null){acc.Planned_Start_Date__c = l.AnticipatedStartDate__c;}
            if(l.ChildrensMinistryMidweek__c != null){acc.Children_s_Ministry_Midweek__c = l.ChildrensMinistryMidweek__c;}
            if(l.ChildrensMinistrySunday__c != null){acc.Children_s_Ministry_Sunday__c = l.ChildrensMinistrySunday__c;}
            if(l.Church_Attendance__c != null){acc.Church_Attendance__c = l.Church_Attendance__c;}            
            if(l.Comments__c != null){acc.Comments__c = l.Comments__c;}            
            if(l.CustomerNotes__c != null){acc.Customer_Notes__c = l.CustomerNotes__c;}
            if(l.Description != null){acc.Description = l.Description;}            
            if(l.Denomination__c != null){acc.Denomination__c = l.Denomination__c;}            
            if(l.FamiliarityWithAwana__c != null){acc.Familiarity_With_Awana__c = l.FamiliarityWithAwana__c;}            
            if(l.Lead_Source__c != null){acc.Lead_Source__c = l.Lead_Source__c;}            
            if(l.PhysicalCity__c != null){acc.Physical_City__c = l.PhysicalCity__c;}            
            if(l.Physical_Country__c != null){acc.PhysicalCountry__c = l.Physical_Country__c;}            
            if(l.PhysicalCounty__c != null){acc.Physical_County__c = l.PhysicalCounty__c;}            
            if(l.PhysicalState__c != null){acc.Physical_State__c = l.PhysicalState__c;}            
            if(l.PhysicalStreet1__c != null){acc.Physical_Street_1__c = l.PhysicalStreet1__c;}            
            if(l.PhysicalStreet2__c != null){acc.Physical_Street_2__c = l.PhysicalStreet2__c;}            
            if(l.PhysicalStreet3__c != null){acc.PhysicalStreet3__c = l.PhysicalStreet3__c;}            
            if(l.PhysicalStreet4__c != null){acc.PhysicalStreet4__c = l.PhysicalStreet4__c;}            
            if(l.PhysicalZipCode__c != null){acc.Physical_Zip__c = l.PhysicalZipCode__c;}            
            if(l.PrimaryEthnicGroup__c != null){acc.Primary_Ethnic_Group__c = l.PrimaryEthnicGroup__c;}            
            if(l.Undeliverable_Physical__c != null){acc.Undeliverable_Physical__c = l.Undeliverable_Physical__c;}            
            if(l.Undeliverable_Billing_Address__c != null){acc.Undeliverable_Billing__c = l.Undeliverable_Billing_Address__c;}            
            if(l.Street != null){acc.BillingStreet = l.Street;}            
            if(l.City != null){acc.BillingCity = l.City;}            
            if(l.State != null){acc.BillingState = l.State;}            
            if(l.County__c != null){acc.Billing_County__c = l.County__c;}            
            if(l.PostalCode != null){acc.BillingPostalCode = l.PostalCode;}
            if(l.Country != null){acc.BillingCountry = l.Country;} //Added by AK
            
            if(l.Phone != null){acc.Phone = l.Phone;}            
            if(l.Fax != null){acc.Fax = l.Fax;}            
            if(l.Website != null){acc.Website = l.Website;}            
            acc.Applicant__c = con.Id;
            if(l.pi__utm_campaign__c != null){acc.UTM_Campaign__c = l.pi__utm_campaign__c;}            
            if(l.pi__utm_content__c != null){acc.UTM_Content__c = l.pi__utm_content__c;}            
            if(l.pi__utm_medium__c != null){acc.UTM_Medium__c = l.pi__utm_medium__c;}            
            if(l.pi__utm_source__c != null){acc.UTM_Source__c = l.pi__utm_source__c;}            
            if(l.pi__utm_term__c != null){acc.UTM_Term__c = l.pi__utm_term__c;}            
            if(l.Club_Interest__c != null){acc.Interest__c = l.Club_Interest__c;}            
            if(l.pi__campaign__c != null){acc.Pardot_Campaign__c = l.pi__campaign__c;}            
            if(l.pi__comments__c != null){acc.Pardot_Comments__c = l.pi__comments__c;}            
            if(l.pi__conversion_date__c != null){acc.Pardot_Conversion_Date__c = l.pi__conversion_date__c;}          
            if(l.pi__conversion_object_name__c != null){acc.Pardot_Conversion_Object_Name__c = l.pi__conversion_object_name__c;}          
            if(l.pi__conversion_object_type__c != null){acc.Pardot_Conversion_Object_Type__c = l.pi__conversion_object_type__c;}            
            if(l.pi__created_date__c != null){acc.Pardot_Created_Date__c = l.pi__created_date__c;}            
            if(l.pi__first_activity__c != null){acc.Pardot_First_Activity__c = l.pi__first_activity__c;}            
            if(l.pi__first_touch_url__c != null){acc.Pardot_First_Referrer__c = l.pi__first_touch_url__c;}            
            if(l.pi__first_search_term__c != null){acc.Pardot_First_Referrer_Query__c = l.pi__first_search_term__c;}            
            if(l.pi__first_search_type__c != null){acc.Pardot_First_Referrer_Type__c = l.pi__first_search_type__c;}            
            if(l.pi__grade__c != null){acc.Pardot_Grade__c = l.pi__grade__c;}            
            if(l.pi__pardot_hard_bounced__c != null){acc.Pardot_Hard_Bounced__c = l.pi__pardot_hard_bounced__c;}            
            if(l.pi__last_activity__c != null){acc.Pardot_Last_Activity__c = l.pi__last_activity__c;}            
            if(l.pi__Pardot_Last_Scored_At__c != null){acc.Pardot_Last_Scored_At__c = l.pi__Pardot_Last_Scored_At__c;}            
            if(l.pi__notes__c != null){acc.Pardot_Notes__c = l.pi__notes__c;}            
            if(l.pi__score__c != null){acc.Pardot_Score__c = l.pi__score__c;}            
            if(l.pi__url__c != null){acc.Pardot_URL__c = l.pi__url__c;}            
            if(l.pi__Needs_Score_Synced__c != null){acc.Needs_Score_Synced__c = l.pi__Needs_Score_Synced__c;}
            
            
            //update Existing Account
            update acc;
            
            
        }
       
        //Map Opportunity Fields
        opp.Name = l.Company;
        opp.AccountId = acc.Id;
        opp.npsp__Primary_Contact__c = con.Id;
        opp.StageName = 'Evaluating';
        opp.Customer_Notes__c = l.CustomerNotes__c;
        opp.CloseDate = Date.today().addDays(30);
        opp.LeadSource = l.Lead_Source__c;
        opp.Phone__c = l.Phone;
        opp.Best_Time_to_Call__c = l.Best_Time_to_Call__c;
        opp.Pardot_Score__c = l.pi__score__c;
        opp.Temperature__c = l.Temperature__c;
        opp.Description = l.Description;
        opp.Club_Interest__c = l.Club_Interest__c;
        //insert Opportunity
        insert opp;
        
        
        // ************- <ASP-1383>- Copy Events to newly converted Account
                List<String> fieldList = new List<String>();
                fieldList.addAll(Event.sobjectType.getDescribe().fields.getMap().keySet());
                String q = 'Select '+ String.join(fieldList,',') + ' FROM Event Where WhoId =\''+InqId+'\'';
                List<Event> eventHistory = Database.query(q);
                if(!eventHistory.isEmpty()){
                    for(Event ev : eventHistory){
                        Event evNew = ev.clone(false,true,false,false);
                        evNew.WhoId = null;
                        evNew.whatId = opp.Id;
                        migratedEvents.add(evNew);
                    }
                }
                for(Task currentAH : activityHistory){
                    system.debug(currentAH);
    
                    migratedTasks.add(new Task(whatId =opp.Id, 
                        OwnerId = currentAH.OwnerId,
                        Subject = currentAH.Subject,
                        ActivityDate = currentAH.ActivityDate,
                        ReminderDateTime=currentAH.ReminderDateTime,
                        Status=currentAH.Status,
                        Description = currentAH.Description));
                }
            //***************- End - <ASP-1383>
            
            
              
        List<npe5__Affiliation__c> aff1 = [select Id from npe5__Affiliation__c where npe5__Organization__c =: acc.Id and npe5__Contact__c =: con.Id];      
       system.debug('affiliation size*********************************'+aff1.size());
        if(aff1.size() <= 0){
            system.debug('Affiliation Not Exist');
        //Affiliate Contact with Account
        aff.npe5__Organization__c = acc.Id;
        aff.npe5__Contact__c = con.Id;
        //aff.Authorized_Purchaser__c = ;
        //aff.Awana_Role__c = ;
        //aff.Church_Role__c = ;
        insert aff;
        }
        
         if(migratedTasks.size() > 0){
            system.debug('<<<<<<<<< BEFORE UPDATE TASKS >>>>>> '+migratedTasks);
            upsert migratedTasks;
            system.debug('<<<<<<<<< AFTER UPDATE TASKS >>>>>> '+migratedTasks);
        }
        if(!migratedEvents.isEmpty()){
            upsert migratedEvents;
        }
        
        //Finally Update the Lead convert status and delete the lead
        //l.IsConverted = true;
        delete l;
        
        string resultId = Id.valueOf(acc.Id);
        system.debug('Account Result ID:'+resultId);
        return resultId;
    }
}