/***********************************************************************************************************************************************************
    Programmers: Shaik A. Baji/ Tony Williams
    Company:    Awana
    Project:    Salesforce SSO
    Original:   5/11/2014  - (S. Baji) Creates a max of 2500  Geo Cooe locations per day for Updated or Created acocunts based on Physical address changes
    Updated:    8/2/2016 (Mike Ltiz) - Added API Google Project and  Public API Server key to override  Google  daily request quota limitations
                (See http://salesforce.stackexchange.com/questions/27566/google-geocoding-api-error-message-you-have-exceeded-when-trying-to-get-la)
    Updated:    09/07/2017 - <ASP-504> - Removed the API Key from the endpoint because we no longer need to run large batch jobs of account records > 2000.
    Updated:    10/117/2017 - <ASP-587> - (Tony W) Parsing JSON results to get the County string to appear on the Account's Physical County string.
  UPdated:  01/29/2018 - <ASP-832> - (Tony W.) Using Smarty Streets Server instead of Google API COncole to get Counties and other meta data (Plus 4)
  
    Called BY:  AccountGeocodesTrigger
  Callout String: https://us-street.api.smartystreets.com/street-address?auth-id=7049d464-e370-9f1d-b52e-22994443e30e&auth-token=jIFOeUuBko6MogYFwkmE&street=5715+S+Settlers+Bay+Dr&city=Wasilla&state=AK&zipcode=99777&
https://us-street.api.smartystreets.com/street-address?auth-id=c66b590f-a4dc-18d5-fa79-ba021b2024b9&auth-token=V6C6CrL8eGlvX4eIilP0&street=5715+S+Settlers+Bay+Dr&city=Wasilla&state=AK&zipcode=99777&
 **********************************************************************************************************************************************************/
