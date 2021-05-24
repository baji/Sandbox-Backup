/**********************************************************************************************************************
    Programmer:         Tony W.
    Company:            Awana
    Contact:            tonyw@awana.org
    Project:            AGD-3
    Original:           7/11/2017- Used to Reset all non-None GO Levels to former annually. (Annual "close-out" process)  
 *********************************************************************************************************************/ 
global class BatchGOLevelToFormerAccounts  implements Database.Batchable<sObject>,Database.AllowsCallouts, Database.Stateful{
    global String query;
    global List<String> trackResetAccounts = new List<String>();
    
    global database.querylocator start(Database.BatchableContext BC){  
        // Select All Accounts that have Current as their free trail Status
        if(query == null) 
        {
            query 
                = 'Select Id, '
                + ' Name, '
                + ' GO_Submission_Date__c, '
                + ' GO_Level__c, '
                + ' Estimated_Club_Size__c, '
                + ' GO_Missions_Month__c, '
                + ' Verse_A_Thon__c, '
                + ' Planning_a_Verse_a_Thon__c '                
                + 'From Account WHERE Registration_Status__c <> \'Dropped\' and Registration_Level__c <> null and Status__c = \'Added\' and RecordType.Name=\'US Organization\' and GO_Level__c in (\'Level 1\', \'Level 2\',\'Level 3\')';   

        }
        system.debug('<< QUERY  >> '+query);  
        
        return Database.getQueryLocator(query);
        
    }
      
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        // Create both Map for the GO Coordinator Affiliaion and a LIST of the Accounts: 
        // ... Using the Key-Value pair on the map to get GO Coordinator
        String dateYear='';
        List<Id> buildAccountIdList = new List<Id>();
        List<Account> buildAccountList = new List<Account>();
        List<GO_History__c> goHistories = new List<GO_History__c>();
        Map<Id,npe5__Affiliation__c> buildAffiliationMap= new Map<Id,npe5__Affiliation__c>();
        List<npe5__Affiliation__c> updateAffObjects = new List<npe5__Affiliation__c>();
        List<CampaignMember> goCoordinatorCampaignMembers = new List<CampaignMember>(); 
        Map<Id,GO_History__c> mapEachGO= new Map<Id,GO_History__c>();
        Integer cnt = 0;
        Date currentDate = Date.today();
        Integer someYear = currentDate.year();
        String campaignName = 'GO Coordinator Campaign '+someYear;
        Campaign currentCampaign = [Select Id from Campaign where Name =:campaignName];
        //First Loop  build
        for(sObject s : scope){
            Account thisAccountObject = (Account)s;
            GO_History__c gh = new GO_History__c();
            
            // Grab everything for the GO Object except for the Coordniator Name and  Coordniator Email
            gh.GO_Missions_Month__c = thisAccountObject.GO_Missions_Month__c;
            system.debug('<< GO MISSIONS MONTH >> '+gh.GO_Missions_Month__c);
            gh.GO_Submission_Date__c = thisAccountObject.GO_Submission_Date__c;
            system.debug('<< GO SUBMISSION DATE >> '+gh.GO_Submission_Date__c);
            gh.GO_Level__c = thisAccountObject.GO_Level__c;
            system.debug('<< GO LEVEL  >> '+gh.GO_Level__c);
            gh.Account__c = thisAccountObject.Id;
            system.debug('<< ACCOUNT >> '+gh.Account__c);
            dateYear = String.valueOf(someYear);
            system.debug('<< DATE YEAR >> '+dateYear);
            dateYear = dateYear.substring(2);
            system.debug('<< DATE YEAR >> '+dateYear);
            gh.Fiscal_Year__c = 'FY'+dateYear;
            system.debug('<< GO FYI >> '+gh.Fiscal_Year__c);
            goHistories.add(gh);
            
            // Reset these following Account fields
            thisAccountObject.GO_Missions_Month__c = '';
            thisAccountObject.Estimated_Club_Size__c = null;
            thisAccountObject.Planning_a_Verse_a_Thon__c = null;
            thisAccountObject.Verse_A_Thon__c = null;
            thisAccountObject.GO_Level__c = 'Former';
            
            // Prep account for updating
            buildAccountList.add(thisAccountObject);
            trackResetAccounts.add(thisAccountObject.Name);
            //Put this ID-GO object pair 
            mapEachGO.put(gh.Account__c,gh);
            
        }
        
        // Now get the KeySet of Acocunt Ids for the Affiliation s who are Go Coordinators and get the email and Name of Coordinator
        for(npe5__Affiliation__c someAffObject : [Select npe5__Organization__c, 
                                                  npe5__Contact__c,
                                                  npe5__Contact__r.FirstName,
                                                  npe5__Contact__r.LastName, 
                                                  npe5__Contact__r.Email,
                                                  Awana_Role__c
                                                  FROM npe5__Affiliation__c
                                                  WHERE Awana_Role__c includes ('Awana GO Coordinator') and npe5__Organization__c in: mapEachGO.keySet()]
           ){
               
                GO_History__c someGOobject =    mapEachGO.get(someAffObject.npe5__Organization__c); 
                // << This will be a  Campaign call so store the contents into a dynamic name GO Coordinator Campaign 2017 >>
             
                goCoordinatorCampaignMembers.add(new CampaignMember(ContactId=someAffObject.npe5__Contact__c,
                                              CampaignId=currentCampaign.Id));  
                // Remove the AWANA GO Coordinator Pattern:
                // First check if we have the AGC Pattern at the front of the string...
                // ... if not then set the Pattern = null... otherwise set the Awana Role to the rest of string.
                Integer positionAtPattern = someAffObject.Awana_Role__c.indexOf('Awana GO Coordinator');
                if(positionAtPattern >= 0){   
                    if(positionAtPattern == 0 ){
                        if(someAffObject.Awana_Role__c.indexOf(';')>=0){
                            someAffObject.Awana_Role__c = someAffObject.Awana_Role__c.substringAfter(';');
                        }else{
                            someAffObject.Awana_Role__c  = null;
                        }
                        system.debug('<< AWANA ROLE VALUE NOW >> '+someAffObject.Awana_Role__c);
                    }else{ //  Pattern for Awanan GO Coordinator (AGC) is somewhere in the middle of the entire string.
                        String strBeforePatternMatch = someAffObject.Awana_Role__c.substringBefore('Awana GO Coordinator');
                        String strAfterPatternMatch = someAffObject.Awana_Role__c.substringAfter('Awana GO Coordinator;');
                        system.debug('<< BEFORE STRING >> '+strBeforePatternMatch);
                        system.debug('<< AFTER STRING >> '+strAfterPatternMatch);
                        // Check to see if there is a string after the AGC Pattern 
                        if(strAfterPatternMatch.length() >  0){
                            someAffObject.Awana_Role__c =  strBeforePatternMatch + strAfterPatternMatch;
                        }else{ // Remove ';' and just give the string before the AGC Pattern                              
                            strBeforePatternMatch = strBeforePatternMatch.substring(0,strBeforePatternMatch.length() - 1);
                            someAffObject.Awana_Role__c =  strBeforePatternMatch;
                        }
                    }
                
                }// IF positionAtPattern >= 0
               updateAffObjects.add(someAffObject);
            }//FOR
            // Update all 3 Object Lists of GO, Account and Affiliaiton
            upsert goHistories;
            upsert updateAffObjects;
            upsert buildAccountList;
            insert goCoordinatorCampaignMembers;
        
    }
    global void finish(Database.BatchableContext BC)
    {
        String formatNames = '';
        Integer rowCnt = 1;
        for(String aName : trackResetAccounts){
            if(math.mod(rowCnt,5) == 0){
                formatNames += aName+'\n';
            }else{
                formatNames += aName;
            }
            rowCnt++;
        }
        //Send an email to the Apex job's submitter notifying that the Orders were not successfully created.
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {'tonyw@awana.org','erikt@awana.org'};
        mail.setToAddresses(toAddresses);
        mail.setSubject('Apex GO Annual Reset');
        mail.setPlainTextBody
        ('Here are the GO accounts that were reset for this year\n'+formatNames);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
    }
    
}