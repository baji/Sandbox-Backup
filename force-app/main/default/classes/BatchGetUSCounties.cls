/*********************************************************************************************************
    Programmer:         Tony W.
    Company:            Awana
    Contact:            tonyw@awana.org
    Project:            ASP-
    Original:          1/20/2018 - Batch Adding of missing counties for Active US Accounts   
 ***********************************************************************************************************/ 

global class BatchGetUSCounties implements Database.Batchable<sObject>,Database.AllowsCallouts, Database.Stateful {
      // global variables  
    global String query;
    global List<Id> accountIds = new List<Id>();
    global Id aId;
    global class UtilException extends Exception {} 
  
    global database.querylocator start(Database.BatchableContext BC)
    {
        //*****************************************************************************************************************************************************************************p
        //Select All active US Accounts that have no counties
        //NOTE: You don't need to get all Physical address components just the city and state and country should be sufficient: See...
        //Run this URL in your browser as a test: https://maps.googleapis.com/maps/api/geocode/json?key=AIzaSyCxFiaTaRCGV36bpZdwZ2UJTzCuWC3XoX8&address=%27addison,IL%27&sensore=false
        //*****************************************************************************************************************************************************************************
        if(query == null) 
        {
        query 
            = 'Select Id,Physical_City__c,Physical_State__c '
            + 'From Account WHERE Status__c = \'Added\' '
            + ' And Physical_County__c = null'
            + ' And Physical_City__c <> null'
            + ' And Physical_State__c <> null'
            + ' And RecordType.Name like \'%Organization%\'' 
            + ' And Registration_Level__c in (\'R1\',\'R2\',\'R3\')';
        }
        system.debug('<< QUERY  >> '+query);  
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        AccountHelper currIds = null;
        List<Account> accList = new List<Account>();
        List<Account> accountsToUpdate = new List<Account>();
        for(sObject s : scope){
            Account thisAccount = (Account)s;
            accountIds.add(thisAccount.Id);
            system.debug('<<AccountID >> '+thisAccount);
            String address = '';
           
            if(thisAccount.Physical_City__c != null)
                address += thisAccount.Physical_City__c +', ';
            if(thisAccount.Physical_State__c != null)
                address += thisAccount.Physical_State__c +', ';
                address += 'United States';
                
            address = EncodingUtil.urlEncode(address, 'UTF-8');
            
            system.debug('GEOCODE ADDRESS: '+address);
            // NOw Get the COunties and GEO Coordinates
             // build callout
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://maps.googleapis.com/maps/api/geocode/json?key=AIzaSyCxFiaTaRCGV36bpZdwZ2UJTzCuWC3XoX8&address='+address+'&sensor=false');
            req.setMethod('GET');
            req.setTimeout(20000);
          
            try{
                // callout
                HttpResponse res = h.send(req);
                system.debug('******** CallOut Response************'+res);
                // parse coordinates from response
                JSONParser parser = JSON.createParser(res.getBody());
                
                system.debug('HERE IS WHAT IS PARSED '+res.getBody());
                double lat = null;
                double lon = null;
                string county = null;
                Boolean foundCounty = false;
                while (parser.nextToken() != null) { 
                   if(parser.getCurrentToken() == JSONToken.START_ARRAY) { // Get the start of the address_components array which contains th counties
                        //Parse the county  within the JSON string
                        system.debug('<<START ARRAY>> '+parser.getCurrentToken() );
                       while(parser.nextToken() != null && !foundCounty) {// Add boolean sentinel so that we know when to stop. DOn;t want to parse the entirew list just County.
                            if(parser.getCurrentToken() == JSONToken.START_OBJECT) {
                                parser.nextToken();
                                system.debug('<< OBJECT VALUE >> '+parser.getText());
                                While(parser.getCurrentToken() != JSONToken.END_ARRAY && !foundCounty){
                                    parser.nextToken();
                                    
                                    // Check to see if administrative_area_level_2 and if so set foundCOunty = true;
                                    if('administrative_area_level_2' ==parser.getText()){
                                        foundCounty = true;
                                    }else // If county = United states then set foundCOunty = true, set count = No County Was Found
                                    if(county=='United States'){
                                        foundCounty = true;
                                        county='No County Was Found';
                                    }else 
                                        if('types'!=parser.getText() && '[' !=parser.getText() && 'administrative_area_level_2' !=parser.getText()){
                                            county = parser.getText();
                                        system.debug('<< COUNTY EQUALS: >> '+county);
                                    }
                                    system.debug('<< NEXT TOKEN >> '+parser.getText());
                                    
                                }
                                // Assign a value to parser.getText() and look for long_name key of the sub object within in the JSON string 
                                
                                
                                //system.debug('<< Next  Token >> '+parser.getText());
                            }// IF
                                parser.nextToken();
                            }//WHILE
                            
                       }//IF
                     
                    if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) &&
                        (parser.getText() == 'location')){
                           parser.nextToken(); // object start
                           while (parser.nextToken() != JSONToken.END_OBJECT){
                               String txt = parser.getText();
                               parser.nextToken();
                               if (txt == 'lat')
                                   lat = parser.getDoubleValue();
                               else if (txt == 'lng')
                                   lon = parser.getDoubleValue();
                           }
                      
                                            }//IF
                   if(parser.getText() == 'OVER_QUERY_LIMIT'){
                            system.debug(res.getBody());
                        }
                }// OUter While
                // update coordinates if we get back
                if (lat != null){
                   thisAccount.Geolocation__Latitude__s = lat; 
                   thisAccount.Geolocation__Longitude__s = lon;
                   //<ASP-587> - We don't want 'County' suffix string in the string just the county name. 
                   thisAccount.Physical_County__c = county;
                   accList.add(thisAccount);
                }    
               
            }catch (Exception e) {
            }//Catch   
        }// FOR LOOP
        if(accList.size() >0){
            upsert accList; 
        }
  }// Execute Method
  global void finish(Database.BatchableContext BC){
          Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
          
          mail.setToAddresses(new String[] {'tonyw@awana.org'});
          
          mail.setSenderDisplayName('Updated Counties');
          mail.setSubject('Updated Counties');
          mail.setPlainTextBody('US Account County job completed.');
          
          // send email
          Messaging.SendEmailResult[] result = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
          system.debug(result);
  }// Finish Method
  // Inner classes used for serialization by readValuesAs()
  

}