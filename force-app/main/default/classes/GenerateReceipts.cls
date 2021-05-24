/****************************************************************************************************************************************************************************************************************
Developer:  Ayesha Zulkha
Company:    Infoglen
Contact:    ayesha@Infoglen.com
Project:    Donation Management
Created:    02/19/2018 - <CRM - 130> Generate Receipts
***************************************************************************************************************************************************************************************************************************************** **************/

global class GenerateReceipts implements Database.Batchable<sObject>, Database.Stateful{
    global String csvColumnHeader;
    global List<String> csvRowValues = new List<String>();
    global Map<String, Receipt_Number_Series__c> ReceiptSeries= Receipt_Number_Series__c.getAll();
    
    global static integer serialNo;
    global static List<String> queryFields = new List<String>{'Batch','Gift_SubType__c','contact','Amount','Amount','CloseDate','ReceiptNumber'};
    global list<opportunity> oppUpdateList = new list<opportunity>();
    global Database.queryLocator start(Database.BatchableContext bc){
        
          Id donationRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();              
          Id matchingGiftTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Matching Gift').getRecordTypeId();              
          
          return Database.getQueryLocator('select id,name,account.npo02__OppAmountThisYear__c,StageName, CloseDate,Account.Constituent_Id__c,npsp__Primary_Contact__r.Constituent_Id__c,'+
                                        'Campaign.name,amount,Account.Mailing_Street_1__c,Account.Mailing_Street_2__c,Apsona_Batch__r.Batch_Number__c,npsp__Primary_Contact__r.Email,Account.Mailing_Street_3__c,Account.Mailing_City__c,Account.Mailing_State_Province__c,Account.Mailing_Zip_Postal_Code__c,'+
                                        'Gift_SubType__c,Account.npo02__Formal_Greeting__c,Account.npo02__Informal_Greeting__c,Account.name,Account.BillingPostalCode,Account.recordtype.name,'+
                                        'npsp__Primary_Contact__r.name,npsp__Primary_Contact__r.MailingStreet,npsp__Primary_Contact__r.Mailingcity,npsp__Primary_Contact__r.MailingState,npsp__Primary_Contact__r.MailingPostalCode,npsp__Primary_Contact__r.Title,npsp__Primary_Contact__r.firstname,'+
                                        '(select name,npsp__General_Accounting_Unit__r.name,npsp__General_Accounting_Unit__r.npsp__Description__c,npsp__Amount__c from npsp__Allocations__r) from opportunity where Receipt_Generated_Date__c=null and StageName=\'Posted\' and Account.id!=null and (recordtype.id =: donationRecordTypeId or recordtype.id =: matchingGiftTypeId ) and Source_Gift_Id__c=null');
      
    }
    
    global void execute (Database.BatchableContext BC, List<opportunity> oppList){
        Receipt_Number_Series__c rtSeries = ReceiptSeries.get('ReceiptStartNumber');
        serialNo =  Integer.valueof(rtSeries.Receipt_No__c);
        String fileRow = '';
        String fieldValue = '';
        for(Opportunity obj : oppList)
        {
            obj.Receipt_Generated_Date__c = system.today();
            serialNo = serialNo +1;
            obj.RECEIPT_NUMBER__c = String.valueOf(serialNo);
            oppUpdateList.add(obj);
            string constID = '';
            String EmailId = '';
            String Addressee = '';
            String AmountThisYear = '';
            String Salutation = '';
            String contactName = '';
            String AddressLine1 = '';String AddressLine2 = '';String AddressLine3 = '';
            String City = ''; String State = '';String ZipCode = '';
            if(String.valueOf(obj.Account.recordtype.name) == 'US Organization' || String.valueOf(obj.Account.recordtype.name) == 'Organization'){
                constID = String.valueOf(obj.Account.Constituent_Id__c);
                Addressee = String.valueOf(obj.Account.Name);
                Salutation = String.valueOf(obj.Account.Name);
                AddressLine1 = String.valueOf(obj.Account.Mailing_Street_1__c);
                if(AddressLine1!=null) AddressLine1 = AddressLine1.replaceAll('[\\s ]+', ' '); 
                AddressLine2 = String.valueOf(obj.Account.Mailing_Street_2__c);
                if(AddressLine2!=null)AddressLine2 = AddressLine2.replaceAll('[\\s ]+', ' '); 
                AddressLine3 = String.valueOf(obj.Account.Mailing_Street_3__c);
                if(AddressLine3!=null)AddressLine3 = AddressLine3.replaceAll('[\\s ]+', ' '); 
                City = String.valueOf(obj.Account.Mailing_City__c);
                State = String.valueOf(obj.Account.Mailing_State_Province__c);
                ZipCode = String.valueOf(obj.Account.Mailing_Zip_Postal_Code__c);
            }
            else if(String.valueOf(obj.Account.recordtype.name) == 'Household Account'){
                constID=String.valueOf(obj.npsp__Primary_Contact__r.Constituent_Id__c);
                EmailId = String.valueOf(obj.npsp__Primary_Contact__r.Email);                
                Addressee = obj.Account.npo02__Formal_Greeting__c;
                Salutation = obj.Account.npo02__Informal_Greeting__c;
                AddressLine1 = String.valueOf(obj.npsp__Primary_Contact__r.MailingStreet);
                if(AddressLine1!=null)AddressLine1 = AddressLine1.replaceAll('[\\s ]+', ' '); 
                City = String.valueOf(obj.npsp__Primary_Contact__r.Mailingcity);
                State = String.valueOf(obj.npsp__Primary_Contact__r.MailingState);
                ZipCode = String.valueOf(obj.npsp__Primary_Contact__r.MailingPostalCode);
            }
            if(obj.accountId!= null){
                AmountThisYear = String.valueOf(obj.getSObject('Account').get('npo02__OppAmountThisYear__c'));
            }
            fileRow = '';
            for(String fieldName : queryFields)
            {
                if(fieldName=='Batch'){
                    fieldValue = '' + String.valueOf(obj.Apsona_Batch__r.Batch_Number__c);
                }
                else if(fieldName=='Contact'){
                    fieldValue = '' + Salutation;
                    fieldValue = fieldValue.replace(',','');
                    fileRow = fileRow + ',' + fieldValue;
                    fieldValue = '' + AddressLine1;
                    fieldValue = fieldValue.replace(',','');
                    fileRow = fileRow + ',' + fieldValue;
                    fieldValue = '' + AddressLine2;
                    fieldValue = fieldValue.replace(',','');
                    fileRow = fileRow + ',' + fieldValue;
                    fieldValue = '' + AddressLine3;
                    fieldValue = fieldValue.replace(',','');
                    fileRow = fileRow + ',' + fieldValue;
                    fieldValue = '' + City;
                    fieldValue = fieldValue.replace(',','');
                    fileRow = fileRow + ',' + fieldValue;
                    fieldValue = '' + State;
                    fieldValue = fieldValue.replace(',','');
                    fileRow = fileRow + ',' + fieldValue;
                    fieldValue = '' + ZipCode;
                    fieldValue = fieldValue.replace(',','');
                    fileRow = fileRow + ',' + fieldValue;
                    fieldValue = '' + EmailId;
                    fieldValue = fieldValue.replace(',','');
                    fileRow = fileRow + ',' + fieldValue;
                    fieldValue = '' + Addressee;
                     
                }
               
                else if(fieldName=='ReceiptNumber'){
                    fieldValue = '' + obj.RECEIPT_NUMBER__c;
                    fieldValue = fieldValue.replace(',','');
                    fileRow = fileRow + ',' + fieldValue;
                    fieldValue = '' + constID;
                }
                else if(fieldName=='Amount'){
                    fieldValue = '' + '$'+obj.get(fieldName);
                }
                else if(fieldName=='Gift_SubType__c'){
                    fieldValue = '' + obj.get(fieldName);
                }
                else if(fieldName=='CloseDate'){
                    String cdate = Datetime.newInstance(obj.closedate, Time.newInstance(0,0,0,0)).format('yyyy-MM-dd');
                    fieldValue = '' + cdate;
                }
                fieldValue = fieldValue.replace(',','');
                fileRow = fileRow + ',' + fieldValue;
                
                
            }
            for(npsp__Allocation__c  ob: obj.npsp__Allocations__r){
                    fieldValue = '' + ob.npsp__General_Accounting_Unit__r.npsp__Description__c;
                    if(ob.npsp__General_Accounting_Unit__r.npsp__Description__c!=null)fieldValue = fieldValue.replaceAll('[\\s ]+', ' ');
                    fieldValue = fieldValue.replace(',','');
                    fileRow = fileRow + ',' + fieldValue;
                    fieldValue = '' + ob.npsp__Amount__c;
                    fieldValue = fieldValue.replace(',','');
                    fileRow = fileRow + ',' + fieldValue;
            }
                    integer sizeliteral = 13+(obj.npsp__Allocations__r.size()*2);
                    for(integer i=sizeliteral;i<=54;i++){
                        fieldValue = '';
                        fieldValue = fieldValue.replace(',','');
                        fileRow = fileRow + ',' + fieldValue;
                        if(i==52){
                            fieldValue = '' + String.valueOf(obj.Campaign.name);
                            fieldValue = fieldValue.replace(',','');
                            fileRow = fileRow + ',' + fieldValue;
                            fieldValue = '' + AmountThisYear; 
                            fieldValue = fieldValue.replace(',','');
                            fileRow = fileRow + ',' + fieldValue;
                        }
                    }
            fileRow = fileRow.replaceFirst(',','');
            fileRow = fileRow.replace('null', '');
            system.debug('%%fileRow'+fileRow );
            csvRowValues.add(fileRow);
        }
        rtSeries.Receipt_No__c = serialNo ;
        try{
            Update rtSeries;
        }
        catch(exception e){
        }
    }
    
    global void finish(Database.BatchableContext BC){
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id =:BC.getJobId()];
      if(a.TotalJobItems > 0){    
        csvColumnHeader = 'Batch Number,Gift Sub Type,Salutation,Address line 1,Address line 2,Address line 3,City,State,ZIP Code,Email,Addressee,Amount,Receipt Amount,Gift Date,Receipt Number,Constituent ID,'+
                          'Fund Description_1,Split Amount_1,Fund Description_2,Split Amount_2,Fund Description_3,Split Amount_3,Fund Description_4,Split Amount_4,Fund Description_5,Split Amount_5,'+
                          'Fund Description_6,Split Amount_6,Fund Description_7,Split Amount_7,Fund Description_8,Split Amount_8,Fund Description_9,Split Amount_9,Fund Description_10,Split Amount_10,'+
                          'Fund Description_11,Split Amount_11,Fund Description_12,Split Amount_12,Fund Description_13,Split Amount_13,Fund Description_14,Split Amount_14,Fund Description_15,Split Amount_15,'+
                          'Fund Description_16,Split Amount_16,Fund Description_17,Split Amount_17,Fund Description_18,Split Amount_18,Fund Description_19,Split Amount_19,Fund Description_20,Split Amount_20,Appeal ID,YTD Amount\n';
        String csvFile = csvColumnHeader + String.join(csvRowValues,'\n');
        Blob csvBlob = Blob.valueOf(csvFile);
        Receipt__c re = new Receipt__c();
        re.name = String.valueof(system.today());
        try{
            insert re;
        }
        catch(exception e){
        }
        /*Attachment AttachmentObj = new Attachment(Body = csvBlob,
                                                  Name = 'Receipt-' +System.now().format('yyyy-MM-dd') + '.csv',
                                                  parentId = re.id);
                                         
        try{
            insert AttachmentObj; 
        }
        catch(exception e){
        }*/
        ContentVersion conVer = new ContentVersion();
        conVer.ContentLocation = 'S'; // S specify this document is in SF, use E for external files
        conVer.PathOnClient = 'Receipt.csv'; // The files name, extension is very important here which will help the file in preview.
        conVer.Title = 'Receipt-' +System.now().format('yyyy-MM-dd') + '.csv'; // Display name of the files
        conVer.VersionData = csvBlob; 
        //insert conVer;
        try{
            insert conVer; 
        }
        catch(exception e){
        }
        // First get the content document Id from ContentVersion
        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
        //Create ContentDocumentLink
        ContentDocumentLink cDe = new ContentDocumentLink();
        cDe.ContentDocumentId = conDoc;
        cDe.LinkedEntityId = re.Id; // you can use objectId,GroupId etc
        cDe.ShareType = 'I'; // Inferred permission, checkout description of ContentDocumentLink object for more details
        cDe.Visibility = 'AllUsers';
        //insert cDe;
        try{
            insert cDe; 
        }
        catch(exception e){
        }
        try{
            Database.update(oppUpdateList,false);
        }
        catch(exception e){
        }
        
      if(a.status == 'Completed'){
        if(re.id!=null){
            re.Tech_BatchProcess_Id__c = a.id;
            try{
                update re;
            }
            catch(exception e){
            }
        }
      }
    }
    }
}