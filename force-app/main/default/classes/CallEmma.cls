global class CallEmma {
    
    @future (callout=true)
    global static void callEmmaMember(String fname,String lname,String email,String promocode){
        // SFDC Production keys and IDs:
        String emma_accountid = '1790225';
        String publicKey = 'ca6f160a584ef9dd662e';
        String privatekey = 'a763184f87bfcae2d9a0';
        // Emma Test keys and sub-account id - SFDC
        //String emma_accountid = '1795475';
        //String publicKey = '6084953b6dee0761064a';
        //String privatekey ='00db3fbed89a38aacc89';
        String url = 'https://api.e2ma.net/'+emma_accountid+'/members/add';
        //String url = 'https://api.e2ma.net/'+emma_accountid+'/groups/2189244/members';
        Map<String,object> jsonObject = new Map<String,object>();
        Map<String,string> fieldsObject = new Map<String,string>();
        List<integer> groups = new List<integer>();
        groups.add(1983761);
        //groups.add(4124051);        //Emma Testing Group -SFDC
        fieldsObject.put('first_name',fname);
        fieldsObject.put('last_name',lname);
        fieldsObject.put('promo',promocode);
        
        jsonObject.put('email',email);
        jsonObject.put('fields',fieldsObject);
        jsonObject.put('group_ids',groups);
        system.debug('jsonInput:'+jsonObject);
        //building http request for emma
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint(url);
        Blob headerValue = Blob.valueOf(publicKey + ':' + privatekey);
        String authorizationHeader = 'BASIC ' +
        EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);
        req.setHeader('Content-Type','application/json; charset=UTF-8');
        String JSONString = JSON.serialize(jsonObject);   
        req.setBody(JSONString);
        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug(res.getBody());
    }
    
    @InvocableMethod
    public static void getEmmaCampaignMember(List<Id> cmpmemIds){

        CampaignMember cm = [select Id,ContactId,Promo_code__c from CampaignMember where Id IN :cmpmemIds];
        system.debug('**************************************************'+cm.ContactId);
        Contact c = [select FirstName,LastName,Email from Contact where Id =: cm.ContactId];
        system.debug('**************************************************'+c);
        
        CallEmma.callEmmaMember(c.FirstName,c.LastName,c.Email,cm.Promo_code__c);
    }
}