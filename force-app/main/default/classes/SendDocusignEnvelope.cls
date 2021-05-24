public class SendDocusignEnvelope {
    
    public String language {get;set;}
    
    public SendDocusignEnvelope(ApexPages.StandardController controller) {
    }
    public SendDocusignEnvelope(){    
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
    
    public PageReference sendAgreement() {   
       Id accid = ApexPages.currentPage().getParameters().get('id');
       Account a = [select Name, Mailing_Address_Book__c from Account where Id =: accid];       
       Contact con = [select Id,FirstName,LastName,Email from Contact where Id =:account.Applicant__c Limit 1];       
       String conFullName = con.FirstName+' '+con.LastName; 
       
       
       system.debug('language--'+language); 
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       String[] toAddresses = new String[] {con.Email};
       mail.setToAddresses(toAddresses);
       mail.setReplyTo(UserInfo.getUserEmail());
       mail.setSenderDisplayName('Awana Customer Care');
       mail.setSubject('Please sign this Awana Ministry Agreement');
       String body;
        
       if(String.isNotBlank(language) && language == 'Spanish'){
           /* PRODUCTION VERSION */
           body='Thank you for your interest in reaching kids with the Gospel! To start your ministry with Awana, please review and electronically sign the agreement by following this link. <html><body><a href="https://www.docusign.net/Member/PowerFormSigning.aspx?PowerFormId=29ea3797-5341-4c39-b24e-f8c64c2f6f1c&Signer1_Email='+con.Email+'&ChurchName='+a.Name+'&CustID='+a.Mailing_Address_Book__c+'&Signer1_UserName='+conFullName+'&ContactEmail='+con.Email+'">Online Ministry Agreement</a></body></html> YOUR ACCESS CODE: awana';                          
           /* DEMO*/
           //body = 'Thank you for your interest in reaching kids with the Gospel! To start your ministry with Awana, please review and electronically sign the agreement by following this link. <html><body><a href=https://demo.docusign.net/Member/PowerFormSigning.aspx?PowerFormId=e9f45644-4d95-49bf-9c20-671690e61cb9&Signer1_Email='+con.Email+'&ChurchName='+a.Name+'&CustID='+a.Mailing_Address_Book__c+'&Signer1_UserName='+conFullName+'&ContactEmail='+con.Email+'">Online Ministry Agreement</a></body></html> YOUR ACCESS CODE: awana';             
           
       }else{
           /* PRODUCTION VERSION */
           body='Thank you for your interest in reaching kids with the Gospel! To start your ministry with Awana, please review and electronically sign the agreement by following this link. <html><body><a href="https://www.docusign.net/Member/PowerFormSigning.aspx?PowerFormId=8b63c624-b8eb-4990-8fb5-8662652c3a1a&Signer1_Email='+con.Email+'&ChurchName='+a.Name+'&CustID='+a.Mailing_Address_Book__c+'&Signer1_UserName='+conFullName+'&ContactEmail='+con.Email+'">Online Ministry Agreement</a></body></html> YOUR ACCESS CODE: awana';       
           /* DEMO VERSION */ 
           //body = 'Thank you for your interest in reaching kids with the Gospel! To start your ministry with Awana, please review and electronically sign the agreement by following this link. <html><body><a href=https://demo.docusign.net/Member/PowerFormSigning.aspx?PowerFormId=0c8621aa-ecbb-4941-bff7-459ad84e15d4&Signer1_Email='+con.Email+'&ChurchName='+a.Name+'&CustID='+a.Mailing_Address_Book__c+'&Signer1_UserName='+conFullName+'&ContactEmail='+con.Email+'">Online Ministry Agreement</a></body></html> YOUR ACCESS CODE: awana';             
       }  
       
       mail.setHtmlBody(body);       
       Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
       //Mayur - Added SOQL to set OwnerId in the task to remove usage of hard code id
       User tagToolUser = [Select Id,Name FROM User WHERE FirstName='Tag' AND LastName='Tools' LIMIT 1];
       Task t = new Task();
       t.OwnerId = tagToolUser.Id;//'005500000035Q0L';
       t.Subject = 'Sent Agreement via Docusign';
       t.ActivityDate =  Date.Today();
       t.Type = 'Registration';
       t.Status = 'Completed';
       t.WhoId = con.Id;
       t.WhatId = accid;
       insert t;
        
       return null;
    }
    
    public PageReference sendToMe() {
       Id accid = ApexPages.currentPage().getParameters().get('id');
       Account a = [select Name, Mailing_Address_Book__c from Account where Id =: accid];      
       Contact con = [select Id,FirstName,LastName,Email from Contact where Id =:account.Applicant__c Limit 1];       
       String conFullName = con.FirstName+' '+con.LastName; 
        
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       String[] toAddresses = new String[] {UserInfo.getUserEmail()}; 
       mail.setToAddresses(toAddresses);
       mail.setReplyTo(UserInfo.getUserEmail());
       mail.setSenderDisplayName('Awana Customer Care');
       mail.setSubject('Please sign this Awana Ministry Agreement');
       
       
       String body;
        
       if(String.isNotBlank(language) && language == 'Spanish'){
           /* PRODUCTION VERSION */
           body='Thank you for your interest in reaching kids with the Gospel! To start your ministry with Awana, please review and electronically sign the agreement by following this link. <html><body><a href="https://www.docusign.net/Member/PowerFormSigning.aspx?PowerFormId=e9f45644-4d95-49bf-9c20-671690e61cb9&Signer1_Email='+con.Email+'&ChurchName='+a.Name+'&CustID='+a.Mailing_Address_Book__c+'&Signer1_UserName='+conFullName+'&ContactEmail='+con.Email+'">Online Ministry Agreement</a></body></html> YOUR ACCESS CODE: awana';                          
           /* DEMO*/
           //body = 'Thank you for your interest in reaching kids with the Gospel! To start your ministry with Awana, please review and electronically sign the agreement by following this link. <html><body><a href=https://demo.docusign.net/Member/PowerFormSigning.aspx?PowerFormId=4433fc3c-54fc-459b-9b51-fa9b767d4965&Signer1_Email='+UserInfo.getUserEmail()+'&ChurchName='+a.Name+'&CustID='+a.Mailing_Address_Book__c+'&Signer1_UserName='+conFullName+'&ContactEmail='+con.Email+'&locale=es">Online Ministry Agreement</a></body></html> YOUR ACCESS CODE: awana';
           
       }else{
           /* PRODUCTION VERSION */
           body='Thank you for your interest in reaching kids with the Gospel! To start your ministry with Awana, please review and electronically sign the agreement by following this link. <html><body><a href="https://www.docusign.net/Member/PowerFormSigning.aspx?PowerFormId=0c8621aa-ecbb-4941-bff7-459ad84e15d4&Signer1_Email='+con.Email+'&ChurchName='+a.Name+'&CustID='+a.Mailing_Address_Book__c+'&Signer1_UserName='+conFullName+'&ContactEmail='+con.Email+'">Online Ministry Agreement</a></body></html> YOUR ACCESS CODE: awana';       
           /* DEMO VERSION */ 
           //body = 'Thank you for your interest in reaching kids with the Gospel! To start your ministry with Awana, please review and electronically sign the agreement by following this link. <html><body><a href=https://demo.docusign.net/Member/PowerFormSigning.aspx?PowerFormId=d19c9d23-5f93-4b62-9af6-596f47eeaf3b&Signer1_Email='+UserInfo.getUserEmail()+'&ChurchName='+a.Name+'&CustID='+a.Mailing_Address_Book__c+'&Signer1_UserName='+conFullName+'&ContactEmail='+con.Email+'&locale=es">Online Ministry Agreement</a></body></html> YOUR ACCESS CODE: awana';
       }  
       
       
       
       /*PRODUCTION VERSION */
       //String body='Thank you for your interest in reaching kids with the Gospel! To start your ministry with Awana, please review and electronically sign the agreement by following this link. <html><body><a href="https://www.docusign.net/Member/PowerFormSigning.aspx?PowerFormId=8b63c624-b8eb-4990-8fb5-8662652c3a1a&Signer1_Email='+UserInfo.getUserEmail()+'&ChurchName='+a.Name+'&CustID='+a.Mailing_Address_Book__c+'&Signer1_UserName='+conFullName+'&ContactEmail='+con.Email+'&locale=es">Online Ministry Agreement</a></body></html> YOUR ACCESS CODE: awana';
       /* DEMO VERSION */
       //String body='Thank you for your interest in reaching kids with the Gospel! To start your ministry with Awana, please review and electronically sign the agreement by following this link. <html><body><a href="https://demo.docusign.net/Member/PowerFormSigning.aspx?PowerFormId=a85dcaa7-2287-4fb4-a30b-2151dabdab79&Signer1_Email='+UserInfo.getUserEmail()+'&ChurchName='+a.Name+'&CustID='+a.Mailing_Address_Book__c+'&Signer1_UserName='+conFullName+'&ContactEmail='+con.Email+'">Online Ministry Agreement</a></body></html> YOUR ACCESS CODE: awana';
       
       mail.setHtmlBody(body);       
       Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
       
       //Mayur - Added SOQL to set OwnerId in the task to remove usage of hard code id
       User tagToolUser = [Select Id,Name FROM User WHERE FirstName='Tag' AND LastName='Tools' LIMIT 1];
       Task t = new Task();
       t.OwnerId = tagToolUser.Id;//'005500000035Q0L';
       t.Subject = 'Sent Agreement via Docusign';
       t.ActivityDate =  Date.Today();
       t.Type = 'Registration';
       t.Status = 'Completed';
       t.WhoId = con.Id;
       t.WhatId = accid;
       insert t;
       
       return null;
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