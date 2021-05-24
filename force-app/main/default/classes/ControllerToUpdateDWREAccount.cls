Global class ControllerToUpdateDWREAccount {
    @future (callout=true)
    
      global static void getAccessToken(List<String> accountIds){
      //global static void getAccessToken(){
    //system.debug(accId+' '+MozoTContactId+' '+MozoTStatus+' '+MozoTStartDate+' '+MozoTEndDate);
        String accErrorId;
        AccountHelper currIds = null;
        List<Account> accList = new List<Account>();
        //String exceptionString = 'MethodNot';
        try{
            string accToken='';
            Http http = new Http(); 
            HttpRequest req = new HttpRequest();
            HttpRequest req1 = new HttpRequest();
            HttpRequest reqUpdate = new HttpRequest(); 
            
            for (String ser : accountIds)
           {
            
             currIDs = (AccountHelper) JSON.deserialize(ser, AccountHelper.class);
             System.debug('Deserialized in future:'+currIds.Id);     
             accErrorId = currIds.Id;
             Account a = [SELECT Id,Mozo_Free_Trial_ContactID__c,Mozo_Trial_Status__c,Mozo_Trial_Start_Date__c,Mozo_Trial_End_Date__c FROM Account WHERE id =: currIds.Id];
                                
            req.setMethod('POST');
            req.setHeader('Authorization','Basic NjQ3NTMxYTktNzZmYy00ZDNhLThjYTMtNmNlNDA5ZmYxMTcxOjcvWFItQSptYWQsRUpNQE5LZD5s');
            //req.setHeader('Authorization','Basic 923d2a4c-b33b-4e3c-ad0a-370afbd46abb');
            
            req.setHeader('Content-Type','application/x-www-form-urlencoded');  
            //req.setEndpoint('https://account.demandware.com/dw/oauth2/access_token?grant_type=client_credentials&user=647531a9-76fc-4d3a-8ca3-6ce409ff1171&password=7/XR-A*mad,EJM@NKd>l'); 
            req.setEndpoint('https://account.demandware.com/dw/oauth2/access_token?grant_type=client_credentials');
                HTTPResponse res = http.send(req); 
                JSONParser parser = JSON.createParser(res.getBody());
                while (parser.nextToken() != null) {
                    if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getCurrentName() == 'access_token')) {
                        parser.nextToken();
                        accToken = parser.getText();    
                    }
                }      
                system.debug('-----Demandware Access Token-------'+ accToken);
                if(accToken != null || accToken != ''){
                    req1.setMethod('GET');
                    req1.setHeader('Authorization','Bearer ' + accToken);
                    //req1.setEndpoint('https://staging-web-awana.demandware.net/s/-/dw/data/v16_3/custom_objects/Account/0015000000GUZYzAAP');
                    //req1.setEndpoint('https://staging.store.awana.org/s/-/dw/data/v16_3/custom_objects/Account/'+a.Id);
                    req1.setEndpoint('https://store.awana.org/s/-/dw/data/v16_3/custom_objects/Account/'+a.Id);
                    
                    HTTPResponse res1 = http.send(req1); 
                    system.debug('*******************'+res1.getBody());
                    string[] headerkeys = res1.getHeaderKeys();
                    string headerValue;
                    for(string s : headerkeys){
                        if(s == 'Etag'){
                            headerValue = res1.getHeader(s);
                            system.debug('header: ' + s + ' value: ' + headerValue);
                        }
                    }
                    if(headerValue != '' || headerValue != null){
                        
                        reqUpdate.setHeader('Authorization','Bearer ' + accToken);
                        reqUpdate.setHeader('Content-Type','application/json; charset=UTF-8');
                        reqUpdate.setHeader('If-Match',headerValue);
                        Map<String,object> jsonObject = new Map<String,object>();
                        //jsonObject.put('c_MozoTrialStatus','Current');
                        system.debug('&&&&&&&&&&&&&&&&&&&&'+a.Mozo_Trial_Status__c+'--'+a.Mozo_Free_Trial_ContactID__c+'--'+a.Mozo_Trial_Start_Date__c);
                        jsonObject.put('c_MozoTrialStatus', a.Mozo_Trial_Status__c);
                        jsonObject.put('c_MozoTrialContactID', a.Mozo_Free_Trial_ContactID__c);
                        Integer d = a.Mozo_Trial_Start_Date__c.day();
                        Integer mo = a.Mozo_Trial_Start_Date__c.month();
                        Integer yr = a.Mozo_Trial_Start_Date__c.year();
                        
                        DateTime ST = DateTime.newInstance(yr, mo, d, 12, 0, 0);
                        jsonObject.put('c_MozoTrialStartDate', ST);
                        
                        Integer ed = a.Mozo_Trial_End_Date__c.day();
                        Integer emo = a.Mozo_Trial_End_Date__c.month();
                        Integer eyr = a.Mozo_Trial_End_Date__c.year();
                        
                        DateTime ET = DateTime.newInstance(eyr, emo, ed, 12, 0, 0);
                        
                        jsonObject.put('c_MozoTrialEndDate', ET);
                        String JSONString = JSON.serialize(jsonObject);   
                        reqUpdate.setBody(JSONString);
                        system.debug(JSONString);
                        //reqUpdate.setEndpoint('https://staging.store.awana.org/s/-/dw/data/v16_3/custom_objects/Account/'+a.Id);  
                        reqUpdate.setEndpoint('https://store.awana.org/s/-/dw/data/v16_3/custom_objects/Account/'+a.Id);  
                        
                        
                        reqUpdate.setMethod('POST');
                        reqUpdate.setHeader('x-dw-http-method-override','PATCH');
   
                        
                            HTTPResponse resUpdate = http.send(reqUpdate); 
                            system.debug('*******************'+resUpdate.getBody());
                            
                    }
                }   
           }//for   
        }//try outer
       catch(Exception ne){
            system.debug('Exception '+ne);
            Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {'integrations@awana.org'};
            mail.setToAddresses(toAddresses);
            mail.setReplyTo('shaikbaji.a@ecgroup-intl.com');
            mail.setSenderDisplayName('Salesforce');
            mail.setSubject('Update Failed');
            mail.setPlainTextBody('Account Id: '+accErrorId+' not existed in Demandware');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            accErrorId = null;
        }
    }
}