/***************************************************************************************************************************************************************
    Programmer: Urvashi Dagara
    Company:    Infoglen
    Contact:    urvashi.dagara@infoglen.com
    Description: This controller is sending Ministry Agreement to contact.
    
  ***************************************************************************************************************************************************************/

public class SendMembershipAgreement {
    public String language {get;set;}
    public String selectedAccount {get;set;}
    Public Contact con {get;set;}
    public boolean hasError {get;set;}
    
    public SendMembershipAgreement(ApexPages.StandardController controller) {
        
    }
    
    public List<SelectOption> getAccounts() {
        List<SelectOption> options = new List<SelectOption>();
        Id conId = ApexPages.currentPage().getParameters().get('id');
        
        Id accUsRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('US Organization').getRecordTypeId();
        
        List<npe5__Affiliation__c> accounts = [SELECT Id,npe5__Organization__r.Id,npe5__Organization__r.Name,npe5__Organization__r.RecordTypeId,
                                               npe5__Status__c 
                                               FROM npe5__Affiliation__c 
                                               WHERE npe5__Contact__c=:conId];
        
        for(npe5__Affiliation__c affAcc : accounts) {
            String accountName = affAcc.npe5__Organization__r.Name;
            //Id conid = affAcc.npe5__Contact__r.Id;
            Id accId = affAcc.npe5__Organization__r.Id;
            if(affAcc.npe5__Organization__r.RecordTypeId == accUsRecordTypeId && (String.isNotBlank(affAcc.npe5__Status__c) && affAcc.npe5__Status__c == 'Current')){
                options.add(new SelectOption(accId,accountName));
            }
        }
        
        return options;
    }
    
    public static List<Membership_Agreement_Settings__c> fetchCustomSettingValues(){
        
        return [SELECT Name,Value__c FROM Membership_Agreement_Settings__c];
    }
    
    public contact fetchContact(String conId){
        
        return [SELECT Id,FirstName,LastName,Email,Ministry_Agreement_Status__c,
                Agreement_Sent_to_Account__c,Agreement_Sent_Version__c
                FROM Contact 
                WHERE Id =:conId Limit 1];
    }
    
    public Account fetchAccount(){
        
        return [SELECT Id,Name, Mailing_Address_Book__c 
                FROM Account 
                WHERE Id =: selectedAccount];
    }
    
    public PageReference sendAgreement() { 
        
        try{ 
            System.debug('selectedAccount==>'+selectedAccount);
            Id conId = ApexPages.currentPage().getParameters().get('id');
            
            List<Membership_Agreement_Settings__c> customSetting = fetchCustomSettingValues();
            
            String EnglishTemplateId;
            String SpanishTemplateId;
            String orgWideId;
            String docVersion;
            string replyTo;
            for(Membership_Agreement_Settings__c mcs : customSetting){
                if(mcs.Name == 'English Agreement Template Id'){
                    EnglishTemplateId = mcs.value__c;
                } 
                if(mcs.Name == 'Org Wide Email Id'){
                    orgWideId = mcs.value__c;
                }
                if(mcs.Name == 'Spanish Agreement Template Id'){
                    SpanishTemplateId = mcs.value__c;
                }
                if(mcs.Name  == 'Email Service Address'){
                    replyTo = mcs.value__c;
                }
                
            }
            
            con = fetchContact(conId);
            
            Account acc =  fetchAccount();     
            
            EmailTemplate tempID ;
            if(String.isNotBlank(language) && language == 'Spanish'){
                tempID = [SELECT Id,Subject,HTMLValue,Name FROM EmailTemplate WHERE Id =:SpanishTemplateId];
                con.Agreement_Sent_Version__c = 'Spanish';
            }else{
                tempID = [SELECT Id,Subject,HTMLValue,Name FROM EmailTemplate WHERE Id =:EnglishTemplateId];
                con.Agreement_Sent_Version__c = 'English';
            }
            
            Attachment attach = [SELECT Id,ContentType,Name,Body FROM Attachment WHERE parentId =:tempID.Id];
            
            //Create Email file attachment from document
            Messaging.EmailFileAttachment mailAttach = new Messaging.EmailFileAttachment();
            mailAttach.setContentType(attach.ContentType);
            mailAttach.setFileName(attach.Name);
            mailAttach.setInline(false);
            mailAttach.Body = attach.Body;
            
            String emailBody = tempID.HTMLValue; 
            string updatedEmailBody =  updateEmailBody(emailBody,con,acc);
            String[] toAddresses = new String[] {con.Email}; 
            String sub =  tempID.Subject;   
            sub = sub.replace('{!Contact.Id}',con.Id); 
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();  
            
            mail.setSubject(sub); 
            mail.setToAddresses(toAddresses);
            mail.setTargetObjectId(con.Id);            
            mail.setOrgWideEmailAddressId(orgWideId);            
            mail.setHTMLBody(updatedEmailBody);
            mail.setTemplateId(tempID.Id);             
            mail.setSaveAsActivity(true);
            mail.setFileAttachments(new Messaging.EmailFileAttachment[] { mailAttach });
            mail.setReplyTo(replyTo);  
            mail.setUseSignature(false); //Added by Anvesh
            
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            
            con.Ministry_Agreement_Status__c = 'Sent';
            con.Agreement_Email_Notes__c = '';
            con.Agreement_Sent_to_Account__c = acc.Id; 
            con.Ministry_Agreement_Document_Version__c = attach.Name.contains('.pdf') ?  attach.Name.split('.pdf')[0] : attach.Name;
            
            update con;         
            hasError = false;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO ,'Mail Sent Successfully.'));
        } catch (Exception e) {
            system.debug('error==>'+e);
            system.debug('error==>'+e.getLineNumber());
            hasError = true;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,string.valueOf(e)));
        }   
        return null;       
    }
    
    
    public static String updateEmailBody(String emailBody,Contact con,Account acc){
        
        emailBody = emailBody.replace('Church_Name',acc.Name);
        
        if(string.isNotBlank(acc.Mailing_Address_Book__c))
            emailBody = emailBody.replace('{!Contact.Customer_Id__c}',acc.Mailing_Address_Book__c);
        else
            emailBody = emailBody.replace('{!Contact.Customer_Id__c}','');
            
        if(string.isNotBlank(con.FirstName))
            emailBody = emailBody.replace('{!Contact.FirstName}',con.FirstName);
        else
            emailBody = emailBody.replace('{!Contact.FirstName}','');
        
        emailBody = emailBody.replace('{!Contact.LastName}',con.LastName);
        return emailBody;
    }
    
    
    
}