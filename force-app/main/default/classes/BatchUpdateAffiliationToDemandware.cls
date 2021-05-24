/*********************************************************************************************************
    Programmer:         S. A. Baji.
    Company:            Awana
    Contact:            tonyw@awana.org
    Project:            MOZO (SFDC-154)
    Original:          8/24/2016- Used to update Mozo User Lecvel fields of Affiliations back to LMS license.   
 ***********************************************************************************************************/ 

global class BatchUpdateAffiliationToDemandware  implements Database.Batchable<sObject>,Database.AllowsCallouts, Database.Stateful{
    // global variables  
    global String query;
    global List<Id> affUpdateIds = new List<Id>();
    global List<npe5__Affiliation__c> affsToUpdateInFinish = new List<npe5__Affiliation__c>();
    global Id aId;
    global class UtilException extends Exception {} 
  
    global database.querylocator start(Database.BatchableContext BC)
    {
        // Select All Accounts that have Current as their free trail Status
        if(query == null) 
        {
        query 
            = 'Select Id, '
            + ' affiliationBatchFlag__c, npe5__Status__c, ' 
            + '  Mozo_User_Level__c '
            + 'From npe5__Affiliation__c WHERE Mozo_User_Level__c = \'LMS\' '
            + 'And affiliationBatchFlag__c = \'Updated\' ';
        }
        system.debug('<< QUERY  >> '+query);  
        return Database.getQueryLocator(query);
    }
   
  global void execute(Database.BatchableContext BC, List<sObject> scope)
  {
    
    List<npe5__Affiliation__c> affsToUpdate = new List<npe5__Affiliation__c>();
    for(sObject s : scope)
    {
      npe5__Affiliation__c thisAffiliation = (npe5__Affiliation__c)s;
      system.debug('<<DEBUG STATUS >> '+thisAffiliation.Id+' <<ID>> '+thisAffiliation.Mozo_User_Level__c+'<<  Mozo Level  >> '+thisAffiliation.affiliationBatchFlag__c+'<<  Batch Flag >> ');
       
        affsToUpdate.add(thisAffiliation);
        affsToUpdateInFinish.add(thisAffiliation);
        aId = (Id)thisAffiliation.Id;
        system.debug('**************************'+aId);
        affUpdateIds.add(aId);
      
    }
    system.debug('**************************'+affUpdateIds.size());
    system.debug('**************no.of accounts to be updated*******************'+affsToUpdate);
    
    for(npe5__Affiliation__c aff: affsToUpdate)
    {
    
        String affErrorId;
        AccountHelper currIds = null;
        List<npe5__Affiliation__c> affList = new List<npe5__Affiliation__c>();
        affList = [select Id from npe5__Affiliation__c where Id =: aff.Id Limit 1];
        //String exceptionString = 'MethodNot';
        List<String> affStr = new List<String>();
        affStr.add(String.valueOf(affList[0].Id));
        try{
            string accToken='';
            Http http = new Http(); 
            HttpRequest req = new HttpRequest();
            HttpRequest req1 = new HttpRequest();
            HttpRequest reqUpdate = new HttpRequest(); 
            
            for (String ser : affStr)
           {
                
             affErrorId = ser;
             npe5__Affiliation__c af = [SELECT Id,npe5__Status__c,Mozo_User_Level__c FROM npe5__Affiliation__c WHERE id =: ser];
                                
            req.setMethod('POST');
            req.setHeader('Authorization','Basic NjQ3NTMxYTktNzZmYy00ZDNhLThjYTMtNmNlNDA5ZmYxMTcxOjcvWFItQSptYWQsRUpNQE5LZD5s');
            //req.setHeader('Authorization','Basic 923d2a4c-b33b-4e3c-ad0a-370afbd46abb');
            
            req.setHeader('Content-Type','application/x-www-form-urlencoded'); 
            req.setEndpoint('https://account.demandware.com/dw/oauth2/access_token?grant_type=client_credentials'); 
            //req.setEndpoint('https://account.demandware.com/dw/oauth2/access_token?grant_type=client_credentials&user=647531a9-76fc-4d3a-8ca3-6ce409ff1171&password=7/XR-A*mad,EJM@NKd>l'); 
           
                
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
                    //req1.setEndpoint('https://staging-web-awana.demandware.net/s/-/dw/data/v16_3/custom_objects/Affiliation/a1Y500000009iCYEAY');
                    //req1.setEndpoint('https://staging.store.awana.org/s/-/dw/data/v16_3/custom_objects/Affiliation/'+af.Id);
                    req1.setEndpoint('https://store.awana.org/s/-/dw/data/v16_3/custom_objects/Affiliation/'+af.Id);
                  
                    
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
                            jsonObject.put('c_Status', af.npe5__Status__c);
                            jsonObject.put('c_MozoLicenseLevel', af.Mozo_User_Level__c);
                            
                            String JSONString = JSON.serialize(jsonObject);   
                            reqUpdate.setBody(JSONString);
                            system.debug(JSONString);
                            //reqUpdate.setEndpoint('https://staging.store.awana.org/s/-/dw/data/v16_3/custom_objects/Affiliation/'+af.Id);  
                            reqUpdate.setEndpoint('https://store.awana.org/s/-/dw/data/v16_3/custom_objects/Affiliation/'+af.Id);  
                            
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
            String[] toAddresses = new String[] {'shaikbaji.a@ecgroup-intl.com'};
            mail.setToAddresses(toAddresses);
            mail.setReplyTo('shaikbaji.a@ecgroup-intl.com');
            mail.setSenderDisplayName('Salesforce');
            mail.setSubject('Update Failed');
            mail.setPlainTextBody('Affiliation '+affErrorId+' not existed in Demandware');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            affErrorId = null;
        }
      }   
  }

  global void finish(Database.BatchableContext BC)
  {
          Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
          
          mail.setToAddresses(new String[] {'shaikbaji.a@ecgroup-intl.com'});
          //mail.setToAddresses('shaikbaji.a@ecgroup-intl.com');
          
          mail.setSenderDisplayName('Baji Shaik');
          mail.setSubject('Affiliation Update to Demandware');
          mail.setPlainTextBody('Batch Job Update Affiliation to Demandware Finished.');
          
          // send email
          Messaging.SendEmailResult[] result = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
          system.debug('______________________________'+affsToUpdateInFinish.size());
          List<npe5__Affiliation__c> batchAffiliationsUpdate = new List<npe5__Affiliation__c>();
          for(npe5__Affiliation__c aff: affsToUpdateInFinish){       
              aff.affiliationBatchFlag__c = NULL;
              batchAffiliationsUpdate.add(aff);
          }    
          update batchAffiliationsUpdate;
         
  }

}