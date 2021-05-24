/****************************************************************************************************************************************************************************************************************
Developer:  Ayesha Zulkha
Company:    Infoglen
Contact:    ayesha@Infoglen.com
Project:    Donation Management
Created:    07/13/2018 - Batch Class to process convio gifts
***************************************************************************************************************************************************************************************************************************************** **************/
global class GenerateConvioGifts implements Database.Batchable<List<String>>, Database.Stateful{
    
    global id reId; 
    global string header;
    global map<string,integer> fileMap;
    global set<string> transSet;
    global Decimal TotalAmount = 0;
    global set<string> gauNames = new set<string>();
    global Map<String,String> newGAU = new Map<String,String>();
    global set<String> campaignSet = new set<String>();
    global apsona_be__Batch__c  newApsonaBatch;
    global integer recProcessed = 0;
    global integer recfailed = 0;
    global string exceptionMsg = '';
    global list<string> errorList = new list<string>();
    global GenerateConvioGifts(Id recId) {
        reId= recId;
        transSet = new set<string>();
        
        newApsonaBatch = ConvioBatch.createCVBatch();
    }
    global Iterable<List<String>> start(Database.BatchableContext bc){
        String nameFile;
        Blob contentFile;
        String[] filelines = new String[]{};
        List<List<String>> strFields = new List<List<String>>();
        ContentDocumentLink con = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =:reId];
        // Get the actual files
        ContentVersion contentVersions = [SELECT Id,ContentUrl,title,VersionData FROM  ContentVersion WHERE  ContentDocumentId =:con.ContentDocumentId AND  IsLatest = True];
        contentFile =   contentVersions.VersionData;    
        String hex = EncodingUtil.convertToHex(contentFile);
        System.assertEquals(0, hex.length() & 1);
        final Integer bytesCount = hex.length() >> 1;
        String[] bytes = new String[bytesCount];
        for(Integer i = 0; i < bytesCount; ++i)
            bytes[i] =  hex.mid(i << 1, 2);
        nameFile  = EncodingUtil.urlDecode('%' + String.join(bytes, '%'), 'ISO 8859-2');
        nameFile = nameFile.replaceAll(',"""',',"DBLQT').replaceall('""",','DBLQT",');
        // now replace all remaining double quotes - we do this so that we can reconstruct
        // fields with commas inside assuming they begin and end with a double quote
        nameFile = nameFile.replaceAll('""','DBLQT');
        nameFile = nameFile.replaceAll(',,',',DBLQT,');
        strFields = CSVReader.readCSVFile(nameFile);
        filelines = nameFile.split('\n');
        header = filelines.remove(0);
        header  = header.replaceAll('[\\s ]+', '');
        fileMap = new map<string,integer>();
        list<string> headerValue = header.split(',');
        for(integer i=0;i<headerValue.size();i++){
            fileMap.put(headerValue[i],i);
        }
        return strFields;
        
    }
    global void execute (Database.BatchableContext BC, List<List<String>> allFields){
        set<string> cleanconIds = new set<string>();
        List<String> newStringFile = new List<String>();
        for(list<string> str1:allFields){
            list<integer> mapvalues = fileMap.values();
            if(str1[fileMap.get('MEMBER_ID')]!='')cleanconIds.add(str1[fileMap.get('MEMBER_ID')]);
            if(str1[fileMap.get('FORM_NAME')]!='')campaignSet.add(str1[fileMap.get('FORM_NAME')]);
            String GAUName = str1[fileMap.get('ACCOUNTING_CODE')];
            if(GAUName!=''){
                String newGAUName = GAUName ;
                boolean alpha = (GAUName.substring(1,2).isalpha());
                if(GAUName.substring(0,1) == 'U' && alpha==false){
                    newGAUName = GAUName.remove('U');
                }
                newGAU.put(GAUName,newGAUName );
            }
        }
        Map<string,account> acMap = new map<string,account>();
        Map<string,contact> conMap = new map<string,contact>();
        for(contact co:[select id,name,constituent_id__c,accountid,Merged_Constituent_Id__c from contact where Constituent_Id__c !=null AND (Constituent_Id__c in :cleanconIds OR Merged_Constituent_Id__c in :cleanconIds)]){
            conMap.put(co.constituent_id__c,co);
            if(co.Merged_Constituent_Id__c!=null)  conMap.put(co.Merged_Constituent_Id__c,co);    
        }
        for(account ac:[select id,name,constituent_id__c,Merged_Constituent_Id__c from account where (recordtype.name != 'Household Account') AND Constituent_Id__c !=null AND (Constituent_Id__c in :cleanconIds OR Merged_Constituent_Id__c in :cleanconIds)]){
            acMap.put(ac.constituent_id__c,ac);
            if(ac.Merged_Constituent_Id__c!=null)  acMap.put(ac.Merged_Constituent_Id__c,ac);    
        }
        Map<String,Id> camMap = new map<String,Id>();
        for(campaign cm:[select id,name from campaign where IsActive=true and name in:campaignSet]){
            camMap.put(cm.name,cm.id);
        }
        Map<String,Id> gauMap = new map<String,Id>();
        for(npsp__General_Accounting_Unit__c gau:[select id,name from npsp__General_Accounting_Unit__c where npsp__Active__c=true]){
            gauMap.put(gau.name,gau.id);
        }
        list<opportunity> opList = new list<opportunity>();
        Id donationRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
        
        for(list<string> str1:allFields){
            try{
                if((!transSet.contains(str1[fileMap.get('TRANSACTION_ID')])) && str1[fileMap.get('TRANSACTION_ID')]!=''){
                    transSet.add(str1[fileMap.get('TRANSACTION_ID')]);
                    
                    if((acMap!= null && acMap.size()>0) || (conMap!= null && conMap.size()>0)) {
                        
                        opportunity op = new opportunity();
                        Date cDate = date.parse(str1[fileMap.get('DONATION_DATE')]);
                        String cldate = Datetime.newInstance(cDate, Time.newInstance(0,0,0,0)).format('yyyy-MM-dd');
                        if((conMap!= null && conMap.size()>0) && conMap.get(str1[fileMap.get('MEMBER_ID')])!=null){
                            op.npsp__Primary_Contact__c = conMap.get(str1[fileMap.get('MEMBER_ID')]).id;
                            op.accountid = conMap.get(str1[fileMap.get('MEMBER_ID')]).accountid;
                            op.name =   conMap.get(str1[fileMap.get('MEMBER_ID')]).name +' '+cldate +' - Donation';
                        }
                        else if((acMap!= null && acMap.size()>0) && acMap.get(str1[fileMap.get('MEMBER_ID')])!=null){
                            op.accountid= acMap.get(str1[fileMap.get('MEMBER_ID')]).id;
                            op.name =   acMap.get(str1[fileMap.get('MEMBER_ID')]).name +' '+cldate +' - Donation';
                        }
                        else{
                            op.name = cldate +' - Donation';
                        }
                        op.recordtypeid = donationRecordTypeId;
                        op.Convio_Batch__c = reId;
                        op.Campaignid = camMap.get(str1[fileMap.get('FORM_NAME')]);
                        op.Transaction_Id__c = str1[fileMap.get('TRANSACTION_ID')];
                        op.Gift_Type__c = 'Cash';
                        op.Gift_SubType__c = 'Convio';
                        op.IsRecurring__c = (str1[fileMap.get('PAYMENT_PLAN')] == 'Sustaining')?true:false;
                        op.closedate = cDate;
                        op.Apsona_Batch__c = newApsonaBatch.id;
                        op.Batch_Number_External_Id__c = newApsonaBatch.Batch_Number__c;
                        string i= str1[fileMap.get('TOTAL_GIFT_AMOUNT')];
                        decimal dAmount = Decimal.valueOf(i.replaceAll('[^.\\d]',''));
                        op.amount = dAmount;
                        TotalAmount = TotalAmount+op.amount;
                        op.stageName = 'Posted';
                        opList.add(op);
                        
                    }
                }
            }
            catch(exception e){
                System.debug('The following exception has occurred: ' + e.getMessage());
                exceptionMsg = ' The exception occured is '+e.getMessage();
            }
        }
        if(opList!=null && opList.size()>0){
            Schema.SObjectField f = Opportunity.Fields.Transaction_Id__c;
            Database.UpsertResult[] srList = Database.upsert(opList,f,false);
            
            // Iterate through each returned result
            Integer index = 0;
            for (Database.UpsertResult sr : srList) {
                if (sr.isSuccess()) {
                    recProcessed = recProcessed+1;
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully inserted  opp ID: ' + sr.getId());
                }
                else {
                    // Operation failed, so get all errors
                    recfailed =recfailed+1;  
                    errorList.add(opList[index].Transaction_Id__c);
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Opportunity fields that affected this error: ' + err.getFields());
                    }
                }
                index++;
            }
            
        }
        Map<string,opportunity> trMap = new Map<string,opportunity>();
        for(opportunity op:[select id,name,transaction_id__c,amount from opportunity where  recordtype.name='Donation' AND transaction_id__c<>null AND transaction_id__c in:transSet]){
            trMap.put(op.transaction_id__c,op);
            
            
        }
        list<npsp__allocation__c> alloList = new list<npsp__allocation__c>();
        for(list<string> str1:allFields){
            if(trMap.containskey(str1[fileMap.get('TRANSACTION_ID')]) && gauMap.containskey(newGAU.get(str1[fileMap.get('ACCOUNTING_CODE')]))){
                npsp__allocation__c np = new npsp__allocation__c();
                np.npsp__General_Accounting_Unit__c = gauMap.get(newGAU.get(str1[fileMap.get('ACCOUNTING_CODE')]));
                np.npsp__Opportunity__c = trMap.get(str1[fileMap.get('TRANSACTION_ID')]).id;
                np.npsp__Amount__c = Decimal.valueOf(str1[fileMap.get('TOTAL_DESIGNATED_AMOUNT')]);
                np.Tech_Unique_Field__c = trMap.get(str1[fileMap.get('TRANSACTION_ID')]).transaction_id__c + gauMap.get(newGAU.get(str1[fileMap.get('ACCOUNTING_CODE')])) +Decimal.valueOf(str1[fileMap.get('TOTAL_DESIGNATED_AMOUNT')]);
                alloList.add(np);
            }
            
            
        }
        if(alloList!=null && alloList.size()>0){
            Schema.SObjectField f = npsp__allocation__c.Fields.Tech_Unique_Field__c ;
            Database.UpsertResult [] arList = Database.upsert(alloList,f, false);
            
            // Iterate through each returned result
            for (Database.UpsertResult sr : arList) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully inserted  opp ID: ' + sr.getId());
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Allocation fields that affected this error: ' + err.getFields());
                    }
                }
            }
        }
    }
    global void finish(Database.BatchableContext BC){
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors,ExtendedStatus, JobItemsProcessed,TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id =:BC.getJobId()];
        if(a.TotalJobItems > 0){
            if(newApsonaBatch!=null && errorList.size()==0){
                newApsonaBatch.Tech_BatchProcess_Id__c = a.id;
            }
            try{
                update newApsonaBatch;
            }
            catch(exception e){
            }
            if(reId!=null && TotalAmount>0){
                List<Convio_Batch__c> cvRecord = [select id,name,Total_Number_of_Gifts__c,Total_Amount__c  from Convio_Batch__c where id=:reId limit 1];
                if(cvRecord[0].id!=null){
                    cvRecord[0].Total_Number_of_Gifts__c = String.valueof(recProcessed);
                    cvRecord[0].Total_Amount__c = TotalAmount;
                    cvRecord[0].Convio_Batch_Number__c = newApsonaBatch.Batch_Number__c;
                    try{
                        update cvRecord;
                    }
                    catch(exception e){
                    }
                }
            }
            
        }
        
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'donotreply@awana.org'];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        if ( owea.size() > 0 ) {
            mail.setOrgWideEmailAddressId(owea.get(0).Id);
        }
        
        String[] toAddresses = new String[] {a.CreatedBy.Email};
            mail.setToAddresses(toAddresses);
        mail.setSubject('Convio Donations Batch ' + a.Status);
        String batchNo ='';
        if(a.NumberOfErrors>0 && a.Status == 'Completed'){
            if(recProcessed >0){
                batchNo  = ' The batch number for the donations is '+newApsonaBatch.Batch_Number__c;
            }
            mail.setPlainTextBody('Batch has encountered error.'+ exceptionMsg +' Number of Batch Failures are '+ a.NumberOfErrors + ' Number of Gifts successfully created are '+ recProcessed +  batchNo  + ' Please verify the csv file');
            
        }
        else{
            if(errorList!=null && errorList.size()>0){
                mail.setPlainTextBody('Donations Created are ' + recProcessed +   ' with '+ recfailed + ' failures. The batch number for the donations is '+newApsonaBatch.Batch_Number__c+' Transaction Ids of the failed records are '+JSON.serialize(errorList));
                
            }
            else{
                mail.setPlainTextBody('Donations Created are ' + recProcessed +   ' with '+ recfailed + ' failures. The batch number for the donations is '+newApsonaBatch.Batch_Number__c);
            }
        }
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
}