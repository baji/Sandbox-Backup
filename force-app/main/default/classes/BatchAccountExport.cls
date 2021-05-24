/*******************************************************
 * @ClassName: BatchAccountExport.cls
 * @author: infoglen - Urvashi Dagara
 * @Description: Batch class to Export Individual type Account records.
 * 10/10/2019 - SMS-88-Convert All Individual Accounts
 * @ChangeHistory
 * 
 * *******************************************************/
global class BatchAccountExport implements Database.Batchable<sObject>, Database.Stateful{
    
    public String query;
    Public string fileOutput;
    public Id accountRecordTypeId =  Awana_Settings__c.getValues('AccountRecordTypeId').value__c;   
    
    public Database.QueryLocator start(Database.BatchableContext BC){              
        fileOutput = createLineHeader() + '\n'; 
        return Database.getQueryLocator(query);
    }
       
    public void execute(Database.BatchableContext info, List<Account> scope){
                    
        if(!scope.isEmpty()){
            for(Account acc : scope){     
                if(acc.Contacts != null && acc.Contacts.size() == 1){
                    for(Contact con :acc.Contacts){
                        if(String.isNotBlank(con.Name) && String.isNotBlank(acc.Name) && con.Name == acc.Name){
                            String lineOutput = '';               
                            lineOutput += acc.id + ',' + acc.name.escapeCsv() + ',' +  acc.contacts[0].Id + ',' + acc.RecordType.Name.escapeCsv();
                            fileOutput += lineOutput.removeEnd(',') + '\n';
                        }
                    }
                }
            }            
        }  
    }

    global void finish(Database.BatchableContext bc){
         
        try{           
            String fileName = 'AccountRecords.csv';
            Document doc = new Document();
            doc.Body = Blob.valueOf(fileOutput);
            doc.type = 'csv';
            doc.Name = fileName;            
            sendEmail(doc,fileName);            
        }catch(exception e){
            system.debug('error--'+e);
        }
    }
    
    public static void invokeBatch(String q,Integer batchSize){
        
        BatchAccountExport batch = new BatchAccountExport();
        
        if(q != null)         
            batch.query = q;
        else
            batch.query = 'SELECT id,Name,(SELECT Id,Name FROM Contacts WHERE AccountId != null),RecordType.Name FROM Account WHERE RecordTypeId =: accountRecordTypeId';                
            
            Database.executeBatch(batch,batchSize); 
      }
    
    /*Method to create CSV file header*/
    private String createLineHeader(){
        
        String lineHdr = 'Id,Name,Contact Id,Record type Name';        
        return lineHdr;
    }  
    
    /*Send success email to receipents after export*/
    public static void sendEmail(Document doc,String fileName){        
        try{ 
                        
            String toAdress = Awana_Settings__c.getValues('ToAddress').Value__c;
            List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
            Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
            efa.setFileName(doc.Name);
            efa.setBody(doc.Body);
            fileAttachments.add(efa);
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[]{toAdress});
            mail.setReplyTo(toAdress);
            mail.setSenderDisplayName('Awana');
            
            mail.setSubject('Records:'+fileName);
            
            String plainBody = 'Hi there,\n\n';
            plainBody += 'Please find '+ fileName + '\n';
            plainBody += 'Please Note: If the attachement is a HTML link, open the file and click the ' +
                         'link inside the file to download the export data.\n\n';
            mail.setPlainTextBody(plainBody);
            
            mail.setFileAttachments(fileAttachments);            
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
      
        }catch(Exception e) {            
            system.debug('error--'+e);                                  
        }       
    }    
}