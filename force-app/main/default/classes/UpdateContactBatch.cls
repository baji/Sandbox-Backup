public class UpdateContactBatch implements Database.batchable<String>, Database.Stateful{ 
    
    public List<String> fileData;   
    public String file;    
    public String fileName;
    public Map<String,Integer> columnHeaderIndexMap;
    public List<String> errList = new List<String>();
    public List<String> updateErrList = new List<String>();
    public Integer totalRecords = 0;
    public Integer successCounter = 0;
    public Integer errorCounter = 0;
    public Id accRecordId = Awana_Settings__c.getValues('AccountUSOrganizationRecordtype').Value__c;
    //public static boolean batchUpdate = false;
    
    public UpdateContactBatch() {
        updateErrList = new List<String>();
    }
    
    public Iterable<String> start(Database.BatchableContext bc){
        try {  
            //totalRecords = 0;
            String header = fileData.remove(0); //remove header row and pass data to execute.
            columnHeaderIndexMap = getColumnNumberMap(header);
        }Catch (Exception ex) {
            system.debug('error==>'+ex);
            errList.add(ex.getMessage());
            errList.add(ex.getStackTraceString());                 
            sendErrorNotification(errList);  
        }
        return fileData; 
    }
    
    public void execute(Database.BatchableContext BC,List<String> csvFileLines) {
        //system.debug('fileData==>'+csvFileLines);
        try{
            Set<String> contactIds = new Set<String>();
            Set<String> accountIds = new Set<String>();
            for (String row : csvFileLines) {
                List<String> columns = row.split(','); 
                
                String conId = columns[columnHeaderIndexMap.get('Id')].trim().replace('\r\n', '').replace('\n', '').replace('\r', '');
                String accId = columns[columnHeaderIndexMap.get('Account Id')].trim().replace('\r\n', '').replace('\n', '').replace('\r', '');
                
                //system.debug('conId==>'+conId);
                //system.debug('accId==>'+accId);
                
                if(String.isNotBlank(conId))
                    contactIds.add(conId.replaceAll('[^a-zA-Z0-9\\s+]',''));                
                
                if(String.isNotBlank(accId))
                    accountIds.add(accId.replaceAll('[^a-zA-Z0-9\\s+]',''));                
                
            }
            //system.debug('contactIds===>'+contactIds);
            //system.debug('accountIds===>'+accountIds);
            if(!contactIds.isEmpty() && contactIds.size() > 0 && !accountIds.isEmpty() && accountIds.size() > 0){
                List<Contact> contactList = [SELECT Id,AccountId,Account.RecordTypeId 
                                             FROM Contact 
                                             WHERE Id IN: contactIds 
                                             AND AccountId IN: accountIds];
                
                //system.debug('contactList==>'+contactList);
                
                List<npe5__Affiliation__c> affiliationList = [SELECT Id,npe5__Contact__c,npe5__Organization__c 
                                                              FROM npe5__Affiliation__c 
                                                              WHERE npe5__Contact__c IN: contactIds];
                
                //system.debug('affiliationList==>'+affiliationList);
                
                Map<Id,Set<Id>> contactVsAffMap = new Map<Id,Set<Id>>();
                if(!affiliationList.isEmpty() && affiliationList.size() > 0){
                    for(npe5__Affiliation__c aff:affiliationList){
                        if(!contactVsAffMap.ContainsKey(aff.npe5__Contact__c))
                            contactVsAffMap.put(aff.npe5__Contact__c,new Set<Id>());
                        
                        contactVsAffMap.get(aff.npe5__Contact__c).add(aff.npe5__Organization__c);
                    }
                }
                
                //system.debug('contactVsAffMap==>'+contactVsAffMap);
                Map<Id,Id> conVsAccountMap = new Map<Id,Id>();
                List<Contact> updateContactList = new List<Contact>();
                if(!contactList.isEmpty() && contactList.size() > 0){
                    for(Contact con:contactList){
                        if(String.isNotBlank(con.AccountId)){
                            if(String.isNotBlank(accRecordId) && accRecordId != con.Account.RecordTypeId){
                                errorCounter++;
                                updateErrList.add('ContactId: '+con.Id +'###AccountId: '+con.AccountId +'###Message: This is not US Organization type Account.');
                            }
                            else if(accRecordId == con.Account.RecordTypeId && (contactVsAffMap.isEmpty() || !contactVsAffMap.containsKey(con.Id))){
                                conVsAccountMap.put(con.Id,con.AccountId);
                            }else if(accRecordId == con.Account.RecordTypeId && !contactVsAffMap.isEmpty() && contactVsAffMap.containsKey(con.Id) && !contactVsAffMap.get(con.Id).contains(con.AccountId)){
                                conVsAccountMap.put(con.id,con.AccountId);
                            }
                            if(accRecordId == con.Account.RecordTypeId){
                                con.AccountId = null;
                                updateContactList.add(con);
                            }
                            
                        }
                        //con.AccountId = null;  
                    }         
                    
                    //system.debug('conVsAccountMap==>'+conVsAccountMap);
                    totalRecords = contactList.size();                    
                    checkRecursive.batchUpdate = true;
                    List<Database.SaveResult> res = Database.update(updateContactList,false);
                    
                    List<npe5__Affiliation__c> affList = new List<npe5__Affiliation__c>();
                    //system.debug('res==>'+res);
                    //system.debug('res==>'+res.size());
                    for(Integer i=0; i < updateContactList.size(); i++) {
                        Database.SaveResult sr = res[i];
                        contact con = updateContactList[i];
                        //system.debug('con==>'+con);
                        if (sr.isSuccess()) {
                            successCounter++; 
                            if(!conVsAccountMap.isEmpty() && conVsAccountMap.containskey(con.Id)){
                                npe5__Affiliation__c aff = new  npe5__Affiliation__c();
                                system.debug('con.id==>'+con.id); 
                                aff.npe5__Organization__c = conVsAccountMap.get(con.id);
                                aff.npe5__Contact__c = con.id;
                                aff.npe5__Status__c = 'Current';                                
                                affList.add(aff);                             
                            } 
                            //System.debug('Records are updated Successfully');
                        } 
                        else if(!sr.isSuccess()) {
                            errorCounter++;
                            Database.Error errors =  sr.getErrors().get(0);
                            updateErrList.add(errors.getMessage() +  ' ContactId: '+con.Id);
                        }
                    }
                    if(!affList.isEmpty()){
                        insert affList;
                    }
                }
            }
        }catch(exception ex){
            system.debug('error==>'+ex);
            //if(Test.isRunningTest()){
            errList.add(ex.getMessage());
            errList.add(ex.getStackTraceString());                 
            sendErrorNotification(errList);
            //}
            
        }
    }
    
    public void finish(Database.BatchableContext BC){
        //system.debug('updateErrList==>'+updateErrList);
        if(updateErrList.size() > 0 && !updateErrList.isEmpty()){            
            sendFinishMail('error',bc);            
        }else{
            sendFinishMail('success',bc);            
        }       
    }
    
    public void sendFinishMail(String finishType,Database.BatchableContext BC){
        //system.debug('finishType===>'+finishType);
        AsyncApexJob a = [SELECT Id, Status,ExtendedStatus,NumberOfErrors,
                          JobItemsProcessed,TotalJobItems,CreatedBy.Email                              
                          FROM AsyncApexJob 
                          WHERE Id =:BC.getJobId()];
        
        Messaging.EmailFileAttachment[] emailAttList = new List<Messaging.EmailFileAttachment>();
        Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
        
        blob csvBlob = Blob.valueOf(file);
        String csvname= String.isNotBlank(fileName) ? fileName :  'Contact.csv' ;
        csvAttc.setFileName(csvname);
        csvAttc.setBody(csvBlob);
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        String[] toAddresses = new String[] {a.CreatedBy.Email};
            
        mail.setToAddresses(toAddresses);
        mail.setSubject('Update contact batch ' + a.Status);
        if(finishType == 'success'){
            mail.setPlainTextBody('Total records in CSV ' + totalRecords +
                                  ' with '+ errorCounter + ' failures and '+ successCounter + ' Suceess. Please find attached file you have uploaded.');
        }else if(finishType == 'error'){
            Messaging.EmailFileAttachment errorCSV = new Messaging.EmailFileAttachment();
            
            mail.setPlainTextBody('Total records processed ' + totalRecords +
                                  ' with '+ errorCounter + ' failures and '+ successCounter + ' Suceess.Please find attached file you have uploaded and along with error file.');
            
            String finalstr = 'Error \n';            
            String attName = 'Error'+Date.today()+'.csv';
            errorCSV.setFileName(attName);
            
            for(String em  : updateErrList){
                string recordString = '"'+em+'"\n';
                finalstr = finalstr +recordString;
            }
            
            
            errorCSV.setBody(Blob.valueOf(finalstr));
            emailAttList.add(errorCSV);
        }
        emailAttList.add(csvAttc);  
        mail.setFileAttachments(emailAttList);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
    public Map<String,Integer> getColumnNumberMap(String header){
        Map<String,Integer> returnMap = new Map<String,Integer>();
        Integer index=0;
        system.debug('>header ==> '+header.split(','));
        Set<String> headerArray = new Set<String>(header.split(','));
        for (String str : header.split(',')) {
            
            if (str.trim().toUpperCase() == ('ID')) {
                returnMap.put('Id',index);
            }
            else if (str.trim().toUpperCase() == ('ACCOUNTID')) {
                returnMap.put('Account Id',index);
            } 
            index++;
        }
        System.debug('>> map>>>'+returnMap);
        return returnMap;
    }
    
    public static void sendErrorNotification(List<String> errList){
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        List<User> user = [SELECT Email FROM User WHERE Id =:Userinfo.getUserId()];
        
        List<String> sendTo = new List<String>();
        sendTo.add(user[0].Email);
        
        String sub = 'Error in Update Contact Batch : '+system.today();
        String plainBody = 'Hi there,\n\n';
        plainBody += 'Update Contact Batch encountered below errors.\n';
        
        if(!errList.isEmpty()) {
            plainBody += '\n\nError List: \n';
            for(Integer i=0; i<errList.size(); i++) {
                plainBody += ' '+(i+1)+'.  '+errList[i]+'. \n';
            }           
        }        
        
        mail.setToAddresses(sendTo);
        mail.setSubject(sub); 
        mail.setPlainTextBody(plainBody);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
}