global class GeoLocationCallouts{
      
       @future (callout=true) // future method needed to run callouts from Triggers
      
       global static void getLocation(List<String> accountIds){
       
        AccountHelper currIds = null;
        List<Account> accList = new List<Account>();
       
       try
       {
        
           for (String ser : accountIds)
           {
            
             currIDs = (AccountHelper) JSON.deserialize(ser, AccountHelper.class);
             System.debug('Deserialized in future:'+currIds.Id);     
             
             Account a = [SELECT Physical_Street_1__c,Physical_Street_2__c,Physical_City__c,
                                Physical_State__c,Physical_Zip__c,PhysicalCountry__c,
                                Geolocation__Latitude__s,Geolocation__Longitude__s
                                FROM Account WHERE id =: currIds.Id];
                                
            system.debug('GEOCODE ACCT: '+a);       
            String buildAddress = '';
            String address = '';
             if (a.Physical_Street_1__c != null){
              buildAddress = a.Physical_Street_1__c;
                 address += '&street='+EncodingUtil.urlEncode(buildAddress, 'UTF-8');
             }
            if (a.Physical_City__c != null){
               buildAddress = a.Physical_City__c;
                address += '&city='+EncodingUtil.urlEncode(buildAddress, 'UTF-8');
            }
            if (a.Physical_State__c != null){
                buildAddress = a.Physical_State__c;
                address += '&state='+EncodingUtil.urlEncode(buildAddress, 'UTF-8');
            }
            if (a.Physical_Zip__c != null){
                buildAddress =a.Physical_Zip__c;
                 address += '&zipcode='+EncodingUtil.urlEncode(buildAddress, 'UTF-8');
                 address +='&';
                 }
               
            //if (a.PhysicalCountry__c != null)
              //  address += a.PhysicalCountry__c;
            system.debug('GEOCODE ADDRESS: '+address);
           
            // build callout
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            //req.setEndpoint('https://us-street.api.smartystreets.com/street-address?'+address+'&auth-id=7049d464-e370-9f1d-b52e-22994443e30e&auth-token=jIFOeUuBko6MogYFwkmE');   
             req.setEndpoint('https://us-street.api.smartystreets.com/street-address?auth-id=c66b590f-a4dc-18d5-fa79-ba021b2024b9&auth-token=V6C6CrL8eGlvX4eIilP0'+address+'&match=invalid&');
             req.setMethod('GET');
             req.setTimeout(20000);
          String plus4code,zipcode = null;
            try{
                // callout
                HttpResponse res = h.send(req);
                system.debug('******** CallOut Response************'+res);
                // parse coordinates from response
                JSONParser parser = JSON.createParser(res.getBody());
                
                system.debug('HERE IS WHAT IS PARSED '+res.getBody());
                double lat = null;
                double lon = null;
                string county_name,rdi,timezone = null;
                
                Boolean foundLongitude = false;
                Integer plus4 = 0;
                
                parser.nextToken();  // Eat first  START_ARRAY [
                parser.nextToken();  // Eat first  START_OBJECT
                system.debug('<< STARTING OBJECT VALUE >> '+parser.getText());

        while (parser.nextToken() != null ) { // "input_index" token
                    while(parser.getCurrentToken() != JSONToken.START_OBJECT){ //while we have not hit "component" start object yet
                        parser.nextToken();
                    }
                    parser.nextToken(); // get primary_number
                    while(parser.getCurrentToken() != JSONToken.END_OBJECT){ //while we have not hit metadata object yet
                      if(parser.getText() =='plus4_code'){
                          parser.nextToken(); // Get plus4 value
                         plus4code = parser.getText();
                           system.debug('<< PLUS4 VALUE >> '+plus4code);   
                      }
                        parser.nextToken(); // GO to delivery_point field
                    }
                    
                    parser.nextToken(); // Eat Metadata tag in order to point at START_OBJECT - {}
                    while(parser.getCurrentToken() != JSONToken.END_OBJECT){ 
                        if(parser.getText() == 'county_name'){
                          parser.nextToken();
                          county_name = parser.getText();
                          system.debug('<< COUNTY VALUE >> '+county_name);
            } 
                        if(parser.getText() == 'rdi'){
                          parser.nextToken();
                          rdi = parser.getText();
                          system.debug('<< RDI VALUE >> '+rdi);
            }
                        if(parser.getText() == 'latitude'){
                           parser.nextToken();
                           lat = parser.getDoubleValue();
                           system.debug('<< LATITUDE VALUE >> '+lat);
            }
                      if(parser.getText() == 'longitude'){
                          parser.nextToken();
                          lon = parser.getDoubleValue();
                          system.debug('<< LONGITUDE VALUE >> '+lon);
                        
            }
                        if(parser.getText() == 'time_zone'){
                          parser.nextToken();
                          timezone = parser.getText();
                          system.debug('<< TIME ZONE VALUE >> '+timezone);
                        
            }
                        parser.nextToken();
                    }
                    
                   parser.nextToken(); 
        }// WHILE parser.nextToken() != null  
                Boolean validLocation = false;
                // update coordinates if we get back. 2) Set the flag to true here because if you can't locate a residence everything else will probably be false due to a JSON empty set
                if (lat != null){
                    a.Geolocation__Latitude__s = lat; 
                     a.Geolocation__Longitude__s = lon;
                    validLocation = true;     
                }
                if(county_name != null){
                   a.Physical_County__c = county_name;
                }
                if(rdi != null){
                  a.RDI__c = rdi;
                }
                if(plus4code != null){
                   a.Plus4_Code__c = plus4code;
                }  
                if(timezone != null){
                   a.Time_Zone__c = timezone;
                }  
                if(validLocation == true){
                   accList.add(a); 
                }          
            }//Try 
              
            catch (Exception e) {
            }//Catch                  
        }//For Loop
    }//outer Try
    catch(Exception e){
    }
   if(accList.size() >  0){
       upsert accList;        
    }
     
  }//Method 

}//Class