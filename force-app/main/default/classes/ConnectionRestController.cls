@RestResource(urlMapping='/Connections/*')
global class ConnectionRestController{
    @HttpGet
    global static List<npe5__Affiliation__c> displayConnections()
    {
        RestRequest req = RestContext.request;
        ID contactId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        List<npe5__Affiliation__c> affiliationList = [select Awana_Role__c,Church_Role__c,npe5__Contact__r.Name,npe5__Organization__r.Name,Other_Role__c,npe5__Status__c  From npe5__Affiliation__c where npe5__Contact__c=:contactId];
        return affiliationList;
    }//Get Method
    
    @HttpPost
    global static String updateConnections(String affiliationId,String awanaRole,String churchRole,String otherRole,String status)
    {
         try{            npe5__Affiliation__c affiliationUpdate;
            if(affiliationId != null){
                affiliationUpdate = [select Awana_Role__c,Church_Role__c,npe5__Contact__c,npe5__Organization__c,Other_Role__c,npe5__Status__c  From npe5__Affiliation__c where Id =: affiliationId ];
                /*
                if(awanaRole != null){
                    if(affiliationUpdate.Awana_Role__c != null){
                        affiliationUpdate.Awana_Role__c += awanaRole;
                    }
                    else{
                        affiliationUpdate.Awana_Role__c = awanaRole;
                    }
                }
                if(churchRole != null){
                    affiliationUpdate.Church_Role__c = churchRole;
                }        
                if(otherRole != null){
                    affiliationUpdate.Other_Role__c = otherRole;
                }
                if(status != null){
                    affiliationUpdate.npe5__Status__c = status;
                }
                */
                affiliationUpdate.Awana_Role__c = awanaRole;
                affiliationUpdate.Church_Role__c = churchRole;
                update affiliationUpdate;
             }//affiliationId
             return 'SUCCESS';
          }//try
          catch(Exception e){
              return String.valueOf(e);
          }      
    }//update connections
    
}//Class