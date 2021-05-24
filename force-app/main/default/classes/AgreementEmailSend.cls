public class AgreementEmailSend {
	  public String language {get;set;}
    
    public AgreementEmailSend(ApexPages.StandardController controller) {
    }
    
    
    public List<SelectOption> getContacts() {
        List<SelectOption> options = new List<SelectOption>();
        Id accid = ApexPages.currentPage().getParameters().get('id');
        
        List<npe5__Affiliation__c> contacts = [select Id, npe5__Contact__r.Id, npe5__Contact__r.FirstName, npe5__Contact__r.LastName from npe5__Affiliation__c where npe5__Organization__c=: accid];
        
        for(npe5__Affiliation__c affCon : contacts) {
            String conName = affCon.npe5__Contact__r.FirstName + ' ' + affCon.npe5__Contact__r.LastName;
            Id conid = affCon.npe5__Contact__r.Id;
            
            options.add(new SelectOption(conid, conName));
        }
        
        return options;
    }
    Account account;
    public Account getAccount(){
        if(account != null){
            return account;
        }
        else{
            account = new Account(Name='Test');
            return account;
        }
    }
    
    public PageReference sendAgreement() { 
        
       Id accid = ApexPages.currentPage().getParameters().get('id');
       Account a = [SELECT Name, Mailing_Address_Book__c 
                    FROM Account 
                    WHERE Id =: accid];  
        
       Contact con = [SELECT Id,FirstName,LastName,Email 
                      FROM Contact 
                      WHERE Id =:account.Applicant__c LIMIT 1];
       
      
        /*List<ContentDocumentLink> links=[SELECT ContentDocumentId,LinkedEntityId FROM ContentDocumentLink where LinkedEntityId= '0690S000000NiiNQAS'];
        Set<Id> ids=new Set<Id>();
        for(ContentDocumentLink link:links)
        {
            ids.add(link.ContentDocumentId);
        }*/
        //List<ContentVersion> versions=[SELECT VersionData,Title,ContentDocumentId,FileExtension FROM ContentVersion WHERE ContentDocumentId = '0690S000000NiiNQAS' AND IsLatest = true];
        
        
        //List<Attachment> files = [SELECT Name,versiondata ContentType FROM Attachment WHERE Id IN :attachmentIds];
        //select id from contentdocument where id ='versions'
        //String attachmentBody = EncodingUtil.base64Encode(attach.VersionData);
        //Blob pdfBlob = EncodingUtil.base64Decode(attachmentBody);
        
       EmailTemplate tempID = [SELECT Id,Subject,HTMLValue,Name 
                               FROM EmailTemplate 
                               WHERE Id ='00X0S000000qC0s'];
	   String emailBody = tempID.HTMLValue; 
       string updatedEmailBody =  createEmailBody('accountNameTest',emailBody,con);
        
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();  
       String[] toAddresses = new String[] {con.Email}; 
       string sub =  tempID.Subject;   
       sub =   sub.replace('{!Contact.Id}',con.Id);       
       mail.setSubject(sub); 
       mail.setToAddresses(toAddresses);
       mail.setTargetObjectId(con.Id);
       mail.setOrgWideEmailAddressId('0D2f40000004Dq7');
        if(String.isNotBlank(language) && language == 'Spanish'){           
            mail.setTemplateId('00X0S000000qBzp');           
       }else{
           mail.setHTMLBody(updatedEmailBody);
           mail.setTemplateId('00X0S000000qC0s');
           
       } 
      
       //mail.setSenderDisplayName('Awana Support');
       String[] ccAddresses = new String[] {'urvashi.dagara@infoglen.com'};  
       //mail.setCcAddresses(ccAddresses);
       mail.setReplyTo('agreementsandbox@o-2e6ylqwkfqbreegodsb058ki61g5zcgv6kjaghgn0tv4t7vsit.0s-9czsuau.cs54.apex.sandbox.salesforce.com');
       //mail.setWhatId(con.Id);  
       
       try {
  			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		} catch (Exception e) {
  			system.debug('error--'+e);
		} 
        
        
	return null;       
    }
    
    
    public static String createEmailBody(String accountName,String emailBody,Contact con){
        
        emailBody = emailBody.replace('Church_Name',accountName);
        emailBody = emailBody.replace('{!Contact.Id}',con.Id);
        emailBody = emailBody.replace('{!Contact.FirstName}',con.FirstName);
        emailBody = emailBody.replace('{!Contact.LastName}',con.LastName);
        return emailBody;
    }
    
    
    public PageReference sendToMe() {
        
        return null;
    }
    
    public void setAccount(Account account){
        if(account != null){
          account = new Account( Name='Test');
        }
        else
        {
            account = new Account(Name='Test');
        }
    }
}