/***************************************************************************************************************************************************************
    Programmer: Urvashi Dagara
    Company:    Infoglen
    Contact:    urvashi.dagara@infoglen.com
    Description: This controller is reading the Ministry Agreement email received from domain like gmail.outlook ect., 
                 sent by end user on SF email service address.
    
***************************************************************************************************************************************************************/
global class AgreementEmailHandler implements Messaging.InboundEmailHandler {
    
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        
        String conId;        
        String subject = email.subject;
        System.debug('subject==>' + subject);
        String emailAddress = envelope.fromAddress;
        List<Contact> contactList; 
        try{            
            if(String.isNotBlank(subject) && subject.contains('Ref#003')){
                String subString = subject.split('Ref#')[1];
                              
                conId = String.isNotBlank(subString) && subString.startsWith('003') ?  subString.trim() : '';
                system.debug('conId==>'+conId);
                if(string.isNotBlank(conId)){
                    contactList = [SELECT Id,Agreement_Email_Notes__c ,Ministry_Agreement_Status__c,
                                   Agreement_Signed_Date__c,Agreement_Sent_to_Account__c,
                                   Agreement_Sent_to_Account__r.Mailing_Address_Book__c
                                   FROM Contact 
                                   WHERE Id=:conId];
                }
            }else if(string.isBlank(conId) || !conId.startsWith('003')) {
                contactList = [SELECT Id,Agreement_Email_Notes__c,Ministry_Agreement_Status__c,
                               Agreement_Signed_Date__c,Agreement_Sent_to_Account__c,
                               Agreement_Sent_to_Account__r.Mailing_Address_Book__c
                               FROM Contact 
                               WHERE Email =: emailAddress];
                system.debug('contactList==>'+contactList);
                if(contactList.size() > 1){
                    List<String>errorList = new List<String >{'Contact Id not found from Email subject','Multiple contact found in salesforce with reference email address'};
                        //notify customer care team. Multiple contact found with same email                
                        notifyCustomerCareTeam(errorList,emailAddress,null);                    
                }else if(contactList.size() == 1){
                    conId  = contactList[0].id;
                }else if(contactList.size() == 0){
                     List<String>errorList = new List<String >{'Contact Id not found from Email subject','Contact not found in salesforce with reference email address'};
                    //notify customer care team. contact not found.
                    notifyCustomerCareTeam(errorList,emailAddress,null); 
                }    
            }else{
                List<String>errorList = new List<String >{'Contact Id not found from Email subject','Contact not found in salesforce with reference email address'};
                    //notify customer care team. contact not found.
                    notifyCustomerCareTeam(errorList,emailAddress,null); 
            }
            
            if(string.isNotBlank(conId)){
                
                String emailbody = email.plainTextBody == null? (email.htmlBody == null? '': email.htmlBody.stripHtmlTags()): email.plainTextBody;   
                Integer maxSize = 250;
                if (emailbody != null && !contactList.isEmpty()){
                    string userInputText;
                    contactList[0].Ministry_Agreement_Return_Email_Text__c = emailbody;
                    if(emailbody.contains('wrote:') && emailbody.length() > maxSize){
                        userInputText = emailbody.split('wrote:')[0];  
                    }else if(emailbody.contains('From:') && emailbody.length() > maxSize){
                        userInputText = emailbody.split('From:')[0];  
                    }else if(emailbody.contains('Regards') && emailbody.length() > maxSize){
                        userInputText = emailbody.split('Regards')[0];  
                    }else if(emailbody.length() < maxSize || emailbody.length() == maxSize){
                        userInputText = emailbody.trim();
                    } 
                    if(string.isNotBlank(userInputText)){                        
                        if(userInputText.length() > maxSize){
                            userInputText = userInputText.substring(0,maxSize);
                        }                                              
                        contactList[0].Agreement_Email_Notes__c = userInputText.trim();
                    }else{
                        
                        if(emailbody.length() > maxSize ){
                            emailbody = emailbody.substring(0, maxSize);                            
                        }             
                        contactList[0].Agreement_Email_Notes__c = emailbody.trim();
                       
                    }
                    
                }else{
                    contactList[0].Agreement_Email_Notes__c = '';                    
                }
                
                if (email.binaryAttachments != null && email.binaryAttachments.size() > 0) {
                    for (integer i = 0 ; i < email.binaryAttachments.size() ; i++) {
                        Attachment attachment = new Attachment();
                        //attach to the account record
                        system.debug('ParentId==>'+contactList[0].Agreement_Sent_to_Account__c);
                        if(string.isNotBlank(contactList[0].Agreement_Sent_to_Account__c)){
                            attachment.ParentId = contactList[0].Agreement_Sent_to_Account__c;
                        }else{
                            attachment.ParentId = conId;
                        }
                        
                        string attName =  email.binaryAttachments[i].filename;
                        String customerId;
                          
                        if(String.isNotBlank(contactList[0].Agreement_Sent_to_Account__r.Mailing_Address_Book__c)){
                            customerId = contactList[0].Agreement_Sent_to_Account__r.Mailing_Address_Book__c;
                        }       
                        system.debug('customerId==>'+customerId);
                        string extension;
                         if(attName.contains('.pdf')){
                             extension = '.pdf';
                         }else if(attName.contains('.jpg')){
                             extension = '.jpg';
                         }else if(attName.contains('.png')){
                              extension = '.png';
                         }else if(attName.contains('.jpeg')){
                               extension = '.jpeg';
                         }
                        
                        if(attName.contains(extension)){
                            attName = attName.split(extension)[0];
                            if(string.isNotBlank(customerId))
                                attName = attName+'_'+customerId.trim()+extension;
                            else
                                attName = attName+'_'+conId+extension;
                        }
                        //Date appendDate = system.today().format();
                        attachment.Name = attName;
                        attachment.Body = email.binaryAttachments[i].body;
                        insert attachment;
                        contactList[0].Ministry_Agreement_Status__c = 'Received';
                        contactList[0].Agreement_Signed_Date__c = system.now();
                    }
                    
                }else{
                    //notify customer care team.Attachment not found.
                    List<String>errorList = new List<String >{'Attachment Not Found.'};
                        notifyCustomerCareTeam(errorList,emailAddress,conId); 
                    contactList[0].Ministry_Agreement_Status__c = 'Received with Errors';
                    contactList[0].Agreement_Signed_Date__c = system.now();
                }
            }
            if(!contactList.isEmpty() && contactList.size()>0){
                system.debug(contactList[0].Agreement_Email_Notes__c.length());
                update contactList;  
            }
            //system.debug('contactList[0]==>'+contactList[0]);
        }catch(exception e){
            system.debug('error==>'+e);
            system.debug('error==>'+e.getLineNumber());
            List<String>errorList = new List<String >{string.valueOf(e)};
            notifyCustomerCareTeam(errorList,emailAddress,conId);
        }  
        return result;
    }
    
    public static void notifyCustomerCareTeam(List<string> errList,string fromEmail,string conId){
        //system.debug('errList==>'+errList);
        String EmailTemplateId;
        String orgWideId;
        List<String> toAddresses;
        
        List<Membership_Agreement_Settings__c> customSetting = fetchCustomSettingValues();
        
        for(Membership_Agreement_Settings__c mcs : customSetting){
            if(mcs.Name == 'Org Wide Email Id'){
                orgWideId = mcs.value__c;
            }
            
            if(mcs.Name == 'Customer Care Email'){
                toAddresses = mcs.Value__c.split(',');
            }
            
            if(mcs.Name == 'Error Notification Template Id'){
                EmailTemplateId = mcs.Value__c;
            }
        }
        
        EmailTemplate tempID = [SELECT Id,Subject,HTMLValue,Name FROM EmailTemplate WHERE Id =:EmailTemplateId];
        String sub =  tempID.Subject;
        string conFirstName;
        String conLastName;
        String customerId;
        if(String.isNotBlank(conId)){
            List<Contact> con = [SELECT Id,FirstName,LastName,Agreement_Sent_to_Account__r.Mailing_Address_Book__c FROM Contact WHERE Id =: conId];
            if(!con.isEmpty()){             
                sub = updateEmailSubject(sub,con[0]);
                conFirstName = con[0].FirstName;
                conLastName = con[0].LastName;
                customerId = con[0].Agreement_Sent_to_Account__r.Mailing_Address_Book__c;
            }else{
                sub = updateEmailSubject(sub,null);
            }
        }else{
            sub = updateEmailSubject(sub,null);
        }
        
        string plainBody = tempID.HTMLValue;
        string updatedBody =  updateEmailBody(plainBody,conId,fromEmail,errList,conFirstName,conLastName,customerId);   
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        mail.setToAddresses(toAddresses);
        mail.setSubject(sub); 
        mail.setOrgWideEmailAddressId(orgWideId);         
        mail.setHtmlBody(updatedBody); 
        mail.setTemplateId(EmailTemplateId); 
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
    }
    
    public static List<Membership_Agreement_Settings__c> fetchCustomSettingValues(){
        
        return [SELECT Name,Value__c FROM Membership_Agreement_Settings__c];
    }
    
    public Static String updateEmailSubject(String sub,Contact con){
        
        if(con != null){
            if(string.isNotBlank(con.FirstName))
                sub = sub.replace('{Contact_FirstName}',con.FirstName); 
            else
                sub = sub.replace('{Contact_FirstName}','');
            
            sub = sub.replace('{Contact_LastName}',con.LastName);
        }else{
            sub = sub.replace('- {Contact_FirstName}','');     
            sub = sub.replace('{Contact_LastName}','');   
        }
        
        return sub;
        
    }
    
    public Static String updateEmailBody(String emailBody,string conId,String fromEmail,List<string> errList,
                                         String conFirstName,String conLastName,String customerId)
    {
        
        if(string.isNotBlank(conId))
            emailBody = emailBody.replace('Contact_Id',conId);
        else
            emailBody = emailBody.replace('Contact_Id','Not Found');
        
        if(string.isNotBlank(fromEmail))
            emailBody = emailBody.replace('Email_Id',fromEmail);
        
        emailBody = emailBody.replace('Error_1',errList[0]);
        
        if(errList.size() > 1)
            emailBody = emailBody.replace('Error_2',errList[1]);
        else
            emailBody = emailBody.replace('<li><b>Error_2<b></li>','');  
        
        if(string.isNotBlank(conFirstName))
            emailBody = emailBody.replace('Contact_FirstName',conFirstName);
        else
            emailBody = emailBody.replace('Contact_FirstName','');
        
        if(string.isNotBlank(conLastName))    
            emailBody = emailBody.replace('Contact_LastName',conLastName);
        else
            emailBody = emailBody.replace('Contact_LastName','');
        
        if(string.isNotBlank(customerId))
             emailBody = emailBody.replace('Customer_Id',customerId);
        else
            emailBody = emailBody.replace('Customer_Id','');
        
        
        return emailBody;
    } 
    
    
    
}