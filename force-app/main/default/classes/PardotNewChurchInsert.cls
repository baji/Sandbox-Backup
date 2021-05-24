/*
Purpose - Code that sets Accounts to prospect 
Author - Baji SAwana1950.
Updated - (TW) <NMM-17> Try/Catch block @ method createAccountTOProspect()
*/
global class PardotNewChurchInsert{
    
    @future (callout=true)
    global static void createProspect(String churchName,String fname,String lname,String contactemail){
        
        String email = 'shaikbaji.a@accionlabs.com.test';
        String password = 'Baji@123';
        String user_key = 'af6ed3052a0753481707d1b0e1a71d8d';
        
        //String email = 'bajibasha.s@accionlabs.com';
        //String password = 'Baji@123';
        //String user_key = '95cc8c08c97fca85947abf71da7fd5f2';
        
        String url = 'https://pi.pardot.com/api/login/version/3/';
        String api_key = '';
        try{
            
            HttpResponse response = httpCallout('https://pi.pardot.com/api/login/version/3?','email='+email+'&password='+password+'&user_key='+ user_key);
            
            /* Parse API Response */
            Dom.Document doc = new Dom.Document();
            doc.load(response.getBody());
            Dom.XMLNode root = doc.getRootElement();
            if(root.getName()=='rsp') {
            system.debug('-----------------'+root.getAttributeValue('stat',''));
                for(Dom.XMLNode node1: root.getChildElements()) {
                    /*
                      if(node1.getName()=='err') {
                        //String err = root.getChildElement('err', null).getText();
                        //String code = root.getChildElement('err', null).getAttribute('code', null);
                        System.debug('::API REQUEST ERROR:: '+code+' - '+err);
                        //return err;
                    }
                    */
                    if(node1.getName()=='api_key') {
                        /* Store API in variable */
                        api_key = root.getChildElement('api_key', null).getText();
                        //return api_key;
                    }
                }
            }//If rsp
            
            if(api_key != '' || api_key != null){
                system.debug('*******API Key******'+api_key);
                system.debug('****sent values*****'+churchName+','+contactemail);
                HttpResponse responseCreate = httpCallout('https://pi.pardot.com/api/prospect/version/3/do/create/email?','api_key='+api_key+'&user_key=af6ed3052a0753481707d1b0e1a71d8d&company='+churchName+'&email='+contactemail+'&first_name='+fname+'&last_name='+lname+'&campaign_id=33691&list_135048=1');
                system.debug('********Create Response*********'+responseCreate);
                
                /* Parse responseCreate Response */
                Dom.Document doc1 = new Dom.Document();
                doc1.load(responseCreate.getBody());
                Dom.XMLNode root1 = doc1.getRootElement();
                if(root1.getName()=='rsp') {
                system.debug('---------Status Value--------'+root1.getAttributeValue('stat',''));
                    if(root1.getAttributeValue('stat','') == 'fail'){
                        //Unable to create prospect in pardot, notify to the check data.
                    }
                }
            }//If api_key
              
        }//try
       catch(Exception ne){
            system.debug('Exception '+ne);
        }//catch
    }
    public static HttpResponse httpCallout(String url, String body){
        HttpRequest     request     = new HttpRequest();
        HttpResponse    response    = new HttpResponse();
        Http            http        = new Http();

        request.setEndPoint(url);
        request.setBody(body);
        request.setMethod('POST');

        /* Try to send the request */
        try {
            response = http.send(request);
            System.debug('::RESPONSE::'+response.getBody());
            return response;
        } catch(System.CalloutException e) {
            System.debug('ERROR: '+ e);
            return null;
        }
    }
    
    @InvocableMethod
    global static void createAccountTOProspect(List<Id> accountId){
        try{
            //Account acc = [select Id,Name,Phone,Physical_Street_1__c,Physical_City__c,Physical_State__c,PhysicalCountry__c,Physical_County__c,Physical_Zip__c,Church_Attendance__c,Language__c,Most_Recent_Date_Added__c,Applicant__c from Account where Id IN :accountId and RecordType.Name =: 'US Organization' Limit 1];
            Account acc = [select Id,Name,Applicant__c from Account where Id IN :accountId and RecordType.Name =: 'US Organization' Limit 1];
            system.debug('***********************Account Details ***************************'+acc);
            Contact c = [select FirstName,LastName,Email from Contact where Id =: acc.Applicant__c];
            system.debug('************************Contact Details **************************'+c);
            //npe5__Affiliation__c aff = [select Id,Church_Role__c from npe5__Affiliation__c where npe5__Contact__c=:c.Id and npe5__Organization__c=:acc.Id];
            //system.debug('************************Affiliation Details **************************'+aff);
            //CallEmma.callEmmaMember(c.FirstName,c.LastName,c.Email,cm.Promo_code__c);
            //PardotNewChurchInsert.createProspect();
            
            PardotNewChurchInsert.createProspect(acc.Name,c.FirstName,c.LastName,c.Email);
            system.debug('***********Order Account ID*************'+accountId);
        }catch(Exception sqe){
            sqe.getMessage();
        }
    }
}